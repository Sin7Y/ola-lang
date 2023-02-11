pub mod load;
pub mod store;

use crate::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        register::{RegClass, RegInfo, GR},
        Ola,
    },
    isa::TargetIsa,
    lower::{Lower as LowerTrait, LoweringContext, LoweringError},
    register::{Reg, RegisterClass, RegisterInfo, VReg},
};
use anyhow::Result;
use load::lower_load;
use store::lower_store;
use vicis_core::ir::{
    function::{
        basic_block::BasicBlockId,
        data::Data as IrData,
        instruction::{
            Alloca, Br, Call, Cast, CondBr, ICmp, ICmpCond,
            Instruction as IrInstruction, InstructionId, IntBinary, Load, Opcode as IrOpcode,
            Operand, Ret, Store,
        },
        Parameter,
    },
    module::name::Name,
    types::{self, CompoundType, FunctionType, Type},
    value::{ConstantExpr, ConstantInt, ConstantValue, Value, ValueId},
};

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
            debug!(reg);
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

fn lower_alloca(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    tys: &[Type],
    _num_elements: &ConstantValue,
    _align: u32,
) -> Result<()> {
    if let Some(slot_id) = ctx.inst_id_to_slot_id.get(&id) {
        let mem = vec![
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
                operands: vec![MO::output(output.into())]
                    .into_iter()
                    .chain(mem.into_iter())
                    .collect(),
            },
            ctx.block_map[&ctx.cur_block],
        ));

        return Ok(());
    }
    let dl = ctx.isa.data_layout();
    let sz = dl.get_size_of(ctx.types, tys[0]) as u32;
    let align = dl.get_align_of(ctx.types, tys[0]) as u32;
    let slot_id = ctx.slots.add_slot(tys[0], sz/4, align);
    ctx.inst_id_to_slot_id.insert(id, slot_id);
    Ok(())
}

fn lower_bin(
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
                operands: vec![MO::output(OperandData::Reg(GR::R6.into())), MO::input(rhs.clone().into())],
            },
            ctx.block_map[&ctx.cur_block],
        ))
    };

    let insert_add = |ctx: &mut LoweringContext<Ola>| {
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::ADDri,
                operands: vec![
                    MO::output(OperandData::Reg(GR::R6.into())), 
                    MO::input(OperandData::Reg(GR::R6.into())),
                    MO::input(OperandData::Int64(1)),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ))
    };

    let data = match rhs {
        OperandData::Int32(rhs) => {
            if IrOpcode::Sub == op {
                insert_not(ctx);
                insert_add(ctx);
            }
            match op {
                IrOpcode::Sub => {  
                    InstructionData {
                        opcode: Opcode::ADDri,
                        operands: vec![
                            MO::input_output(output.into()), 
                            MO::input(lhs.into()),
                            MO::input(OperandData::Reg(GR::R6.into())),
                        ],
                    }
                }, 
                IrOpcode::Add => { 
                    InstructionData {
                        opcode: Opcode::ADDri,
                        operands: vec![
                            MO::input_output(output.into()), 
                            MO::input(lhs.into()),
                            MO::input(rhs.into()),
                        ],
                    }
                },  
                IrOpcode::Mul => { 
                    InstructionData {
                        opcode: Opcode::MULri,
                        operands: vec![
                            MO::input_output(output.into()), 
                            MO::input(lhs.into()),
                            MO::input(rhs.into()),
                        ],
                    }
                }, 
                op => {
                    return Err(
                        LoweringError::Todo(format!("Unsupported opcode: {:?}", op)).into()
                    )
                }     
            }
        }
        OperandData::VReg(rhs) => {
            if IrOpcode::Sub == op {
                insert_not(ctx);
                insert_add(ctx);
            }
            match op {
                IrOpcode::Sub => {  
                    InstructionData {
                        opcode: Opcode::ADDrr,
                        operands: vec![
                            MO::input_output(output.into()), 
                            MO::input(lhs.into()),
                            MO::input(OperandData::Reg(GR::R6.into())),
                        ],
                    }
                }, 
                IrOpcode::Add => { 
                    InstructionData {
                        opcode: Opcode::ADDrr,
                        operands: vec![
                            MO::input_output(output.into()), 
                            MO::input(lhs.into()),
                            MO::input(rhs.into()),
                        ],
                    }
                },  
                IrOpcode::Mul => { 
                    InstructionData {
                        opcode: Opcode::MULrr,
                        operands: vec![
                            MO::input_output(output.into()), 
                            MO::input(lhs.into()),
                            MO::input(rhs.into()),
                        ],
                    }
                }, 
                op => {
                    return Err(
                        LoweringError::Todo(format!("Unsupported opcode: {:?}", op)).into()
                    )
                }     
            }
        }
        e => return Err(LoweringError::Todo(format!("Unsupported operand: {:?}", e)).into()),
    };

    ctx.inst_seq
        .push(MachInstruction::new(data, ctx.block_map[&ctx.cur_block]));

    Ok(())
}

fn lower_br(ctx: &mut LoweringContext<Ola>, block: BasicBlockId) -> Result<()> {
    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::JMPr,
            operands: vec![MO::new(OperandData::Block(ctx.block_map[&block]))],
        },
        ctx.block_map[&ctx.cur_block],
    ));
    Ok(())
}

fn lower_condbr(
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
    fn is_trunc_from_i8(data: &IrData, val: &Value) -> Option<(InstructionId, ValueId)> {
        match val {
            Value::Instruction(id) => {
                let inst = data.inst_ref(*id);
                match &inst.operand {
                    Operand::Cast(Cast {
                        arg,
                        tys: [from, to],
                    }) if inst.opcode == IrOpcode::Trunc && from.is_i8() && to.is_i1() => {
                        Some((*id, *arg))
                    }
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
            Value::Constant(ConstantValue::Int(ConstantInt::Int32(rhs))) => {
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::CMPri,
                        operands: vec![MO::input(lhs.into()), MO::new(rhs.into())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
            Value::Constant(ConstantValue::Null(_)) => {
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::CMPri,
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
                        opcode: Opcode::CMPrr, // TODO: CMPrr64
                        operands: vec![MO::input(lhs.into()), MO::input(rhs.into())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
            e => return Err(LoweringError::Todo(format!("Unsupported operand: {:?}", e)).into()),
        }

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: match cond {
                    ICmpCond::Eq => Opcode::CJMPr,
                    ICmpCond::Ne => Opcode::CJMPr,
                    ICmpCond::Sle => Opcode::CJMPr,
                    ICmpCond::Slt => Opcode::CJMPr,
                    ICmpCond::Sge => Opcode::CJMPr,
                    ICmpCond::Sgt => Opcode::CJMPr,
                    // ICmpCond::Ule => Opcode::JLE,
                    // ICmpCond::Ult => Opcode::JL,
                    // ICmpCond::Uge => Opcode::JGE,
                    // ICmpCond::Ugt => Opcode::JG,
                    e => {
                        return Err(LoweringError::Todo(format!(
                            "Unsupported icmp condition: {:?}",
                            e
                        ))
                        .into())
                    }
                },
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

    if let Some((trunc, src)) = is_trunc_from_i8(ctx.ir_data, arg) {
        ctx.mark_as_merged(trunc);
        let lhs = get_vreg_for_val(ctx, types::I8, src)?;
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::CMPri,
                operands: vec![MO::input(lhs.into()), MO::new(0i8.into())],
            },
            ctx.block_map[&ctx.cur_block],
        ));
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

fn lower_call(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    tys: &[Type],
    args: &[ValueId],
) -> Result<()> {
    let callee = args[0];
    let name = match &ctx.ir_data.values[callee] {
        Value::Constant(ConstantValue::GlobalRef(Name::Name(name), _)) => name.clone(),
        callee => {
            return Err(LoweringError::Todo(format!("Unsupported callee: {:?}", callee)).into())
        }
    };
    log::debug!("call name: {}", name);

    let result_ty = if let Some(ty) = ctx.types.get(tys[0])
                    && let CompoundType::Function(FunctionType { ret, .. }) = &*ty {
        *ret
    } else {
        tys[0]
    };
    let output = new_empty_inst_output(ctx, result_ty, id);

    pass_args_to_regs(ctx, &tys[1..], &args[1..])?;

    let result_reg: Reg = GR::R0.into();

    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::CALL,
            operands: vec![
                MO::implicit_output(result_reg.into()),
                MO::new(OperandData::Label(name)),
            ],
        },
        ctx.block_map[&ctx.cur_block],
    ));

    if !ctx.ir_data.users_of(id).is_empty() {
        let opcode = Opcode::MOVrr;
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode,
                operands: vec![MO::output(output.into()), MO::input(result_reg.into())],
            },
            ctx.block_map[&ctx.cur_block],
        ));
    }

    Ok(())
}

fn pass_args_to_regs(
    ctx: &mut LoweringContext<Ola>,
    tys: &[Type],
    args: &[ValueId],
) -> Result<()> {
    let gpru = RegInfo::arg_reg_list(&ctx.call_conv);

    for (gpr_used, (&ty, &arg)) in tys.iter().zip(args.iter()).enumerate() {
        let arg = get_operand_for_val(ctx, ty, arg)?;
        let out = gpru[gpr_used].apply(&RegClass::for_type(ctx.types, ty));
        let opcode = match &arg {
            OperandData::Int32(_) => Opcode::MOVri,
            OperandData::Reg(_) => Opcode::MOVrr, // TODO: FIXME
            OperandData::VReg(vreg) => {
                let ty = ctx.mach_data.vregs.type_for(*vreg);
                let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty);
                match sz {
                    4 => Opcode::MOVrr,
                    e => {
                        return Err(LoweringError::Todo(format!(
                            "Unsupported argument size: {:?}",
                            e
                        ))
                        .into())
                    }
                }
            }
            e => return Err(LoweringError::Todo(format!("Unsupported argument: {:?}", e)).into()),
        };
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode,
                operands: vec![MO::output(out.into()), MO::input(arg)],
            },
            ctx.block_map[&ctx.cur_block],
        ));
    }

    Ok(())
}

fn lower_return(ctx: &mut LoweringContext<Ola>, arg: Option<(Type, ValueId)>) -> Result<()> {
    if let Some((ty, value)) = arg {
        let vreg = get_vreg_for_val(ctx, ty, value)?;
        let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty);
        assert!(ty.is_integer() || ty.is_pointer(ctx.types));
        let (reg, opcode) = match sz {
            4 => (GR::R0.into(), Opcode::MOVrr),
            _ => todo!(),
        };
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode,
                operands: vec![MO::output(OperandData::Reg(reg)), MO::input(vreg.into())],
            },
            ctx.block_map[&ctx.cur_block],
        ));
    }
    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::RET,
            operands: vec![],
        },
        ctx.block_map[&ctx.cur_block],
    ));
    Ok(())
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
