use super::builder::AsmBuilder;
use super::func::Slot;
use std::fs::File;
use std::io::Result;

/// A global/local value.
pub enum AsmValue<'i> {
    Global(&'i str),
    Local(Slot),
    Const(u32),
    Arg(usize),
    Void,
}

/// Returns the assembly value of the given value data.
macro_rules! asm_value {
    ($info:expr, $v:expr) => {
        AsmValue::from(cur_func!($info).slot_offset($v))
    };
}
pub(crate) use asm_value;

impl<'i> AsmValue<'i> {
    /// Returns `true` if the value is a pointer.
    pub fn is_ptr(&self) -> bool {
        matches!(self, Self::Local(slot) if slot.is_ptr)
    }

    /// Writes the assembly value to the given register.
    pub fn write_to(&self, f: &mut File, reg: &'static str) -> Result<()> {
        let mut builder = AsmBuilder::new(f, reg);
        match self {
            Self::Global(symbol) => builder.loada(reg, symbol),
            Self::Local(slot) => Ok(()),
            Self::Const(num) => builder.loadi(reg, *num),
            _ => unreachable!(),
        }
    }

    /// Writes the address of assembly value to the give register.
    pub fn write_addr_to(&self, f: &mut File, reg: &'static str) -> Result<()> {
        let mut builder = AsmBuilder::new(f, reg);
        match self {
            Self::Global(symbol) => builder.loada(reg, symbol),
            Self::Local(slot) => Ok(()),
            _ => unreachable!(),
        }
    }

    /// Writes the assembly value (argument) to the given register.
    pub fn write_arg_to(&self, f: &mut File, reg: &'static str, sp_offset: usize) -> Result<()> {
        Ok(())
    }

    /// Reads the value of the given register to the assembly value.
    pub fn read_from(&self, f: &mut File, reg: &'static str, temp: &'static str) -> Result<()> {
        let mut builder = AsmBuilder::new(f, temp);
        match self {
            Self::Global(symbol) => builder.loada(temp, symbol),
            Self::Local(slot) => Ok(()),
            Self::Const(_) => unreachable!(),
            Self::Arg(index) => Ok(()),
            Self::Void => Ok(()),
        }
    }
}

impl<'i> From<LocalValue> for AsmValue<'i> {
    fn from(v: LocalValue) -> Self {
        match v {
            LocalValue::Local(slot) => Self::Local(slot),
            LocalValue::Const(num) => Self::Const(num),
        }
    }
}

impl<'i> From<Option<Slot>> for AsmValue<'i> {
    fn from(v: Option<Slot>) -> Self {
        match v {
            Some(slot) => Self::Local(slot),
            None => Self::Void,
        }
    }
}

/// A local value (simplified version of assembly value).
pub enum LocalValue {
    Local(Slot),
    Const(u32),
}

impl<'i> From<AsmValue<'i>> for LocalValue {
    fn from(value: AsmValue) -> Self {
        match value {
            AsmValue::Local(slot) => Self::Local(slot),
            AsmValue::Const(num) => Self::Const(num),
            _ => unreachable!(),
        }
    }
}
