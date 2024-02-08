// SPDX-License-Identifier: Apache-2.0
use crate::emit_context;
use crate::irgen::binary::Binary;
use crate::sema::ast::{ArrayLength, Contract, Expression, Namespace, RetrieveType, Type};
use inkwell::types::BasicTypeEnum;
use inkwell::values::{BasicValue, BasicValueEnum, FunctionValue, IntValue, PointerValue};
use num_traits::ToPrimitive;

use super::expression::expression;
use super::functions::Vartable;

impl Contract {
    /// Get the storage slot for a variable, possibly from base contract
    pub fn get_storage_slot<'a>(
        &self,
        bin: &Binary<'a>,
        var_contract_no: usize,
        var_no: usize,
    ) -> BasicValueEnum<'a> {
        if let Some(layout) = self
            .layout
            .iter()
            .find(|l| l.contract_no == var_contract_no && l.var_no == var_no)
        {
            let slot = layout.slot.clone().to_u64().unwrap();
            bin.context.i64_type().const_int(slot, false).into()
        } else {
            panic!("get_storage_slot called on non-storage variable");
        }
    }
}

/// Push() method on dynamic array in storage
pub(crate) fn storage_array_push<'a>(
    bin: &Binary<'a>,
    args: &[Expression],
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let mut array_slot = expression(&args[0], bin, func_value, var_table, ns);

    let array_length = storage_load_internal(bin, array_slot);

    let array_length_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            array_length,
            &[bin.context.i64_type().const_int(3, false)],
            "length",
        )
    };

    let array_length = bin
        .builder
        .build_load(bin.context.i64_type(), array_length_ptr, "")
        .into_int_value();

    let elem_ty = args[0].ty().storage_array_elem();

    let push_pos = array_offset(bin, array_slot, array_length, elem_ty.clone(), ns);

    if args.len() == 2 {
        let value = expression(&args[1], bin, func_value, var_table, ns);

        storage_store(bin, &elem_ty, &mut push_pos.clone(), value, func_value, ns);
    }

    // increase length
    let new_length = bin
        .builder
        .build_int_add(array_length, i64_const!(1), "new_length");
    storage_store(
        bin,
        &Type::Uint(32),
        &mut array_slot,
        new_length.into(),
        func_value,
        ns,
    );

    // Dynamic array return value is currently not used.
    push_pos
}

/// Pop() method on dynamic array in storage
pub(crate) fn storage_array_pop<'a>(
    bin: &Binary<'a>,
    args: &[Expression],
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let mut array_slot = expression(&args[0], bin, func_value, var_table, ns);

    let array_length = storage_load_internal(bin, array_slot);
    let array_length_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            array_length,
            &[bin.context.i64_type().const_int(3, false)],
            "length",
        )
    };

    let array_length = bin
        .builder
        .build_load(bin.context.i64_type(), array_length_ptr, "")
        .into_int_value();

    let elem_ty = args[0].ty().storage_array_elem();

    let mut pop_pos = array_offset(bin, array_slot, array_length, elem_ty, ns);

    let elem_ty = args[0].ty().storage_array_elem().deref_any().clone();

    let ret = storage_load(bin, &elem_ty, &mut pop_pos.clone(), func_value, ns);

    // clear the slot pop value
    storage_delete(bin, &elem_ty, &mut pop_pos, func_value, ns);

    // set decrease length
    let new_length = bin
        .builder
        .build_int_sub(array_length, i64_const!(1), "new_length");
    storage_store(
        bin,
        &Type::Uint(32),
        &mut array_slot,
        new_length.into(),
        func_value,
        ns,
    );

    ret
}

pub(crate) fn storage_load<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);

    match ty {
        Type::Ref(ty) => storage_load(bin, ty, slot, function, ns),
        Type::Array(elem_ty, dim) => {
            if let Some(ArrayLength::Fixed(d)) = dim.last() {
                let llvm_ty = bin.llvm_type(ty.deref_any(), ns);

                let ty = ty.array_deref();

                let array_size = bin
                    .context
                    .i64_type()
                    .const_int(ty.memory_size_of(ns).to_u64().unwrap(), false);

                let new_array = bin.heap_malloc(array_size);

                bin.emit_static_loop_with_int(
                    function,
                    i64_zero!(),
                    i64_const!(d.to_u64().unwrap()),
                    slot,
                    |index: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        let elem = unsafe {
                            bin.builder.build_gep(
                                llvm_ty,
                                new_array,
                                &[i64_zero!(), index],
                                "index_access",
                            )
                        };

                        let val = storage_load(bin, &ty, slot, function, ns);

                        // let val = if ty.deref_memory().is_fixed_reference_type() {
                        //     let load_ty = bin.llvm_type(ty.deref_any(), ns);
                        //     bin.builder
                        //         .build_load(load_ty, val.into_pointer_value(), "elem")
                        // } else {
                        //     val
                        // };

                        bin.builder.build_store(elem, val);
                    },
                );

                new_array.into()
            } else {
                let length = storage_load_internal(bin, *slot);

                let length_ptr = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        length,
                        &[bin.context.i64_type().const_int(3, false)],
                        "length",
                    )
                };

                let length = bin
                    .builder
                    .build_load(bin.context.i64_type(), length_ptr, "")
                    .into_int_value();

                let dest = bin.alloca_dynamic_array(function, ty, length, None, false, ns);

                let mut elem_slot = slot_hash(bin, *slot);

                bin.emit_loop_cond_first_with_int(
                    function,
                    i64_zero!(),
                    length,
                    &mut elem_slot,
                    |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        let elem = bin.array_subscript(ty, dest.into(), elem_no, ns);

                        let entry = storage_load(bin, elem_ty, slot, function, ns);

                        // let entry = if elem_ty.deref_memory().is_fixed_reference_type() {
                        //     bin.builder.build_load(
                        //         bin.llvm_type(elem_ty.deref_memory(), ns),
                        //         entry.into_pointer_value(),
                        //         "elem",
                        //     )
                        // } else {
                        //     entry
                        // };

                        bin.builder.build_store(elem, entry);
                    },
                );
                // load
                dest.into()
            }
        }
        Type::Struct(no) => {
            let llvm_ty = bin.llvm_type(ty.deref_any(), ns);
            let struct_size = bin
                .context
                .i64_type()
                .const_int(ty.memory_size_of(ns).to_u64().unwrap(), false);

            let struct_alloca = bin.heap_malloc(struct_size);

            for (i, field) in ns.structs[*no].fields.iter().enumerate() {
                let val = storage_load(bin, &field.ty, slot, function, ns);

                let elem = bin
                    .builder
                    .build_struct_gep(llvm_ty, struct_alloca, i as u32, field.name_as_str())
                    .unwrap();

                bin.builder.build_store(elem, val);
            }

            struct_alloca.into()
        }
        Type::String | Type::DynamicBytes => {
            let ret = get_storage_dynamic_bytes(bin, ty, slot, function, ns);
            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(1, false).into(),
            );
            ret
        }
        Type::Address | Type::Contract(_) | Type::Hash => {
            let ret = storage_load_internal(bin, *slot).into();
            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(1, false).into(),
            );
            ret
        }
        Type::Uint(256) => {
            let high = storage_load_internal(bin, *slot);
            let low = storage_load_internal(bin, slot_offest(bin, *slot, i64_const!(1).into()));
            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(2, false).into(),
            );
            merge_u256(bin, high, low).into()
        }
        Type::Uint(32) | Type::Bool | Type::Enum(_) | Type::Field => {
            let storage_loaded = storage_load_internal(bin, *slot);
            let storage_value_ptr = unsafe {
                bin.builder.build_gep(
                    bin.context.i64_type(),
                    storage_loaded,
                    &[bin.context.i64_type().const_int(3, false)],
                    "",
                )
            };
            let ret =
                bin.builder
                    .build_load(bin.context.i64_type(), storage_value_ptr, "storage_value");
            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(1, false).into(),
            );
            ret
        }
        _ => {
            unimplemented!("load {}", ty.to_string(ns))
        }
    }
}

pub(crate) fn storage_store<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut BasicValueEnum<'a>,
    dest: BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) {
    emit_context!(bin);
    match ty.deref_any() {
        Type::Array(elem_ty, dim) => {
            if let Some(ArrayLength::Fixed(d)) = dim.last() {
                bin.emit_static_loop_with_int(
                    function,
                    i64_zero!(),
                    i64_const!(d.to_u64().unwrap()),
                    slot,
                    |index: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        let mut elem = unsafe {
                            bin.builder.build_gep(
                                bin.llvm_type(ty.deref_any(), ns),
                                dest.into_pointer_value(),
                                &[i64_zero!(), index],
                                "index_access",
                            )
                        };

                        if elem_ty.is_reference_type(ns)
                            && !elem_ty.deref_memory().is_fixed_reference_type()
                        {
                            let load_ty = bin.llvm_type(elem_ty, ns);
                            elem = bin
                                .builder
                                .build_load(load_ty, elem, "")
                                .into_pointer_value();
                        }
                        storage_store(bin, elem_ty, slot, elem.into(), function, ns);

                        if !elem_ty.is_reference_type(ns) {
                            *slot = slot_offest(
                                bin,
                                *slot,
                                bin.context
                                    .i64_type()
                                    .const_int(elem_ty.storage_slots(ns).to_u64().unwrap(), false)
                                    .into(),
                            );
                        }
                    },
                );
            } else {
                // get the length of the our in-memory array

                let previous_length = storage_load_internal(bin, *slot);

                let previous_length_ptr = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        previous_length,
                        &[bin.context.i64_type().const_int(3, false)],
                        "length",
                    )
                };

                let previous_length = bin
                    .builder
                    .build_load(bin.context.i64_type(), previous_length_ptr, "")
                    .into_int_value();

                let llvm_elem_ty = bin.llvm_var_ty(elem_ty, ns);

                let len = bin.vector_len(dest);

                // store new length
                storage_store_internal(bin, *slot, len.into());

                let mut elem_slot = slot_hash(bin, *slot);

                bin.emit_loop_cond_first_with_int(
                    function,
                    i64_zero!(),
                    len,
                    &mut elem_slot,
                    |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        let mut elem = bin.array_subscript(ty, dest, elem_no, ns);

                        if elem_ty.is_reference_type(ns)
                            && !elem_ty.deref_memory().is_fixed_reference_type()
                        {
                            elem = bin
                                .builder
                                .build_load(llvm_elem_ty, elem, "")
                                .into_pointer_value();
                        }

                        storage_store(bin, elem_ty, slot, elem.into(), function, ns);

                        if !elem_ty.is_reference_type(ns) {
                            *slot = slot_offest(
                                bin,
                                *slot,
                                bin.context
                                    .i64_type()
                                    .const_int(elem_ty.storage_slots(ns).to_u64().unwrap(), false)
                                    .into(),
                            );
                        }
                    },
                );

                // we've populated the array with the new values; if the new array is shorter
                // than the previous, clear out the trailing elements
                bin.emit_loop_cond_first_with_int(
                    function,
                    len,
                    previous_length,
                    &mut elem_slot,
                    |_: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        storage_delete(bin, elem_ty, slot, function, ns);

                        if !elem_ty.is_reference_type(ns) {
                            *slot = slot_offest(
                                bin,
                                *slot,
                                bin.context
                                    .i64_type()
                                    .const_int(elem_ty.storage_slots(ns).to_u64().unwrap(), false)
                                    .into(),
                            );
                        }
                    },
                );
            }
        }
        Type::Struct(no) => {
            for (i, field) in ns.structs[*no].fields.iter().enumerate() {
                let elem_ptr = bin
                    .builder
                    .build_struct_gep(
                        bin.llvm_type(ty.deref_any(), ns),
                        dest.into_pointer_value(),
                        i as u32,
                        field.name_as_str(),
                    )
                    .unwrap();
                let elem = bin
                    .builder
                    .build_load(bin.llvm_var_ty(&field.ty, ns), elem_ptr, "");
                storage_store(bin, &field.ty, slot, elem.into(), function, ns);

                if (!field.ty.is_reference_type(ns) || matches!(field.ty, Type::String))
                    && (i != ns.structs[*no].fields.len() - 1)
                {
                    *slot = slot_offest(
                        bin,
                        *slot,
                        bin.context
                            .i64_type()
                            .const_int(field.ty.storage_slots(ns).to_u64().unwrap(), false)
                            .into(),
                    );
                }
            }
        }
        Type::String | Type::DynamicBytes => {
            set_storage_dynamic_bytes(bin, ty, slot, dest, function, ns);
        }
        Type::Uint(256) => {
            let (high_value, low_value) = split_u256(bin, dest.into_pointer_value());
            storage_store_internal(bin, *slot, high_value.as_basic_value_enum());
            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(1, false).into(),
            );
            storage_store_internal(bin, *slot, low_value.as_basic_value_enum());
        }
        Type::Address | Type::Contract(_) | Type::Hash => storage_store_internal(bin, *slot, dest),
        Type::Uint(32) | Type::Bool | Type::Enum(_) | Type::Field => {
            let dest = if dest.is_pointer_value() {
                let m =
                    bin.builder
                        .build_load(bin.context.i64_type(), dest.into_pointer_value(), "");
                m
            } else {
                dest
            };
            storage_store_internal(bin, *slot, dest)
        }
        _ => {
            unimplemented!("{:?}", ty)
        }
    }
}

pub(crate) fn storage_delete<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) {
    emit_context!(bin);
    match ty.deref_any() {
        Type::Array(_, dim) => {
            let ty = ty.array_deref();

            if let Some(ArrayLength::Fixed(d)) = dim.last() {
                bin.emit_static_loop_with_int(
                    function,
                    i64_zero!(),
                    i64_const!(d.to_u64().unwrap()),
                    slot,
                    |_index: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        storage_delete(bin, &ty, slot, function, ns);

                        if !ty.is_reference_type(ns) {
                            *slot = slot_offest(
                                bin,
                                *slot,
                                bin.context
                                    .i64_type()
                                    .const_int(ty.storage_slots(ns).to_u64().unwrap(), false)
                                    .into(),
                            );
                        }
                    },
                );
            } else {
                // dynamic length array load length
                let length_load = storage_load_internal(bin, *slot);

                let length_ptr = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        length_load,
                        &[bin.context.i64_type().const_int(3, false)],
                        "length",
                    )
                };

                let length = bin
                    .builder
                    .build_load(bin.context.i64_type(), length_ptr, "")
                    .into_int_value();

                let mut elem_slot = slot_hash(bin, *slot);

                // now loop from first slot to first slot + length
                bin.emit_loop_cond_first_with_int(
                    function,
                    i64_zero!(),
                    length,
                    &mut elem_slot,
                    |_index: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        storage_delete(bin, &ty, slot, function, ns);

                        if !ty.is_reference_type(ns) {
                            *slot = slot_offest(
                                bin,
                                *slot,
                                bin.context
                                    .i64_type()
                                    .const_int(ty.storage_slots(ns).to_u64().unwrap(), false)
                                    .into(),
                            );
                        }
                    },
                );

                // clear length itself
                storage_delete(bin, &Type::Uint(32), slot, function, ns);
            }
        }
        Type::Struct(no) => {
            for (_, field) in ns.structs[*no].fields.iter().enumerate() {
                storage_delete(bin, &field.ty, slot, function, ns);

                if !field.ty.is_reference_type(ns) || matches!(field.ty, Type::String) {
                    *slot = slot_offest(
                        bin,
                        *slot,
                        bin.context
                            .i64_type()
                            .const_int(field.ty.storage_slots(ns).to_u64().unwrap(), false)
                            .into(),
                    );
                }
            }
        }
        Type::Mapping(..) => {
            // nothing to do, step over it
        }
        Type::Uint(256) => {
            storage_delete(bin, &Type::Uint(32), slot, function, ns);
            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(1, false).into(),
            );
            storage_delete(bin, &Type::Uint(32), slot, function, ns);
        }
        _ => {
            storage_clear_internal(bin, *slot);
        }
    }
}

/// Read string and bytes from storage
pub(crate) fn get_storage_dynamic_bytes<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let length_load = storage_load_internal(bin, *slot);

    let length_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            length_load,
            &[bin.context.i64_type().const_int(3, false)],
            "length",
        )
    };

    let length = bin
        .builder
        .build_load(bin.context.i64_type(), length_ptr, "")
        .into_int_value();

    let dest = bin.alloca_dynamic_array(function, ty, length, None, false, ns);
    let mut elem_slot = slot_hash(bin, *slot);

    bin.emit_loop_cond_first_with_int(
        function,
        i64_zero!(),
        length,
        &mut elem_slot,
        |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
            let elem = bin.array_subscript(ty, dest.into(), elem_no, ns);

            let entry = storage_load(bin, &Type::Uint(32), slot, function, ns);

            bin.builder.build_store(elem, entry);
        },
    );
    // load
    dest.into()
}

/// set string and bytes to storage
pub(crate) fn set_storage_dynamic_bytes<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut BasicValueEnum<'a>,
    dest: BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) {
    emit_context!(bin);

    let previous_length = storage_load_internal(bin, *slot);

    let length_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            previous_length,
            &[bin.context.i64_type().const_int(3, false)],
            "length",
        )
    };

    let previous_length = bin
        .builder
        .build_load(bin.context.i64_type(), length_ptr, "")
        .into_int_value();
    // get the length of the our in-memory array
    let len = bin.vector_len(dest);
    // store new length
    storage_store_internal(bin, *slot, len.into());

    let mut elem_slot = slot_hash(bin, *slot);

    bin.emit_loop_cond_first_with_int(
        function,
        i64_zero!(),
        len,
        &mut elem_slot,
        |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
            let elem = bin.array_subscript(ty, dest, elem_no, ns);
            storage_store(bin, &Type::Uint(32), slot, elem.into(), function, ns);

            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(1, false).into(),
            );
        },
    );

    // we've populated the array with the new values; if the new array is shorter
    // than the previous, clear out the trailing elements
    bin.emit_loop_cond_first_with_int(
        function,
        len,
        previous_length,
        &mut elem_slot,
        |_: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
            storage_delete(bin, &Type::Uint(32), slot, function, ns);

            *slot = slot_offest(
                bin,
                *slot,
                bin.context.i64_type().const_int(1, false).into(),
            );
        },
    );
}

pub(crate) fn storage_load_internal<'a>(
    bin: &Binary<'a>,
    key: BasicValueEnum<'a>,
) -> PointerValue<'a> {
    emit_context!(bin);
    let storage_value_ptr = bin.heap_malloc(i64_const!(4));
    let storage_key = match key.get_type() {
        BasicTypeEnum::IntType(..) => uint_to_slot(bin, key),
        _ => key,
    };
    call!(
        "get_storage",
        &[storage_key.into(), storage_value_ptr.into()]
    );
    storage_value_ptr.into()
}

pub(crate) fn storage_clear_internal<'a>(bin: &Binary<'a>, key: BasicValueEnum<'a>) {
    emit_context!(bin);
    let storage_key = match key.get_type() {
        BasicTypeEnum::IntType(..) => uint_to_slot(bin, key),
        _ => key,
    };

    let storage_value_ptr = bin.heap_malloc(i64_const!(4));

    for i in 0..4 {
        let elem_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                storage_value_ptr,
                &[i64_const!(i)],
                "storage_zero_ptr",
            )
        };
        bin.builder.build_store(elem_ptr, i64_zero!());
    }

    call!(
        "set_storage",
        &[storage_key.into(), storage_value_ptr.into()]
    );
}

pub(crate) fn storage_store_internal<'a>(
    bin: &Binary<'a>,
    key: BasicValueEnum<'a>,
    value: BasicValueEnum<'a>,
) {
    emit_context!(bin);
    let storage_key = match key.get_type() {
        BasicTypeEnum::IntType(..) => uint_to_slot(bin, key),
        _ => key,
    };
    let storage_value: BasicValueEnum<'_> = match value.get_type() {
        BasicTypeEnum::IntType(..) => uint_to_slot(bin, value),
        _ => value,
    };
    call!("set_storage", &[storage_key.into(), storage_value.into()]);
}

pub(crate) fn slot_hash<'a>(bin: &Binary<'a>, slot: BasicValueEnum<'a>) -> BasicValueEnum<'a> {
    emit_context!(bin);

    let mut inputs = Vec::with_capacity(1);
    let slot_value = match slot.get_type() {
        BasicTypeEnum::IntType(..) => uint_to_slot(bin, slot),
        _ => slot,
    };
    inputs.push((slot_value.into(), i64_const!(4)));
    bin.poseidon_hash(inputs)
}

pub(crate) fn array_offset<'a>(
    bin: &Binary<'a>,
    start: BasicValueEnum<'a>,
    index: IntValue<'a>,
    elem_ty: Type,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let elem_size = elem_ty.storage_slots(ns);
    let hash_ret = slot_hash(bin, start);
    let last_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            hash_ret.into_pointer_value(),
            &[bin.context.i64_type().const_int(3, false)],
            "hash_value_low",
        )
    };

    let hash_value_low = bin
        .builder
        .build_load(bin.context.i64_type(), last_elem_ptr, "");

    let index_with_size = bin.builder.build_int_mul(
        index,
        bin.context
            .i64_type()
            .const_int(elem_size.to_u64().unwrap(), false),
        "",
    );

    let new_hash_low = bin.builder.build_int_add(
        hash_value_low.into_int_value(),
        index_with_size,
        "storage_array_offset",
    );
    bin.builder.build_store(last_elem_ptr, new_hash_low);
    hash_ret
}

pub(crate) fn slot_offest<'a>(
    bin: &Binary<'a>,
    slot: BasicValueEnum<'a>,
    offset: BasicValueEnum<'a>,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    match slot.get_type() {
        BasicTypeEnum::PointerType(..) => {
            let new_slot = bin.heap_malloc(i64_const!(4));
            bin.memcpy(slot.into_pointer_value(), new_slot, i64_const!(4));
            let last_elem_ptr = unsafe {
                bin.builder.build_gep(
                    bin.context.i64_type(),
                    new_slot,
                    &[bin.context.i64_type().const_int(3, false)],
                    "last_elem_ptr",
                )
            };
            let last_elem = bin
                .builder
                .build_load(bin.context.i64_type(), last_elem_ptr, "");
            let new_elem = bin.builder.build_int_add(
                last_elem.into_int_value(),
                offset.into_int_value(),
                "last_elem",
            );
            bin.builder.build_store(last_elem_ptr, new_elem);
            // for i in 0..4 {
            //     let elem_ptr = unsafe {
            //         bin.builder.build_gep(
            //             bin.context.i64_type(),
            //             new_slot,
            //             &[bin.context.i64_type().const_int(i, false)],
            //             "new_slot_ptr",
            //         )
            //     };
            //     let old_elem_ptr = unsafe {
            //         bin.builder.build_gep(
            //             bin.context.i64_type(),
            //             slot.into_pointer_value(),
            //             &[bin.context.i64_type().const_int(i, false)],
            //             "old_slot_ptr",
            //         )
            //     };
            //     let old_elem =
            //         bin.builder
            //             .build_load(bin.context.i64_type(), old_elem_ptr, "");
            //     if i == 3 {
            //         let new_elem = bin.builder.build_int_add(
            //             old_elem.into_int_value(),
            //             offset.into_int_value(),
            //             "",
            //         );
            //         bin.builder.build_store(elem_ptr, new_elem);
            //     } else {
            //         bin.builder.build_store(elem_ptr, old_elem);
            //     }
            // }
            new_slot.into()
        }
        _ => bin
            .builder
            .build_int_add(
                slot.into_int_value(),
                offset.into_int_value(),
                "slot_offset",
            )
            .into(),
    }
}

pub fn uint_to_slot<'a>(bin: &Binary<'a>, value: BasicValueEnum<'a>) -> BasicValueEnum<'a> {
    let heap_ptr = bin.heap_malloc(bin.context.i64_type().const_int(4, false));
    for i in 0..3 {
        let elem_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                heap_ptr,
                &[bin.context.i64_type().const_int(i, false)],
                "",
            )
        };
        bin.builder
            .build_store(elem_ptr, bin.context.i64_type().const_zero());
    }
    let last_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            heap_ptr,
            &[bin.context.i64_type().const_int(3, false)],
            "",
        )
    };
    bin.builder
        .build_store(last_elem_ptr, value.into_int_value());
    heap_ptr.into()
}

pub fn split_u256<'a>(
    bin: &Binary<'a>,
    value: PointerValue<'a>,
) -> (PointerValue<'a>, PointerValue<'a>) {
    emit_context!(bin);
    let high = bin.heap_malloc(i64_const!(4));
    bin.memcpy(value, high, i64_const!(4));
    let low = bin.heap_malloc(i64_const!(4));
    bin.memcpy(
        unsafe {
            bin.builder
                .build_gep(bin.context.i64_type(), value, &[i64_const!(4)], "")
        },
        low,
        i64_const!(4),
    );
    (high.into(), low.into())
}

pub fn merge_u256<'a>(
    bin: &Binary<'a>,
    high: PointerValue<'a>,
    low: PointerValue<'a>,
) -> PointerValue<'a> {
    emit_context!(bin);
    let value = bin.heap_malloc(i64_const!(8));
    bin.memcpy(high, value, i64_const!(4));
    bin.memcpy(
        low,
        unsafe {
            bin.builder
                .build_gep(bin.context.i64_type(), value, &[i64_const!(4)], "")
        },
        i64_const!(4),
    );
    value
}
