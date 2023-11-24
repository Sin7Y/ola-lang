use super::{get_operand_for_val, get_operands_for_val, new_empty_inst_output};
use crate::codegen::core::ir::{function::instruction::InstructionId, types::Type, value::ValueId};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MO, OperandData},
        Ola,
    },
    lower::{LoweringContext, LoweringError},
};
use anyhow::Result;
use debug_print::debug_println;

pub fn lower_extractvalue(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    tys: &Type,
    args: &[ValueId],
) -> Result<()> {
    debug_println!("lower extractvalue");
    let value = get_operands_for_val(ctx, *tys, args[0])?;
    let elm_ty = ctx.types.base().element(*tys).unwrap();
    let op_idx = get_operand_for_val(ctx, elm_ty, args[1])?;

    let idx =
        match op_idx {
            OperandData::Int32(i) => i as usize,
            OperandData::Int64(i) => i as usize,
            e => {
                return Err(LoweringError::Todo(format!(
                    "Unsupported extractvalue idx operand: {:?}",
                    e
                ))
                .into())
            }
        };
    let output = new_empty_inst_output(ctx, elm_ty, id);

    let opcode =
        match value[idx as usize].clone() {
            OperandData::Int32(_) | OperandData::Int64(_) => Opcode::MOVri,
            OperandData::VReg(_) => Opcode::MOVrr,
            e => {
                return Err(LoweringError::Todo(format!(
                    "Unsupported extractvalue idx operand data type: {:?}",
                    e
                ))
                .into())
            }
        };

    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode,
            operands: vec![
                MO::output(output[0].into()),
                MO::input(value[idx as usize].clone()),
            ],
        },
        ctx.block_map[&ctx.cur_block],
    ));
    Ok(())
}

#[cfg(test)]
mod test {
    use crate::codegen::{
        core::ir::module::Module,
        isa::ola::{asm::AsmProgram, Ola},
        lower::compile_module,
    };
    #[test]
    fn codegen_extractv_var_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'StrImm'
source_filename = "examples/source/storage/storage_u32.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define i64 @get() {
    entry:
      %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
      %1 = extractvalue [4 x i64] %0, 2
      %2 = extractvalue [4 x i64] %0, 3
      %3 = add i32 %1, %2
      ret i64 %3
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
            "get:
.LBL10_0:
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r6 r4
  add r0 r5 r6
  ret
"
        );
    }

    #[test]
    fn codegen_extractv_imm_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'StrImm'
source_filename = "examples/source/storage/storage_u32.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define i64 @get1() {
    entry:
      %1 = extractvalue [4 x i64] [i64 1,i64 2,i64 3,i64 4], 0
      %2 = extractvalue [4 x i64] [i64 10,i64 20,i64 30,i64 40], 1
      %3 = extractvalue [4 x i64] [i64 5,i64 6,i64 7,i64 8], 2
      %4 = extractvalue [4 x i64] [i64 50,i64 60,i64 70,i64 80], 3
      %5 = add i64 %1, %2
      %6 = mul i64 %3, %4
      %7 = add i64 %5, %6
      
      ret i64 %7
}

define i64 @get2() {
    entry:
      %1 = extractvalue [4 x i64] [i64 10,i64 20,i64 30,i64 40], 0
      %2 = extractvalue [4 x i64] [i64 10,i64 20,i64 30,i64 40], 1
      %3 = extractvalue [4 x i64] [i64 10,i64 20,i64 30,i64 40], 2
      %4 = extractvalue [4 x i64] [i64 10,i64 20,i64 30,i64 40], 3
      %5 = add i64 %1, %2
      %6 = mul i64 %3, %4
      %7 = add i64 %5, %6
      
      ret i64 %7
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
        debug_println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "get1:
.LBL10_0:
  mov r7 1
  mov r8 20
  add r6 r7 r8
  mov r7 7
  mov r8 80
  mul r5 r7 r8
  add r0 r6 r5
  ret
get2:
.LBL11_0:
  mov r7 10
  mov r8 20
  add r6 r7 r8
  mov r7 30
  mov r8 40
  mul r5 r7 r8
  add r0 r6 r5
  ret
"
        );
    }
}
