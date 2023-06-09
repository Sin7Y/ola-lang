use crate::irgen::binary::Binary;
use crate::irgen::functions::FunctionContext;
use crate::irgen::u32_op::{
    u32_add, u32_and, u32_bitwise_and, u32_bitwise_not, u32_bitwise_or, u32_bitwise_xor, u32_div,
    u32_equal, u32_less, u32_less_equal, u32_mod, u32_more, u32_more_equal, u32_mul, u32_not,
    u32_not_equal, u32_or, u32_power, u32_shift_left, u32_shift_right, u32_sub,
};
use inkwell::types::{BasicType, BasicTypeEnum};
use inkwell::values::{AnyValue, BasicMetadataValueEnum, BasicValue, BasicValueEnum};
use inkwell::AddressSpace;
use num_traits::ToPrimitive;
use ola_parser::program;

use crate::sema::{
    ast,
    ast::{Expression, LibFunc, Namespace, RetrieveType, Type},
    diagnostics::Diagnostics,
    eval::eval_const_number,
    expression::integers::bigint_to_expression,
    expression::ResolveTo,
};

pub fn expression<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match expr {
        ast::Expression::StorageVariable {
            loc,
            contract_no: var_contract_no,
            var_no,
            ..
        } => {
            // // base storage variables should precede contract variables, not overlap
            // ns.contracts[contract_no].get_storage_slot(*loc, *var_contract_no, *var_no,
            // ns, None)
            unimplemented!()
        }
        ast::Expression::StorageLoad { loc, ty, expr } => {
            // let storage = expression(expr, cfg, contract_no, func, ns, vartab, opt);

            // load_storage(loc, ty, storage, cfg, vartab)
            unimplemented!()
        }
        ast::Expression::Add {
            loc,
            ty,
            left,
            right,
        } => u32_add(left, right, bin, func_context, ns),
        ast::Expression::Subtract {
            loc,
            ty,
            left,
            right,
        } => u32_sub(left, right, bin, func_context, ns),
        ast::Expression::Multiply {
            loc,
            ty,
            left,
            right,
        } => u32_mul(left, right, bin, func_context, ns),
        ast::Expression::Divide {
            loc,
            ty,
            left,
            right,
        } => u32_div(left, right, bin, func_context, ns),
        ast::Expression::Modulo {
            loc,
            ty,
            left,
            right,
        } => u32_mod(left, right, bin, func_context, ns),
        ast::Expression::Power { loc, ty, base, exp } => {
            u32_power(base, exp, bin, func_context, ns)
        }
        ast::Expression::BitwiseOr {
            loc,
            ty,
            left,
            right,
        } => u32_bitwise_or(left, right, bin, func_context, ns),
        ast::Expression::BitwiseAnd {
            loc,
            ty,
            left,
            right,
        } => u32_bitwise_and(left, right, bin, func_context, ns),
        ast::Expression::BitwiseXor {
            loc,
            ty,
            left,
            right,
        } => u32_bitwise_xor(left, right, bin, func_context, ns),
        ast::Expression::ShiftLeft {
            loc,
            ty,
            left,
            right,
        } => u32_shift_left(left, right, bin, func_context, ns),
        ast::Expression::ShiftRight {
            loc,
            ty,
            left,
            right,
        } => u32_shift_right(left, right, bin, func_context, ns),
        ast::Expression::Equal { loc, left, right } => {
            u32_equal(left, right, bin, func_context, ns)
        }
        ast::Expression::NotEqual { loc, left, right } => {
            u32_not_equal(left, right, bin, func_context, ns)
        }
        ast::Expression::More { loc, left, right } => u32_more(left, right, bin, func_context, ns),
        ast::Expression::MoreEqual { loc, left, right } => {
            u32_more_equal(left, right, bin, func_context, ns)
        }
        ast::Expression::Less { loc, left, right } => u32_less(left, right, bin, func_context, ns),
        ast::Expression::LessEqual { loc, left, right } => {
            u32_less_equal(left, right, bin, func_context, ns)
        }

        ast::Expression::Not { loc, expr } => u32_not(expr, bin, func_context, ns),
        ast::Expression::BitwiseNot { loc, ty, expr } => {
            u32_bitwise_not(expr, bin, func_context, ns)
        }
        ast::Expression::Or { loc, left, right } => u32_or(left, right, bin, func_context, ns),
        ast::Expression::And { loc, left, right } => u32_and(left, right, bin, func_context, ns),

        Expression::Decrement { loc, ty, expr } => {
            let v = match expr.ty() {
                Type::Ref(ty) => Expression::Load {
                    loc: *loc,
                    ty: ty.as_ref().clone(),
                    expr: expr.clone(),
                },
                Type::StorageRef(ty) => unimplemented!(),
                _ => *expr.clone(),
            };
            let one = bin.context.i64_type().const_int(1, false);
            match expr.as_ref() {
                Expression::Variable { ty, var_no, .. } => {
                    let before_ptr = *func_context.var_table.get(var_no).unwrap();
                    let before_val = bin.builder.build_load(
                        bin.llvm_type(&ty, ns),
                        before_ptr.into_pointer_value(),
                        "",
                    );
                    let after = bin.builder.build_int_sub(
                        before_val.as_any_value_enum().into_int_value(),
                        one,
                        "",
                    );
                    bin.builder
                        .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum());
                    return before_ptr.as_basic_value_enum();
                }
                _ => {
                    let dest = expression(expr, bin, func_context, ns);
                    let value = expression(&v, bin, func_context, ns);
                    match expr.ty() {
                        Type::StorageRef(..) => {
                            unimplemented!("storage ref")
                        }
                        Type::Ref(_) => {
                            let after = bin.builder.build_int_sub(value.into_int_value(), one, "");
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
                Type::Ref(ty) => Expression::Load {
                    loc: *loc,
                    ty: ty.as_ref().clone(),
                    expr: expr.clone(),
                },
                Type::StorageRef(ty) => unimplemented!(),
                _ => *expr.clone(),
            };
            let one = bin.context.i64_type().const_int(1, false);
            match expr.as_ref() {
                Expression::Variable { ty, var_no, .. } => {
                    let one = bin.context.i64_type().const_int(1, false);
                    let before_ptr = *func_context.var_table.get(var_no).unwrap();
                    let before_val = bin.builder.build_load(
                        bin.llvm_type(&ty, ns),
                        before_ptr.into_pointer_value(),
                        "",
                    );
                    let after = bin
                        .builder
                        .build_int_add(before_val.into_int_value(), one, "");
                    bin.builder
                        .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum());
                    return before_ptr.as_basic_value_enum();
                }
                _ => {
                    let dest = expression(expr, bin, func_context, ns);
                    let value = expression(&v, bin, func_context, ns);
                    match expr.ty() {
                        Type::StorageRef(..) => {
                            unimplemented!("storage ref")
                        }
                        Type::Ref(_) => {
                            let after = bin.builder.build_int_add(value.into_int_value(), one, "");
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
        ast::Expression::Assign { left, right, .. } => {
            // // If an assignment where the left hand side is an array, call a helper
            // // function that updates the temp variable.
            // if let Expression::Variable(_, Type::Array(..), var_no, ..) = &**l {
            //     handle_array_assign(r, bin, func_context, *var_no, ns);
            // }
            assign_single(left, right, bin, func_context, ns)
        }
        Expression::FunctionCall { .. } => {
            let (ret, _) = emit_function_call(expr, bin, func_context, ns);
            ret
        }
        ast::Expression::NumberLiteral { ty, value, .. } => {
            bin.number_literal(ty, value, ns).into()
        }

        ast::Expression::Variable { ty, var_no, .. } => {
            let ptr = func_context
                .var_table
                .get(var_no)
                .unwrap()
                .as_basic_value_enum();
            if ty.is_reference_type(ns) {
                return ptr;
            }

            bin.builder
                .build_load(bin.llvm_var_ty(&ty, ns), ptr.into_pointer_value(), "")
        }

        Expression::LibFunction {
            kind: LibFunc::U32Sqrt,
            args,
            ..
        } => {
            let value = expression(&args[0], bin, func_context, ns).into_int_value();
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

        ast::Expression::StructLiteral { ty, values, .. } => {
            let struct_ty = bin.llvm_type(ty, ns);

            let struct_alloca = bin.build_alloca(func_context.func_val, struct_ty, "struct_alloca");

            for (i, expr) in values.iter().enumerate() {
                let elemptr = bin
                    .builder
                    .build_struct_gep(struct_ty, struct_alloca, i as u32, "struct member")
                    .unwrap();

                let elem = expression(expr, bin, func_context, ns);

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

        ast::Expression::ArrayLiteral {
            loc,
            ty,
            dimensions,
            values,
        } => {
            let array_ty = bin.llvm_type(ty, ns);
            let array_alloca = bin.build_alloca(func_context.func_val, array_ty, "array_literal");

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

                let elem = expression(expr, bin, func_context, ns);

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
        ast::Expression::ConstArrayLiteral {
            loc,
            ty,
            dimensions,
            values,
        } => {
            unimplemented!()
        }

        ast::Expression::ConstantVariable {
            contract_no: Some(var_contract_no),
            var_no,
            ..
        } => {
            unimplemented!()
        }

        Expression::StorageArrayLength {
            loc,
            ty,
            array,
            elem_ty,
        } => {
            unimplemented!()
        }
        ast::Expression::Subscript {
            loc,
            ty: elem_ty,
            array_ty,
            array,
            index,
        } => array_subscript(loc, array_ty, array, index, bin, func_context, ns),

        ast::Expression::StructMember {
            loc,
            ty,
            expr: var,
            field: field_no,
        } if ty.is_contract_storage() => {
            unimplemented!()
        }
        ast::Expression::StructMember {
            loc,
            ty,
            expr: var,
            field: field_no,
        } => {
            let struct_ty = bin.llvm_type(var.ty().deref_memory(), ns);
            let struct_ptr = expression(var, bin, func_context, ns).into_pointer_value();
            bin.builder
                .build_struct_gep(struct_ty, struct_ptr, *field_no as u32, "struct member")
                .unwrap()
                .into()
        }
        ast::Expression::Load { ty, expr, .. } => {
            let ptr = expression(expr, bin, func_context, ns).into_pointer_value();
            if ty.is_reference_type(ns) && !ty.is_fixed_reference_type() {
                let loaded_type = bin.llvm_type(ty, ns).ptr_type(AddressSpace::default());
                let value = bin.builder.build_load(loaded_type, ptr, "");
                // if the pointer is null, it needs to be allocated
                let allocation_needed = bin
                    .builder
                    .build_is_null(value.into_pointer_value(), "allocation_needed");
                let allocate = bin
                    .context
                    .append_basic_block(func_context.func_val, "allocate");
                let already_allocated = bin
                    .context
                    .append_basic_block(func_context.func_val, "already_allocated");
                bin.builder.build_conditional_branch(
                    allocation_needed,
                    allocate,
                    already_allocated,
                );

                let entry = bin.builder.get_insert_block().unwrap();

                bin.builder.position_at_end(allocate);

                // allocate a new struct
                let ty = expr.ty();

                let llvm_ty = bin.llvm_type(ty.deref_memory(), ns);

                let new_struct = bin.build_alloca(func_context.func_val, llvm_ty, "struct_alloca");
                bin.builder.build_store(ptr, new_struct);
                bin.builder.build_unconditional_branch(already_allocated);
                bin.builder.position_at_end(already_allocated);
                let combined_struct_ptr = bin.builder.build_phi(
                    llvm_ty.ptr_type(AddressSpace::default()),
                    &format!("ptr_{}", ty.to_string(ns)),
                );
                combined_struct_ptr.add_incoming(&[(&value, entry), (&new_struct, allocate)]);

                combined_struct_ptr.as_basic_value()
            } else {
                let loaded_type = bin.llvm_type(ty, ns);
                bin.builder.build_load(loaded_type, ptr, "")
            }
        }

        Expression::LibFunction {
            tys,
            kind: LibFunc::ArrayPush,
            args,
            ..
        } => {
            if args[0].ty().is_contract_storage() {
                // TODO Add support for storage type arrays
                unimplemented!();
            } else {
                // TODO Add memory array push support
                unimplemented!();
            }
        }
        Expression::LibFunction {
            tys,
            kind: LibFunc::ArrayPop,
            args,
            ..
        } => {
            if args[0].ty().is_contract_storage() {
                // TODO Add support for storage type arrays
                unimplemented!();
            } else {
                // TODO Add memory array pop support
                unimplemented!();
            }
        }
        Expression::LibFunction {
            tys,
            kind: LibFunc::ArrayLength,
            args,
            ..
        } => {
            let array = expression(&args[0], bin, func_context, ns);

            bin.vector_len(array).into()
        }
        Expression::LibFunction {
            loc,
            tys,
            kind: LibFunc::ArraySort,
            args,
        } => {
            let array = expression(&args[0], bin, func_context, ns);
            let vector_length_expr = Expression::LibFunction {
                loc: *loc,
                tys: tys.clone(),
                kind: LibFunc::ArrayLength,
                args: args.clone(),
            };
            let array_length = expression(&vector_length_expr, bin, func_context, ns);

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
            array_sorted.into()
        }
        Expression::AllocDynamicBytes {
            loc,
            ty,
            length: size,
            init,
        } => {
            let size = expression(size, bin, func_context, ns).into_int_value();
            bin.vector_new(size, init.as_ref()).into()
        }
        ast::Expression::ConditionalOperator {
            loc,
            ty,
            cond,
            true_option: left,
            false_option: right,
        } => conditional_operator(bin, ty, cond, func_context, ns, left, right),
        ast::Expression::BoolLiteral { loc, value } => bin
            .context
            .bool_type()
            .const_int(*value as u64, false)
            .into(),

        ast::Expression::GetRef { loc, ty, expr: exp } => {
            let address = expression(expr, bin, func_context, ns).into_array_value();

            let stack = bin.build_alloca(func_context.func_val, address.get_type(), "address");

            bin.builder.build_store(stack, address);

            stack.into()
        }

        Expression::Cast { loc, to, expr }
            if matches!(to, Type::Array(..))
                && matches!(**expr, Expression::ArrayLiteral { .. }) =>
        {
            array_literal_to_memory_array(loc, &expr, to, bin, func_context, ns)
        }

        _ => {
            unimplemented!()
        }
    }
}

pub fn array_literal_to_memory_array<'a>(
    loc: &program::Loc,
    expr: &Expression,
    ty: &Type,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let dims = expr.ty().array_length().unwrap().clone();
    let array_vector = bin.vector_new(
        bin.context
            .i64_type()
            .const_int(dims.to_u64().unwrap(), false),
        None,
    );

    let elements = if let Expression::ArrayLiteral { values: items, .. } = expr {
        items
    } else {
        unreachable!()
    };

    for (item_no, item) in elements.iter().enumerate() {
        let item = expression(item, bin, func_context, ns);

        let index = bin.context.i64_type().const_int(item_no as u64, false);
        let array_type: BasicTypeEnum = bin.llvm_var_ty(ty, ns);
        let index_access = unsafe {
            bin.builder.build_gep(
                array_type,
                bin.vector_data(array_vector.as_basic_value_enum()),
                &[index],
                "index_access",
            )
        };
        bin.builder.build_store(index_access, item);
    }
    array_vector.as_basic_value_enum()
}

pub fn emit_function_call<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, bool) {
    if let Expression::FunctionCall { function, args, .. } = expr {
        if let Expression::Function { function_no, .. } = function.as_ref() {
            let callee = &ns.functions[*function_no];
            let callee_value = bin.module.get_function(&callee.name).unwrap();
            let params = args
                .iter()
                .map(|a| expression(a, bin, func_context, ns).into())
                .collect::<Vec<BasicMetadataValueEnum>>();

            let ret_value = bin
                .builder
                .build_call(callee_value, &params, "")
                .try_as_basic_value()
                .left()
                .unwrap();
            if callee.returns.len() == 1 {
                (ret_value, true)
            } else {
                let struct_ty = bin
                    .context
                    .struct_type(
                        &callee
                            .returns
                            .iter()
                            .map(|f| bin.llvm_field_ty(&f.ty, ns))
                            .collect::<Vec<BasicTypeEnum>>(),
                        false,
                    )
                    .as_basic_type_enum();
                let ret_ptr = bin.build_alloca(func_context.func_val, struct_ty, "struct_alloca");
                bin.builder.build_store(ret_ptr, ret_value);
                (ret_value, false)
            }
        } else {
            unimplemented!()
        }
    } else {
        unimplemented!()
    }
}

fn conditional_operator<'a>(
    bin: &Binary<'a>,
    ty: &Type,
    cond: &Expression,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
    left: &Expression,
    right: &Expression,
) -> BasicValueEnum<'a> {
    let cond = expression(cond, bin, func_context, ns);
    let left_block = bin
        .context
        .append_basic_block(func_context.func_val, "left_value");
    let right_block = bin
        .context
        .append_basic_block(func_context.func_val, "right_value");
    let done_block = bin
        .context
        .append_basic_block(func_context.func_val, "conditional_done");

    bin.builder
        .build_conditional_branch(cond.into_int_value(), left_block, right_block);

    bin.builder.position_at_end(left_block);

    let left_val = expression(left, bin, func_context, ns);
    bin.builder.build_unconditional_branch(done_block);
    let left_block_end = bin.builder.get_insert_block().unwrap();
    bin.builder.position_at_end(right_block);

    let right_val = expression(right, bin, func_context, ns);
    bin.builder.build_unconditional_branch(done_block);

    let right_block_end = bin.builder.get_insert_block().unwrap();

    bin.builder.position_at_end(done_block);

    let phi = bin.builder.build_phi(bin.llvm_type(ty, ns), "phi");

    phi.add_incoming(&[(&left_val, left_block_end), (&right_val, right_block_end)]);

    phi.as_basic_value()
}

/// Codegen for an array subscript expression
fn array_subscript<'a>(
    loc: &program::Loc,
    array_ty: &Type,
    array: &Expression,
    index: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let array_ptr = expression(array, bin, func_context, ns);
    let index = expression(index, bin, func_context, ns);
    let array_length = match array_ty.deref_any() {
        Type::Array(..) => match array_ty.array_length() {
            None => {
                if let Type::StorageRef(..) = array_ty {
                    unimplemented!("storage array subscript")
                } else {
                    // If a subscript is encountered array length will be called
                    // Return array length by default
                    let array_length_expr = Expression::LibFunction {
                        loc: *loc,
                        tys: vec![Type::Uint(32)],
                        kind: LibFunc::ArrayLength,
                        args: vec![array.clone()],
                    };
                    let returned =
                        expression(&array_length_expr, bin, func_context, ns).into_int_value();
                    returned.into()
                }
            }

            Some(l) => {
                let ast_big_int = bigint_to_expression(
                    loc,
                    l,
                    ns,
                    &mut Diagnostics::default(),
                    ResolveTo::Unknown,
                )
                .unwrap();
                expression(&ast_big_int, bin, func_context, ns)
            }
        },
        _ => {
            unreachable!()
        }
    };

    if array_ty.is_dynamic_memory() {
        let array_type: BasicTypeEnum = bin.llvm_var_ty(array_ty, ns);
        let vector_ptr = bin.vector_data(array_ptr);
        return unsafe {
            bin.builder
                .build_gep(
                    array_type,
                    vector_ptr,
                    &[index.into_int_value()],
                    "index_access",
                )
                .as_basic_value_enum()
        };
    }

    let array_type = bin.llvm_type(array_ty.deref_memory(), ns);
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

    let element_ptr = unsafe {
        bin.builder.build_gep(
            array_type,
            array_ptr.into_pointer_value(),
            &[bin.context.i64_type().const_zero(), index.into_int_value()],
            "index_access",
        )
    };

    element_ptr.as_basic_value_enum()
}

pub fn assign_single<'a>(
    left: &Expression,
    right: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let right_value = expression(right, bin, func_context, ns);
    match left {
        ast::Expression::Variable { loc, ty, var_no } => {
            let right_value = match right_value {
                BasicValueEnum::PointerValue(p) => {
                    func_context.var_table.insert(*var_no, right_value);
                    if !ty.is_reference_type(ns) {
                        bin.builder.build_load(bin.llvm_var_ty(ty, ns), p, "")
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

            let dest = expression(left, bin, func_context, ns);

            match left_ty {
                Type::StorageRef(..) => {
                    unimplemented!()
                }
                Type::Ref(_) => {
                    bin.builder
                        .build_store(dest.into_pointer_value(), right_value);
                }
                _ => unreachable!(),
            }

            dest
        }
    }
}

// fn verify_sorted_array(
//     array: BasicValueEnum,
//     bin: &Binary,
//     func_context: &FunctionContext,
//     ns: &Namespace,
// ) {
//     let array_type = array.get_type();
//     let array_len = array_type.array_length();

//     let start_block = bin
//         .context
//         .append_basic_block(func_context.function, "start");
//     let loop_block = bin
//         .context
//         .append_basic_block(func_context.function, "loop");
//     let end_block = bin.context.append_basic_block(func_context.function,
// "end");

//     // Start block
//     bin.builder.position_at_end(start_block);
//     bin.builder.build_unconditional_branch(loop_block);

//     // Loop block
//     bin.builder.position_at_end(loop_block);

//     let index = bin.builder.build_phi(bin.context.i32_type(), "index");
//     index.add_incoming(&[(bin.context.i32_type().const_zero(),
// start_block)]);

//     let current_element_ptr = unsafe {
//         bin.builder.build_gep(
//             array.into_array_value(),
//             &[index.as_basic_value()],
//             "current_element_ptr",
//         )
//     };
//     let current_element = bin
//         .builder
//         .build_load(current_element_ptr, "current_element");

//     let next_index = bin.builder.build_int_add(
//         index.as_basic_value().into_int_value(),
//         bin.context.i32_type().const_int(1, false),
//         "next_index",
//     );
//     let next_element_ptr = unsafe {
//         bin.builder
//             .build_gep(array.into_array_value(), &[next_index],
// "next_element_ptr")     };
//     let next_element = bin.builder.build_load(next_element_ptr,
// "next_element");

//     let comparison = bin.builder.build_int_compare(
//         IntPredicate::ULE,
//         current_element.into_int_value(),
//         next_element.into_int_value(),
//         "comparison",
//     );

//     let continue_condition = bin.builder.build_int_compare(
//         IntPredicate::ULT,
//         next_index,
//         bin.context.i32_type().const_int(array_len as u64, false),
//         "continue_condition",
//     );
//     let is_sorted_condition =
//         bin.builder
//             .build_and(continue_condition, comparison,
// "is_sorted_condition");

//     index.add_incoming(&[(next_index, loop_block)]);

//     bin.builder
//         .build_conditional_branch(is_sorted_condition, loop_block,
// end_block);

//     // End block
//     bin.builder.position_at_end(end_block);
// }
