use super::{get_operand_for_val, get_vreg_for_val, new_empty_inst_output};
use crate::codegen::core::ir::{
    function::{
        basic_block::BasicBlockId,
        data::Data as IrData,
        instruction::{ICmp, ICmpCond, InstructionId, Operand},
    },
    types::Type,
    value::{ConstantInt, ConstantValue, Value, ValueId},
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        Ola,
    },
    lower::{LoweringContext, LoweringError},
};
use anyhow::Result;

pub fn lower_br(ctx: &mut LoweringContext<Ola>, block: BasicBlockId) -> Result<()> {
    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::JMPr,
            operands: vec![MO::new(OperandData::Block(ctx.block_map[&block]))],
        },
        ctx.block_map[&ctx.cur_block],
    ));
    Ok(())
}

pub fn lower_condbr(
    ctx: &mut LoweringContext<Ola>,
    arg: ValueId,
    blocks: [BasicBlockId; 2],
) -> Result<()> {
    fn is_icmp<'a>(
        data: &'a IrData,
        val: &Value,
    ) -> Option<(InstructionId, &'a Type, &'a [ValueId; 2], &'a ICmpCond)> {
        match val {
            Value::Instruction(id) => {
                let inst = data.inst_ref(*id);
                match &inst.operand {
                    Operand::ICmp(ICmp { ty, args, cond }) => Some((*id, ty, args, cond)),
                    _ => None,
                }
            }
            _ => None,
        }
    }

    let arg = ctx.ir_data.value_ref(arg);

    if let Some((icmp, ty, args, cond)) = is_icmp(ctx.ir_data, arg) {
        ctx.mark_as_merged(icmp);
        let lhs = get_vreg_for_val(ctx, *ty, args[0])?;
        let rhs = ctx.ir_data.value_ref(args[1]);
        match rhs {
            Value::Constant(ConstantValue::Int(ConstantInt::Int32(rhs))) => match cond {
                ICmpCond::Eq => {
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::EQri,
                            operands: vec![MO::input(lhs.into()), MO::new(rhs.into())],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                ICmpCond::Ne => {
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::NEQ,
                            operands: vec![MO::input(lhs.into()), MO::new(rhs.into())],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                ICmpCond::Sge | ICmpCond::Uge => {
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::GTE,
                            operands: vec![MO::input(lhs.into()), MO::new(rhs.into())],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                ICmpCond::Ult => {
                    let output = new_empty_inst_output(ctx, *ty, icmp);
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::MOVri,
                            operands: vec![
                                MO::output(OperandData::VReg(output)),
                                MO::new(rhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));

                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::GTE,
                            operands: vec![
                                MO::input(OperandData::VReg(output)),
                                MO::input(lhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));

                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::NEQ,
                            operands: vec![
                                MO::input(OperandData::VReg(output)),
                                MO::input(lhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                e => {
                    return Err(
                        LoweringError::Todo(format!("Unsupported icmp condition: {:?}", e)).into(),
                    )
                }
            },
            Value::Constant(ConstantValue::Null(_)) => {
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::GTE,
                        operands: vec![MO::input(lhs.into()), MO::new(0.into())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
            Value::Argument(_) | Value::Instruction(_) => {
                assert!(ty.is_i32() || ty.is_i64());
                let rhs = get_operand_for_val(ctx, *ty, args[1])?;
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::GTE, // TODO: CMPrr64
                        operands: vec![MO::input(lhs.into()), MO::input(rhs.into())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
            e => return Err(LoweringError::Todo(format!("Unsupported operand: {:?}", e)).into()),
        }

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::CJMPr,
                operands: vec![MO::new(OperandData::Block(ctx.block_map[&blocks[0]]))],
            },
            ctx.block_map[&ctx.cur_block],
        ));

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::JMPr,
                operands: vec![MO::new(OperandData::Block(ctx.block_map[&blocks[1]]))],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    Err(LoweringError::Todo("Unsupported conditional br pattern".into()).into())
}
