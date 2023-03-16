use crate::irgen::binary::Binary;
use crate::sema::ast::{Expression, Function, LibFunc, Namespace, RetrieveType};
use inkwell::values::{BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue};
use inkwell::IntPredicate;
use std::collections::HashMap;


// field only supports + - * / operations, all other operations are not supported
pub fn expression<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func: Option<&Function>,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match expr {
        Expression::Add(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns);
            let right = expression(r, bin, func, func_val, var_table, ns);
            bin.builder
                .build_int_add(left.into_int_value(), right.into_int_value(), "")
                .into()
        }
        Expression::Subtract(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_sub(left, right, "").into()
        }
        Expression::Multiply(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_mul(left, right, "").into()
        }
        Expression::Divide(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_unsigned_div(left, right, "").into()
        }

        // only support u32、u6
        Expression::Modulo(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_unsigned_rem(left, right, "").into()
        }
        Expression::BitwiseOr(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_or(left, right, "").into()
        }
        Expression::BitwiseAnd(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_and(left, right, "").into()
        }
        Expression::BitwiseXor(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_xor(left, right, "").into()
        }
        Expression::ShiftLeft(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_left_shift(left, right, "").into()
        }
        Expression::ShiftRight(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_right_shift(left, right, false, "").into()
        }
        Expression::Equal(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::EQ, left, right, "")
                .into()
        }
        Expression::NotEqual(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::NE, left, right, "")
                .into()
        }
        Expression::More(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::UGT, left, right, "")
                .into()
        }
        Expression::MoreEqual(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::UGE, left, right, "")
                .into()
        }
        Expression::Less(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::ULT, left, right, "")
                .into()
        }
        Expression::LessEqual(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::ULE, left, right, "")
                .into()
        }
        Expression::Not(_, expr) => {
            let e = expression(expr, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::EQ, e, e.get_type().const_zero(), "")
                .into()
        }
        Expression::Complement(_, _, expr) => {
            let e = expression(expr, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_not(e, "").into()
        }
        Expression::Decrement(_, _, expr) => match **expr {
            Expression::Variable(_, _, pos) => {
                let one = bin.context.i32_type().const_int(1, false);
                let before_ptr = *var_table.get(&pos).unwrap();
                let before_val = bin.builder.build_load(before_ptr.into_pointer_value(), "");
                let after = bin
                    .builder
                    .build_int_sub(before_val.into_int_value(), one, "");
                bin.builder
                    .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum());
                return before_ptr.as_basic_value_enum();
            }
            _ => unreachable!(),
        },
        Expression::Increment(_, _, expr) => match **expr {
            Expression::Variable(_, _, pos) => {
                let one = bin.context.i32_type().const_int(1, false);
                let before_ptr = *var_table.get(&pos).unwrap();
                let before_val = bin.builder.build_load(before_ptr.into_pointer_value(), "");
                let after = bin
                    .builder
                    .build_int_add(before_val.into_int_value(), one, "");
                bin.builder
                    .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum());
                return before_ptr.as_basic_value_enum();
            }
            _ => unreachable!(),
        },
        Expression::Assign(_, _, l, r) => {
            let right = expression(r, bin, func, func_val, var_table, ns);
            let left = match **l {
                Expression::Variable(_, _, pos) => {
                    let ret = *var_table.get(&pos).unwrap();
                    ret
                }
                _ => unreachable!(),
            };
            bin.builder.build_store(left.into_pointer_value(), right);
            left
        }
        Expression::FunctionCall { .. } => {
            emit_function_call(expr, bin, func, func_val, var_table, ns)
        }

        Expression::Or(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns);
            let right = expression(r, bin, func, func_val, var_table, ns);
            bin.builder
                .build_or(left.into_int_value(), right.into_int_value(), "")
                .into()
        }

        Expression::NumberLiteral(_, ty, n) => bin.number_literal(ty.bits(ns) as u32, n, ns).into(),

        Expression::Variable(_, _, var_no) => {
            let ptr = var_table.get(var_no).unwrap().as_basic_value_enum();
            bin.builder.build_load(ptr.into_pointer_value(), "")
        }

        Expression::LibFunction(_, _, LibFunc::U32_SQRT, args) => {
            let value_u32 = expression(&args[0], bin, func, func_val, var_table, ns).into_int_value();
            let value_u64 = bin.builder.build_int_s_extend(
                value_u32,
                bin.context.i64_type(),
                "extended_a",
            );
            let root = bin.builder.build_call(
                bin.module.get_function("u32_sqrt").expect("u32_sqrt should have been defined before"),
                &[value_u64.into()],
                "",
            ).try_as_basic_value().left().expect("Should have a left return value");

            let res = bin.builder.build_int_truncate(root.into_int_value(), bin.context.i32_type(), "truncate_a");
            res.as_basic_value_enum()

        }

        _ => unreachable!(),
    }
}

//Convert a function call expression to CFG in expression context
pub fn emit_function_call<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func: Option<&Function>,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let mut ret_value = bin.context.i32_type().const_zero().as_basic_value_enum();
    match expr {
        Expression::FunctionCall { function, args, .. } => {
            if let Expression::Function { function_no, .. } = function.as_ref() {
                let callee = &ns.functions[*function_no];
                if let Some(callee_value) = bin.module.get_function(&callee.name) {
                    let params = args
                        .iter()
                        .map(|a| expression(a, bin, func, func_val, var_table, ns).into())
                        .collect::<Vec<BasicMetadataValueEnum>>();

                    ret_value = bin
                        .builder
                        .build_call(callee_value, &params, "")
                        .try_as_basic_value()
                        .left()
                        .unwrap();
                }
            }
            ret_value
        }
        _ => unreachable!(),
    }
}
