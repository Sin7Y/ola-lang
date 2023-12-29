use crate::irgen::binary::Binary;
use crate::irgen::u32_op::{
    logic_and, logic_not, logic_or, u32_add, u32_bitwise_and, u32_bitwise_not, u32_bitwise_or,
    u32_bitwise_xor, u32_compare, u32_div, u32_mod, u32_mul, u32_power, u32_shift_left,
    u32_shift_right, u32_sub,
};
use crate::sema::ast::{ArrayLength, CallTy, StringLocation};
use inkwell::types::{BasicType, BasicTypeEnum};
use inkwell::values::{BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue};
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

use super::address_or_hash_op::address_or_hash_compare;
use super::encoding::{abi_decode, abi_encode, abi_encode_with_selector};
use super::functions::Vartable;
use super::storage::{
    array_offset, slot_offest, storage_array_pop, storage_array_push, storage_load, storage_store,
};
use super::strings::string_location;

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
        Expression::Equal { left, right, .. } => match left.ty() {
            Type::Address | Type::Contract(_) | Type::Hash => address_or_hash_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::EQ,
            ),
            Type::Uint(32) | Type::Bool | Type::Field => u32_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::EQ,
            ),
            _ => unimplemented!("equal for type {:?}", left.ty()),
        },
        Expression::NotEqual { left, right, .. } => match left.ty() {
            Type::Address | Type::Contract(_) | Type::Hash => address_or_hash_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::NE,
            ),
            Type::Uint(32) | Type::Bool | Type::Field => u32_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::NE,
            ),
            _ => unimplemented!("not equal for type {:?}", left.ty()),
        },
        Expression::More { left, right, .. } => match left.ty() {
            Type::Address | Type::Contract(_) | Type::Hash => address_or_hash_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::UGT,
            ),
            Type::Uint(32) => u32_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::UGT,
            ),

            _ => unimplemented!("more for type {:?}", left.ty()),
        },
        Expression::MoreEqual { left, right, .. } => match left.ty() {
            Type::Address | Type::Contract(_) | Type::Hash => address_or_hash_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::UGE,
            ),
            Type::Uint(32) => u32_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::UGE,
            ),
            _ => unimplemented!("more equal for type {:?}", left.ty()),
        },
        Expression::Less { left, right, .. } => match left.ty() {
            Type::Address | Type::Contract(_) | Type::Hash => address_or_hash_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::ULT,
            ),
            Type::Uint(32) => u32_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::ULT,
            ),
            _ => unimplemented!("less for type {:?}", left.ty()),
        },
        Expression::LessEqual { left, right, .. } => match left.ty() {
            Type::Address | Type::Contract(_) | Type::Hash => address_or_hash_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::ULE,
            ),
            Type::Uint(32) => u32_compare(
                left,
                right,
                bin,
                func_value,
                var_table,
                ns,
                IntPredicate::ULE,
            ),
            _ => unimplemented!("less equal for type {:?}", left.ty()),
        },

        Expression::Not { expr, .. } => logic_not(expr, bin, func_value, var_table, ns),
        Expression::BitwiseNot { expr, .. } => {
            u32_bitwise_not(expr, bin, func_value, var_table, ns)
        }
        Expression::Or { left, right, .. } => logic_or(left, right, bin, func_value, var_table, ns),
        Expression::And { left, right, .. } => {
            logic_and(left, right, bin, func_value, var_table, ns)
        }

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

        Expression::HashLiteral { value, .. } => bin.hash_literal(value),

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
                    bin.module.get_function("u32_sqrt").unwrap(),
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
                bin.module.get_function("builtin_assert").unwrap(),
                &[bin
                    .builder
                    .build_int_z_extend(cond.into_int_value(), bin.context.i64_type(), "")
                    .into()],
                "",
            );
            bin.context.i64_type().const_zero().into()
        }

        Expression::LibFunction {
            kind: LibFunc::CheckECDSA,
            args,
            ..
        } => {
            let msg = expression(&args[0], bin, func_value, var_table, ns);
            let pubkey = expression(&args[1], bin, func_value, var_table, ns);
            let signature = expression(&args[2], bin, func_value, var_table, ns);
            bin.builder
                .build_call(
                    bin.module.get_function("check_ecdsa").unwrap(),
                    &[msg.into(), pubkey.into(), signature.into()],
                    "",
                )
                .try_as_basic_value()
                .left()
                .expect("Should have a left return value")
        }

        Expression::LibFunction {
            kind: LibFunc::Signature,
            ..
        } => {
            let context_data_index = bin.context.i64_type().const_int(13, false);
            let heap_start_ptr = bin.vector_new(bin.context.i64_type().const_int(8, false));
            let data_start_ptr = bin.vector_data(heap_start_ptr.as_basic_value_enum());
            for i in 0..8 {
                let data_elem = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        data_start_ptr,
                        &[bin.context.i64_type().const_int(i, false)],
                        "",
                    )
                };
                let tape_index = bin.builder.build_int_add(
                    context_data_index,
                    bin.context.i64_type().const_int(i, false),
                    "",
                );
                bin.context_data_load(data_elem, tape_index);
            }

            heap_start_ptr.into()
        }

        Expression::LibFunction {
            kind: LibFunc::SequenceAddress,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::OriginAddress,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::TransactionHash,
            ..
        } => {
            let context_data_index = match expr {
                Expression::LibFunction {
                    kind: LibFunc::SequenceAddress,
                    ..
                } => bin.context.i64_type().const_int(2, false),
                Expression::LibFunction {
                    kind: LibFunc::OriginAddress,
                    ..
                } => bin.context.i64_type().const_int(8, false),

                Expression::LibFunction {
                    kind: LibFunc::TransactionHash,
                    ..
                } => bin.context.i64_type().const_int(17, false),
                _ => unreachable!(),
            };
            let heap_start_ptr = bin.heap_malloc(bin.context.i64_type().const_int(4, false));
            for i in 0..4 {
                let data_elem = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        heap_start_ptr,
                        &[bin.context.i64_type().const_int(i, false)],
                        "",
                    )
                };
                let tape_index = bin.builder.build_int_add(
                    context_data_index,
                    bin.context.i64_type().const_int(i, false),
                    "",
                );
                bin.context_data_load(data_elem, tape_index);
            }

            heap_start_ptr.into()
        }

        Expression::LibFunction {
            kind: LibFunc::BlockNumber,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::BlockTimestamp,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::TransactionVersion,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::ChainId,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::Nonce,
            ..
        } => {
            let context_data_index = match expr {
                Expression::LibFunction {
                    kind: LibFunc::BlockNumber,
                    ..
                } => bin.context.i64_type().const_int(0, false),
                Expression::LibFunction {
                    kind: LibFunc::BlockTimestamp,
                    ..
                } => bin.context.i64_type().const_int(1, false),
                Expression::LibFunction {
                    kind: LibFunc::TransactionVersion,
                    ..
                } => bin.context.i64_type().const_int(6, false),
                Expression::LibFunction {
                    kind: LibFunc::ChainId,
                    ..
                } => bin.context.i64_type().const_int(7, false),
                Expression::LibFunction {
                    kind: LibFunc::Nonce,
                    ..
                } => bin.context.i64_type().const_int(12, false),
                _ => unreachable!(),
            };
            let heap_start_ptr = bin.heap_malloc(bin.context.i64_type().const_int(1, false));
            bin.context_data_load(heap_start_ptr, context_data_index);
            bin.builder
                .build_load(bin.context.i64_type(), heap_start_ptr, "")
        }

        Expression::LibFunction {
            kind: LibFunc::CallerAddress,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::CodeAddress,
            ..
        }
        | Expression::LibFunction {
            kind: LibFunc::CurrentAddress,
            ..
        } => {
            let address_index = match expr {
                Expression::LibFunction {
                    kind: LibFunc::CallerAddress,
                    ..
                } => bin.context.i64_type().const_int(12, false),
                Expression::LibFunction {
                    kind: LibFunc::CodeAddress,
                    ..
                } => bin.context.i64_type().const_int(8, false),
                Expression::LibFunction {
                    kind: LibFunc::CurrentAddress,
                    ..
                } => bin.context.i64_type().const_int(4, false),
                _ => unreachable!(),
            };

            let heap_start_ptr = bin.heap_malloc(address_index);
            bin.tape_data_load(heap_start_ptr, address_index);
            heap_start_ptr.into()
        }
        Expression::StructLiteral { ty, values, .. } => {
            let struct_ty = bin.llvm_type(ty, ns);

            let struct_size = bin
                .context
                .i64_type()
                .const_int(ty.memory_size_of(ns).to_u64().unwrap(), false);

            let struct_alloca = bin.heap_malloc(struct_size);

            for (i, expr) in values.iter().enumerate() {
                let elemptr = bin
                    .builder
                    .build_struct_gep(struct_ty, struct_alloca, i as u32, "struct_member")
                    .unwrap();

                let elem = expression(expr, bin, func_value, var_table, ns);

                // let elem = if expr.ty().is_fixed_reference_type() {
                //     let load_type = bin.llvm_type(&expr.ty(), ns);
                //     bin.builder
                //         .build_load(load_type, elem.into_pointer_value(), "elem")
                // } else {
                //     elem
                // };

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
            let array_size = bin
                .context
                .i64_type()
                .const_int(ty.type_size_of(ns).to_u64().unwrap(), false);

            let array_alloca = bin.heap_malloc(array_size);

            for (i, expr) in values.iter().enumerate() {
                let mut ind = vec![];

                let mut e = i as u32;

                // Mapping one-dimensional array indices to multi-dimensional array indices.
                for d in dimensions {
                    ind.insert(0, bin.context.i64_type().const_int((e % *d).into(), false));

                    e /= *d;
                }

                let elemptr = unsafe {
                    bin.builder
                        .build_gep(array_ty, array_alloca, &ind, &format!("elemptr{i}"))
                };

                let elem = expression(expr, bin, func_value, var_table, ns);

                bin.builder.build_store(elemptr, elem);
            }

            array_alloca.into()
        }

        Expression::StorageArrayLength { loc, ty, array, .. } => {
            let array_ty = array.ty().deref_into();
            let mut array = expression(array, bin, func_value, var_table, ns);
            match array_ty {
                Type::String | Type::DynamicBytes => {
                    storage_load(bin, &Type::Uint(32), &mut array, func_value, ns)
                }
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
            let index_value = expression(index, bin, func_value, var_table, ns);
            array_subscript(
                array_ty,
                array,
                index_value,
                &index.ty(),
                bin,
                func_value,
                ns,
            )
        }

        Expression::ArraySlice {
            array_ty,
            array,
            start,
            end,
            ..
        } => {
            let array = expression(array, bin, func_value, var_table, ns);
            array_slice(array_ty, array, start, end, bin, func_value, var_table, ns)
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
                .build_struct_gep(struct_ty, struct_ptr, *field_no as u32, "struct_member")
                .unwrap()
                .into()
        }
        Expression::Load { ty, expr, .. } => {
            let ptr = expression(expr, bin, func_value, var_table, ns).into_pointer_value();
            bin.builder.build_load(bin.llvm_var_ty(ty, ns), ptr, "")
        }

        Expression::AllocDynamicBytes {
            ty,
            length: size,
            init,
            ..
        } => {
            let size = expression(size, bin, func_value, var_table, ns).into_int_value();
            bin.alloca_dynamic_array(func_value, ty, size, init.as_ref(), true, ns)
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

        Expression::Cast { to, expr, .. }
            if matches!(to, Type::String | Type::DynamicBytes)
                && matches!(expr.ty(), Type::String | Type::DynamicBytes) =>
        {
            expression(expr, bin, func_value, var_table, ns)
        }

        Expression::Cast { to, expr, .. }
            if matches!(to, Type::Hash | Type::Address)
                && matches!(expr.ty(), Type::Hash | Type::Address) =>
        {
            expression(expr, bin, func_value, var_table, ns)
        }

        Expression::Cast { to, expr, .. }
            if matches!(to, Type::Hash | Type::Address) && matches!(expr.ty(), Type::Uint(32)) =>
        {
            let expr = expression(expr, bin, func_value, var_table, ns);
            let zero = bin.context.i64_type().const_zero();
            let value = [zero, zero, zero, expr.into_int_value()];
            let heap_ptr =
                bin.heap_malloc(bin.context.i64_type().const_int(value.len() as u64, false));
            for (i, v) in value.iter().enumerate() {
                let index = bin.context.i64_type().const_int(i as u64, false);
                let index_access = unsafe {
                    bin.builder.build_gep(
                        bin.context.i64_type(),
                        heap_ptr,
                        &[index],
                        "index_access",
                    )
                };
                bin.builder
                    .build_store(index_access, v.clone().as_basic_value_enum());
            }
            heap_ptr.into()
        }

        Expression::Cast { to, expr, .. }
            if matches!(to, Type::DynamicBytes)
                && matches!(expr.ty(), Type::Hash | Type::Address) =>
        {
            let source = expression(expr, bin, func_value, var_table, ns);
            hash_or_address_to_fields(source, bin)
        }

        Expression::BytesCast {
            from: Type::Field,
            to: Type::DynamicBytes,
            expr,
            ..
        } => {
            let source = expression(expr, bin, func_value, var_table, ns);
            field_to_fields(source, bin)
        }

        Expression::StringCompare { left, right, .. } => {
            string_compare(left, right, bin, func_value, var_table, ns)
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
                    bin.module.get_function("prophet_u32_array_sort").unwrap(),
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
        } => {
            let (types, encoder_args): (Vec<_>, Vec<_>) = args
                .iter()
                .map(|expr| {
                    let ty = expr.ty().unwrap_user_type(ns).clone();
                    let arg = expression(expr, bin, func_value, var_table, ns);
                    (ty, arg)
                })
                .unzip();

            abi_encode(bin, encoder_args, &types, func_value, ns).as_basic_value_enum()
        }
        Expression::LibFunction {
            kind: LibFunc::AbiEncodeWithSignature,
            args,
            ..
        } => {
            let selector = expression(&args[0], bin, func_value, var_table, ns);
            let (types, encoder_args): (Vec<_>, Vec<_>) = args[1..]
                .iter()
                .map(|a| {
                    let ty = a.ty();
                    let expr = expression(a, bin, func_value, var_table, ns);
                    (ty, expr)
                })
                .unzip();

            abi_encode_with_selector(bin, selector, encoder_args, &types, func_value, ns)
                .as_basic_value_enum()
        }
        Expression::LibFunction {
            kind: LibFunc::FieldsConcat,
            args,
            ..
        } => {
            let left = expression(&args[0], bin, func_value, var_table, ns);
            let right = expression(&args[1], bin, func_value, var_table, ns);

            let result = bin
                .builder
                .build_call(
                    bin.module.get_function("fields_concat").unwrap(),
                    &[left.into(), right.into()],
                    "",
                )
                .try_as_basic_value()
                .left()
                .expect("Should have a left return value");
            result
        }

        Expression::LibFunction {
            kind: LibFunc::PoseidonHash,
            args,
            ..
        } => {
            let hash_input = expression(&args[0], bin, func_value, var_table, ns);
            let hash_input_length = bin.vector_len(hash_input);
            let hash_input_data = bin.vector_data(hash_input);
            bin.poseidon_hash(vec![(hash_input_data.into(), hash_input_length)])
        }

        Expression::LibFunction {
            kind: LibFunc::Print,
            args,
            ..
        } => {
            let ty = args[0].ty();
            let arg = expression(&args[0], bin, func_value, var_table, ns);
            debug_print(bin, arg, &ty, func_value, ns);
            bin.context.i64_type().const_zero().into()
        }

        Expression::LibFunction {
            kind: LibFunc::GetSelector,
            args,
            ..
        } => {
            // We have already completed the calculation of the function selector in the
            // SEMA stage.  Here, we just need to return it.
            expression(&args[0], bin, func_value, var_table, ns)
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
    let array_vector = bin.alloca_dynamic_array(
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

            let return_data = external_call(bin, args, address, ty.clone());
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
    index_ty: &Type,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    if array_ty.is_mapping() {
        return mapping_subscript(array, index, index_ty, bin);
    }
    let (array_length, fixed) = match array_ty.deref_any() {
        Type::Array(..) | Type::String | Type::DynamicBytes => match array_ty.array_length() {
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
    let array_length_sub_one_sub_index = bin.builder.build_int_sub(
        array_length_sub_one.into_int_value(),
        index.into_int_value(),
        "",
    );
    bin.range_check(array_length_sub_one_sub_index);

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
                .build_int_add(offset, array.into_int_value(), "index_slot")
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
                &[index.into_int_value()],
                "index_access",
            )
        };

        return element_ptr.as_basic_value_enum();
    }
}

/// Codegen for an array subscript expression
pub fn array_slice<'a>(
    array_ty: &Type,
    array: BasicValueEnum<'a>,
    start: &Option<Box<Expression>>,
    end: &Option<Box<Expression>>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let array_length = match array_ty.deref_any() {
        Type::Array(..) | Type::DynamicBytes | Type::String => match array_ty.array_length() {
            None => bin.vector_len(array),

            Some(l) => bin
                .context
                .i64_type()
                .const_int(l.to_u64().unwrap(), false)
                .into(),
        },
        _ => {
            unreachable!("array_slice should only be called on arrays or fields")
        }
    };
    let start = match start {
        Some(start) => expression(start, bin, func_value, var_table, ns).into_int_value(),
        None => bin.context.i64_type().const_zero(),
    };

    let end = match end {
        Some(end) => expression(end, bin, func_value, var_table, ns).into_int_value(),
        None => array_length,
    };

    // check start index is out of bounds
    let array_length_sub_one = bin.builder.build_int_sub(
        array_length,
        bin.context.i64_type().const_int(1, false),
        "array_len_sub_one",
    );
    let array_length_sub_one_sub_start = bin.builder.build_int_sub(array_length_sub_one, start, "");
    bin.range_check(array_length_sub_one_sub_start);

    let array_length_sub_end = bin.builder.build_int_sub(array_length, end, "");
    bin.range_check(array_length_sub_end);

    // slice length = end - start
    let end_sub_start: inkwell::values::IntValue<'_> =
        bin.builder.build_int_sub(end, start, "slice_len");
    bin.range_check(end_sub_start);

    // alloc slice
    let new_array = bin.vector_new(end_sub_start);

    let dest_array = bin.vector_data(new_array.into());

    let src_data = if array_ty.is_dynamic_memory() {
        bin.vector_data(array)
    } else {
        array.into_pointer_value()
    };
    let src_data_start = unsafe {
        bin.builder
            .build_gep(bin.context.i64_type(), src_data, &[start], "src_data_start")
    };
    bin.memcpy(src_data_start, dest_array, end_sub_start);
    new_array.as_basic_value_enum()
}

pub fn mapping_subscript<'a>(
    array: BasicValueEnum<'a>,
    index: BasicValueEnum<'a>,
    index_ty: &Type,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let mut inputs = Vec::with_capacity(2);
    let slot_value = match array.get_type() {
        BasicTypeEnum::IntType(..) => bin.convert_uint_storage(array),
        _ => array,
    };
    inputs.push((slot_value, bin.context.i64_type().const_int(4, false)));
    match index_ty {
        Type::Uint(32) | Type::Field | Type::Bool | Type::Hash | Type::Address => {
            let index_value = match index.get_type() {
                BasicTypeEnum::IntType(..) => bin.convert_uint_storage(index),
                _ => index,
            };
            inputs.push((index_value, bin.context.i64_type().const_int(4, false)));
        }
        Type::DynamicBytes | Type::String => {
            inputs.push((bin.vector_data(index).into(), bin.vector_len(index)));
        }
        _ => unreachable!(),
    }

    bin.poseidon_hash(inputs)
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
        Expression::Variable { var_no, ty, .. } => {
            let right_value = expression(right, bin, func_value, var_table, ns);
            if !ty.is_reference_type(ns) {
                let left_var = var_table.get(var_no).unwrap();
                bin.builder
                    .build_store(left_var.into_pointer_value(), right_value);
            } else {
                var_table.insert(*var_no, right_value);
            }
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
        bin.module.get_function("builtin_assert").unwrap(),
        &[bin
            .builder
            .build_int_z_extend(equal, bin.context.i64_type(), "")
            .into()],
        "",
    );

    bin.memcmp(left, right, left_len, IntPredicate::EQ, &Type::Uint(32))
        .into()
}

fn field_to_fields<'a>(source: BasicValueEnum<'a>, bin: &Binary<'a>) -> BasicValueEnum<'a> {
    let left_len = bin.context.i64_type().const_int(1, false);
    let new_fields = bin.vector_new(left_len);
    let new_fields_data = bin.vector_data(new_fields.into());
    let dest_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            new_fields_data,
            &[bin.context.i64_type().const_zero()],
            "",
        )
    };
    bin.builder.build_store(dest_elem_ptr, source);
    new_fields.as_basic_value_enum()
}

fn hash_or_address_to_fields<'a>(
    source: BasicValueEnum<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let left_len = bin.context.i64_type().const_int(4, false);
    let new_fields = bin.vector_new(left_len);
    let new_fields_data = bin.vector_data(new_fields.into());
    for i in 0..4 {
        let source_elem_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                source.into_pointer_value(),
                &[bin.context.i64_type().const_int(i, false)],
                "",
            )
        };
        let source_value = bin
            .builder
            .build_load(bin.context.i64_type(), source_elem_ptr, "");

        let dest_elem_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                new_fields_data,
                &[bin.context.i64_type().const_int(i, false)],
                "",
            )
        };
        bin.builder.build_store(dest_elem_ptr, source_value);
    }
    new_fields.as_basic_value_enum()
}

/// Call external binary
fn external_call<'a>(
    bin: &Binary<'a>,
    args: BasicValueEnum<'a>,
    address: BasicValueEnum<'a>,
    call_type: CallTy,
) -> BasicValueEnum<'a> {
    let payload_len = bin.vector_len(args);
    let payload_ptr = bin.vector_data(args);
    // store payload and payload len to tape
    bin.tape_data_store(payload_ptr, payload_len);

    let call_type = match call_type {
        CallTy::Regular => bin.context.i64_type().const_zero(),
        CallTy::Delegate => bin.context.i64_type().const_int(1, false),
        CallTy::Static => bin.context.i64_type().const_int(2, false),
    };

    bin.builder.build_call(
        bin.module.get_function("contract_call").unwrap(),
        &[address.into(), call_type.into()],
        "",
    );

    // length start from index = 0 in tape data
    let length_size = bin.context.i64_type().const_int(1, false);
    let length_start_ptr = bin.heap_malloc(length_size);
    bin.tape_data_load(length_start_ptr, length_size);

    let return_length =
        bin.builder
            .build_load(bin.context.i64_type(), length_start_ptr, "return_length");

    let tape_size = bin.builder.build_int_add(
        return_length.into_int_value(),
        bin.context.i64_type().const_int(1, false),
        "tape_size",
    );

    let heap_size = bin.builder.build_int_add(
        return_length.into_int_value(),
        bin.context.i64_type().const_int(2, false),
        "heap_size",
    );

    let heap_start_ptr = bin.heap_malloc(heap_size);

    // store return length to heap
    // heap[0] = return_length
    // heap[1..len] = return_data
    // heap[len] = return_length
    bin.builder.build_store(heap_start_ptr, return_length);

    let return_data_start = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            heap_start_ptr,
            &[bin.context.i64_type().const_int(1, false)],
            "return_data_start",
        )
    };

    bin.tape_data_load(return_data_start, tape_size);
    heap_start_ptr.as_basic_value_enum()
}

pub(crate) fn debug_print<'a>(
    bin: &Binary<'a>,
    arg: BasicValueEnum<'a>,
    ty: &Type,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    // print the value
    let print_func = bin.module.get_function("prophet_printf").unwrap();
    match ty {
        Type::Bool | Type::Uint(_) | Type::Field | Type::Enum(_) => {
            let arg_value = match arg.get_type() {
                BasicTypeEnum::IntType(_) => arg,
                BasicTypeEnum::PointerType(_) => {
                    bin.builder
                        .build_load(bin.context.i64_type(), arg.into_pointer_value(), "")
                }
                _ => unreachable!(),
            };
            bin.builder.build_call(
                print_func,
                &[
                    arg_value.into(),
                    bin.context.i64_type().const_int(3, false).into(),
                ],
                "",
            );
        }
        Type::Address => {
            let address_start = bin.builder.build_ptr_to_int(
                arg.into_pointer_value(),
                bin.context.i64_type(),
                "address_start",
            );
            bin.builder.build_call(
                print_func,
                &[
                    address_start.into(),
                    bin.context.i64_type().const_int(2, false).into(),
                ],
                "",
            );
        }
        Type::Hash => {
            let hash_start = bin.builder.build_ptr_to_int(
                arg.into_pointer_value(),
                bin.context.i64_type(),
                "hash_start",
            );
            bin.builder.build_call(
                print_func,
                &[
                    hash_start.into(),
                    bin.context.i64_type().const_int(2, false).into(),
                ],
                "",
            );
        }

        Type::DynamicBytes => {
            let fields_start = bin.builder.build_ptr_to_int(
                arg.into_pointer_value(),
                bin.context.i64_type(),
                "fields_start",
            );

            bin.builder.build_call(
                print_func,
                &[
                    fields_start.into(),
                    bin.context.i64_type().const_int(0, false).into(),
                ],
                "",
            );
        }
        Type::String => {
            let string_start = bin.builder.build_ptr_to_int(
                arg.into_pointer_value(),
                bin.context.i64_type(),
                "string_start",
            );
            bin.builder.build_call(
                print_func,
                &[
                    string_start.into(),
                    bin.context.i64_type().const_int(1, false).into(),
                ],
                "",
            );
        }
        Type::Array(..) => {
            let array_start = bin.builder.build_ptr_to_int(
                arg.into_pointer_value(),
                bin.context.i64_type(),
                "array_start",
            );
            bin.builder.build_call(
                print_func,
                &[
                    array_start.into(),
                    bin.context.i64_type().const_zero().into(),
                ],
                "",
            );
        }
        Type::Struct(no) => {
            for (i, field) in ns.structs[*no].fields.iter().enumerate() {
                let elem_ptr = bin
                    .builder
                    .build_struct_gep(
                        bin.llvm_type(&ty, ns),
                        arg.into_pointer_value(),
                        i as u32,
                        "struct_member",
                    )
                    .unwrap();
                let elem = bin
                    .builder
                    .build_load(bin.llvm_var_ty(&field.ty, ns), elem_ptr, "");
                debug_print(bin, elem.into(), &field.ty, func_value, ns);
            }
        }
        Type::Mapping(_) => todo!(),
        Type::Contract(_) => todo!(),
        Type::Ref(ty) => {
            let ref_value = if ty.is_reference_type(ns) && !ty.is_fixed_reference_type() {
                let loaded_type = bin.llvm_type(ty, ns).ptr_type(AddressSpace::default());
                bin.builder
                    .build_load(loaded_type, arg.into_pointer_value(), "")
            } else {
                let loaded_type = bin.llvm_type(ty, ns);
                bin.builder
                    .build_load(loaded_type, arg.into_pointer_value(), "")
            };
            debug_print(bin, ref_value, ty, func_value, ns);
        }
        Type::StorageRef(ty) => {
            let value = storage_load(bin, ty, &mut arg.into(), func_value, ns);
            debug_print(bin, value, ty, func_value, ns);
        }
        Type::Function { .. } => todo!(),
        Type::UserType(_) => todo!(),
        Type::Void => todo!(),
        Type::Unreachable => todo!(),
        Type::Slice(_) => todo!(),
        Type::Unresolved => todo!(),
        Type::BufferPointer => todo!(),
    }
}
