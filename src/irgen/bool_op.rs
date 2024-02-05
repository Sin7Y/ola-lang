use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::Expression::NumberLiteral;
use crate::sema::ast::{Expression, Namespace, Type};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::{AddressSpace, IntPredicate};
use num_bigint::BigInt;
use ola_parser::program::Loc;

use super::functions::Vartable;

pub fn logic_or<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let left = bin
        .builder
        .build_int_z_extend(left.into_int_value(), bin.context.i64_type(), "");
    let right = bin
        .builder
        .build_int_z_extend(right.into_int_value(), bin.context.i64_type(), "");
    bin.builder.build_or(left, right, "").into()
}

pub fn logic_and<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let left = bin
        .builder
        .build_int_z_extend(left.into_int_value(), bin.context.i64_type(), "");
    let right = bin
        .builder
        .build_int_z_extend(right.into_int_value(), bin.context.i64_type(), "");
    bin.builder.build_and(left, right, "").into()
}

// Logical NOT operation can only be used for bool type.
pub fn logic_not<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let e = expression(expr, bin, func_value, var_table, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::EQ, e, e.get_type().const_zero(), "")
        .into()
}
