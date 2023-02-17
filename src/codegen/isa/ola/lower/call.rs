use super::{get_operand_for_val, get_vreg_for_val, new_empty_inst_output};
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
use anyhow::Result;

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

fn pass_args_to_regs(ctx: &mut LoweringContext<Ola>, tys: &[Type], args: &[ValueId]) -> Result<()> {
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

pub fn lower_return(ctx: &mut LoweringContext<Ola>, arg: Option<(Type, ValueId)>) -> Result<()> {
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
