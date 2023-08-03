use super::{get_operand_for_val, new_empty_inst_output};
use crate::codegen::core::ir::{
    function::basic_block::BasicBlockId, function::instruction::InstructionId, types::Type,
    value::ValueId,
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        Ola,
    },
    lower::LoweringContext,
};
use anyhow::Result;

pub fn lower_phi(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    ty: Type,
    args: &[ValueId],
    blocks: &[BasicBlockId],
) -> Result<()> {
    let output = new_empty_inst_output(ctx, ty, id);
    let mut operands = vec![MO::output(output[0].into())];
    for (arg, block) in args.iter().zip(blocks.iter()) {
        operands.push(MO::input(get_operand_for_val(ctx, ty, *arg)?));
        operands.push(MO::new(OperandData::Block(ctx.block_map[block])))
    }
    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::Phi,
            operands,
        },
        ctx.block_map[&ctx.cur_block],
    ));
    Ok(())
}
