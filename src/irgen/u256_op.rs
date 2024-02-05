use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::{Expression, Namespace, Type};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::IntPredicate;

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
    let result: BasicValueEnum = u256_add_internal(left, right, bin);
    result
}

pub fn u256_add_internal<'a>(
    l: BasicValueEnum<'a>,
    r: BasicValueEnum<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let result = bin
        .builder
        .build_call(
            bin.module.get_function("u256_add").unwrap(),
            &[l.into(), r.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    result
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
    let result: BasicValueEnum = u256_sub_internal(left, right, bin);
    result
}

pub fn u256_sub_internal<'a>(
    l: BasicValueEnum<'a>,
    r: BasicValueEnum<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let result = bin
        .builder
        .build_call(
            bin.module.get_function("u256_sub").unwrap(),
            &[l.into(), r.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    result
}

pub fn u256_mul<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = u256_mul_internal(left, right, bin);
    result
}

pub fn u256_mul_internal<'a>(
    l: BasicValueEnum<'a>,
    r: BasicValueEnum<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let result = bin
        .builder
        .build_call(
            bin.module.get_function("u256_mul").unwrap(),
            &[l.into(), r.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    result
}

#[allow(unused_variables)]
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

#[allow(unused_variables)]
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
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = u256_bitwise_internal(left, right, bin, "u256_bitwise_and");
    result
}

pub fn u256_bitwise_or<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = u256_bitwise_internal(left, right, bin, "u256_bitwise_or");
    result
}

pub fn u256_bitwise_xor<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);
    let result: BasicValueEnum = u256_bitwise_internal(left, right, bin, "u256_bitwise_xor");
    result
}

pub fn u256_bitwise_internal<'a>(
    l: BasicValueEnum<'a>,
    r: BasicValueEnum<'a>,
    bin: &Binary<'a>,
    op: &str,
) -> BasicValueEnum<'a> {
    let result = bin
        .builder
        .build_call(
            bin.module.get_function(op).unwrap(),
            &[l.into(), r.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    result
}

#[allow(unused_variables)]
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

#[allow(unused_variables)]
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
    let left = expression(l, bin, func_value, var_table, ns).into_pointer_value();
    let right = expression(r, bin, func_value, var_table, ns).into_pointer_value();
    bin.memcmp(
        left,
        right,
        bin.context.i64_type().const_int(8, false),
        op,
        &Type::Uint(32),
    )
    .into()
}

pub fn u256_bitwise_not<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let expr = expression(expr, bin, func_value, var_table, ns);
    let result: BasicValueEnum = u256_bitwise_not_internal(expr, bin);
    result
}

pub fn u256_bitwise_not_internal<'a>(
    v: BasicValueEnum<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let result = bin
        .builder
        .build_call(
            bin.module.get_function("u256_bitwise_not").unwrap(),
            &[v.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    result
}

#[allow(unused_variables)]
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

pub fn define_u256_add<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>) {
    let i64_type = bin.context.i64_type();

    let entry = bin.context.append_basic_block(func_value, "entry");

    bin.builder.position_at_end(entry);

    let l = func_value.get_first_param().unwrap().into_pointer_value();
    let r = func_value.get_nth_param(1).unwrap().into_pointer_value();

    let result_ret = bin.heap_malloc(bin.context.i64_type().const_int(8, false));

    let mut carry = bin.context.i64_type().const_int(0, false);

    for i in 0..8 {
        let left_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, l, &[i64_type.const_int(7 - i, false)], "")
        };
        let left = bin
            .builder
            .build_load(i64_type, left_ptr, "")
            .into_int_value();

        let right_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, r, &[i64_type.const_int(7 - i, false)], "")
        };
        let right = bin
            .builder
            .build_load(i64_type, right_ptr, "")
            .into_int_value();

        let sum = bin.builder.build_int_add(left, right, "");
        let sum_with_carry = bin.builder.build_int_add(sum, carry, "sum_with_carry");
        let field_low;

        if i < 7 {
            let field_high_ptr = bin.build_alloca(func_value, bin.context.i64_type(), "field_high");
            let field_low_ptr = bin.build_alloca(func_value, bin.context.i64_type(), "field_low");

            bin.builder.build_call(
                bin.module.get_function("split_field").unwrap(),
                &[
                    sum_with_carry.into(),
                    field_high_ptr.into(),
                    field_low_ptr.into(),
                ],
                "",
            );

            let field_high = bin
                .builder
                .build_load(bin.context.i64_type(), field_high_ptr, "")
                .into_int_value();
            carry = field_high;

            field_low = bin
                .builder
                .build_load(bin.context.i64_type(), field_low_ptr, "")
                .into_int_value();
        } else {
            // We should ensure that the highest bit does not overflow during the last
            // calculation.
            bin.range_check(sum_with_carry);
            field_low = sum_with_carry;
        }

        let result_ret_ptr = unsafe {
            bin.builder.build_gep(
                i64_type,
                result_ret,
                &[i64_type.const_int(7 - i, false)],
                "",
            )
        };
        bin.builder.build_store(result_ret_ptr, field_low);
    }

    bin.builder.build_return(Some(&result_ret));
}

pub fn define_u256_sub<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>) {
    let i64_type = bin.context.i64_type();

    let u32_max_plus = bin.context.i64_type().const_int(u32::MAX as u64 + 1, false);

    let entry = bin.context.append_basic_block(func_value, "entry");

    bin.builder.position_at_end(entry);

    let l = func_value.get_first_param().unwrap().into_pointer_value();
    let r = func_value.get_nth_param(1).unwrap().into_pointer_value();

    let result_ret = bin.heap_malloc(bin.context.i64_type().const_int(8, false));

    let mut borrow = bin.context.i64_type().const_int(0, false);

    for i in 0..8 {
        let left_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, l, &[i64_type.const_int(7 - i, false)], "")
        };
        let mut left = bin
            .builder
            .build_load(i64_type, left_ptr, "")
            .into_int_value();

        let right_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, r, &[i64_type.const_int(7 - i, false)], "")
        };
        let right = bin
            .builder
            .build_load(i64_type, right_ptr, "")
            .into_int_value();

        // borrow[i] = a[i] - borrow[i-1] < b[i]
        // c[i] = a[i] + borrow[i] * 2^32 - b[i]
        if i != 0 {
            left = bin.builder.build_int_sub(left, borrow, "");
        }
        let diff;
        if i < 7 {
            borrow = bin
                .builder
                .build_int_compare(IntPredicate::UGT, right, left, "borrow");
            borrow = bin
                .builder
                .build_int_z_extend(borrow, bin.context.i64_type(), "")
                .into();
            let borrow_val = bin.builder.build_int_mul(borrow, u32_max_plus, "");
            let sum_borrow = bin.builder.build_int_add(left, borrow_val, "");
            diff = bin.builder.build_int_sub(sum_borrow, right, "");

        // We should ensure that the highest bit does not overflow during the
        // last calculation.
        } else {
            diff = bin.builder.build_int_sub(left, right, "");
            bin.range_check(diff);
        }

        let result_ret_ptr = unsafe {
            bin.builder.build_gep(
                i64_type,
                result_ret,
                &[i64_type.const_int(7 - i, false)],
                "",
            )
        };
        bin.builder.build_store(result_ret_ptr, diff);
    }

    bin.builder.build_return(Some(&result_ret));
}

pub fn define_u256_bitwise<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>, op: &str) {
    let i64_type = bin.context.i64_type();

    let entry = bin.context.append_basic_block(func_value, "entry");

    bin.builder.position_at_end(entry);

    let l = func_value.get_first_param().unwrap().into_pointer_value();
    let r = func_value.get_nth_param(1).unwrap().into_pointer_value();

    let result_ret = bin.heap_malloc(bin.context.i64_type().const_int(8, false));

    for i in 0..8 {
        let left_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, l, &[i64_type.const_int(7 - i, false)], "")
        };
        let left = bin
            .builder
            .build_load(i64_type, left_ptr, "")
            .into_int_value();

        let right_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, r, &[i64_type.const_int(7 - i, false)], "")
        };
        let right = bin
            .builder
            .build_load(i64_type, right_ptr, "")
            .into_int_value();

        let res = match op {
            "and" => bin.builder.build_and(left, right, ""),
            "or" => bin.builder.build_or(left, right, ""),
            "xor" => bin.builder.build_xor(left, right, ""),
            _ => unreachable!(),
        };

        let result_ret_ptr = unsafe {
            bin.builder.build_gep(
                i64_type,
                result_ret,
                &[i64_type.const_int(7 - i, false)],
                "",
            )
        };
        bin.builder.build_store(result_ret_ptr, res);
    }

    bin.builder.build_return(Some(&result_ret));
}

pub fn define_u256_bitwise_not<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>) {
    let i64_type = bin.context.i64_type();

    let u32_max = bin.context.i64_type().const_int(u32::MAX as u64, false);

    let entry = bin.context.append_basic_block(func_value, "entry");

    bin.builder.position_at_end(entry);

    let v = func_value.get_first_param().unwrap().into_pointer_value();

    let result_ret = bin.heap_malloc(bin.context.i64_type().const_int(8, false));

    for i in 0..8 {
        let v_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, v, &[i64_type.const_int(7 - i, false)], "")
        };
        let val = bin.builder.build_load(i64_type, v_ptr, "").into_int_value();

        let result: BasicValueEnum = bin.builder.build_int_sub(u32_max, val, "").into();
        bin.builder.build_call(
            bin.module.get_function("builtin_range_check").unwrap(),
            &[result.into()],
            "",
        );

        let result_ret_ptr = unsafe {
            bin.builder.build_gep(
                i64_type,
                result_ret,
                &[i64_type.const_int(7 - i, false)],
                "",
            )
        };
        bin.builder.build_store(result_ret_ptr, result);
    }

    bin.builder.build_return(Some(&result_ret));
}

// TODO: Recursive exponential calculation multiplication and addition for
// C[0..7] = A[0..7] * B[0..7]
pub fn define_u256_mul<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>) {
    let i64_type = bin.context.i64_type();

    let entry = bin.context.append_basic_block(func_value, "entry");

    bin.builder.position_at_end(entry);

    let l = func_value.get_first_param().unwrap().into_pointer_value();
    let r = func_value.get_nth_param(1).unwrap().into_pointer_value();

    let result_ret = bin.heap_malloc(bin.context.i64_type().const_int(8, false));

    // let mut carry = bin.context.i64_type().const_int(0, false);

    let mut lefts = Vec::new();
    let mut rights = Vec::new();
    for i in 0..8 {
        let left_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, l, &[i64_type.const_int(i, false)], "")
        };
        let left = bin
            .builder
            .build_load(i64_type, left_ptr, "")
            .into_int_value();
        lefts.push(left);
        let right_ptr = unsafe {
            bin.builder
                .build_gep(i64_type, r, &[i64_type.const_int(i, false)], "")
        };
        let right = bin
            .builder
            .build_load(i64_type, right_ptr, "")
            .into_int_value();
        rights.push(right);
    }
    let mul_with_carry = bin
        .builder
        .build_int_mul(lefts[7], rights[7], "mul_with_carry");

    let field_high = bin.build_alloca(func_value, bin.context.i64_type(), "field_high");
    let field_low = bin.build_alloca(func_value, bin.context.i64_type(), "field_low");

    bin.builder.build_call(
        bin.module.get_function("split_field").unwrap(),
        &[mul_with_carry.into(), field_high.into(), field_low.into()],
        "",
    );

    let _field_high = bin
        .builder
        .build_load(bin.context.i64_type(), field_high, "")
        .into_int_value();

    let field_low = bin
        .builder
        .build_load(bin.context.i64_type(), field_low, "")
        .into_int_value();

    let result_ret_ptr = unsafe {
        bin.builder
            .build_gep(i64_type, result_ret, &[i64_type.const_int(7, false)], "")
    };
    bin.builder.build_store(result_ret_ptr, field_low);

    bin.builder.build_return(Some(&result_ret));
}