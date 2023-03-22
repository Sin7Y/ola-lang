use crate::irgen::binary::Binary;
use crate::sema::ast::{Expression, Function, LibFunc, Namespace, RetrieveType, Type};
use inkwell::values::{AnyValue, BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue};
use std::collections::HashMap;
use crate::irgen::u32_op::{u32_add, u32_and, u32_bitwise_and, u32_bitwise_or, u32_bitwise_xor, u32_complement, u32_div, u32_equal, u32_less, u32_less_equal, u32_mod, u32_more, u32_more_equal, u32_mul, u32_not, u32_not_equal, u32_or, u32_power, u32_shift_left, u32_shift_right, u32_sub};


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
            u32_add(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Subtract(_, _, l, r) => {
            u32_sub(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Multiply(_, _, l, r) => {
            u32_mul(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Divide(_, _, l, r) => {
            u32_div(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Modulo(_, _, l, r) => {
            u32_mod(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::BitwiseOr(_, _, l, r) => {
            u32_bitwise_or(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::BitwiseAnd(_, _, l, r) => {
            u32_bitwise_and(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::BitwiseXor(_, _, l, r) => {
            u32_bitwise_xor(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::ShiftLeft(_, _, l, r) => {
            u32_shift_left(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::ShiftRight(_, _, l, r) => {
            u32_shift_right(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Equal(_, l, r) => {
            u32_equal(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::NotEqual(_, l, r) => {
            u32_not_equal(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::More(_, l, r) => {
            u32_more(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::MoreEqual(_, l, r) => {
            u32_more_equal(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Less(_, l, r) => {
            u32_less(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::LessEqual(_, l, r) => {
            u32_less_equal(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Not(_, expr) => {
            u32_not(expr, bin, func, func_val, var_table, ns)
        }
        Expression::Complement(_, _, expr) => {
            u32_complement(expr, bin, func, func_val, var_table, ns)
        }
        Expression::Or(_, l, r) => {
            u32_or(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::And(_, l, r) => {
            u32_and(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Power(_, _, l, r) => {
            u32_power(l, r, bin, func, func_val, var_table, ns)
        }
        Expression::Decrement(_, _, expr) => match **expr {
            Expression::Variable(_, _, pos) => {
                let one = bin.context.i64_type().const_int(1, false);
                let before_ptr = *var_table.get(&pos).unwrap();
                let before_val = bin.builder.build_load(before_ptr.into_pointer_value(), "");
                before_val.as_instruction_value().unwrap().set_alignment(8).unwrap();
                let after = bin
                    .builder
                    .build_int_sub(before_val.as_any_value_enum().into_int_value(), one, "");
                bin.builder
                    .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum()).set_alignment(8).unwrap();
                return before_ptr.as_basic_value_enum();
            }
            _ => unreachable!(),
        },
        Expression::Increment(_, _, expr) => match **expr {
            Expression::Variable(_, _, pos) => {
                let one = bin.context.i64_type().const_int(1, false);
                let before_ptr = *var_table.get(&pos).unwrap();
                let before_val = bin.builder.build_load(before_ptr.into_pointer_value(), "");
                before_val.as_instruction_value().unwrap().set_alignment(8).unwrap();
                let after = bin
                    .builder
                    .build_int_add(before_val.into_int_value(), one, "");
                bin.builder
                    .build_store(before_ptr.into_pointer_value(), after.as_basic_value_enum()).set_alignment(8).unwrap();
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
        Expression::NumberLiteral(_, ty, n) => bin.number_literal(ty, n, ns).into(),

        Expression::Variable(_, _, var_no) => {
            let ptr = var_table.get(var_no).unwrap().as_basic_value_enum();
            let load_var = bin.builder.build_load(ptr.into_pointer_value(), "");
            load_var.as_instruction_value().unwrap().set_alignment(8).unwrap();
            load_var
        }

        Expression::LibFunction(_, _, LibFunc::U32Sqrt, args) => {
            let value =
                expression(&args[0], bin, func, func_val, var_table, ns).into_int_value();
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
    let mut ret_value = bin.context.i64_type().const_zero().as_basic_value_enum();
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
