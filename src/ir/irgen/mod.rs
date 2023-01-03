mod func;
mod gen;
mod scopes;
mod values;

use crate::ir::program::Program;
use ola_parser::program::SourceUnit;

use crate::sema::ast::Namespace;
use gen::GenerateProgram;

/// Result type of IR generator.
pub type Result<T> = std::result::Result<T, Error>;

/// Error returned by IR generator.
pub enum Error {
    DuplicatedDef,
    SymbolNotFound,
    UseVoidValue,
    NonIntCalc,
    ArrayAssign,
}

/// Generates IR program for the given compile unit (ASTs).
pub fn generate_program(ns: &Namespace) -> Result<Program> {
    let mut program = Program::new();
    ns.generate(&mut program)?;
    Ok(program)
}
