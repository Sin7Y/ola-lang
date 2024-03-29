use crate::codegen::core::ir::types::{Type, Typed};

use super::Instruction;

impl Typed for Instruction {
    fn ty(&self) -> Type {
        self.ty
    }
}
