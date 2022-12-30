use super::func::FunctionInfo;
use std::fs::File;
use std::io::{Result, Write};

/// Assembly builder.
pub struct AsmBuilder<'f> {
    f: &'f mut File,
    temp: &'static str,
}

impl<'f> AsmBuilder<'f> {
    /// Creates a new assembly builder.
    pub fn new(f: &'f mut File, temp: &'static str) -> Self {
        Self { f, temp }
    }

    pub fn loadi(&mut self, dest: &str, imm: u32) -> Result<()> {
        writeln!(self.f, "  mload {dest}, {imm}")
    }

    pub fn loada(&mut self, dest: &str, symbol: &str) -> Result<()> {
        writeln!(self.f, "  mload {dest}, {symbol}")
    }

    pub fn stri(&mut self, dest: &str, imm: u32) -> Result<()> {
        writeln!(self.f, "  mstore {dest}, {imm}")
    }

    pub fn stra(&mut self, dest: &str, symbol: &str) -> Result<()> {
        writeln!(self.f, "  mstore {dest}, {symbol}")
    }

    pub fn mov(&mut self, dest: &str, src: &str) -> Result<()> {
        if dest != src {
            writeln!(self.f, "  mov {dest}, {src}")
        } else {
            Ok(())
        }
    }

    pub fn op2(&mut self, op: &str, dest: &str, lhs: &str, rhs: &str) -> Result<()> {
        writeln!(self.f, "  {op} {dest}, {lhs}, {rhs}")
    }

    pub fn op1(&mut self, op: &str, dest: &str, src: &str) -> Result<()> {
        writeln!(self.f, "  {op} {dest}, {src}")
    }

    pub fn jmp(&mut self, label: &str) -> Result<()> {
        writeln!(self.f, "  jmp {label}")
    }

    pub fn call(&mut self, func: &str) -> Result<()> {
        writeln!(self.f, "  call {func}")
    }

    pub fn prologue(&mut self, func_name: &str, info: &FunctionInfo) -> Result<()> {
        // declaration
        writeln!(self.f, "  .text")?;
        writeln!(self.f, "  .globl {}", &func_name[1..])?;
        writeln!(self.f, "{}:", &func_name[1..])?;
        // ldr/str todo
        Ok(())
    }

    pub fn epilogue(&mut self, info: &FunctionInfo) -> Result<()> {
        // ldr/str todo
        writeln!(self.f, "  ret")
    }
}
