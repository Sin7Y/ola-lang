use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::Expression::NumberLiteral;
use crate::sema::ast::{Expression, Namespace, Type};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::{AddressSpace, IntPredicate};
use num_bigint::BigInt;
use ola_parser::program::Loc;

use super::functions::Vartable;

pub fn u256_add<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = u256_add_internal(left, right, bin, func_value, var_table, ns);
    result
}

pub fn u256_add_internal<'a>(
    l: BasicValueEnum<'a>,
    r: BasicValueEnum<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_sub<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = u256_sub_internal(left, right, bin, func_value, var_table, ns);
    result
}

pub fn u256_sub_internal<'a>(
    l: BasicValueEnum<'a>,
    r: BasicValueEnum<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_mul<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_div<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_mod<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_bitwise_and<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_bitwise_or<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_bitwise_xor<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_shift_left<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_shift_right<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_compare<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
    op: IntPredicate,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_bitwise_not<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}

pub fn u256_power<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    unimplemented!()
}
