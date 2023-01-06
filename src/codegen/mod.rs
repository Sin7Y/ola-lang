mod builder;
mod func;
mod gen;
mod info;
mod values;

use crate::ir::Program;
use gen::GenerateToAsm;
use info::ProgramInfo;
use std::fs::File;
use std::io::Result;

/// Generates the given IR program to Ola assembly.
pub fn generate_asm(program: &Program, path: &str) -> Result<()> {
    program.generate(&mut File::create(path)?, &mut ProgramInfo::new(program))
}
