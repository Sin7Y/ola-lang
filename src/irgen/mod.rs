// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::{Contract, Function, Namespace, Parameter, Type};
use std::str;

use inkwell::values::{
    ArrayValue, BasicMetadataValueEnum, BasicValueEnum, FunctionValue, IntValue, PointerValue,
};

pub mod binary;
mod expression;
mod functions;
mod statements;
use crate::sema::ast;

#[derive(Clone)]
pub struct Variable<'a> {
    value: BasicValueEnum<'a>,
}

impl ast::Contract {
    /// Generate the binary. This can be used to generate llvm text, object file
    /// or final linked binary.
    pub fn binary<'a>(
        &'a self,
        ns: &'a ast::Namespace,
        context: &'a inkwell::context::Context,
        filename: &'a str,
    ) -> binary::Binary {
        binary::Binary::build(context, self, ns, filename)
    }
}
