use crate::ir::program::Program;
use ola_parser::program::SourceUnit;
use std::fs::File;
use std::io::Result;

/// Trait for generating Ola assembly.
pub trait GenerateToAsm<'p> {
    type Out;

    fn generate(&self, f: &mut File, program: &Program) -> Result<Self::Out>;
}

impl<'p> GenerateToAsm<'p> for Program {
    type Out = ();

    fn generate(&self, f: &mut File, program: &Program) -> Result<Self::Out> {
        Ok(())
    }
}
