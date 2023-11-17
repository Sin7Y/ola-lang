use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::Expression::NumberLiteral;
use crate::sema::ast::{Expression, Namespace, Type};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::{IntPredicate, AddressSpace};
use num_bigint::BigInt;
use ola_parser::program::Loc;

use super::functions::Vartable;

pub fn u32_add<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = bin
        .builder
        .build_int_add(left.into_int_value(), right.into_int_value(), "")
        .into();
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[result.into()],
        "",
    );
    result
}

pub fn u32_sub<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = bin
        .builder
        .build_int_sub(left.into_int_value(), right.into_int_value(), "")
        .into();
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[result.into()],
        "",
    );
    result
}

pub fn u32_mul<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = bin
        .builder
        .build_int_mul(left.into_int_value(), right.into_int_value(), "")
        .into();
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[result.into()],
        "",
    );
    result
}

pub fn u32_div<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let ret = bin.build_alloca(func_value, bin.context.i64_type(), "");
    
    bin.builder
        .build_call(
            bin.module
                .get_function("u32_div_mod")
                .expect("u32_div_mod should have been defined before"),
            &[left.into(), right.into(), ret.into(), bin.context.i64_type().ptr_type(AddressSpace::default()).const_null().into()],
            "",
        );
    bin.builder.build_load(bin.context.i64_type(), ret, "")
}

pub fn u32_mod<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let ret = bin.build_alloca(func_value, bin.context.i64_type(), "");
    
    bin.builder
        .build_call(
            bin.module
                .get_function("u32_div_mod")
                .expect("u32_div_mod should have been defined before"),
            &[left.into(), right.into(), bin.context.i64_type().ptr_type(AddressSpace::default()).const_null().into(), ret.into()],
            "",
        );
    bin.builder.build_load(bin.context.i64_type(), ret, "")
}

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
    let left = bin.builder.build_int_z_extend(left.into_int_value(), bin.context.i64_type(), "");
    let right = bin.builder.build_int_z_extend(right.into_int_value(), bin.context.i64_type(), "");
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
    let left = bin.builder.build_int_z_extend(left.into_int_value(), bin.context.i64_type(), "");
    let right = bin.builder.build_int_z_extend(right.into_int_value(), bin.context.i64_type(), "");
    bin.builder.build_and(left, right, "").into()
}

pub fn u32_bitwise_and<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns).into_int_value();
    let right = expression(r, bin, func_value, var_table, ns).into_int_value();

    bin.builder.build_and(left, right, "").into()
}

pub fn u32_bitwise_or<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns).into_int_value();
    let right = expression(r, bin, func_value, var_table, ns).into_int_value();

    bin.builder.build_or(left, right, "").into()
}

pub fn u32_bitwise_xor<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns).into_int_value();
    let right = expression(r, bin, func_value, var_table, ns).into_int_value();

    bin.builder.build_xor(left, right, "").into()
}

pub fn u32_shift_left<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns).into_int_value();
    let base_two = NumberLiteral {
        loc: Loc::IRgen,
        ty: Type::Uint(32),
        value: BigInt::from(2),
    };
    let pow_two = u32_power(&base_two, r, bin, func_value, var_table, ns).into_int_value();
    let result: BasicValueEnum = bin.builder.build_int_mul(left, pow_two, "").into();
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[result.into()],
        "",
    );
    result
}

pub fn u32_shift_right<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns).into_int_value();
    let base_two = NumberLiteral {
        loc: Loc::IRgen,
        ty: Type::Uint(32),
        value: BigInt::from(2),
    };
    let right = u32_power(&base_two, r, bin, func_value, var_table, ns).into_int_value();

    let ret = bin.build_alloca(func_value, bin.context.i64_type(), "");
    
    bin.builder
        .build_call(
            bin.module
                .get_function("u32_div_mod")
                .expect("u32_div_mod should have been defined before"),
            &[left.into(), right.into(), ret.into(), bin.context.i64_type().ptr_type(AddressSpace::default()).const_null().into()],
            "",
        );
    bin.builder.build_load(bin.context.i64_type(), ret, "")
}

pub fn u32_compare<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
    op: IntPredicate,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns).into_int_value();
    let right = expression(r, bin, func_value, var_table, ns).into_int_value();

    bin.builder.build_int_compare(op, left, right, "").into()
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

pub fn u32_bitwise_not<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let u32_max = NumberLiteral {
        loc: Loc::IRgen,
        ty: Type::Uint(32),
        value: BigInt::from(u32::MAX),
    };
    u32_sub(&u32_max, expr, bin, func_value, var_table, ns)
}


pub fn u32_power<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {

    let left_value = expression(l, bin, func_value, var_table, ns).into_int_value();
    let right_value = expression(r, bin, func_value, var_table, ns).into_int_value();
     bin.builder
        .build_call(
            bin.module
                .get_function("u32_power")
                .expect("u32_power should have been defined before"),
            &[left_value.into(), right_value.into()],
            "",
        ).try_as_basic_value().left().unwrap()

}
