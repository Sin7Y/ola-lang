// SPDX-License-Identifier: Apache-2.0

use inkwell::values::{FunctionValue, IntValue, PointerValue};

use crate::sema::ast::{Expression, Namespace, StringLocation};

use super::{binary::Binary, expression::expression, functions::Vartable};

/// Load a string from expression or create global
pub(super) fn string_location<'a>(
    bin: &Binary<'a>,
    location: &StringLocation<Expression>,
    var_table: &mut Vartable<'a>,
    function: FunctionValue<'a>,
    ns: &Namespace,
) -> (PointerValue<'a>, IntValue<'a>) {
    match location {
        StringLocation::CompileTime(..) => unimplemented!("compile time string"),
        StringLocation::RunTime(e) => {
            let v = expression(e, bin, function, var_table, ns);

            (bin.vector_data(v), bin.vector_len(v))
        }
    }
}
