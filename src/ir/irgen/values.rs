use super::scopes::{cur_func, Scopes};
use super::{Error, Result};
use crate::ir::builder_traits::*;
use crate::ir::Value as IrValue;
use crate::ir::{Program, Type, TypeKind};
/// use crate::sema::ast::Type::Field;
use std::iter::repeat_with;

/// A value.
pub enum Value {
  /// Koopa IR value.
  Value(IrValue),
  /// Constant integer.
  Const(i32),
}

/// An expression value.
pub enum ExpValue {
  /// An `void`.
  Void,
  /// An integer.
  Int(IrValue),
  /// An integer pointer.
  IntPtr(IrValue),
  /// An array pointer (part of array).
  ArrPtr(IrValue),
}

impl ExpValue {
  /// Converts the value into a right value.
  pub fn into_val(self, program: &mut Program, scopes: &Scopes) -> Result<IrValue> {
    match self {
      Self::Void => Err(Error::UseVoidValue),
      Self::Int(val) => Ok(val),
      Self::IntPtr(ptr) => {
        let info = cur_func!(scopes);
        let load = info.new_value(program).load(ptr);
        info.push_inst(program, load);
        Ok(load)
      }
      Self::ArrPtr(ptr) => Ok(ptr),
    }
  }

  /// Converts the value into a integer right value.
  pub fn into_int(self, program: &mut Program, scopes: &Scopes) -> Result<IrValue> {
    match self {
      Self::ArrPtr(_) => Err(Error::NonIntCalc),
      _ => self.into_val(program, scopes),
    }
  }

  /// Converts the value into a left-value pointer.
  pub fn into_ptr(self) -> Result<IrValue> {
    match self {
      Self::IntPtr(ptr) => Ok(ptr),
      Self::ArrPtr(_) => Err(Error::ArrayAssign),
      _ => unreachable!(),
    }
  }
}
