use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::irgen::functions::FunctionContext;
use crate::sema::ast::Expression::NumberLiteral;
use crate::sema::ast::{Expression, Namespace, Type};
use inkwell::values::BasicValueEnum;
use inkwell::IntPredicate;
use num_bigint::BigInt;
use ola_parser::program::Loc;

pub fn u32_add<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns);
    let right = expression(r, bin, func_context, ns);
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
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns);
    let right = expression(r, bin, func_context, ns);
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
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns);
    let right = expression(r, bin, func_context, ns);
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
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns);
    let right = expression(r, bin, func_context, ns);

    let remainder = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_mod")
                .expect("prophet_u32_mod should have been defined before"),
            &[left.into(), right.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // remainder should be in the u32 range
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[remainder.into()],
        "",
    );

    // 0 <= right - (remainder + 1)
    let one = bin.context.i64_type().const_int(1, false);
    let right_minus_remainder_minus_one = bin.builder.build_int_sub(
        right.into_int_value(),
        bin.builder
            .build_int_add(remainder.into_int_value(), one, ""),
        "",
    );
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[right_minus_remainder_minus_one.into()],
        "",
    );

    let quotient = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_div")
                .expect("prophet_u32_div should have been defined before"),
            &[left.into(), right.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // quotient should be in the u32 range
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[quotient.into()],
        "",
    );

    // assert that quotient * right + remainder == left
    let quotient_mul_right_plus_remainder = bin.builder.build_int_add(
        bin.builder
            .build_int_mul(quotient.into_int_value(), right.into_int_value(), ""),
        remainder.into_int_value(),
        "",
    );

    bin.builder.build_call(
        bin.module
            .get_function("builtin_assert")
            .expect("builtin_assert should have been defined before"),
        &[quotient_mul_right_plus_remainder.into(), left.into()],
        "",
    );
    quotient
}

pub fn u32_mod<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns);
    let right = expression(r, bin, func_context, ns);

    let remainder = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_mod")
                .expect("prophet_u32_mod should have been defined before"),
            &[left.into(), right.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // remainder should be in the u32 range
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[remainder.into()],
        "",
    );

    // 0 <= right - (remainder + 1)
    let one = bin.context.i64_type().const_int(1, false);
    let right_minus_remainder_minus_one = bin.builder.build_int_sub(
        right.into_int_value(),
        bin.builder
            .build_int_add(remainder.into_int_value(), one, ""),
        "",
    );
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[right_minus_remainder_minus_one.into()],
        "",
    );

    let quotient = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_div")
                .expect("prophet_u32_div should have been defined before"),
            &[left.into(), right.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // quotient should be in the u32 range
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[quotient.into()],
        "",
    );

    // assert that quotient * right + remainder == left
    let quotient_mul_right_plus_remainder = bin.builder.build_int_add(
        bin.builder
            .build_int_mul(quotient.into_int_value(), right.into_int_value(), ""),
        remainder.into_int_value(),
        "",
    );

    bin.builder.build_call(
        bin.module
            .get_function("builtin_assert")
            .expect("builtin_assert should have been defined before"),
        &[quotient_mul_right_plus_remainder.into(), left.into()],
        "",
    );
    remainder
}

pub fn u32_bitwise_or<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder.build_or(left, right, "").into()
}

pub fn u32_bitwise_and<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder.build_and(left, right, "").into()
}

pub fn u32_bitwise_xor<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder.build_xor(left, right, "").into()
}

pub fn u32_shift_left<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let base_two = NumberLiteral(Loc::IRgen, Type::Uint(32), BigInt::from(2));
    let pow_two = u32_power(&base_two, r, bin, func_context, ns).into_int_value();
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
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let base_two = NumberLiteral(Loc::IRgen, Type::Uint(32), BigInt::from(2));
    let right = u32_power(&base_two, r, bin, func_context, ns).into_int_value();
    let remainder = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_mod")
                .expect("prophet_u32_mod should have been defined before"),
            &[left.into(), right.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // remainder should be in the u32 range
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[remainder.into()],
        "",
    );

    // 0 <= right - (remainder + 1)
    let one = bin.context.i64_type().const_int(1, false);
    let right_minus_remainder_minus_one = bin.builder.build_int_sub(
        right,
        bin.builder
            .build_int_add(remainder.into_int_value(), one, ""),
        "",
    );
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[right_minus_remainder_minus_one.into()],
        "",
    );

    let quotient = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_div")
                .expect("prophet_u32_div should have been defined before"),
            &[left.into(), right.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // quotient should be in the u32 range
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[quotient.into()],
        "",
    );

    // assert that quotient * right + remainder == left
    let quotient_mul_right_plus_remainder = bin.builder.build_int_add(
        bin.builder
            .build_int_mul(quotient.into_int_value(), right, ""),
        remainder.into_int_value(),
        "",
    );

    bin.builder.build_call(
        bin.module
            .get_function("builtin_assert")
            .expect("builtin_assert should have been defined before"),
        &[quotient_mul_right_plus_remainder.into(), left.into()],
        "",
    );
    quotient
}

pub fn u32_equal<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::EQ, left, right, "")
        .into()
}

pub fn u32_not_equal<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::NE, left, right, "")
        .into()
}

pub fn u32_more<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::UGT, left, right, "")
        .into()
}

pub fn u32_more_equal<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::UGE, left, right, "")
        .into()
}

pub fn u32_less<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::ULT, left, right, "")
        .into()
}

pub fn u32_less_equal<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_context, ns).into_int_value();
    let right = expression(r, bin, func_context, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::ULE, left, right, "")
        .into()
}

pub fn u32_not<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let e = expression(expr, bin, func_context, ns).into_int_value();

    bin.builder
        .build_int_compare(IntPredicate::EQ, e, e.get_type().const_zero(), "")
        .into()
}

pub fn u32_bitwise_not<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let u32_max = NumberLiteral(Loc::IRgen, Type::Uint(32), BigInt::from(u32::MAX));
    u32_sub(&u32_max, expr, bin, func_context, ns)
}

pub fn u32_or<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    // Generate code for the left and right expressions
    let left_value = expression(l, bin, func_context, ns).into_int_value();

    let bool_type = bin.context.bool_type();
    // Create basic blocks for the OR expression
    let current_bb = bin.builder.get_insert_block().unwrap();
    let left_true_bb = bin
        .context
        .append_basic_block(func_context.func_val, "left_true");
    let right_true_bb = bin
        .context
        .append_basic_block(func_context.func_val, "right_true");
    let merge_bb = bin
        .context
        .append_basic_block(func_context.func_val, "merge");
    bin.builder.position_at_end(current_bb);

    // Create a temporary variable to store the result
    let result_ptr = bin.build_alloca(func_context.func_val, bool_type, "");

    // Generate the OR expression using basic blocks
    bin.builder
        .build_conditional_branch(left_value, left_true_bb, right_true_bb);

    bin.builder.position_at_end(left_true_bb);
    bin.builder.build_store(result_ptr, left_value);
    bin.builder.build_unconditional_branch(merge_bb);

    bin.builder.position_at_end(right_true_bb);
    let right_value = expression(r, bin, func_context, ns).into_int_value();
    bin.builder.build_store(result_ptr, right_value);
    bin.builder.build_unconditional_branch(merge_bb);

    bin.builder.position_at_end(merge_bb);
    let result = bin.builder.build_load(bool_type, result_ptr, "");

    result
}

pub fn u32_and<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    // Generate code for the left and right expressions
    let left_value = expression(l, bin, func_context, ns).into_int_value();

    let bool_type = bin.context.bool_type();
    // Create basic blocks for the OR expression
    let current_bb = bin.builder.get_insert_block().unwrap();
    let left_false_bb = bin
        .context
        .append_basic_block(func_context.func_val, "left_false");
    let right_false_bb = bin
        .context
        .append_basic_block(func_context.func_val, "right_false");
    let merge_bb = bin
        .context
        .append_basic_block(func_context.func_val, "merge");
    bin.builder.position_at_end(current_bb);

    // Create a temporary variable to store the result
    let result_ptr = bin.build_alloca(func_context.func_val, bool_type, "");

    // Generate the OR expression using basic blocks
    bin.builder
        .build_conditional_branch(left_value, right_false_bb, left_false_bb);

    bin.builder.position_at_end(left_false_bb);
    bin.builder.build_store(result_ptr, left_value);
    bin.builder.build_unconditional_branch(merge_bb);

    bin.builder.position_at_end(right_false_bb);
    let right_value = expression(r, bin, func_context, ns).into_int_value();
    bin.builder.build_store(result_ptr, right_value);
    bin.builder.build_unconditional_branch(merge_bb);

    bin.builder.position_at_end(merge_bb);
    let result = bin.builder.build_load(bool_type, result_ptr, "");

    result
}

pub fn u32_power<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let current_bb = bin.builder.get_insert_block().unwrap();
    let left_value = expression(l, bin, func_context, ns).into_int_value();
    let right_value = expression(r, bin, func_context, ns).into_int_value();
    bin.builder.position_at_end(current_bb);

    let loop_block = bin
        .context
        .append_basic_block(func_context.func_val, "loop");
    let exit_block = bin
        .context
        .append_basic_block(func_context.func_val, "exit");
    let i64_type = bin.context.i64_type();

    // Initialize the accumulator with the value 1
    let accumulator = bin.build_alloca(func_context.func_val, bin.context.i64_type(), "");
    bin.builder
        .build_store(accumulator, i64_type.const_int(1, false));

    let current_right_value = bin.build_alloca(func_context.func_val, bin.context.i64_type(), "");
    bin.builder.build_store(current_right_value, right_value);

    bin.builder.build_unconditional_branch(loop_block);
    bin.builder.position_at_end(loop_block);

    let current_right_value_loaded = bin
        .builder
        .build_load(i64_type, current_right_value, "")
        .into_int_value();

    let is_zero = bin.builder.build_int_compare(
        IntPredicate::EQ,
        current_right_value_loaded,
        i64_type.const_zero(),
        "",
    );
    bin.builder
        .build_conditional_branch(is_zero, exit_block, loop_block);

    bin.builder.position_at_end(loop_block);

    // Update the accumulator
    let acc_value = bin
        .builder
        .build_load(i64_type, accumulator, "")
        .into_int_value();
    let new_acc_value = bin.builder.build_int_mul(acc_value, left_value, "");
    bin.builder.build_store(accumulator, new_acc_value);

    // Decrement the right value
    let updated_right_value =
        bin.builder
            .build_int_sub(current_right_value_loaded, i64_type.const_int(1, false), "");
    bin.builder
        .build_store(current_right_value, updated_right_value);

    bin.builder.build_unconditional_branch(loop_block);

    bin.builder.position_at_end(exit_block);
    let result = bin.builder.build_load(i64_type, accumulator, "");
    bin.builder.build_call(
        bin.module
            .get_function("builtin_range_check")
            .expect("builtin_range_check should have been defined before"),
        &[result.into()],
        "",
    );
    result
}
