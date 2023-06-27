use super::{
    get_inst_output, get_operand_for_val, get_operands_for_val, new_empty_str_inst_output,
};
use crate::codegen::core::ir::{
    function::instruction::{InstructionId, Opcode as IrOpcode},
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

pub fn lower_insertvalue(
    ctx: &mut LoweringContext<Ola>,
    id: InstructionId,
    tys: &[Type],
    args: &[ValueId],
) -> Result<()> {
    println!("lower insertvalue");
    let value = get_operands_for_val(ctx, tys[0], args[0])?;
    let op_value = get_operand_for_val(ctx, tys[1], args[1])?;
    let elm_ty = ctx.types.base().element(tys[0]).unwrap();
    let op_idx = get_operand_for_val(ctx, elm_ty, args[2])?;

    let idx = match op_idx {
        OperandData::Int32(op_idx) => op_idx,
        e => {
            return Err(LoweringError::Todo(format!(
                "Unsupported extractvalue idx operand: {:?}",
                e
            ))
            .into())
        }
    };
    let mut output = vec![];
    for _ in 0..4 {
        output = new_empty_str_inst_output(ctx, elm_ty, id);
    }
    for ist_idx in 0..4 {
        let input = if ist_idx == idx {
            op_value.clone()
        } else {
            value[ist_idx as usize].clone()
        };
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::MOVrr,
                operands: vec![
                    MO::output(output[ist_idx as usize].into()),
                    MO::input(input),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ));
    }
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
    fn codegen_insertv_test() {
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

define i64 @insert(i64 %0) {
    entry:
      %a = alloca i64, align 8
      store i64 %0, ptr %a, align 4
      %1 = load i64, ptr %a, align 4
      %2 = add i64 %1, 1
      call void @builtin_range_check(i64 %2)
      %3 = insertvalue [4 x i64] [i64 10, i64 20, i64 30, i64 40], i64 %2, 2
      %4 = extractvalue [4 x i64] %3, 2
      ;call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %3)
      ret i64 %4
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
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "insert:
.LBL10_0:
  add r9 r9 1
  mstore [r9,-1] r1
  mload r1 [r9,-1]
  add r0 r1 1
  range r0
  mov r1 10
  mov r2 20
  mov r3 30
  mov r4 40
  mov r3 r0
  mov r0 r3
  add r9 r9 -1
  ret
"
        );
    }
}
