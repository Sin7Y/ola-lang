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

pub fn lower_gep(
    ctx: &mut LoweringContext<Ola>,
    self_id: InstructionId,
    gep: &GetElementPtr,
) -> Result<()> {
    let base = if let Value::Instruction(id) = &ctx.ir_data.values[gep.args[0]]
               && let Some(slot) = ctx.inst_id_to_slot_id.get(id).copied() {
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
            println!("gep struct");
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
            println!("gep no struct");
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
    let mut mem_imm = OperandData::None;
    let mut mem_rbase = OperandData::None;
    let mut mem_ridx = OperandData::None;
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
            mem_imm = (imm/4).into();
            println!("gep mem_imm: {:?}", mem_imm);
        }
        [(_, x)] if x.sext_as_i64().is_some() => {
            unreachable!()
        }
        [(m, x)] if matches!(m, 1 | 2 | 4 | 8) => {
            mem_ridx = x.to_owned();
            // mem_mul = (*m as i64).into();
            println!("gep size: {:?},idx {:?}", mem_ridx, mem_mul);
        }
        _ => simple_case = false,
    }

    let ty = ctx.types.base_mut().pointer(cur_ty);
    let output = new_empty_inst_output(ctx, ty, self_id);

    if simple_case {
        println!("gep simple case");
        ctx.inst_seq.push(MachInstruction::new(
            InstructionData {
                opcode: Opcode::MLOADr,
                operands: vec![
                    MOperand::output(output[0].into()),
                    MOperand::new(OperandData::MemStart),
                    MOperand::new(OperandData::None),
                    MOperand::new(mem_slot),
                    MOperand::new(mem_imm),
                    MOperand::input(mem_rbase),
                    MOperand::input(mem_ridx),
                    MOperand::new(mem_mul),
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
        println!("{}", code.program);
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
        println!("{}", code.program);
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
        println!("{}", code.program);
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
        println!("{}", code.program);
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
        println!("{}", code.program);
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
        println!("{}", code.program);
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
  %index = alloca i64, align 8
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
  ;%index = alloca i64, align 8
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
        println!("{}", code.program);
        println!("{:#?}", code.prophets);
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
}
