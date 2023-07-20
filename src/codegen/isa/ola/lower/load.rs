use super::{
    get_inst_output, get_operand_for_val, new_empty_inst_output, new_empty_str_inst_output,
};
use crate::codegen::core::ir::{
    function::instruction::{InstructionId, Opcode as IrOpcode},
    types::Type,
    value::{ConstantInt, ConstantValue, Value, ValueId},
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MOperand, OperandData},
        Ola,
    },
    isa::TargetIsa,
    lower::{LoweringContext, LoweringError},
};
use anyhow::Result;

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
                let opcode = ctx.ir_data.instructions[*addr_id].opcode;
                if opcode == IrOpcode::GetElementPtr {
                    return lower_load_gep(ctx, id, tys, *addr_id, _align);
                }
                vreg = Some(get_inst_output(ctx, tys[1], *addr_id)?);
            }
        }
        Value::Constant(ConstantValue::GlobalRef(name, _ty)) => {
            gbl = Some(name);
        }
        Value::Argument(a) => {
            let mut vregs = vec![];
            let ops = ctx.arg_idx_to_vreg.get(&a.nth).unwrap();
            for idx in 0..ops.len() {
                vregs.push(ops[idx]);
            }
            vreg = Some(vregs);
        }
        _ => return Err(LoweringError::Todo("Unsupported load pattern 1".into()).into()),
    }

    let mut mem;
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
            MOperand::input(OperandData::VReg(vreg[0])),
            MOperand::input(OperandData::None),
            MOperand::new(OperandData::None),
        ]
    } else {
        return Err(LoweringError::Todo("Unsupported load pattern 2".into()).into());
    }

    let sz = ctx.isa.data_layout().get_size_of(ctx.types, src_ty) / 4;
    let output;
    if sz > 1 {
        output = new_empty_str_inst_output(ctx, src_ty, id);
    } else {
        output = new_empty_inst_output(ctx, src_ty, id);
    }
    for idx in 0..sz {
        mem[3] = MOperand::new(OperandData::Int64(-4 * idx as i64 + 12));
        if sz == 1 {
            mem[3] = MOperand::new(OperandData::None);
        }
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::MLOADr,
                operands: vec![MOperand::output(output[idx].into())]
                    .into_iter()
                    .chain(mem.clone().into_iter())
                    .collect(),
            },
            ctx.block_map[&ctx.cur_block],
        ));
    }

    Ok(())
}

fn lower_load_gep(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    tys: &[Type],
    gep_id: InstructionId,
    _align: u32,
) -> Result<()> {
    use {
        Constant as Const,
        ConstantInt::{Int32, Int64},
        ConstantValue::Int,
        Value::Constant,
    };

    let gep = &ctx.ir_data.instructions[gep_id];

    let gep_args: Vec<&Value> = gep
        .operand
        .args()
        .iter()
        .map(|&arg| &ctx.ir_data.values[arg])
        .collect();

    let mem = match &gep_args[..] {
        [Value::Instruction(base_ptr), Const(Int(Int64(idx0))), Const(Int(Int64(idx1)))] => {
            let mut slot = None;
            let mut base = None;
            if let Some(p) = ctx.inst_id_to_slot_id.get(base_ptr) {
                slot = Some(*p);
            } else {
                base = Some(get_operand_for_val(
                    ctx,
                    gep.operand.types()[1],
                    gep.operand.args()[0],
                )?);
            }
            let base_ty = gep.operand.types()[0];
            let offset = idx0 * ctx.isa.data_layout.get_size_of(ctx.types, base_ty) as i64
                + idx1
                    * ctx
                        .isa
                        .data_layout
                        .get_size_of(ctx.types, gep.operand.types()[3])
                        as i64;

            vec![
                MOperand::new(OperandData::MemStart),
                MOperand::new(OperandData::None),
                MOperand::new(slot.map_or(OperandData::None, |s| OperandData::Slot(s))),
                MOperand::new(OperandData::Int32(-offset as i32)),
                MOperand::input(base.map_or(OperandData::None, |x| x)),
                MOperand::input(OperandData::None),
                MOperand::new(OperandData::None),
            ]
        }
        [Value::Instruction(base_ptr), Const(Int(Int32(idx0))), Const(Int(Int32(idx1)))] => {
            println!(
                "load_gep: base_ptr {:?},idx0 {},idx1 {}",
                base_ptr, idx0, idx1
            );
            let base_ptr = ctx.inst_id_to_slot_id[base_ptr];
            let base_ty = gep.operand.types()[0];
            let offset = idx0 * ctx.isa.data_layout.get_size_of(ctx.types, base_ty) as i32
                + idx1
                    * ctx
                        .isa
                        .data_layout
                        .get_size_of(ctx.types, ctx.types.get_element(base_ty).unwrap())
                        as i32;

            vec![
                MOperand::new(OperandData::MemStart),
                MOperand::new(OperandData::None),
                MOperand::new(OperandData::Slot(base_ptr)),
                MOperand::new(OperandData::Int32(-offset as i32)),
                MOperand::input(OperandData::None),
                MOperand::input(OperandData::None),
                MOperand::new(OperandData::None),
            ]
        }
        [Value::Instruction(base_ptr), Const(Int(Int64(idx0))), Value::Instruction(idx1)] => {
            let mut slot = None;
            let mut base = None;
            if let Some(p) = ctx.inst_id_to_slot_id.get(base_ptr) {
                slot = Some(*p);
                println!("load gep slot");
            } else {
                base = Some(get_operand_for_val(
                    ctx,
                    gep.operand.types()[1],
                    gep.operand.args()[0],
                )?);
                println!("load gep base");
            }

            let base_ty = gep.operand.types()[0];
            let offset = idx0 * ctx.isa.data_layout.get_size_of(ctx.types, base_ty) as i64;
            println!("gep load off:{}", offset);

            let idx1_ty = gep.operand.types()[3];
            //assert!(idx1_ty.is_i64());
            let idx1 = get_inst_output(ctx, idx1_ty, *idx1)?;

            assert!({
                let mul = ctx
                    .isa
                    .data_layout
                    .get_size_of(ctx.types, ctx.types.get_element(base_ty).unwrap());
                mul == 1 || mul == 2 || mul == 4 || mul == 8
            });

            vec![
                MOperand::new(OperandData::MemStart),
                MOperand::new(OperandData::None),
                MOperand::new(slot.map_or(OperandData::None, |s| OperandData::Slot(s))),
                MOperand::new(OperandData::Int32(-offset as i32)),
                MOperand::input(base.map_or(OperandData::None, |x| x)),
                MOperand::input(OperandData::VReg(idx1[0])),
                MOperand::new(OperandData::None),
            ]
        }
        [Value::Instruction(base_ptr), Value::Instruction(idx1)] => {
            let mut slot = None;
            let mut base = None;
            if let Some(p) = ctx.inst_id_to_slot_id.get(base_ptr) {
                slot = Some(*p);
            } else {
                base = Some(get_operand_for_val(
                    ctx,
                    gep.operand.types()[1],
                    gep.operand.args()[0],
                )?);
            }

            // let base_ty = gep.operand.types()[0];
            //let offset = idx0 * ctx.isa.data_layout.get_size_of(ctx.types, base_ty) as
            // i64;

            let idx1_ty = gep.operand.types()[2];
            let idx1 = get_inst_output(ctx, idx1_ty, *idx1)?;

            vec![
                MOperand::new(OperandData::MemStart),
                MOperand::new(OperandData::None),
                MOperand::new(slot.map_or(OperandData::None, |s| OperandData::Slot(s))),
                MOperand::new(OperandData::Int32(0 as i32)),
                MOperand::input(base.map_or(OperandData::None, |x| x)),
                MOperand::input(OperandData::VReg(idx1[0])),
                MOperand::new(OperandData::Int32(4 as i32)),
            ]
        }
        e => todo!("Unsupported GEP pattern for load: {:?}", e),
    };

    //ctx.mark_as_merged(gep_id);

    let output = new_empty_inst_output(ctx, tys[0], id);

    let src_ty = tys[0];
    if src_ty.is_i32() {
        ctx.inst_seq.append(&mut vec![MachInstruction::new(
            InstructionData {
                opcode: Opcode::MLOADr,
                operands: vec![MOperand::output(OperandData::VReg(output[0]))]
                    .into_iter()
                    .chain(mem.into_iter())
                    .collect(),
            },
            ctx.block_map[&ctx.cur_block],
        )]);
    } else {
        return Err(LoweringError::Todo("Load result".into()).into());
    }

    Ok(())
}
