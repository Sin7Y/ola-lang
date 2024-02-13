use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::Expression::NumberLiteral;
use crate::sema::ast::{Expression, Namespace, Type};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::{AddressSpace, IntPredicate};
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
        bin.module.get_function("builtin_range_check").unwrap(),
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
        bin.module.get_function("builtin_range_check").unwrap(),
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
        bin.module.get_function("builtin_range_check").unwrap(),
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

    bin.builder.build_call(
        bin.module.get_function("u32_div_mod").unwrap(),
        &[
            left.into(),
            right.into(),
            ret.into(),
            bin.context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .const_null()
                .into(),
        ],
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

    bin.builder.build_call(
        bin.module.get_function("u32_div_mod").unwrap(),
        &[
            left.into(),
            right.into(),
            bin.context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .const_null()
                .into(),
            ret.into(),
        ],
        "",
    );
    bin.builder.build_load(bin.context.i64_type(), ret, "")
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
        bin.module.get_function("builtin_range_check").unwrap(),
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

    bin.builder.build_call(
        bin.module.get_function("u32_div_mod").unwrap(),
        &[
            left.into(),
            right.into(),
            ret.into(),
            bin.context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .const_null()
                .into(),
        ],
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
            bin.module.get_function("u32_power").unwrap(),
            &[left_value.into(), right_value.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .unwrap()
}

pub fn define_u32_power<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    let context = &bin.context;
    let builder = &bin.builder;
    let i64_type = context.i64_type();

    let entry_block = context.append_basic_block(function, "entry");
    let loop_block = context.append_basic_block(function, "loop");
    let exit_block = context.append_basic_block(function, "exit");

    builder.position_at_end(entry_block);

    let base = function.get_nth_param(0).unwrap().into_int_value();
    let exponent = function.get_nth_param(1).unwrap().into_int_value();

    let counter_ptr = builder.build_alloca(i64_type, "counter");
    let result_ptr = builder.build_alloca(i64_type, "result");

    builder.build_store(counter_ptr, i64_type.const_zero());
    builder.build_store(result_ptr, i64_type.const_int(1, false));

    builder.build_unconditional_branch(loop_block);

    builder.position_at_end(loop_block);

    let counter = builder
        .build_load(context.i64_type(), counter_ptr, "")
        .into_int_value();
    let result = builder
        .build_load(context.i64_type(), result_ptr, "")
        .into_int_value();

    let new_counter = builder.build_int_add(counter, i64_type.const_int(1, false), "newCounter");
    let new_result = builder.build_int_mul(result, base, "newResult");

    builder.build_store(counter_ptr, new_counter);
    builder.build_store(result_ptr, new_result);

    let condition = builder.build_int_compare(
        inkwell::IntPredicate::ULT,
        new_counter,
        exponent,
        "condition",
    );
    builder.build_conditional_branch(condition, loop_block, exit_block);

    builder.position_at_end(exit_block);

    let final_result = builder
        .build_load(context.i64_type(), result_ptr, "finalResult")
        .into_int_value();
    builder.build_return(Some(&final_result));
}

pub fn define_u32_div_mod<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let dividend = function.get_nth_param(0).unwrap();
    let divisor = function.get_nth_param(1).unwrap();
    let quotient = function.get_nth_param(2).unwrap().into_pointer_value();
    let remainder = function.get_nth_param(3).unwrap().into_pointer_value();

    let remainder_ret = bin
        .builder
        .build_call(
            bin.module.get_function("prophet_u32_mod").unwrap(),
            &[dividend.into(), divisor.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // remainder should be in the u32 range
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[remainder_ret.into()],
        "",
    );

    // 0 <= right - (remainder + 1)
    let one = bin.context.i64_type().const_int(1, false);
    let right_minus_remainder_minus_one = bin.builder.build_int_sub(
        divisor.into_int_value(),
        bin.builder
            .build_int_add(remainder_ret.into_int_value(), one, ""),
        "",
    );
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[right_minus_remainder_minus_one.into()],
        "",
    );

    let quotient_ret = bin
        .builder
        .build_call(
            bin.module.get_function("prophet_u32_div").unwrap(),
            &[dividend.into(), divisor.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // quotient should be in the u32 range
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[quotient.into()],
        "",
    );

    // assert that quotient * right + remainder == left
    let quotient_mul_right_plus_remainder = bin.builder.build_int_add(
        bin.builder
            .build_int_mul(quotient_ret.into_int_value(), divisor.into_int_value(), ""),
        remainder_ret.into_int_value(),
        "",
    );

    let equal = bin.builder.build_int_compare(
        IntPredicate::EQ,
        quotient_mul_right_plus_remainder,
        dividend.into_int_value(),
        "",
    );

    bin.builder.build_call(
        bin.module.get_function("builtin_assert").unwrap(),
        &[bin
            .builder
            .build_int_z_extend(equal, bin.context.i64_type(), "")
            .into()],
        "",
    );
    bin.builder.build_store(quotient, quotient_ret);
    bin.builder.build_store(remainder, remainder_ret);
    bin.builder.build_return(None);
}

pub fn define_u32_sqrt<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let value = function.get_first_param().unwrap().into();
    let root = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_sqrt")
                .expect("prophet_u32_sqrt should have been defined before"),
            &[value],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    bin.range_check(root.into_int_value());
    let root_squared = bin
        .builder
        .build_int_mul(root.into_int_value(), root.into_int_value(), "");
    let equal = bin.builder.build_int_compare(
        inkwell::IntPredicate::EQ,
        root_squared,
        value.into_int_value(),
        "",
    );
    bin.builder.build_call(
        bin.module.get_function("builtin_assert").unwrap(),
        &[bin
            .builder
            .build_int_z_extend(equal, bin.context.i64_type(), "")
            .into()],
        "",
    );
    bin.builder.build_return(Some(&root));
}
