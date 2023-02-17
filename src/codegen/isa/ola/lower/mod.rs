pub mod alloca;
pub mod bin;
pub mod br;
pub mod call;
pub mod load;
pub mod store;

use crate::codegen::core::ir::{
    function::{
        instruction::{
            Alloca, Br, Call, CondBr, Instruction as IrInstruction, InstructionId, IntBinary, Load,
            Operand, Ret, Store,
        },
        Parameter,
    },
    types::Type,
    value::{ConstantExpr, ConstantInt, ConstantValue, Value, ValueId},
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        register::{RegClass, RegInfo, GR},
        Ola,
    },
    lower::{Lower as LowerTrait, LoweringContext, LoweringError},
    register::{RegisterClass, RegisterInfo, VReg},
};
use anyhow::Result;

use alloca::lower_alloca;
use bin::lower_bin;
use br::{lower_br, lower_condbr};
use call::{lower_call, lower_return};
use load::lower_load;
use store::lower_store;

#[derive(Clone, Copy, Default)]
pub struct Lower {}

impl Lower {
    pub fn new() -> Self {
        Lower::default()
    }
}

impl LowerTrait<Ola> for Lower {
    fn lower(ctx: &mut LoweringContext<Ola>, inst: &IrInstruction) -> Result<()> {
        lower(ctx, inst)
    }

    fn copy_args_to_vregs(ctx: &mut LoweringContext<Ola>, params: &[Parameter]) -> Result<()> {
        let args = RegInfo::arg_reg_list(&ctx.call_conv);
        for (gpr_used, Parameter { name: _, ty, .. }) in params.iter().enumerate() {
            let reg = args[gpr_used].apply(&RegClass::for_type(ctx.types, *ty));
            // debug!(reg);
            // Copy reg to new vreg
            assert!(ty.is_integer() || ty.is_pointer(ctx.types));
            let output = ctx.mach_data.vregs.add_vreg_data(*ty);
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MOVrr,
                    operands: vec![MO::output(output.into()), MO::input(reg.into())],
                },
                ctx.block_map[&ctx.cur_block],
            ));
            ctx.arg_idx_to_vreg.insert(gpr_used, output);
        }
        Ok(())
    }
}

fn lower(ctx: &mut LoweringContext<Ola>, inst: &IrInstruction) -> Result<()> {
    match inst.operand {
        Operand::Alloca(Alloca {
            ref tys,
            ref num_elements,
            align,
        }) => lower_alloca(ctx, inst.id.unwrap(), tys, num_elements, align),
        Operand::Load(Load {
            ref tys,
            addr,
            align,
        }) => lower_load(ctx, inst.id.unwrap(), tys, addr, align),
        Operand::Store(Store {
            ref tys,
            ref args,
            align,
        }) => lower_store(ctx, tys, args, align),
        Operand::IntBinary(IntBinary { ty, ref args, .. }) => {
            lower_bin(ctx, inst.id.unwrap(), inst.opcode, ty, args)
        }
        Operand::Br(Br { block }) => lower_br(ctx, block),
        Operand::CondBr(CondBr { arg, blocks }) => lower_condbr(ctx, arg, blocks),
        Operand::Call(Call {
            ref args, ref tys, ..
        }) => lower_call(ctx, inst.id.unwrap(), tys, args),
        Operand::Ret(Ret { val: None, .. }) => lower_return(ctx, None),
        Operand::Ret(Ret { val: Some(val), ty }) => lower_return(ctx, Some((ty, val))),
        ref e => Err(LoweringError::Todo(format!("Unsupported instruction: {:?}", e)).into()),
    }
}

fn get_inst_output(ctx: &mut LoweringContext<Ola>, ty: Type, id: InstructionId) -> Result<VReg> {
    if let Some(vreg) = ctx.inst_id_to_vreg.get(&id) {
        return Ok(*vreg);
    }

    if ctx.ir_data.inst_ref(id).parent != ctx.cur_block {
        // The instruction indexed as `id` must be placed in another basic block
        let vreg = new_empty_inst_output(ctx, ty, id);
        return Ok(vreg);
    }

    let inst = ctx.ir_data.inst_ref(id);
    lower(ctx, inst)?;

    Ok(new_empty_inst_output(ctx, ty, id))
}

fn new_empty_inst_output(ctx: &mut LoweringContext<Ola>, ty: Type, id: InstructionId) -> VReg {
    if let Some(vreg) = ctx.inst_id_to_vreg.get(&id) {
        return *vreg;
    }
    let vreg = ctx.mach_data.vregs.add_vreg_data(ty);
    ctx.inst_id_to_vreg.insert(id, vreg);
    vreg
}

fn get_operand_for_val(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    val: ValueId,
) -> Result<OperandData> {
    match ctx.ir_data.values[val] {
        Value::Instruction(id) => Ok(get_inst_output(ctx, ty, id)?.into()),
        Value::Argument(ref a) => Ok(ctx.arg_idx_to_vreg[&a.nth].into()),
        Value::Constant(ref konst) => get_operand_for_const(ctx, ty, konst),
        ref e => Err(LoweringError::Todo(format!("Unsupported value: {:?}", e)).into()),
    }
}

fn get_operand_for_const(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    konst: &ConstantValue,
) -> Result<OperandData> {
    match konst {
        ConstantValue::Int(ConstantInt::Int32(i)) => Ok(OperandData::Int32(*i)),
        ConstantValue::Int(ConstantInt::Int64(i)) => Ok(OperandData::Int64(*i)),
        ConstantValue::Expr(ConstantExpr::GetElementPtr {
            inbounds: _,
            tys: _,
            ref args,
        }) => {
            // TODO: Refactoring.
            assert!(ty.is_pointer(ctx.types));
            assert!(matches!(args[0], ConstantValue::GlobalRef(_, _)));
            let all_indices_0 = args[1..]
                .iter()
                .all(|arg| matches!(arg, ConstantValue::Int(i) if i.is_zero()));
            assert!(all_indices_0);
            let src = OperandData::Label(args[0].as_global_ref().as_string().clone());
            let dst = ctx.mach_data.vregs.add_vreg_data(ty);
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MLOADr,
                    operands: vec![
                        MO::output(dst.into()),
                        MO::new(OperandData::MemStart),
                        MO::new(src),
                        MO::new(OperandData::None),
                        MO::new(OperandData::None),
                        MO::input(OperandData::Reg(GR::R8.into())),
                        MO::input(OperandData::None),
                        MO::new(OperandData::None),
                    ],
                },
                ctx.block_map[&ctx.cur_block],
            ));
            Ok(dst.into())
        }
        ConstantValue::Expr(ConstantExpr::Bitcast {
            tys: [from, to],
            arg,
        }) => {
            assert!(from.is_pointer(ctx.types));
            assert!(to.is_pointer(ctx.types));
            get_operand_for_const(ctx, *to, arg)
        }
        ConstantValue::GlobalRef(ref name, ty) => {
            assert!(ty.is_pointer(ctx.types));
            let addr = ctx.mach_data.vregs.add_vreg_data(*ty);
            let src = OperandData::Label(name.to_string().unwrap().to_owned());
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MLOADr,
                    operands: vec![
                        MO::output(addr.into()),
                        MO::new(OperandData::MemStart),
                        MO::new(src),
                        MO::new(OperandData::None),
                        MO::new(OperandData::None),
                        MO::input(OperandData::Reg(GR::R8.into())),
                        MO::input(OperandData::None),
                        MO::new(OperandData::None),
                    ],
                },
                ctx.block_map[&ctx.cur_block],
            ));
            Ok(addr.into())
        }
        ConstantValue::Null(ty) => {
            assert!(ty.is_pointer(ctx.types));
            let addr = ctx.mach_data.vregs.add_vreg_data(*ty);
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MOVri,
                    operands: vec![MO::output(addr.into()), MO::new(0.into())],
                },
                ctx.block_map[&ctx.cur_block],
            ));
            Ok(addr.into())
        }
        e => todo!("{:?}", e),
    }
}

fn get_vreg_for_val(ctx: &mut LoweringContext<Ola>, ty: Type, val: ValueId) -> Result<VReg> {
    match get_operand_for_val(ctx, ty, val)? {
        OperandData::Int32(i) => {
            let output = ctx.mach_data.vregs.add_vreg_data(ty);
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode: Opcode::MOVri,
                    operands: vec![MO::output(output.into()), MO::new(i.into())],
                },
                ctx.block_map[&ctx.cur_block],
            ));
            Ok(output)
        }
        OperandData::VReg(vr) => Ok(vr),
        e => Err(LoweringError::Todo(format!("Unsupported operand: {:?}", e)).into()),
    }
}
