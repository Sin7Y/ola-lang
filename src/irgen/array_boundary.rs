// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::Type::Uint;
use crate::sema::ast::{Expression, Namespace};

use super::{binary::Binary, functions::FunctionContext};

pub(crate) fn handle_array_assign<'a>(
    right: &Expression,
    bin: &Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    pos: usize,
    ns: &Namespace,
) {
    if let Expression::AllocDynamicArray { .. } = right {
        let alloca = bin.build_alloca(
            func_context.func_val,
            bin.llvm_var_ty(&Uint(32), ns),
            "array_length",
        );
        func_context.array_lengths_vars.insert(pos, alloca.into());
    } else if let Expression::Variable(_, _, right_res) = &right {
        // If we have initialized a temp var for this var
        if func_context.array_lengths_vars.contains_key(right_res) {
            let to_update = func_context.array_lengths_vars[right_res];
            func_context.array_lengths_vars.insert(pos, to_update);
        } else {
            // If the right hand side doesn't have a temp, it must be a function parameter
            // or a struct member.
            func_context.array_lengths_vars.remove(&pos);
        }
    }
}
