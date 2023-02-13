use crate::codegen::{
    function::{Function, instruction::TargetInst},
    isa::ola::{
        instruction::{Opcode, Operand, OperandData},
        register::reg_to_str,
        Ola,
    },
    register::Reg,
    module::{DisplayAsm, Module},
};
use std::{fmt, str};

impl fmt::Display for DisplayAsm<'_, Ola> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        print(f, self.0)
    }
}

pub fn print(f: &mut fmt::Formatter<'_>, module: &Module<Ola>) -> fmt::Result {
    // writeln!(f, "  .text")?;
    // writeln!(f, "  .ola_syntax noprefix")?;

    for (i, (_, func)) in module.functions.iter().enumerate() {
        print_function(f, func, i)?
    }

    Ok(())
}

pub fn print_function(
    f: &mut fmt::Formatter<'_>,
    function: &Function<Ola>,
    fn_idx: usize,
) -> fmt::Result {
    if function.is_declaration {
        return Ok(());
    }

    /*
    if let Some(name) = &function.ir.section {
        writeln!(f, "  .section {}", name)?;
    } else {
        writeln!(f, "  .text")?;
    }
    if !function.ir.linkage.is_internal() {
        writeln!(f, "  .globl {}", function.ir.name())?;
    }
    */
    let mut main_call = false;
    writeln!(f, "{}:", function.ir.name())?;

    for block in function.layout.block_iter() {
        writeln!(f, ".LBL{}_{}:", fn_idx, block.index())?;
        for inst in function.layout.inst_iter(block) {
            let inst = function.data.inst_ref(inst);
            if Opcode::MSTOREr == inst.data.opcode {
                if matches!(&inst.data.operands[0].data, OperandData::Reg(Reg(0,8))) && 
                    matches!(&inst.data.operands[1].data, OperandData::Reg(Reg(0,8))) {
                        write!(f, "  mstore [r8,-2] r8")?;
                        writeln!(f)?;
                        continue;
                }
            }
            if inst.data.is_call() {
                main_call = true;
            }
            if function.ir.name() == "main" && main_call && Opcode::RET == inst.data.opcode {  
                write!(f, "  end ")?;                              
            } else {
                write!(f, "  {} ", inst.data.opcode)?;
            }
            let mut i = 0;
            while i < inst.data.operands.len() {
                let operand = &inst.data.operands[i];
                if operand.implicit {
                    i += 1;
                    continue;
                }
                if matches!(operand.data, OperandData::MemStart) {
                    i += 1;
                    let sz = mem_size(&inst.data.opcode);
                    write!(f, "{}", sz)?;
                    if !sz.is_empty() {
                        write!(f, " ")?;
                    }
                    write!(f, "{}", mem_op(&inst.data.operands[i..i + 6]))?;
                    i += 6 - 1;
                } else {
                    write_operand(f, &operand.data, fn_idx)?;
                }
                if i < inst.data.operands.len() - 1 {
                    write!(f, " ")?
                }
                i += 1;
            }
            writeln!(f)?;
        }
    }

    Ok(())
}

impl fmt::Display for Opcode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Self::ADDri | Self::ADDrr => "add",
                Self::MULri | Self::MULrr => "mul",
                Self::MOVri | Self::MOVrr => "mov",
                Self::JMPi | Self::JMPr => "jmp",
                Self::CJMPi | Self::CJMPr => "cjmp",
                Self::CALL => "call",
                Self::RET => "ret",
                Self::Phi => "PHI",
                Self::MLOADi | Self::MLOADr => "mload",
                Self::MSTOREi | Self::MSTOREr => "mstore",
                Self::NOT => "not",
                Self::GTE => "gte",
                Self::NEQ => "neq",
                Self::EQri | Self::EQrr => "eq",
                e => todo!("{:?}", e),
            }
        )
    }
}

fn write_operand(f: &mut fmt::Formatter<'_>, op: &OperandData, fn_idx: usize) -> fmt::Result {
    match op {
        OperandData::Reg(r) => write!(f, "{}", reg_to_str(r)),
        OperandData::VReg(r) => write!(f, "%{}", r.0),
        OperandData::Slot(slot) => write!(f, "{:?}", slot),
        OperandData::Int8(i) => write!(f, "{}", i),
        OperandData::Int32(i) => write!(f, "{}", i),
        OperandData::Int64(i) => write!(f, "{}", i),
        OperandData::Block(block) => write!(f, ".LBL{}_{}", fn_idx, block.index()),
        OperandData::Label(name) => write!(f, "{}", name),
        OperandData::MemStart => Ok(()),
        OperandData::GlobalAddress(name) => write!(f, "offset {}", name),
        OperandData::None => write!(f, "none"),
    }
}

fn mem_size(_opcode: &Opcode) -> &'static str {
    ""
}

fn mem_op(args: &[Operand]) -> String {
    // return  format!("[{}]", "abc");
    assert!(matches!(&args[1].data, &OperandData::None)); // assure slot is eliminated
    match (
        &args[0].data,
        &args[2].data,
        &args[3].data,
        &args[4].data,
        &args[5].data,
    ) {
        (
            OperandData::Label(name),
            OperandData::None,
            OperandData::None,
            OperandData::None,
            OperandData::None,
        ) => {
            format!("[{}]", name)
        }
        (
            OperandData::None,
            OperandData::Int32(imm),
            OperandData::Reg(reg),
            OperandData::None,
            OperandData::None,
        ) => {
            format!(
                "[{},{}{}]",
                reg_to_str(reg),
                if *imm < 0 { "" } else { "+" },
                *imm
            )
        }
        (
            OperandData::None,
            OperandData::Int32(imm),
            OperandData::Reg(reg1),
            OperandData::Reg(reg2),
            OperandData::Int32(shift),
        ) => {
            format!(
                "[{}{}{}+{}*{}]",
                reg_to_str(reg1),
                if *imm < 0 { "" } else { "+" },
                *imm,
                reg_to_str(reg2),
                shift
            )
        }
        (
            OperandData::None,
            OperandData::None,
            OperandData::Reg(reg1),
            OperandData::None,
            OperandData::None,
        ) => {
            format!("[{}]", reg_to_str(reg1),)
        }
        (
            OperandData::None,
            OperandData::None,
            OperandData::Reg(reg1),
            OperandData::Reg(reg2),
            OperandData::Int32(mul),
        ) => {
            format!("[{}+{}*{}]", reg_to_str(reg1), reg_to_str(reg2), mul)
        }
        (
            OperandData::Label(lbl),
            OperandData::None,
            OperandData::Reg(reg1),
            OperandData::None,
            OperandData::None,
        ) => {
            format!("[{} + {lbl}]", reg_to_str(reg1))
        }
        e => todo!("{:?}", e),
    }
}
