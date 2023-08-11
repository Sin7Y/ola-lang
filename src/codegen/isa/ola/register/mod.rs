use crate::codegen::core::ir::types::{self, Type, Types};
use crate::codegen::{
    call_conv::CallConvKind,
    register::{Reg, RegUnit, RegisterClass, RegisterInfo},
};
use std::fmt;

pub struct RegInfo;

pub enum GR {
    R0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    R8,
    R9,
}

pub enum RegClass {
    GR,
}

impl From<GR> for Reg {
    fn from(r: GR) -> Self {
        Reg(RegClass::GR as u16, r as u16)
    }
}

impl From<GR> for RegUnit {
    fn from(r: GR) -> Self {
        RegUnit(RegClass::GR as u16, r as u16)
    }
}

const ARG_REGS: [RegUnit; 3] = [
    RegUnit(RegClass::GR as u16, GR::R1 as u16),
    RegUnit(RegClass::GR as u16, GR::R2 as u16),
    RegUnit(RegClass::GR as u16, GR::R3 as u16),
];

const STR_ARG_REGS: [RegUnit; 8] = [
    RegUnit(RegClass::GR as u16, GR::R1 as u16),
    RegUnit(RegClass::GR as u16, GR::R2 as u16),
    RegUnit(RegClass::GR as u16, GR::R3 as u16),
    RegUnit(RegClass::GR as u16, GR::R4 as u16),
    RegUnit(RegClass::GR as u16, GR::R5 as u16),
    RegUnit(RegClass::GR as u16, GR::R6 as u16),
    RegUnit(RegClass::GR as u16, GR::R7 as u16),
    RegUnit(RegClass::GR as u16, GR::R8 as u16),
];

const CSR: [RegUnit; 5] = [
    RegUnit(RegClass::GR as u16, GR::R4 as u16),
    RegUnit(RegClass::GR as u16, GR::R5 as u16),
    RegUnit(RegClass::GR as u16, GR::R6 as u16),
    RegUnit(RegClass::GR as u16, GR::R7 as u16),
    RegUnit(RegClass::GR as u16, GR::R8 as u16),
];

impl RegisterInfo for RegInfo {
    fn arg_reg_list(cc: &CallConvKind) -> &'static [RegUnit] {
        match cc {
            CallConvKind::SystemV => &ARG_REGS,
            CallConvKind::AAPCS64 => &[],
        }
    }

    fn str_arg_reg_list(cc: &CallConvKind) -> &'static [RegUnit] {
        match cc {
            CallConvKind::SystemV => &STR_ARG_REGS,
            CallConvKind::AAPCS64 => &[],
        }
    }

    fn to_reg_unit(r: Reg) -> RegUnit {
        match r {
            Reg(/* GR */ 0, x) => RegUnit(RegClass::GR as u16, x),
            _ => panic!(),
        }
    }

    fn is_csr(r: RegUnit) -> bool {
        CSR.contains(&r)
    }
}

impl RegisterClass for RegClass {
    fn for_type(types: &Types, ty: Type) -> Self {
        match ty {
            types::VOID | types::I1 | types::I8 | types::I16 | types::I32 | types::I64 => {
                RegClass::GR
            }
            _ if ty.is_pointer(types) => RegClass::GR,
            _ if ty.is_array(types) => RegClass::GR,
            e => todo!("{}", types.to_string(e)),
        }
    }

    fn gpr_list(&self) -> Vec<Reg> {
        match self {
            RegClass::GR => vec![GR::R8, GR::R7, GR::R6, GR::R5]
                .into_iter()
                .map(|r| r.into())
                .collect(),
        }
    }

    fn csr_list(&self) -> Vec<Reg> {
        match self {
            RegClass::GR => vec![GR::R1, GR::R2, GR::R3, GR::R4, GR::R0]
                .into_iter()
                .map(|r| r.into())
                .collect(),
        }
    }

    fn apply_for(&self, ru: RegUnit) -> Reg {
        match self {
            Self::GR => Reg(RegClass::GR as u16, ru.1),
        }
    }
}

pub fn to_reg_unit(r: Reg) -> RegUnit {
    match r {
        Reg(/* GR */ 0, x) => RegUnit(0, x),
        _ => panic!(),
    }
}

impl fmt::Debug for GR {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Self::R0 => "r0",
                Self::R1 => "r1",
                Self::R2 => "r2",
                Self::R3 => "r3",
                Self::R4 => "r4",
                Self::R5 => "r5",
                Self::R6 => "r6",
                Self::R7 => "r7",
                Self::R8 => "r8",
                Self::R9 => "r9",
            }
        )
    }
}

impl fmt::Display for GR {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

pub fn reg_to_str(r: &Reg) -> &'static str {
    let gr = ["r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9"];
    match r {
        Reg(0, i) => gr[*i as usize],
        e => todo!("{:?}", e),
    }
}
