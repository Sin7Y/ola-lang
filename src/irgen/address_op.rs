use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::{Expression, Namespace};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::IntPredicate;

use super::functions::Vartable;

pub fn address_compare<'a>(
    l: &Expression,
    r: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
    op: IntPredicate,
) -> BasicValueEnum<'a> {
    let left = expression(l, bin, func_value, var_table, ns).into_array_value();
    let right = expression(r, bin, func_value, var_table, ns).into_array_value();

    let mut result = bin.context.bool_type().const_int(1, false);

    // Compare each pair of elements
    for i in 0..4 {
        let left_elem = bin
            .builder
            .build_extract_value(left, i, &format!("left_elem_{}", i))
            .unwrap()
            .into_int_value();
        let right_elem = bin
            .builder
            .build_extract_value(right, i, &format!("right_elem_{}", i))
            .unwrap()
            .into_int_value();

        let compare =
            bin.builder
                .build_int_compare(op, left_elem, right_elem, &format!("compare_{}", i));

        result = bin
            .builder
            .build_and(result, compare, &format!("result_{}", i));
    }
    result.into()
}
