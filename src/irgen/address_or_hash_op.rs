use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::{Expression, Namespace, Type};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::IntPredicate;

use super::functions::Vartable;

pub fn address_or_hash_compare<'a>(
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
        bin.context.i64_type().const_int(4, false),
        op,
        &Type::Field,
    )
    .into()
}
