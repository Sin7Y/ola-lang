// SPDX-License-Identifier: Apache-2.0

use crate::codegen::core::ir::value;
use crate::codegen::isa::ola::lower::bin;
use crate::emit_context;
use crate::irgen::binary::Binary;
use crate::sema::ast::{self, ArrayLength, Contract, Namespace, Type};
use inkwell::types::{BasicType, BasicTypeEnum, IntType};
use inkwell::values::{ArrayValue, BasicValueEnum, FunctionValue, IntValue, PointerValue};
use inkwell::{AddressSpace, IntPredicate};
use num_bigint::BigInt;
use num_traits::{One, ToPrimitive};
use ola_parser::program;

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

// /// Push() method on dynamic array in storage
// pub(crate) fn storage_slots_array_push(
//     loc: &program::Loc,
//     args: &[ast::Expression],
//     cfg: &mut ControlFlowGraph,
//     contract_no: usize,
//     func: Option<&Function>,
//     ns: &Namespace,
//     vartab: &mut Vartable,
//     opt: &Options,
// ) -> Expression {
//     // set array+length to val_expr
//     let slot_ty = ns.storage_type();
//     let length_pos = vartab.temp_anonymous(&slot_ty);

//     let var_expr = expression(&args[0], cfg, contract_no, func, ns, vartab,
// opt);

//     let expr = load_storage(loc, &slot_ty, var_expr.clone(), cfg, vartab);

//     cfg.add(
//         vartab,
//         Instr::Set {
//             loc: program::Loc::Codegen,
//             res: length_pos,
//             expr,
//         },
//     );

//     let elem_ty = args[0].ty().storage_array_elem();

//     let entry_pos = vartab.temp_anonymous(&slot_ty);

//     cfg.add(
//         vartab,
//         Instr::Set {
//             loc: program::Loc::Codegen,
//             res: entry_pos,
//             expr: array_offset(
//                 loc,
//                 Expression::Keccak256 {
//                     loc: *loc,
//                     ty: slot_ty.clone(),
//                     exprs: vec![var_expr.clone()],
//                 },
//                 Expression::Variable {
//                     loc: *loc,
//                     ty: slot_ty.clone(),
//                     var_no: length_pos,
//                 },
//                 elem_ty.clone(),
//                 ns,
//             ),
//         },
//     );

//     if args.len() == 2 {
//         let value = expression(&args[1], cfg, contract_no, func, ns, vartab,
// opt);

//         cfg.add(
//             vartab,
//             Instr::SetStorage {
//                 ty: elem_ty.clone(),
//                 value,
//                 storage: Expression::Variable {
//                     loc: *loc,
//                     ty: slot_ty.clone(),
//                     var_no: entry_pos,
//                 },
//             },
//         );
//     }

//     // increase length
//     let new_length = Expression::Add {
//         loc: *loc,
//         ty: slot_ty.clone(),
//         overflowing: true,
//         left: Box::new(Expression::Variable {
//             loc: *loc,
//             ty: slot_ty.clone(),
//             var_no: length_pos,
//         }),
//         right: Box::new(Expression::NumberLiteral {
//             loc: *loc,
//             ty: slot_ty.clone(),
//             value: BigInt::one(),
//         }),
//     };

//     cfg.add(
//         vartab,
//         Instr::SetStorage {
//             ty: slot_ty,
//             value: new_length,
//             storage: var_expr,
//         },
//     );

//     if args.len() == 1 {
//         Expression::Variable {
//             loc: *loc,
//             ty: elem_ty,
//             var_no: entry_pos,
//         }
//     } else {
//         Expression::Poison
//     }
// }

// /// Pop() method on dynamic array in storage
// pub(crate) fn storage_slots_array_pop(
//     loc: &program::Loc,
//     args: &[ast::Expression],
//     return_ty: &Type,
//     cfg: &mut ControlFlowGraph,
//     contract_no: usize,
//     func: Option<&Function>,
//     ns: &Namespace,
//     vartab: &mut Vartable,
//     opt: &Options,
// ) -> Expression {
//     // set array+length to val_expr
//     let slot_ty = ns.storage_type();
//     let length_ty = ns.storage_type();
//     let length_pos = vartab.temp_anonymous(&slot_ty);

//     let ty = args[0].ty();
//     let var_expr = expression(&args[0], cfg, contract_no, func, ns, vartab,
// opt);

//     let expr = load_storage(loc, &length_ty, var_expr.clone(), cfg, vartab);

//     cfg.add(
//         vartab,
//         Instr::Set {
//             loc: program::Loc::Codegen,
//             res: length_pos,
//             expr,
//         },
//     );

//     let empty_array = cfg.new_basic_block("empty_array".to_string());
//     let has_elements = cfg.new_basic_block("has_elements".to_string());

//     cfg.add(
//         vartab,
//         Instr::BranchCond {
//             cond: Expression::Equal {
//                 loc: *loc,
//                 left: Box::new(Expression::Variable {
//                     loc: *loc,
//                     ty: length_ty.clone(),
//                     var_no: length_pos,
//                 }),
//                 right: Box::new(Expression::NumberLiteral {
//                     loc: *loc,
//                     ty: length_ty.clone(),
//                     value: BigInt::zero(),
//                 }),
//             },
//             true_block: empty_array,
//             false_block: has_elements,
//         },
//     );

//     cfg.set_basic_block(empty_array);

//     cfg.set_basic_block(has_elements);
//     let new_length = vartab.temp_anonymous(&slot_ty);

//     cfg.add(
//         vartab,
//         Instr::Set {
//             loc: program::Loc::Codegen,
//             res: new_length,
//             expr: Expression::Subtract {
//                 loc: *loc,
//                 ty: length_ty.clone(),
//                 overflowing: true,
//                 left: Box::new(Expression::Variable {
//                     loc: *loc,
//                     ty: length_ty.clone(),
//                     var_no: length_pos,
//                 }),
//                 right: Box::new(Expression::NumberLiteral {
//                     loc: *loc,
//                     ty: length_ty,
//                     value: BigInt::one(),
//                 }),
//             },
//         },
//     );

//     // The array element will be loaded before clearing. So, the return
//     // type of pop() is the derefenced array dereference
//     let elem_ty = ty.storage_array_elem().deref_any().clone();
//     let entry_pos = vartab.temp_anonymous(&slot_ty);

//     cfg.add(
//         vartab,
//         Instr::Set {
//             loc: program::Loc::Codegen,
//             res: entry_pos,
//             expr: array_offset(
//                 loc,
//                 Expression::Keccak256 {
//                     loc: *loc,
//                     ty: slot_ty.clone(),
//                     exprs: vec![var_expr.clone()],
//                 },
//                 Expression::Variable {
//                     loc: *loc,
//                     ty: slot_ty.clone(),
//                     var_no: new_length,
//                 },
//                 elem_ty.clone(),
//                 ns,
//             ),
//         },
//     );

//     let val = if *return_ty != Type::Void {
//         let res_pos = vartab.temp_anonymous(&elem_ty);

//         let expr = load_storage(
//             loc,
//             &elem_ty,
//             Expression::Variable {
//                 loc: *loc,
//                 ty: elem_ty.clone(),
//                 var_no: entry_pos,
//             },
//             cfg,
//             vartab,
//         );

//         cfg.add(
//             vartab,
//             Instr::Set {
//                 loc: *loc,
//                 res: res_pos,
//                 expr,
//             },
//         );
//         Expression::Variable {
//             loc: *loc,
//             ty: elem_ty.clone(),
//             var_no: res_pos,
//         }
//     } else {
//         Expression::Undefined {
//             ty: elem_ty.clone(),
//         }
//     };

//     cfg.add(
//         vartab,
//         Instr::ClearStorage {
//             ty: elem_ty,
//             storage: Expression::Variable {
//                 loc: *loc,
//                 ty: slot_ty.clone(),
//                 var_no: entry_pos,
//             },
//         },
//     );

//     // set decrease length
//     cfg.add(
//         vartab,
//         Instr::SetStorage {
//             ty: slot_ty.clone(),
//             value: Expression::Variable {
//                 loc: *loc,
//                 ty: slot_ty,
//                 var_no: new_length,
//             },
//             storage: var_expr,
//         },
//     );

//     val
// }

// /// Push() method on array or bytes in storage
// pub(crate) fn array_push(
//     loc: &program::Loc,
//     args: &[ast::Expression],
//     cfg: &mut ControlFlowGraph,
//     contract_no: usize,
//     func: Option<&Function>,
//     ns: &Namespace,
//     vartab: &mut Vartable,
//     opt: &Options,
// ) -> Expression {
//     let storage = expression(&args[0], cfg, contract_no, func, ns, vartab,
// opt);

//     let mut ty = args[0].ty().storage_array_elem();

//     let value = if args.len() > 1 {
//         Some(expression(
//             &args[1],
//             cfg,
//             contract_no,
//             func,
//             ns,
//             vartab,
//             opt,
//         ))
//     } else {
//         ty.deref_any().default(ns)
//     };

//     if !ty.is_reference_type(ns) {
//         ty = ty.deref_into();
//     }

//     let res = vartab.temp_anonymous(&ty);

//     cfg.add(
//         vartab,
//         Instr::PushStorage {
//             res,
//             ty: ty.deref_any().clone(),
//             storage,
//             value,
//         },
//     );

//     Expression::Variable {
//         loc: *loc,
//         ty,
//         var_no: res,
//     }
// }

// /// Pop() method on array or bytes in storage
// pub fn array_pop(
//     loc: &program::Loc,
//     args: &[ast::Expression],
//     return_ty: &Type,
//     cfg: &mut ControlFlowGraph,
//     contract_no: usize,
//     func: Option<&Function>,
//     ns: &Namespace,
//     vartab: &mut Vartable,
//     opt: &Options,
// ) -> Expression {
//     let storage = expression(&args[0], cfg, contract_no, func, ns, vartab,
// opt);

//     let ty = args[0].ty().storage_array_elem().deref_into();

//     let res = if *return_ty != Type::Void {
//         Some(vartab.temp_anonymous(&ty))
//     } else {
//         None
//     };

//     cfg.add(
//         vartab,
//         Instr::PopStorage {
//             res,
//             ty: ty.clone(),
//             storage,
//         },
//     );

//     if let Some(res) = res {
//         Expression::Variable {
//             loc: *loc,
//             ty,
//             var_no: res,
//         }
//     } else {
//         Expression::Undefined { ty }
//     }
// }

// pub(crate) fn get_storage_address<'a>(
//     binary: &Binary<'a>,
//     slot: PointerValue<'a>,
//     ns: &Namespace,
// ) -> ArrayValue<'a> {
//     emit_context!(binary);

//     let (scratch_buf, scratch_len) = scratch_buf!();

//     binary
//         .builder
//         .build_store(scratch_len, i64_const!(ns.address_length as u64));

//     let exists = seal_get_storage!(
//         slot.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         scratch_len.into()
//     );

//     let exists =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::EQ, exists, i64_zero!(),
// "storage_exists");

//     binary
//         .builder
//         .build_select(
//             exists,
//             binary
//                 .builder
//                 .build_load(binary.address_type(ns), scratch_buf, "address")
//                 .into_array_value(),
//             binary.address_type(ns).const_zero(),
//             "retrieved_address",
//         )
//         .into_array_value()
// }

// pub(crate) fn storage_delete_single_slot(binary: &Binary, slot: PointerValue)
// {     emit_context!(binary);

//     let ret = call!("clear_storage", &[slot.into(), i64_const!(32).into()])
//         .try_as_basic_value()
//         .left()
//         .unwrap()
//         .into_int_value();
// }

fn storage_load_slot<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut IntValue<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    emit_context!(bin);

    match ty {
        // Type::Ref(ty) => storage_load_slot(bin, ty, slot, function, ns),
        // Type::Array(elem_ty, dim) => {
        //     if let Some(ArrayLength::Fixed(d)) = dim.last() {
        //         let llvm_ty = bin.llvm_type(ty.deref_any(), ns);

        //         let ty = ty.array_deref();

        //         let new = bin.build_alloca(function, llvm_ty, "array_literal");

        //         bin.emit_static_loop_with_int(
        //             function,
        //             bin.context.i64_type().const_zero(),
        //             bin.context.i64_type().const_int(d.to_u64().unwrap(), false),
        //             slot,
        //             |index: IntValue<'a>, slot: &mut IntValue<'a>| {
        //                 let elem = unsafe {
        //                     bin.builder.build_gep(
        //                         llvm_ty,
        //                         new,
        //                         &[i64_zero!(), index],
        //                         "index_access",
        //                     )
        //                 };

        //                 let val = storage_load_slot(bin, &ty, slot, function, ns);

        //                 let val = if ty.deref_memory().is_fixed_reference_type() {
        //                     let load_ty = bin.llvm_type(ty.deref_any(), ns);
        //                     bin.builder
        //                         .build_load(load_ty, val.into_pointer_value(), "elem")
        //                 } else {
        //                     val
        //                 };

        //                 bin.builder.build_store(elem, val);
        //             },
        //         );

        //         new.into()
        //     } else {
        //         // iterate over dynamic array
        //         let slot_ty = Type::Uint(32);

        //         let size = storage_load_slot(bin, &slot_ty, slot, function, ns).into_int_value();

        //         let llvm_elem_ty = bin.llvm_field_ty(elem_ty, ns);

        //         let init = bin
        //             .context
        //             .i64_type()
        //             .ptr_type(AddressSpace::default())
        //             .const_null();

        //         let dest = call!("vector_new", &[size.into(), init.into()])
        //             .try_as_basic_value()
        //             .left()
        //             .unwrap()
        //             .into_pointer_value();

        //         // get the slot for the elements
        //         // this hashes in-place
        //         keccak256_hash(
        //             bin,
        //             slot_ptr,
        //             slot.get_type()
        //                 .size_of()
        //                 .const_cast(bin.context.i64_type(), false),
        //             slot_ptr,
        //             ns,
        //         );

        //         let mut elem_slot = bin
        //             .builder
        //             .build_load(slot.get_type(), slot_ptr, "elem_slot")
        //             .into_int_value();

        //         bin.emit_loop_cond_first_with_int(
        //             function,
        //             i64_zero!(),
        //             size,
        //             &mut elem_slot,
        //             |elem_no: IntValue<'a>, slot: &mut IntValue<'a>| {
        //                 let elem = bin.array_subscript(ty, dest, elem_no, ns);

        //                 let entry = storage_load_slot(bin, elem_ty, slot, slot_ptr, function,
        // ns);

        //                 let entry = if elem_ty.deref_memory().is_fixed_reference_type() {
        //                     bin.builder.build_load(
        //                         bin.llvm_type(elem_ty.deref_memory(), ns),
        //                         entry.into_pointer_value(),
        //                         "elem",
        //                     )
        //                 } else {
        //                     entry
        //                 };

        //                 bin.builder.build_store(elem, entry);
        //             },
        //         );
        //         // load
        //         dest.into()
        //     }
        // }
        // Type::Struct(no) => {
        //     let llvm_ty = bin.llvm_type(ty.deref_any(), ns);
        //     let new = bin.build_alloca(function, llvm_ty, "struct_alloca");

        //     for (i, field) in ns.structs[*no].fields.iter().enumerate() {
        //         let val = storage_load_slot(bin, &field.ty, slot, slot_ptr, function, ns);

        //         let elem = unsafe {
        //             bin.builder.build_gep(
        //                 llvm_ty,
        //                 new,
        //                 &[i64_zero!(), i64_const!(i as u64)],
        //                 field.name_as_str(),
        //             )
        //         };

        //         let val = if field.ty.deref_memory().is_fixed_reference_type() {
        //             let load_ty = bin.llvm_type(field.ty.deref_memory(), ns);
        //             bin.builder
        //                 .build_load(load_ty, val.into_pointer_value(), field.name_as_str())
        //         } else {
        //             val
        //         };

        //         bin.builder.build_store(elem, val);
        //     }

        //     new.into()
        // }
        // Type::String => {
        //     let ret = get_storage_string(bin, function, slot);

        //     *slot = bin.builder.build_int_add(
        //         *slot,
        //         bin.number_literal(&Type::Uint(32), &BigInt::one(), ns),
        //         "string",
        //     );

        //     ret.into()
        // }
        // Type::Address | Type::Contract(_) => {
        //     let ret = get_storage_address(bin, slot_ptr, ns);

        //     *slot = bin.builder.build_int_add(
        //         *slot,
        //         bin.number_literal(256, &BigInt::one(), ns),
        //         "string",
        //     );

        //     ret.into()
        // }
        Type::Uint(32) => {
            let ret = get_storage_u32(bin, function, slot.clone());
            *slot = bin.builder.build_int_add(*slot, i64_const!(1), "u32");

            ret.into()
        }
        _ => {
            unimplemented!("load {}", ty.to_string(ns))
        }
    }
}

pub(crate) fn storage_store_slot<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut IntValue<'a>,
    value: BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) {
    match ty.deref_any() {
        // Type::Array(elem_ty, dim) => {
        //     if let Some(ArrayLength::Fixed(d)) = dim.last() {
        //         bin.emit_static_loop_with_int(
        //             function,
        //             bin.context.i64_type().const_zero(),
        //             bin.context.i64_type().const_int(d.to_u64().unwrap(), false),
        //             slot,
        //             |index: IntValue<'a>, slot: &mut IntValue<'a>| {
        //                 let mut elem = unsafe {
        //                     bin.builder.build_gep(
        //                         bin.llvm_type(ty.deref_any(), ns),
        //                         dest.into_pointer_value(),
        //                         &[bin.context.i64_type().const_zero(), index],
        //                         "index_access",
        //                     )
        //                 };

        //                 if elem_ty.is_reference_type(ns)
        //                     && !elem_ty.deref_memory().is_fixed_reference_type()
        //                 {
        //                     let load_ty =
        //                         bin.llvm_type(elem_ty, ns).ptr_type(AddressSpace::default());
        //                     elem = bin
        //                         .builder
        //                         .build_load(load_ty, elem, "")
        //                         .into_pointer_value();
        //                 }

        //                 storage_store_slot(bin, elem_ty, slot, slot_ptr, elem.into(), function,
        // ns);

        //                 if !elem_ty.is_reference_type(ns) {
        //                     *slot = bin.builder.build_int_add(
        //                         *slot,
        //                         bin.number_literal(256, &elem_ty.storage_slots(ns), ns),
        //                         "",
        //                     );
        //                 }
        //             },
        //         );
        //     } else {
        //         // get the length of the our in-memory array
        //         let len = bin.vector_len(dest);

        //         let slot_ty = Type::Uint(256);

        //         // details about our array elements
        //         let llvm_elem_ty = bin.llvm_field_ty(elem_ty, ns);
        //         let elem_size = bin.builder.build_int_truncate(
        //             llvm_elem_ty.size_of().unwrap(),
        //             bin.context.i64_type(),
        //             "size_of",
        //         );

        //         // the previous length of the storage array
        //         // we need this to clear any elements
        //         let previous_size = bin.builder.build_int_truncate(
        //             storage_load_slot(bin, &slot_ty, slot, slot_ptr, function,
        // ns).into_int_value(),             bin.context.i64_type(),
        //             "previous_size",
        //         );

        //         let new_slot = bin
        //             .builder
        //             .build_alloca(bin.llvm_type(&slot_ty, ns).into_int_type(), "new");

        //         // set new length
        //         bin.builder.build_store(
        //             new_slot,
        //             bin.builder.build_int_z_extend(
        //                 len,
        //                 bin.llvm_type(&slot_ty, ns).into_int_type(),
        //                 "",
        //             ),
        //         );

        //         set_storage(bin, slot_ptr, new_slot, bin.llvm_type(&slot_ty, ns));

        //         keccak256_hash(
        //             bin,
        //             slot_ptr,
        //             slot.get_type()
        //                 .size_of()
        //                 .const_cast(bin.context.i64_type(), false),
        //             new_slot,
        //             ns,
        //         );

        //         let mut elem_slot = bin
        //             .builder
        //             .build_load(
        //                 bin.llvm_type(&slot_ty, ns).into_int_type(),
        //                 new_slot,
        //                 "elem_slot",
        //             )
        //             .into_int_value();

        //         bin.emit_loop_cond_first_with_int(
        //             function,
        //             bin.context.i64_type().const_zero(),
        //             len,
        //             &mut elem_slot,
        //             |elem_no: IntValue<'a>, slot: &mut IntValue<'a>| {
        //                 let index = bin.builder.build_int_mul(elem_no, elem_size, "");

        //                 let mut elem = unsafe {
        //                     bin.builder.build_gep(
        //                         bin.llvm_type(ty.deref_any(), ns),
        //                         dest.into_pointer_value(),
        //                         &[
        //                             bin.context.i64_type().const_zero(),
        //                             bin.context.i64_type().const_int(2, false),
        //                             index,
        //                         ],
        //                         "data",
        //                     )
        //                 };

        //                 if elem_ty.is_reference_type(ns)
        //                     && !elem_ty.deref_memory().is_fixed_reference_type()
        //                 {
        //                     elem = bin
        //                         .builder
        //                         .build_load(llvm_elem_ty, elem, "")
        //                         .into_pointer_value();
        //                 }

        //                 storage_store_slot(bin, elem_ty, slot, slot_ptr, elem.into(), function,
        // ns);

        //                 if !elem_ty.is_reference_type(ns) {
        //                     *slot = bin.builder.build_int_add(
        //                         *slot,
        //                         bin.number_literal(256, &elem_ty.storage_slots(ns), ns),
        //                         "",
        //                     );
        //                 }
        //             },
        //         );

        //         // we've populated the array with the new values; if the new array is shorter
        //         // than the previous, clear out the trailing elements
        //         bin.emit_loop_cond_first_with_int(
        //             function,
        //             len,
        //             previous_size,
        //             &mut elem_slot,
        //             |_: IntValue<'a>, slot: &mut IntValue<'a>| {
        //                 storage_delete_slot(bin, elem_ty, slot, slot_ptr, function, ns);

        //                 if !elem_ty.is_reference_type(ns) {
        //                     *slot = bin.builder.build_int_add(
        //                         *slot,
        //                         bin.number_literal(256, &elem_ty.storage_slots(ns), ns),
        //                         "",
        //                     );
        //                 }
        //             },
        //         );
        //     }
        // }
        // Type::Struct(str_ty) => {
        //     for (i, field) in str_ty.definition(ns).fields.iter().enumerate() {
        //         let mut elem = unsafe {
        //             bin.builder.build_gep(
        //                 bin.llvm_type(ty.deref_any(), ns),
        //                 dest.into_pointer_value(),
        //                 &[
        //                     bin.context.i64_type().const_zero(),
        //                     bin.context.i64_type().const_int(i as u64, false),
        //                 ],
        //                 field.name_as_str(),
        //             )
        //         };

        //         if field.ty.is_reference_type(ns) && !field.ty.is_fixed_reference_type() {
        //             let load_ty = bin
        //                 .llvm_type(&field.ty, ns)
        //                 .ptr_type(AddressSpace::default());
        //             elem = bin
        //                 .builder
        //                 .build_load(load_ty, elem, field.name_as_str())
        //                 .into_pointer_value();
        //         }

        //         storage_store_slot(bin, &field.ty, slot, slot_ptr, elem.into(), function, ns);

        //         if !field.ty.is_reference_type(ns)
        //             || matches!(field.ty, Type::String | Type::DynamicBytes)
        //         {
        //             *slot = bin.builder.build_int_add(
        //                 *slot,
        //                 bin.number_literal(256, &field.ty.storage_slots(ns), ns),
        //                 field.name_as_str(),
        //             );
        //         }
        //     }
        // }
        // Type::String | Type::DynamicBytes => {
        //     set_storage_string(bin, function, slot_ptr, dest);
        // }
        // Type::Address | Type::Contract(_) => {
        //     if dest.is_pointer_value() {
        //         set_storage(
        //             bin,
        //             slot_ptr,
        //             dest.into_pointer_value(),
        //             bin.llvm_type(ty, ns),
        //         );
        //     } else {
        //         let address = bin.builder.build_alloca(bin.address_type(ns), "address");

        //         bin.builder.build_store(address, dest.into_array_value());

        //         set_storage(
        //             bin,
        //             slot_ptr,
        //             address,
        //             bin.address_type(ns).as_basic_type_enum(),
        //         );
        //     }
        // }
        Type::Uint(32) => set_storage_u32(bin, function, slot.clone(), value.into_int_value()),
        _ => {
            unimplemented!("store {}", ty.to_string(ns))
        }
    }
}

// pub(crate) fn storage_delete_slot<'a>(
//     bin: &Binary<'a>,
//     ty: &Type,
//     slot: &mut IntValue<'a>,
//     slot_ptr: PointerValue<'a>,
//     function: FunctionValue<'a>,
//     ns: &Namespace,
// ) {
//     match ty.deref_any() {
//         Type::Array(_, dim) => {
//             let ty = ty.array_deref();

//             if let Some(ArrayLength::Fixed(d)) = dim.last() {
//                 bin.emit_static_loop_with_int(
//                     function,
//                     bin.context.i64_type().const_zero(),
//                     bin.context.i64_type().const_int(d.to_u64().unwrap(),
// false),                     slot,
//                     |_index: IntValue<'a>, slot: &mut IntValue<'a>| {
//                         storage_delete_slot(bin, &ty, slot, slot_ptr,
// function, ns);

//                         if !ty.is_reference_type(ns) {
//                             *slot = bin.builder.build_int_add(
//                                 *slot,
//                                 bin.number_literal(256,
// &ty.storage_slots(ns), ns),                                 "",
//                             );
//                         }
//                     },
//                 );
//             } else {
//                 // dynamic length array.
//                 // load length

//                 let slot_ty = bin.context.custom_width_int_type(256);

//                 let buf = bin.builder.build_alloca(slot_ty, "buf");

//                 let length = get_storage_int(bin, function, slot_ptr,
// slot_ty);

//                 // we need to hash the length slot in order to get the slot
// of the first                 // entry of the array
//                 keccak256_hash(
//                     bin,
//                     slot_ptr,
//                     slot.get_type()
//                         .size_of()
//                         .const_cast(bin.context.i64_type(), false),
//                     buf,
//                     ns,
//                 );

//                 let mut entry_slot = bin
//                     .builder
//                     .build_load(slot.get_type(), buf, "entry_slot")
//                     .into_int_value();

//                 // now loop from first slot to first slot + length
//                 bin.emit_loop_cond_first_with_int(
//                     function,
//                     length.get_type().const_zero(),
//                     length,
//                     &mut entry_slot,
//                     |_index: IntValue<'a>, slot: &mut IntValue<'a>| {
//                         storage_delete_slot(bin, &ty, slot, slot_ptr,
// function, ns);

//                         if !ty.is_reference_type(ns) {
//                             *slot = bin.builder.build_int_add(
//                                 *slot,
//                                 bin.number_literal(256,
// &ty.storage_slots(ns), ns),                                 "",
//                             );
//                         }
//                     },
//                 );

//                 // clear length itself
//                 storage_delete_slot(bin, &Type::Uint(256), slot, slot_ptr,
// function, ns);             }
//         }
//         Type::Struct(str_ty) => {
//             for (_, field) in str_ty.definition(ns).fields.iter().enumerate()
// {                 storage_delete_slot(bin, &field.ty, slot, slot_ptr,
// function, ns);

//                 if !field.ty.is_reference_type(ns)
//                     || matches!(field.ty, Type::String | Type::DynamicBytes)
//                 {
//                     *slot = bin.builder.build_int_add(
//                         *slot,
//                         bin.number_literal(256, &field.ty.storage_slots(ns),
// ns),                         field.name_as_str(),
//                     );
//                 }
//             }
//         }
//         Type::Mapping(..) => {
//             // nothing to do, step over it
//         }
//         Type::Uint(32) => {}
//         _ => {
//             unimplemented!("delete {}", ty.to_string(ns))
//         }
//     }
// }

// pub(crate) fn set_storage_string<'a>(
//     binary: &Binary<'a>,
//     function: FunctionValue<'a>,
//     slot: PointerValue<'a>,
//     dest: BasicValueEnum<'a>,
// ) {
//     emit_context!(binary);

//     let len = binary.vector_len(dest);
//     let data = binary.vector_bytes(dest);

//     let exists = binary
//         .builder
//         .build_int_compare(IntPredicate::NE, len, i64_zero!(), "exists");

//     let delete_block = binary.context.append_basic_block(function,
// "delete_block");

//     let set_block = binary.context.append_basic_block(function, "set_block");

//     let done_storage = binary.context.append_basic_block(function,
// "done_storage");

//     binary
//         .builder
//         .build_conditional_branch(exists, set_block, delete_block);

//     binary.builder.position_at_end(set_block);

//     let ret = seal_set_storage!(slot.into(), i64_const!(32).into(),
// data.into(), len.into());

//     binary.builder.build_unconditional_branch(done_storage);

//     binary.builder.position_at_end(delete_block);

//     let ret = call!("clear_storage", &[slot.into(), i64_const!(32).into()])
//         .try_as_basic_value()
//         .left()
//         .unwrap()
//         .into_int_value();

//     binary.builder.build_unconditional_branch(done_storage);

//     binary.builder.position_at_end(done_storage);
// }

/// Read from substrate storage
pub(crate) fn get_storage_u32<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    slot: IntValue<'a>,
) -> IntValue<'a> {
    emit_context!(bin);

    let storage_ret_0 = bin.build_alloca(function, bin.context.i64_type(), "storage_ret_0");
    let storage_ret_1 = bin.build_alloca(function, bin.context.i64_type(), "storage_ret_1");
    let storage_ret_2 = bin.build_alloca(function, bin.context.i64_type(), "storage_ret_2");
    let storage_ret_3 = bin.build_alloca(function, bin.context.i64_type(), "storage_ret_3");

    call!(
        "get_storage",
        &[
            i64_const!(0).into(),
            i64_const!(0).into(),
            i64_const!(0).into(),
            slot.into(),
            storage_ret_3.into(),
            storage_ret_2.into(),
            storage_ret_1.into(),
            storage_ret_0.into()
        ]
    );

    let ret = bin
        .builder
        .build_load(bin.context.i64_type(), storage_ret_0, "storage_ret_0")
        .into_int_value();
    ret
}

/// set u32 value to storage
pub(crate) fn set_storage_u32<'a>(
    bin: &Binary<'a>,
    function: FunctionValue,
    slot: IntValue<'a>,
    value: IntValue<'a>,
) {
    emit_context!(bin);

    call!(
        "set_storage",
        &[
            i64_zero!().into(),
            i64_zero!().into(),
            i64_zero!().into(),
            slot.into(),
            i64_zero!().into(),
            i64_zero!().into(),
            i64_zero!().into(),
            value.into()
        ]
    );
}

// /// Read string from substrate storage
// pub(crate) fn get_storage_string<'a>(
//     binary: &Binary<'a>,
//     function: FunctionValue,
//     slot: BasicValueEnum<'a>,
// ) -> PointerValue<'a> {
//     //1. If the length of the data is less than or equal to 31 bytes,
//     // it is stored in the high-order byte (left-aligned), and the
// lowest-order byte     // stores length 2.

//     //2. If the length of the data exceeds 31 bytes, store length 2 +1 in the
//     // slot, and store data normally in posidon_hash(slot).
//     emit_context!(binary);
//     let value_ptr_0 = binary.build_alloca(function,
// binary.context.i64_type(), "value_0");     let value_ptr_1 =
// binary.build_alloca(function, binary.context.i64_type(), "value_1");
//     let value_ptr_2 = binary.build_alloca(function,
// binary.context.i64_type(), "value_2");     let value_ptr_3 =
// binary.build_alloca(function, binary.context.i64_type(), "value_3");

//     let hash_ret_ptr_0 = binary.build_alloca(function,
// binary.context.i64_type(), "hash_ret_ptr_0");     let hash_ret_ptr_1 =
// binary.build_alloca(function, binary.context.i64_type(), "hash_ret_ptr_1");
//     let hash_ret_ptr_2 = binary.build_alloca(function,
// binary.context.i64_type(), "hash_ret_ptr_2");     let hash_ret_ptr_3 =
// binary.build_alloca(function, binary.context.i64_type(), "hash_ret_ptr_3");

//     // first we get the length of the string
//     call!(
//         "get_storage",
//         &[
//             i64_zero!(),
//             i64_zero!(),
//             i64_zero!(),
//             slot,
//             value_ptr_3,
//             value_ptr_2,
//             value_ptr_1,
//             value_ptr_0
//         ]
//     );
//     let string_len =
//         binary
//             .builder
//             .build_load(binary.context.i64_type(), value_ptr_0,
// "string_len");

//     call!(
//         "poseidon_hash",
//         &[
//             i64_zero!(),
//             i64_zero!(),
//             i64_zero!(),
//             i64_zero!(),
//             i64_zero!(),
//             i64_zero!(),
//             i64_zero!(),
//             slot,
//             hash_ret_ptr_3,
//             hash_ret_ptr_2,
//             hash_ret_ptr_1,
//             hash_ret_ptr_0
//         ]
//     );

//     // Get the real starting position of the string stored through hash
// calculation.     let hash_ret_0 =
//         binary
//             .builder
//             .build_load(binary.context.i64_type(), hash_ret_ptr_0,
// "hash_ret_0");

//     let hash_ret_1 =
//         binary
//             .builder
//             .build_load(binary.context.i64_type(), hash_ret_ptr_1,
// "hash_ret_1");

//     let hash_ret_2 =
//         binary
//             .builder
//             .build_load(binary.context.i64_type(), hash_ret_ptr_2,
// "hash_ret_2");

//     let hash_ret_3 =
//         binary
//             .builder
//             .build_load(binary.context.i64_type(), hash_ret_ptr_3,
// "hash_ret_3");

//     let elem_slot = hash_ret_0;

//     let init = binary
//         .context
//         .i64_type()
//         .ptr_type(AddressSpace::default())
//         .const_null();

//     // string is actually a dynamic array.

//     let elem_ty = Box::new(Type::Uint(32));
//     let ty = &Type::Array(elem_ty, vec![ArrayLength::Dynamic]);

//     let dest = call!("vector_new", &[string_len.into(), init.into()])
//         .try_as_basic_value()
//         .left()
//         .unwrap()
//         .into_pointer_value();

//     binary.emit_static_loop_with_int(
//         function,
//         i64_zero!(),
//         string_len,
//         &mut elem_slot,
//         |elem_no: IntValue<'a>, slot: &mut IntValue<'a>| {
//             let elem = binary.array_subscript(ty, dest, elem_no, ns);

//             let entry = storage_load_slot(binary, &elem_ty, slot, slot_ptr,
// function, ns);

//             let entry = if elem_ty.deref_memory().is_fixed_reference_type() {
//                 binary.builder.build_load(
//                     binary.llvm_type(elem_ty.deref_memory(), ns),
//                     entry.into_pointer_value(),
//                     "elem",
//                 )
//             } else {
//                 entry
//             };

//             binary.builder.build_store(elem, entry);
//         },
//     );
//     // load
//     dest.into()
// }

// /// Read string from substrate storage
// pub(crate) fn get_storage_bytes_subscript<'a>(
//     binary: &Binary<'a>,
//     function: FunctionValue,
//     slot: IntValue<'a>,
//     index: IntValue<'a>,
//     loc: program::Loc,
//     ns: &Namespace,
// ) -> IntValue<'a> {
//     emit_context!(binary);

//     let slot_ptr = binary.builder.build_alloca(slot.get_type(), "slot");
//     binary.builder.build_store(slot_ptr, slot);

//     let (scratch_buf, scratch_len) = scratch_buf!();

//     binary
//         .builder
//         .build_store(scratch_len, i64_const!(SCRATCH_SIZE as u64));

//     let exists = seal_get_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         scratch_len.into()
//     );

//     let exists =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::EQ, exists, i64_zero!(),
// "storage_exists");

//     let length = binary
//         .builder
//         .build_select(
//             exists,
//             binary
//                 .builder
//                 .build_load(binary.context.i64_type(), scratch_len,
// "string_len"),             i64_zero!().into(),
//             "string_length",
//         )
//         .into_int_value();

//     // do bounds check on index
//     let in_range =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::ULT, index, length,
// "index_in_range");

//     let retrieve_block = binary.context.append_basic_block(function,
// "in_range");     let bang_block = binary.context.append_basic_block(function,
// "bang_block");

//     binary
//         .builder
//         .build_conditional_branch(in_range, retrieve_block, bang_block);

//     binary.builder.position_at_end(bang_block);

//     binary.builder.position_at_end(retrieve_block);

//     let offset = unsafe {
//         binary.builder.build_gep(
//             binary.context.i8_type().array_type(SCRATCH_SIZE),
//             binary.scratch.unwrap().as_pointer_value(),
//             &[i64_zero!(), index],
//             "data_offset",
//         )
//     };

//     binary
//         .builder
//         .build_load(binary.context.i8_type(), offset, "value")
//         .into_int_value()
// }

// pub(crate) fn set_storage_bytes_subscript(
//     binary: &Binary,
//     function: FunctionValue,
//     slot: IntValue,
//     index: IntValue,
//     val: IntValue,
//     ns: &Namespace,
//     loc: program::Loc,
// ) {
//     emit_context!(binary);

//     let slot_ptr = binary.builder.build_alloca(slot.get_type(), "slot");
//     binary.builder.build_store(slot_ptr, slot);

//     let (scratch_buf, scratch_len) = scratch_buf!();

//     binary
//         .builder
//         .build_store(scratch_len, i64_const!(SCRATCH_SIZE as u64));

//     let exists = seal_get_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         scratch_len.into()
//     );

//     let exists =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::EQ, exists, i64_zero!(),
// "storage_exists");

//     let length = binary
//         .builder
//         .build_select(
//             exists,
//             binary
//                 .builder
//                 .build_load(binary.context.i64_type(), scratch_len,
// "string_len"),             i64_zero!().into(),
//             "string_length",
//         )
//         .into_int_value();

//     // do bounds check on index
//     let in_range =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::ULT, index, length,
// "index_in_range");

//     let retrieve_block = binary.context.append_basic_block(function,
// "in_range");     let bang_block = binary.context.append_basic_block(function,
// "bang_block");

//     binary
//         .builder
//         .build_conditional_branch(in_range, retrieve_block, bang_block);

//     binary.builder.position_at_end(bang_block);

//     let offset = unsafe {
//         binary.builder.build_gep(
//             binary.context.i8_type().array_type(SCRATCH_SIZE),
//             binary.scratch.unwrap().as_pointer_value(),
//             &[i64_zero!(), index],
//             "data_offset",
//         )
//     };

//     // set the result
//     binary.builder.build_store(offset, val);

//     let ret = seal_set_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         length.into()
//     );
// }

// /// Push a byte onto a bytes string in storage
// pub(crate) fn storage_push<'a>(
//     binary: &Binary<'a>,
//     _function: FunctionValue,
//     _ty: &ast::Type,
//     slot: IntValue<'a>,
//     val: Option<BasicValueEnum<'a>>,
//     _ns: &ast::Namespace,
// ) -> BasicValueEnum<'a> {
//     emit_context!(binary);

//     let val = val.unwrap();

//     let slot_ptr = binary.builder.build_alloca(slot.get_type(), "slot");
//     binary.builder.build_store(slot_ptr, slot);

//     let (scratch_buf, scratch_len) = scratch_buf!();

//     // Since we are going to add one byte, we set the buffer length to one
// less.     // This will trap for us if it does not fit, so we don't have to
// code this     // ourselves
//     binary
//         .builder
//         .build_store(scratch_len, i64_const!(SCRATCH_SIZE as u64 - 1));

//     let exists = seal_get_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         scratch_len.into()
//     );

//     let exists =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::EQ, exists, i64_zero!(),
// "storage_exists");

//     let length = binary
//         .builder
//         .build_select(
//             exists,
//             binary
//                 .builder
//                 .build_load(binary.context.i64_type(), scratch_len,
// "string_len"),             i64_zero!().into(),
//             "string_length",
//         )
//         .into_int_value();

//     // set the result
//     let offset = unsafe {
//         binary.builder.build_gep(
//             binary.context.i8_type().array_type(SCRATCH_SIZE),
//             binary.scratch.unwrap().as_pointer_value(),
//             &[i64_zero!(), length],
//             "data_offset",
//         )
//     };

//     binary.builder.build_store(offset, val);

//     // Set the new length
//     let length = binary
//         .builder
//         .build_int_add(length, i64_const!(1), "new_length");

//     let ret = seal_set_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         length.into()
//     );

//     val
// }

// /// Pop a value from a bytes string
// pub(crate) fn storage_pop<'a>(
//     binary: &Binary<'a>,
//     function: FunctionValue<'a>,
//     ty: &ast::Type,
//     slot: IntValue<'a>,
//     load: bool,
//     ns: &ast::Namespace,
//     loc: program::Loc,
// ) -> Option<BasicValueEnum<'a>> {
//     emit_context!(binary);

//     let slot_ptr = binary.builder.build_alloca(slot.get_type(), "slot");
//     binary.builder.build_store(slot_ptr, slot);

//     let (scratch_buf, scratch_len) = scratch_buf!();

//     binary
//         .builder
//         .build_store(scratch_len, i64_const!(SCRATCH_SIZE as u64));

//     let exists = seal_get_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         scratch_len.into()
//     );

//     let exists =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::EQ, exists, i64_zero!(),
// "storage_exists");

//     let length = binary
//         .builder
//         .build_select(
//             exists,
//             binary
//                 .builder
//                 .build_load(binary.context.i64_type(), scratch_len,
// "string_len"),             i64_zero!().into(),
//             "string_length",
//         )
//         .into_int_value();

//     // do bounds check on index
//     let in_range =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::NE, i64_zero!(), length,
// "index_in_range");

//     let retrieve_block = binary.context.append_basic_block(function,
// "in_range");     let bang_block = binary.context.append_basic_block(function,
// "bang_block");

//     binary
//         .builder
//         .build_conditional_branch(in_range, retrieve_block, bang_block);

//     binary.builder.position_at_end(bang_block);

//     binary.builder.position_at_end(retrieve_block);

//     // Set the new length
//     let new_length = binary
//         .builder
//         .build_int_sub(length, i64_const!(1), "new_length");

//     let val = if load {
//         let offset = unsafe {
//             binary.builder.build_gep(
//                 binary.context.i8_type().array_type(SCRATCH_SIZE),
//                 binary.scratch.unwrap().as_pointer_value(),
//                 &[i64_zero!(), new_length],
//                 "data_offset",
//             )
//         };

//         Some(
//             binary
//                 .builder
//                 .build_load(binary.llvm_type(ty, ns), offset,
// "popped_value"),         )
//     } else {
//         None
//     };

//     let ret = seal_set_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         new_length.into()
//     );

//     val
// }

// /// Calculate length of storage dynamic bytes(string/bytes)
// pub(crate) fn storage_array_length<'a>(
//     binary: &Binary<'a>,
//     _function: FunctionValue,
//     slot: IntValue<'a>,
//     _ty: &ast::Type,
//     _ns: &ast::Namespace,
// ) -> IntValue<'a> {
//     emit_context!(binary);

//     let slot_ptr = binary.builder.build_alloca(slot.get_type(), "slot");
//     binary.builder.build_store(slot_ptr, slot);

//     let (scratch_buf, scratch_len) = scratch_buf!();

//     binary
//         .builder
//         .build_store(scratch_len, i64_const!(SCRATCH_SIZE as u64));

//     let exists = seal_get_storage!(
//         slot_ptr.into(),
//         i64_const!(32).into(),
//         scratch_buf.into(),
//         scratch_len.into()
//     );

//     let exists =
//         binary
//             .builder
//             .build_int_compare(IntPredicate::EQ, exists, i64_zero!(),
// "storage_exists");

//     binary
//         .builder
//         .build_select(
//             exists,
//             binary
//                 .builder
//                 .build_load(binary.context.i64_type(), scratch_len,
// "string_len"),             i64_zero!().into(),
//             "string_length",
//         )
//         .into_int_value()
// }

pub(crate) fn storage_load<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    // let slot_ptr = binary.builder.build_alloca(slot.get_type(), "slot");

    storage_load_slot(bin, ty, &mut slot.into_int_value(), function, ns)
}

pub(crate) fn storage_store<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    slot: &mut BasicValueEnum<'a>,
    value: BasicValueEnum<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) {
    // let slot_ptr = binary.builder.build_alloca(slot.get_type(), "slot");

    storage_store_slot(bin, ty, &mut slot.into_int_value(), value, function, ns);
}

// pub(crate) fn hash_add<'a>(
//     binary: &Binary<'a>,
//     index: IntValue<'a>,
//     hash_low: IntValue<'a>,
// ) -> IntValue<'a> {
//     emit_context!(binary);

//     let ret = binary.builder.build_int_add(hash_low, index, "hash_add");
// }
