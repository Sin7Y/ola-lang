use crate::codegen::core::ir::{
    function::instruction::InstructionId, types::Type, value::ConstantValue,
};
use crate::codegen::isa::TargetIsa;
use crate::codegen::register::Reg;
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        register::GR,
        Ola,
    },
    lower::LoweringContext,
};
use anyhow::Result;
use debug_print::debug_println;

pub fn lower_alloca(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    tys: &[Type],
    _num_elements: &ConstantValue,
    _align: u32,
) -> Result<()> {
    if let Some(slot_id) = ctx.inst_id_to_slot_id.get(&id) {
        debug_println!("alloca slot id exists");
        let ty = ctx.types.base_mut().pointer(tys[0]);
        //let output = new_empty_inst_output(ctx, ty, id);
        let addr = ctx.mach_data.vregs.add_vreg_data(ty);

        let fp: Reg = GR::R9.into();
        let src_slot = Some(*slot_id);
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::ADDri,
                operands: vec![
                    MO::output(addr.into()),
                    MO::new(fp.into()),
                    MO::new(OperandData::Slot(src_slot.unwrap())),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        ctx.inst_id_to_vreg.insert(id, vec![addr]);
        /* let mem = vec![
            MO::new(OperandData::MemStart),
            MO::new(OperandData::None),
            MO::new(OperandData::Slot(*slot_id)),
            MO::new(OperandData::None),
            MO::input(OperandData::None),
            MO::input(OperandData::None),
            MO::new(OperandData::None),
        ];

        let ty = ctx.types.base_mut().pointer(tys[0]);
        let output = new_empty_inst_output(ctx, ty, id);
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::MLOADr,
                operands: vec![MO::output(output[0].into())]
                    .into_iter()
                    .chain(mem.into_iter())
                    .collect(),
            },
            ctx.block_map[&ctx.cur_block],
        )); */

        return Ok(());
    }
    let dl = ctx.isa.data_layout();
    let sz = dl.get_size_of(ctx.types, tys[0]) as u32;
    let align = dl.get_align_of(ctx.types, tys[0]) as u32;
    let slot_id = ctx.slots.add_slot(tys[0], sz, align);
    ctx.inst_id_to_slot_id.insert(id, slot_id);
    Ok(())
}
