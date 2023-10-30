use crate::codegen::{
    function::Function,
    isa::ola::{
        instruction::{Opcode, OperandData},
        Ola,
    },
    module::Module,
};
use anyhow::Result;

pub fn run_on_module(module: &mut Module<Ola>) -> Result<()> {
    for (_, func) in &mut module.functions {
        run_on_function(func);
    }
    Ok(())
}

pub fn run_on_function(function: &mut Function<Ola>) {
    let mut dead_list = vec![];
    let mut replace_list = vec![];

    for block_id in function.layout.block_iter() {
        for inst_id in function.layout.inst_iter(block_id) {
            let inst = function.data.inst_ref(inst_id);
            match inst.data.opcode {
                Opcode::ADDrr | Opcode::ADDri => {
                    let imm = if let Some(imm_op) = inst.data.operands[2].data.sext_as_i64() {
                        imm_op
                    } else {
                        1 as i64
                    };
                    if imm == 0 {
                        match &inst.data.operands[1].data {
                            OperandData::Int32(_) | OperandData::Int64(_) => {
                                replace_list.push(inst_id)
                            }
                            OperandData::Reg(reg) => {
                                if reg == inst.data.operands[0].data.as_reg() {
                                    dead_list.push(inst_id)
                                }
                            }
                            OperandData::VReg(reg) => {
                                if reg == inst.data.operands[0].data.as_vreg() {
                                    dead_list.push(inst_id)
                                }
                            }
                            _ => todo!(),
                        }
                    }
                }
                _ => {}
            }
        }
    }

    // remove inst for pattern "add reg reg 0"
    for inst_id in dead_list {
        function.remove_inst(inst_id);
    }
    // repalce inst for pattern "add reg imm 0" into "mov reg imm"
    for inst_id in replace_list {
        let inst = function.data.inst_ref_mut(inst_id);
        inst.data.opcode = Opcode::MOVri;
        inst.data.operands.pop();
    }
}
