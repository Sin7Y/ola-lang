use super::{get_inst_output, new_empty_inst_output};
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
    function::instruction::InstructionId,
    types::Type,
    value::{ConstantValue, Value, ValueId},
};

pub fn lower_load(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    tys: &[Type],
    addr: ValueId,
    _align: u32,
) -> Result<()> {
    let mut slot = None;
    let mut vreg = None;
    let mut gbl = None;

    match &ctx.ir_data.values[addr] {
        Value::Instruction(addr_id) => {
            if let Some(slot_id) = ctx.inst_id_to_slot_id.get(addr_id) {
                slot = Some(*slot_id);
            } else {

                vreg = Some(get_inst_output(ctx, tys[1], *addr_id)?);
            }
        }
        Value::Constant(ConstantValue::GlobalRef(name, _ty)) => {
            gbl = Some(name);
        }
        Value::Argument(a) => {
            vreg = ctx.arg_idx_to_vreg.get(&a.nth).copied();
        }
        _ => return Err(LoweringError::Todo("Unsupported load pattern 1".into()).into()),
    }

    let mem;
    let src_ty = tys[0];

    if let Some(slot) = slot {
        mem = vec![
            MOperand::new(OperandData::MemStart),
            MOperand::new(OperandData::None),
            MOperand::new(OperandData::Slot(slot)),
            MOperand::new(OperandData::None),
            MOperand::input(OperandData::None),
            MOperand::input(OperandData::None),
            MOperand::new(OperandData::None),
        ];
    } else if let Some(gbl) = gbl {
        mem = vec![
            MOperand::new(OperandData::MemStart),
            MOperand::new(OperandData::Label(gbl.as_string().to_owned())),
            MOperand::new(OperandData::None),
            MOperand::new(OperandData::None),
            MOperand::input(OperandData::None),
            MOperand::input(OperandData::None),
            MOperand::new(OperandData::None),
        ]
    } else if let Some(vreg) = vreg {
        mem = vec![
            MOperand::new(OperandData::MemStart),
            MOperand::new(OperandData::None),
            MOperand::new(OperandData::None),
            MOperand::new(OperandData::None),
            MOperand::input(OperandData::VReg(vreg)),
            MOperand::input(OperandData::None),
            MOperand::new(OperandData::None),
        ]
    } else {
        return Err(LoweringError::Todo("Unsupported load pattern 2".into()).into());
    }

    let output = new_empty_inst_output(ctx, src_ty, id);

    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::MLOADr,
            operands: vec![MOperand::output(output.into())]
                .into_iter()
                .chain(mem.into_iter())
                .collect(),
        },
        ctx.block_map[&ctx.cur_block],
    ));

    Ok(())
}