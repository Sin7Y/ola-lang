mod gen;

use crate::ir::program::Program;

use gen::GenerateToAsm;

use std::fs::File;
use std::io::Result;

/// Generates the given IR program to ola assembly.
pub fn generate_asm(program: &Program, path: &str) -> Result<()> {
    program.generate(&mut File::create(path)?, program)
}
