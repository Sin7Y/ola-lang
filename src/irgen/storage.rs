use std::vec;

// SPDX-License-Identifier: Apache-2.0
use crate::emit_context;
use crate::irgen::binary::Binary;
use crate::sema::ast::{ArrayLength, Contract, Expression, Namespace, RetrieveType, Type};
use inkwell::types::{BasicType, BasicTypeEnum};
use inkwell::values::{BasicValueEnum, FunctionValue, IntValue, PointerValue};
use inkwell::AddressSpace;
use num_traits::ToPrimitive;

use super::expression::expression;
use super::functions::FunctionContext;

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
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let mut array_slot = expression(&args[0], bin, func_context, ns);

    let array_length = storage_load(
        bin,
        &Type::Uint(32),
        &mut array_slot,
        func_context.func_val,
        ns,
    );

    let elem_ty = args[0].ty().storage_array_elem();

    let mut push_pos = array_offset(bin, func_context.func_val, array_slot, array_length);

    if args.len() == 2 {
        let value = expression(&args[1], bin, func_context, ns);

        storage_store(
            bin,
            &elem_ty,
            &mut push_pos,
            value,
            func_context.func_val,
            ns,
        );
    }

    // increase length
    let new_length = bin.builder.build_int_add(
        array_length.into_int_value(),
        i64_const!(1).into(),
        "new_length",
    );
    storage_store(
        bin,
        &Type::Uint(32),
        &mut array_slot,
        new_length.into(),
        func_context.func_val,
        ns,
    );

    if args.len() == 1 {
        push_pos.into()
    } else {
        unreachable!()
    }
}

/// Pop() method on dynamic array in storage
pub(crate) fn storage_array_pop<'a>(
    bin: &Binary<'a>,
    args: &[Expression],
    return_ty: &Type,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let mut array_slot = expression(&args[0], bin, func_context, ns);

    let array_length = storage_load(
        bin,
        &Type::Uint(32),
        &mut array_slot,
        func_context.func_val,
        ns,
    );

    let mut pop_pos = array_offset(bin, func_context.func_val, array_slot, array_length);

    let elem_ty = args[0].ty().storage_array_elem();

    // set decrease length
    let new_length = bin.builder.build_int_sub(
        array_length.into_int_value(),
        i64_const!(1).into(),
        "new_length",
    );
    storage_store(
        bin,
        &Type::Uint(32),
        &mut array_slot,
        new_length.into(),
        func_context.func_val,
        ns,
    );

    // clear the slot store value

    storage_delete(bin, &elem_ty, &mut pop_pos, func_context.func_val, ns);

    if *return_ty != Type::Void {
        storage_load(bin, &elem_ty, &mut pop_pos, func_context.func_val, ns)
    } else {
        unreachable!()
    }
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

                let new_array = bin.build_alloca(function, llvm_ty, "array_literal");

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

                        let val = if ty.deref_memory().is_fixed_reference_type() {
                            let load_ty = bin.llvm_type(ty.deref_any(), ns);
                            bin.builder
                                .build_load(load_ty, val.into_pointer_value(), "elem")
                        } else {
                            val
                        };

                        bin.builder.build_store(elem, val);
                    },
                );

                new_array.into()
            } else {
                let size = storage_load(bin, &Type::Uint(32), slot, function, ns);

                let init = bin
                    .context
                    .i64_type()
                    .ptr_type(AddressSpace::default())
                    .const_null();

                let dest = call!("vector_new", &[size.into(), init.into()]);

                let mut elem_slot = slot_hash(bin, function, *slot);

                bin.emit_loop_cond_first_with_int(
                    function,
                    i64_zero!(),
                    size.into_int_value(),
                    &mut elem_slot,
                    |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        let elem = bin.array_subscript(ty, dest.into_pointer_value(), elem_no, ns);

                        let entry = storage_load(bin, elem_ty, slot, function, ns);

                        let entry = if elem_ty.deref_memory().is_fixed_reference_type() {
                            bin.builder.build_load(
                                bin.llvm_type(elem_ty.deref_memory(), ns),
                                entry.into_pointer_value(),
                                "elem",
                            )
                        } else {
                            entry
                        };

                        bin.builder.build_store(elem, entry);
                    },
                );
                // load
                dest.into()
            }
        }
        Type::Struct(no) => {
            let llvm_ty = bin.llvm_type(ty.deref_any(), ns);
            let new_struct = bin.build_alloca(function, llvm_ty, "struct_alloca");

            for (i, field) in ns.structs[*no].fields.iter().enumerate() {
                let val = storage_load(bin, &field.ty, slot, function, ns);

                let elem = unsafe {
                    bin.builder.build_gep(
                        llvm_ty,
                        new_struct,
                        &[i64_zero!(), i64_const!(i as u64)],
                        field.name_as_str(),
                    )
                };

                let val = if field.ty.deref_memory().is_fixed_reference_type() {
                    let load_ty = bin.llvm_type(field.ty.deref_memory(), ns);
                    bin.builder
                        .build_load(load_ty, val.into_pointer_value(), field.name_as_str())
                } else {
                    val
                };

                bin.builder.build_store(elem, val);
            }

            new_struct.into()
        }
        Type::String => {
            let array_ty = Type::Array(Box::new(Type::Uint(32)), vec![ArrayLength::Dynamic]);
            let ret = get_storage_dynamic_bytes(bin, &array_ty, slot, function, ns);

            *slot = bin
                .builder
                .build_int_add(slot.into_int_value(), i64_const!(1), "string")
                .into();

            ret.into()
        }
        Type::Address | Type::Contract(_) => {
            let ret = storage_load_internal(bin, function, *slot);

            *slot = bin
                .builder
                .build_int_add(slot.into_int_value(), i64_const!(1), "address")
                .into();

            ret.into()
        }
        Type::Uint(32) => {
            let ret = storage_load_internal(bin, function, *slot);
            let value = bin
                .builder
                .build_extract_value(ret.into_array_value(), 3, "")
                .unwrap();
            *slot = bin
                .builder
                .build_int_add(slot.into_int_value(), i64_const!(1), "u32")
                .into();
            value
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
                            let load_ty =
                                bin.llvm_type(elem_ty, ns).ptr_type(AddressSpace::default());
                            elem = bin
                                .builder
                                .build_load(load_ty, elem, "")
                                .into_pointer_value();
                        }

                        storage_store(bin, elem_ty, slot, elem.into(), function, ns);

                        if !elem_ty.is_reference_type(ns) {
                            *slot = bin
                                .builder
                                .build_int_add(slot.into_int_value(), i64_const!(1), "")
                                .into();
                        }
                    },
                );
            } else {
                // get the length of the our in-memory array
                let len = bin.vector_len(dest);
                let previous_size =
                    storage_load(bin, &Type::Uint(32), slot, function, ns).into_int_value();

                let llvm_elem_ty = bin.llvm_field_ty(elem_ty, ns);

                let new_slot = bin.builder.build_alloca(bin.context.i64_type(), "new");

                // set new length
                bin.builder.build_store(new_slot, len);

                // store new length
                storage_store(bin, &Type::Uint(32), slot, new_slot.into(), function, ns);

                let mut elem_slot = slot_hash(bin, function, *slot);

                bin.emit_loop_cond_first_with_int(
                    function,
                    i64_zero!(),
                    len,
                    &mut elem_slot,
                    |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        let mut elem = unsafe {
                            bin.builder.build_gep(
                                bin.llvm_type(ty.deref_any(), ns),
                                dest.into_pointer_value(),
                                &[i64_zero!(), i64_const!(1), elem_no],
                                "data",
                            )
                        };

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
                            *slot = bin
                                .builder
                                .build_int_add(slot.into_int_value(), i64_const!(1), "")
                                .into();
                        }
                    },
                );

                // we've populated the array with the new values; if the new array is shorter
                // than the previous, clear out the trailing elements
                bin.emit_loop_cond_first_with_int(
                    function,
                    len,
                    previous_size,
                    &mut elem_slot,
                    |_: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        storage_delete(bin, elem_ty, slot, function, ns);

                        if !elem_ty.is_reference_type(ns) {
                            *slot = bin
                                .builder
                                .build_int_add(slot.into_int_value(), i64_const!(1), "")
                                .into();
                        }
                    },
                );
            }
        }
        Type::Struct(no) => {
            for (i, field) in ns.structs[*no].fields.iter().enumerate() {
                let mut elem = unsafe {
                    bin.builder.build_gep(
                        bin.llvm_type(ty.deref_any(), ns),
                        dest.into_pointer_value(),
                        &[
                            bin.context.i64_type().const_zero(),
                            bin.context.i64_type().const_int(i as u64, false),
                        ],
                        field.name_as_str(),
                    )
                };

                if field.ty.is_reference_type(ns) && !field.ty.is_fixed_reference_type() {
                    let load_ty = bin
                        .llvm_type(&field.ty, ns)
                        .ptr_type(AddressSpace::default());
                    elem = bin
                        .builder
                        .build_load(load_ty, elem, field.name_as_str())
                        .into_pointer_value();
                }

                storage_store(bin, &field.ty, slot, elem.into(), function, ns);

                if !field.ty.is_reference_type(ns) || matches!(field.ty, Type::String) {
                    *slot = bin
                        .builder
                        .build_int_add(slot.into_int_value(), i64_const!(1), field.name_as_str())
                        .into();
                }
            }
        }
        Type::String => {
            let array_ty = Type::Array(Box::new(Type::Uint(32)), vec![ArrayLength::Dynamic]);
            set_storage_dynamic_bytes(bin, &array_ty, slot, dest, function, ns);
        }
        Type::Address | Type::Contract(_) => storage_store_internal(bin, function, *slot, dest),
        Type::Uint(32) => storage_store_internal(bin, function, *slot, dest),
        _ => {
            unimplemented!("store {}", ty.to_string(ns))
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
                            *slot = bin
                                .builder
                                .build_int_add(slot.into_int_value(), i64_const!(1), "")
                                .into();
                        }
                    },
                );
            } else {
                // dynamic length array.
                // load length

                let length =
                    storage_load(bin, &Type::Uint(32), slot, function, ns).into_int_value();
                let mut elem_slot = slot_hash(bin, function, *slot);

                // now loop from first slot to first slot + length
                bin.emit_loop_cond_first_with_int(
                    function,
                    i64_zero!(),
                    length,
                    &mut elem_slot,
                    |_index: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
                        storage_delete(bin, &ty, slot, function, ns);

                        if !ty.is_reference_type(ns) {
                            *slot = bin
                                .builder
                                .build_int_add(slot.into_int_value(), i64_const!(1), "")
                                .into();
                        }
                    },
                );

                // clear length itself
                storage_delete(bin, &Type::Uint(32), slot, function, ns);
            }
        }
        Type::Struct(no) => {
            for (i, field) in ns.structs[*no].fields.iter().enumerate() {
                storage_delete(bin, &field.ty, slot, function, ns);

                if !field.ty.is_reference_type(ns) || matches!(field.ty, Type::String) {
                    *slot = bin
                        .builder
                        .build_int_add(slot.into_int_value(), i64_const!(1), field.name_as_str())
                        .into();
                }
            }
        }
        Type::Mapping(..) => {
            // nothing to do, step over it
        }
        Type::Uint(32) => storage_clear_internal(bin, function, *slot),
        _ => {
            unimplemented!("delete {}", ty.to_string(ns))
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
    let size = storage_load(bin, &Type::Uint(32), slot, function, ns);

    let init = bin
        .context
        .i64_type()
        .ptr_type(AddressSpace::default())
        .const_null();

    let dest = call!("vector_new", &[size.into(), init.into()]);

    let mut elem_slot = slot_hash(bin, function, *slot);

    bin.emit_loop_cond_first_with_int(
        function,
        i64_zero!(),
        size.into_int_value(),
        &mut elem_slot,
        |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
            let elem = bin.array_subscript(ty, dest.into_pointer_value(), elem_no, ns);

            let entry = storage_load(bin, &Type::Uint(32), slot, function, ns);

            bin.builder.build_store(elem, entry);
        },
    );
    // load
    dest
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
    // get the length of the our in-memory array
    let len = bin.vector_len(dest);
    let previous_size = storage_load(bin, &Type::Uint(32), slot, function, ns).into_int_value();

    let new_slot = bin.builder.build_alloca(bin.context.i64_type(), "new");

    // set new length
    bin.builder.build_store(new_slot, len);

    // store new length
    storage_store(bin, &Type::Uint(32), slot, new_slot.into(), function, ns);

    let mut elem_slot = slot_hash(bin, function, *slot);

    bin.emit_loop_cond_first_with_int(
        function,
        i64_zero!(),
        len,
        &mut elem_slot,
        |elem_no: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
            let elem = unsafe {
                bin.builder.build_gep(
                    bin.llvm_type(ty.deref_any(), ns),
                    dest.into_pointer_value(),
                    &[i64_zero!(), i64_const!(1), elem_no],
                    "data",
                )
            };

            storage_store(bin, &Type::Uint(32), slot, elem.into(), function, ns);

            *slot = bin
                .builder
                .build_int_add(slot.into_int_value(), i64_const!(1), "")
                .into();
        },
    );

    // we've populated the array with the new values; if the new array is shorter
    // than the previous, clear out the trailing elements
    bin.emit_loop_cond_first_with_int(
        function,
        len,
        previous_size,
        &mut elem_slot,
        |_: IntValue<'a>, slot: &mut BasicValueEnum<'a>| {
            storage_delete(bin, &Type::Uint(32), slot, function, ns);

            *slot = bin
                .builder
                .build_int_add(slot.into_int_value(), i64_const!(1), "")
                .into();
        },
    );
}

pub(crate) fn storage_load_internal<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    key: BasicValueEnum<'a>,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let storage_key = match key.get_type() {
        BasicTypeEnum::IntType(..) => {
            let storage_key_ptr = bin.build_array_alloca(
                function,
                bin.context.i64_type(),
                i64_const!(4),
                "storage_key_ptr",
            );
            let storage_key = bin
                .builder
                .build_load(array_type!(4), storage_key_ptr, "storage_key")
                .into_array_value();
            for i in 0..3 {
                bin.builder
                    .build_insert_value(storage_key, i64_zero!(), i, "");
            }
            bin.builder.build_insert_value(storage_key, key, 3, "");
            storage_key.into()
        }
        _ => key,
    };
    call!("get_storage", &[storage_key.into()])
}

pub(crate) fn storage_clear_internal<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    key: BasicValueEnum<'a>,
) {
    emit_context!(bin);
    let storage_key = match key.get_type() {
        BasicTypeEnum::IntType(..) => {
            let storage_key_ptr = bin.build_array_alloca(
                function,
                bin.context.i64_type(),
                i64_const!(4),
                "storage_key_ptr",
            );
            let storage_key = bin
                .builder
                .build_load(array_type!(4), storage_key_ptr, "storage_key")
                .into_array_value();
            for i in 0..3 {
                bin.builder
                    .build_insert_value(storage_key, i64_zero!(), i, "");
            }
            bin.builder.build_insert_value(storage_key, key, 3, "");
            storage_key.into()
        }
        _ => key,
    };

    let storage_value_ptr = bin.build_array_alloca(
        function,
        bin.context.i64_type(),
        i64_const!(4),
        "storage_value_ptr",
    );
    let storage_value = bin
        .builder
        .build_load(array_type!(4), storage_value_ptr, "storage_value")
        .into_array_value();
    for i in 0..4 {
        bin.builder
            .build_insert_value(storage_value, i64_zero!(), i, "");
    }

    call!("set_storage", &[storage_key.into(), storage_value.into()]);
}

pub(crate) fn storage_store_internal<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    key: BasicValueEnum<'a>,
    value: BasicValueEnum<'a>,
) {
    emit_context!(bin);
    let storage_key = match key.get_type() {
        BasicTypeEnum::IntType(..) => {
            let storage_key_ptr = bin.build_array_alloca(
                function,
                bin.context.i64_type(),
                i64_const!(4),
                "storage_key_ptr",
            );
            let storage_key = bin
                .builder
                .build_load(array_type!(4), storage_key_ptr, "storage_key")
                .into_array_value();
            for i in 0..3 {
                bin.builder
                    .build_insert_value(storage_key, i64_zero!(), i, "");
            }
            bin.builder.build_insert_value(storage_key, key, 3, "");
            storage_key.into()
        }
        _ => key,
    };
    let storage_value: BasicValueEnum<'_> = match value.get_type() {
        BasicTypeEnum::IntType(..) => {
            let storage_value_ptr = bin.build_array_alloca(
                function,
                bin.context.i64_type(),
                i64_const!(4),
                "storage_value_ptr",
            );
            let storage_value = bin
                .builder
                .build_load(array_type!(4), storage_value_ptr, "storage_value")
                .into_array_value();
            for i in 0..3 {
                bin.builder
                    .build_insert_value(storage_value, i64_zero!(), i, "");
            }
            bin.builder.build_insert_value(storage_value, value, 3, "");
            storage_value.into()
        }
        _ => value,
    };
    call!(
        (),
        "set_storage",
        &[storage_key.into(), storage_value.into()]
    );
}

pub(crate) fn slot_hash<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    slot: BasicValueEnum<'a>,
) -> BasicValueEnum<'a> {
    let mut inputs = vec![slot];
    poseidon_hash(bin, function, &mut inputs)
}

pub(crate) fn poseidon_hash<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    inputs: &mut Vec<BasicValueEnum<'a>>,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let hash_src_ptr = bin.build_array_alloca(
        function,
        bin.context.i64_type(),
        i64_const!(8),
        "hash_src_ptr",
    );
    let hash_src = bin
        .builder
        .build_load(array_type!(8), hash_src_ptr, "hash_src")
        .into_array_value();
    for i in 0..8 {
        bin.builder
            .build_insert_value(hash_src, inputs.pop().unwrap_or(i64_zero!().into()), i, "");
    }
    call!("poseidon_hash", &[hash_src.into(),])
}

pub(crate) fn array_offset<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    start: BasicValueEnum<'a>,
    index: BasicValueEnum<'a>,
) -> BasicValueEnum<'a> {
    emit_context!(bin);
    let hash_ret = slot_hash(bin, function, start);
    let hash_value_0 = bin
        .builder
        .build_extract_value(hash_ret.into_array_value(), 3, "");

    let res = bin.builder.build_int_add(
        hash_value_0.unwrap().into_int_value(),
        index.into_int_value(),
        "",
    );

    bin.builder
        .build_insert_value(hash_ret.into_array_value(), res, 3, "");
    hash_ret
}
