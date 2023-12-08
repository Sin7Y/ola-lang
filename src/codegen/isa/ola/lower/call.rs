use std::vec;

use super::{
    get_operand_for_val, get_operands_for_val, get_vreg_for_val, new_empty_inst_output,
    new_empty_str_inst_output,
};
use crate::codegen::core::ir::{
    function::instruction::InstructionId,
    module::name::Name,
    types::{CompoundType, FunctionType, Type},
    value::{ConstantValue, Value, ValueId},
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        register::{RegClass, RegInfo, GR},
        Ola,
    },
    isa::TargetIsa,
    lower::{LoweringContext, LoweringError},
    register::{Reg, RegisterClass, RegisterInfo},
};
use anyhow::{Ok, Result};
use debug_print::debug_println;

pub fn lower_call(
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

    // frist lower builtin call into isa inst directly
    if name.starts_with("builtin") {
        match name.as_str() {
            "builtin_assert" => {
                let arg = get_operand_for_val(ctx, tys[1], args[1])?;
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::ASSERTri,
                        operands: vec![MO::input(arg)],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
            "builtin_range_check" => {
                let arg = get_operand_for_val(ctx, tys[1], args[1])?;
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::RANGECHECK,
                        operands: vec![MO::input(arg)],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
            e => todo!("{:?}", e),
        }
        return Ok(());
    }

    if name.as_str() == "contract_call" {
        let addr = get_vreg_for_val(ctx, tys[1], args[1])?;
        let flag = get_operand_for_val(ctx, tys[2], args[2])?;
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::SCCALL,
                operands: vec![MO::input(addr.into()), MO::input(flag)],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    if name.as_str() == "get_storage" {
        let src = get_vreg_for_val(ctx, tys[1], args[1])?;
        let dst = get_operand_for_val(ctx, tys[2], args[2])?;

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::SLOAD,
                operands: vec![MO::input(src.into()), MO::output(dst)],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    if name.as_str() == "set_storage" {
        let src = get_vreg_for_val(ctx, tys[1], args[1])?;
        let dst = get_operand_for_val(ctx, tys[2], args[2])?;

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::SSTORE,
                operands: vec![MO::input(src.into()), MO::output(dst)],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    if name.as_str() == "poseidon_hash" {
        let src = get_vreg_for_val(ctx, tys[1], args[1])?;
        let dst = get_vreg_for_val(ctx, tys[2], args[2])?;
        let len = get_operand_for_val(ctx, tys[3], args[3])?;

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::POSEIDON,
                operands: vec![
                    MO::output(dst.into()),
                    MO::input(src.into()),
                    MO::input(len),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    if name.as_str() == "get_context_data" || name.as_str() == "get_tape_data" {
        let flag_imm = if name.as_str() == "get_tape_data" {
            1
        } else {
            0
        };
        let addr = ctx.mach_data.vregs.add_vreg_data(tys[1]);
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::MOVri,
                operands: vec![MO::output(addr.into()), MO::new(flag_imm.into())],
            },
            ctx.block_map[&ctx.cur_block],
        ));

        let dest = get_vreg_for_val(ctx, tys[1], args[1])?;
        let idx = get_operand_for_val(ctx, tys[2], args[2])?;

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::TLOADri,
                operands: vec![
                    MO::output(dest.into()),
                    MO::input(addr.into()),
                    MO::input(idx),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    if name.as_str() == "set_tape_data" {
        let src = get_vreg_for_val(ctx, tys[1], args[1])?;
        let len = get_operand_for_val(ctx, tys[2], args[2])?;

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::TSTOREr,
                operands: vec![MO::input(src.into()), MO::input(len)],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    if name.as_str() == "set_storage" {
        pass_str_args_to_regs(ctx, &tys[1..], &args[1..])?;
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::SSTORE,
                operands: vec![],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    if name.as_str() == "get_storage" || name.as_str() == "poseidon_hash" {
        pass_str_args_to_regs(ctx, &tys[1..], &args[1..])?;

        let ret_reg0: Reg = GR::R1.into();
        let ret_reg1: Reg = GR::R2.into();
        let ret_reg2: Reg = GR::R3.into();
        let ret_reg3: Reg = GR::R4.into();

        let opcode = if name.as_str() == "get_storage" {
            Opcode::SLOAD
        } else {
            Opcode::POSEIDON
        };
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode,
                operands: vec![
                    MO::implicit_output(ret_reg0.into()),
                    MO::implicit_output(ret_reg1.into()),
                    MO::implicit_output(ret_reg2.into()),
                    MO::implicit_output(ret_reg3.into()),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ));

        let sz = ctx.isa.data_layout().get_size_of(ctx.types, tys[0]) / 4;
        let res_reg: [Reg; 4] = [ret_reg0, ret_reg1, ret_reg2, ret_reg3];
        let opcode = Opcode::MOVrr;
        if !ctx.ir_data.users_of(id).is_empty() {
            let output = new_empty_str_inst_output(ctx, tys[0], id);
            for idx in 0..sz {
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode,
                        operands: vec![
                            MO::output(output[idx].into()),
                            MO::input(res_reg[idx].into()),
                        ],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
        }
        return Ok(());
    }

    // then lower general function calls and prophet separately:
    // for gfc insts pattern as args + call_inst + return
    // for prophet insts pattern as args + prophet_pseudo + return_prophet
    let mut opcode = Opcode::CALL;
    if name.starts_with("prophet") {
        opcode = Opcode::PROPHET;
    }

    let result_ty = if let Some(ty) = ctx.types.get(tys[0])
        && let CompoundType::Function(FunctionType { ret, .. }) = &*ty
    {
        *ret
    } else {
        tys[0]
    };

    pass_args_to_regs(ctx, &tys[1..], &args[1..])?;

    let sz = ctx.isa.data_layout().get_size_of(ctx.types, result_ty) / 4;
    let output;
    let result_reg: Vec<Reg>;
    let mut operands = vec![];
    if sz > 1 {
        output = new_empty_str_inst_output(ctx, result_ty, id);
        result_reg = [GR::R0.into(), GR::R1.into(), GR::R2.into(), GR::R3.into()].to_vec();
        for idx in 0..sz {
            operands.push(MO::implicit_output(result_reg[idx].into()));
        }
    } else {
        output = new_empty_inst_output(ctx, result_ty, id);
        result_reg = [GR::R0.into()].to_vec();
        operands.push(MO::implicit_output(result_reg[0].into()));
    }
    operands.push(MO::new(OperandData::Label(name)));

    ctx.inst_seq.push(MachInstruction::new(
        InstructionData { opcode, operands },
        ctx.block_map[&ctx.cur_block],
    ));

    if !ctx.ir_data.users_of(id).is_empty() {
        let opcode = Opcode::MOVrr;
        for idx in 0..sz {
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode,
                    operands: vec![
                        MO::output(output[idx].into()),
                        MO::input(result_reg[idx].into()),
                    ],
                },
                ctx.block_map[&ctx.cur_block],
            ));
        }
    }

    Ok(())
}

fn pass_args_to_regs(ctx: &mut LoweringContext<Ola>, tys: &[Type], args: &[ValueId]) -> Result<()> {
    let gpru = RegInfo::str_arg_reg_list(&ctx.call_conv);
    let mut gpr_used = args.len();

    for (_, (&ty, &arg0)) in tys.iter().rev().zip(args.iter().rev()).enumerate() {
        debug_println!(
            "type pointer {:?},{:?},arg {:?}",
            ty.is_pointer(ctx.types),
            ty,
            arg0
        );
        assert!(ty.is_integer() || ty.is_pointer(ctx.types) || ty.is_array(ctx.types));
        if ty.is_array(ctx.types) {
            let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty) / 4;
            let e_ty = ctx.types.base().element(ty).unwrap();

            let arg = get_operands_for_val(ctx, ty, arg0)?;
            for idx in 0..sz {
                let reg = gpru[gpr_used].apply(&RegClass::for_type(ctx.types, e_ty));
                let opcode = match &arg[idx] {
                    OperandData::Int32(_) | OperandData::Int64(_) => Opcode::MOVri,
                    OperandData::Reg(_) | OperandData::VReg(_) => Opcode::MOVrr,
                    e => {
                        return Err(LoweringError::Todo(format!(
                            "Unsupported actual argument: {:?}",
                            e
                        ))
                        .into())
                    }
                };
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode,
                        operands: vec![MO::output(reg.into()), MO::input(arg[idx].clone())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
                gpr_used += 1;
            }
        } else {
            let arg = get_operand_for_val(ctx, ty, arg0)?;
            gpr_used -= 1;
            let out = gpru[gpr_used].apply(&RegClass::for_type(ctx.types, ty));

            // TODO: pointer with ref passing
            /* if ty.is_pointer(ctx.types) {
                match &ctx.ir_data.values[arg0] {
                    Value::Instruction(addr_id) => {
                        let opcode = ctx.ir_data.instructions[*addr_id].opcode;
                        if opcode == IrOpcode::GetElementPtr {
                            // ctx.mark_as_merged(*addr_id);
                        }
                    }
                    _ => return Err(LoweringError::Todo("Unsupported load pattern 1".into()).into()),
                }

                let fp: Reg = GR::R9.into();
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::ADDri,
                        operands: vec![
                            MO::output(out.into()),
                            MO::input(fp.into()),
                            MO::input((-3).into()),
                        ],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
                continue;
            } */

            let opcode = match &arg {
                OperandData::Int32(_) | OperandData::Int64(_) => Opcode::MOVri,
                OperandData::Reg(_) => Opcode::MOVrr,
                OperandData::VReg(vreg) => {
                    let ty = ctx.mach_data.vregs.type_for(*vreg);
                    let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty);
                    match sz {
                        4 | 8 => Opcode::MOVrr,
                        e => {
                            return Err(LoweringError::Todo(format!(
                                "Unsupported argument size: {:?}",
                                e
                            ))
                            .into())
                        }
                    }
                }
                e => {
                    return Err(
                        LoweringError::Todo(format!("Unsupported argument: {:?}", e)).into(),
                    )
                }
            };
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode,
                    operands: vec![MO::output(out.into()), MO::input(arg)],
                },
                ctx.block_map[&ctx.cur_block],
            ));
        }
    }

    Ok(())
}

fn pass_str_args_to_regs(
    ctx: &mut LoweringContext<Ola>,
    tys: &[Type],
    args: &[ValueId],
) -> Result<()> {
    let gpru = RegInfo::str_arg_reg_list(&ctx.call_conv);

    let mut arg_str = get_operands_for_val(ctx, tys[0], args[0])?;
    // sstore: [key,value]
    // sload: [key]
    // poseidion: [params]
    if args.len() > 1 {
        let v = get_operands_for_val(ctx, tys[0], args[1])?;
        arg_str.extend(v);
    }

    for (gpr_used, arg) in arg_str.iter().enumerate() {
        let cur_ty = ctx.types.base().element(tys[0]).unwrap();
        let out = gpru[gpr_used].apply(&RegClass::for_type(ctx.types, cur_ty));

        let opcode = match &arg {
            OperandData::Int32(_) | OperandData::Int64(_) => Opcode::MOVri,
            OperandData::Reg(_) => Opcode::MOVrr,
            OperandData::VReg(_) => Opcode::MOVrr,
            e => {
                return Err(
                    LoweringError::Todo(format!("Unsupported storage argument: {:?}", e)).into(),
                )
            }
        };
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode,
                operands: vec![MO::output(out.into()), MO::input(arg.clone())],
            },
            ctx.block_map[&ctx.cur_block],
        ));
    }

    Ok(())
}

pub fn lower_return(ctx: &mut LoweringContext<Ola>, arg: Option<(Type, ValueId)>) -> Result<()> {
    if let Some((ty, value)) = arg {
        let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty) / 4;
        if sz > 1 {
            let values = get_operands_for_val(ctx, ty, value)?;
            let ret_reg0: Reg = GR::R0.into();
            let ret_reg1: Reg = GR::R1.into();
            let ret_reg2: Reg = GR::R2.into();
            let ret_reg3: Reg = GR::R3.into();
            let res_reg: [Reg; 4] = [ret_reg0, ret_reg1, ret_reg2, ret_reg3];
            let opcode = match &values[0] {
                OperandData::Int32(_) | OperandData::Int64(_) => Opcode::MOVri,
                OperandData::VReg(_) => Opcode::MOVrr,
                e => {
                    return Err(LoweringError::Todo(format!(
                        "Unsupported return data type: {:?}",
                        e
                    ))
                    .into())
                }
            };
            for idx in 0..sz {
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode,
                        operands: vec![
                            MO::output(res_reg[idx].into()),
                            MO::input(values[idx].clone().into()),
                        ],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
        } else {
            debug_println!("lower return scalar");
            let vreg = get_vreg_for_val(ctx, ty, value)?;
            let sz = ctx.isa.data_layout().get_size_of(ctx.types, ty);
            assert!(ty.is_integer() || ty.is_pointer(ctx.types));
            let (reg, opcode) = match sz {
                4 | 8 => (GR::R0.into(), Opcode::MOVrr),
                _ => todo!(),
            };
            debug_println!("reg {:#?},vreg {:#?}, sz {}", reg, vreg, sz);
            ctx.inst_seq.push(MachInstruction::new(
                InstructionData {
                    opcode,
                    operands: vec![MO::output(OperandData::Reg(reg)), MO::input(vreg.into())],
                },
                ctx.block_map[&ctx.cur_block],
            ));
        }
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
