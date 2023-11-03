pub mod alloca;
pub mod bin;
pub mod br;
pub mod call;
pub mod extractv;
pub mod gep;
pub mod insertv;
pub mod load;
pub mod phi;
pub mod store;
pub mod zext;

use crate::codegen::core::ir::{
    function::{
        instruction::{
            Alloca, Br, Call, Cast, CondBr, ExtractValue, InsertValue,
            Instruction as IrInstruction, InstructionId, IntBinary, Load, Opcode as IrOpcode,
            Operand, Phi, Ret, Store, Switch,
        },
        Parameter,
    },
    types::Type,
    value::{ConstantArray, ConstantExpr, ConstantInt, ConstantValue, Value, ValueId},
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        register::{RegClass, RegInfo, GR},
        Ola,
    },
    isa::TargetIsa,
    lower::{Lower as LowerTrait, LoweringContext, LoweringError},
    register::{RegisterClass, RegisterInfo, VReg},
};
use anyhow::Result;
use debug_print::debug_println;

use alloca::lower_alloca;
use bin::{lower_bin, lower_itp};
use br::{lower_br, lower_condbr, lower_switch};
use call::{lower_call, lower_return};
use extractv::lower_extractvalue;
use gep::lower_gep;
use insertv::lower_insertvalue;
use load::lower_load;
use phi::lower_phi;
use store::lower_store;
use zext::lower_zext;

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
        let args = RegInfo::str_arg_reg_list(&ctx.call_conv);
        let mut gpr_used = 0;
        for (para_idx, Parameter { name: _, ty, .. }) in params.iter().enumerate() {
            assert!(ty.is_integer() || ty.is_pointer(ctx.types) || ty.is_array(ctx.types));
            if ty.is_array(ctx.types) {
                let sz = ctx.isa.data_layout().get_size_of(ctx.types, *ty) / 4;
                let e_ty = ctx.types.base().element(*ty).unwrap();
                let mut outputs = vec![];
                for _ in 0..sz {
                    let reg = args[gpr_used].apply(&RegClass::for_type(ctx.types, e_ty));
                    let output = ctx.mach_data.vregs.add_vreg_data(e_ty);
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::MOVrr,
                            operands: vec![MO::output(output.into()), MO::input(reg.into())],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                    outputs.push(output);
                    gpr_used += 1;
                }
                ctx.arg_idx_to_vreg.insert(para_idx, outputs);
            } else {
                let reg = args[gpr_used].apply(&RegClass::for_type(ctx.types, *ty));
                // debug!(reg);
                // Copy reg to new vreg
                let output = ctx.mach_data.vregs.add_vreg_data(*ty);
                gpr_used += 1;
                assert!(gpr_used <= 8);
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::MOVrr,
                        operands: vec![MO::output(output.into()), MO::input(reg.into())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
                ctx.arg_idx_to_vreg.insert(para_idx, vec![output]);
            }
        }
        Ok(())
    }
}

fn lower(ctx: &mut LoweringContext<Ola>, inst: &IrInstruction) -> Result<()> {
    debug_println!("lower opcode {:?}", inst.opcode);
    match inst.operand {
        Operand::Alloca(Alloca {
            ref tys,
            ref num_elements,
            align,
        }) => lower_alloca(ctx, inst.id.unwrap(), tys, num_elements, align),
        Operand::Phi(Phi {
            ty,
            ref args,
            ref blocks,
        }) => lower_phi(ctx, inst.id.unwrap(), ty, args, blocks),
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
        Operand::GetElementPtr(ref gep) => lower_gep(ctx, inst.id.unwrap(), gep),
        Operand::InsertValue(InsertValue { ref tys, ref args }) => {
            lower_insertvalue(ctx, inst.id.unwrap(), tys, args)
        }
        Operand::ExtractValue(ExtractValue { ref ty, ref args }) => {
            lower_extractvalue(ctx, inst.id.unwrap(), ty, args)
        }
        Operand::IntBinary(IntBinary { ty, ref args, .. }) => {
            lower_bin(ctx, inst.id.unwrap(), inst.opcode, ty, args)
        }
        Operand::Cast(Cast { ref tys, arg })
            if inst.opcode == IrOpcode::IntToPtr || inst.opcode == IrOpcode::PtrToInt =>
        {
            lower_itp(ctx, inst.id.unwrap(), tys, arg)
        }
        Operand::Cast(Cast { ref tys, arg }) if inst.opcode == IrOpcode::Zext => {
            lower_zext(ctx, inst.id.unwrap(), tys, arg)
        }
        Operand::Br(Br { block }) => lower_br(ctx, block),
        Operand::CondBr(CondBr { arg, blocks }) => lower_condbr(ctx, arg, blocks),
        Operand::Switch(Switch {
            ref tys,
            ref args,
            ref blocks,
        }) => lower_switch(ctx, inst.id.unwrap(), tys, args, blocks),
        Operand::Call(Call {
            ref args, ref tys, ..
        }) => lower_call(ctx, inst.id.unwrap(), tys, args),
        Operand::Ret(Ret { val: None, .. }) => lower_return(ctx, None),
        Operand::Ret(Ret { val: Some(val), ty }) => lower_return(ctx, Some((ty, val))),
        ref e => Err(LoweringError::Todo(format!("Unsupported instruction: {:?}", e)).into()),
    }
}

fn get_inst_output(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    id: InstructionId,
) -> Result<Vec<VReg>> {
    if let Some(vreg) = ctx.inst_id_to_vreg.get(&id) {
        return Ok(vreg.to_vec());
    }

    if ctx.ir_data.inst_ref(id).parent != ctx.cur_block {
        // The instruction indexed as `id` must be placed in another basic block
        debug_println!("inst output ref not current block");
        let vreg = new_empty_inst_output(ctx, ty, id);
        return Ok(vreg);
    }

    let inst = ctx.ir_data.inst_ref(id);
    lower(ctx, inst)?;

    Ok(new_empty_inst_output(ctx, ty, id))
}

fn new_empty_inst_output(ctx: &mut LoweringContext<Ola>, ty: Type, id: InstructionId) -> Vec<VReg> {
    if let Some(vreg) = ctx.inst_id_to_vreg.get(&id) {
        return vreg.to_vec();
    }
    let vreg = ctx.mach_data.vregs.add_vreg_data(ty);
    ctx.inst_id_to_vreg.insert(id, vec![vreg]);
    vec![vreg]
}

fn get_str_inst_output(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    id: InstructionId,
) -> Result<Vec<VReg>> {
    let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty) / 4;
    if let Some(vreg) = ctx.inst_id_to_vreg.get(&id) {
        if vreg.len() == sz {
            debug_println!("storage insts vregs len: {:?}", vreg.len());
            return Ok(vreg.to_vec());
        }
    }

    if ctx.ir_data.inst_ref(id).parent != ctx.cur_block {
        // The instruction indexed as `id` must be placed in another basic block
        let vreg = new_empty_str_inst_output(ctx, ty, id);
        return Ok(vreg);
    }

    let inst = ctx.ir_data.inst_ref(id);
    lower(ctx, inst)?;

    Ok(new_empty_str_inst_output(ctx, ty, id))
}

fn new_empty_str_inst_output(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    id: InstructionId,
) -> Vec<VReg> {
    let mut vregs = if let Some(vreg) = ctx.inst_id_to_vreg.get(&id) {
        vreg.to_vec()
    } else {
        vec![]
    };

    let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty) / 4;
    if vregs.len() == sz {
        return vregs;
    }

    let e_ty = ctx.types.base().element(ty).unwrap();
    for _ in 0..sz {
        let vreg = ctx.mach_data.vregs.add_vreg_data(e_ty);
        vregs.push(vreg);
    }
    ctx.inst_id_to_vreg.insert(id, vregs.clone());
    vregs
}

fn get_operand_for_val(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    val: ValueId,
) -> Result<OperandData> {
    match ctx.ir_data.values[val] {
        Value::Instruction(id) => {
            let vreg = get_inst_output(ctx, ty, id)?;
            Ok(vreg[0].into())
        }
        Value::Argument(ref a) => Ok(ctx.arg_idx_to_vreg[&a.nth][0].into()),
        Value::Constant(ref konst) => get_operand_for_const(ctx, ty, konst),
        ref e => Err(LoweringError::Todo(format!("Unsupported value: {:?}", e)).into()),
    }
}

fn get_operand_for_const(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    konst: &ConstantValue,
) -> Result<OperandData> {
    debug_println!("scalar const operand");
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
                        MO::input(OperandData::Reg(GR::R9.into())),
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
                        MO::input(OperandData::Reg(GR::R9.into())),
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

fn get_operands_for_val(
    ctx: &mut LoweringContext<Ola>,
    ty: Type,
    val: ValueId,
) -> Result<Vec<OperandData>> {
    match ctx.ir_data.values[val] {
        Value::Instruction(id) => {
            let mut vregs_dst: Vec<OperandData> = vec![];
            let vregs_src = get_str_inst_output(ctx, ty, id)?;
            let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty) / 4;

            for idx in 0..sz {
                vregs_dst.push(vregs_src[idx].into());
            }
            Ok(vregs_dst)
        }
        Value::Argument(ref a) => {
            let mut vregs = vec![];
            let ops = ctx.arg_idx_to_vreg.get(&a.nth).unwrap();
            for idx in 0..ops.len() {
                vregs.push(ops[idx].into());
            }
            Ok(vregs)
        }
        Value::Constant(ref konst) => get_operands_for_const(ctx, ty, konst),
        ref e => Err(LoweringError::Todo(format!("Unsupported value: {:?}", e)).into()),
    }
}

fn get_operands_for_const(
    ctx: &mut LoweringContext<Ola>,
    _ty: Type,
    konst: &ConstantValue,
) -> Result<Vec<OperandData>> {
    debug_println!("aggregation const operand");
    match konst {
        ConstantValue::Array(ConstantArray {
            ty: _,
            elem_ty: _,
            ref elems,
            ..
        }) => {
            let mut inputs = vec![];
            for (_idx, e) in elems.iter().enumerate() {
                /*
                    let addr = ctx.mach_data.vregs.add_vreg_data(*elem_ty);
                    let input: Result<MO, &str> = match e {
                        ConstantValue::Int(ConstantInt::Int32(i)) => {
                            Ok(MO::new(OperandData::Int32(*i)))
                        }
                        ConstantValue::Int(ConstantInt::Int64(i)) => {
                            Ok(MO::new(OperandData::Int64(*i)))
                        }
                        e => todo!("{:?}", e),
                    };
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::MOVri,
                            operands: vec![MO::output(addr.into()), input.unwrap()],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                    debug_println!("array const operand vreg: {:?}", addr);
                    inputs.push(addr.into());
                */
                let input = match e {
                    ConstantValue::Int(ConstantInt::Int32(i)) => OperandData::Int32(*i),
                    ConstantValue::Int(ConstantInt::Int64(i)) => OperandData::Int64(*i),
                    ConstantValue::Undef(_) => 0.into(),
                    e => todo!("{:?}", e),
                };
                debug_println!("array const operand vreg: {:?}", input);
                inputs.push(input);
            }
            Ok(inputs)
        }
        ConstantValue::AggregateZero(ty) | ConstantValue::Undef(ty) => {
            let mut inputs = vec![];
            let sz = ctx.isa.data_layout().get_size_of(ctx.types, *ty) / 4;
            // let elem_ty = ctx.types.base().element(*ty).unwrap();
            for _ in 0..sz {
                /*
                let addr = ctx.mach_data.vregs.add_vreg_data(elem_ty);
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::MOVri,
                        operands: vec![MO::output(addr.into()), MO::new(0.into())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
                debug_println!("aggregate zero const operand vreg {:?}", addr);
                inputs.push(addr.into());
                */
                debug_println!("aggregate zero const operand");
                inputs.push(0.into());
            }
            Ok(inputs)
        }
        e => todo!("{:?}", e),
    }
}

fn get_vreg_for_val(ctx: &mut LoweringContext<Ola>, ty: Type, val: ValueId) -> Result<VReg> {
    match get_operand_for_val(ctx, ty, val)? {
        OperandData::Int64(i) => {
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
