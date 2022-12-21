use super::Result;
use crate::ir::program::Program;
use ola_parser::program::SourceUnit;
/// Trait for generating IR program.
pub trait GenerateProgram<'ast> {
    type Out;

    fn generate(&'ast self, program: &mut Program) -> Result<Self::Out>;
}

impl<'ast> GenerateProgram<'ast> for SourceUnit {
    type Out = ();

    fn generate(&'ast self, program: &mut Program) -> Result<Self::Out> {
        Ok(())
    }
}
