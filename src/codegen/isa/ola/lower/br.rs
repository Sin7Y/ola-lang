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
        register::GR,
        Ola,
    },
    lower::{LoweringContext, LoweringError},
    register::Reg,
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

// instructions selection pattern:
// eq/neq/gte ->
// {
//   eq tmp a b;/neq tmp a b;/gte tmp a,b;
//   cjmp tmp label;
// }
//
// gt ->
// a > b(a>=b && a!=b) =>
// {
//   gte tmp1 a b; neq tmp2 a b;
//   and tmp3 tmp1 tmp2;
//   cjmp tmp3 label
// }
// lt ->
//
// a < b(b>=a && a!=b) =>
// {
//   gte tmp1 b a; neq tmp2 a b;
//   and tmp3 tmp1 tmp2;
//   cjmp tmp3 label
// }
// lte ->
// a <= b(b>=a) =>
// {
//   gte tmp b,a;
//   cjmp tmp label
// }

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
        let output = new_empty_inst_output(ctx, *ty, icmp);
        match rhs {
            Value::Constant(ConstantValue::Int(ConstantInt::Int64(rhs))) => match cond {
                ICmpCond::Eq => {
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::EQri,
                            operands: vec![
                                MO::output(OperandData::VReg(output[0])),
                                MO::input(lhs.into()),
                                MO::new(rhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                ICmpCond::Ne => {
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::NEQ,
                            operands: vec![
                                MO::output(OperandData::VReg(output[0])),
                                MO::input(lhs.into()),
                                MO::new(rhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                ICmpCond::Sge | ICmpCond::Uge => {
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::GTE,
                            operands: vec![
                                MO::output(OperandData::VReg(output[0])),
                                MO::input(lhs.into()),
                                MO::new(rhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                ICmpCond::Sle | ICmpCond::Ule => {
                    let tmp_reg: Reg = GR::R7.into();
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::MOVri,
                            operands: vec![MO::output(tmp_reg.into()), MO::input(rhs.into())],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::GTE,
                            operands: vec![
                                MO::output(OperandData::VReg(output[0])),
                                MO::input(tmp_reg.into()),
                                MO::new(lhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
                ICmpCond::Slt | ICmpCond::Ult | ICmpCond::Sgt | ICmpCond::Ugt => {
                    let mut op0 = MO::new(lhs.into());
                    let mut op1 = MO::new(rhs.into());
                    if *cond == ICmpCond::Slt || *cond == ICmpCond::Ult {
                        op0 = MO::new(rhs.into());
                        op1 = MO::new(lhs.into());
                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::MOVri,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    op0.clone(),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));
                        op0 = MO::input(OperandData::VReg(output[0]));
                    }
                    let inst = MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::GTE,
                            operands: vec![MO::output(OperandData::VReg(output[0])), op0, op1],
                        },
                        ctx.block_map[&ctx.cur_block],
                    );
                    ctx.inst_seq.push(inst);
                    let output2 = ctx.mach_data.vregs.add_vreg_data(*ty);
                    ctx.inst_id_to_vreg.insert(icmp, vec![output2]);
                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::NEQ,
                            operands: vec![
                                MO::output(OperandData::VReg(output2)),
                                MO::input(lhs.into()),
                                MO::input(rhs.into()),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));

                    ctx.inst_seq.push(MachInstruction::new(
                        InstructionData {
                            opcode: Opcode::AND,
                            operands: vec![
                                MO::output(OperandData::VReg(output[0])),
                                MO::input_output(OperandData::VReg(output[0])),
                                MO::input(OperandData::VReg(output2)),
                            ],
                        },
                        ctx.block_map[&ctx.cur_block],
                    ));
                }
            },
            Value::Constant(ConstantValue::Null(_)) => {
                ctx.inst_seq.push(MachInstruction::new(
                    InstructionData {
                        opcode: Opcode::EQrr,
                        operands: vec![MO::input(lhs.into()), MO::new(0.into())],
                    },
                    ctx.block_map[&ctx.cur_block],
                ));
            }
            Value::Argument(_) | Value::Instruction(_) => {
                assert!(ty.is_i32() || ty.is_i64());
                let rhs_reg = get_operand_for_val(ctx, *ty, args[1])?;
                match cond {
                    ICmpCond::Eq => {
                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::EQrr,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input(lhs.into()),
                                    MO::input(rhs_reg.into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));
                    }
                    ICmpCond::Ne => {
                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::NEQ,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input(lhs.into()),
                                    MO::input(rhs_reg.into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));
                    }
                    ICmpCond::Sge | ICmpCond::Uge => {
                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::GTE,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input(lhs.into()),
                                    MO::input(rhs_reg.into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));
                    }
                    ICmpCond::Sle | ICmpCond::Ule => {
                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::GTE,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input(rhs_reg.into()),
                                    MO::input(lhs.into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));
                    }
                    ICmpCond::Sgt | ICmpCond::Ugt => {
                        let inst = MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::GTE,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input(lhs.into()),
                                    MO::input(rhs_reg.clone().into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        );
                        ctx.inst_seq.push(inst);
                        let output2 = ctx.mach_data.vregs.add_vreg_data(*ty);
                        ctx.inst_id_to_vreg.insert(icmp, vec![output2]);
                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::NEQ,
                                operands: vec![
                                    MO::output(OperandData::VReg(output2)),
                                    MO::input(lhs.into()),
                                    MO::input(rhs_reg.clone().into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));

                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::AND,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input_output(OperandData::VReg(output[0])),
                                    MO::input(OperandData::VReg(output2)),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));
                    }
                    ICmpCond::Slt | ICmpCond::Ult => {
                        let inst = MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::GTE,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input(rhs_reg.clone().into()),
                                    MO::input(lhs.into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        );
                        ctx.inst_seq.push(inst);
                        let output2 = ctx.mach_data.vregs.add_vreg_data(*ty);
                        ctx.inst_id_to_vreg.insert(icmp, vec![output2]);
                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::NEQ,
                                operands: vec![
                                    MO::output(OperandData::VReg(output2)),
                                    MO::input(lhs.into()),
                                    MO::input(rhs_reg.clone().into()),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));

                        ctx.inst_seq.push(MachInstruction::new(
                            InstructionData {
                                opcode: Opcode::AND,
                                operands: vec![
                                    MO::output(OperandData::VReg(output[0])),
                                    MO::input_output(OperandData::VReg(output[0])),
                                    MO::input(OperandData::VReg(output2)),
                                ],
                            },
                            ctx.block_map[&ctx.cur_block],
                        ));
                    }
                };
            }
            e => return Err(LoweringError::Todo(format!("Unsupported operand: {:?}", e)).into()),
        }

        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::CJMPr,
                operands: vec![
                    MO::input(output[0].into()),
                    MO::new(OperandData::Block(ctx.block_map[&blocks[0]])),
                ],
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

#[cfg(test)]
mod test {
    use crate::codegen::{
        core::ir::module::Module,
        isa::ola::{asm::AsmProgram, Ola},
        lower::compile_module,
    };
    #[test]
    fn codegen_eq_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'condCmp'
        source_filename = "test.ola"

        define void @main() {
        entry:
          %0 = call i32 @eq(i32 1)
          ret void
        }

        define i32 @eq(i32 %0) {
        entry:
          %1 = icmp eq i32 %0, 1
          br i1 %1, label %then, label %enif

        then:                                             ; preds = %entry
          ret i32 2

        enif:                                             ; preds = %entry
          ret i32 3
    }
"#;

        // Parse the assembly and get a module
        let module = Module::try_from(asm).expect("failed to parse LLVM IR");

        // Compile the module for Ola and get a machine module
        let isa = Ola::default();
        let mach_module = compile_module(&isa, &module).expect("failed to compile");

        // Display the machine module as assembly
        let code: AsmProgram =
            serde_json::from_str(mach_module.display_asm().to_string().as_str()).unwrap();
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
  call eq
  add r9 r9 -2
  end
eq:
.LBL1_0:
  mov r5 r1
  eq r5 r5 1
  cjmp r5 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  ret
.LBL1_2:
  mov r0 3
  ret
"
        );
    }

    #[test]
    fn codegen_ne_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'condCmp'
        source_filename = "test.ola"

        define void @main() {
        entry:
          %0 = call i32 @ne(i32 1)
          ret void
        }

        define i32 @ne(i32 %0) {
        entry:
          %1 = icmp ne i32 %0, 1
          br i1 %1, label %then, label %enif

        then:                                             ; preds = %entry
          ret i32 2

        enif:                                             ; preds = %entry
          ret i32 3
    }
"#;

        // Parse the assembly and get a module
        let module = Module::try_from(asm).expect("failed to parse LLVM IR");

        // Compile the module for Ola and get a machine module
        let isa = Ola::default();
        let mach_module = compile_module(&isa, &module).expect("failed to compile");

        // Display the machine module as assembly
        let code: AsmProgram =
            serde_json::from_str(mach_module.display_asm().to_string().as_str()).unwrap();
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
  call ne
  add r9 r9 -2
  end
ne:
.LBL1_0:
  mov r5 r1
  neq r5 r5 1
  cjmp r5 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  ret
.LBL1_2:
  mov r0 3
  ret
"
        );
    }

    #[test]
    fn codegen_ge_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'condCmp'
        source_filename = "test.ola"

        define void @main() {
        entry:
          %0 = call i32 @ge(i32 1)
          ret void
        }

        define i32 @ge(i32 %0) {
        entry:
          %1 = icmp uge i32 %0, 1
          br i1 %1, label %then, label %enif

        then:                                             ; preds = %entry
          ret i32 2

        enif:                                             ; preds = %entry
          ret i32 3
    }
"#;

        // Parse the assembly and get a module
        let module = Module::try_from(asm).expect("failed to parse LLVM IR");

        // Compile the module for Ola and get a machine module
        let isa = Ola::default();
        let mach_module = compile_module(&isa, &module).expect("failed to compile");

        // Display the machine module as assembly
        let code: AsmProgram =
            serde_json::from_str(mach_module.display_asm().to_string().as_str()).unwrap();
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
  call ge
  add r9 r9 -2
  end
ge:
.LBL1_0:
  mov r5 r1
  gte r5 r5 1
  cjmp r5 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  ret
.LBL1_2:
  mov r0 3
  ret
"
        );
    }

    #[test]
    fn codegen_gt_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'condCmp'
        source_filename = "test.ola"

        define void @main() {
        entry:
          %0 = call i32 @gt(i32 1)
          ret void
        }

        define i32 @gt(i32 %0) {
        entry:
          %1 = icmp ugt i32 %0, 1
          br i1 %1, label %then, label %enif

        then:                                             ; preds = %entry
          ret i32 2

        enif:                                             ; preds = %entry
          ret i32 3
    }
"#;

        // Parse the assembly and get a module
        let module = Module::try_from(asm).expect("failed to parse LLVM IR");

        // Compile the module for Ola and get a machine module
        let isa = Ola::default();
        let mach_module = compile_module(&isa, &module).expect("failed to compile");

        // Display the machine module as assembly
        let code: AsmProgram =
            serde_json::from_str(mach_module.display_asm().to_string().as_str()).unwrap();
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
  call gt
  add r9 r9 -2
  end
gt:
.LBL1_0:
  mov r5 r1
  gte r6 r5 1
  neq r5 r5 1
  and r6 r6 r5
  cjmp r6 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  ret
.LBL1_2:
  mov r0 3
  ret
"
        );
    }

    #[test]
    fn codegen_lt_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'condCmp'
        source_filename = "test.ola"

        define void @main() {
        entry:
          %0 = call i32 @lt(i32 1)
          ret void
        }

        define i32 @eq(i32 %0) {
        entry:
          %1 = icmp ult i32 %0, 1
          br i1 %1, label %then, label %enif

        then:                                             ; preds = %entry
          ret i32 2

        enif:                                             ; preds = %entry
          ret i32 3
    }
"#;

        // Parse the assembly and get a module
        let module = Module::try_from(asm).expect("failed to parse LLVM IR");

        // Compile the module for Ola and get a machine module
        let isa = Ola::default();
        let mach_module = compile_module(&isa, &module).expect("failed to compile");

        // Display the machine module as assembly
        let code: AsmProgram =
            serde_json::from_str(mach_module.display_asm().to_string().as_str()).unwrap();
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
  call lt
  add r9 r9 -2
  end
eq:
.LBL1_0:
  mov r5 r1
  mov r6 1
  gte r6 r6 r5
  neq r5 r5 1
  and r6 r6 r5
  cjmp r6 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  ret
.LBL1_2:
  mov r0 3
  ret
"
        );
    }

    #[test]
    fn codegen_le_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'condCmp'
        source_filename = "test.ola"

        define void @main() {
        entry:
          %0 = call i32 @le(i32 1)
          ret void
        }

        define i32 @le(i32 %0) {
        entry:
          %1 = icmp ule i32 %0, 1
          br i1 %1, label %then, label %enif

        then:                                             ; preds = %entry
          ret i32 2

        enif:                                             ; preds = %entry
          ret i32 3
    }
"#;

        // Parse the assembly and get a module
        let module = Module::try_from(asm).expect("failed to parse LLVM IR");

        // Compile the module for Ola and get a machine module
        let isa = Ola::default();
        let mach_module = compile_module(&isa, &module).expect("failed to compile");

        // Display the machine module as assembly
        let code: AsmProgram =
            serde_json::from_str(mach_module.display_asm().to_string().as_str()).unwrap();
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
  call le
  add r9 r9 -2
  end
le:
.LBL1_0:
  mov r5 r1
  mov r7 1
  gte r5 r7 r5
  cjmp r5 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  ret
.LBL1_2:
  mov r0 3
  ret
"
        );
    }
}
