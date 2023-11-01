use crate::irgen::binary::Binary;
use crate::irgen::expression::expression;
use crate::sema::ast::{Expression, Namespace};
use inkwell::values::{BasicValueEnum, FunctionValue};
use inkwell::IntPredicate;

use super::functions::Vartable;

pub fn hash_compare<'a>(
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
    match op {
        IntPredicate::EQ  | IntPredicate::UGT | IntPredicate::UGE => {
            bin.memcmp(left, right, bin.context.i64_type().const_int(4, false), op).into()
        }
        IntPredicate::NE => {
            let result = bin.memcmp(left, right, bin.context.i64_type().const_int(4, false), IntPredicate::EQ);
            bin.builder.build_int_compare(IntPredicate::EQ, result, bin.context.i64_type().const_zero(), "").into()
        }
        IntPredicate::ULT =>  {
            bin.memcmp(right, left, bin.context.i64_type().const_int(4, false), IntPredicate::UGT).into()
        }  
        ,
        IntPredicate::ULE => bin.memcmp(right, left, bin.context.i64_type().const_int(4, false), IntPredicate::UGE).into(),
        _ => unreachable!()

    }
}
