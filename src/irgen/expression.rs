use crate::irgen::binary::Binary;
use crate::irgen::u32_op::{
    u32_add, u32_and, u32_bitwise_and, u32_bitwise_not, u32_bitwise_or, u32_bitwise_xor, u32_div,
    u32_mod, u32_mul, u32_not, u32_or, u32_power, u32_shift_left, u32_shift_right, u32_sub,
};
use crate::sema::ast::{ArrayLength, CallTy, StringLocation};
use inkwell::types::{BasicType, BasicTypeEnum};
use inkwell::values::{
    BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue, IntValue,
};
use inkwell::{AddressSpace, IntPredicate};
use num_bigint::BigInt;
use num_traits::ToPrimitive;
use ola_parser::program;

use crate::sema::{
    ast::{Expression, LibFunc, Namespace, RetrieveType, Type},
    diagnostics::Diagnostics,
    expression::integers::bigint_to_expression,
    expression::ResolveTo,
};

use super::address_op::address_compare;
use super::encoding::{abi_decode, abi_encode};
use super::functions::Vartable;
use super::storage::{
    array_offset, poseidon_hash, slot_offest, storage_array_pop, storage_array_push, storage_load,
    storage_store,
};
use super::strings::string_location;
use super::u32_op::u32_compare;

pub fn expression<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match expr {
        Expression::StorageVariable {
            contract_no,
            var_no,
            ..
        } => {
            // base storage variables should precede contract variables, not overlap
            ns.contracts[*contract_no].get_storage_slot(bin, *contract_no, *var_no)
        }
        Expression::StorageLoad { ty, expr, .. } => {
            let mut slot = expression(expr, bin, func_value, var_table, ns);
            storage_load(bin, ty, &mut slot, func_value, ns)
        }
        Expression::Add { left, right, .. } => u32_add(left, right, bin, func_value, var_table, ns),
        Expression::Subtract { left, right, .. } => {
            u32_sub(left, right, bin, func_value, var_table, ns)
        }
        Expression::Multiply { left, right, .. } => {
            u32_mul(left, right, bin, func_value, var_table, ns)
        }
        Expression::Divide { left, right, .. } => {
            u32_div(left, right, bin, func_value, var_table, ns)
        }
        Expression::Modulo { left, right, .. } => {
            u32_mod(left, right, bin, func_value, var_table, ns)
        }
        Expression::Power { base, exp, .. } => u32_power(base, exp, bin, func_value, var_table, ns),
        Expression::BitwiseOr { left, right, .. } => {
            u32_bitwise_or(left, right, bin, func_value, var_table, ns)
        }
        Expression::BitwiseAnd { left, right, .. } => {
            u32_bitwise_and(left, right, bin, func_value, var_table, ns)
        }
        Expression::BitwiseXor { left, right, .. } => {
            u32_bitwise_xor(left, right, bin, func_value, var_table, ns)
        }
        Expression::ShiftLeft { left, right, .. } => {
            u32_shift_left(left, right, bin, func_value, var_table, ns)
        }
        Expression::ShiftRight { left, right, .. } => {
            u32_shift_right(left, right, bin, func_value, var_table, ns)
        }
        Expression::Equal { left, right, .. } => {
            if left.ty().is_address() {
                address_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::EQ,
                )
            } else {
                u32_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::EQ,
                )
            }
        }
        Expression::NotEqual { left, right, .. } => {
            if left.ty().is_address() {
                address_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::NE,
                )
            } else {
                u32_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::NE,
                )
            }
        }
        Expression::More { left, right, .. } => {
            if left.ty().is_address() {
                address_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::UGT,
                )
            } else {
                u32_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::UGT,
                )
            }
        }
        Expression::MoreEqual { left, right, .. } => {
            if left.ty().is_address() {
                address_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::UGE,
                )
            } else {
                u32_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::UGE,
                )
            }
        }
        Expression::Less { left, right, .. } => {
            if left.ty().is_address() {
                address_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::ULT,
                )
            } else {
                u32_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::ULT,
                )
            }
        }
        Expression::LessEqual { left, right, .. } => {
            if left.ty().is_address() {
                address_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::ULE,
                )
            } else {
                u32_compare(
                    left,
                    right,
                    bin,
                    func_value,
                    var_table,
                    ns,
                    IntPredicate::ULE,
                )
            }
        }

        Expression::Not { expr, .. } => u32_not(expr, bin, func_value, var_table, ns),
        Expression::BitwiseNot { expr, .. } => {
            u32_bitwise_not(expr, bin, func_value, var_table, ns)
        }
        Expression::Or { left, right, .. } => u32_or(left, right, bin, func_value, var_table, ns),
        Expression::And { left, right, .. } => u32_and(left, right, bin, func_value, var_table, ns),

        Expression::Decrement { loc, ty, expr } => {
            let v = match expr.ty() {
                Type::Ref(ty) => {
                    let expr_load = Expression::Load {
                        loc: *loc,
                        ty: ty.as_ref().clone(),
                        expr: expr.clone(),
                    };
                    expression(&expr_load, bin, func_value, var_table, ns)
                }
                Type::StorageRef(ty) => {
                    let mut slot = expression(expr, bin, func_value, var_table, ns);
                    storage_load(bin, ty.as_ref(), &mut slot, func_value, ns)
                }
                _ => expression(expr, bin, func_value, var_table, ns),
            };
            let one = bin.context.i64_type().const_int(1, false);
            let after = bin.builder.build_int_sub(v.into_int_value(), one, "");
            match expr.as_ref() {
                Expression::Variable { var_no, .. } => {
                    let before_ptr = var_table.get(var_no).unwrap();
                    bin.builder
                        .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum());
                    return before_ptr.as_basic_value_enum();
                }
                _ => {
                    let mut dest = expression(expr, bin, func_value, var_table, ns);
                    let after = bin.builder.build_int_sub(v.into_int_value(), one, "");
                    match expr.ty() {
                        Type::StorageRef(..) => {
                            storage_store(
                                bin,
                                ty,
                                &mut dest,
                                after.as_basic_value_enum(),
                                func_value,
                                ns,
                            );
                            dest
                        }
                        Type::Ref(_) => {
                            bin.builder.build_store(
                                dest.into_pointer_value(),
                                after.as_basic_value_enum(),
                            );
                            return dest.as_basic_value_enum();
                        }
                        _ => unreachable!(),
                    }
                }
            }
        }
        Expression::Increment { loc, ty, expr } => {
            let v = match expr.ty() {
                Type::Ref(ty) => {
                    let expr_load = Expression::Load {
                        loc: *loc,
                        ty: ty.as_ref().clone(),
                        expr: expr.clone(),
                    };
                    expression(&expr_load, bin, func_value, var_table, ns)
                }
                Type::StorageRef(ty) => {
                    let mut slot = expression(expr, bin, func_value, var_table, ns);
                    storage_load(bin, ty.as_ref(), &mut slot, func_value, ns)
                }
                _ => expression(expr, bin, func_value, var_table, ns),
            };
            let one = bin.context.i64_type().const_int(1, false);
            let after = bin.builder.build_int_add(v.into_int_value(), one, "");
            match expr.as_ref() {
                Expression::Variable { var_no, .. } => {
                    let before_ptr = var_table.get(var_no).unwrap();
                    bin.builder
                        .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum());
                    return before_ptr.as_basic_value_enum();
                }
                _ => {
                    let mut dest = expression(expr, bin, func_value, var_table, ns);
                    let after = bin.builder.build_int_add(v.into_int_value(), one, "");
                    match expr.ty() {
                        Type::StorageRef(..) => {
                            storage_store(
                                bin,
                                ty,
                                &mut dest,
                                after.as_basic_value_enum(),
                                func_value,
                                ns,
                            );
                            dest
                        }
                        Type::Ref(_) => {
                            let after = bin.builder.build_int_add(v.into_int_value(), one, "");
                            bin.builder.build_store(
                                dest.into_pointer_value(),
                                after.as_basic_value_enum(),
                            );
                            return dest.as_basic_value_enum();
                        }
                        _ => unreachable!(),
                    }
                }
            }
        }
        Expression::Assign { left, right, .. } => {
            // // If an assignment where the left hand side is an array, call a helper
            // // function that updates the temp variable.
            // if let Expression::Variable(_, Type::Array(..), var_no, ..) = &**l {
            //     handle_array_assign(r, bin, func_value, var_table, *var_no, ns);
            // }
            assign_single(left, right, bin, func_value, var_table, ns)
        }
        Expression::FunctionCall { .. }
        | Expression::ExternalFunctionCallRaw { .. }
        | Expression::LibFunction {
            kind: LibFunc::AbiDecode,
            ..
        } => {
            let mut returns = emit_function_call(expr, bin, func_value, var_table, ns);
            returns.remove(0)
        }
        Expression::NumberLiteral { ty, value, .. } => bin.number_literal(ty, value, ns),

        Expression::AddressLiteral { value, .. } => bin.address_literal(value),

        Expression::Variable { ty, var_no, .. } => {
            let ptr = var_table.get(var_no).unwrap().as_basic_value_enum();
            if ty.is_reference_type(ns) && !ty.is_contract_storage() {
                return ptr;
            }

            bin.builder
                .build_load(bin.llvm_type(ty, ns), ptr.into_pointer_value(), "")
        }

        Expression::LibFunction {
            kind: LibFunc::U32Sqrt,
            args,
            ..
        } => {
            let value = expression(&args[0], bin, func_value, var_table, ns).into_int_value();
            let root = bin
                .builder
                .build_call(
                    bin.module
                        .get_function("u32_sqrt")
                        .expect("u32_sqrt should have been defined before"),
                    &[value.into()],
                    "",
                )
                .try_as_basic_value()
                .left()
                .expect("Should have a left return value");
            root
        }

        Expression::LibFunction {
            kind: LibFunc::Assert,
            args,
            ..
        } => {
            let cond = expression(&args[0], bin, func_value, var_table, ns);
            bin.builder.build_call(
                bin.module
                    .get_function("builtin_assert")
                    .expect("builtin_assert should have been defined before"),
                &[bin
                    .builder
                    .build_int_z_extend(cond.into_int_value(), bin.context.i64_type(), "")
                    .into()],
                "",
            );
            bin.context.i64_type().const_zero().into()
        }

        Expression::LibFunction {
            kind: LibFunc::CallerAddress,
            ..
        } => {
            let mut caller_address = bin.context.i64_type().array_type(4).get_undef();
            let (heap_start_int, heap_start_ptr) =
                bin.heap_malloc(bin.context.i64_type().const_int(4, false));
            bin.context_data_load(heap_start_int, bin.context.i64_type().const_int(2, false));
            // caller address is start from index = 2 in tape data
            for i in 0..4 {
                let index_access = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        heap_start_ptr,
                        &[bin.context.i64_type().const_int(i, false)],
                        "",
                    )
                };
                let caller_address_value = bin
                    .builder
                    .build_load(bin.context.i64_type(), index_access, "")
                    .into_int_value();
                caller_address = bin
                    .builder
                    .build_insert_value(caller_address, caller_address_value, i as u32, "")
                    .unwrap()
                    .into_array_value()
            }
            caller_address.into()
        }

        Expression::StructLiteral { ty, values, .. } => {
            let struct_ty = bin.llvm_type(ty, ns);

            let struct_alloca = bin.build_alloca(func_value, struct_ty, "struct_alloca");

            for (i, expr) in values.iter().enumerate() {
                let elemptr = bin
                    .builder
                    .build_struct_gep(struct_ty, struct_alloca, i as u32, "struct member")
                    .unwrap();

                let elem = expression(expr, bin, func_value, var_table, ns);

                let elem = if expr.ty().is_fixed_reference_type() {
                    let load_type = bin.llvm_type(&expr.ty(), ns);
                    bin.builder
                        .build_load(load_type, elem.into_pointer_value(), "elem")
                } else {
                    elem
                };

                bin.builder.build_store(elemptr, elem);
            }

            struct_alloca.into()
        }

        Expression::ArrayLiteral {
            ty,
            dimensions,
            values,
            ..
        } => {
            let array_ty = bin.llvm_type(ty, ns);
            let array_alloca = bin.build_alloca(func_value, array_ty, "array_literal");

            for (i, expr) in values.iter().enumerate() {
                let mut ind = vec![bin.context.i64_type().const_zero()];

                let mut e = i as u32;

                // Mapping one-dimensional array indices to multi-dimensional array indices.
                for d in dimensions {
                    ind.insert(1, bin.context.i64_type().const_int((e % *d).into(), false));

                    e /= *d;
                }

                let elemptr = unsafe {
                    bin.builder
                        .build_gep(array_ty, array_alloca, &ind, &format!("elemptr{i}"))
                };

                let elem = expression(expr, bin, func_value, var_table, ns);

                let elem = if expr.ty().is_fixed_reference_type() {
                    bin.builder.build_load(
                        bin.llvm_type(&expr.ty(), ns),
                        elem.into_pointer_value(),
                        "elem",
                    )
                } else {
                    elem
                };

                bin.builder.build_store(elemptr, elem);
            }

            array_alloca.into()
        }

        Expression::StorageArrayLength { loc, ty, array, .. } => {
            let array_ty = array.ty().deref_into();
            let mut array = expression(array, bin, func_value, var_table, ns);
            match array_ty {
                Type::String => storage_load(bin, &Type::Uint(32), &mut array, func_value, ns),
                Type::Array(_, dim) => match dim.last().unwrap() {
                    ArrayLength::Dynamic => {
                        storage_load(bin, &Type::Uint(32), &mut array, func_value, ns)
                    }
                    ArrayLength::Fixed(length) => {
                        let ast_expr = bigint_to_expression(
                            loc,
                            length,
                            ns,
                            &mut Diagnostics::default(),
                            ResolveTo::Type(ty),
                        )
                        .unwrap();
                        expression(&ast_expr, bin, func_value, var_table, ns)
                    }
                    _ => unreachable!(),
                },
                _ => unreachable!(),
            }
        }
        Expression::Subscript {
            array_ty,
            array,
            index,
            ..
        } => {
            let array = expression(array, bin, func_value, var_table, ns);
            let index = expression(index, bin, func_value, var_table, ns);
            array_subscript(array_ty, array, index, bin, func_value, ns)
        }

        Expression::StructMember {
            ty,
            expr: var,
            field: field_no,
            ..
        } if ty.is_contract_storage() => {
            if let Type::Struct(no) = var.ty().deref_any() {
                let offset: BigInt = ns.structs[*no].fields[..*field_no]
                    .iter()
                    .filter(|field| !field.infinite_size)
                    .map(|field| field.ty.storage_slots(ns))
                    .sum();
                let slot = expression(var, bin, func_value, var_table, ns);
                slot_offest(
                    bin,
                    slot,
                    bin.context
                        .i64_type()
                        .const_int(offset.to_u64().unwrap(), false)
                        .into(),
                )
            } else {
                unreachable!();
            }
        }
        Expression::StructMember {
            expr: var,
            field: field_no,
            ..
        } => {
            let struct_ty = bin.llvm_type(var.ty().deref_memory(), ns);
            let struct_ptr = expression(var, bin, func_value, var_table, ns).into_pointer_value();
            bin.builder
                .build_struct_gep(struct_ty, struct_ptr, *field_no as u32, "struct member")
                .unwrap()
                .into()
        }
        Expression::Load { ty, expr, .. } => {
            let ptr = expression(expr, bin, func_value, var_table, ns).into_pointer_value();
            if ty.is_reference_type(ns) && !ty.is_fixed_reference_type() {
                let loaded_type = bin.llvm_type(ty, ns).ptr_type(AddressSpace::default());
                bin.builder.build_load(loaded_type, ptr, "")
            } else {
                let loaded_type = bin.llvm_type(ty, ns);
                bin.builder.build_load(loaded_type, ptr, "")
            }
        }

        Expression::LibFunction {
            kind: LibFunc::ArrayPush,
            args,
            ..
        } => {
            if args[0].ty().is_contract_storage() {
                storage_array_push(bin, args, func_value, var_table, ns)
            } else {
                // TODO Add memory array push support
                unimplemented!();
            }
        }
        Expression::LibFunction {
            kind: LibFunc::ArrayPop,
            args,
            ..
        } => {
            if args[0].ty().is_contract_storage() {
                storage_array_pop(bin, args, func_value, var_table, ns)
            } else {
                // TODO implement memory array pop
                unimplemented!()
            }
        }
        Expression::LibFunction {
            kind: LibFunc::ArrayLength,
            args,
            ..
        } => {
            let array = expression(&args[0], bin, func_value, var_table, ns);

            bin.vector_len(array).into()
        }
        Expression::LibFunction {
            loc,
            tys,
            kind: LibFunc::ArraySort,
            args,
        } => {
            let array = expression(&args[0], bin, func_value, var_table, ns);
            let vector_length_expr = Expression::LibFunction {
                loc: *loc,
                tys: tys.clone(),
                kind: LibFunc::ArrayLength,
                args: args.clone(),
            };
            let array_length = expression(&vector_length_expr, bin, func_value, var_table, ns);

            let array_sorted = bin
                .builder
                .build_call(
                    bin.module
                        .get_function("prophet_u32_array_sort")
                        .expect("prophet_u32_array_sort should have been defined before"),
                    &[array.into(), array_length.into()],
                    "",
                )
                .try_as_basic_value()
                .left()
                .expect("Should have a left return value");
            array_sorted
        }

        Expression::LibFunction {
            kind: LibFunc::AbiEncode,
            args,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::AbiEncodeWithSignature,
            args,
            ..
        } => {
            let (types, encoder_args): (Vec<_>, Vec<_>) = args
                .iter()
                .map(|expr| {
                    let ty = expr.ty().unwrap_user_type(ns).clone();
                    let arg = expression(expr, bin, func_value, var_table, ns);
                    (ty, arg)
                })
                .unzip();

            abi_encode(bin, encoder_args, &types, func_value, ns)
                .1
                .as_basic_value_enum()
        }
        Expression::AllocDynamicBytes {
            ty,
            length: size,
            init,
            ..
        } => {
            let size = expression(size, bin, func_value, var_table, ns).into_int_value();
            bin.vector_new(func_value, ty, size, init.as_ref(), true, ns)
                .into()
        }
        Expression::ConditionalOperator {
            ty,
            cond,
            true_option: left,
            false_option: right,
            ..
        } => conditional_operator(bin, ty, cond, func_value, var_table, ns, left, right),
        Expression::BoolLiteral { value, .. } => bin
            .context
            .i64_type()
            .const_int(*value as u64, false)
            .into(),

        Expression::GetRef { expr, .. } => {
            let address = expression(expr, bin, func_value, var_table, ns).into_array_value();

            let stack = bin.build_alloca(func_value, address.get_type(), "address");

            bin.builder.build_store(stack, address);

            stack.into()
        }

        Expression::Cast { to, expr, .. }
            if matches!(to, Type::Array(..))
                && matches!(**expr, Expression::ArrayLiteral { .. }) =>
        {
            array_literal_to_memory_array(expr, to, bin, func_value, var_table, ns)
        }
        Expression::StringCompare { left, right, .. } => {
            string_compare(left, right, bin, func_value, var_table, ns)
        }
        _ => unimplemented!("{:?}", expr),
    }
}

pub fn array_literal_to_memory_array<'a>(
    expr: &Expression,
    ty: &Type,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let dims = expr.ty().array_length().unwrap().clone();
    let array_vector = bin.vector_new(
        func_value,
        ty,
        bin.context
            .i64_type()
            .const_int(dims.to_u64().unwrap(), false),
        None,
        false,
        ns,
    );

    let elements = if let Expression::ArrayLiteral { values: items, .. } = expr {
        items
    } else {
        unreachable!()
    };
    let vector_data = bin.vector_data(array_vector.as_basic_value_enum());
    for (item_no, item) in elements.iter().enumerate() {
        let item = expression(item, bin, func_value, var_table, ns);

        let index = bin.context.i64_type().const_int(item_no as u64, false);
        let array_type: BasicTypeEnum = bin.llvm_type(ty, ns);
        let index_access = unsafe {
            bin.builder
                .build_gep(array_type, vector_data, &[index], "index_access")
        };
        bin.builder.build_store(index_access, item);
    }
    array_vector.as_basic_value_enum()
}

pub fn emit_function_call<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> Vec<BasicValueEnum<'a>> {
    match expr {
        Expression::FunctionCall { function, args, .. } => {
            if let Expression::Function { function_no, .. } = function.as_ref() {
                let callee = &ns.functions[*function_no];
                let callee_value = bin.module.get_function(&callee.name).unwrap();
                let mut params = args
                    .iter()
                    .map(|a| expression(a, bin, func_value, var_table, ns).into())
                    .collect::<Vec<BasicMetadataValueEnum>>();

                if callee.returns.len() > 1 {
                    for v in callee.returns.iter() {
                        params.push(
                            bin.build_alloca(
                                func_value,
                                bin.llvm_var_ty(&v.ty, ns),
                                v.name_as_str(),
                            )
                            .into(),
                        );
                    }
                }

                let ret_value = bin
                    .builder
                    .build_call(callee_value, &params, "")
                    .try_as_basic_value()
                    .left();
                if callee.returns.len() <= 1 {
                    vec![ret_value.unwrap_or(bin.context.i64_type().const_zero().into())]
                } else {
                    let mut returns = Vec::new();
                    for (i, v) in callee.returns.iter().enumerate() {
                        let load_ty = bin.llvm_var_ty(&v.ty, ns);
                        let val = bin.builder.build_load(
                            load_ty,
                            params[args.len() + i].into_pointer_value(),
                            v.name_as_str(),
                        );
                        returns.push(val.into());
                    }
                    returns
                }
            } else {
                unimplemented!()
            }
        }
        Expression::ExternalFunctionCallRaw {
            address, args, ty, ..
        } => {
            let args = expression(args, bin, func_value, var_table, ns);
            let address = expression(address, bin, func_value, var_table, ns);

            let (address_heap_int, address_heap_ptr) =
                bin.heap_malloc(bin.context.i64_type().const_int(4, false));

            // extract address value and store to heap
            for i in 0..4 {
                let index_access = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        address_heap_ptr,
                        &[bin.context.i64_type().const_int(i, false)],
                        "",
                    )
                };
                let address_value = bin
                    .builder
                    .build_extract_value(address.into_array_value(), i as u32, "")
                    .unwrap();
                bin.builder.build_store(index_access, address_value);
            }

            let return_data =
                external_call(bin, args, address_heap_int, ty.clone());
            vec![return_data]
        }
        Expression::LibFunction {
            tys,
            kind: LibFunc::AbiDecode,
            args,
            ..
        } => {
            let data = expression(&args[0], bin, func_value, var_table, ns);
            let input_length = bin.vector_len(data);
            let input = bin.vector_data(data);
            abi_decode(bin, input_length, input, tys, func_value, ns)
        }
        _ => unreachable!(),
    }
}

fn conditional_operator<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    cond: &Expression,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
    left: &Expression,
    right: &Expression,
) -> BasicValueEnum<'a> {
    let cond = expression(cond, bin, func_value, var_table, ns);
    let left_block = bin.context.append_basic_block(func_value, "left_value");
    let right_block = bin.context.append_basic_block(func_value, "right_value");
    let done_block = bin
        .context
        .append_basic_block(func_value, "conditional_done");

    bin.builder
        .build_conditional_branch(cond.into_int_value(), left_block, right_block);

    bin.builder.position_at_end(left_block);

    let left_val = expression(left, bin, func_value, var_table, ns);
    bin.builder.build_unconditional_branch(done_block);
    let left_block_end = bin.builder.get_insert_block().unwrap();
    bin.builder.position_at_end(right_block);

    let right_val = expression(right, bin, func_value, var_table, ns);
    bin.builder.build_unconditional_branch(done_block);

    let right_block_end = bin.builder.get_insert_block().unwrap();

    bin.builder.position_at_end(done_block);

    let phi = bin.builder.build_phi(bin.llvm_type(ty, ns), "phi");

    phi.add_incoming(&[(&left_val, left_block_end), (&right_val, right_block_end)]);

    phi.as_basic_value()
}

/// Codegen for an array subscript expression
pub fn array_subscript<'a>(
    array_ty: &Type,
    array: BasicValueEnum<'a>,
    index: BasicValueEnum<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    if array_ty.is_mapping() {
        let inputs = vec![array, index];
        return poseidon_hash(bin, inputs);
    }

    let (array_length, fixed) = match array_ty.deref_any() {
        Type::Array(..) => match array_ty.array_length() {
            None => {
                if let Type::StorageRef(..) = array_ty {
                    let array_length =
                        storage_load(bin, &Type::Uint(32), &mut array.clone(), func_value, ns);
                    (array_length, false)
                } else {
                    (bin.vector_len(array).into(), false)
                }
            }

            Some(l) => (
                bin.context
                    .i64_type()
                    .const_int(l.to_u64().unwrap(), false)
                    .into(),
                true,
            ),
        },
        _ => {
            unreachable!()
        }
    };

    let array_length_sub_one: BasicValueEnum = bin
        .builder
        .build_int_sub(
            array_length.into_int_value(),
            bin.context.i64_type().const_int(1, false),
            "",
        )
        .into();
    let array_length_sub_one_sub_index: BasicValueEnum = bin
        .builder
        .build_int_sub(
            array_length_sub_one.into_int_value(),
            index.into_int_value(),
            "",
        )
        .into();
    // check if index is out of bounds
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[array_length_sub_one_sub_index.into()],
        "",
    );

    if let Type::StorageRef(ty) = &array_ty {
        let elem_ty = ty.storage_array_elem();
        if fixed {
            let elem_size = elem_ty.storage_slots(ns);
            let offset = bin.builder.build_int_mul(
                index.into_int_value(),
                bin.context
                    .i64_type()
                    .const_int(elem_size.to_u64().unwrap(), false),
                "index_offset",
            );
            bin.builder
                .build_int_add(array.into_int_value(), offset, "index_slot")
                .into()
        } else {
            array_offset(bin, array, index, elem_ty, ns)
        }
    } else if array_ty.is_dynamic_memory() {
        let elem_ty = array_ty.array_deref();
        let llvm_elem_ty = bin.llvm_var_ty(elem_ty.deref_memory(), ns);
        let vector_ptr = bin.vector_data(array);
        return unsafe {
            bin.builder
                .build_gep(
                    llvm_elem_ty,
                    vector_ptr,
                    &[index.into_int_value()],
                    "index_access",
                )
                .as_basic_value_enum()
        };
    } else {
        let array_type = bin.llvm_type(array_ty.deref_memory(), ns);

        let element_ptr = unsafe {
            bin.builder.build_gep(
                array_type,
                array.into_pointer_value(),
                &[bin.context.i64_type().const_zero(), index.into_int_value()],
                "index_access",
            )
        };

        return element_ptr.as_basic_value_enum();
    }
}

pub fn assign_single<'a>(
    left: &Expression,
    right: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match left {
        Expression::Variable { ty, var_no, .. } => {
            let right_value = expression(right, bin, func_value, var_table, ns);
            let right_value = match right_value {
                BasicValueEnum::PointerValue(p) => {
                    var_table.insert(*var_no, right_value);
                    if !ty.is_reference_type(ns) {
                        bin.builder.build_load(bin.llvm_type(ty, ns), p, "")
                    } else {
                        right_value
                    }
                }
                _ => right_value,
            };

            right_value
        }
        _ => {
            let left_ty = left.ty();
            let ty = left_ty.deref_memory();

            let mut dest = expression(left, bin, func_value, var_table, ns);

            let expr_right =
                if !left_ty.is_contract_storage() && right.ty().is_fixed_reference_type() {
                    expression(
                        &Expression::Load {
                            loc: program::Loc::IRgen,
                            ty: right.ty(),
                            expr: Box::new(right.clone()),
                        },
                        bin,
                        func_value,
                        var_table,
                        ns,
                    )
                } else {
                    expression(right, bin, func_value, var_table, ns)
                };
            match left_ty {
                Type::StorageRef(..) => {
                    storage_store(
                        bin,
                        &ty.deref_any().clone(),
                        &mut dest,
                        expr_right,
                        func_value,
                        ns,
                    );
                }
                Type::Ref(..) => {
                    bin.builder
                        .build_store(dest.into_pointer_value(), expr_right);
                }
                _ => unreachable!(),
            }

            dest
        }
    }
}

pub fn string_compare<'a>(
    left: &StringLocation<Expression>,
    right: &StringLocation<Expression>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let (left, left_len) = string_location(bin, left, var_table, func_value, ns);
    let (right, right_len) = string_location(bin, right, var_table, func_value, ns);

    // Check if the strings are equal length
    let equal = bin
        .builder
        .build_int_compare(IntPredicate::EQ, left_len, right_len, "");
    bin.builder.build_call(
        bin.module
            .get_function("builtin_assert")
            .expect("builtin_assert should have been defined before"),
        &[bin
            .builder
            .build_int_z_extend(equal, bin.context.i64_type(), "")
            .into()],
        "",
    );

    // Create a loop for comparing each character in the strings
    let cond = bin.context.append_basic_block(func_value, "cond");
    let body = bin.context.append_basic_block(func_value, "body");
    let done = bin.context.append_basic_block(func_value, "done");
    let index_ptr = bin.build_alloca(func_value, bin.context.i64_type(), "index");
    bin.builder
        .build_store(index_ptr, bin.context.i64_type().const_int(0, false));

    bin.builder.build_unconditional_branch(cond);
    bin.builder.position_at_end(cond);

    let index = bin
        .builder
        .build_load(bin.context.i64_type(), index_ptr, "index")
        .into_int_value();

    let continue_condition = bin
        .builder
        .build_int_compare(IntPredicate::ULT, index, left_len, "");
    bin.builder
        .build_conditional_branch(continue_condition, body, done);

    // build the loop body
    bin.builder.position_at_end(body);

    let left_char_ptr = unsafe {
        bin.builder
            .build_gep(bin.context.i64_type(), left, &[index], "left_char_ptr")
    };
    let right_char_ptr = unsafe {
        bin.builder
            .build_gep(bin.context.i64_type(), right, &[index], "right_char_ptr")
    };

    let left_char = bin
        .builder
        .build_load(bin.context.i64_type(), left_char_ptr, "left_char");
    let right_char = bin
        .builder
        .build_load(bin.context.i64_type(), right_char_ptr, "right_char");

    let comparison = bin.builder.build_int_compare(
        IntPredicate::EQ,
        left_char.into_int_value(),
        right_char.into_int_value(),
        "comparison",
    );
    let next_index = bin.builder.build_int_add(
        index,
        bin.context.i64_type().const_int(1, false),
        "next_index",
    );
    bin.builder.build_store(index_ptr, next_index);

    bin.builder.build_conditional_branch(comparison, cond, done);
    bin.builder.position_at_end(done);

    bin.builder
        .build_int_compare(IntPredicate::EQ, index, right_len, "equal")
        .into()
}

/// Call external binary
fn external_call<'a>(
    bin: &Binary<'a>,
    args: BasicValueEnum<'a>,
    address: IntValue<'a>,
    call_type: CallTy,
) -> BasicValueEnum<'a> {
    let payload_len = bin.builder.build_load(
        bin.context.i64_type(),
        args.into_pointer_value(),
        "payload_len",
    );

    let len_add_one = bin.builder.build_int_add(
        payload_len.into_int_value(),
        bin.context.i64_type().const_int(1, false),
        "",
    );

    let payload_heap_addr =
        bin.builder
            .build_ptr_to_int(args.into_pointer_value(), bin.context.i64_type(), "");

    // store payload and payload len to tape
    bin.tape_data_store(payload_heap_addr, len_add_one);

    let call_type = match call_type {
        CallTy::Regular => bin.context.i64_type().const_zero(),
        CallTy::Delegate => bin.context.i64_type().const_int(1, false),
        CallTy::Static => bin.context.i64_type().const_int(2, false),
    };

    bin.builder.build_call(
        bin.module
            .get_function("contract_call")
            .expect("contract_call should have been defined before"),
        &[address.into(), call_type.into()],
        "",
    );

    // length start from index 2
    let length_size = bin.context.i64_type().const_int(2, false);
    let (length_start_int, length_start_ptr) = bin.heap_malloc(length_size);
    bin.tape_data_load(length_start_int, length_size);
    let return_length =
        bin.builder
            .build_load(bin.context.i64_type(), length_start_ptr, "return_length");
    let calldata_size = bin.builder.build_int_add(
        return_length.into_int_value(),
        bin.context.i64_type().const_int(2, false),
        "",
    );
    let (data_start_int, data_start_ptr) = bin.heap_malloc(calldata_size);
    bin.tape_data_load(data_start_int, calldata_size);
    data_start_ptr.as_basic_value_enum()
}
