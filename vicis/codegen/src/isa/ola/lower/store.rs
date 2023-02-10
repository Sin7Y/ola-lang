use super::get_inst_output;
use crate::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MOperand, OperandData},
        Ola,
    },
    lower::{LoweringContext, LoweringError},
};
use anyhow::Result;
use vicis_core::ir::{
    types::Type,
    value::{ConstantInt, ConstantValue, Value, ValueId},
};

pub fn lower_store(
    ctx: &mut LoweringContext<Ola>,
    tys: &[Type],
    args: &[ValueId],
    _align: u32,
) -> Result<()> {
    let mut dst_slot = None;
    let mut dst_vreg = None;

    let dst = args[1];
    match ctx.ir_data.value_ref(dst) {
        Value::Instruction(id) => {
            // Maybe Alloca
            if let Some(slot_id) = ctx.inst_id_to_slot_id.get(id) {
                dst_slot = Some(*slot_id);
            } else {
                dst_vreg = Some(get_inst_output(ctx, tys[1], *id)?);
            }
        }
        _ => {
            return Err(
                LoweringError::Todo("Store dest must be an instruction result".into()).into(),
            )
        }
    }

    let mut konst = None;
    let mut vreg = None;

    let src = args[0];
    match ctx.ir_data.value_ref(src) {
        Value::Constant(c) => konst = Some(c),
        Value::Instruction(id) => vreg = Some(get_inst_output(ctx, tys[0], *id)?),
        Value::Argument(a) => vreg = ctx.arg_idx_to_vreg.get(&a.nth).copied(),
        e => return Err(LoweringError::Todo(format!("Unsupported store source: {:?}", e)).into()),
    }

    match (dst_vreg, dst_slot, vreg, konst) {
        (None, Some(slot), Some(vreg), None) => {
            ctx.inst_seq.append(&mut vec![MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MSTOREr,
                    operands: vec![
                        MOperand::new(OperandData::MemStart),
                        MOperand::new(OperandData::None),
                        MOperand::new(OperandData::Slot(slot)),
                        MOperand::new(OperandData::None),
                        MOperand::input(OperandData::None),
                        MOperand::input(OperandData::None),
                        MOperand::new(OperandData::None),
                        MOperand::input(vreg.into()),
                    ],
                },
                ctx.block_map[&ctx.cur_block],
            )]);
            Ok(())
        }
        (Some(dst), None, Some(vreg), None) => {
            ctx.inst_seq.append(&mut vec![MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MSTOREr,
                    operands: vec![
                        MOperand::new(OperandData::MemStart),
                        MOperand::new(OperandData::None),
                        MOperand::new(OperandData::None),
                        MOperand::new(OperandData::None),
                        MOperand::input(dst.into()),
                        MOperand::input(OperandData::None),
                        MOperand::new(OperandData::None),
                        MOperand::input(vreg.into()),
                    ],
                },
                ctx.block_map[&ctx.cur_block],
            )]);
            Ok(())
        }
        (None, Some(slot), None, Some(konst)) => {
            ctx.inst_seq.append(&mut vec![MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MSTOREi,
                    operands: vec![
                        MOperand::new(OperandData::MemStart),
                        MOperand::new(OperandData::None),
                        MOperand::new(OperandData::Slot(slot)),
                        MOperand::new(OperandData::None),
                        MOperand::input(OperandData::None),
                        MOperand::input(OperandData::None),
                        MOperand::new(OperandData::None),
                        MOperand::input(match konst {
                            ConstantValue::Int(ConstantInt::Int8(i)) => i.into(),
                            ConstantValue::Int(ConstantInt::Int32(i)) => i.into(),
                            ConstantValue::Null(_) => 0i64.into(),
                            _ => panic!(),
                        }),
                    ],
                },
                ctx.block_map[&ctx.cur_block],
            )]);
            Ok(())
        }
        e => Err(LoweringError::Todo(format!("Unsupported store dest pattern: {:?}", e)).into()),
    }
}