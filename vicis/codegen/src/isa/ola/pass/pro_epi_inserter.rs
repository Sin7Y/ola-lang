use crate::{
    function::{instruction::Instruction, Function},
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand, OperandData},
        register::{RegClass, GR},
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
    if function.is_declaration {
        return;
    }

    let slot_size = function.slots.ensure_computed_offsets();

    let mut used_csr = function
        .data
        .used_csr
        .clone()
        .into_iter()
        .map(|r| r.apply(&RegClass::GR))
        .collect::<Vec<_>>();
    used_csr.sort();
    let num_saved_64bit_regs = 1/*8=rbp*/ + used_csr.len() as u32;

    let adj = (roundup(
        (slot_size + num_saved_64bit_regs * 1 + 1/*=call*/) as i32,
        1,
    ) - (num_saved_64bit_regs * 1 + 1) as i32) / 4;

    // insert prologue
    let entry = function.layout.first_block.unwrap();
    if adj > 0 {
        let sub = function.data.create_inst(Instruction::new(
            InstructionData {
                opcode: Opcode::ADDri,
                operands: vec![
                    Operand::input_output(GR::R8.into()),
                    Operand::input_output(GR::R8.into()),
                    Operand::input(adj.into()),
                ],
            },
            entry,
        ));
        function.layout.insert_inst_at_start(sub, entry);
    }

    // insert epilogue
    let mut epilogues = vec![];
    for block in function.layout.block_iter() {
        for inst_id in function.layout.inst_iter(block) {
            let inst = function.data.inst_ref(inst_id);
            if !matches!(inst.data.opcode, Opcode::RET) {
                continue;
            }
            epilogues.push((block, inst_id));
        }
    }
    for (block, ret_id) in epilogues {
        if adj > 0 {
            // insert: sub fp fp size
            let not_size = function.data.create_inst(Instruction::new(
                InstructionData {
                    opcode: Opcode::NOT,
                    operands: vec![
                        Operand::input_output(GR::R6.into()),
                        Operand::input(adj.into()),
                    ],
                },
                block,
            ));
            function.layout.insert_inst_before(ret_id, not_size, block);

            let add_one = function.data.create_inst(Instruction::new(
                InstructionData {
                    opcode: Opcode::ADDri,
                    operands: vec![
                        Operand::output(GR::R6.into()),
                        Operand::input_output(GR::R6.into()),
                        Operand::input(OperandData::Int64(1)),
                    ],
                },
                block,
            ));
            function.layout.insert_inst_before(ret_id, add_one, block);

            let add_fp = function.data.create_inst(Instruction::new(
                InstructionData {
                    opcode: Opcode::ADDri,
                    operands: vec![
                        Operand::output(GR::R8.into()),
                        Operand::input_output(GR::R8.into()),
                        Operand::input(GR::R6.into()),
                    ],
                },
                block,
            ));
            function.layout.insert_inst_before(ret_id, add_fp, block);
        }
    }
}

fn roundup(n: i32, align: i32) -> i32 {
    (n + align - 1) & !(align - 1)
}
