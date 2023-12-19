use super::{get_operand_for_val, new_empty_inst_output};
use crate::codegen::core::ir::{
    function::instruction::{GetElementPtr, InstructionId},
    value::Value,
};
use crate::codegen::{
    function::instruction::Instruction as MachInstruction,
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand as MOperand, OperandData},
        Ola,
    },
    lower::LoweringContext,
};
use anyhow::Result;
use debug_print::debug_println;

pub fn lower_gep(
    ctx: &mut LoweringContext<Ola>,
    self_id: InstructionId,
    gep: &GetElementPtr,
) -> Result<()> {
    let base = if let Value::Instruction(id) = &ctx.ir_data.values[gep.args[0]]
        && let Some(slot) = ctx.inst_id_to_slot_id.get(id).copied()
    {
        OperandData::Slot(slot)
    } else {
        get_operand_for_val(ctx, gep.tys[1], gep.args[0])?
    };

    // NOTE: addr = base + mul.0*idx.0 + mul.1*idx.1 + ...
    let mut indices = vec![]; // (mul, idx)
    let mut cur_ty = gep.tys[1];
    for (&arg, &arg_ty) in gep.args[1..].iter().zip(gep.tys[2..].iter()) {
        let idx = get_operand_for_val(ctx, arg_ty, arg)?;
        if cur_ty.is_struct(ctx.types) {
            debug_println!("gep struct");
            let layout = ctx
                .isa
                .data_layout
                .new_struct_layout_for(ctx.types, cur_ty)
                .unwrap();
            let idx = idx.sext_as_i64().unwrap() as usize;
            let offset = layout.get_elem_offset(idx).unwrap();
            if offset != 0 {
                indices.push((1 as i64, OperandData::Int64(offset as i64)));
            }
            cur_ty = ctx.types.base().element_at(cur_ty, idx).unwrap();
        } else {
            //cur_ty = ctx.types.get_element(cur_ty).unwrap();
            debug_println!("gep no struct");
            let sz = ctx.isa.data_layout.get_size_of(ctx.types, cur_ty) as i64;
            if let Some(idx) = idx.sext_as_i64() {
                if idx != 0 {
                    indices.push((1, OperandData::Int64(sz * idx)));
                }
            } else {
                indices.push((sz, idx));
            }
        }
    }

    let mut mem_slot = OperandData::None;
    let mut mem_imm = 0.into();
    let mut mem_rbase = OperandData::None;
    let mem_ridx = OperandData::None;
    let mem_mul = OperandData::None;

    if matches!(base, OperandData::Slot(_)) {
        mem_slot = base
    } else {
        mem_rbase = base
    }

    let mut simple_case = true;
    match &indices[..] {
        [] => {}
        [(1, x)] if x.sext_as_i64().is_some() => {
            // mem_imm = x.to_owned();
            let imm = x.sext_as_i64().unwrap();
            mem_imm = (imm / 4).into();
            debug_println!("gep mem_imm: {:?}", mem_imm);
        }
        [(_, x)] if x.sext_as_i64().is_some() => {
            unreachable!()
        }
        [(m, x)] if matches!(m, 1 | 2 | 4 | 8) => {
            mem_imm = x.to_owned();
            // mem_mul = (*m as i64).into();
            debug_println!("gep size {:?},idx {:?},imm {:?}", m, mem_ridx, mem_imm);
        }
        _ => simple_case = false,
    }

    let ty = ctx.types.base_mut().pointer(cur_ty);
    let output = new_empty_inst_output(ctx, ty, self_id);

    if simple_case {
        debug_println!(
            "gep simple case: mem_slot {:?},mem_imm {:?},mem_rbase {:?},mem_ridx {:?},mem_mul {:?}",
            mem_slot,
            mem_imm,
            mem_rbase,
            mem_ridx,
            mem_mul
        );
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::ADDrr,
                operands: vec![
                    MOperand::output(output[0].into()),
                    MOperand::input(mem_rbase),
                    MOperand::input(mem_imm),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        return Ok(());
    }

    ctx.inst_seq.push(MachInstruction::new(
        InstructionData {
            opcode: Opcode::MLOADr,
            operands: vec![
                MOperand::output(output[0].into()),
                MOperand::new(OperandData::MemStart),
                MOperand::new(OperandData::None),
                MOperand::new(mem_slot),
                MOperand::new(OperandData::None),
                MOperand::input(mem_rbase),
                MOperand::input(OperandData::None),
                MOperand::new(OperandData::None),
            ],
        },
        ctx.block_map[&ctx.cur_block],
    ));

    for (mul, idx) in indices {
        let mul_output = ctx.mach_data.vregs.add_vreg_data(ty);
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::MULrr,
                operands: vec![
                    MOperand::output(mul_output.into()),
                    MOperand::input(idx.into()),
                    MOperand::new(OperandData::Int64(mul)),
                ],
            },
            ctx.block_map[&ctx.cur_block],
        ));
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::ADDrr,
                operands: vec![
                    MOperand::output(output[0].into()),
                    MOperand::input(mul_output.into()),
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
    #[ignore]
    #[test]
    fn codegen_arr_php_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'ArraySortExample'
        source_filename = "examples/source/array/array_sort.ola"
        
        declare void @builtin_assert(i64, i64)
        
        declare void @builtin_range_check(i64)
        
        declare i64 @prophet_u32_sqrt(i64)
        
        declare i64 @prophet_u32_div(i64, i64)
        
        declare i64 @prophet_u32_mod(i64, i64)
        
        declare ptr @prophet_u32_array_sort(ptr, i64)
        
        declare ptr @prophet_malloc(i64)
        
        define void @main() {
        entry:
          %returned = alloca [10 x i64], align 8
          %source = alloca ptr, align 8
          %array_literal = alloca [10 x i64], align 8
          %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
          store i64 3, ptr %elemptr0, align 4
          %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
          store i64 4, ptr %elemptr1, align 4
          %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
          store i64 5, ptr %elemptr2, align 4
          %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
          store i64 1, ptr %elemptr3, align 4
          %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
          store i64 7, ptr %elemptr4, align 4
          %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
          store i64 9, ptr %elemptr5, align 4
          %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
          store i64 0, ptr %elemptr6, align 4
          %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
          store i64 2, ptr %elemptr7, align 4
          %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
          store i64 8, ptr %elemptr8, align 4
          %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
          store i64 6, ptr %elemptr9, align 4
          store ptr %array_literal, ptr %source, align 8
          %0 = load ptr, ptr %source, align 8
          %1 = call ptr @array_sort_test(ptr %0)
          store ptr %1, ptr %returned, align 8
          %2 = load ptr, ptr %returned, align 8
          call void @builtin_range_check(i64 9)
          %index_access = getelementptr [10 x i64], ptr %2, i64 0, i64 0
          %3 = load i64, ptr %index_access, align 4
          %4 = add i64 %3, 1
          call void @builtin_range_check(i64 %4)
          %5 = load ptr, ptr %returned, align 8
          call void @builtin_range_check(i64 9)
          %index_access1 = getelementptr [10 x i64], ptr %5, i64 0, i64 0
          store i64 %4, ptr %index_access1, align 4
          %6 = load ptr, ptr %returned, align 8
          call void @builtin_range_check(i64 8)
          %index_access2 = getelementptr [10 x i64], ptr %6, i64 0, i64 1
          %7 = load i64, ptr %index_access2, align 4
          %8 = sub i64 %7, 1
          call void @builtin_range_check(i64 %8)
          %9 = load ptr, ptr %returned, align 8
          call void @builtin_range_check(i64 8)
          %index_access3 = getelementptr [10 x i64], ptr %9, i64 0, i64 1
          store i64 %8, ptr %index_access3, align 4
          ret void
        }
        
        define ptr @array_sort_test(ptr %0) {
        entry:
          %array_sorted = alloca [10 x i64], align 8
          %source = alloca ptr, align 8
          store ptr %0, ptr %source, align 8
          %1 = load ptr, ptr %source, align 8
          %2 = call ptr @prophet_u32_array_sort(ptr %1, i64 10)
          store ptr %2, ptr %array_sorted, align 8
          %3 = load ptr, ptr %array_sorted, align 8
          ret ptr %3
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
    }

    #[test]
    fn codegen_array_test() {
        // LLVM Assembly
        let asm = r#"
        define i64 @test_array() #0 {
            %1 = alloca [3 x i64], align 4
            %2 = getelementptr inbounds [3 x i64], [3 x i64]* %1, i64 0, i64 0
            store i64 1, i64* %2, align 4
            %3 = getelementptr inbounds [3 x i64], [3 x i64]* %1, i64 0, i64 1
            store i64 2, i64* %3, align 4
            %4 = getelementptr inbounds [3 x i64], [3 x i64]* %1, i64 0, i64 2
            store i64 3, i64* %4, align 4
            %5 = getelementptr inbounds [3 x i64], [3 x i64]* %1, i64 0, i64 2
            %6 = load i64, i64* %5, align 4
            ret i64 %6
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
            "test_array:
.LBL0_0:
  add r9 r9 3
  mov r5 1
  mstore [r9,-3] r5
  mov r5 2
  mstore [r9,-2] r5
  mov r5 3
  mstore [r9,-1] r5
  mload r0 [r9,-1]
  add r9 r9 -3
  ret
"
        );
    }

    #[test]
    fn codegen_passing_ref_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'Array'
        source_filename = "examples/array.ola"
        
        declare void @builtin_assert(i64, i64)
        
        declare void @builtin_range_check(i64)
        
        declare i64 @prophet_u32_sqrt(i64)
        
        declare i64 @prophet_u32_div(i64, i64)
        
        declare i64 @prophet_u32_mod(i64, i64)
        
        declare i64* @prophet_u32_array_sort(i64*, i64)
        
        declare i64* @prophet_malloc(i64)
        
        ;declare i64 @array_literal(i64*)
        define i64 @array_literal(i64* %0) {
            entry:
              call void @builtin_range_check(i64 2)
              %1 = load i64, i64* %0, align 4
              ret i64 %1
            }
        
        define void @main() {
        entry:
          %array_literal = alloca [3 x i64], align 4
          %elemptr0 = getelementptr [3 x i64], [3 x i64]* %array_literal, i64 0, i64 0
          store i64 1, i64* %elemptr0, align 4
          %elemptr1 = getelementptr [3 x i64], [3 x i64]* %array_literal, i64 0, i64 1
          store i64 2, i64* %elemptr1, align 4
          %elemptr2 = getelementptr [3 x i64], [3 x i64]* %array_literal, i64 0, i64 2
          store i64 3, i64* %elemptr2, align 4
          %array_ptr = getelementptr [3 x i64], [3 x i64]* %array_literal, i64 0, i64 0
          %0 = call i64 @array_literal(i64* %array_ptr)
          ret void
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
            "array_literal:
.LBL7_0:
  mov r5 r1
  range 2
  mload r0 [r5]
  ret
main:
.LBL8_0:
  add r9 r9 5
  mstore [r9,-2] r9
  mov r5 1
  mstore [r9,-5] r5
  mov r5 2
  mstore [r9,-4] r5
  mov r5 3
  mstore [r9,-3] r5
  mload r1 [r9,-5]
  call array_literal
  add r9 r9 -5
  end
"
        );
    }

    #[test]
    fn codegen_passing_ref_ptr_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'Array'
        source_filename = "examples/array.ola"
        
        declare void @builtin_assert(i64, i64)
        
        declare void @builtin_range_check(i64)
        
        declare i64 @prophet_u32_sqrt(i64)
        
        declare i64 @prophet_u32_div(i64, i64)
        
        declare i64 @prophet_u32_mod(i64, i64)
        
        declare ptr @prophet_u32_array_sort(ptr, i64)
        
        declare ptr @prophet_malloc(i64)
        
        ;declare i64 @array_literal(ptr)
        define i64 @array_literal(ptr %0) {
            entry:
              call void @builtin_range_check(i64 2)
              %1 = load i64, ptr %0, align 4
              ret i64 %1
            }
        
        define void @main() {
        entry:
          %array_literal = alloca [3 x i64], align 4
          %elemptr0 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 0
          store i64 1, ptr %elemptr0, align 4
          %elemptr1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
          store i64 2, ptr %elemptr1, align 4
          %elemptr2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
          store i64 3, ptr %elemptr2, align 4
          %array_ptr = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 0
          %0 = call i64 @array_literal(ptr %array_ptr)
          ret void
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
            "array_literal:
.LBL7_0:
  mov r5 r1
  range 2
  mload r0 [r5]
  ret
main:
.LBL8_0:
  add r9 r9 5
  mstore [r9,-2] r9
  mov r5 1
  mstore [r9,-5] r5
  mov r5 2
  mstore [r9,-4] r5
  mov r5 3
  mstore [r9,-3] r5
  mload r1 [r9,-5]
  call array_literal
  add r9 r9 -5
  end
"
        );
    }

    #[test]
    fn codegen_array_pointer_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'ArraySortExample'
        source_filename = "examples/array_sort.ola"
        
        declare void @builtin_assert(i64, i64)
        
        declare void @builtin_range_check(i64)
        
        declare i64 @prophet_u32_sqrt(i64)
        
        declare i64 @prophet_u32_div(i64, i64)
        
        declare i64 @prophet_u32_mod(i64, i64)
        
        declare ptr @prophet_u32_array_sort(ptr, i64)
        
        declare ptr @prophet_malloc(i64)

        define void @main() {
            entry:
              %0 = alloca ptr, align 8
              %source = alloca ptr, align 8
              %array_literal = alloca [10 x i64], align 8
              %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
              store i64 3, ptr %elemptr0, align 4
              %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
              store i64 4, ptr %elemptr1, align 4
              %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
              store i64 5, ptr %elemptr2, align 4
              %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
              store i64 1, ptr %elemptr3, align 4
              %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
              store i64 7, ptr %elemptr4, align 4
              %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
              store i64 9, ptr %elemptr5, align 4
              %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
              store i64 0, ptr %elemptr6, align 4
              %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
              store i64 2, ptr %elemptr7, align 4
              %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
              store i64 8, ptr %elemptr8, align 4
              %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
              store i64 6, ptr %elemptr9, align 4
              store ptr %array_literal, ptr %source, align 8
              %1 = load ptr, ptr %source, align 8
              %2 = call ptr @array_sort_test(ptr %1)
              store ptr %2, ptr %0, align 8
              ret void
            }
                    
        define ptr @array_sort_test(ptr %0) {
        entry:
          %array_sorted = alloca ptr, align 8
          %source = alloca ptr, align 8
          store ptr %0, ptr %source, align 8
          %1 = load ptr, ptr %source, align 8
          %2 = call ptr @prophet_u32_array_sort(ptr %1, i64 10)
          store ptr %2, ptr %array_sorted, align 8
          %3 = load ptr, ptr %array_sorted, align 8
          ret ptr %3
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
            "main:
.LBL7_0:
  add r9 r9 14
  mstore [r9,-2] r9
  mov r5 3
  mstore [r9,-14] r5
  mov r5 4
  mstore [r9,-13] r5
  mov r5 5
  mstore [r9,-12] r5
  mov r5 1
  mstore [r9,-11] r5
  mov r5 7
  mstore [r9,-10] r5
  mov r5 9
  mstore [r9,-9] r5
  mov r5 0
  mstore [r9,-8] r5
  mov r5 2
  mstore [r9,-7] r5
  mov r5 8
  mstore [r9,-6] r5
  mov r5 6
  mstore [r9,-5] r5
  add r5 r9 -14
  mstore [r9,-4] r5
  mload r1 [r9,-4]
  call array_sort_test
  mov r5 r0
  mstore [r9,-3] r5
  add r9 r9 -14
  end
array_sort_test:
.LBL8_0:
  add r9 r9 2
  mov r5 r1
  mstore [r9,-2] r5
  mload r1 [r9,-2]
  mov r2 10
.PROPHET8_0:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  mstore [r9,-1] r5
  mload r0 [r9,-1]
  add r9 r9 -2
  ret
"
        );
    }

    #[test]
    fn codegen_vector_gep_var_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define void @main() {
entry:
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 5)
  %heap_ptr = sub i64 %0, 5
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 5
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr { i64, ptr }, ptr %int_to_ptr, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %1 = call ptr @vector_new_init(i64 5, ptr %int_to_ptr)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %2 = sub i64 %length, 1
  %3 = sub i64 %2, 0
  call void @builtin_range_check(i64 %3)
  %data = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access1 = getelementptr ptr, ptr %data, i64 0
  %4 = call i64 @vector_new(i64 2)
  %heap_ptr2 = sub i64 %4, 2
  %int_to_ptr3 = inttoptr i64 %heap_ptr2 to ptr
  %index_access4 = getelementptr i64, ptr %int_to_ptr3, i64 0
  store i64 66, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %int_to_ptr3, i64 1
  store i64 67, ptr %index_access5, align 4
  %5 = call ptr @vector_new_init(i64 2, ptr %int_to_ptr3)
  store ptr %5, ptr %index_access1, align 8
  store i64 1, ptr %i, align 4
  br label %cond6

cond6:                                            ; preds = %next, %done
  %6 = load i64, ptr %i, align 4
  %7 = icmp ult i64 %6, 5
  br i1 %7, label %body7, label %endfor

body7:                                            ; preds = %cond6
  %8 = load i64, ptr %i, align 4
  %vector_len8 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length9 = load i64, ptr %vector_len8, align 4
  %9 = sub i64 %length9, 1
  %10 = sub i64 %9, %8
  call void @builtin_range_check(i64 %10)
  %data10 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access11 = getelementptr ptr, ptr %data10, i64 %8
  %11 = call i64 @vector_new(i64 1)
  %heap_ptr12 = sub i64 %11, 1
  %int_to_ptr13 = inttoptr i64 %heap_ptr12 to ptr
  %index_access14 = getelementptr i64, ptr %int_to_ptr13, i64 0
  store i64 65, ptr %index_access14, align 4
  %12 = call ptr @vector_new_init(i64 1, ptr %int_to_ptr13)
  store ptr %12, ptr %index_access11, align 8
  br label %next

next:                                             ; preds = %body7
  %13 = load i64, ptr %i, align 4
  %14 = add i64 %13, 1
  store i64 %14, ptr %i, align 4
  br label %cond6

endfor:                                           ; preds = %cond6
  ret void
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
            "main:
"
        );
    }

    #[test]
    fn codegen_string_assert_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'AssertContract'
source_filename = "examples/source/assert/string_assert.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

define void @main() {
entry:
  ;%index = alloca i64, align 8
  %0 = call i64 @vector_new(i64 5)
  %heap_ptr = sub i64 %0, 5
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 0
  store i64 104, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %int_to_ptr, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %int_to_ptr, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %int_to_ptr, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %int_to_ptr, i64 4
  store i64 111, ptr %index_access4, align 4
  %1 = call ptr @vector_new_init(i64 5, ptr %int_to_ptr)
  %2 = call i64 @vector_new(i64 5)
  %heap_ptr5 = sub i64 %2, 5
  %int_to_ptr6 = inttoptr i64 %heap_ptr5 to ptr
  %index_access7 = getelementptr i64, ptr %int_to_ptr6, i64 0
  store i64 104, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %int_to_ptr6, i64 1
  store i64 101, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %int_to_ptr6, i64 2
  store i64 108, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %int_to_ptr6, i64 3
  store i64 108, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %int_to_ptr6, i64 4
  store i64 111, ptr %index_access11, align 4
  %3 = call ptr @vector_new_init(i64 5, ptr %int_to_ptr6)
  %data_ptr = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %length_ptr = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length = load i64, ptr %length_ptr, align 4
  %data_ptr12 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %length_ptr13 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length14 = load i64, ptr %length_ptr13, align 4
  call void @builtin_assert(i64 %length, i64 %length14)
  %index = alloca i64, align 8
  store i64 0, ptr %index, align 4
  br label %loop

loop:                                             ; preds = %loop, %entry
  %index15 = load i64, ptr %index, align 4
  %left_char_ptr = getelementptr i64, ptr %data_ptr, i64 %index15
  %right_char_ptr = getelementptr i64, ptr %data_ptr12, i64 %index15
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  call void @builtin_assert(i64 %left_char, i64 %right_char)
  %4 = icmp ult i64 %index15, %length
  %next_index = add i64 %index15, 1
  store i64 %next_index, ptr %index, align 4
  br i1 %4, label %loop, label %end

end:                                              ; preds = %loop
  ret void
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)


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
        debug_println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "vector_new_init:
.LBL7_0:
  add r9 r9 2
  mov r5 r1
  mov r6 r2
  mstore [r9,-2] r5
  mstore [r9,-1] r6
  add r0 r9 -2
  add r9 r9 -2
  ret
main:
.LBL8_0:
  add r9 r9 5
  mstore [r9,-2] r9
  mov r1 5
.PROPHET8_0:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  not r7 5
  add r7 r7 1
  add r2 r5 r7
  mov r5 104
  mstore [r2] r5
  mov r5 101
  mstore [r2,+1] r5
  mov r5 108
  mstore [r2,+2] r5
  mov r5 108
  mstore [r2,+3] r5
  mov r5 111
  mstore [r2,+4] r5
  mov r1 5
  call vector_new_init
  mov r5 r0
  mstore [r9,-5] r5
  mov r1 5
.PROPHET8_1:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  not r7 5
  add r7 r7 1
  add r5 r5 r7
  mstore [r9,-4] r5
  mload r2 [r9,-4]
  mov r5 104
  mstore [r2] r5
  mov r5 101
  mstore [r2,+1] r5
  mov r5 108
  mstore [r2,+2] r5
  mov r5 108
  mstore [r2,+3] r5
  mov r5 111
  mstore [r2,+4] r5
  mov r1 5
  call vector_new_init
  mov r5 r0
  mload r6 [r9,-5]
  mload r6 [r6,+1]
  mload r7 [r9,-5]
  mload r7 [r7]
  mload r8 [r5,+1]
  mload r5 [r5]
  assert r7 r5
  mov r5 0
  mstore [r9,-3] r5
  jmp .LBL8_1
.LBL8_1:
  mload r1 [r9,-3]
  mload r2 [r6,r1]
  mload r3 [r8,r1]
  assert r2 r3
  add r5 r1 1
  mstore [r9,-3] r5
  gte r5 r7 r1
  neq r1 r1 r7
  and r5 r5 r1
  cjmp r5 .LBL8_1
  jmp .LBL8_2
.LBL8_2:
  add r9 r9 -5
  end
"
        );
    }

    #[test]
    fn codegen_string_heap_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry:
  %index = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_start_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_start_ptr, align 4
  %1 = ptrtoint ptr %heap_start_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %3 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %3, 4
  %heap_start_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 3, ptr %heap_start_ptr2, align 4
  %4 = ptrtoint ptr %heap_start_ptr2 to i64
  %5 = add i64 %4, 1
  %vector_data3 = inttoptr i64 %5 to ptr
  %6 = call i64 @vector_new(i64 2)
  %heap_start4 = sub i64 %6, 2
  %heap_start_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 1, ptr %heap_start_ptr5, align 4
  %7 = ptrtoint ptr %heap_start_ptr5 to i64
  %8 = add i64 %7, 1
  %vector_data6 = inttoptr i64 %8 to ptr
  %index_access7 = getelementptr i64, ptr %vector_data6, i64 0
  store i64 65, ptr %index_access7, align 4
  %index_access8 = getelementptr ptr, ptr %vector_data3, i64 0
  store ptr %heap_start_ptr5, ptr %index_access8, align 8
  %9 = call i64 @vector_new(i64 2)
  %heap_start9 = sub i64 %9, 2
  %heap_start_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 1, ptr %heap_start_ptr10, align 4
  %10 = ptrtoint ptr %heap_start_ptr10 to i64
  %11 = add i64 %10, 1
  %vector_data11 = inttoptr i64 %11 to ptr
  %index_access12 = getelementptr i64, ptr %vector_data11, i64 0
  store i64 66, ptr %index_access12, align 4
  %index_access13 = getelementptr ptr, ptr %vector_data3, i64 1
  store ptr %heap_start_ptr10, ptr %index_access13, align 8
  %12 = call i64 @vector_new(i64 2)
  %heap_start14 = sub i64 %12, 2
  %heap_start_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 1, ptr %heap_start_ptr15, align 4
  %13 = ptrtoint ptr %heap_start_ptr15 to i64
  %14 = add i64 %13, 1
  %vector_data16 = inttoptr i64 %14 to ptr
  %index_access17 = getelementptr i64, ptr %vector_data16, i64 0
  store i64 67, ptr %index_access17, align 4
  %index_access18 = getelementptr ptr, ptr %vector_data3, i64 2
  store ptr %heap_start_ptr15, ptr %index_access18, align 8
  store i64 0, ptr %i, align 4
  br label %cond19

cond19:                                           ; preds = %next, %done
  %15 = load i64, ptr %i, align 4
  %16 = icmp ult i64 %15, 3
  br i1 %16, label %body20, label %endfor

body20:                                           ; preds = %cond19
  %17 = load i64, ptr %i, align 4
  %length = load i64, ptr %heap_start_ptr, align 4
  %18 = sub i64 %length, 1
  %19 = sub i64 %18, %17
  call void @builtin_range_check(i64 %19)
  %20 = ptrtoint ptr %heap_start_ptr to i64
  %21 = add i64 %20, 1
  %vector_data21 = inttoptr i64 %21 to ptr
  %index_access22 = getelementptr ptr, ptr %vector_data21, i64 %17
  %22 = load i64, ptr %i, align 4
  %length23 = load i64, ptr %heap_start_ptr2, align 4
  %23 = sub i64 %length23, 1
  %24 = sub i64 %23, %22
  call void @builtin_range_check(i64 %24)
  %25 = ptrtoint ptr %heap_start_ptr2 to i64
  %26 = add i64 %25, 1
  %vector_data24 = inttoptr i64 %26 to ptr
  %index_access25 = getelementptr ptr, ptr %vector_data24, i64 %22
  %27 = load ptr, ptr %index_access25, align 8
  store ptr %27, ptr %index_access22, align 8
  br label %next

next:                                             ; preds = %body20
  %28 = load i64, ptr %i, align 4
  %29 = add i64 %28, 1
  store i64 %29, ptr %i, align 4
  br label %cond19

endfor:                                           ; preds = %cond19
  %length26 = load i64, ptr %heap_start_ptr, align 4
  %30 = sub i64 %length26, 1
  %31 = sub i64 %30, 1
  call void @builtin_range_check(i64 %31)
  %32 = ptrtoint ptr %heap_start_ptr to i64
  %33 = add i64 %32, 1
  %vector_data27 = inttoptr i64 %33 to ptr
  %index_access28 = getelementptr ptr, ptr %vector_data27, i64 1
  %34 = load ptr, ptr %index_access28, align 8
  %35 = ptrtoint ptr %34 to i64
  %36 = add i64 %35, 1
  %vector_data29 = inttoptr i64 %36 to ptr
  %length30 = load i64, ptr %34, align 4
  %37 = call i64 @vector_new(i64 2)
  %heap_start31 = sub i64 %37, 2
  %heap_start_ptr32 = inttoptr i64 %heap_start31 to ptr
  store i64 1, ptr %heap_start_ptr32, align 4
  %38 = ptrtoint ptr %heap_start_ptr32 to i64
  %39 = add i64 %38, 1
  %vector_data33 = inttoptr i64 %39 to ptr
  %index_access34 = getelementptr i64, ptr %vector_data33, i64 0
  store i64 66, ptr %index_access34, align 4
  %40 = ptrtoint ptr %heap_start_ptr32 to i64
  %41 = add i64 %40, 1
  %vector_data35 = inttoptr i64 %41 to ptr
  %length36 = load i64, ptr %heap_start_ptr32, align 4
  call void @builtin_assert(i64 %length30, i64 %length36)
  store i64 0, ptr %index, align 4
  br label %cond37

cond37:                                           ; preds = %body38, %endfor
  %index40 = load i64, ptr %index, align 4
  %42 = icmp ult i64 %index40, %length30
  br i1 %42, label %body38, label %done39

body38:                                           ; preds = %cond37
  %left_char_ptr = getelementptr i64, ptr %vector_data29, i64 %index40
  %right_char_ptr = getelementptr i64, ptr %vector_data35, i64 %index40
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  call void @builtin_assert(i64 %left_char, i64 %right_char)
  %next_index41 = add i64 %index40, 1
  store i64 %next_index41, ptr %index, align 4
  br label %cond37

done39:                                           ; preds = %cond37
  ret void
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
        debug_println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL13_0:
  add r9 r9 14
  mov r1 4
.PROPHET13_0:
  mov r0 psp
  mload r0 [r0]
  mov r8 r0
  not r7 4
  add r7 r7 1
  add r5 r8 r7
  mov r7 3
  mstore [r5] r7
  mov r7 r5
  add r6 r7 1
  mov r7 0
  mstore [r9,-3] r7
  jmp .LBL13_1
.LBL13_1:
  mload r7 [r9,-3]
  mov r8 3
  gte r8 r8 r7
  neq r1 r7 3
  and r8 r8 r1
  cjmp r8 .LBL13_2
  jmp .LBL13_3
.LBL13_2:
  mov r1 0
  mstore [r6,r7] r1
  add r8 r7 1
  mstore [r9,-3] r8
  jmp .LBL13_1
.LBL13_3:
  mov r1 4
.PROPHET13_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r6 r1 r7
  mov r7 3
  mstore [r6] r7
  mov r1 2
.PROPHET13_2:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 2
  add r7 r7 1
  add r8 r1 r7
  mov r7 r8
  mov r8 1
  mstore [r7] r8
  mov r8 r7
  add r2 r8 1
  mov r8 r2
  mov r1 65
  mstore [r8] r1
  mov r8 r6
  add r3 r8 1
  mov r8 r3
  mstore [r8] r7
  mov r1 2
.PROPHET13_3:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 2
  add r7 r7 1
  add r7 r1 r7
  mstore [r9,-4] r7
  mload r7 [r9,-4]
  mov r1 1
  mstore [r7] r1
  mov r1 r7
  add r1 r1 1
  mstore [r9,-5] r1
  mload r1 [r9,-5]
  mov r2 66
  mstore [r1] r2
  mstore [r8,+1] r7
  mov r1 2
.PROPHET13_4:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 2
  add r7 r7 1
  add r7 r1 r7
  mstore [r9,-6] r7
  mload r7 [r9,-6]
  mov r1 1
  mstore [r7] r1
  mov r1 r7
  add r1 r1 1
  mstore [r9,-7] r1
  mload r1 [r9,-7]
  mov r2 67
  mstore [r1] r2
  mstore [r8,+2] r7
  mov r7 0
  mstore [r9,-2] r7
  jmp .LBL13_4
.LBL13_4:
  mload r7 [r9,-2]
  mov r8 3
  gte r8 r8 r7
  neq r7 r7 3
  and r8 r8 r7
  cjmp r8 .LBL13_5
  jmp .LBL13_7
.LBL13_5:
  mload r7 [r9,-2]
  mstore [r9,-10] r7
  mload r7 [r5]
  mstore [r9,-11] r7
  not r7 1
  add r7 r7 1
  mload r7 [r9,-11]
  add r8 r7 r7
  mload r7 [r9,-10]
  not r7 r7
  add r7 r7 1
  add r1 r8 r7
  range r1
  mload r8 [r9,-2]
  mload r1 [r6]
  not r7 1
  add r7 r7 1
  add r2 r1 r7
  not r7 r8
  add r7 r7 1
  add r3 r2 r7
  range r3
  mov r7 r6
  add r7 r7 1
  mstore [r9,-8] r7
  mload r7 [r9,-8]
  mload r7 [r7,r8]
  mov r8 r5
  add r8 r8 1
  mstore [r9,-9] r8
  mload r8 [r9,-9]
  mload r1 [r9,-10]
  mstore [r8,r1] r7
  jmp .LBL13_6
.LBL13_6:
  mload r8 [r9,-2]
  add r7 r8 1
  mstore [r9,-2] r7
  jmp .LBL13_4
.LBL13_7:
  mload r7 [r5]
  mstore [r9,-14] r7
  not r7 1
  add r7 r7 1
  mload r7 [r9,-14]
  add r6 r7 r7
  not r7 1
  add r7 r7 1
  add r8 r6 r7
  range r8
  add r1 r5 1
  mov r5 r1
  mload r5 [r5,+1]
  mov r6 r5
  add r2 r6 1
  mov r6 r2
  mload r5 [r5]
  mov r1 2
.PROPHET13_5:
  mov r0 psp
  mload r0 [r0]
  mov r8 r0
  not r7 2
  add r7 r7 1
  add r3 r8 r7
  mov r7 r3
  mov r8 1
  mstore [r7] r8
  mov r8 r7
  add r8 r8 1
  mstore [r9,-12] r8
  mload r8 [r9,-12]
  mov r1 66
  mstore [r8] r1
  mov r8 r7
  add r8 r8 1
  mstore [r9,-13] r8
  mload r8 [r9,-13]
  mload r7 [r7]
  assert r5 r7
  mov r7 0
  mstore [r9,-1] r7
  jmp .LBL13_8
.LBL13_8:
  mload r7 [r9,-1]
  gte r1 r5 r7
  neq r2 r7 r5
  and r1 r1 r2
  cjmp r1 .LBL13_9
  jmp .LBL13_10
.LBL13_9:
  mload r2 [r6,r7]
  mload r3 [r8,r7]
  assert r2 r3
  add r1 r7 1
  mstore [r9,-1] r1
  jmp .LBL13_8
.LBL13_10:
  add r9 r9 -14
  end
"
        );
    }

    #[test]
    fn codegen_string_heap2_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry: ;入口bb，alloca分配栈空间, 动态数组堆上：len赋值长度2，预留变量%vector_data指向堆数据首地址
  %index = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %heap_start = sub i64 %0, 3
  %heap_start_ptr = inttoptr i64 %heap_start to ptr
  store i64 2, ptr %heap_start_ptr, align 4
  %1 = ptrtoint ptr %heap_start_ptr to i64 ;%heap_start -> %heap_start_ptr -> %1 此处int -> ptr -> int 可以优化用原值，节省指令同时节省寄存器%1
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr ;[heap(data[0])] 预先计算数据区首地址，寄存器r6作为基址
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry ;循环条件bb,以循环索引变量%index_alloca判断跳转到循环主体body或结束done  寄存器r7
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value ;寻址 变址后的基址+index偏移寄存器 即r6+r7(r7循环索引可变量)，但为伪指令不生成指令
  store ptr null, ptr %index_access, align 8 ;循环主体循环两次，依次初始化 heap[data[0]] = 0  heap[data[1]] = 0 
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4 ;循环自增变量栈上分配，后增更新
  br label %cond

done:                                             ; preds = %cond
  %3 = call i64 @vector_new(i64 3)
  %heap_start1 = sub i64 %3, 3
  %heap_start_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 2, ptr %heap_start_ptr2, align 4
  %4 = ptrtoint ptr %heap_start_ptr2 to i64 ;同上，可优化删除
  %5 = add i64 %4, 1 ;?
  %vector_data3 = inttoptr i64 %5 to ptr ;同上[heap(data1[0])] 预先计算数据区首地址，寄存器rxxx作为基址  ???    r6
  %6 = call i64 @vector_new(i64 2)
  %heap_start4 = sub i64 %6, 2
  %heap_start_ptr5 = inttoptr i64 %heap_start4 to ptr ; [array] arr2基地址  [r7]
  store i64 1, ptr %heap_start_ptr5, align 4
  %7 = ptrtoint ptr %heap_start_ptr5 to i64  ;mov r8 r7
  %8 = add i64 %7, 1 ;add r2 r8 1
  %vector_data6 = inttoptr i64 %8 to ptr ;mov r8 r2
  %index_access7 = getelementptr i64, ptr %vector_data6, i64 0 [r8]
  store i64 65, ptr %index_access7, align 4
  %index_access8 = getelementptr ptr, ptr %vector_data3, i64 0
  store ptr %heap_start_ptr5, ptr %index_access8, align 8   heap[data2[0]] = [heap[string(65)]]
  %9 = call i64 @vector_new(i64 2)
  %heap_start9 = sub i64 %9, 2 ;r7
  %heap_start_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 1, ptr %heap_start_ptr10, align 4
  %10 = ptrtoint ptr %heap_start_ptr10 to i64
  %11 = add i64 %10, 1
  %vector_data11 = inttoptr i64 %11 to ptr
  %index_access12 = getelementptr i64, ptr %vector_data11, i64 0
  store i64 66, ptr %index_access12, align 4
  %index_access13 = getelementptr ptr, ptr %vector_data3, i64 1  ;[r6+1]
  store ptr %heap_start_ptr10, ptr %index_access13, align 8
  store i64 0, ptr %i, align 4
  br label %cond14

cond14:                                           ; preds = %next, %done
  %12 = load i64, ptr %i, align 4
  %13 = icmp ult i64 %12, 2
  br i1 %13, label %body15, label %endfor

body15:                                           ; preds = %cond14
  %14 = load i64, ptr %i, align 4 ;[r9-8]
  %length = load i64, ptr %heap_start_ptr, align 4 ;[r9-9]
  %15 = sub i64 %length, 1
  %16 = sub i64 %15, %14
  call void @builtin_range_check(i64 %16)
  %17 = ptrtoint ptr %heap_start_ptr to i64
  %18 = add i64 %17, 1
  %vector_data16 = inttoptr i64 %18 to ptr
  %index_access17 = getelementptr ptr, ptr %vector_data16, i64 %14
  %19 = load i64, ptr %i, align 4
  %length18 = load i64, ptr %heap_start_ptr2, align 4
  %20 = sub i64 %length18, 1
  %21 = sub i64 %20, %19
  call void @builtin_range_check(i64 %21)
  %22 = ptrtoint ptr %heap_start_ptr2 to i64
  %23 = add i64 %22, 1
  %vector_data19 = inttoptr i64 %23 to ptr
  %index_access20 = getelementptr ptr, ptr %vector_data19, i64 %19
  store ptr %index_access20, ptr %index_access17, align 8
  br label %next

next:                                             ; preds = %body15
  %24 = load i64, ptr %i, align 4
  %25 = add i64 %24, 1
  store i64 %25, ptr %i, align 4
  br label %cond14

endfor:                                           ; preds = %cond14
  %length21 = load i64, ptr %heap_start_ptr, align 4
  %26 = sub i64 %length21, 1
  %27 = sub i64 %26, 0
  call void @builtin_range_check(i64 %27)
  %28 = ptrtoint ptr %heap_start_ptr to i64
  %29 = add i64 %28, 1
  %vector_data22 = inttoptr i64 %29 to ptr
  %index_access23 = getelementptr ptr, ptr %vector_data22, i64 0
  %30 = ptrtoint ptr %index_access23 to i64
  %31 = add i64 %30, 1
  %vector_data24 = inttoptr i64 %31 to ptr
  %length25 = load i64, ptr %index_access23, align 4
  %32 = call i64 @vector_new(i64 2)
  %heap_start26 = sub i64 %32, 2
  %heap_start_ptr27 = inttoptr i64 %heap_start26 to ptr
  store i64 1, ptr %heap_start_ptr27, align 4
  %33 = ptrtoint ptr %heap_start_ptr27 to i64
  %34 = add i64 %33, 1
  %vector_data28 = inttoptr i64 %34 to ptr
  %index_access29 = getelementptr i64, ptr %vector_data28, i64 0
  store i64 65, ptr %index_access29, align 4
  %35 = ptrtoint ptr %heap_start_ptr27 to i64
  %36 = add i64 %35, 1
  %vector_data30 = inttoptr i64 %36 to ptr
  %length31 = load i64, ptr %heap_start_ptr27, align 4
  call void @builtin_assert(i64 %length25, i64 %length31)
  store i64 0, ptr %index, align 4
  br label %cond32

cond32:                                           ; preds = %body33, %endfor
  %index35 = load i64, ptr %index, align 4
  %37 = icmp ult i64 %index35, %length25
  br i1 %37, label %body33, label %done34

body33:                                           ; preds = %cond32
  %left_char_ptr = getelementptr i64, ptr %vector_data24, i64 %index35
  %right_char_ptr = getelementptr i64, ptr %vector_data30, i64 %index35
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  call void @builtin_assert(i64 %left_char, i64 %right_char)
  %next_index36 = add i64 %index35, 1
  store i64 %next_index36, ptr %index, align 4
  br label %cond32

done34:                                           ; preds = %cond32
  ret void
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
        debug_println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "vector_new_init:

"
        );
    }

    #[test]
    fn codegen_vote_stest() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'Voting'
        source_filename = "examples/source/storage/vote.ola"
        
        @heap_address = internal global i64 -4294967353
        
        declare void @builtin_assert(i64, i64)
        
        declare void @builtin_range_check(i64)
        
        declare i64 @prophet_u32_sqrt(i64)
        
        declare i64 @prophet_u32_div(i64, i64)
        
        declare i64 @prophet_u32_mod(i64, i64)
        
        declare ptr @prophet_u32_array_sort(ptr, i64)
        
        declare i64 @vector_new(i64)
        
        declare ptr @contract_input()
        
        declare [4 x i64] @get_storage([4 x i64])
        
        declare void @set_storage([4 x i64], [4 x i64])
        
        declare [4 x i64] @poseidon_hash([8 x i64])
        
        declare void @tape_store(i64, i64)
        
        declare i64 @tape_load(i64, i64)
        
        define void @contract_init(ptr %0) {
        entry:
          %1 = alloca [4 x i64], align 8
          %index_alloca11 = alloca i64, align 8
          %2 = alloca [4 x i64], align 8
          %index_alloca = alloca i64, align 8
          %struct_alloca = alloca { ptr, i64 }, align 8
          %i = alloca i64, align 8
          %proposalNames_ = alloca ptr, align 8
          store ptr %0, ptr %proposalNames_, align 8
          %3 = call [4 x i64] @get_caller()
          call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %3)
          store i64 0, ptr %i, align 4
          br label %cond
        
        cond:                                             ; preds = %next, %entry
          %4 = load i64, ptr %i, align 4
          %length = load i64, ptr %proposalNames_, align 4
          %5 = icmp ult i64 %4, %length
          br i1 %5, label %body, label %endfor
        
        body:                                             ; preds = %cond
          %6 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %7 = extractvalue [4 x i64] %6, 3
          %8 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %9 = extractvalue [4 x i64] %8, 3
          %10 = add i64 %9, %7
          %11 = insertvalue [4 x i64] %8, i64 %10, 3
          %"struct member" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
          %12 = load i64, ptr %i, align 4
          %length1 = load i64, ptr %proposalNames_, align 4
          %13 = sub i64 %length1, 1
          %14 = sub i64 %13, %12
          call void @builtin_range_check(i64 %14)
          %15 = ptrtoint ptr %proposalNames_ to i64
          %16 = add i64 %15, 1
          %vector_data = inttoptr i64 %16 to ptr
          %index_access = getelementptr ptr, ptr %vector_data, i64 %12
          %17 = load ptr, ptr %index_access, align 8
          store ptr %17, ptr %"struct member", align 8
          %"struct member2" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
          store i64 0, ptr %"struct member2", align 4
          %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
          %length3 = load i64, ptr %name, align 4
          %18 = call [4 x i64] @get_storage([4 x i64] %11)
          %19 = extractvalue [4 x i64] %18, 3
          %20 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length3, 3
          call void @set_storage([4 x i64] %11, [4 x i64] %20)
          %21 = extractvalue [4 x i64] %11, 0
          %22 = extractvalue [4 x i64] %11, 1
          %23 = extractvalue [4 x i64] %11, 2
          %24 = extractvalue [4 x i64] %11, 3
          %25 = insertvalue [8 x i64] undef, i64 %24, 7
          %26 = insertvalue [8 x i64] %25, i64 %23, 6
          %27 = insertvalue [8 x i64] %26, i64 %22, 5
          %28 = insertvalue [8 x i64] %27, i64 %21, 4
          %29 = insertvalue [8 x i64] %28, i64 0, 3
          %30 = insertvalue [8 x i64] %29, i64 0, 2
          %31 = insertvalue [8 x i64] %30, i64 0, 1
          %32 = insertvalue [8 x i64] %31, i64 0, 0
          %33 = call [4 x i64] @poseidon_hash([8 x i64] %32)
          store i64 0, ptr %index_alloca, align 4
          store [4 x i64] %33, ptr %2, align 4
          br label %cond4
        
        next:                                             ; preds = %done10
          %34 = load i64, ptr %i, align 4
          %35 = add i64 %34, 1
          store i64 %35, ptr %i, align 4
          br label %cond
        
        endfor:                                           ; preds = %cond
          ret void
        
        cond4:                                            ; preds = %body5, %body
          %index_value = load i64, ptr %index_alloca, align 4
          %loop_cond = icmp ult i64 %index_value, %length3
          br i1 %loop_cond, label %body5, label %done
        
        body5:                                            ; preds = %cond4
          %36 = load [4 x i64], ptr %2, align 4
          %37 = ptrtoint ptr %name to i64
          %38 = add i64 %37, 1
          %vector_data6 = inttoptr i64 %38 to ptr
          %index_access7 = getelementptr i64, ptr %vector_data6, i64 %index_value
          %39 = load i64, ptr %index_access7, align 4
          %40 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %39, 3
          call void @set_storage([4 x i64] %36, [4 x i64] %40)
          %41 = extractvalue [4 x i64] %36, 3
          %42 = add i64 %41, 1
          %43 = insertvalue [4 x i64] %36, i64 %42, 3
          store [4 x i64] %43, ptr %2, align 4
          %next_index = add i64 %index_value, 1
          store i64 %next_index, ptr %index_alloca, align 4
          br label %cond4
        
        done:                                             ; preds = %cond4
          store i64 %length3, ptr %index_alloca11, align 4
          store [4 x i64] %33, ptr %1, align 4
          br label %cond8
        
        cond8:                                            ; preds = %body9, %done
          %index_value12 = load i64, ptr %index_alloca11, align 4
          %loop_cond13 = icmp ult i64 %index_value12, %19
          br i1 %loop_cond13, label %body9, label %done10
        
        body9:                                            ; preds = %cond8
          %44 = load [4 x i64], ptr %1, align 4
          call void @set_storage([4 x i64] %44, [4 x i64] zeroinitializer)
          %45 = extractvalue [4 x i64] %44, 3
          %46 = add i64 %45, 1
          %47 = insertvalue [4 x i64] %44, i64 %46, 3
          store [4 x i64] %47, ptr %1, align 4
          %next_index14 = add i64 %index_value12, 1
          store i64 %next_index14, ptr %index_alloca11, align 4
          br label %cond8
        
        done10:                                           ; preds = %cond8
          %48 = extractvalue [4 x i64] %11, 3
          %49 = add i64 %48, 1
          %50 = insertvalue [4 x i64] %11, i64 %49, 3
          %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
          %51 = load i64, ptr %voteCount, align 4
          %52 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %51, 3
          call void @set_storage([4 x i64] %50, [4 x i64] %52)
          %new_length = add i64 %7, 1
          %53 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
          call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2], [4 x i64] %53)
          br label %next
        }
        
        define void @vote_proposal(i64 %0) {
        entry:
          %sender = alloca i64, align 8
          %msgSender = alloca [4 x i64], align 8
          %proposal_ = alloca i64, align 8
          store i64 %0, ptr %proposal_, align 4
          %1 = call [4 x i64] @get_caller()
          store [4 x i64] %1, ptr %msgSender, align 4
          %2 = load [4 x i64], ptr %msgSender, align 4
          %3 = extractvalue [4 x i64] %2, 0
          %4 = extractvalue [4 x i64] %2, 1
          %5 = extractvalue [4 x i64] %2, 2
          %6 = extractvalue [4 x i64] %2, 3
          %7 = insertvalue [8 x i64] undef, i64 %6, 7
          %8 = insertvalue [8 x i64] %7, i64 %5, 6
          %9 = insertvalue [8 x i64] %8, i64 %4, 5
          %10 = insertvalue [8 x i64] %9, i64 %3, 4
          %11 = insertvalue [8 x i64] %10, i64 1, 3
          %12 = insertvalue [8 x i64] %11, i64 0, 2
          %13 = insertvalue [8 x i64] %12, i64 0, 1
          %14 = insertvalue [8 x i64] %13, i64 0, 0
          %15 = call [4 x i64] @poseidon_hash([8 x i64] %14)
          store [4 x i64] %15, ptr %sender, align 4
          %16 = load i64, ptr %sender, align 4
          %17 = add i64 %16, 0
          %18 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %17, 3
          call void @set_storage([4 x i64] %18, [4 x i64] [i64 0, i64 0, i64 0, i64 1])
          %19 = load i64, ptr %sender, align 4
          %20 = add i64 %19, 1
          %21 = load i64, ptr %proposal_, align 4
          %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %20, 3
          %23 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %21, 3
          call void @set_storage([4 x i64] %22, [4 x i64] %23)
          %24 = load i64, ptr %proposal_, align 4
          %25 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %26 = extractvalue [4 x i64] %25, 3
          %27 = sub i64 %26, 1
          %28 = sub i64 %27, %24
          call void @builtin_range_check(i64 %28)
          %29 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %30 = extractvalue [4 x i64] %29, 3
          %31 = add i64 %30, %24
          %32 = insertvalue [4 x i64] %29, i64 %31, 3
          %33 = extractvalue [4 x i64] %32, 3
          %34 = add i64 %33, 1
          %35 = insertvalue [4 x i64] %32, i64 %34, 3
          %36 = load i64, ptr %proposal_, align 4
          %37 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %38 = extractvalue [4 x i64] %37, 3
          %39 = sub i64 %38, 1
          %40 = sub i64 %39, %36
          call void @builtin_range_check(i64 %40)
          %41 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %42 = extractvalue [4 x i64] %41, 3
          %43 = add i64 %42, %36
          %44 = insertvalue [4 x i64] %41, i64 %43, 3
          %45 = extractvalue [4 x i64] %44, 3
          %46 = add i64 %45, 1
          %47 = insertvalue [4 x i64] %44, i64 %46, 3
          %48 = call [4 x i64] @get_storage([4 x i64] %47)
          %49 = extractvalue [4 x i64] %48, 3
          %50 = add i64 %49, 1
          call void @builtin_range_check(i64 %50)
          %51 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %50, 3
          call void @set_storage([4 x i64] %35, [4 x i64] %51)
          ret void
        }
        
        define i64 @winningProposal() {
        entry:
          %p = alloca i64, align 8
          %winningVoteCount = alloca i64, align 8
          %winningProposal_ = alloca i64, align 8
          store i64 0, ptr %winningProposal_, align 4
          store i64 0, ptr %winningVoteCount, align 4
          store i64 0, ptr %p, align 4
          br label %cond
        
        cond:                                             ; preds = %next, %entry
          %0 = load i64, ptr %p, align 4
          %1 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %2 = extractvalue [4 x i64] %1, 3
          %3 = icmp ult i64 %0, %2
          br i1 %3, label %body, label %endfor
        
        body:                                             ; preds = %cond
          %4 = load i64, ptr %p, align 4
          %5 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %6 = extractvalue [4 x i64] %5, 3
          %7 = sub i64 %6, 1
          %8 = sub i64 %7, %4
          call void @builtin_range_check(i64 %8)
          %9 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %10 = extractvalue [4 x i64] %9, 3
          %11 = add i64 %10, %4
          %12 = insertvalue [4 x i64] %9, i64 %11, 3
          %13 = extractvalue [4 x i64] %12, 3
          %14 = add i64 %13, 1
          %15 = insertvalue [4 x i64] %12, i64 %14, 3
          %16 = call [4 x i64] @get_storage([4 x i64] %15)
          %17 = extractvalue [4 x i64] %16, 3
          %18 = load i64, ptr %winningVoteCount, align 4
          %19 = icmp ugt i64 %17, %18
          br i1 %19, label %then, label %enif
        
        next:                                             ; preds = %enif
          %20 = load i64, ptr %p, align 4
          %21 = add i64 %20, 1
          store i64 %21, ptr %p, align 4
          br label %cond
        
        endfor:                                           ; preds = %cond
          %22 = load i64, ptr %winningProposal_, align 4
          ret i64 %22
        
        then:                                             ; preds = %body
          %23 = load i64, ptr %p, align 4
          %24 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %25 = extractvalue [4 x i64] %24, 3
          %26 = sub i64 %25, 1
          %27 = sub i64 %26, %23
          call void @builtin_range_check(i64 %27)
          %28 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %29 = extractvalue [4 x i64] %28, 3
          %30 = add i64 %29, %23
          %31 = insertvalue [4 x i64] %28, i64 %30, 3
          %32 = extractvalue [4 x i64] %31, 3
          %33 = add i64 %32, 1
          %34 = insertvalue [4 x i64] %31, i64 %33, 3
          %35 = call [4 x i64] @get_storage([4 x i64] %34)
          %36 = extractvalue [4 x i64] %35, 3
          %37 = load i64, ptr %p, align 4
          br label %enif
        
        enif:                                             ; preds = %then, %body
          br label %next
        }
        
        define ptr @getWinnerName() {
        entry:
          %0 = alloca [4 x i64], align 8
          %index_alloca = alloca i64, align 8
          %1 = call i64 @winningProposal()
          %2 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %3 = extractvalue [4 x i64] %2, 3
          %4 = sub i64 %3, 1
          %5 = sub i64 %4, %1
          call void @builtin_range_check(i64 %5)
          %6 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %7 = extractvalue [4 x i64] %6, 3
          %8 = add i64 %7, %1
          %9 = insertvalue [4 x i64] %6, i64 %8, 3
          %10 = extractvalue [4 x i64] %9, 3
          %11 = add i64 %10, 0
          %12 = insertvalue [4 x i64] %9, i64 %11, 3
          %13 = call [4 x i64] @get_storage([4 x i64] %12)
          %14 = extractvalue [4 x i64] %13, 3
          %size = mul i64 %14, 1
          %size_add_one = add i64 %size, 1
          %15 = call i64 @vector_new(i64 %size_add_one)
          %heap_start = sub i64 %15, %size_add_one
          %heap_start_ptr = inttoptr i64 %heap_start to ptr
          store i64 %14, ptr %heap_start_ptr, align 4
          %16 = extractvalue [4 x i64] %12, 0
          %17 = extractvalue [4 x i64] %12, 1
          %18 = extractvalue [4 x i64] %12, 2
          %19 = extractvalue [4 x i64] %12, 3
          %20 = insertvalue [8 x i64] undef, i64 %19, 7
          %21 = insertvalue [8 x i64] %20, i64 %18, 6
          %22 = insertvalue [8 x i64] %21, i64 %17, 5
          %23 = insertvalue [8 x i64] %22, i64 %16, 4
          %24 = insertvalue [8 x i64] %23, i64 0, 3
          %25 = insertvalue [8 x i64] %24, i64 0, 2
          %26 = insertvalue [8 x i64] %25, i64 0, 1
          %27 = insertvalue [8 x i64] %26, i64 0, 0
          %28 = call [4 x i64] @poseidon_hash([8 x i64] %27)
          store i64 0, ptr %index_alloca, align 4
          store [4 x i64] %28, ptr %0, align 4
          br label %cond
        
        cond:                                             ; preds = %body, %entry
          %index_value = load i64, ptr %index_alloca, align 4
          %loop_cond = icmp ult i64 %index_value, %14
          br i1 %loop_cond, label %body, label %done
        
        body:                                             ; preds = %cond
          %29 = load [4 x i64], ptr %0, align 4
          %30 = ptrtoint ptr %heap_start_ptr to i64
          %31 = add i64 %30, 1
          %vector_data = inttoptr i64 %31 to ptr
          %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
          %32 = call [4 x i64] @get_storage([4 x i64] %29)
          %33 = extractvalue [4 x i64] %32, 3
          store i64 %33, ptr %index_access, align 4
          store [4 x i64] %29, ptr %0, align 4
          %next_index = add i64 %index_value, 1
          store i64 %next_index, ptr %index_alloca, align 4
          br label %cond
        
        done:                                             ; preds = %cond
          ret ptr %heap_start_ptr
        }
        
        define [4 x i64] @get_caller() {
        entry:
          ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
        }
        
        define void @main() {
        entry:
          %index = alloca i64, align 8
          %0 = alloca [4 x i64], align 8
          %index_alloca104 = alloca i64, align 8
          %1 = alloca [4 x i64], align 8
          %index_alloca95 = alloca i64, align 8
          %2 = alloca [4 x i64], align 8
          %index_alloca86 = alloca i64, align 8
          %struct_alloca = alloca { ptr, i64 }, align 8
          %i = alloca i64, align 8
          %index_alloca = alloca i64, align 8
          %3 = call i64 @vector_new(i64 4)
          %heap_start = sub i64 %3, 4
          %heap_start_ptr = inttoptr i64 %heap_start to ptr
          store i64 3, ptr %heap_start_ptr, align 4
          %4 = ptrtoint ptr %heap_start_ptr to i64
          %5 = add i64 %4, 1
          %vector_data = inttoptr i64 %5 to ptr
          store i64 0, ptr %index_alloca, align 4
          br label %cond
        
        cond:                                             ; preds = %body, %entry
          %index_value = load i64, ptr %index_alloca, align 4
          %loop_cond = icmp ult i64 %index_value, 3
          br i1 %loop_cond, label %body, label %done
        
        body:                                             ; preds = %cond
          %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
          store ptr null, ptr %index_access, align 8
          %next_index = add i64 %index_value, 1
          store i64 %next_index, ptr %index_alloca, align 4
          br label %cond
        
        done:                                             ; preds = %cond
          %length = load i64, ptr %heap_start_ptr, align 4
          %6 = sub i64 %length, 1
          %7 = sub i64 %6, 0
          call void @builtin_range_check(i64 %7)
          %8 = ptrtoint ptr %heap_start_ptr to i64
          %9 = add i64 %8, 1
          %vector_data1 = inttoptr i64 %9 to ptr
          %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
          %10 = call i64 @vector_new(i64 11)
          %heap_start3 = sub i64 %10, 11
          %heap_start_ptr4 = inttoptr i64 %heap_start3 to ptr
          store i64 10, ptr %heap_start_ptr4, align 4
          %11 = ptrtoint ptr %heap_start_ptr4 to i64
          %12 = add i64 %11, 1
          %vector_data5 = inttoptr i64 %12 to ptr
          %index_access6 = getelementptr i64, ptr %vector_data5, i64 0
          store i64 80, ptr %index_access6, align 4
          %13 = ptrtoint ptr %heap_start_ptr4 to i64
          %14 = add i64 %13, 1
          %vector_data7 = inttoptr i64 %14 to ptr
          %index_access8 = getelementptr i64, ptr %vector_data7, i64 1
          store i64 114, ptr %index_access8, align 4
          %15 = ptrtoint ptr %heap_start_ptr4 to i64
          %16 = add i64 %15, 1
          %vector_data9 = inttoptr i64 %16 to ptr
          %index_access10 = getelementptr i64, ptr %vector_data9, i64 2
          store i64 111, ptr %index_access10, align 4
          %17 = ptrtoint ptr %heap_start_ptr4 to i64
          %18 = add i64 %17, 1
          %vector_data11 = inttoptr i64 %18 to ptr
          %index_access12 = getelementptr i64, ptr %vector_data11, i64 3
          store i64 112, ptr %index_access12, align 4
          %19 = ptrtoint ptr %heap_start_ptr4 to i64
          %20 = add i64 %19, 1
          %vector_data13 = inttoptr i64 %20 to ptr
          %index_access14 = getelementptr i64, ptr %vector_data13, i64 4
          store i64 111, ptr %index_access14, align 4
          %21 = ptrtoint ptr %heap_start_ptr4 to i64
          %22 = add i64 %21, 1
          %vector_data15 = inttoptr i64 %22 to ptr
          %index_access16 = getelementptr i64, ptr %vector_data15, i64 5
          store i64 115, ptr %index_access16, align 4
          %23 = ptrtoint ptr %heap_start_ptr4 to i64
          %24 = add i64 %23, 1
          %vector_data17 = inttoptr i64 %24 to ptr
          %index_access18 = getelementptr i64, ptr %vector_data17, i64 6
          store i64 97, ptr %index_access18, align 4
          %25 = ptrtoint ptr %heap_start_ptr4 to i64
          %26 = add i64 %25, 1
          %vector_data19 = inttoptr i64 %26 to ptr
          %index_access20 = getelementptr i64, ptr %vector_data19, i64 7
          store i64 108, ptr %index_access20, align 4
          %27 = ptrtoint ptr %heap_start_ptr4 to i64
          %28 = add i64 %27, 1
          %vector_data21 = inttoptr i64 %28 to ptr
          %index_access22 = getelementptr i64, ptr %vector_data21, i64 8
          store i64 32, ptr %index_access22, align 4
          %29 = ptrtoint ptr %heap_start_ptr4 to i64
          %30 = add i64 %29, 1
          %vector_data23 = inttoptr i64 %30 to ptr
          %index_access24 = getelementptr i64, ptr %vector_data23, i64 9
          store i64 49, ptr %index_access24, align 4
          store ptr %heap_start_ptr4, ptr %index_access2, align 8
          %length25 = load i64, ptr %heap_start_ptr, align 4
          %31 = sub i64 %length25, 1
          %32 = sub i64 %31, 1
          call void @builtin_range_check(i64 %32)
          %33 = ptrtoint ptr %heap_start_ptr to i64
          %34 = add i64 %33, 1
          %vector_data26 = inttoptr i64 %34 to ptr
          %index_access27 = getelementptr ptr, ptr %vector_data26, i64 1
          %35 = call i64 @vector_new(i64 11)
          %heap_start28 = sub i64 %35, 11
          %heap_start_ptr29 = inttoptr i64 %heap_start28 to ptr
          store i64 10, ptr %heap_start_ptr29, align 4
          %36 = ptrtoint ptr %heap_start_ptr29 to i64
          %37 = add i64 %36, 1
          %vector_data30 = inttoptr i64 %37 to ptr
          %index_access31 = getelementptr i64, ptr %vector_data30, i64 0
          store i64 80, ptr %index_access31, align 4
          %38 = ptrtoint ptr %heap_start_ptr29 to i64
          %39 = add i64 %38, 1
          %vector_data32 = inttoptr i64 %39 to ptr
          %index_access33 = getelementptr i64, ptr %vector_data32, i64 1
          store i64 114, ptr %index_access33, align 4
          %40 = ptrtoint ptr %heap_start_ptr29 to i64
          %41 = add i64 %40, 1
          %vector_data34 = inttoptr i64 %41 to ptr
          %index_access35 = getelementptr i64, ptr %vector_data34, i64 2
          store i64 111, ptr %index_access35, align 4
          %42 = ptrtoint ptr %heap_start_ptr29 to i64
          %43 = add i64 %42, 1
          %vector_data36 = inttoptr i64 %43 to ptr
          %index_access37 = getelementptr i64, ptr %vector_data36, i64 3
          store i64 112, ptr %index_access37, align 4
          %44 = ptrtoint ptr %heap_start_ptr29 to i64
          %45 = add i64 %44, 1
          %vector_data38 = inttoptr i64 %45 to ptr
          %index_access39 = getelementptr i64, ptr %vector_data38, i64 4
          store i64 111, ptr %index_access39, align 4
          %46 = ptrtoint ptr %heap_start_ptr29 to i64
          %47 = add i64 %46, 1
          %vector_data40 = inttoptr i64 %47 to ptr
          %index_access41 = getelementptr i64, ptr %vector_data40, i64 5
          store i64 115, ptr %index_access41, align 4
          %48 = ptrtoint ptr %heap_start_ptr29 to i64
          %49 = add i64 %48, 1
          %vector_data42 = inttoptr i64 %49 to ptr
          %index_access43 = getelementptr i64, ptr %vector_data42, i64 6
          store i64 97, ptr %index_access43, align 4
          %50 = ptrtoint ptr %heap_start_ptr29 to i64
          %51 = add i64 %50, 1
          %vector_data44 = inttoptr i64 %51 to ptr
          %index_access45 = getelementptr i64, ptr %vector_data44, i64 7
          store i64 108, ptr %index_access45, align 4
          %52 = ptrtoint ptr %heap_start_ptr29 to i64
          %53 = add i64 %52, 1
          %vector_data46 = inttoptr i64 %53 to ptr
          %index_access47 = getelementptr i64, ptr %vector_data46, i64 8
          store i64 32, ptr %index_access47, align 4
          %54 = ptrtoint ptr %heap_start_ptr29 to i64
          %55 = add i64 %54, 1
          %vector_data48 = inttoptr i64 %55 to ptr
          %index_access49 = getelementptr i64, ptr %vector_data48, i64 9
          store i64 50, ptr %index_access49, align 4
          store ptr %heap_start_ptr29, ptr %index_access27, align 8
          %length50 = load i64, ptr %heap_start_ptr, align 4
          %56 = sub i64 %length50, 1
          %57 = sub i64 %56, 2
          call void @builtin_range_check(i64 %57)
          %58 = ptrtoint ptr %heap_start_ptr to i64
          %59 = add i64 %58, 1
          %vector_data51 = inttoptr i64 %59 to ptr
          %index_access52 = getelementptr ptr, ptr %vector_data51, i64 2
          %60 = call i64 @vector_new(i64 11)
          %heap_start53 = sub i64 %60, 11
          %heap_start_ptr54 = inttoptr i64 %heap_start53 to ptr
          store i64 10, ptr %heap_start_ptr54, align 4
          %61 = ptrtoint ptr %heap_start_ptr54 to i64
          %62 = add i64 %61, 1
          %vector_data55 = inttoptr i64 %62 to ptr
          %index_access56 = getelementptr i64, ptr %vector_data55, i64 0
          store i64 80, ptr %index_access56, align 4
          %63 = ptrtoint ptr %heap_start_ptr54 to i64
          %64 = add i64 %63, 1
          %vector_data57 = inttoptr i64 %64 to ptr
          %index_access58 = getelementptr i64, ptr %vector_data57, i64 1
          store i64 114, ptr %index_access58, align 4
          %65 = ptrtoint ptr %heap_start_ptr54 to i64
          %66 = add i64 %65, 1
          %vector_data59 = inttoptr i64 %66 to ptr
          %index_access60 = getelementptr i64, ptr %vector_data59, i64 2
          store i64 111, ptr %index_access60, align 4
          %67 = ptrtoint ptr %heap_start_ptr54 to i64
          %68 = add i64 %67, 1
          %vector_data61 = inttoptr i64 %68 to ptr
          %index_access62 = getelementptr i64, ptr %vector_data61, i64 3
          store i64 112, ptr %index_access62, align 4
          %69 = ptrtoint ptr %heap_start_ptr54 to i64
          %70 = add i64 %69, 1
          %vector_data63 = inttoptr i64 %70 to ptr
          %index_access64 = getelementptr i64, ptr %vector_data63, i64 4
          store i64 111, ptr %index_access64, align 4
          %71 = ptrtoint ptr %heap_start_ptr54 to i64
          %72 = add i64 %71, 1
          %vector_data65 = inttoptr i64 %72 to ptr
          %index_access66 = getelementptr i64, ptr %vector_data65, i64 5
          store i64 115, ptr %index_access66, align 4
          %73 = ptrtoint ptr %heap_start_ptr54 to i64
          %74 = add i64 %73, 1
          %vector_data67 = inttoptr i64 %74 to ptr
          %index_access68 = getelementptr i64, ptr %vector_data67, i64 6
          store i64 97, ptr %index_access68, align 4
          %75 = ptrtoint ptr %heap_start_ptr54 to i64
          %76 = add i64 %75, 1
          %vector_data69 = inttoptr i64 %76 to ptr
          %index_access70 = getelementptr i64, ptr %vector_data69, i64 7
          store i64 108, ptr %index_access70, align 4
          %77 = ptrtoint ptr %heap_start_ptr54 to i64
          %78 = add i64 %77, 1
          %vector_data71 = inttoptr i64 %78 to ptr
          %index_access72 = getelementptr i64, ptr %vector_data71, i64 8
          store i64 32, ptr %index_access72, align 4
          %79 = ptrtoint ptr %heap_start_ptr54 to i64
          %80 = add i64 %79, 1
          %vector_data73 = inttoptr i64 %80 to ptr
          %index_access74 = getelementptr i64, ptr %vector_data73, i64 9
          store i64 51, ptr %index_access74, align 4
          store ptr %heap_start_ptr54, ptr %index_access52, align 8
          store i64 0, ptr %i, align 4
          br label %cond75
        
        cond75:                                           ; preds = %next, %done
          %81 = load i64, ptr %i, align 4
          %length77 = load i64, ptr %heap_start_ptr, align 4
          %82 = icmp ult i64 %81, %length77
          br i1 %82, label %body76, label %endfor
        
        body76:                                           ; preds = %cond75
          %83 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %84 = extractvalue [4 x i64] %83, 3
          %85 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %86 = extractvalue [4 x i64] %85, 3
          %87 = add i64 %86, %84
          %88 = insertvalue [4 x i64] %85, i64 %87, 3
          %"struct member" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
          %89 = load i64, ptr %i, align 4
          %length78 = load i64, ptr %heap_start_ptr, align 4
          %90 = sub i64 %length78, 1
          %91 = sub i64 %90, %89
          call void @builtin_range_check(i64 %91)
          %92 = ptrtoint ptr %heap_start_ptr to i64
          %93 = add i64 %92, 1
          %vector_data79 = inttoptr i64 %93 to ptr
          %index_access80 = getelementptr ptr, ptr %vector_data79, i64 %89
          %94 = load ptr, ptr %index_access80, align 8
          store ptr %94, ptr %"struct member", align 8
          %"struct member81" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
          store i64 0, ptr %"struct member81", align 4
          %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
          %length82 = load i64, ptr %name, align 4
          %95 = call [4 x i64] @get_storage([4 x i64] %88)
          %96 = extractvalue [4 x i64] %95, 3
          %97 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length82, 3
          call void @set_storage([4 x i64] %88, [4 x i64] %97)
          %98 = extractvalue [4 x i64] %88, 0
          %99 = extractvalue [4 x i64] %88, 1
          %100 = extractvalue [4 x i64] %88, 2
          %101 = extractvalue [4 x i64] %88, 3
          %102 = insertvalue [8 x i64] undef, i64 %101, 7
          %103 = insertvalue [8 x i64] %102, i64 %100, 6
          %104 = insertvalue [8 x i64] %103, i64 %99, 5
          %105 = insertvalue [8 x i64] %104, i64 %98, 4
          %106 = insertvalue [8 x i64] %105, i64 0, 3
          %107 = insertvalue [8 x i64] %106, i64 0, 2
          %108 = insertvalue [8 x i64] %107, i64 0, 1
          %109 = insertvalue [8 x i64] %108, i64 0, 0
          %110 = call [4 x i64] @poseidon_hash([8 x i64] %109)
          store i64 0, ptr %index_alloca86, align 4
          store [4 x i64] %110, ptr %2, align 4
          br label %cond83
        
        next:                                             ; preds = %done94
          %111 = load i64, ptr %i, align 4
          %112 = add i64 %111, 1
          store i64 %112, ptr %i, align 4
          br label %cond75
        
        endfor:                                           ; preds = %cond75
          %113 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
          %114 = extractvalue [4 x i64] %113, 3
          %115 = sub i64 %114, 1
          %116 = sub i64 %115, 1
          call void @builtin_range_check(i64 %116)
          %117 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
          %118 = extractvalue [4 x i64] %117, 3
          %119 = add i64 %118, 1
          %120 = insertvalue [4 x i64] %117, i64 %119, 3
          %121 = extractvalue [4 x i64] %120, 3
          %122 = add i64 %121, 0
          %123 = insertvalue [4 x i64] %120, i64 %122, 3
          %124 = call [4 x i64] @get_storage([4 x i64] %123)
          %125 = extractvalue [4 x i64] %124, 3
          %size = mul i64 %125, 1
          %size_add_one = add i64 %size, 1
          %126 = call i64 @vector_new(i64 %size_add_one)
          %heap_start99 = sub i64 %126, %size_add_one
          %heap_start_ptr100 = inttoptr i64 %heap_start99 to ptr
          store i64 %125, ptr %heap_start_ptr100, align 4
          %127 = extractvalue [4 x i64] %123, 0
          %128 = extractvalue [4 x i64] %123, 1
          %129 = extractvalue [4 x i64] %123, 2
          %130 = extractvalue [4 x i64] %123, 3
          %131 = insertvalue [8 x i64] undef, i64 %130, 7
          %132 = insertvalue [8 x i64] %131, i64 %129, 6
          %133 = insertvalue [8 x i64] %132, i64 %128, 5
          %134 = insertvalue [8 x i64] %133, i64 %127, 4
          %135 = insertvalue [8 x i64] %134, i64 0, 3
          %136 = insertvalue [8 x i64] %135, i64 0, 2
          %137 = insertvalue [8 x i64] %136, i64 0, 1
          %138 = insertvalue [8 x i64] %137, i64 0, 0
          %139 = call [4 x i64] @poseidon_hash([8 x i64] %138)
          store i64 0, ptr %index_alloca104, align 4
          store [4 x i64] %139, ptr %0, align 4
          br label %cond101
        
        cond83:                                           ; preds = %body84, %body76
          %index_value87 = load i64, ptr %index_alloca86, align 4
          %loop_cond88 = icmp ult i64 %index_value87, %length82
          br i1 %loop_cond88, label %body84, label %done85
        
        body84:                                           ; preds = %cond83
          %140 = load [4 x i64], ptr %2, align 4
          %141 = ptrtoint ptr %name to i64
          %142 = add i64 %141, 1
          %vector_data89 = inttoptr i64 %142 to ptr
          %index_access90 = getelementptr i64, ptr %vector_data89, i64 %index_value87
          %143 = load i64, ptr %index_access90, align 4
          %144 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %143, 3
          call void @set_storage([4 x i64] %140, [4 x i64] %144)
          %145 = extractvalue [4 x i64] %140, 3
          %146 = add i64 %145, 1
          %147 = insertvalue [4 x i64] %140, i64 %146, 3
          store [4 x i64] %147, ptr %2, align 4
          %next_index91 = add i64 %index_value87, 1
          store i64 %next_index91, ptr %index_alloca86, align 4
          br label %cond83
        
        done85:                                           ; preds = %cond83
          store i64 %length82, ptr %index_alloca95, align 4
          store [4 x i64] %110, ptr %1, align 4
          br label %cond92
        
        cond92:                                           ; preds = %body93, %done85
          %index_value96 = load i64, ptr %index_alloca95, align 4
          %loop_cond97 = icmp ult i64 %index_value96, %96
          br i1 %loop_cond97, label %body93, label %done94
        
        body93:                                           ; preds = %cond92
          %148 = load [4 x i64], ptr %1, align 4
          call void @set_storage([4 x i64] %148, [4 x i64] zeroinitializer)
          %149 = extractvalue [4 x i64] %148, 3
          %150 = add i64 %149, 1
          %151 = insertvalue [4 x i64] %148, i64 %150, 3
          store [4 x i64] %151, ptr %1, align 4
          %next_index98 = add i64 %index_value96, 1
          store i64 %next_index98, ptr %index_alloca95, align 4
          br label %cond92
        
        done94:                                           ; preds = %cond92
          %152 = extractvalue [4 x i64] %88, 3
          %153 = add i64 %152, 1
          %154 = insertvalue [4 x i64] %88, i64 %153, 3
          %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
          %155 = load i64, ptr %voteCount, align 4
          %156 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %155, 3
          call void @set_storage([4 x i64] %154, [4 x i64] %156)
          %new_length = add i64 %84, 1
          %157 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
          call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2], [4 x i64] %157)
          br label %next
        
        cond101:                                          ; preds = %body102, %endfor
          %index_value105 = load i64, ptr %index_alloca104, align 4
          %loop_cond106 = icmp ult i64 %index_value105, %125
          br i1 %loop_cond106, label %body102, label %done103
        
        body102:                                          ; preds = %cond101
          %158 = load [4 x i64], ptr %0, align 4
          %159 = ptrtoint ptr %heap_start_ptr100 to i64
          %160 = add i64 %159, 1
          %vector_data107 = inttoptr i64 %160 to ptr
          %index_access108 = getelementptr i64, ptr %vector_data107, i64 %index_value105
          %161 = call [4 x i64] @get_storage([4 x i64] %158)
          %162 = extractvalue [4 x i64] %161, 3
          store i64 %162, ptr %index_access108, align 4
          store [4 x i64] %158, ptr %0, align 4
          %next_index109 = add i64 %index_value105, 1
          store i64 %next_index109, ptr %index_alloca104, align 4
          br label %cond101
        
        done103:                                          ; preds = %cond101
          %163 = ptrtoint ptr %heap_start_ptr100 to i64
          %164 = add i64 %163, 1
          %vector_data110 = inttoptr i64 %164 to ptr
          %length111 = load i64, ptr %heap_start_ptr100, align 4
          %165 = call i64 @vector_new(i64 11)
          %heap_start112 = sub i64 %165, 11
          %heap_start_ptr113 = inttoptr i64 %heap_start112 to ptr
          store i64 10, ptr %heap_start_ptr113, align 4
          %166 = ptrtoint ptr %heap_start_ptr113 to i64
          %167 = add i64 %166, 1
          %vector_data114 = inttoptr i64 %167 to ptr
          %index_access115 = getelementptr i64, ptr %vector_data114, i64 0
          store i64 80, ptr %index_access115, align 4
          %168 = ptrtoint ptr %heap_start_ptr113 to i64
          %169 = add i64 %168, 1
          %vector_data116 = inttoptr i64 %169 to ptr
          %index_access117 = getelementptr i64, ptr %vector_data116, i64 1
          store i64 114, ptr %index_access117, align 4
          %170 = ptrtoint ptr %heap_start_ptr113 to i64
          %171 = add i64 %170, 1
          %vector_data118 = inttoptr i64 %171 to ptr
          %index_access119 = getelementptr i64, ptr %vector_data118, i64 2
          store i64 111, ptr %index_access119, align 4
          %172 = ptrtoint ptr %heap_start_ptr113 to i64
          %173 = add i64 %172, 1
          %vector_data120 = inttoptr i64 %173 to ptr
          %index_access121 = getelementptr i64, ptr %vector_data120, i64 3
          store i64 112, ptr %index_access121, align 4
          %174 = ptrtoint ptr %heap_start_ptr113 to i64
          %175 = add i64 %174, 1
          %vector_data122 = inttoptr i64 %175 to ptr
          %index_access123 = getelementptr i64, ptr %vector_data122, i64 4
          store i64 111, ptr %index_access123, align 4
          %176 = ptrtoint ptr %heap_start_ptr113 to i64
          %177 = add i64 %176, 1
          %vector_data124 = inttoptr i64 %177 to ptr
          %index_access125 = getelementptr i64, ptr %vector_data124, i64 5
          store i64 115, ptr %index_access125, align 4
          %178 = ptrtoint ptr %heap_start_ptr113 to i64
          %179 = add i64 %178, 1
          %vector_data126 = inttoptr i64 %179 to ptr
          %index_access127 = getelementptr i64, ptr %vector_data126, i64 6
          store i64 97, ptr %index_access127, align 4
          %180 = ptrtoint ptr %heap_start_ptr113 to i64
          %181 = add i64 %180, 1
          %vector_data128 = inttoptr i64 %181 to ptr
          %index_access129 = getelementptr i64, ptr %vector_data128, i64 7
          store i64 108, ptr %index_access129, align 4
          %182 = ptrtoint ptr %heap_start_ptr113 to i64
          %183 = add i64 %182, 1
          %vector_data130 = inttoptr i64 %183 to ptr
          %index_access131 = getelementptr i64, ptr %vector_data130, i64 8
          store i64 32, ptr %index_access131, align 4
          %184 = ptrtoint ptr %heap_start_ptr113 to i64
          %185 = add i64 %184, 1
          %vector_data132 = inttoptr i64 %185 to ptr
          %index_access133 = getelementptr i64, ptr %vector_data132, i64 9
          store i64 50, ptr %index_access133, align 4
          %186 = ptrtoint ptr %heap_start_ptr113 to i64
          %187 = add i64 %186, 1
          %vector_data134 = inttoptr i64 %187 to ptr
          %length135 = load i64, ptr %heap_start_ptr113, align 4
          call void @builtin_assert(i64 %length111, i64 %length135)
          store i64 0, ptr %index, align 4
          br label %cond136
        
        cond136:                                          ; preds = %body137, %done103
          %index139 = load i64, ptr %index, align 4
          %188 = icmp ult i64 %index139, %length111
          br i1 %188, label %body137, label %done138
        
        body137:                                          ; preds = %cond136
          %left_char_ptr = getelementptr i64, ptr %vector_data110, i64 %index139
          %right_char_ptr = getelementptr i64, ptr %vector_data134, i64 %index139
          %left_char = load i64, ptr %left_char_ptr, align 4
          %right_char = load i64, ptr %right_char_ptr, align 4
          call void @builtin_assert(i64 %left_char, i64 %right_char)
          %next_index140 = add i64 %index139, 1
          store i64 %next_index140, ptr %index, align 4
          br label %cond136
        
        done138:                                          ; preds = %cond136
          ret void
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
        debug_println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "vector_new_init:

"
        );
    }

    #[test]
    fn codegen_vote_v2_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_start_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_start_ptr, align 4
  %1 = ptrtoint ptr %heap_start_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_start_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_start_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 0
  store i64 65, ptr %index_access2, align 4
  %length3 = load i64, ptr %heap_start_ptr, align 4
  %7 = sub i64 %length3, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %9 = ptrtoint ptr %heap_start_ptr to i64
  %10 = add i64 %9, 1
  %vector_data4 = inttoptr i64 %10 to ptr
  %index_access5 = getelementptr i64, ptr %vector_data4, i64 1
  store i64 66, ptr %index_access5, align 4
  %length6 = load i64, ptr %heap_start_ptr, align 4
  %11 = sub i64 %length6, 1
  %12 = sub i64 %11, 2
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %heap_start_ptr to i64
  %14 = add i64 %13, 1
  %vector_data7 = inttoptr i64 %14 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 2
  store i64 67, ptr %index_access8, align 4
  store i64 0, ptr %i, align 4
  br label %cond9

cond9:                                            ; preds = %next, %done
  %15 = load i64, ptr %i, align 4
  %length11 = load i64, ptr %heap_start_ptr, align 4
  %16 = icmp ult i64 %15, %length11
  br i1 %16, label %body10, label %endfor

body10:                                           ; preds = %cond9
  %17 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %18 = extractvalue [4 x i64] %17, 3
  %19 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %20 = extractvalue [4 x i64] %19, 3
  %21 = mul i64 %18, 2
  %22 = add i64 %20, %21
  %23 = insertvalue [4 x i64] %19, i64 %22, 3
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %24 = load i64, ptr %i, align 4
  %length12 = load i64, ptr %heap_start_ptr, align 4
  %25 = sub i64 %length12, 1
  %26 = sub i64 %25, %24
  call void @builtin_range_check(i64 %26)
  %27 = ptrtoint ptr %heap_start_ptr to i64
  %28 = add i64 %27, 1
  %vector_data13 = inttoptr i64 %28 to ptr
  %index_access14 = getelementptr i64, ptr %vector_data13, i64 %24
  %29 = load i64, ptr %index_access14, align 4
  store i64 %29, ptr %"struct member", align 4
  %"struct member15" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %30 = load i64, ptr %i, align 4
  store i64 %30, ptr %"struct member15", align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %31 = load i64, ptr %name, align 4
  %32 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %31, 3
  call void @set_storage([4 x i64] %23, [4 x i64] %32)
  %33 = extractvalue [4 x i64] %23, 3
  %34 = add i64 %33, 1
  %35 = insertvalue [4 x i64] %23, i64 %34, 3
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %36 = load i64, ptr %voteCount, align 4
  %37 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %36, 3
  call void @set_storage([4 x i64] %35, [4 x i64] %37)
  %new_length = add i64 %18, 1
  %38 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %38)
  br label %next

next:                                             ; preds = %body10
  %39 = load i64, ptr %i, align 4
  %40 = add i64 %39, 1
  store i64 %40, ptr %i, align 4
  br label %cond9

endfor:                                           ; preds = %cond9
  %length16 = load i64, ptr %heap_start_ptr, align 4
  %41 = sub i64 %length16, 1
  %42 = sub i64 %41, 1
  call void @builtin_range_check(i64 %42)
  %43 = ptrtoint ptr %heap_start_ptr to i64
  %44 = add i64 %43, 1
  %vector_data17 = inttoptr i64 %44 to ptr
  %index_access18 = getelementptr i64, ptr %vector_data17, i64 1
  %45 = load i64, ptr %index_access18, align 4
  call void @builtin_assert(i64 %45, i64 66)
  ret void
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
        debug_println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL13_0:
  add r9 r9 23
  mov r1 4
.PROPHET13_0:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  not r7 4
  add r7 r7 1
  add r8 r5 r7
  mstore [r9,-5] r8
  mov r8 3
  mload r7 [r9,-5]
  mstore [r7] r8
  mload r8 [r9,-5]
  add r6 r8 1
  mov r8 r6
  mov r7 0
  mstore [r9,-4] r7
  jmp .LBL13_1
.LBL13_1:
  mload r7 [r9,-4]
  mov r6 3
  gte r6 r6 r7
  neq r5 r7 3
  and r6 r6 r5
  cjmp r6 .LBL13_2
  jmp .LBL13_3
.LBL13_2:
  mov r5 0
  mstore [r8,r7] r5
  add r6 r7 1
  mstore [r9,-4] r6
  jmp .LBL13_1
.LBL13_3:
  mload r7 [r9,-5]
  mload r7 [r7]
  mstore [r9,-9] r7
  not r7 1
  add r7 r7 1
  mload r7 [r9,-9]
  add r8 r7 r7
  not r7 0
  add r7 r7 1
  add r6 r8 r7
  range r6
  mload r8 [r9,-5]
  add r5 r8 1
  mov r8 r5
  mov r7 65
  mstore [r8] r7
  mload r8 [r9,-5]
  mload r8 [r8]
  not r7 1
  add r7 r7 1
  add r1 r8 r7
  not r7 1
  add r7 r7 1
  add r2 r1 r7
  range r2
  mload r8 [r9,-5]
  add r3 r8 1
  mov r8 r3
  mov r7 66
  mstore [r8,+1] r7
  mload r8 [r9,-5]
  mload r8 [r8]
  not r7 1
  add r7 r7 1
  add r8 r8 r7
  mstore [r9,-6] r8
  not r7 2
  add r7 r7 1
  mload r8 [r9,-6]
  add r8 r8 r7
  mstore [r9,-7] r8
  mload r8 [r9,-7]
  range r8
  mload r8 [r9,-5]
  add r8 r8 1
  mstore [r9,-8] r8
  mload r8 [r9,-8]
  mov r7 67
  mstore [r8,+2] r7
  mov r8 0
  mstore [r9,-3] r8
  jmp .LBL13_4
.LBL13_4:
  mload r8 [r9,-3]
  mload r7 [r9,-5]
  mload r7 [r7]
  gte r6 r7 r8
  neq r8 r8 r7
  and r6 r6 r8
  cjmp r6 .LBL13_5
  jmp .LBL13_7
.LBL13_5:
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sload 
  mov r8 r1
  mov r8 r2
  mov r8 r3
  mov r8 r4
  mstore [r9,-17] r8
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 0
  poseidon 
  mov r8 r4
  mload r6 [r9,-3]
  mload r7 [r9,-5]
  mload r5 [r7]
  not r7 1
  add r7 r7 1
  add r7 r5 r7
  mstore [r9,-10] r7
  not r7 r6
  add r7 r7 1
  mload r7 [r9,-10]
  add r7 r7 r7
  mstore [r9,-11] r7
  mload r7 [r9,-11]
  range r7
  mload r7 [r9,-5]
  add r7 r7 1
  mstore [r9,-12] r7
  mload r7 [r9,-12]
  mload r7 [r7,r6]
  mstore [r9,-2] r7
  mload r7 [r9,-3]
  mstore [r9,-1] r7
  mload r7 [r9,-2]
  mload r6 [r9,-17]
  mstore [r9,-18] r6
  mload r6 [r9,-18]
  mul r6 r6 2
  mstore [r9,-13] r6
  mload r6 [r9,-13]
  add r8 r8 r6
  mstore [r9,-14] r8
  mov r8 r1
  mstore [r9,-19] r8
  mov r8 r2
  mstore [r9,-20] r8
  mov r8 r3
  mstore [r9,-21] r8
  mload r8 [r9,-14]
  mov r8 r8
  mstore [r9,-22] r8
  mov r5 0
  mov r6 0
  mov r8 0
  mov r7 r7
  mstore [r9,-23] r7
  mload r7 [r9,-19]
  mov r1 r7
  mload r7 [r9,-20]
  mov r2 r7
  mload r7 [r9,-21]
  mov r3 r7
  mload r7 [r9,-22]
  mov r4 r7
  mov r7 r8
  mload r8 [r9,-23]
  sstore 
  mload r8 [r9,-1]
  mload r7 [r9,-22]
  add r7 r7 1
  mstore [r9,-15] r7
  mload r7 [r9,-19]
  mov r1 r7
  mload r7 [r9,-20]
  mov r2 r7
  mload r7 [r9,-21]
  mov r3 r7
  mload r7 [r9,-15]
  mov r4 r7
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 r8
  sstore 
  mload r8 [r9,-18]
  add r8 r8 1
  mstore [r9,-16] r8
  mov r5 0
  mov r6 0
  mov r7 0
  mload r8 [r9,-16]
  mov r8 r8
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sstore 
  jmp .LBL13_6
.LBL13_6:
  mload r7 [r9,-3]
  add r8 r7 1
  mstore [r9,-3] r8
  jmp .LBL13_4
.LBL13_7:
  mload r7 [r9,-5]
  mload r1 [r7]
  not r7 1
  add r7 r7 1
  add r8 r1 r7
  not r7 1
  add r7 r7 1
  add r6 r8 r7
  range r6
  mload r8 [r9,-5]
  add r5 r8 1
  mov r8 r5
  mload r8 [r8,+1]
  assert r8 66
  add r9 r9 -23
  end
"
        );
    }

    #[test]
    fn codegen_vote_v3_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @contract_init(ptr %0) {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %i = alloca i64, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %length = load i64, ptr %0, align 4
  %2 = icmp ult i64 %1, %length
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %4 = extractvalue [4 x i64] %3, 3
  %5 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %6 = extractvalue [4 x i64] %5, 3
  %7 = mul i64 %4, 2
  %8 = add i64 %6, %7
  %9 = insertvalue [4 x i64] %5, i64 %8, 3
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %10 = load i64, ptr %i, align 4
  %length1 = load i64, ptr %0, align 4
  %11 = sub i64 %length1, 1
  %12 = sub i64 %11, %10
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %0 to i64
  %14 = add i64 %13, 1
  %vector_data = inttoptr i64 %14 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %10
  %15 = load i64, ptr %index_access, align 4
  store i64 %15, ptr %"struct member", align 4
  %"struct member2" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member2", align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %16 = load i64, ptr %name, align 4
  %17 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %16, 3
  call void @set_storage([4 x i64] %9, [4 x i64] %17)
  %18 = extractvalue [4 x i64] %9, 3
  %19 = add i64 %18, 1
  %20 = insertvalue [4 x i64] %9, i64 %19, 3
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %21 = load i64, ptr %voteCount, align 4
  %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %21, 3
  call void @set_storage([4 x i64] %20, [4 x i64] %22)
  %new_length = add i64 %4, 1
  %23 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1], [4 x i64] %23)
  br label %next

next:                                             ; preds = %body
  %24 = load i64, ptr %i, align 4
  %25 = add i64 %24, 1
  store i64 %25, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
}

define void @main() {
entry:
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_start_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_start_ptr, align 4
  %1 = ptrtoint ptr %heap_start_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_start_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_start_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 0
  store i64 65, ptr %index_access2, align 4
  %length3 = load i64, ptr %heap_start_ptr, align 4
  %7 = sub i64 %length3, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %9 = ptrtoint ptr %heap_start_ptr to i64
  %10 = add i64 %9, 1
  %vector_data4 = inttoptr i64 %10 to ptr
  %index_access5 = getelementptr i64, ptr %vector_data4, i64 1
  store i64 66, ptr %index_access5, align 4
  %length6 = load i64, ptr %heap_start_ptr, align 4
  %11 = sub i64 %length6, 1
  %12 = sub i64 %11, 2
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %heap_start_ptr to i64
  %14 = add i64 %13, 1
  %vector_data7 = inttoptr i64 %14 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 2
  store i64 67, ptr %index_access8, align 4
  call void @contract_init(ptr %heap_start_ptr)
  %15 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1])
  %16 = extractvalue [4 x i64] %15, 3
  %17 = sub i64 %16, 1
  %18 = sub i64 %17, 1
  call void @builtin_range_check(i64 %18)
  %19 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %20 = extractvalue [4 x i64] %19, 3
  %21 = add i64 %20, 2
  %22 = insertvalue [4 x i64] %19, i64 %21, 3
  %23 = extractvalue [4 x i64] %22, 3
  %24 = add i64 %23, 0
  %25 = insertvalue [4 x i64] %22, i64 %24, 3
  %26 = call [4 x i64] @get_storage([4 x i64] %25)
  %27 = extractvalue [4 x i64] %26, 3
  call void @builtin_assert(i64 %27, i64 66)
  ret void
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
        debug_println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "contract_init:
.LBL13_0:
  add r9 r9 18
  mov r8 r1
  mstore [r9,-4] r8
  mov r8 0
  mstore [r9,-3] r8
  jmp .LBL13_1
.LBL13_1:
  mload r8 [r9,-3]
  mload r7 [r9,-4]
  mload r7 [r7]
  gte r6 r7 r8
  neq r8 r8 r7
  and r6 r6 r8
  cjmp r6 .LBL13_2
  jmp .LBL13_4
.LBL13_2:
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 1
  sload 
  mov r8 r1
  mov r8 r2
  mov r8 r3
  mov r8 r4
  mstore [r9,-12] r8
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 1
  poseidon 
  mov r8 r4
  mload r6 [r9,-3]
  mload r7 [r9,-4]
  mload r5 [r7]
  not r7 1
  add r7 r7 1
  add r7 r5 r7
  mstore [r9,-5] r7
  not r7 r6
  add r7 r7 1
  mload r7 [r9,-5]
  add r7 r7 r7
  mstore [r9,-6] r7
  mload r7 [r9,-6]
  range r7
  mload r7 [r9,-4]
  add r7 r7 1
  mstore [r9,-7] r7
  mload r7 [r9,-7]
  mload r7 [r7,r6]
  mstore [r9,-2] r7
  mov r7 0
  mstore [r9,-1] r7
  mload r7 [r9,-2]
  mload r6 [r9,-12]
  mstore [r9,-13] r6
  mload r6 [r9,-13]
  mul r6 r6 2
  mstore [r9,-8] r6
  mload r6 [r9,-8]
  add r8 r8 r6
  mstore [r9,-9] r8
  mov r8 r1
  mstore [r9,-14] r8
  mov r8 r2
  mstore [r9,-15] r8
  mov r8 r3
  mstore [r9,-16] r8
  mload r8 [r9,-9]
  mov r8 r8
  mstore [r9,-17] r8
  mov r5 0
  mov r6 0
  mov r8 0
  mov r7 r7
  mstore [r9,-18] r7
  mload r7 [r9,-14]
  mov r1 r7
  mload r7 [r9,-15]
  mov r2 r7
  mload r7 [r9,-16]
  mov r3 r7
  mload r7 [r9,-17]
  mov r4 r7
  mov r7 r8
  mload r8 [r9,-18]
  sstore 
  mload r8 [r9,-1]
  mload r7 [r9,-17]
  add r7 r7 1
  mstore [r9,-10] r7
  mload r7 [r9,-14]
  mov r1 r7
  mload r7 [r9,-15]
  mov r2 r7
  mload r7 [r9,-16]
  mov r3 r7
  mload r7 [r9,-10]
  mov r4 r7
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 r8
  sstore 
  mload r8 [r9,-13]
  add r8 r8 1
  mstore [r9,-11] r8
  mov r5 0
  mov r6 0
  mov r7 0
  mload r8 [r9,-11]
  mov r8 r8
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 1
  sstore 
  jmp .LBL13_3
.LBL13_3:
  mload r7 [r9,-3]
  add r8 r7 1
  mstore [r9,-3] r8
  jmp .LBL13_1
.LBL13_4:
  add r9 r9 -18
  ret
main:
.LBL14_0:
  add r9 r9 12
  mstore [r9,-2] r9
  mov r1 4
.PROPHET14_0:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  not r7 4
  add r7 r7 1
  add r8 r5 r7
  mov r1 r8
  mov r8 3
  mstore [r1] r8
  mov r8 r1
  add r6 r8 1
  mov r8 r6
  mov r7 0
  mstore [r9,-3] r7
  jmp .LBL14_1
.LBL14_1:
  mload r7 [r9,-3]
  mov r6 3
  gte r6 r6 r7
  neq r5 r7 3
  and r6 r6 r5
  cjmp r6 .LBL14_2
  jmp .LBL14_3
.LBL14_2:
  mov r5 0
  mstore [r8,r7] r5
  add r6 r7 1
  mstore [r9,-3] r6
  jmp .LBL14_1
.LBL14_3:
  mload r7 [r1]
  mstore [r9,-12] r7
  not r7 1
  add r7 r7 1
  mload r7 [r9,-12]
  add r8 r7 r7
  not r7 0
  add r7 r7 1
  add r6 r8 r7
  range r6
  mov r8 r1
  add r5 r8 1
  mov r8 r5
  mov r7 65
  mstore [r8] r7
  mload r8 [r1]
  not r7 1
  add r7 r7 1
  add r2 r8 r7
  not r7 1
  add r7 r7 1
  add r3 r2 r7
  range r3
  mov r8 r1
  add r8 r8 1
  mstore [r9,-8] r8
  mload r8 [r9,-8]
  mov r7 66
  mstore [r8,+1] r7
  mload r8 [r1]
  not r7 1
  add r7 r7 1
  add r8 r8 r7
  mstore [r9,-9] r8
  not r7 2
  add r7 r7 1
  mload r8 [r9,-9]
  add r8 r8 r7
  mstore [r9,-10] r8
  mload r8 [r9,-10]
  range r8
  mov r8 r1
  add r8 r8 1
  mstore [r9,-11] r8
  mload r8 [r9,-11]
  mov r7 67
  mstore [r8,+2] r7
  call contract_init
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 1
  sload 
  mov r8 r1
  mov r8 r2
  mov r8 r3
  mov r8 r4
  not r7 1
  add r7 r7 1
  add r8 r8 r7
  mstore [r9,-4] r8
  not r7 1
  add r7 r7 1
  mload r8 [r9,-4]
  add r8 r8 r7
  mstore [r9,-7] r8
  mload r8 [r9,-7]
  range r8
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 1
  poseidon 
  mov r8 r4
  add r8 r8 2
  mstore [r9,-6] r8
  mload r8 [r9,-6]
  mov r8 r8
  mstore [r9,-5] r8
  mload r8 [r9,-5]
  mov r4 r8
  sload 
  mov r8 r1
  mov r8 r2
  mov r8 r3
  mov r8 r4
  assert r8 66
  add r9 r9 -12
  end
"
        );
    }
}
