mod gen;

use crate::ir::program::Program;
use ola_parser::program::SourceUnit;

use gen::GenerateProgram;

/// Result type of IR generator.
pub type Result<T> = std::result::Result<T, Error>;

/// Error returned by IR generator.
pub enum Error {
    DuplicatedDef,
    SymbolNotFound,
}

/// Generates IR program for the given compile unit (ASTs).
pub fn generate_program(src_unit: &SourceUnit) -> Result<Program> {
    let mut program = Program::new();
    src_unit.generate(&mut program)?;
    Ok(program)
}
