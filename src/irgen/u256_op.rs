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

pub fn define_u256_add<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>) {
    let i64_type = bin.context.i64_type();

    let u32_max = bin.context.i64_type().const_int(u32::MAX as u64, false);

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

        // We should ensure that the highest bit does not overflow during the last
        // calculation.
        if i == 7 {
            bin.range_check(sum_with_carry);
        }

        let result = bin.builder.build_and(sum_with_carry, u32_max, "result");
        carry = bin
            .builder
            .build_int_compare(IntPredicate::UGT, sum_with_carry, u32_max, "carry");

        carry = bin
            .builder
            .build_int_z_extend(carry, bin.context.i64_type(), "")
            .into();

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

pub fn define_u256_sub<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>) {}
