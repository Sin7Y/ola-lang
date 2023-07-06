use super::{get_operand_for_val, get_vreg_for_val, new_empty_inst_output};
use crate::codegen::core::ir::{
    function::instruction::{InstructionId, Opcode as IrOpcode},
    types::Type,
    value::ValueId,
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        register::GR,
        Ola,
    },
    lower::{LoweringContext, LoweringError},
};
use anyhow::Result;

pub fn lower_bin(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    op: IrOpcode,
    ty: Type,
    args: &[ValueId],
) -> Result<()> {
    let lhs = get_vreg_for_val(ctx, ty, args[0])?;
    let rhs = get_operand_for_val(ctx, ty, args[1])?;
    let output = new_empty_inst_output(ctx, ty, id);

    let insert_not = |ctx: &mut LoweringContext<Ola>| {
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::NOT,
                operands: vec![
                    MO::output(OperandData::Reg(GR::R7.into())),
                    MO::input(rhs.clone().into()),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ))
    };

    let insert_add = |ctx: &mut LoweringContext<Ola>| {
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::ADDri,
                operands: vec![
                    MO::output(OperandData::Reg(GR::R7.into())),
                    MO::input(OperandData::Reg(GR::R7.into())),
                    MO::input(OperandData::Int64(1)),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ))
    };

    let data = match rhs {
        OperandData::Int64(rhs) => {
            if IrOpcode::Sub == op {
                insert_not(ctx);
                insert_add(ctx);
            }
            match op {
                IrOpcode::Sub => InstructionData {
                    opcode: Opcode::ADDri,
                    operands: vec![
                        MO::input_output(output[0].into()),
                        MO::input(lhs.into()),
                        MO::input(OperandData::Reg(GR::R7.into())),
                    ],
                },
                IrOpcode::Add => InstructionData {
                    opcode: Opcode::ADDri,
                    operands: vec![
                        MO::input_output(output[0].into()),
                        MO::input(lhs.into()),
                        MO::input(rhs.into()),
                    ],
                },
                IrOpcode::Mul => InstructionData {
                    opcode: Opcode::MULri,
                    operands: vec![
                        MO::input_output(output[0].into()),
                        MO::input(lhs.into()),
                        MO::input(rhs.into()),
                    ],
                },
                op => {
                    return Err(LoweringError::Todo(format!("Unsupported opcode: {:?}", op)).into())
                }
            }
        }
        OperandData::VReg(rhs) => {
            if IrOpcode::Sub == op {
                insert_not(ctx);
                insert_add(ctx);
            }
            match op {
                IrOpcode::Sub => InstructionData {
                    opcode: Opcode::ADDrr,
                    operands: vec![
                        MO::input_output(output[0].into()),
                        MO::input(lhs.into()),
                        MO::input(OperandData::Reg(GR::R7.into())),
                    ],
                },
                IrOpcode::Add => InstructionData {
                    opcode: Opcode::ADDrr,
                    operands: vec![
                        MO::input_output(output[0].into()),
                        MO::input(lhs.into()),
                        MO::input(rhs.into()),
                    ],
                },
                IrOpcode::Mul => InstructionData {
                    opcode: Opcode::MULrr,
                    operands: vec![
                        MO::input_output(output[0].into()),
                        MO::input(lhs.into()),
                        MO::input(rhs.into()),
                    ],
                },
                op => {
                    return Err(LoweringError::Todo(format!("Unsupported opcode: {:?}", op)).into())
                }
            }
        }
        e => return Err(LoweringError::Todo(format!("Unsupported operand: {:?}", e)).into()),
    };

    ctx.inst_seq
        .push(MachInstruction::new(data, ctx.block_map[&ctx.cur_block]));

    Ok(())
}

pub fn lower_itp(
    ctx: &mut LoweringContext<Ola>,
    self_id: InstructionId,
    tys: &[Type; 2],
    arg: ValueId,
) -> Result<()> {
    let from = tys[0];
    let to = tys[1];

    let val = get_operand_for_val(ctx, from, arg)?;
    let output = new_empty_inst_output(ctx, to, self_id);

    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::MOVrr,
            operands: vec![MO::output(output[0].into()), MO::input(val.into())],
        },
        ctx.block_map[&ctx.cur_block],
    ));

    Ok(())
}
