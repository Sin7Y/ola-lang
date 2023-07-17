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
    let mut mem_mul = OperandData::None;

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
            mem_imm = (-imm).into();
        }
        [(_, x)] if x.sext_as_i64().is_some() => {
            unreachable!()
        }
        [(m, x)] if matches!(m, 1 | 2 | 4 | 8) => {
            mem_ridx = x.to_owned();
            mem_mul = (*m as i64).into();
        }
        _ => simple_case = false,
    }

    let ty = ctx.types.base_mut().pointer(cur_ty);
    let output = new_empty_inst_output(ctx, ty, self_id);

    if simple_case {
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
}
