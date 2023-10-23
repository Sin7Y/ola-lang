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
    let left = expression(l, bin, func_value, var_table, ns);
    let right = expression(r, bin, func_value, var_table, ns);

    let mut result = bin.context.i64_type().const_int(1, false);

    // Compare each pair of elements
    for i in 0..4 {
        let left_elem_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                left.into_pointer_value(),
                &[bin.context.i64_type().const_int(i, false)],
                &format!("left_elem_{}", i),
            )
        };
        let left_elem = bin
            .builder
            .build_load(bin.context.i64_type(), left_elem_ptr, "")
            .into_int_value();

        let right_elem_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                right.into_pointer_value(),
                &[bin.context.i64_type().const_int(i, false)],
                &format!("right_elem_{}", i),
            )
        };
        let right_elem = bin
            .builder
            .build_load(bin.context.i64_type(), right_elem_ptr, "")
            .into_int_value();

        let compare =
            bin.builder
                .build_int_compare(op, left_elem, right_elem, &format!("compare_{}", i));

        let compare = bin
            .builder
            .build_int_z_extend(compare, bin.context.i64_type(), "")
            .into();

        result = bin
            .builder
            .build_and(compare, result, &format!("result_{}", i));
    }
    result.into()
}
