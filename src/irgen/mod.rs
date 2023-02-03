use std::str;

pub mod binary;
mod expression;
mod functions;
mod statements;
use crate::sema::ast;

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
