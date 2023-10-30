#[macro_use]
pub mod call_conv;
pub mod core;
pub mod function;
pub mod isa;
pub mod lower;
pub mod module;
pub mod pass;
pub mod register;

#[cfg(test)]
mod test {
    use crate::codegen::{
        core::ir::module::Module,
        isa::ola::{asm::AsmProgram, Ola},
        lower::compile_module,
    };

    #[test]
    fn codegen_storage_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'SimpleVar'
source_filename = "examples/source/storage/storage_u32.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define void @inc_simple() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %1, align 4
  %2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %3, align 4
  %4 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %4, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 100, ptr %heap_to_ptr2, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %7, align 4
  call void @set_storage(ptr %heap_to_ptr, ptr %heap_to_ptr2)
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %9 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %9, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 0, ptr %heap_to_ptr6, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %12, align 4
  call void @get_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr4)
  %storage_value = load i64, ptr %heap_to_ptr4, align 4
  %13 = icmp eq i64 %storage_value, 100
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2364819430, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @inc_simple()
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "inc_simple:
.LBL14_0:
  mov r1 4
.PROPHET14_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r2 r1 r7
  mov r1 0
  mstore [r2] r1
  mov r1 0
  mstore [r2,+1] r1
  mov r1 0
  mstore [r2,+2] r1
  mov r1 0
  mstore [r2,+3] r1
  mov r1 4
.PROPHET14_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r3 r1 r7
  mov r1 r3
  mov r3 100
  mstore [r1] r3
  mov r3 0
  mstore [r1,+1] r3
  mov r3 0
  mstore [r1,+2] r3
  mov r3 0
  mstore [r1,+3] r3
  sstore r2 r1
  mov r1 4
.PROPHET14_2:
  mov r0 psp
  mload r0 [r0]
  mov r2 r0
  mov r1 4
.PROPHET14_3:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r4 r1 r7
  mov r1 r4
  mov r3 0
  mstore [r1] r3
  mov r3 0
  mstore [r1,+1] r3
  mov r3 0
  mstore [r1,+2] r3
  mov r3 0
  mstore [r1,+3] r3
  not r7 4
  add r7 r7 1
  add r5 r2 r7
  mov r2 r5
  sload r1 r2
  mload r1 [r2]
  eq r1 r1 100
  assert r1
  ret
function_dispatch:
.LBL15_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r2 r3
  eq r1 r1 2364819430
  cjmp r1 .LBL15_2
  jmp .LBL15_1
.LBL15_1:
  ret
.LBL15_2:
  call inc_simple
  add r9 r9 -2
  ret
main:
.LBL16_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 13
.PROPHET16_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 13
  add r7 r7 1
  add r2 r1 r7
  tload r2 r6 13
  mov r1 r2
  mload r2 [r1]
  mov r1 14
.PROPHET16_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 14
  add r7 r7 1
  add r3 r1 r7
  tload r3 r6 14
  mov r1 r3
  mload r3 [r1]
  add r4 r3 14
  mov r1 r4
.PROPHET16_2:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 r4
  add r7 r7 1
  add r5 r1 r7
  tload r5 r6 r4
  mov r1 r2
  mov r2 r3
  mov r3 r5
  call function_dispatch
  add r9 r9 -2
  end
"
        );
    }

    #[test]
    fn codegen_poseidon_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'HashContract'
source_filename = "examples/source/types/hash.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define void @hash_test() {
entry:
  %h = alloca ptr, align 8
  %0 = call i64 @vector_new(i64 11)
  %heap_start = sub i64 %0, 11
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 10, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 5
  store i64 119, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 6
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 7
  store i64 114, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 8
  store i64 108, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data, i64 9
  store i64 100, ptr %index_access9, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data10 = inttoptr i64 %4 to ptr
  %5 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %5, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @poseidon_hash(ptr %vector_data10, ptr %heap_to_ptr12, i64 %length)
  store ptr %heap_to_ptr12, ptr %h, align 8
  %6 = load ptr, ptr %h, align 8
  %7 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %7, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  %index_access15 = getelementptr i64, ptr %heap_to_ptr14, i64 0
  store i64 129094667183523914, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 107395124437206779, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 -7568657024057810014, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 1885151562297713155, ptr %index_access18, align 4
  %left_elem_0 = getelementptr i64, ptr %6, i64 0
  %8 = load i64, ptr %left_elem_0, align 4
  %right_elem_0 = getelementptr i64, ptr %heap_to_ptr14, i64 0
  %9 = load i64, ptr %right_elem_0, align 4
  %compare_0 = icmp eq i64 %8, %9
  %10 = zext i1 %compare_0 to i64
  %result_0 = and i64 %10, 1
  %left_elem_1 = getelementptr i64, ptr %6, i64 1
  %11 = load i64, ptr %left_elem_1, align 4
  %right_elem_1 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  %12 = load i64, ptr %right_elem_1, align 4
  %compare_1 = icmp eq i64 %11, %12
  %13 = zext i1 %compare_1 to i64
  %result_1 = and i64 %13, %result_0
  %left_elem_2 = getelementptr i64, ptr %6, i64 2
  %14 = load i64, ptr %left_elem_2, align 4
  %right_elem_2 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  %15 = load i64, ptr %right_elem_2, align 4
  %compare_2 = icmp eq i64 %14, %15
  %16 = zext i1 %compare_2 to i64
  %result_2 = and i64 %16, %result_1
  %left_elem_3 = getelementptr i64, ptr %6, i64 3
  %17 = load i64, ptr %left_elem_3, align 4
  %right_elem_3 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  %18 = load i64, ptr %right_elem_3, align 4
  %compare_3 = icmp eq i64 %17, %18
  %19 = zext i1 %compare_3 to i64
  %result_3 = and i64 %19, %result_2
  call void @builtin_assert(i64 %result_3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1239976900, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @hash_test()
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "hash_test:
.LBL14_0:
  add r9 r9 7
  mov r1 11
.PROPHET14_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 11
  add r7 r7 1
  add r2 r1 r7
  mov r1 10
  mstore [r2] r1
  mov r1 r2
  add r3 r1 1
  mov r1 r3
  mov r3 104
  mstore [r1] r3
  mov r3 101
  mstore [r1,+1] r3
  mov r3 108
  mstore [r1,+2] r3
  mov r3 108
  mstore [r1,+3] r3
  mov r3 111
  mstore [r1,+4] r3
  mov r3 119
  mstore [r1,+5] r3
  mov r3 111
  mstore [r1,+6] r3
  mov r3 114
  mstore [r1,+7] r3
  mov r3 108
  mstore [r1,+8] r3
  mov r3 100
  mstore [r1,+9] r3
  mload r3 [r2]
  mov r1 4
.PROPHET14_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  add r4 r2 1
  mov r2 r4
  not r7 4
  add r7 r7 1
  add r5 r1 r7
  mov r1 r5
  poseidon r1 r2 r3
  mstore [r9,-1] r1
  mload r2 [r9,-1]
  mov r1 4
.PROPHET14_2:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r6 r1 r7
  mov r1 r6
  mov r3 129094667183523914
  mstore [r1] r3
  mov r3 107395124437206779
  mstore [r1,+1] r3
  mov r3 10878087049651741602
  mstore [r1,+2] r3
  mov r3 1885151562297713155
  mstore [r1,+3] r3
  mload r3 [r2]
  mload r4 [r1]
  mload r5 [r2,+1]
  mload r6 [r1,+1]
  mload r7 [r2,+2]
  mstore [r9,-6] r7
  mload r7 [r1,+2]
  mstore [r9,-7] r7
  mload r2 [r2,+3]
  mload r1 [r1,+3]
  eq r1 r2 r1
  mload r2 [r9,-6]
  mload r7 [r9,-7]
  eq r2 r2 r7
  eq r5 r5 r6
  eq r3 r3 r4
  and r3 r3 1
  mstore [r9,-2] r3
  mload r3 [r9,-2]
  and r3 r5 r3
  mstore [r9,-3] r3
  mload r3 [r9,-3]
  and r2 r2 r3
  mstore [r9,-4] r2
  mload r2 [r9,-4]
  and r1 r1 r2
  mstore [r9,-5] r1
  mload r1 [r9,-5]
  assert r1
  add r9 r9 -7
  ret
function_dispatch:
.LBL15_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r2 r3
  eq r1 r1 1239976900
  cjmp r1 .LBL15_2
  jmp .LBL15_1
.LBL15_1:
  ret
.LBL15_2:
  call hash_test
  add r9 r9 -2
  ret
main:
.LBL16_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 13
.PROPHET16_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 13
  add r7 r7 1
  add r2 r1 r7
  tload r2 r6 13
  mov r1 r2
  mload r2 [r1]
  mov r1 14
.PROPHET16_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 14
  add r7 r7 1
  add r3 r1 r7
  tload r3 r6 14
  mov r1 r3
  mload r3 [r1]
  add r4 r3 14
  mov r1 r4
.PROPHET16_2:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 r4
  add r7 r7 1
  add r5 r1 r7
  tload r5 r6 r4
  mov r1 r2
  mov r2 r3
  mov r3 r5
  call function_dispatch
  add r9 r9 -2
  end
"
        );
    }

    #[test]
    fn codegen_global_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'SystemContextExample'
source_filename = "examples/source/system/system_context.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define ptr @caller_address_test() {
entry:
  %0 = call i64 @vector_new(i64 12)
  %heap_start = sub i64 %0, 12
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 12)
  ret ptr %heap_to_ptr
}

define ptr @origin_address_test() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %1 = add i64 %heap_start, 0
  call void @get_context_data(i64 %1, i64 8)
  %2 = add i64 %heap_start, 1
  call void @get_context_data(i64 %2, i64 9)
  %3 = add i64 %heap_start, 2
  call void @get_context_data(i64 %3, i64 10)
  %4 = add i64 %heap_start, 3
  call void @get_context_data(i64 %4, i64 11)
  ret ptr %heap_to_ptr
}

define ptr @code_address_test() {
entry:
  %0 = call i64 @vector_new(i64 8)
  %heap_start = sub i64 %0, 8
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 8)
  ret ptr %heap_to_ptr
}

define ptr @current_address_test() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 4)
  ret ptr %heap_to_ptr
}

define i64 @chain_id_test() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_context_data(i64 %heap_start, i64 7)
  %1 = load i64, ptr %heap_to_ptr, align 4
  ret i64 %1
}

define void @all_test() {
entry:
  %chain = alloca i64, align 8
  %current = alloca ptr, align 8
  %code = alloca ptr, align 8
  %origin = alloca ptr, align 8
  %caller = alloca ptr, align 8
  %0 = call ptr @caller_address_test()
  store ptr %0, ptr %caller, align 8
  %1 = load ptr, ptr %caller, align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 17, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 18, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 19, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 20, ptr %index_access3, align 4
  %left_elem_0 = getelementptr i64, ptr %1, i64 0
  %3 = load i64, ptr %left_elem_0, align 4
  %right_elem_0 = getelementptr i64, ptr %heap_to_ptr, i64 0
  %4 = load i64, ptr %right_elem_0, align 4
  %compare_0 = icmp eq i64 %3, %4
  %5 = zext i1 %compare_0 to i64
  %result_0 = and i64 %5, 1
  %left_elem_1 = getelementptr i64, ptr %1, i64 1
  %6 = load i64, ptr %left_elem_1, align 4
  %right_elem_1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  %7 = load i64, ptr %right_elem_1, align 4
  %compare_1 = icmp eq i64 %6, %7
  %8 = zext i1 %compare_1 to i64
  %result_1 = and i64 %8, %result_0
  %left_elem_2 = getelementptr i64, ptr %1, i64 2
  %9 = load i64, ptr %left_elem_2, align 4
  %right_elem_2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  %10 = load i64, ptr %right_elem_2, align 4
  %compare_2 = icmp eq i64 %9, %10
  %11 = zext i1 %compare_2 to i64
  %result_2 = and i64 %11, %result_1
  %left_elem_3 = getelementptr i64, ptr %1, i64 3
  %12 = load i64, ptr %left_elem_3, align 4
  %right_elem_3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  %13 = load i64, ptr %right_elem_3, align 4
  %compare_3 = icmp eq i64 %12, %13
  %14 = zext i1 %compare_3 to i64
  %result_3 = and i64 %14, %result_2
  call void @builtin_assert(i64 %result_3)
  %15 = call ptr @origin_address_test()
  store ptr %15, ptr %origin, align 8
  %16 = load ptr, ptr %origin, align 8
  %17 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %17, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %index_access6 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  store i64 5, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 6, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 7, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 8, ptr %index_access9, align 4
  %left_elem_010 = getelementptr i64, ptr %16, i64 0
  %18 = load i64, ptr %left_elem_010, align 4
  %right_elem_011 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  %19 = load i64, ptr %right_elem_011, align 4
  %compare_012 = icmp eq i64 %18, %19
  %20 = zext i1 %compare_012 to i64
  %result_013 = and i64 %20, 1
  %left_elem_114 = getelementptr i64, ptr %16, i64 1
  %21 = load i64, ptr %left_elem_114, align 4
  %right_elem_115 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  %22 = load i64, ptr %right_elem_115, align 4
  %compare_116 = icmp eq i64 %21, %22
  %23 = zext i1 %compare_116 to i64
  %result_117 = and i64 %23, %result_013
  %left_elem_218 = getelementptr i64, ptr %16, i64 2
  %24 = load i64, ptr %left_elem_218, align 4
  %right_elem_219 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  %25 = load i64, ptr %right_elem_219, align 4
  %compare_220 = icmp eq i64 %24, %25
  %26 = zext i1 %compare_220 to i64
  %result_221 = and i64 %26, %result_117
  %left_elem_322 = getelementptr i64, ptr %16, i64 3
  %27 = load i64, ptr %left_elem_322, align 4
  %right_elem_323 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  %28 = load i64, ptr %right_elem_323, align 4
  %compare_324 = icmp eq i64 %27, %28
  %29 = zext i1 %compare_324 to i64
  %result_325 = and i64 %29, %result_221
  call void @builtin_assert(i64 %result_325)
  %30 = call ptr @code_address_test()
  store ptr %30, ptr %code, align 8
  %31 = load ptr, ptr %code, align 8
  %32 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %32, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  %index_access28 = getelementptr i64, ptr %heap_to_ptr27, i64 0
  store i64 9, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  store i64 10, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %heap_to_ptr27, i64 2
  store i64 11, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  store i64 12, ptr %index_access31, align 4
  %left_elem_032 = getelementptr i64, ptr %31, i64 0
  %33 = load i64, ptr %left_elem_032, align 4
  %right_elem_033 = getelementptr i64, ptr %heap_to_ptr27, i64 0
  %34 = load i64, ptr %right_elem_033, align 4
  %compare_034 = icmp eq i64 %33, %34
  %35 = zext i1 %compare_034 to i64
  %result_035 = and i64 %35, 1
  %left_elem_136 = getelementptr i64, ptr %31, i64 1
  %36 = load i64, ptr %left_elem_136, align 4
  %right_elem_137 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  %37 = load i64, ptr %right_elem_137, align 4
  %compare_138 = icmp eq i64 %36, %37
  %38 = zext i1 %compare_138 to i64
  %result_139 = and i64 %38, %result_035
  %left_elem_240 = getelementptr i64, ptr %31, i64 2
  %39 = load i64, ptr %left_elem_240, align 4
  %right_elem_241 = getelementptr i64, ptr %heap_to_ptr27, i64 2
  %40 = load i64, ptr %right_elem_241, align 4
  %compare_242 = icmp eq i64 %39, %40
  %41 = zext i1 %compare_242 to i64
  %result_243 = and i64 %41, %result_139
  %left_elem_344 = getelementptr i64, ptr %31, i64 3
  %42 = load i64, ptr %left_elem_344, align 4
  %right_elem_345 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  %43 = load i64, ptr %right_elem_345, align 4
  %compare_346 = icmp eq i64 %42, %43
  %44 = zext i1 %compare_346 to i64
  %result_347 = and i64 %44, %result_243
  call void @builtin_assert(i64 %result_347)
  %45 = call ptr @current_address_test()
  store ptr %45, ptr %current, align 8
  %46 = load ptr, ptr %current, align 8
  %47 = call i64 @vector_new(i64 4)
  %heap_start48 = sub i64 %47, 4
  %heap_to_ptr49 = inttoptr i64 %heap_start48 to ptr
  %index_access50 = getelementptr i64, ptr %heap_to_ptr49, i64 0
  store i64 13, ptr %index_access50, align 4
  %index_access51 = getelementptr i64, ptr %heap_to_ptr49, i64 1
  store i64 14, ptr %index_access51, align 4
  %index_access52 = getelementptr i64, ptr %heap_to_ptr49, i64 2
  store i64 15, ptr %index_access52, align 4
  %index_access53 = getelementptr i64, ptr %heap_to_ptr49, i64 3
  store i64 16, ptr %index_access53, align 4
  %left_elem_054 = getelementptr i64, ptr %46, i64 0
  %48 = load i64, ptr %left_elem_054, align 4
  %right_elem_055 = getelementptr i64, ptr %heap_to_ptr49, i64 0
  %49 = load i64, ptr %right_elem_055, align 4
  %compare_056 = icmp eq i64 %48, %49
  %50 = zext i1 %compare_056 to i64
  %result_057 = and i64 %50, 1
  %left_elem_158 = getelementptr i64, ptr %46, i64 1
  %51 = load i64, ptr %left_elem_158, align 4
  %right_elem_159 = getelementptr i64, ptr %heap_to_ptr49, i64 1
  %52 = load i64, ptr %right_elem_159, align 4
  %compare_160 = icmp eq i64 %51, %52
  %53 = zext i1 %compare_160 to i64
  %result_161 = and i64 %53, %result_057
  %left_elem_262 = getelementptr i64, ptr %46, i64 2
  %54 = load i64, ptr %left_elem_262, align 4
  %right_elem_263 = getelementptr i64, ptr %heap_to_ptr49, i64 2
  %55 = load i64, ptr %right_elem_263, align 4
  %compare_264 = icmp eq i64 %54, %55
  %56 = zext i1 %compare_264 to i64
  %result_265 = and i64 %56, %result_161
  %left_elem_366 = getelementptr i64, ptr %46, i64 3
  %57 = load i64, ptr %left_elem_366, align 4
  %right_elem_367 = getelementptr i64, ptr %heap_to_ptr49, i64 3
  %58 = load i64, ptr %right_elem_367, align 4
  %compare_368 = icmp eq i64 %57, %58
  %59 = zext i1 %compare_368 to i64
  %result_369 = and i64 %59, %result_265
  call void @builtin_assert(i64 %result_369)
  %60 = call i64 @chain_id_test()
  store i64 %60, ptr %chain, align 4
  %61 = load i64, ptr %chain, align 4
  %62 = icmp eq i64 %61, 1
  %63 = zext i1 %62 to i64
  call void @builtin_assert(i64 %63)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3263022682, label %func_0_dispatch
    i64 1793245141, label %func_1_dispatch
    i64 1041928024, label %func_2_dispatch
    i64 2985880226, label %func_3_dispatch
    i64 1386073907, label %func_4_dispatch
    i64 3458276513, label %func_5_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @caller_address_test()
  %4 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %4, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %6, ptr %start, align 4
  %7 = getelementptr i64, ptr %3, i64 1
  %8 = load i64, ptr %7, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %8, ptr %start1, align 4
  %9 = getelementptr i64, ptr %3, i64 2
  %10 = load i64, ptr %9, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %10, ptr %start2, align 4
  %11 = getelementptr i64, ptr %3, i64 3
  %12 = load i64, ptr %11, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %12, ptr %start3, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 4, ptr %start4, align 4
  call void @set_tape_data(i64 %heap_start, i64 5)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %13 = call ptr @origin_address_test()
  %14 = call i64 @vector_new(i64 5)
  %heap_start5 = sub i64 %14, 5
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %15 = getelementptr i64, ptr %13, i64 0
  %16 = load i64, ptr %15, align 4
  %start7 = getelementptr i64, ptr %heap_to_ptr6, i64 0
  store i64 %16, ptr %start7, align 4
  %17 = getelementptr i64, ptr %13, i64 1
  %18 = load i64, ptr %17, align 4
  %start8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 %18, ptr %start8, align 4
  %19 = getelementptr i64, ptr %13, i64 2
  %20 = load i64, ptr %19, align 4
  %start9 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 %20, ptr %start9, align 4
  %21 = getelementptr i64, ptr %13, i64 3
  %22 = load i64, ptr %21, align 4
  %start10 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 %22, ptr %start10, align 4
  %start11 = getelementptr i64, ptr %heap_to_ptr6, i64 4
  store i64 4, ptr %start11, align 4
  call void @set_tape_data(i64 %heap_start5, i64 5)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %23 = call ptr @code_address_test()
  %24 = call i64 @vector_new(i64 5)
  %heap_start12 = sub i64 %24, 5
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  %25 = getelementptr i64, ptr %23, i64 0
  %26 = load i64, ptr %25, align 4
  %start14 = getelementptr i64, ptr %heap_to_ptr13, i64 0
  store i64 %26, ptr %start14, align 4
  %27 = getelementptr i64, ptr %23, i64 1
  %28 = load i64, ptr %27, align 4
  %start15 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 %28, ptr %start15, align 4
  %29 = getelementptr i64, ptr %23, i64 2
  %30 = load i64, ptr %29, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 %30, ptr %start16, align 4
  %31 = getelementptr i64, ptr %23, i64 3
  %32 = load i64, ptr %31, align 4
  %start17 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 %32, ptr %start17, align 4
  %start18 = getelementptr i64, ptr %heap_to_ptr13, i64 4
  store i64 4, ptr %start18, align 4
  call void @set_tape_data(i64 %heap_start12, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %33 = call ptr @current_address_test()
  %34 = call i64 @vector_new(i64 5)
  %heap_start19 = sub i64 %34, 5
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  %35 = getelementptr i64, ptr %33, i64 0
  %36 = load i64, ptr %35, align 4
  %start21 = getelementptr i64, ptr %heap_to_ptr20, i64 0
  store i64 %36, ptr %start21, align 4
  %37 = getelementptr i64, ptr %33, i64 1
  %38 = load i64, ptr %37, align 4
  %start22 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 %38, ptr %start22, align 4
  %39 = getelementptr i64, ptr %33, i64 2
  %40 = load i64, ptr %39, align 4
  %start23 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 %40, ptr %start23, align 4
  %41 = getelementptr i64, ptr %33, i64 3
  %42 = load i64, ptr %41, align 4
  %start24 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 %42, ptr %start24, align 4
  %start25 = getelementptr i64, ptr %heap_to_ptr20, i64 4
  store i64 4, ptr %start25, align 4
  call void @set_tape_data(i64 %heap_start19, i64 5)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %43 = call i64 @chain_id_test()
  %44 = call i64 @vector_new(i64 2)
  %heap_start26 = sub i64 %44, 2
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  %start28 = getelementptr i64, ptr %heap_to_ptr27, i64 0
  store i64 %43, ptr %start28, align 4
  %start29 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  store i64 1, ptr %start29, align 4
  call void @set_tape_data(i64 %heap_start26, i64 2)
  ret void

func_5_dispatch:                                  ; preds = %entry
  call void @all_test()
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "caller_address_test:
.LBL14_0:
  mov r1 12
.PROPHET14_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r3 1
  not r7 12
  add r7 r7 1
  add r2 r1 r7
  tload r2 r3 12
  mov r0 r2
  ret
origin_address_test:
.LBL15_0:
  add r9 r9 1
  mov r1 4
.PROPHET15_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r7 0
  mstore [r9,-1] r7
  not r7 4
  add r7 r7 1
  add r6 r1 r7
  add r2 r6 0
  mload r1 [r9,-1]
  tload r2 r1 8
  mov r1 0
  add r3 r6 1
  tload r3 r1 9
  mov r1 0
  add r4 r6 2
  tload r4 r1 10
  mov r1 0
  add r5 r6 3
  tload r5 r1 11
  mov r0 r6
  add r9 r9 -1
  ret
code_address_test:
.LBL16_0:
  mov r1 8
.PROPHET16_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r3 1
  not r7 8
  add r7 r7 1
  add r2 r1 r7
  tload r2 r3 8
  mov r0 r2
  ret
current_address_test:
.LBL17_0:
  mov r1 4
.PROPHET17_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r3 1
  not r7 4
  add r7 r7 1
  add r2 r1 r7
  tload r2 r3 4
  mov r0 r2
  ret
chain_id_test:
.LBL18_0:
  mov r1 1
.PROPHET18_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r3 0
  not r7 1
  add r7 r7 1
  add r2 r1 r7
  tload r2 r3 7
  mov r1 r2
  mload r0 [r1]
  ret
all_test:
.LBL19_0:
  add r9 r9 65
  mstore [r9,-2] r9
  call caller_address_test
  mov r1 r0
  mstore [r9,-7] r1
  mload r2 [r9,-7]
  mov r1 4
.PROPHET19_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-16] r1
  mload r1 [r9,-16]
  mov r3 17
  mstore [r1] r3
  mov r3 18
  mstore [r1,+1] r3
  mov r3 19
  mstore [r1,+2] r3
  mov r3 20
  mstore [r1,+3] r3
  mload r3 [r2]
  mload r4 [r1]
  mload r5 [r2,+1]
  mload r6 [r1,+1]
  mload r7 [r2,+2]
  mstore [r9,-58] r7
  mload r7 [r1,+2]
  mstore [r9,-59] r7
  mload r2 [r2,+3]
  mload r1 [r1,+3]
  eq r1 r2 r1
  mload r2 [r9,-58]
  mload r7 [r9,-59]
  eq r2 r2 r7
  eq r5 r5 r6
  eq r3 r3 r4
  and r3 r3 1
  mstore [r9,-10] r3
  mload r3 [r9,-10]
  and r3 r5 r3
  mstore [r9,-23] r3
  mload r3 [r9,-23]
  and r2 r2 r3
  mstore [r9,-15] r2
  mload r2 [r9,-15]
  and r1 r1 r2
  mstore [r9,-27] r1
  mload r1 [r9,-27]
  assert r1
  call origin_address_test
  mov r1 r0
  mstore [r9,-6] r1
  mload r2 [r9,-6]
  mov r1 4
.PROPHET19_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-25] r1
  mload r1 [r9,-25]
  mov r3 5
  mstore [r1] r3
  mov r3 6
  mstore [r1,+1] r3
  mov r3 7
  mstore [r1,+2] r3
  mov r3 8
  mstore [r1,+3] r3
  mload r3 [r2]
  mload r4 [r1]
  mload r5 [r2,+1]
  mload r6 [r1,+1]
  mload r7 [r2,+2]
  mstore [r9,-60] r7
  mload r7 [r1,+2]
  mstore [r9,-61] r7
  mload r2 [r2,+3]
  mload r1 [r1,+3]
  eq r1 r2 r1
  mload r2 [r9,-60]
  mload r7 [r9,-61]
  eq r2 r2 r7
  eq r5 r5 r6
  eq r3 r3 r4
  and r3 r3 1
  mstore [r9,-19] r3
  mload r3 [r9,-19]
  and r3 r5 r3
  mstore [r9,-11] r3
  mload r3 [r9,-11]
  and r2 r2 r3
  mstore [r9,-24] r2
  mload r2 [r9,-24]
  and r1 r1 r2
  mstore [r9,-17] r1
  mload r1 [r9,-17]
  assert r1
  call code_address_test
  mov r1 r0
  mstore [r9,-5] r1
  mload r2 [r9,-5]
  mov r1 4
.PROPHET19_2:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-13] r1
  mload r1 [r9,-13]
  mov r3 9
  mstore [r1] r3
  mov r3 10
  mstore [r1,+1] r3
  mov r3 11
  mstore [r1,+2] r3
  mov r3 12
  mstore [r1,+3] r3
  mload r3 [r2]
  mload r4 [r1]
  mload r5 [r2,+1]
  mload r6 [r1,+1]
  mload r7 [r2,+2]
  mstore [r9,-62] r7
  mload r7 [r1,+2]
  mstore [r9,-63] r7
  mload r2 [r2,+3]
  mload r1 [r1,+3]
  eq r1 r2 r1
  mload r2 [r9,-62]
  mload r7 [r9,-63]
  eq r2 r2 r7
  eq r5 r5 r6
  eq r3 r3 r4
  and r3 r3 1
  mstore [r9,-8] r3
  mload r3 [r9,-8]
  and r3 r5 r3
  mstore [r9,-20] r3
  mload r3 [r9,-20]
  and r2 r2 r3
  mstore [r9,-12] r2
  mload r2 [r9,-12]
  and r1 r1 r2
  mstore [r9,-26] r1
  mload r1 [r9,-26]
  assert r1
  call current_address_test
  mov r1 r0
  mstore [r9,-4] r1
  mload r2 [r9,-4]
  mov r1 4
.PROPHET19_3:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-22] r1
  mload r1 [r9,-22]
  mov r3 13
  mstore [r1] r3
  mov r3 14
  mstore [r1,+1] r3
  mov r3 15
  mstore [r1,+2] r3
  mov r3 16
  mstore [r1,+3] r3
  mload r3 [r2]
  mload r4 [r1]
  mload r5 [r2,+1]
  mload r6 [r1,+1]
  mload r7 [r2,+2]
  mstore [r9,-64] r7
  mload r7 [r1,+2]
  mstore [r9,-65] r7
  mload r2 [r2,+3]
  mload r1 [r1,+3]
  eq r1 r2 r1
  mload r2 [r9,-64]
  mload r7 [r9,-65]
  eq r2 r2 r7
  eq r5 r5 r6
  eq r3 r3 r4
  and r3 r3 1
  mstore [r9,-18] r3
  mload r3 [r9,-18]
  and r3 r5 r3
  mstore [r9,-9] r3
  mload r3 [r9,-9]
  and r2 r2 r3
  mstore [r9,-21] r2
  mload r2 [r9,-21]
  and r1 r1 r2
  mstore [r9,-14] r1
  mload r1 [r9,-14]
  assert r1
  call chain_id_test
  mov r1 r0
  mstore [r9,-3] r1
  mload r1 [r9,-3]
  eq r1 r1 1
  assert r1
  add r9 r9 -65
  ret
function_dispatch:
.LBL20_0:
  add r9 r9 7
  mstore [r9,-2] r9
  mov r4 r1
  mov r1 r2
  mov r1 r3
  eq r1 r4 3263022682
  cjmp r1 .LBL20_2
  eq r1 r4 1793245141
  cjmp r1 .LBL20_3
  eq r1 r4 1041928024
  cjmp r1 .LBL20_4
  eq r1 r4 2985880226
  cjmp r1 .LBL20_5
  eq r1 r4 1386073907
  cjmp r1 .LBL20_6
  eq r1 r4 3458276513
  cjmp r1 .LBL20_7
  jmp .LBL20_1
.LBL20_1:
  ret
.LBL20_2:
  call caller_address_test
  mov r2 r0
  mov r1 5
.PROPHET20_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mload r3 [r2]
  not r7 5
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-3] r1
  mload r1 [r9,-3]
  mstore [r1] r3
  mload r3 [r2,+1]
  mstore [r1,+1] r3
  mload r3 [r2,+2]
  mstore [r1,+2] r3
  mload r2 [r2,+3]
  mstore [r1,+3] r2
  mov r2 4
  mstore [r1,+4] r2
  mload r1 [r9,-3]
  tstore r1 5
  add r9 r9 -7
  ret
.LBL20_3:
  call origin_address_test
  mov r2 r0
  mov r1 5
.PROPHET20_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mload r3 [r2]
  not r7 5
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-4] r1
  mload r1 [r9,-4]
  mstore [r1] r3
  mload r3 [r2,+1]
  mstore [r1,+1] r3
  mload r3 [r2,+2]
  mstore [r1,+2] r3
  mload r2 [r2,+3]
  mstore [r1,+3] r2
  mov r2 4
  mstore [r1,+4] r2
  mload r1 [r9,-4]
  tstore r1 5
  add r9 r9 -7
  ret
.LBL20_4:
  call code_address_test
  mov r2 r0
  mov r1 5
.PROPHET20_2:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mload r3 [r2]
  not r7 5
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-5] r1
  mload r1 [r9,-5]
  mstore [r1] r3
  mload r3 [r2,+1]
  mstore [r1,+1] r3
  mload r3 [r2,+2]
  mstore [r1,+2] r3
  mload r2 [r2,+3]
  mstore [r1,+3] r2
  mov r2 4
  mstore [r1,+4] r2
  mload r1 [r9,-5]
  tstore r1 5
  add r9 r9 -7
  ret
.LBL20_5:
  call current_address_test
  mov r2 r0
  mov r1 5
.PROPHET20_3:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mload r3 [r2]
  not r7 5
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-6] r1
  mload r1 [r9,-6]
  mstore [r1] r3
  mload r3 [r2,+1]
  mstore [r1,+1] r3
  mload r3 [r2,+2]
  mstore [r1,+2] r3
  mload r2 [r2,+3]
  mstore [r1,+3] r2
  mov r2 4
  mstore [r1,+4] r2
  mload r1 [r9,-6]
  tstore r1 5
  add r9 r9 -7
  ret
.LBL20_6:
  call chain_id_test
  mov r2 r0
  mov r1 2
.PROPHET20_4:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 2
  add r7 r7 1
  add r1 r1 r7
  mstore [r9,-7] r1
  mload r1 [r9,-7]
  mstore [r1] r2
  mov r2 1
  mstore [r1,+1] r2
  mload r1 [r9,-7]
  tstore r1 2
  add r9 r9 -7
  ret
.LBL20_7:
  call all_test
  add r9 r9 -7
  ret
main:
.LBL21_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 13
.PROPHET21_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 13
  add r7 r7 1
  add r2 r1 r7
  tload r2 r6 13
  mov r1 r2
  mload r2 [r1]
  mov r1 14
.PROPHET21_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 14
  add r7 r7 1
  add r3 r1 r7
  tload r3 r6 14
  mov r1 r3
  mload r3 [r1]
  add r4 r3 14
  mov r1 r4
.PROPHET21_2:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r6 1
  not r7 r4
  add r7 r7 1
  add r5 r1 r7
  tload r5 r6 r4
  mov r1 r2
  mov r2 r3
  mov r3 r5
  call function_dispatch
  add r9 r9 -2
  end
"
        );
    }

    #[test]
    fn codegen_str_concat_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'FieldsContract'
source_filename = "examples/source/types/fields.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define ptr @fields_concat(ptr %0, ptr %1) {
entry:
  %index_alloca7 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %length = load i64, ptr %0, align 4
  %2 = ptrtoint ptr %0 to i64
  %3 = add i64 %2, 1
  %vector_data = inttoptr i64 %3 to ptr
  %length1 = load i64, ptr %1, align 4
  %4 = ptrtoint ptr %1 to i64
  %5 = add i64 %4, 1
  %vector_data2 = inttoptr i64 %5 to ptr
  %new_len = add i64 %length, %length1
  %size_add_one = add i64 %new_len, 1
  %6 = call i64 @vector_new(i64 %size_add_one)
  %heap_start = sub i64 %6, %size_add_one
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %new_len, ptr %heap_to_ptr, align 4
  %7 = ptrtoint ptr %heap_to_ptr to i64
  %8 = add i64 %7, 1
  %vector_data3 = inttoptr i64 %8 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %9 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %vector_data, i64 %9
  %10 = load i64, ptr %src_index_access, align 4
  %11 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %vector_data3, i64 %11
  store i64 %10, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca7, align 4
  br label %cond4

cond4:                                            ; preds = %body5, %done
  %index_value8 = load i64, ptr %index_alloca7, align 4
  %loop_cond9 = icmp ult i64 %index_value8, %length1
  br i1 %loop_cond9, label %body5, label %done6

body5:                                            ; preds = %cond4
  %12 = add i64 0, %index_value8
  %src_index_access10 = getelementptr i64, ptr %vector_data2, i64 %12
  %13 = load i64, ptr %src_index_access10, align 4
  %14 = add i64 %length, %index_value8
  %dest_index_access11 = getelementptr i64, ptr %vector_data3, i64 %14
  store i64 %13, ptr %dest_index_access11, align 4
  %next_index12 = add i64 %index_value8, 1
  store i64 %next_index12, ptr %index_alloca7, align 4
  br label %cond4

done6:                                            ; preds = %cond4
  ret ptr %heap_to_ptr
}

define ptr @fields_test() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 111, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 108, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 97, ptr %index_access2, align 4
  %3 = call i64 @vector_new(i64 3)
  %heap_start3 = sub i64 %3, 3
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 2, ptr %heap_to_ptr4, align 4
  %4 = ptrtoint ptr %heap_to_ptr4 to i64
  %5 = add i64 %4, 1
  %vector_data5 = inttoptr i64 %5 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 0
  store i64 118, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data5, i64 1
  store i64 109, ptr %index_access7, align 4
  %6 = call ptr @fields_concat(ptr %heap_to_ptr, ptr %heap_to_ptr4)
  ret ptr %6
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %offset_ptr = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 3859955665, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @fields_test()
  %length = load i64, ptr %3, align 4
  %4 = add i64 %length, 1
  %heap_size = add i64 %4, 1
  %5 = call i64 @vector_new(i64 %heap_size)
  %heap_start = sub i64 %5, %heap_size
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %length1 = load i64, ptr %3, align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %length1, ptr %start, align 4
  %6 = ptrtoint ptr %3 to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
  store i64 1, ptr %offset_ptr, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %func_0_dispatch
%offset = load i64, ptr %offset_ptr, align 4
%start2 = getelementptr i64, ptr %heap_to_ptr, i64 %offset
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr ptr, ptr %vector_data, i64 %index
  %elem = load i64, ptr %element, align 4
  store i64 %elem, ptr %start2, align 4
  %next_offset = add i64 %offset, 1
  store i64 %next_offset, ptr %offset_ptr, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %length1
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
   %8 = add i64 %length1, 1
  %9 = add i64 0, %8
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 %9
  store i64 %4, ptr %start3, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_struct_params_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'MultInputExample'
source_filename = "examples/source/contract_input/struct_input.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define void @foo(ptr %0) {
entry:
  %t = alloca ptr, align 8
  store ptr %0, ptr %t, align 8
  %1 = load ptr, ptr %t, align 8
  %struct_member = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 0
  %2 = load ptr, ptr %struct_member, align 8
  %address_start = ptrtoint ptr %2 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %struct_member1 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 1
  %3 = load i64, ptr %struct_member1, align 4
  call void @prophet_printf(i64 %3, i64 3)
  %struct_member2 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 2
  %4 = load i64, ptr %struct_member2, align 4
  call void @prophet_printf(i64 %4, i64 3)
  %struct_member3 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 3
  %5 = load i64, ptr %struct_member3, align 4
  call void @prophet_printf(i64 %5, i64 3)
  %struct_member4 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 4
  %6 = load ptr, ptr %struct_member4, align 8
  %fields_start = ptrtoint ptr %6 to i64
  call void @prophet_printf(i64 %fields_start, i64 1)
  %struct_member5 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 5
  %7 = load ptr, ptr %struct_member5, align 8
  %fields_start6 = ptrtoint ptr %7 to i64
  call void @prophet_printf(i64 %fields_start6, i64 1)
  %struct_member7 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 6
  %8 = load ptr, ptr %struct_member7, align 8
  %fields_start8 = ptrtoint ptr %8 to i64
  call void @prophet_printf(i64 %fields_start8, i64 1)
  %struct_member9 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i64 7
  %9 = load ptr, ptr %struct_member9, align 8
  %hash_start = ptrtoint ptr %9 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3469705383, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %struct_offset = add i64 %input_start, 4
  %4 = inttoptr i64 %struct_offset to ptr
  %decode_value = load i64, ptr %4, align 4
  %struct_offset1 = add i64 %struct_offset, 1
  %5 = inttoptr i64 %struct_offset1 to ptr
  %decode_value2 = load i64, ptr %5, align 4
  %struct_offset3 = add i64 %struct_offset1, 1
  %6 = inttoptr i64 %struct_offset3 to ptr
  %decode_value4 = load i64, ptr %6, align 4
  %struct_offset5 = add i64 %struct_offset3, 1
  %7 = inttoptr i64 %struct_offset5 to ptr
  %length = load i64, ptr %7, align 4
  %8 = add i64 %length, 1
  %struct_offset6 = add i64 %struct_offset5, %8
  %9 = inttoptr i64 %struct_offset6 to ptr
  %length7 = load i64, ptr %9, align 4
  %10 = add i64 %length7, 1
  %struct_offset8 = add i64 %struct_offset6, %10
  %11 = inttoptr i64 %struct_offset8 to ptr
  %length9 = load i64, ptr %11, align 4
  %12 = add i64 %length9, 1
  %struct_offset10 = add i64 %struct_offset8, %12
  %13 = inttoptr i64 %struct_offset10 to ptr
  %struct_offset11 = add i64 %struct_offset10, 4
  %struct_decode_size = sub i64 %struct_offset11, %input_start
  %14 = call i64 @vector_new(i64 14)
  %heap_start = sub i64 %14, 14
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 0
  store ptr %3, ptr %struct_member, align 8
  %struct_member12 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 1
  store i64 %decode_value, ptr %struct_member12, align 4
  %struct_member13 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 2
  store i64 %decode_value2, ptr %struct_member13, align 4
  %struct_member14 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 3
  store i64 %decode_value4, ptr %struct_member14, align 4
  %struct_member15 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 4
  store ptr %7, ptr %struct_member15, align 8
  %struct_member16 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 5
  store ptr %9, ptr %struct_member16, align 8
  %struct_member17 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 6
  store ptr %11, ptr %struct_member17, align 8
  %struct_member18 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i64 7
  store ptr %13, ptr %struct_member18, align 8
  call void @foo(ptr %heap_to_ptr)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_struct_params_s_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'MultInputExample'
source_filename = "examples/source/contract_input/struct_input.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define void @foo(ptr %0) {
entry:
  %t = alloca ptr, align 8
  store ptr %0, ptr %t, align 8
  %1 = load ptr, ptr %t, align 8
  %string_start = ptrtoint ptr %1 to i64
  call void @prophet_printf(i64 %string_start, i64 1)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1768495859, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %length = load i64, ptr %3, align 4
  %4 = add i64 %length, 1
  call void @foo(ptr %3)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_map_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'NonceHolder'
source_filename = "examples/source/types/mapping_1.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

define void @mempcy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define void @setNonce(ptr %0, i64 %1) {
entry:
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %8 = inttoptr i64 %heap_start1 to ptr
  call void @mempcy(ptr %heap_to_ptr, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @mempcy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %10, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %11 = load i64, ptr %_nonce, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %11, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  %16 = call i64 @vector_new(i64 8)
  %heap_start7 = sub i64 %16, 8
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %17 = inttoptr i64 %heap_start7 to ptr
  call void @mempcy(ptr %heap_to_ptr4, ptr %17, i64 4)
  %next_dest_offset9 = add i64 %heap_start7, 4
  %18 = inttoptr i64 %next_dest_offset9 to ptr
  call void @mempcy(ptr %heap_to_ptr6, ptr %18, i64 4)
  %19 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %19, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr11, i64 8)
  %20 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %20, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @get_storage(ptr %heap_to_ptr11, ptr %heap_to_ptr13)
  %storage_value = load i64, ptr %heap_to_ptr13, align 4
  %21 = icmp eq i64 %storage_value, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  %23 = load ptr, ptr %_address, align 8
  %24 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %24, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 0, ptr %heap_to_ptr15, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %27, align 4
  %28 = call i64 @vector_new(i64 8)
  %heap_start16 = sub i64 %28, 8
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  %29 = inttoptr i64 %heap_start16 to ptr
  call void @mempcy(ptr %heap_to_ptr15, ptr %29, i64 4)
  %next_dest_offset18 = add i64 %heap_start16, 4
  %30 = inttoptr i64 %next_dest_offset18 to ptr
  call void @mempcy(ptr %23, ptr %30, i64 4)
  %31 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %31, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr17, ptr %heap_to_ptr20, i64 8)
  %32 = load i64, ptr %_nonce, align 4
  %33 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %33, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 %32, ptr %heap_to_ptr22, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %36, align 4
  %37 = call i64 @vector_new(i64 8)
  %heap_start23 = sub i64 %37, 8
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  %38 = inttoptr i64 %heap_start23 to ptr
  call void @mempcy(ptr %heap_to_ptr20, ptr %38, i64 4)
  %next_dest_offset25 = add i64 %heap_start23, 4
  %39 = inttoptr i64 %next_dest_offset25 to ptr
  call void @mempcy(ptr %heap_to_ptr22, ptr %39, i64 4)
  %40 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %40, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr24, ptr %heap_to_ptr27, i64 8)
  %41 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %41, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 1, ptr %heap_to_ptr29, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %44, align 4
  call void @set_storage(ptr %heap_to_ptr27, ptr %heap_to_ptr29)
  %45 = load ptr, ptr %_address, align 8
  %46 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %46, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  store i64 0, ptr %heap_to_ptr31, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr31, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr31, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  store i64 0, ptr %49, align 4
  %50 = call i64 @vector_new(i64 8)
  %heap_start32 = sub i64 %50, 8
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  %51 = inttoptr i64 %heap_start32 to ptr
  call void @mempcy(ptr %heap_to_ptr31, ptr %51, i64 4)
  %next_dest_offset34 = add i64 %heap_start32, 4
  %52 = inttoptr i64 %next_dest_offset34 to ptr
  call void @mempcy(ptr %45, ptr %52, i64 4)
  %53 = call i64 @vector_new(i64 4)
  %heap_start35 = sub i64 %53, 4
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr33, ptr %heap_to_ptr36, i64 8)
  %54 = load i64, ptr %_nonce, align 4
  %55 = call i64 @vector_new(i64 4)
  %heap_start37 = sub i64 %55, 4
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  store i64 %54, ptr %heap_to_ptr38, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr38, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr38, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr38, i64 3
  store i64 0, ptr %58, align 4
  %59 = call i64 @vector_new(i64 8)
  %heap_start39 = sub i64 %59, 8
  %heap_to_ptr40 = inttoptr i64 %heap_start39 to ptr
  %60 = inttoptr i64 %heap_start39 to ptr
  call void @mempcy(ptr %heap_to_ptr36, ptr %60, i64 4)
  %next_dest_offset41 = add i64 %heap_start39, 4
  %61 = inttoptr i64 %next_dest_offset41 to ptr
  call void @mempcy(ptr %heap_to_ptr38, ptr %61, i64 4)
  %62 = call i64 @vector_new(i64 4)
  %heap_start42 = sub i64 %62, 4
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr40, ptr %heap_to_ptr43, i64 8)
  %63 = call i64 @vector_new(i64 4)
  %heap_start44 = sub i64 %63, 4
  %heap_to_ptr45 = inttoptr i64 %heap_start44 to ptr
  call void @get_storage(ptr %heap_to_ptr43, ptr %heap_to_ptr45)
  %storage_value46 = load i64, ptr %heap_to_ptr45, align 4
  call void @builtin_assert(i64 %storage_value46)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3694669121, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = add i64 %input_start, 4
  %5 = inttoptr i64 %4 to ptr
  %decode_value = load i64, ptr %5, align 4
  call void @setNonce(ptr %3, i64 %decode_value)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_debug_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'NonceHolder'
source_filename = "examples/source/types/mapping.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

define void @mempcy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define void @setNonce(ptr %0, i64 %1) {
entry:
  %_nonceSet = alloca i64, align 8
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %8 = inttoptr i64 %heap_start1 to ptr
  call void @mempcy(ptr %heap_to_ptr, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @mempcy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %10, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %11 = load i64, ptr %_nonce, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %11, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  %16 = call i64 @vector_new(i64 8)
  %heap_start7 = sub i64 %16, 8
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %17 = inttoptr i64 %heap_start7 to ptr
  call void @mempcy(ptr %heap_to_ptr4, ptr %17, i64 4)
  %next_dest_offset9 = add i64 %heap_start7, 4
  %18 = inttoptr i64 %next_dest_offset9 to ptr
  call void @mempcy(ptr %heap_to_ptr6, ptr %18, i64 4)
  %19 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %19, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr11, i64 8)
  %20 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %20, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  store i64 55, ptr %heap_to_ptr13, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 0, ptr %23, align 4
  call void @set_storage(ptr %heap_to_ptr11, ptr %heap_to_ptr13)
  %24 = load ptr, ptr %_address, align 8
  %25 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %25, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 0, ptr %heap_to_ptr15, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %28, align 4
  %29 = call i64 @vector_new(i64 8)
  %heap_start16 = sub i64 %29, 8
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  %30 = inttoptr i64 %heap_start16 to ptr
  call void @mempcy(ptr %heap_to_ptr15, ptr %30, i64 4)
  %next_dest_offset18 = add i64 %heap_start16, 4
  %31 = inttoptr i64 %next_dest_offset18 to ptr
  call void @mempcy(ptr %24, ptr %31, i64 4)
  %32 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %32, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr17, ptr %heap_to_ptr20, i64 8)
  %33 = load i64, ptr %_nonce, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %34, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 %33, ptr %heap_to_ptr22, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %37, align 4
  %38 = call i64 @vector_new(i64 8)
  %heap_start23 = sub i64 %38, 8
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  %39 = inttoptr i64 %heap_start23 to ptr
  call void @mempcy(ptr %heap_to_ptr20, ptr %39, i64 4)
  %next_dest_offset25 = add i64 %heap_start23, 4
  %40 = inttoptr i64 %next_dest_offset25 to ptr
  call void @mempcy(ptr %heap_to_ptr22, ptr %40, i64 4)
  %41 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %41, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr24, ptr %heap_to_ptr27, i64 8)
  %42 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %42, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  call void @get_storage(ptr %heap_to_ptr27, ptr %heap_to_ptr29)
  %storage_value = load i64, ptr %heap_to_ptr29, align 4
  store i64 %storage_value, ptr %_nonceSet, align 4
  %43 = load i64, ptr %_nonceSet, align 4
  call void @prophet_printf(i64 %43, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3694669121, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = add i64 %input_start, 4
  %5 = inttoptr i64 %4 to ptr
  %decode_value = load i64, ptr %5, align 4
  call void @setNonce(ptr %3, i64 %decode_value)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
"
        );
    }

    #[test]
    fn codegen_array_slice_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'ArraySlice'
source_filename = "examples/source/array/array_slice.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define void @array_slice_test() {
entry:
  %index = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %0, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 5, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access4, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = sub i64 %length, 2
  call void @builtin_range_check(i64 %5)
  %6 = call i64 @vector_new(i64 3)
  %heap_start5 = sub i64 %6, 3
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 2, ptr %heap_to_ptr6, align 4
  %7 = ptrtoint ptr %heap_to_ptr6 to i64
  %8 = add i64 %7, 1
  %vector_data7 = inttoptr i64 %8 to ptr
  ;call void @builtin_range_check(i64 2)
  %9 = ptrtoint ptr %heap_to_ptr to i64
  %10 = add i64 %9, 1
  %vector_data8 = inttoptr i64 %10 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %11 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %vector_data8, i64 %11
  %12 = load i64, ptr %src_index_access, align 4
  %13 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %vector_data7, i64 %13
  store i64 %12, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %14 = ptrtoint ptr %heap_to_ptr6 to i64
  %15 = add i64 %14, 1
  %vector_data9 = inttoptr i64 %15 to ptr
  %length10 = load i64, ptr %heap_to_ptr6, align 4
  %16 = call i64 @vector_new(i64 3)
  %heap_start11 = sub i64 %16, 3
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 2, ptr %heap_to_ptr12, align 4
  %17 = ptrtoint ptr %heap_to_ptr12 to i64
  %18 = add i64 %17, 1
  %vector_data13 = inttoptr i64 %18 to ptr
  %index_access14 = getelementptr i64, ptr %vector_data13, i64 0
  store i64 104, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data13, i64 1
  store i64 101, ptr %index_access15, align 4
  %19 = ptrtoint ptr %heap_to_ptr12 to i64
  %20 = add i64 %19, 1
  %vector_data16 = inttoptr i64 %20 to ptr
  %length17 = load i64, ptr %heap_to_ptr12, align 4
  %21 = icmp eq i64 %length10, %length17
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  store i64 0, ptr %index, align 4
  br label %cond18

cond18:                                           ; preds = %body19, %done
  %index21 = load i64, ptr %index, align 4
  %23 = icmp ult i64 %index21, %length10
  br i1 %23, label %body19, label %done20

body19:                                           ; preds = %cond18
  %left_char_ptr = getelementptr i64, ptr %vector_data9, i64 %index21
  %right_char_ptr = getelementptr i64, ptr %vector_data16, i64 %index21
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index22 = add i64 %index21, 1
  store i64 %next_index22, ptr %index, align 4
  br i1 %comparison, label %cond18, label %done20

done20:                                           ; preds = %body19, %cond18
  %equal = icmp eq i64 %index21, %length17
  %24 = zext i1 %equal to i64
  call void @builtin_assert(i64 %24)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1458788567, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @array_slice_test()
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_binop_test() {
        // LLVM Assembly
        let asm = r#"
  source_filename = "asm"
  ; Function Attrs: noinline nounwind optnone uwtable
  define dso_local i32 @main() #0 {
    %a = alloca i32, align 4
    store i32 10, i32* %a
    %b = load i32, i32* %a
    %c = add i32 %b, 20 ; 30
    %d = add i32 %b, 30 ; 60
    %e = mul i32 %c, %d ; 1800
    %f = sub i32 %e, %d ; 1740
    ret i32 %f
  }
  attributes #0 = { noinline nounwind optnone uwtable }
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
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_multi_params_test() {
        // LLVM Assembly
        let asm = r#"
define void @foo(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5) {
entry:
  %result = alloca i64, align 8
  %e_f = alloca i64, align 8
  %c_d = alloca i64, align 8
  %a_b = alloca i64, align 8
  %f = alloca i64, align 8
  %e = alloca i64, align 8
  %d = alloca i64, align 8
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  store i64 %2, ptr %c, align 4
  store i64 %3, ptr %d, align 4
  store i64 %4, ptr %e, align 4
  store i64 %5, ptr %f, align 4
  %6 = load i64, ptr %a, align 4
  %7 = load i64, ptr %b, align 4
  %8 = add i64 %6, %7
  call void @builtin_range_check(i64 %8)
  store i64 %8, ptr %a_b, align 4
  %9 = load i64, ptr %c, align 4
  %10 = load i64, ptr %d, align 4
  %11 = add i64 %9, %10
  call void @builtin_range_check(i64 %11)
  store i64 %11, ptr %c_d, align 4
  %12 = load i64, ptr %e, align 4
  %13 = load i64, ptr %f, align 4
  %14 = add i64 %12, %13
  call void @builtin_range_check(i64 %14)
  store i64 %14, ptr %e_f, align 4
  %15 = load i64, ptr %a_b, align 4
  %16 = load i64, ptr %c_d, align 4
  %17 = add i64 %15, %16
  call void @builtin_range_check(i64 %17)
  %18 = load i64, ptr %e_f, align 4
  %19 = add i64 %17, %18
  call void @builtin_range_check(i64 %19)
  store i64 %19, ptr %result, align 4
  %20 = load i64, ptr %result, align 4
  %21 = icmp eq i64 %20, 21
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 4183569553, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 6, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %start3 = getelementptr i64, ptr %2, i64 2
  %value4 = load i64, ptr %start3, align 4
  %start5 = getelementptr i64, ptr %2, i64 3
  %value6 = load i64, ptr %start5, align 4
  %start7 = getelementptr i64, ptr %2, i64 4
  %value8 = load i64, ptr %start7, align 4
  %start9 = getelementptr i64, ptr %2, i64 5
  %value10 = load i64, ptr %start9, align 4
  %4 = icmp ult i64 6, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @foo(i64 %value, i64 %value2, i64 %value4, i64 %value6, i64 %value8, i64 %value10)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_vec_ldrstr_test() {
        // LLVM Assembly
        let asm = r#"
  source_filename = "asm"
  ; Function Attrs: noinline nounwind optnone uwtable
  define dso_local i64 @main() #0 {
    %a = alloca [4xi64], align 4
    ;%1 = load [4xi64], ptr %a, align 4
    %1 = call [4xi64] @get_storage([4xi64] [i64 10,i64 20,i64 30,i64 40])
    %2 = extractvalue [4 x i64] %1, 2
    %3 = add i64 %2, 100
    call void @set_storage([4xi64] %1, [4xi64] [i64 50,i64 60,i64 70,i64 80])
    ret i64 %3
  }

  define dso_local i64 @codegen_vec_ldrstr_test() #0 {
    %a = alloca [4xi64], align 4
    store [4xi64] [i64 10,i64 20,i64 30,i64 40], ptr %a
    %1 = load [4xi64], ptr %a, align 4
    store [4xi64] %1, ptr %a
    %2 = extractvalue [4 x i64] %1, 0
    %3 = extractvalue [4 x i64] %1, 1
    %4 = extractvalue [4 x i64] %1, 2
    %5 = extractvalue [4 x i64] %1, 3
    %6 = add i64 %2, %3
    %7 = mul i64 %4, %5
    %8 = add i64 %6, %7
    ;call void @set_storage([4xi64] %1, [4xi64] [i64 50,i64 60,i64 70,i64 80])
    ret i64 %8
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
.LBL0_0:
  add r9 r9 5
  mov r1 10
  mov r2 20
  mov r3 30
  mov r4 40
  sload 
  mov r5 r3
  mstore [r9,-5] r5
  mload r5 [r9,-5]
  mov r3 r5
  mov r5 50
  mov r6 60
  mov r7 70
  mov r8 80
  sstore 
  mload r5 [r9,-5]
  add r0 r5 100
  add r9 r9 -5
  end
codegen_vec_ldrstr_test:
.LBL1_0:
  add r9 r9 4
  mov r7 10
  mov r8 20
  mov r1 30
  mov r2 40
  mstore [r9,-4] r2
  mstore [r9,-3] r1
  mstore [r9,-2] r8
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  mload r8 [r9,-2]
  mload r1 [r9,-3]
  mload r2 [r9,-4]
  mstore [r9,-4] r2
  mstore [r9,-3] r1
  mstore [r9,-2] r8
  mstore [r9,-1] r7
  add r6 r7 r8
  mov r7 r1
  mov r8 r2
  mul r5 r7 r8
  add r0 r6 r5
  add r9 r9 -4
  ret
"
        );
    }

    #[test]
    fn codegen_storage_contract_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'SimpleVar'
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

define void @inc_simple() {
entry:
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] [i64 100, i64 200, i64 300, i64 400])
  ret void
}

define i64 @get() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %1 = extractvalue [4 x i64] %0, 2
  %2 = extractvalue [4 x i64] %0, 3
  %3 = add i64 %1, %2
  ret i64 %3
}

define void @main() {
entry:
  %x = alloca i64, align 8
  call void @inc_simple()
  %0 = call i64 @get()
  store i64 %0, ptr %x, align 4
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
            "inc_simple:
.LBL10_0:
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 100
  mov r6 200
  mov r7 300
  mov r8 400
  sstore 
  ret
get:
.LBL11_0:
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
main:
.LBL12_0:
  add r9 r9 3
  mstore [r9,-2] r9
  call inc_simple
  call get
  mov r5 r0
  mstore [r9,-3] r5
  add r9 r9 -3
  end
"
        );
    }

    #[test]
    fn codegen_malloc_test() {
        let asm = r#"
define void @main() {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %0 = call i64 @vector_new(i64 3)
  %int_to_ptr = inttoptr i64 %0 to ptr
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  store i64 1, ptr %index_access, align 4
  %index_access1 = getelementptr ptr, ptr %data, i64 1
  store i64 2, ptr %index_access1, align 4
  %index_access2 = getelementptr ptr, ptr %data, i64 2
  store i64 3, ptr %index_access2, align 4
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
        //println!("{:#?}",code);
        println!("{}", code.program);
        println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mov r1 3
.PROPHET0_0:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  mov r6 3
  mstore [r9,-2] r6
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  mov r6 1
  mstore [r5] r6
  mov r6 2
  mstore [r5,+1] r6
  mov r6 3
  mstore [r5,+2] r6
  add r9 r9 -2
  end
"
        );
    }

    #[test]
    fn codegen_array_param_test() {
        // LLVM Assembly
        let asm = r#"
declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define void @add_mapping([4 x i64] %3, i64 %2) {
entry:
  %4 = extractvalue [4 x i64] %3, 0
  %5 = extractvalue [4 x i64] %3, 1
  %6 = extractvalue [4 x i64] %3, 2
  %7 = extractvalue [4 x i64] %3, 3
  %8 = insertvalue [8 x i64] undef, i64 %7, 7
  %9 = insertvalue [8 x i64] %8, i64 %6, 6
  %10 = insertvalue [8 x i64] %9, i64 %5, 5
  %11 = insertvalue [8 x i64] %10, i64 %4, 4
  %12 = insertvalue [8 x i64] %11, i64 0, 3
  %13 = insertvalue [8 x i64] %12, i64 0, 2
  %14 = insertvalue [8 x i64] %13, i64 0, 1
  %15 = insertvalue [8 x i64] %14, i64 0, 0
  %16 = call [4 x i64] @poseidon_hash([8 x i64] %15)
  %17 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %2, 3
  call void @set_storage([4 x i64] %16, [4 x i64] %17)
  ret void
}

define void @main() {
  entry:
    ;0595c3e78A0Df589 B486778c4d81a360 5A37Fb041466a0CF A2DA9151fd6b580E
    call void @add_mapping([4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938], i64 1)
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
            "add_mapping:
.LBL11_0:
  add r9 r9 12
  mov r6 r1
  mov r7 r2
  mov r8 r3
  mov r1 r4
  mstore [r9,-1] r5
  mov r5 r1
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mstore [r9,-2] r4
  mov r4 0
  mstore [r9,-3] r4
  mov r4 0
  mstore [r9,-4] r4
  mov r4 0
  mstore [r9,-5] r4
  mov r5 r5
  mload r4 [r9,-2]
  mstore [r9,-6] r4
  mload r4 [r9,-3]
  mstore [r9,-7] r4
  mload r4 [r9,-4]
  mstore [r9,-8] r4
  mov r8 r8
  mload r4 [r9,-6]
  mstore [r9,-9] r4
  mload r4 [r9,-7]
  mstore [r9,-10] r4
  mov r7 r7
  mload r4 [r9,-9]
  mstore [r9,-11] r4
  mov r6 r6
  mov r4 0
  mov r3 0
  mov r2 0
  mov r1 0
  mstore [r9,-12] r5
  mov r5 r6
  mov r6 r7
  mov r7 r8
  mload r5 [r9,-12]
  mov r8 r5
  poseidon 
  mov r5 0
  mov r6 0
  mov r7 0
  mload r8 [r9,-1]
  mov r8 r8
  sstore 
  add r9 r9 -12
  ret
main:
.LBL12_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 402443140940559753
  mov r2 13008216018185724768
  mov r3 6500940582073311439
  mov r4 11734851560397297678
  mov r5 1
  call add_mapping
  add r9 r9 -2
  end
"
        );
    }

    #[test]
    fn codegen_str_u32_imm_test() {
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

define void @str_imm(i64 %0) {   ;mstore [r9,-1] r1 
entry:
  %a = alloca i64, align 8      ;[r9,-2]
  store i64 %0, ptr %a, align 4     ;mload r0 [r9,-1]  mstore [r9,-2] r0
  %1 = load i64, ptr %a, align 4    ;mload r0 [r9,-2] 
  ;%2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3    ;mov r1 0, mov r2 0, mov r3 0,mov r4 r0
  ;call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %2)   ;mov r5 0,mov r6 0,mov r7 0,mov r8 0
  ;call void @set_storage([4 x i64] [i64 1, i64 2, i64 3, i64 4], [4 x i64] [i64 5, i64 6, i64 7, i64 8])
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] [i64 5, i64 6, i64 7, i64 8])
  %3 = call [4 x i64] @get_storage([4 x i64] [i64 1, i64 2, i64 3, i64 4])
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %3)
  %4 = call [4 x i64] @poseidon_hash([8 x i64] [i64 10, i64 20, i64 30, i64 40, i64 50, i64 60, i64 70, i64 80])
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
            "str_imm:
.LBL10_0:
  add r9 r9 1
  mov r5 r1
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 5
  mov r6 6
  mov r7 7
  mov r8 8
  sstore 
  mov r1 1
  mov r2 2
  mov r3 3
  mov r4 4
  sload 
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mov r8 r4
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sstore 
  mov r1 10
  mov r2 20
  mov r3 30
  mov r4 40
  mov r5 50
  mov r6 60
  mov r7 70
  mov r8 80
  poseidon 
  add r9 r9 -1
  ret
"
        );
    }

    #[test]
    fn codegen_str_u32_var_test() {
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

define void @str_var(i64 %0) {   ;mstore [r9,-1] r1 
entry:
  %3 = call [4 x i64] @get_storage([4 x i64] [i64 1, i64 2, i64 3, i64 4])
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %3)
  %4 = call [4 x i64] @poseidon_hash([8 x i64] [i64 10, i64 20, i64 30, i64 40, i64 50, i64 60, i64 70, i64 80])
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
            "str_var:
.LBL10_0:
  mov r5 r1
  mov r1 1
  mov r2 2
  mov r3 3
  mov r4 4
  sload 
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mov r8 r4
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sstore 
  mov r1 10
  mov r2 20
  mov r3 30
  mov r4 40
  mov r5 50
  mov r6 60
  mov r7 70
  mov r8 80
  poseidon 
  ret
"
        );
    }

    #[test]
    fn codegen_str_poseidon_imm_test() {
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

define void @str_var(i64 %0) {   ;mstore [r9,-1] r1 
entry:
  %3 = call [4 x i64] @get_storage([4 x i64] [i64 1, i64 2, i64 3, i64 4])
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %3)
  %4 = call [4 x i64] @poseidon_hash([8 x i64] [i64 10, i64 20, i64 30, i64 40, i64 50, i64 60, i64 70, i64 80])
  call void @set_storage([4 x i64] [i64 5, i64 6, i64 7, i64 8], [4 x i64] %4)
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
            "str_var:
.LBL10_0:
  mov r5 r1
  mov r1 1
  mov r2 2
  mov r3 3
  mov r4 4
  sload 
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mov r8 r4
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sstore 
  mov r1 10
  mov r2 20
  mov r3 30
  mov r4 40
  mov r5 50
  mov r6 60
  mov r7 70
  mov r8 80
  poseidon 
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mov r8 r4
  mov r1 5
  mov r2 6
  mov r3 7
  mov r4 8
  sstore 
  ret
"
        );
    }

    #[test]
    fn codegen_str_poseidon_var_test() {
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

define void @str_var(i64 %6, i64 %7) { 
entry:
  %0 = add i64 %6, 666
  %1 = add i64 %0, 888
  %8 = insertvalue [8 x i64] undef, i64 %0, 7
  %9 = insertvalue [8 x i64] %8, i64 %6, 6
  %10 = insertvalue [8 x i64] %9, i64 %1, 5
  %11 = insertvalue [8 x i64] %10, i64 100 , 4
  %12 = insertvalue [8 x i64] %11, i64 200, 3
  %13 = insertvalue [8 x i64] %12, i64 30, 2
  %14 = insertvalue [8 x i64] %13, i64 20, 1
  %15 = insertvalue [8 x i64] %14, i64 10, 0
  %16 = call [4 x i64] @poseidon_hash([8 x i64] %15)
  call void @set_storage([4 x i64] [i64 5, i64 6, i64 7, i64 8], [4 x i64] %16)
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
            "str_var:
.LBL10_0:
  add r9 r9 7
  mov r7 r1
  mov r8 r2
  add r5 r7 666
  mov r8 0
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mstore [r9,-1] r4
  mov r4 0
  mstore [r9,-2] r4
  mov r4 0
  mstore [r9,-3] r4
  mov r4 r5
  mstore [r9,-4] r4
  mload r4 [r9,-1]
  mstore [r9,-5] r4
  mload r4 [r9,-2]
  mstore [r9,-6] r4
  mov r7 r7
  mload r4 [r9,-4]
  mstore [r9,-7] r4
  add r6 r5 888
  mov r5 r8
  mov r8 r1
  mov r1 r2
  mov r2 r3
  mload r3 [r9,-5]
  mov r6 r6
  mload r3 [r9,-7]
  mov r2 100
  mov r4 200
  mov r1 r2
  mov r2 r3
  mov r3 30
  mov r8 r1
  mov r1 r2
  mov r2 20
  mov r5 r8
  mov r8 r1
  mov r1 10
  poseidon 
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mov r8 r4
  mov r1 5
  mov r2 6
  mov r3 7
  mov r4 8
  sstore 
  add r9 r9 -7
  ret
"
        );
        /*
        .LBL10_0:
          add r9 r9 21
          mov r0 r1
          mov r1 r2
          mov r2 r3
          mov r3 0
          mov r4 0
          mov r5 0
          mov r6 0
          mstore [r9,-1] r6
          mov r6 0
          mstore [r9,-2] r6
          mov r6 0
          mstore [r9,-3] r6
          mov r6 0
          mstore [r9,-4] r6
          mov r6 0
          mstore [r9,-5] r6
          mload r6 [r9,-1]
          mstore [r9,-6] r6
          mload r6 [r9,-2]
          mstore [r9,-7] r6
          mload r6 [r9,-3]
          mstore [r9,-8] r6
          mload r6 [r9,-4]
          mstore [r9,-9] r6
          mload r6 [r9,-6]
          mstore [r9,-10] r6
          mload r6 [r9,-7]
          mstore [r9,-11] r6
          mload r6 [r9,-8]
          mstore [r9,-12] r6
          mload r6 [r9,-10]
          mstore [r9,-13] r6
          mload r6 [r9,-11]
          mstore [r9,-14] r6
          mload r6 [r9,-13]
          mstore [r9,-15] r6
          mov r6 50
          mstore [r9,-16] r6
          mov r5 40
          mload r6 [r9,-16]
          mstore [r9,-17] r6
          mov r4 30
          mload r6 [r9,-17]
          mstore [r9,-18] r6
          mov r3 20
          mload r6 [r9,-18]
          mstore [r9,-19] r6
          mov r6 10
          mstore [r9,-20] r6
          mload r6 [r9,-19]
          mstore [r9,-21] r6
          add r6 r0 0
          add r7 r1 0
          add r8 r2 0
          mload r0 [r9,-20]
          mov r1 r0
          mov r2 r3
          mov r3 r4
          mov r4 r5
          mload r0 [r9,-21]
          mov r5 r0
          poseidon
          add r9 r9 -21
          ret
        */
        /*
        str_var:
        .LBL10_0:
          add r9 r9 21
          mov r0 r1
          mov r1 r2
          mov r2 r3
          mov r3 0
          mov r4 0
          mov r5 0
          mov r6 0
          mstore [r9,-1] r6
          mov r6 0
          mstore [r9,-2] r6
          mov r6 0
          mstore [r9,-3] r6
          mov r6 0
          mstore [r9,-4] r6
          mov r6 0
          mstore [r9,-5] r6
          add r3 r3 0
          add r4 r4 0
          add r5 r5 0
          mload r6 [r9,-1]
          add r6 r6 0
          mstore [r9,-6] r6
          mload r6 [r9,-2]
          add r6 r6 0
          mstore [r9,-7] r6
          mload r6 [r9,-3]
          add r6 r6 0
          mstore [r9,-8] r6
          mload r6 [r9,-4]
          add r6 r6 0
          mstore [r9,-9] r6
          add r2 r2 0
          add r3 r3 0
          add r4 r4 0
          add r5 r5 0
          mload r6 [r9,-6]
          add r6 r6 0
          mstore [r9,-10] r6
          mload r6 [r9,-7]
          add r6 r6 0
          mstore [r9,-11] r6
          mload r6 [r9,-8]
          add r6 r6 0
          mstore [r9,-12] r6
          add r1 r1 0
          add r2 r2 0
          add r3 r3 0
          add r4 r4 0
          add r5 r5 0
          mload r6 [r9,-10]
          add r6 r6 0
          mstore [r9,-13] r6
          mload r6 [r9,-11]
          add r6 r6 0
          mstore [r9,-14] r6
          add r0 r0 0
          add r1 r1 0
          add r2 r2 0
          add r3 r3 0
          add r4 r4 0
          add r5 r5 0
          mload r6 [r9,-13]
          add r6 r6 0
          mstore [r9,-15] r6
          add r6 50 0
          mstore [r9,-16] r6
          add r0 r0 0
          add r1 r1 0
          add r2 r2 0
          add r3 r3 0
          add r4 r4 0
          add r5 r5 0
          add r5 40 0
          mload r6 [r9,-16]
          add r6 r6 0
          mstore [r9,-17] r6
          add r0 r0 0
          add r1 r1 0
          add r2 r2 0
          add r3 r3 0
          add r4 r4 0
          add r4 30 0
          add r5 r5 0
          mload r6 [r9,-17]
          add r6 r6 0
          mstore [r9,-18] r6
          add r0 r0 0
          add r1 r1 0
          add r2 r2 0
          add r3 r3 0
          add r3 20 0
          add r4 r4 0
          add r5 r5 0
          mload r6 [r9,-18]
          add r6 r6 0
          mstore [r9,-19] r6
          add r0 r0 0
          add r1 r1 0
          add r2 r2 0
          add r6 10 0
          mstore [r9,-20] r6
          add r3 r3 0
          add r4 r4 0
          add r5 r5 0
          mload r6 [r9,-19]
          add r6 r6 0
          mstore [r9,-21] r6
          add r6 r0 0
          add r7 r1 0
          add r8 r2 0
          mload r0 [r9,-20]
          mov r1 r0
          mov r2 r3
          mov r3 r4
          mov r4 r5
          mload r0 [r9,-21]
          mov r5 r0
          poseidon
          add r9 r9 -21
          ret
         */
    }

    #[ignore]
    #[test]
    fn codegen_str_binop_test() {
        // LLVM Assembly
        let asm = r#"
  source_filename = "asm"
  ; Function Attrs: noinline nounwind optnone uwtable
  define dso_local i32 @main() #0 {
    %a = alloca i32, align 4
    store i32 10, i32* %a
    %b = load i32, i32* %a
    %c = add i32 %b, 20 ; 30
    %d = add i32 %b, 30 ; 60
    %e = mul i32 %c, %d ; 1800
    ;%f = sub i32 %e, %d ; 1740
    ;call void @ordinary_call(i64 100,i64 %b, i64 %e)
    %d1 = add i32 %d, 1000
    %d2 = add i32 %d1, 2000
    %d3 = add i32 %d2, 3000
    %d4 = add i32 %d3, 4000
    %d5 = add i32 %d4, 5000
    %d6 = add i32 %d5, 6000
    %d7 = add i32 %d5, %d6
    %d8 = add i32 %d5, %d7
    %d9 = add i32 %d7, %d8
    call void @set_storage(i64 %d9, i64 %b, i64 2, i64 3, i64 4, i64 5, i64 6, i64 %e)
    ;call void @get_storage(i64 10, i64 20, i64 30, i64 40, i64 50, i64 60, i64 70, i64 %c)
    %g = add i32 %d9, 666
    ret i32 %g
  }
  attributes #0 = { noinline nounwind optnone uwtable }
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
.LBL0_0:
  add r8 r8 12
  mov r1 10
  mstore [r8,-1] r1
  mload r1 [r8,-1]
  add r0 r1 20
  add r2 r1 30
  mstore [r8,-2] r2
  mload r2 [r8,-2]
  mul r7 r0 r2
  mov r6 6
  mov r5 5
  mov r4 4
  mov r3 3
  mov r2 2
  mload r0 [r8,-2]
  add r0 r0 1000
  mstore [r8,-3] r0
  mload r0 [r8,-3]
  add r0 r0 2000
  mstore [r8,-4] r0
  mload r0 [r8,-4]
  add r0 r0 3000
  mstore [r8,-5] r0
  mload r0 [r8,-5]
  add r0 r0 4000
  mstore [r8,-6] r0
  mload r0 [r8,-6]
  add r0 r0 5000
  mstore [r8,-8] r0
  mload r0 [r8,-8]
  add r0 r0 6000
  mstore [r8,-7] r0
  mload r0 [r8,-7]
  mload r1 [r8,-8]
  add r0 r1 r0
  mstore [r8,-9] r0
  mload r0 [r8,-8]
  mload r1 [r8,-9]
  add r0 r0 r1
  mstore [r8,-10] r0
  mload r0 [r8,-9]
  mload r1 [r8,-10]
  add r0 r0 r1
  mstore [r8,-11] r0
  mload r0 [r8,-11]
  sstore 
  mload r0 [r8,-11]
  add r0 r0 666
  mstore [r8,-12] r0
  mload r0 [r8,-12]
  add r8 r8 -12
  end
"
        );
    }

    #[test]
    fn codegen_functioncall_test() {
        // LLVM Assembly
        let asm = r#"
source_filename = "asm"

; Function Attrs: noinline nounwind optnone ssp uwtable
define void @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 10, i32* %1, align 4
  store i32 20, i32* %2, align 4
  store i32 100, i32* %3, align 4
  %4 = load i32, i32* %1, align 4
  %5 = load i32, i32* %2, align 4
  %6 = call i32 @bar(i32 %4, i32 %5)
  store i32 %6, i32* %3, align 4
  %7 = load i32, i32* %3, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @bar(i32 %0, i32 %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  store i32 %1, i32* %4, align 4
  store i32 200, i32* %5, align 4
  %6 = load i32, i32* %3, align 4
  %7 = load i32, i32* %4, align 4
  %8 = add nsw i32 %6, %7
  store i32 %8, i32* %5, align 4
  %9 = load i32, i32* %5, align 4
  ret i32 %9
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
.LBL0_0:
  add r9 r9 5
  mstore [r9,-2] r9
  mov r5 10
  mstore [r9,-3] r5
  mov r5 20
  mstore [r9,-4] r5
  mov r5 100
  mstore [r9,-5] r5
  mload r1 [r9,-3]
  mload r2 [r9,-4]
  call bar
  mov r5 r0
  mstore [r9,-5] r5
  mload r5 [r9,-5]
  add r9 r9 -5
  end
bar:
.LBL1_0:
  add r9 r9 3
  mov r6 r1
  mov r7 r2
  mstore [r9,-1] r6
  mstore [r9,-2] r7
  mov r6 200
  mstore [r9,-3] r6
  mload r6 [r9,-1]
  mload r7 [r9,-2]
  add r5 r6 r7
  mstore [r9,-3] r5
  mload r0 [r9,-3]
  add r9 r9 -3
  ret
"
        );
    }

    #[test]
    fn codegen_functioncall_multiparams_test() {
        // LLVM Assembly
        let asm = r#"
source_filename = "asm"

; Function Attrs: noinline nounwind optnone ssp uwtable
define void @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  store i32 10, i32* %1, align 4
  store i32 20, i32* %2, align 4
  store i32 30, i32* %3, align 4
  store i32 40, i32* %4, align 4
  %5 = load i32, i32* %1, align 4
  %6 = load i32, i32* %2, align 4
  %7 = load i32, i32* %3, align 4
  %8 = load i32, i32* %4, align 4
  %9 = call i32 @add(i32 %5, i32 %6, i32 %7, i32 %8)
  store i32 %9, i32* %1, align 4
  %10 = load i32, i32* %1, align 4
  ret void
}

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @bar(i32 %0, i32 %1, i32 %2, i32 %3) #0 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 %0, i32* %4, align 4
  store i32 %1, i32* %5, align 4
  store i32 %2, i32* %6, align 4
  store i32 %3, i32* %7, align 4
  %8 = load i32, i32* %4, align 4
  %9 = load i32, i32* %5, align 4
  %10 = load i32, i32* %6, align 4
  %11 = load i32, i32* %7, align 4
  %12 = add nsw i32 %8, %9
  %13 = add nsw i32 %10, %11
  %14 = add nsw i32 %12, %13
  store i32 %14, i32* %4, align 4
  %15 = load i32, i32* %4, align 4
  ret i32 %15
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
.LBL0_0:
  add r9 r9 6
  mstore [r9,-2] r9
  mov r5 10
  mstore [r9,-3] r5
  mov r5 20
  mstore [r9,-4] r5
  mov r5 30
  mstore [r9,-5] r5
  mov r5 40
  mstore [r9,-6] r5
  mload r1 [r9,-3]
  mload r2 [r9,-4]
  mload r3 [r9,-5]
  mload r4 [r9,-6]
  call add
  mov r5 r0
  mstore [r9,-3] r5
  mload r5 [r9,-3]
  add r9 r9 -6
  end
bar:
.LBL1_0:
  add r9 r9 4
  mov r8 r1
  mov r1 r2
  mov r2 r3
  mov r3 r4
  mstore [r9,-1] r8
  mstore [r9,-2] r1
  mstore [r9,-3] r2
  mstore [r9,-4] r3
  mload r8 [r9,-1]
  mload r1 [r9,-2]
  mload r2 [r9,-3]
  mload r3 [r9,-4]
  add r5 r8 r1
  add r6 r2 r3
  add r7 r5 r6
  mstore [r9,-1] r7
  mload r0 [r9,-1]
  add r9 r9 -4
  ret
"
        );
    }

    #[test]
    fn codegen_fib_test() {
        // LLVM Assembly
        let asm = r#"
    ; ModuleID = 'Fibonacci'
source_filename = "fib.ola"

define void @main() {
entry:
  %0 = call i32 @fib_non_recursive(i32 10)
  ret void
}

define i32 @fib_recursive(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp ule i32 %1, 2
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 1

enif:                                             ; preds = %entry
  %3 = load i32, i32* %n, align 4
  %4 = sub i32 %3, 1
  %5 = call i32 @fib_recursive(i32 %4)
  %6 = load i32, i32* %n, align 4
  %7 = sub i32 %6, 2
  %8 = call i32 @fib_recursive(i32 %7)
  %9 = add i32 %5, %8
  ret i32 %9
}

define i32 @fib_non_recursive(i32 %0) {
entry:
  %i = alloca i32, align 4
  %third = alloca i32, align 4
  %second = alloca i32, align 4
  %first = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 0, i32* %first, align 4
  store i32 1, i32* %second, align 4
  store i32 1, i32* %third, align 4
  store i32 2, i32* %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i32, i32* %i, align 4
  %2 = load i32, i32* %n, align 4
  %3 = icmp ule i32 %1, %2
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = load i32, i32* %first, align 4
  %5 = load i32, i32* %second, align 4
  %6 = add i32 %4, %5
  store i32 %6, i32* %third, align 4
  %7 = load i32, i32* %second, align 4
  store i32 %7, i32* %first, align 4
  %8 = load i32, i32* %third, align 4
  store i32 %8, i32* %second, align 4
  br label %next

next:                                             ; preds = %body
  %9 = load i32, i32* %i, align 4
  %10 = add i32 %9, 1
  store i32 %10, i32* %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %11 = load i32, i32* %third, align 4
  ret i32 %11
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
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 10
  call fib_non_recursive
  add r9 r9 -2
  end
fib_recursive:
.LBL1_0:
  add r9 r9 7
  mstore [r9,-2] r9
  mov r5 r1
  mstore [r9,-3] r5
  mload r5 [r9,-3]
  mov r7 2
  gte r5 r7 r5
  cjmp r5 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 1
  add r9 r9 -7
  ret
.LBL1_2:
  mload r5 [r9,-3]
  not r7 1
  add r7 r7 1
  add r1 r5 r7
  call fib_recursive
  mov r5 r0
  mstore [r9,-7] r5
  mload r5 [r9,-3]
  not r7 2
  add r7 r7 1
  add r5 r5 r7
  mstore [r9,-5] r5
  mload r1 [r9,-5]
  call fib_recursive
  mov r5 r0
  mload r6 [r9,-7]
  add r5 r6 r5
  mstore [r9,-4] r5
  mload r0 [r9,-4]
  add r9 r9 -7
  ret
fib_non_recursive:
.LBL2_0:
  add r9 r9 5
  mov r5 r1
  mstore [r9,-5] r5
  mov r5 0
  mstore [r9,-4] r5
  mov r5 1
  mstore [r9,-3] r5
  mov r5 1
  mstore [r9,-2] r5
  mov r5 2
  mstore [r9,-1] r5
  jmp .LBL2_1
.LBL2_1:
  mload r5 [r9,-1]
  mload r6 [r9,-5]
  gte r5 r6 r5
  cjmp r5 .LBL2_2
  jmp .LBL2_4
.LBL2_2:
  mload r6 [r9,-4]
  mload r7 [r9,-3]
  add r5 r6 r7
  mstore [r9,-2] r5
  mload r5 [r9,-3]
  mstore [r9,-4] r5
  mload r5 [r9,-2]
  mstore [r9,-3] r5
  jmp .LBL2_3
.LBL2_3:
  mload r6 [r9,-1]
  add r5 r6 1
  mstore [r9,-1] r5
  jmp .LBL2_1
.LBL2_4:
  mload r0 [r9,-2]
  add r9 r9 -5
  ret
"
        );
    }

    #[test]
    fn codegen_condbr_test() {
        // LLVM Assembly
        let asm = r#"
  source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @eq_rr(i32 1)
  ret void
}

define i32 @eq_ri(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp eq i32 %1, 1
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @eq_rr(i32 %0) {
entry:
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 1, i32* %m, align 4
  %1 = load i32, i32* %n, align 4
  %2 = load i32, i32* %m, align 4
  %3 = icmp eq i32 %1, %2
  br i1 %3, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @neq_ri(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp ne i32 %1, 1
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @neq_rr(i32 %0) {
entry:
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 1, i32* %m, align 4
  %1 = load i32, i32* %n, align 4
  %2 = load i32, i32* %m, align 4
  %3 = icmp ne i32 %1, %2
  br i1 %3, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @lt_ri(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp ult i32 %1, 1
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @lt_rr(i32 %0) {
entry:
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 1, i32* %m, align 4
  %1 = load i32, i32* %n, align 4
  %2 = load i32, i32* %m, align 4
  %3 = icmp ult i32 %1, %2
  br i1 %3, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @lte_ri(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp ule i32 %1, 1
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @lte_rr(i32 %0) {
entry:
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 1, i32* %m, align 4
  %1 = load i32, i32* %n, align 4
  %2 = load i32, i32* %m, align 4
  %3 = icmp ule i32 %1, %2
  br i1 %3, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @gt_ri(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp ugt i32 %1, 1
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @gt_rr(i32 %0) {
entry:
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 1, i32* %m, align 4
  %1 = load i32, i32* %n, align 4
  %2 = load i32, i32* %m, align 4
  %3 = icmp ugt i32 %1, %2
  br i1 %3, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @gte_ri(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp uge i32 %1, 1
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}

define i32 @gte_rr(i32 %0) {
entry:
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 1, i32* %m, align 4
  %1 = load i32, i32* %n, align 4
  %2 = load i32, i32* %m, align 4
  %3 = icmp uge i32 %1, %2
  br i1 %3, label %then, label %enif

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
        println!("{}", code.program);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
  call eq_rr
  add r9 r9 -2
  end
eq_ri:
.LBL1_0:
  add r9 r9 1
  mov r5 r1
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  eq r5 r5 1
  cjmp r5 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  add r9 r9 -1
  ret
.LBL1_2:
  mov r0 3
  add r9 r9 -1
  ret
eq_rr:
.LBL2_0:
  add r9 r9 2
  mov r5 r1
  mstore [r9,-2] r5
  mov r5 1
  mstore [r9,-1] r5
  mload r5 [r9,-2]
  mload r6 [r9,-1]
  eq r5 r5 r6
  cjmp r5 .LBL2_1
  jmp .LBL2_2
.LBL2_1:
  mov r0 2
  add r9 r9 -2
  ret
.LBL2_2:
  mov r0 3
  add r9 r9 -2
  ret
neq_ri:
.LBL3_0:
  add r9 r9 1
  mov r5 r1
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  neq r5 r5 1
  cjmp r5 .LBL3_1
  jmp .LBL3_2
.LBL3_1:
  mov r0 2
  add r9 r9 -1
  ret
.LBL3_2:
  mov r0 3
  add r9 r9 -1
  ret
neq_rr:
.LBL4_0:
  add r9 r9 2
  mov r5 r1
  mstore [r9,-2] r5
  mov r5 1
  mstore [r9,-1] r5
  mload r5 [r9,-2]
  mload r6 [r9,-1]
  neq r5 r5 r6
  cjmp r5 .LBL4_1
  jmp .LBL4_2
.LBL4_1:
  mov r0 2
  add r9 r9 -2
  ret
.LBL4_2:
  mov r0 3
  add r9 r9 -2
  ret
lt_ri:
.LBL5_0:
  add r9 r9 1
  mov r5 r1
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  mov r6 1
  gte r6 r6 r5
  neq r5 r5 1
  and r6 r6 r5
  cjmp r6 .LBL5_1
  jmp .LBL5_2
.LBL5_1:
  mov r0 2
  add r9 r9 -1
  ret
.LBL5_2:
  mov r0 3
  add r9 r9 -1
  ret
lt_rr:
.LBL6_0:
  add r9 r9 2
  mov r5 r1
  mstore [r9,-2] r5
  mov r5 1
  mstore [r9,-1] r5
  mload r5 [r9,-2]
  mload r6 [r9,-1]
  gte r7 r6 r5
  neq r5 r5 r6
  and r7 r7 r5
  cjmp r7 .LBL6_1
  jmp .LBL6_2
.LBL6_1:
  mov r0 2
  add r9 r9 -2
  ret
.LBL6_2:
  mov r0 3
  add r9 r9 -2
  ret
lte_ri:
.LBL7_0:
  add r9 r9 1
  mov r5 r1
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  mov r7 1
  gte r5 r7 r5
  cjmp r5 .LBL7_1
  jmp .LBL7_2
.LBL7_1:
  mov r0 2
  add r9 r9 -1
  ret
.LBL7_2:
  mov r0 3
  add r9 r9 -1
  ret
lte_rr:
.LBL8_0:
  add r9 r9 2
  mov r5 r1
  mstore [r9,-2] r5
  mov r5 1
  mstore [r9,-1] r5
  mload r5 [r9,-2]
  mload r6 [r9,-1]
  gte r5 r6 r5
  cjmp r5 .LBL8_1
  jmp .LBL8_2
.LBL8_1:
  mov r0 2
  add r9 r9 -2
  ret
.LBL8_2:
  mov r0 3
  add r9 r9 -2
  ret
gt_ri:
.LBL9_0:
  add r9 r9 1
  mov r5 r1
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  gte r6 r5 1
  neq r5 r5 1
  and r6 r6 r5
  cjmp r6 .LBL9_1
  jmp .LBL9_2
.LBL9_1:
  mov r0 2
  add r9 r9 -1
  ret
.LBL9_2:
  mov r0 3
  add r9 r9 -1
  ret
gt_rr:
.LBL10_0:
  add r9 r9 2
  mov r5 r1
  mstore [r9,-2] r5
  mov r5 1
  mstore [r9,-1] r5
  mload r5 [r9,-2]
  mload r6 [r9,-1]
  gte r7 r5 r6
  neq r5 r5 r6
  and r7 r7 r5
  cjmp r7 .LBL10_1
  jmp .LBL10_2
.LBL10_1:
  mov r0 2
  add r9 r9 -2
  ret
.LBL10_2:
  mov r0 3
  add r9 r9 -2
  ret
gte_ri:
.LBL11_0:
  add r9 r9 1
  mov r5 r1
  mstore [r9,-1] r5
  mload r5 [r9,-1]
  gte r5 r5 1
  cjmp r5 .LBL11_1
  jmp .LBL11_2
.LBL11_1:
  mov r0 2
  add r9 r9 -1
  ret
.LBL11_2:
  mov r0 3
  add r9 r9 -1
  ret
gte_rr:
.LBL12_0:
  add r9 r9 2
  mov r5 r1
  mstore [r9,-2] r5
  mov r5 1
  mstore [r9,-1] r5
  mload r5 [r9,-2]
  mload r6 [r9,-1]
  gte r5 r5 r6
  cjmp r5 .LBL12_1
  jmp .LBL12_2
.LBL12_1:
  mov r0 2
  add r9 r9 -2
  ret
.LBL12_2:
  mov r0 3
  add r9 r9 -2
  ret
"
        );
    }

    #[test]
    fn codegen_sqrt_test() {
        // LLVM Assembly
        let asm = r#"
        ; ModuleID = 'SqrtContract'
        source_filename = "examples/sqrt.ola"

        declare void @builtin_assert(i64, i64)

        declare void @builtin_range_check(i64)

        declare i64 @prophet_u32_sqrt(i64)

        define i64 @u32_sqrt(i64 %0) {
        entry:
          %1 = call i64 @prophet_u32_sqrt(i64 %0)
          call void @builtin_range_check(i64 %1)
          %2 = mul i64 %1, %1
          call void @builtin_assert(i64 %2, i64 %0)
          ret i64 %1
        }

        define void @main() {
        entry:
          %0 = call i64 @sqrt_test(i64 4)
          ret void
        }

        define i64 @sqrt_test(i64 %0) {
        entry:
          %b = alloca i64, align 8
          %n = alloca i64, align 8
          store i64 %0, i64* %n, align 8
          %1 = load i64, i64* %n, align 8
          %2 = call i64 @u32_sqrt(i64 %1)
          store i64 %2, i64* %b, align 8
          %3 = load i64, i64* %b, align 8
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
        println!("{}", code.program);
        println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "u32_sqrt:
.LBL3_0:
  mov r6 r1
  mov r1 r6
.PROPHET3_0:
  mov r0 psp
  mload r0 [r0]
  range r0
  mul r5 r0 r0
  assert r5 r6
  ret
main:
.LBL4_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 4
  call sqrt_test
  add r9 r9 -2
  end
sqrt_test:
.LBL5_0:
  add r9 r9 4
  mstore [r9,-2] r9
  mov r5 r1
  mstore [r9,-4] r5
  mload r1 [r9,-4]
  call u32_sqrt
  mov r5 r0
  mstore [r9,-3] r5
  mload r0 [r9,-3]
  add r9 r9 -4
  ret
"
        );
        assert_eq!(
            format!("{:#?}", code.prophets),
            r#"[
    Prophet {
        label: ".PROPHET3_0",
        code: "%{\n    entry() {\n        cid.y = sqrt(cid.x);\n    }\n%}",
        inputs: [
            Input {
                name: "cid.x",
                length: 1,
                is_ref: false,
                is_input_output: false,
            },
        ],
        outputs: [
            Output {
                name: "cid.y",
                length: 1,
                is_ref: false,
                is_input_output: false,
            },
        ],
    },
]"#
        );
    }

    #[test]
    fn codegen_sqrt_inst_test() {
        // LLVM Assembly
        let asm = r#"
; ModuleID = 'SqrtContract'
source_filename = "examples/sqrt.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

define void @main() {
entry:
  %0 = call i64 @sqrt_test(i64 4)
  ret void
}

define i64 @sqrt_test(i64 %0) {
entry:
  %i = alloca i64, align 8
  %x = alloca i64, align 8
  %result = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, i64* %a, align 8
  store i64 0, i64* %result, align 8
  %1 = load i64, i64* %a, align 8
  %2 = icmp ugt i64 %1, 3
  br i1 %2, label %then, label %else

then:                                             ; preds = %entry
  %3 = load i64, i64* %a, align 8
  store i64 %3, i64* %result, align 4
  %4 = load i64, i64* %a, align 8
  %5 = call i64 @prophet_u32_mod(i64 %4, i64 2)
  call void @builtin_range_check(i64 %5)
  %6 = add i64 %5, 1
  %7 = sub i64 2, %6
  call void @builtin_range_check(i64 %7)
  %8 = call i64 @prophet_u32_div(i64 %4, i64 2)
  call void @builtin_range_check(i64 %8)
  %9 = mul i64 %8, 2
  %10 = add i64 %9, %5
  call void @builtin_assert(i64 %10, i64 %4)
  %11 = add i64 %8, 1
  call void @builtin_range_check(i64 %11)
  store i64 %11, i64* %x, align 8
  store i64 0, i64* %i, align 8
  br label %cond

else:                                             ; preds = %entry
  %12 = load i64, i64* %a, align 8
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %then3, label %enif4

enif:                                             ; preds = %enif4, %endfor
  %14 = load i64, i64* %result, align 8
  ret i64 %14

cond:                                             ; preds = %next, %then
  %15 = load i64, i64* %i, align 8
  %16 = icmp ult i64 %15, 100
  br i1 %16, label %body, label %endfor

body:                                             ; preds = %cond
  %17 = load i64, i64* %x, align 8
  %18 = load i64, i64* %result, align 8
  %19 = icmp uge i64 %17, %18
  br i1 %19, label %then1, label %enif2

next:                                             ; preds = %enif2
  %20 = load i64, i64* %i, align 8
  %21 = add i64 %20, 1
  store i64 %21, i64* %i, align 8
  br label %cond

endfor:                                           ; preds = %then1, %cond
  br label %enif

then1:                                            ; preds = %body
  br label %endfor

enif2:                                            ; preds = %body
  %22 = load i64, i64* %x, align 8
  store i64 %22, i64* %result, align 4
  %23 = load i64, i64* %a, align 8
  %24 = load i64, i64* %x, align 8
  %25 = call i64 @prophet_u32_mod(i64 %23, i64 %24)
  call void @builtin_range_check(i64 %25)
  %26 = add i64 %25, 1
  %27 = sub i64 %24, %26
  call void @builtin_range_check(i64 %27)
  %28 = call i64 @prophet_u32_div(i64 %23, i64 %24)
  call void @builtin_range_check(i64 %28)
  %29 = mul i64 %28, %24
  %30 = add i64 %29, %25
  call void @builtin_assert(i64 %30, i64 %23)
  %31 = load i64, i64* %x, align 8
  %32 = add i64 %28, %31
  call void @builtin_range_check(i64 %32)
  %33 = call i64 @prophet_u32_mod(i64 %32, i64 2)
  call void @builtin_range_check(i64 %33)
  %34 = add i64 %33, 1
  %35 = sub i64 2, %34
  call void @builtin_range_check(i64 %35)
  %36 = call i64 @prophet_u32_div(i64 %32, i64 2)
  call void @builtin_range_check(i64 %36)
  %37 = mul i64 %36, 2
  %38 = add i64 %37, %33
  call void @builtin_assert(i64 %38, i64 %32)
  store i64 %36, i64* %x, align 4
  br label %next

then3:                                            ; preds = %else
  store i64 1, i64* %result, align 4
  br label %enif4

enif4:                                            ; preds = %then3, %else
  br label %enif
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
.LBL5_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 4
  call sqrt_test
  add r9 r9 -2
  end
sqrt_test:
.LBL6_0:
  add r9 r9 15
  mov r5 r1
  mstore [r9,-4] r5
  mov r5 0
  mstore [r9,-3] r5
  mload r5 [r9,-4]
  gte r6 r5 3
  neq r5 r5 3
  and r6 r6 r5
  cjmp r6 .LBL6_1
  jmp .LBL6_2
.LBL6_1:
  mload r7 [r9,-4]
  mstore [r9,-3] r7
  mload r7 [r9,-4]
  mstore [r9,-6] r7
  mload r7 [r9,-6]
  mov r1 r7
  mov r2 2
.PROPHET6_0:
  mov r0 psp
  mload r0 [r0]
  mov r7 r0
  mstore [r9,-7] r7
  mload r7 [r9,-7]
  range r7
  mov r1 2
  mload r7 [r9,-7]
  add r5 r7 1
  not r7 r5
  add r7 r7 1
  add r6 r1 r7
  range r6
  mload r5 [r9,-6]
  mov r1 r5
  mov r2 2
.PROPHET6_1:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  range r5
  mul r8 r5 2
  mload r6 [r9,-7]
  add r3 r8 r6
  mload r6 [r9,-6]
  assert r3 r6
  add r5 r5 1
  mstore [r9,-5] r5
  mload r5 [r9,-5]
  range r5
  mload r5 [r9,-5]
  mstore [r9,-2] r5
  mov r5 0
  mstore [r9,-1] r5
  jmp .LBL6_4
.LBL6_2:
  mload r5 [r9,-4]
  neq r5 r5 0
  cjmp r5 .LBL6_10
  jmp .LBL6_11
.LBL6_3:
  mload r0 [r9,-3]
  add r9 r9 -15
  ret
.LBL6_4:
  mload r5 [r9,-1]
  mov r6 100
  gte r6 r6 r5
  neq r5 r5 100
  and r6 r6 r5
  cjmp r6 .LBL6_5
  jmp .LBL6_7
.LBL6_5:
  mload r5 [r9,-2]
  mload r6 [r9,-3]
  gte r5 r5 r6
  cjmp r5 .LBL6_8
  jmp .LBL6_9
.LBL6_6:
  mload r6 [r9,-1]
  add r5 r6 1
  mstore [r9,-1] r5
  jmp .LBL6_4
.LBL6_7:
  jmp .LBL6_3
.LBL6_8:
  jmp .LBL6_7
.LBL6_9:
  mload r7 [r9,-2]
  mstore [r9,-3] r7
  mload r7 [r9,-4]
  mstore [r9,-13] r7
  mload r7 [r9,-2]
  mstore [r9,-14] r7
  mload r7 [r9,-13]
  mov r1 r7
  mload r7 [r9,-14]
  mov r2 r7
.PROPHET6_2:
  mov r0 psp
  mload r0 [r0]
  mov r7 r0
  mstore [r9,-15] r7
  mload r7 [r9,-15]
  range r7
  mload r7 [r9,-15]
  add r5 r7 1
  not r7 r5
  add r7 r7 1
  mload r5 [r9,-14]
  add r6 r5 r7
  range r6
  mload r5 [r9,-13]
  mov r1 r5
  mload r5 [r9,-14]
  mov r2 r5
.PROPHET6_3:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  range r5
  mload r6 [r9,-14]
  mul r8 r5 r6
  mload r6 [r9,-15]
  add r3 r8 r6
  mload r6 [r9,-13]
  assert r3 r6
  mload r6 [r9,-2]
  add r5 r5 r6
  mstore [r9,-11] r5
  mload r5 [r9,-11]
  range r5
  mload r5 [r9,-11]
  mov r1 r5
  mov r2 2
.PROPHET6_4:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  range r5
  mov r6 2
  add r7 r5 1
  mstore [r9,-8] r7
  mload r7 [r9,-8]
  not r7 r7
  add r7 r7 1
  add r6 r6 r7
  mstore [r9,-9] r6
  mload r6 [r9,-9]
  range r6
  mload r6 [r9,-11]
  mov r1 r6
  mov r2 2
.PROPHET6_5:
  mov r0 psp
  mload r0 [r0]
  mov r6 r0
  range r6
  mul r7 r6 2
  mstore [r9,-10] r7
  mload r7 [r9,-10]
  add r5 r7 r5
  mstore [r9,-12] r5
  mload r5 [r9,-11]
  mload r7 [r9,-12]
  assert r7 r5
  mstore [r9,-2] r6
  jmp .LBL6_6
.LBL6_10:
  mov r5 1
  mstore [r9,-3] r5
  jmp .LBL6_11
.LBL6_11:
  jmp .LBL6_3
"
        );
    }

    #[test]
    fn codegen_vote_test() {
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

define void @contract_init(ptr %0) {
entry:
  %1 = alloca [4 x i64], align 8
  %index_alloca13 = alloca i64, align 8
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
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
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
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %13 = sub i64 %length2, 1
  %14 = sub i64 %13, %12
  call void @builtin_range_check(i64 %14)
  %data = getelementptr inbounds { i64, ptr }, ptr %proposalNames_, i32 0, i32 1
  %index_access = getelementptr { i64, ptr }, ptr %data, i64 %12
  store ptr %index_access, ptr %"struct member", align 8
  %"struct member3" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 0, ptr %"struct member3", align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %vector_len4 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 0
  %length5 = load i64, ptr %vector_len4, align 4
  %15 = call [4 x i64] @get_storage([4 x i64] %11)
  %16 = extractvalue [4 x i64] %15, 3
  %17 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length5, 3
  call void @set_storage([4 x i64] %11, [4 x i64] %17)
  %18 = extractvalue [4 x i64] %11, 0
  %19 = extractvalue [4 x i64] %11, 1
  %20 = extractvalue [4 x i64] %11, 2
  %21 = extractvalue [4 x i64] %11, 3
  %22 = insertvalue [8 x i64] undef, i64 %21, 7
  %23 = insertvalue [8 x i64] %22, i64 %20, 6
  %24 = insertvalue [8 x i64] %23, i64 %19, 5
  %25 = insertvalue [8 x i64] %24, i64 %18, 4
  %26 = insertvalue [8 x i64] %25, i64 0, 3
  %27 = insertvalue [8 x i64] %26, i64 0, 2
  %28 = insertvalue [8 x i64] %27, i64 0, 1
  %29 = insertvalue [8 x i64] %28, i64 0, 0
  %30 = call [4 x i64] @poseidon_hash([8 x i64] %29)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %30, ptr %2, align 4
  br label %cond6

next:                                             ; preds = %done12
  %31 = load i64, ptr %i, align 4
  %32 = add i64 %31, 1
  store i64 %32, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond6:                                            ; preds = %body7, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length5
  br i1 %loop_cond, label %body7, label %done

body7:                                            ; preds = %cond6
  %33 = load [4 x i64], ptr %2, align 4
  %data8 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 1
  %index_access9 = getelementptr i64, ptr %data8, i64 %index_value
  %34 = load i64, ptr %index_access9, align 4
  %35 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %34, 3
  call void @set_storage([4 x i64] %33, [4 x i64] %35)
  %36 = extractvalue [4 x i64] %33, 3
  %37 = add i64 %36, 1
  %38 = insertvalue [4 x i64] %33, i64 %37, 3
  store [4 x i64] %38, ptr %2, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond6

done:                                             ; preds = %cond6
  store i64 %length5, ptr %index_alloca13, align 4
  store [4 x i64] %30, ptr %1, align 4
  br label %cond10

cond10:                                           ; preds = %body11, %done
  %index_value14 = load i64, ptr %index_alloca13, align 4
  %loop_cond15 = icmp ult i64 %index_value14, %16
  br i1 %loop_cond15, label %body11, label %done12

body11:                                           ; preds = %cond10
  %39 = load [4 x i64], ptr %1, align 4
  call void @set_storage([4 x i64] %39, [4 x i64] zeroinitializer)
  %40 = extractvalue [4 x i64] %39, 3
  %41 = add i64 %40, 1
  %42 = insertvalue [4 x i64] %39, i64 %41, 3
  store [4 x i64] %42, ptr %1, align 4
  %next_index16 = add i64 %index_value14, 1
  store i64 %next_index16, ptr %index_alloca13, align 4
  br label %cond10

done12:                                           ; preds = %cond10
  %43 = extractvalue [4 x i64] %11, 3
  %44 = add i64 %43, 1
  %45 = insertvalue [4 x i64] %11, i64 %44, 3
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  %46 = load i64, ptr %voteCount, align 4
  %47 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %46, 3
  call void @set_storage([4 x i64] %45, [4 x i64] %47)
  %new_length = add i64 %7, 1
  %48 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2], [4 x i64] %48)
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
  %19 = load i64, ptr %proposal_, align 4
  %20 = load i64, ptr %sender, align 4
  %21 = add i64 %20, 1
  %22 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %21, 3
  %23 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %19, 3
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
  %36 = call [4 x i64] @get_storage([4 x i64] %35)
  %37 = extractvalue [4 x i64] %36, 3
  %38 = add i64 %37, 1
  call void @builtin_range_check(i64 %38)
  %39 = load i64, ptr %proposal_, align 4
  %40 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %41 = extractvalue [4 x i64] %40, 3
  %42 = sub i64 %41, 1
  %43 = sub i64 %42, %39
  call void @builtin_range_check(i64 %43)
  %44 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %45 = extractvalue [4 x i64] %44, 3
  %46 = add i64 %45, %39
  %47 = insertvalue [4 x i64] %44, i64 %46, 3
  %48 = extractvalue [4 x i64] %47, 3
  %49 = add i64 %48, 1
  %50 = insertvalue [4 x i64] %47, i64 %49, 3
  %51 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %38, 3
  call void @set_storage([4 x i64] %50, [4 x i64] %51)
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
  %vector_alloca = alloca { i64, ptr }, align 8
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
  %15 = call i64 @vector_new(i64 %14)
  %int_to_ptr = inttoptr i64 %15 to ptr
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %14, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
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
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %index_value
  %30 = call [4 x i64] @get_storage([4 x i64] %29)
  %31 = extractvalue [4 x i64] %30, 3
  store i64 %31, ptr %index_access, align 4
  store [4 x i64] %29, ptr %0, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %vector_alloca
}

define [4 x i64] @get_caller() {
entry:
  ret [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938]
}

define void @main() {
entry:
  %vector_alloca46 = alloca { i64, ptr }, align 8
  %vector_alloca28 = alloca { i64, ptr }, align 8
  %vector_alloca12 = alloca { i64, ptr }, align 8
  %vector_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %int_to_ptr = inttoptr i64 %0 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %1 = call i64 @vector_new(i64 10)
  %int_to_ptr1 = inttoptr i64 %1 to ptr
  %index_access2 = getelementptr i64, ptr %int_to_ptr1, i64 0
  store i64 80, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %int_to_ptr1, i64 1
  store i64 114, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %int_to_ptr1, i64 2
  store i64 111, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %int_to_ptr1, i64 3
  store i64 112, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %int_to_ptr1, i64 4
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %int_to_ptr1, i64 5
  store i64 115, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %int_to_ptr1, i64 6
  store i64 97, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %int_to_ptr1, i64 7
  store i64 108, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %int_to_ptr1, i64 8
  store i64 32, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %int_to_ptr1, i64 9
  store i64 49, ptr %index_access11, align 4
  %vector_len13 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 0
  store i64 10, ptr %vector_len13, align 4
  %vector_data14 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 1
  store ptr %int_to_ptr1, ptr %vector_data14, align 8
  %vector_len15 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len15, align 4
  %2 = sub i64 %length, 1
  %3 = sub i64 %2, 0
  call void @builtin_range_check(i64 %3)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access16 = getelementptr { i64, ptr }, ptr %data, i64 0
  store ptr %vector_alloca12, ptr %index_access16, align 8
  %4 = call i64 @vector_new(i64 10)
  %int_to_ptr17 = inttoptr i64 %4 to ptr
  %index_access18 = getelementptr i64, ptr %int_to_ptr17, i64 0
  store i64 80, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %int_to_ptr17, i64 1
  store i64 114, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %int_to_ptr17, i64 2
  store i64 111, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %int_to_ptr17, i64 3
  store i64 112, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %int_to_ptr17, i64 4
  store i64 111, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %int_to_ptr17, i64 5
  store i64 115, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %int_to_ptr17, i64 6
  store i64 97, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %int_to_ptr17, i64 7
  store i64 108, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %int_to_ptr17, i64 8
  store i64 32, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %int_to_ptr17, i64 9
  store i64 50, ptr %index_access27, align 4
  %vector_len29 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca28, i32 0, i32 0
  store i64 10, ptr %vector_len29, align 4
  %vector_data30 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca28, i32 0, i32 1
  store ptr %int_to_ptr17, ptr %vector_data30, align 8
  %vector_len31 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length32 = load i64, ptr %vector_len31, align 4
  %5 = sub i64 %length32, 1
  %6 = sub i64 %5, 1
  call void @builtin_range_check(i64 %6)
  %data33 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access34 = getelementptr { i64, ptr }, ptr %data33, i64 1
  store ptr %vector_alloca28, ptr %index_access34, align 8
  %7 = call i64 @vector_new(i64 10)
  %int_to_ptr35 = inttoptr i64 %7 to ptr
  %index_access36 = getelementptr i64, ptr %int_to_ptr35, i64 0
  store i64 80, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %int_to_ptr35, i64 1
  store i64 114, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %int_to_ptr35, i64 2
  store i64 111, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %int_to_ptr35, i64 3
  store i64 112, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %int_to_ptr35, i64 4
  store i64 111, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %int_to_ptr35, i64 5
  store i64 115, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %int_to_ptr35, i64 6
  store i64 97, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %int_to_ptr35, i64 7
  store i64 108, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %int_to_ptr35, i64 8
  store i64 32, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %int_to_ptr35, i64 9
  store i64 51, ptr %index_access45, align 4
  %vector_len47 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca46, i32 0, i32 0
  store i64 10, ptr %vector_len47, align 4
  %vector_data48 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca46, i32 0, i32 1
  store ptr %int_to_ptr35, ptr %vector_data48, align 8
  %vector_len49 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length50 = load i64, ptr %vector_len49, align 4
  %8 = sub i64 %length50, 1
  %9 = sub i64 %8, 2
  call void @builtin_range_check(i64 %9)
  %data51 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access52 = getelementptr { i64, ptr }, ptr %data51, i64 2
  store ptr %vector_alloca46, ptr %index_access52, align 8
  call void @contract_init(ptr %vector_alloca)
  call void @vote_proposal(i64 0)
  call void @vote_proposal(i64 1)
  call void @vote_proposal(i64 0)
  %10 = call ptr @getWinnerName()
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
        //println!("{:#?}",code);
        println!("{}", code.program);
        println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "contract_init:
.LBL11_0:
  add r9 r9 53
  mstore [r9,-2] r9
  mov r5 r1
  mstore [r9,-16] r5
  call get_caller
  mov r5 r0
  mov r6 r1
  mov r7 r2
  mov r8 r3
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sstore 
  mov r5 0
  mstore [r9,-15] r5
  jmp .LBL11_1
.LBL11_1:
  mload r5 [r9,-15]
  mload r6 [r9,-16]
  gte r7 r6 r5
  neq r5 r5 r6
  and r7 r7 r5
  cjmp r7 .LBL11_2
  jmp .LBL11_4
.LBL11_2:
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  mstore [r9,-20] r5
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 2
  poseidon 
  mov r5 r4
  mload r6 [r9,-20]
  add r5 r5 r6
  mstore [r9,-17] r5
  mov r5 r1
  mstore [r9,-21] r5
  mov r5 r2
  mstore [r9,-22] r5
  mov r5 r3
  mstore [r9,-23] r5
  mload r5 [r9,-17]
  mov r5 r5
  mstore [r9,-24] r5
  mload r5 [r9,-15]
  mload r6 [r9,-16]
  not r7 1
  add r7 r7 1
  add r6 r6 r7
  mstore [r9,-18] r6
  not r7 r5
  add r7 r7 1
  mload r6 [r9,-18]
  add r6 r6 r7
  mstore [r9,-19] r6
  mload r6 [r9,-19]
  range r6
  mload r6 [r9,-17]
  mload r5 [r6,r5,+4]
  mstore [r9,-14] r5
  mov r5 0
  mstore [r9,-13] r5
  mload r5 [r9,-14]
  mstore [r9,-25] r5
  mload r5 [r9,-25]
  mload r5 [r5]
  mstore [r9,-26] r5
  mload r5 [r9,-21]
  mov r1 r5
  mload r5 [r9,-22]
  mov r2 r5
  mload r5 [r9,-23]
  mov r3 r5
  mload r5 [r9,-24]
  mov r4 r5
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  mstore [r9,-27] r5
  mov r5 0
  mov r6 0
  mov r7 0
  mload r8 [r9,-26]
  mov r8 r8
  mload r1 [r9,-21]
  mload r1 [r9,-22]
  mov r2 r1
  mload r1 [r9,-23]
  mov r3 r1
  mload r1 [r9,-24]
  mov r4 r1
  sstore 
  mload r5 [r9,-24]
  mov r6 0
  mov r7 0
  mov r8 0
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mstore [r9,-28] r4
  mov r5 r5
  mload r4 [r9,-23]
  mstore [r9,-29] r4
  mload r3 [r9,-29]
  mov r3 r3
  mload r4 [r9,-22]
  mstore [r9,-30] r4
  mload r2 [r9,-30]
  mov r2 r2
  mload r4 [r9,-21]
  mstore [r9,-31] r4
  mload r1 [r9,-31]
  mov r1 r1
  mov r4 0
  mov r8 r1
  mov r1 r2
  mov r2 r3
  mov r3 0
  mov r7 r8
  mov r8 r1
  mov r1 r2
  mov r2 0
  mov r6 r7
  mov r7 r8
  mov r8 r1
  mov r1 0
  mstore [r9,-32] r5
  mov r5 r6
  mov r6 r7
  mov r7 r8
  mload r5 [r9,-32]
  mov r8 r5
  poseidon 
  mov r5 r1
  mstore [r9,-33] r5
  mov r5 r2
  mstore [r9,-34] r5
  mov r5 r3
  mstore [r9,-35] r5
  mov r5 r4
  mstore [r9,-36] r5
  mov r5 0
  mstore [r9,-12] r5
  mload r5 [r9,-36]
  mstore [r9,-11] r5
  mload r5 [r9,-35]
  mstore [r9,-10] r5
  mload r5 [r9,-34]
  mstore [r9,-9] r5
  mload r5 [r9,-33]
  mstore [r9,-8] r5
  jmp .LBL11_5
.LBL11_3:
  mload r6 [r9,-15]
  add r5 r6 1
  mstore [r9,-15] r5
  jmp .LBL11_1
.LBL11_4:
  add r9 r9 -53
  ret
.LBL11_5:
  mload r5 [r9,-12]
  mstore [r9,-37] r5
  mload r5 [r9,-26]
  mload r6 [r9,-37]
  gte r5 r5 r6
  mload r6 [r9,-26]
  mload r7 [r9,-37]
  neq r6 r7 r6
  and r5 r5 r6
  cjmp r5 .LBL11_6
  jmp .LBL11_7
.LBL11_6:
  mload r5 [r9,-8]
  mstore [r9,-40] r5
  mload r5 [r9,-9]
  mstore [r9,-41] r5
  mload r5 [r9,-10]
  mstore [r9,-42] r5
  mload r5 [r9,-11]
  mstore [r9,-43] r5
  mload r5 [r9,-25]
  mload r5 [r5,-4]
  mload r6 [r9,-37]
  mload r5 [r5,r6,+4]
  mov r6 0
  mov r7 0
  mov r8 0
  mov r5 r5
  mstore [r9,-44] r5
  mload r5 [r9,-40]
  mov r1 r5
  mload r5 [r9,-41]
  mov r2 r5
  mload r5 [r9,-42]
  mov r3 r5
  mload r5 [r9,-43]
  mov r4 r5
  mov r5 r6
  mov r6 r7
  mov r7 r8
  mload r5 [r9,-44]
  mov r8 r5
  sstore 
  mload r5 [r9,-43]
  add r5 r5 1
  mstore [r9,-38] r5
  mload r5 [r9,-40]
  mload r6 [r9,-41]
  mload r7 [r9,-42]
  mload r8 [r9,-38]
  mov r8 r8
  mstore [r9,-11] r8
  mstore [r9,-10] r7
  mstore [r9,-9] r6
  mstore [r9,-8] r5
  mload r5 [r9,-37]
  add r5 r5 1
  mstore [r9,-39] r5
  mload r5 [r9,-39]
  mstore [r9,-12] r5
  jmp .LBL11_5
.LBL11_7:
  mload r5 [r9,-26]
  mstore [r9,-7] r5
  mload r5 [r9,-36]
  mstore [r9,-6] r5
  mload r5 [r9,-35]
  mstore [r9,-5] r5
  mload r5 [r9,-34]
  mstore [r9,-4] r5
  mload r5 [r9,-33]
  mstore [r9,-3] r5
  jmp .LBL11_8
.LBL11_8:
  mload r5 [r9,-7]
  mstore [r9,-45] r5
  mload r5 [r9,-27]
  mload r6 [r9,-45]
  gte r5 r5 r6
  mload r6 [r9,-27]
  mload r7 [r9,-45]
  neq r6 r7 r6
  and r5 r5 r6
  cjmp r5 .LBL11_9
  jmp .LBL11_10
.LBL11_9:
  mload r5 [r9,-3]
  mstore [r9,-48] r5
  mload r5 [r9,-4]
  mstore [r9,-49] r5
  mload r5 [r9,-5]
  mstore [r9,-50] r5
  mload r5 [r9,-6]
  mstore [r9,-51] r5
  mload r5 [r9,-48]
  mov r1 r5
  mload r5 [r9,-49]
  mov r2 r5
  mload r5 [r9,-50]
  mov r3 r5
  mload r5 [r9,-51]
  mov r4 r5
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 0
  sstore 
  mload r5 [r9,-51]
  add r5 r5 1
  mstore [r9,-46] r5
  mload r5 [r9,-48]
  mload r6 [r9,-49]
  mload r7 [r9,-50]
  mload r8 [r9,-46]
  mov r8 r8
  mstore [r9,-6] r8
  mstore [r9,-5] r7
  mstore [r9,-4] r6
  mstore [r9,-3] r5
  mload r5 [r9,-45]
  add r5 r5 1
  mstore [r9,-47] r5
  mload r5 [r9,-47]
  mstore [r9,-7] r5
  jmp .LBL11_8
.LBL11_10:
  mload r6 [r9,-13]
  mload r7 [r9,-24]
  add r5 r7 1
  mload r7 [r9,-21]
  mov r1 r7
  mload r7 [r9,-22]
  mov r2 r7
  mload r7 [r9,-23]
  mov r3 r7
  mov r4 r5
  mov r5 0
  mov r7 0
  mov r8 0
  mov r6 r6
  mstore [r9,-53] r6
  mov r6 r7
  mov r7 r8
  mload r5 [r9,-53]
  mov r8 r5
  sstore 
  mload r5 [r9,-20]
  add r5 r5 1
  mstore [r9,-52] r5
  mov r5 0
  mov r6 0
  mov r7 0
  mload r8 [r9,-52]
  mov r8 r8
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sstore 
  jmp .LBL11_3
vote_proposal:
.LBL12_0:
  add r9 r9 32
  mstore [r9,-2] r9
  mov r5 r1
  mstore [r9,-8] r5
  call get_caller
  mov r5 r0
  mov r6 r1
  mov r7 r2
  mov r8 r3
  mstore [r9,-7] r8
  mstore [r9,-6] r7
  mstore [r9,-5] r6
  mstore [r9,-4] r5
  mload r5 [r9,-4]
  mload r6 [r9,-5]
  mload r7 [r9,-6]
  mload r8 [r9,-7]
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mstore [r9,-20] r4
  mov r4 0
  mstore [r9,-21] r4
  mov r4 0
  mstore [r9,-22] r4
  mov r4 0
  mstore [r9,-23] r4
  mov r8 r8
  mload r4 [r9,-20]
  mstore [r9,-24] r4
  mload r4 [r9,-21]
  mstore [r9,-25] r4
  mload r4 [r9,-22]
  mstore [r9,-26] r4
  mov r7 r7
  mload r4 [r9,-24]
  mstore [r9,-27] r4
  mload r4 [r9,-25]
  mstore [r9,-28] r4
  mov r6 r6
  mload r4 [r9,-27]
  mstore [r9,-29] r4
  mov r5 r5
  mov r4 1
  mov r3 0
  mov r2 0
  mov r1 0
  poseidon 
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mov r8 r4
  mstore [r9,-3] r8
  mstore [r9,-2] r7
  mstore [r9,-1] r6
  mstore [r9] r5
  mload r5 [r9,-3]
  mstore [r9,-16] r5
  mov r1 0
  mov r2 0
  mov r3 0
  mload r5 [r9,-16]
  mov r4 r5
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 1
  sstore 
  mload r5 [r9,-8]
  mload r6 [r9,-3]
  add r6 r6 1
  mstore [r9,-17] r6
  mov r1 0
  mov r2 0
  mov r3 0
  mload r6 [r9,-17]
  mov r4 r6
  mov r6 0
  mov r7 0
  mov r8 0
  mov r5 r5
  mstore [r9,-30] r5
  mov r5 r6
  mov r6 r7
  mov r7 r8
  mload r5 [r9,-30]
  mov r8 r5
  sstore 
  mload r5 [r9,-8]
  mstore [r9,-31] r5
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  not r7 1
  add r7 r7 1
  add r5 r5 r7
  mstore [r9,-12] r5
  mload r5 [r9,-31]
  not r7 r5
  add r7 r7 1
  mload r5 [r9,-12]
  add r5 r5 r7
  mstore [r9,-11] r5
  mload r5 [r9,-11]
  range r5
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 2
  poseidon 
  mov r5 r4
  mload r6 [r9,-31]
  add r5 r5 r6
  mstore [r9,-15] r5
  mload r5 [r9,-15]
  mov r5 r5
  add r5 r5 1
  mstore [r9,-10] r5
  mload r5 [r9,-10]
  mov r4 r5
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  add r5 r5 1
  mstore [r9,-18] r5
  mload r5 [r9,-18]
  range r5
  mload r5 [r9,-8]
  mstore [r9,-32] r5
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  not r7 1
  add r7 r7 1
  add r5 r5 r7
  mstore [r9,-19] r5
  mload r5 [r9,-32]
  not r7 r5
  add r7 r7 1
  mload r5 [r9,-19]
  add r5 r5 r7
  mstore [r9,-14] r5
  mload r5 [r9,-14]
  range r5
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 2
  poseidon 
  mov r5 r4
  mload r6 [r9,-32]
  add r5 r5 r6
  mstore [r9,-9] r5
  mload r5 [r9,-9]
  mov r5 r5
  add r5 r5 1
  mstore [r9,-13] r5
  mload r5 [r9,-13]
  mov r4 r5
  mov r5 0
  mov r6 0
  mov r7 0
  mload r8 [r9,-18]
  mov r8 r8
  sstore 
  add r9 r9 -32
  ret
winningProposal:
.LBL13_0:
  add r9 r9 9
  mov r5 0
  mstore [r9,-3] r5
  mov r5 0
  mstore [r9,-2] r5
  mov r5 0
  mstore [r9,-1] r5
  jmp .LBL13_1
.LBL13_1:
  mload r5 [r9,-1]
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sload 
  mov r6 r1
  mov r6 r2
  mov r6 r3
  mov r6 r4
  gte r7 r6 r5
  neq r5 r5 r6
  and r7 r7 r5
  cjmp r7 .LBL13_2
  jmp .LBL13_4
.LBL13_2:
  mload r7 [r9,-1]
  mstore [r9,-6] r7
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sload 
  mov r7 r1
  mov r7 r2
  mov r7 r3
  mov r7 r4
  mov r8 r7
  not r7 1
  add r7 r7 1
  add r5 r8 r7
  mload r7 [r9,-6]
  not r7 r7
  add r7 r7 1
  add r6 r5 r7
  range r6
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 2
  poseidon 
  mov r5 r4
  mload r6 [r9,-6]
  add r5 r5 r6
  mstore [r9,-4] r5
  mload r5 [r9,-4]
  mov r5 r5
  add r5 r5 1
  mstore [r9,-5] r5
  mload r5 [r9,-5]
  mov r4 r5
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  mload r6 [r9,-2]
  gte r7 r5 r6
  neq r5 r5 r6
  and r7 r7 r5
  cjmp r7 .LBL13_5
  jmp .LBL13_6
.LBL13_3:
  mload r6 [r9,-1]
  add r5 r6 1
  mstore [r9,-1] r5
  jmp .LBL13_1
.LBL13_4:
  mload r0 [r9,-3]
  add r9 r9 -9
  ret
.LBL13_5:
  mload r7 [r9,-1]
  mstore [r9,-9] r7
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sload 
  mov r7 r1
  mov r7 r2
  mov r7 r3
  mov r7 r4
  mov r8 r7
  not r7 1
  add r7 r7 1
  add r5 r8 r7
  mload r7 [r9,-9]
  not r7 r7
  add r7 r7 1
  add r6 r5 r7
  range r6
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 2
  poseidon 
  mov r5 r4
  mload r6 [r9,-9]
  add r5 r5 r6
  mstore [r9,-7] r5
  mload r5 [r9,-7]
  mov r5 r5
  add r5 r5 1
  mstore [r9,-8] r5
  mload r5 [r9,-8]
  mov r4 r5
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  mload r5 [r9,-1]
  jmp .LBL13_6
.LBL13_6:
  jmp .LBL13_3
getWinnerName:
.LBL14_0:
  add r9 r9 28
  mstore [r9,-2] r9
  call winningProposal
  mov r5 r0
  mstore [r9,-15] r5
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 2
  sload 
  mov r5 r1
  mov r5 r2
  mov r5 r3
  mov r5 r4
  not r7 1
  add r7 r7 1
  add r5 r5 r7
  mstore [r9,-12] r5
  mload r5 [r9,-15]
  not r7 r5
  add r7 r7 1
  mload r5 [r9,-12]
  add r5 r5 r7
  mstore [r9,-11] r5
  mload r5 [r9,-11]
  range r5
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mov r7 0
  mov r8 2
  poseidon 
  mov r5 r4
  mload r6 [r9,-15]
  add r5 r5 r6
  mstore [r9,-13] r5
  mload r5 [r9,-13]
  mov r5 r5
  mstore [r9,-10] r5
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mload r8 [r9,-10]
  mov r8 r8
  mov r1 r5
  mov r2 r6
  mov r3 r7
  mov r4 r8
  sload 
  mov r1 r2
  mov r1 r3
  mov r1 r4
  mstore [r9,-16] r1
  mload r1 [r9,-16]
.PROPHET14_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mload r2 [r9,-16]
  mstore [r9,-9] r2
  mstore [r9,-8] r1
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mstore [r9,-17] r4
  mov r4 0
  mstore [r9,-18] r4
  mov r4 0
  mstore [r9,-19] r4
  mov r4 0
  mstore [r9,-20] r4
  mov r8 r8
  mload r4 [r9,-17]
  mstore [r9,-21] r4
  mload r4 [r9,-18]
  mstore [r9,-22] r4
  mload r4 [r9,-19]
  mstore [r9,-23] r4
  mov r7 r7
  mload r4 [r9,-21]
  mstore [r9,-24] r4
  mload r4 [r9,-22]
  mstore [r9,-25] r4
  mov r6 r6
  mload r4 [r9,-24]
  mstore [r9,-26] r4
  mov r5 r5
  mov r4 0
  mov r3 0
  mov r2 0
  mov r1 0
  poseidon 
  mov r5 r1
  mov r6 r2
  mov r7 r3
  mov r8 r4
  mov r1 0
  mstore [r9,-7] r1
  mstore [r9,-6] r8
  mstore [r9,-5] r7
  mstore [r9,-4] r6
  mstore [r9,-3] r5
  jmp .LBL14_1
.LBL14_1:
  mload r5 [r9,-7]
  mload r6 [r9,-16]
  gte r6 r6 r5
  mload r7 [r9,-16]
  neq r7 r5 r7
  and r6 r6 r7
  cjmp r6 .LBL14_2
  jmp .LBL14_3
.LBL14_2:
  mload r7 [r9,-3]
  mload r8 [r9,-4]
  mload r1 [r9,-5]
  mstore [r9,-27] r1
  mload r1 [r9,-6]
  mstore [r9,-28] r1
  mov r1 r7
  mov r2 r8
  mload r1 [r9,-27]
  mov r3 r1
  mload r1 [r9,-28]
  mov r4 r1
  sload 
  mov r1 r2
  mov r1 r3
  mov r1 r4
  mload r2 [r9,-10]
  mstore [r2] r1
  mload r1 [r9,-28]
  mstore [r9,-6] r1
  mload r1 [r9,-27]
  mstore [r9,-5] r1
  mstore [r9,-4] r8
  mstore [r9,-3] r7
  add r6 r5 1
  mstore [r9,-7] r6
  jmp .LBL14_1
.LBL14_3:
  mload r0 [r9,-14]
  add r9 r9 -28
  ret
get_caller:
.LBL15_0:
  mov r0 402443140940559753
  mov r1 13008216018185724768
  mov r2 6500940582073311439
  mov r3 11734851560397297678
  ret
main:
.LBL16_0:
  add r9 r9 18
  mstore [r9,-2] r9
  mov r1 3
.PROPHET16_0:
  mov r0 psp
  mload r0 [r0]
  mov r7 r0
  mov r1 0
  mstore [r9,-11] r1
  jmp .LBL16_1
.LBL16_1:
  mload r1 [r9,-11]
  mov r3 3
  gte r3 r3 r1
  neq r4 r1 3
  mstore [r9,-12] r4
  mload r4 [r9,-12]
  and r3 r3 r4
  cjmp r3 .LBL16_2
  jmp .LBL16_3
.LBL16_2:
  mov r4 0
  mstore [r9,-13] r4
  mload r4 [r9,-13]
  mstore [r7] r4
  add r3 r1 1
  mstore [r9,-11] r3
  jmp .LBL16_1
.LBL16_3:
  mov r1 3
  mstore [r9,-10] r1
  mstore [r9,-9] r7
  mov r1 10
.PROPHET16_1:
  mov r0 psp
  mload r0 [r0]
  mov r7 r0
  mov r1 80
  mstore [r7] r1
  mov r1 114
  mstore [r7,+1] r1
  mov r1 111
  mstore [r7,+2] r1
  mov r1 112
  mstore [r7,+3] r1
  mov r1 111
  mstore [r7,+4] r1
  mov r1 115
  mstore [r7,+5] r1
  mov r1 97
  mstore [r7,+6] r1
  mov r1 108
  mstore [r7,+7] r1
  mov r1 32
  mstore [r7,+8] r1
  mov r1 49
  mstore [r7,+9] r1
  mov r1 10
  mstore [r9,-8] r1
  mstore [r9,-7] r7
  mload r1 [r9,-10]
  not r7 1
  add r7 r7 1
  add r3 r1 r7
  not r7 0
  add r7 r7 1
  add r7 r3 r7
  mstore [r9,-14] r7
  mload r7 [r9,-14]
  range r7
  mload r7 [r9,-11]
  mstore [r7] r5
  mov r1 10
.PROPHET16_2:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  mov r7 80
  mstore [r5] r7
  mov r7 114
  mstore [r5,+1] r7
  mov r7 111
  mstore [r5,+2] r7
  mov r7 112
  mstore [r5,+3] r7
  mov r7 111
  mstore [r5,+4] r7
  mov r7 115
  mstore [r5,+5] r7
  mov r7 97
  mstore [r5,+6] r7
  mov r7 108
  mstore [r5,+7] r7
  mov r7 32
  mstore [r5,+8] r7
  mov r7 50
  mstore [r5,+9] r7
  mov r7 10
  mstore [r9,-6] r7
  mstore [r9,-5] r5
  mload r5 [r9,-10]
  not r7 1
  add r7 r7 1
  add r5 r5 r7
  mstore [r9,-15] r5
  not r7 1
  add r7 r7 1
  mload r5 [r9,-15]
  add r5 r5 r7
  mstore [r9,-16] r5
  mload r5 [r9,-16]
  range r5
  mload r5 [r9,-11]
  mstore [r5,+2] r6
  mov r1 10
.PROPHET16_3:
  mov r0 psp
  mload r0 [r0]
  mov r5 r0
  mov r6 80
  mstore [r5] r6
  mov r6 114
  mstore [r5,+1] r6
  mov r6 111
  mstore [r5,+2] r6
  mov r6 112
  mstore [r5,+3] r6
  mov r6 111
  mstore [r5,+4] r6
  mov r6 115
  mstore [r5,+5] r6
  mov r6 97
  mstore [r5,+6] r6
  mov r6 108
  mstore [r5,+7] r6
  mov r6 32
  mstore [r5,+8] r6
  mov r6 51
  mstore [r5,+9] r6
  mov r6 10
  mstore [r9,-4] r6
  mstore [r9,-3] r5
  mload r5 [r9,-10]
  not r7 1
  add r7 r7 1
  add r5 r5 r7
  mstore [r9,-17] r5
  not r7 2
  add r7 r7 1
  mload r5 [r9,-17]
  add r5 r5 r7
  mstore [r9,-18] r5
  mload r5 [r9,-18]
  range r5
  mload r5 [r9,-11]
  mstore [r5,+4] r8
  mov r1 r2
  call contract_init
  mov r1 0
  call vote_proposal
  mov r1 1
  call vote_proposal
  mov r1 0
  call vote_proposal
  call getWinnerName
  add r9 r9 -18
  end
"
        );
    }

    #[test]
    fn codegen_vote_simple_test() {
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

define void @main() {
entry:
  %0 = alloca [4 x i64], align 8
  %index_alloca76 = alloca i64, align 8
  %1 = alloca [4 x i64], align 8
  %index_alloca67 = alloca i64, align 8
  %struct_alloca = alloca { ptr, i64 }, align 8
  %i = alloca i64, align 8
  %vector_alloca46 = alloca { i64, ptr }, align 8
  %vector_alloca28 = alloca { i64, ptr }, align 8
  %vector_alloca12 = alloca { i64, ptr }, align 8
  %vector_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %2 = call i64 @vector_new(i64 3)
  %int_to_ptr = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 3, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %int_to_ptr, ptr %vector_data, align 8
  %3 = call i64 @vector_new(i64 10)
  %int_to_ptr1 = inttoptr i64 %3 to ptr
  %index_access2 = getelementptr i64, ptr %int_to_ptr1, i64 0
  store i64 80, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %int_to_ptr1, i64 1
  store i64 114, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %int_to_ptr1, i64 2
  store i64 111, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %int_to_ptr1, i64 3
  store i64 112, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %int_to_ptr1, i64 4
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %int_to_ptr1, i64 5
  store i64 115, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %int_to_ptr1, i64 6
  store i64 97, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %int_to_ptr1, i64 7
  store i64 108, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %int_to_ptr1, i64 8
  store i64 32, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %int_to_ptr1, i64 9
  store i64 49, ptr %index_access11, align 4
  %vector_len13 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 0
  store i64 10, ptr %vector_len13, align 4
  %vector_data14 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca12, i32 0, i32 1
  store ptr %int_to_ptr1, ptr %vector_data14, align 8
  %vector_len15 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length = load i64, ptr %vector_len15, align 4
  %4 = sub i64 %length, 1
  %5 = sub i64 %4, 0
  call void @builtin_range_check(i64 %5)
  %data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access16 = getelementptr { i64, ptr }, ptr %data, i64 0
  store ptr %vector_alloca12, ptr %index_access16, align 8
  %6 = call i64 @vector_new(i64 10)
  %int_to_ptr17 = inttoptr i64 %6 to ptr
  %index_access18 = getelementptr i64, ptr %int_to_ptr17, i64 0
  store i64 80, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %int_to_ptr17, i64 1
  store i64 114, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %int_to_ptr17, i64 2
  store i64 111, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %int_to_ptr17, i64 3
  store i64 112, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %int_to_ptr17, i64 4
  store i64 111, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %int_to_ptr17, i64 5
  store i64 115, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %int_to_ptr17, i64 6
  store i64 97, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %int_to_ptr17, i64 7
  store i64 108, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %int_to_ptr17, i64 8
  store i64 32, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %int_to_ptr17, i64 9
  store i64 50, ptr %index_access27, align 4
  %vector_len29 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca28, i32 0, i32 0
  store i64 10, ptr %vector_len29, align 4
  %vector_data30 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca28, i32 0, i32 1
  store ptr %int_to_ptr17, ptr %vector_data30, align 8
  %vector_len31 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length32 = load i64, ptr %vector_len31, align 4
  %7 = sub i64 %length32, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %data33 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access34 = getelementptr { i64, ptr }, ptr %data33, i64 1
  store ptr %vector_alloca28, ptr %index_access34, align 8
  %9 = call i64 @vector_new(i64 10)
  %int_to_ptr35 = inttoptr i64 %9 to ptr
  %index_access36 = getelementptr i64, ptr %int_to_ptr35, i64 0
  store i64 80, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %int_to_ptr35, i64 1
  store i64 114, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %int_to_ptr35, i64 2
  store i64 111, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %int_to_ptr35, i64 3
  store i64 112, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %int_to_ptr35, i64 4
  store i64 111, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %int_to_ptr35, i64 5
  store i64 115, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %int_to_ptr35, i64 6
  store i64 97, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %int_to_ptr35, i64 7
  store i64 108, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %int_to_ptr35, i64 8
  store i64 32, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %int_to_ptr35, i64 9
  store i64 51, ptr %index_access45, align 4
  %vector_len47 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca46, i32 0, i32 0
  store i64 10, ptr %vector_len47, align 4
  %vector_data48 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca46, i32 0, i32 1
  store ptr %int_to_ptr35, ptr %vector_data48, align 8
  %vector_len49 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length50 = load i64, ptr %vector_len49, align 4
  %10 = sub i64 %length50, 1
  %11 = sub i64 %10, 2
  call void @builtin_range_check(i64 %11)
  %data51 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access52 = getelementptr { i64, ptr }, ptr %data51, i64 2
  store ptr %vector_alloca46, ptr %index_access52, align 8
  store i64 0, ptr %i, align 4
  br label %cond53

cond53:                                           ; preds = %next, %done
  %12 = load i64, ptr %i, align 4
  %vector_len55 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length56 = load i64, ptr %vector_len55, align 4
  %13 = icmp ult i64 %12, %length56
  br i1 %13, label %body54, label %endfor

body54:                                           ; preds = %cond53
  %14 = call [4 x i64] @get_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2])
  %15 = extractvalue [4 x i64] %14, 3
  %16 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 2])
  %17 = extractvalue [4 x i64] %16, 3
  %18 = add i64 %17, %15
  %19 = insertvalue [4 x i64] %16, i64 %18, 3
  %"struct member" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %20 = load i64, ptr %i, align 4
  %vector_len57 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  %length58 = load i64, ptr %vector_len57, align 4
  %21 = sub i64 %length58, 1
  %22 = sub i64 %21, %20
  call void @builtin_range_check(i64 %22)
  %data59 = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  %index_access60 = getelementptr { i64, ptr }, ptr %data59, i64 %20
  store ptr %index_access60, ptr %"struct member", align 8
  %"struct member61" = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  %23 = load i64, ptr %i, align 4
  store i64 %23, ptr %"struct member61", align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 0
  %vector_len62 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 0
  %length63 = load i64, ptr %vector_len62, align 4
  %24 = call [4 x i64] @get_storage([4 x i64] %19)
  %25 = extractvalue [4 x i64] %24, 3
  %26 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length63, 3
  call void @set_storage([4 x i64] %19, [4 x i64] %26)
  %27 = extractvalue [4 x i64] %19, 0
  %28 = extractvalue [4 x i64] %19, 1
  %29 = extractvalue [4 x i64] %19, 2
  %30 = extractvalue [4 x i64] %19, 3
  %31 = insertvalue [8 x i64] undef, i64 %30, 7
  %32 = insertvalue [8 x i64] %31, i64 %29, 6
  %33 = insertvalue [8 x i64] %32, i64 %28, 5
  %34 = insertvalue [8 x i64] %33, i64 %27, 4
  %35 = insertvalue [8 x i64] %34, i64 0, 3
  %36 = insertvalue [8 x i64] %35, i64 0, 2
  %37 = insertvalue [8 x i64] %36, i64 0, 1
  %38 = insertvalue [8 x i64] %37, i64 0, 0
  %39 = call [4 x i64] @poseidon_hash([8 x i64] %38)
  store i64 0, ptr %index_alloca67, align 4
  store [4 x i64] %39, ptr %1, align 4
  br label %cond64

next:                                             ; preds = %done75
  %40 = load i64, ptr %i, align 4
  %41 = add i64 %40, 1
  store i64 %41, ptr %i, align 4
  br label %cond53

endfor:                                           ; preds = %cond53
  ret void

cond64:                                           ; preds = %body65, %body54
  %index_value68 = load i64, ptr %index_alloca67, align 4
  %loop_cond69 = icmp ult i64 %index_value68, %length63
  br i1 %loop_cond69, label %body65, label %done66

body65:                                           ; preds = %cond64
  %42 = load [4 x i64], ptr %1, align 4
  %data70 = getelementptr inbounds { i64, ptr }, ptr %name, i32 0, i32 1
  %index_access71 = getelementptr i64, ptr %data70, i64 %index_value68
  %43 = load i64, ptr %index_access71, align 4
  %44 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %43, 3
  call void @set_storage([4 x i64] %42, [4 x i64] %44)
  %45 = extractvalue [4 x i64] %42, 3
  %46 = add i64 %45, 1
  %47 = insertvalue [4 x i64] %42, i64 %46, 3
  store [4 x i64] %47, ptr %1, align 4
  %next_index72 = add i64 %index_value68, 1
  store i64 %next_index72, ptr %index_alloca67, align 4
  br label %cond64

done66:                                           ; preds = %cond64
  store i64 %length63, ptr %index_alloca76, align 4
  store [4 x i64] %39, ptr %0, align 4
  br label %cond73

cond73:                                           ; preds = %body74, %done66
  %index_value77 = load i64, ptr %index_alloca76, align 4
  %loop_cond78 = icmp ult i64 %index_value77, %25
  br i1 %loop_cond78, label %body74, label %done75

body74:                                           ; preds = %cond73
  %48 = load [4 x i64], ptr %0, align 4
  call void @set_storage([4 x i64] %48, [4 x i64] zeroinitializer)
  %49 = extractvalue [4 x i64] %48, 3
  %50 = add i64 %49, 1
  %51 = insertvalue [4 x i64] %48, i64 %50, 3
  store [4 x i64] %51, ptr %0, align 4
  %next_index79 = add i64 %index_value77, 1
  store i64 %next_index79, ptr %index_alloca76, align 4
  br label %cond73

done75:                                           ; preds = %cond73
  %52 = extractvalue [4 x i64] %19, 3
  %53 = add i64 %52, 1
  %54 = insertvalue [4 x i64] %19, i64 %53, 3
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %struct_alloca, i32 0, i32 1
  %55 = load i64, ptr %voteCount, align 4
  %56 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %55, 3
  call void @set_storage([4 x i64] %54, [4 x i64] %56)
  %new_length = add i64 %15, 1
  %57 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 2], [4 x i64] %57)
  br label %next
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
        println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_tape_test() {
        // LLVM Assembly
        let asm = r#"
  define dso_local void @foo(i64 %len1) #0 {
    %a = alloca i64, align 8
    store i32 10, i64* %a
    %b = alloca i64, align 8
    store i32 20, i64* %b
    %len = alloca i64, align 8
    store i32 30, i32* %len
    call void @get_call_data(i64 %a, i64 2)
    call void @get_call_data(i64 %a, i64 %len1)

    call void @get_ctx_data(i64 %a, i64 3)
    call void @get_ctx_data(i64 %a, i64 %len1)
    call void @set_tape_data(i64 %a, i64 4)
    call void @set_tape_data(i64 %a, i64 %len1)
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
            "foo:
.LBL0_0:
  add r9 r9 3
  mov r6 r1
  mov r5 10
  mstore [r9,-1] r5
  mov r5 20
  mstore [r8] r5
  mov r8 30
  mstore [r7] r8
  add r8 r9 -1
  mov r7 1
  tload r8 r7 2
  mov r7 1
  tload r8 r7 r6
  mov r7 0
  tload r8 r7 3
  mov r7 0
  tload r8 r7 r6
  tstore r8 4
  tstore r8 r6
  add r9 r9 -3
  ret
"
        );
    }

    #[test]
    fn codegen_switch_test() {
        // LLVM Assembly
        let asm = r#"
define i64 @main() {
entry:
  %x = alloca i64, align 4
  store i64 2, i64* %x, align 4
  %0 = load i64, i64* %x, align 4
  switch i64 %0, label %default [
    i64 1, label %case1
    i64 2, label %case2
    i64 3, label %case3
  ]

case1:
  br label %end

case2:
  br label %end

case3:
  br label %end

default:
  unreachable
  br label %end

end:
  ret i64 100
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
.LBL0_0:
  add r9 r9 1
  mov r8 2
  mstore [r9,-1] r8
  mload r8 [r9,-1]
  eq r7 r8 1
  cjmp r7 .LBL0_1
  eq r7 r8 2
  cjmp r7 .LBL0_2
  eq r7 r8 3
  cjmp r7 .LBL0_3
  jmp .LBL0_4
.LBL0_1:
  jmp .LBL0_5
.LBL0_2:
  jmp .LBL0_5
.LBL0_3:
  jmp .LBL0_5
.LBL0_4:
  jmp .LBL0_5
.LBL0_5:
  mov r0 100
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_contract_test() {
        // LLVM Assembly
        let asm = r#"
declare void @get_context_data(i64, i64)

declare void @get_call_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define i64 @foo(i64 %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = add i64 %2, %3
  call void @builtin_range_check(i64 %4)
  ret i64 %4
}

define i64 @bar(i64 %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = mul i64 %2, %3
  call void @builtin_range_check(i64 %4)
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 253268590, label %func_0_dispatch
    i64 1503968193, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 2, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %4 = icmp ult i64 2, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %5 = call i64 @foo(i64 %value, i64 %value2)
  %6 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %6, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %start3, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start4, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = icmp ule i64 2, %1
  br i1 %7, label %inbounds5, label %out_of_bounds6

inbounds5:                                        ; preds = %func_1_dispatch
  %start7 = getelementptr i64, ptr %2, i64 0
  %value8 = load i64, ptr %start7, align 4
  %start9 = getelementptr i64, ptr %2, i64 1
  %value10 = load i64, ptr %start9, align 4
  %8 = icmp ult i64 2, %1
  br i1 %8, label %not_all_bytes_read11, label %buffer_read12

out_of_bounds6:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read11:                             ; preds = %inbounds5
  unreachable

buffer_read12:                                    ; preds = %inbounds5
  %9 = call i64 @bar(i64 %value8, i64 %value10)
  %10 = call i64 @vector_new(i64 2)
  %heap_start13 = sub i64 %10, 2
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  %start15 = getelementptr i64, ptr %heap_to_ptr14, i64 0
  store i64 %9, ptr %start15, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 1, ptr %start16, align 4
  call void @set_tape_data(i64 %heap_start13, i64 2)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_call_data(i64 %heap_start, i64 1)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 2)
  %heap_start1 = sub i64 %1, 2
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_call_data(i64 %heap_start1, i64 2)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 2
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_call_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "foo:
.LBL6_0:
  add r9 r9 2
  mov r8 r1
  mov r7 r2
  mstore [r9,-2] r8
  mstore [r9,-1] r7
  mload r8 [r9,-2]
  mload r7 [r9,-1]
  add r0 r8 r7
  range r0
  add r9 r9 -2
  ret
bar:
.LBL7_0:
  add r9 r9 2
  mov r8 r1
  mov r7 r2
  mstore [r9,-2] r8
  mstore [r9,-1] r7
  mload r8 [r9,-2]
  mload r7 [r9,-1]
  mul r0 r8 r7
  range r0
  add r9 r9 -2
  ret
function_dispatch:
.LBL8_0:
  add r9 r9 4
  mstore [r9,-2] r9
  mov r8 r1
  mov r7 r2
  mov r6 r3
  eq r1 r8 253268590
  cjmp r1 .LBL8_2
  eq r1 r8 1503968193
  cjmp r1 .LBL8_7
  jmp .LBL8_1
.LBL8_1:
  ret
.LBL8_2:
  mov r8 2
  gte r8 r7 r8
  cjmp r8 .LBL8_3
  jmp .LBL8_4
.LBL8_3:
  mload r1 [r6]
  mload r2 [r6,+1]
  mov r8 2
  gte r6 r7 r8
  neq r8 r8 r7
  and r6 r6 r8
  cjmp r6 .LBL8_5
  jmp .LBL8_6
.LBL8_4:
  ret
.LBL8_5:
  ret
.LBL8_6:
  call foo
  mov r8 r0
  mov r1 2
.PROPHET8_0:
  mov r0 psp
  mload r0 [r0]
  mov r6 r0
  not r7 2
  add r7 r7 1
  add r7 r6 r7
  mstore [r9,-3] r7
  mload r7 [r9,-3]
  mstore [r7] r8
  mov r8 1
  mstore [r7,+1] r8
  mload r8 [r9,-3]
  tstore r8 2
  add r9 r9 -4
  ret
.LBL8_7:
  mov r8 2
  gte r8 r7 r8
  cjmp r8 .LBL8_8
  jmp .LBL8_9
.LBL8_8:
  mload r1 [r6]
  mload r2 [r6,+1]
  mov r8 2
  gte r6 r7 r8
  neq r8 r8 r7
  and r6 r6 r8
  cjmp r6 .LBL8_10
  jmp .LBL8_11
.LBL8_9:
  ret
.LBL8_10:
  ret
.LBL8_11:
  call bar
  mov r8 r0
  mov r1 2
.PROPHET8_1:
  mov r0 psp
  mload r0 [r0]
  mov r6 r0
  not r7 2
  add r7 r7 1
  add r7 r6 r7
  mstore [r9,-4] r7
  mload r7 [r9,-4]
  mstore [r7] r8
  mov r8 1
  mstore [r7,+1] r8
  mload r8 [r9,-4]
  tstore r8 2
  add r9 r9 -4
  ret
main:
.LBL9_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 1
.PROPHET9_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 1
  add r7 r7 1
  add r8 r1 r7
  mov r7 1
  tload r8 r7 1
  mload r8 [r8]
  mov r1 2
.PROPHET9_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 2
  add r7 r7 1
  add r6 r1 r7
  mov r7 1
  tload r6 r7 2
  mov r7 r6
  mload r2 [r7]
  add r5 r2 2
  mov r1 r5
.PROPHET9_2:
  mov r0 psp
  mload r0 [r0]
  mov r6 r0
  not r7 r5
  add r7 r7 1
  add r3 r6 r7
  mov r7 1
  tload r3 r7 r5
  mov r1 r8
  call function_dispatch
  add r9 r9 -2
  end
"
        );
    }

    #[test]
    fn codegen_callee_test() {
        // LLVM Assembly
        let asm = r#"
define void @setVars(i64 %0) {
entry:
  %data = alloca i64, align 8
  store i64 %0, ptr %data, align 4
  %1 = load i64, ptr %data, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %2)
  ret void
}

define i64 @add(i64 %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = add i64 %2, %3
  call void @builtin_range_check(i64 %4)
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2371037854, label %func_0_dispatch
    i64 2062500454, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 1, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = icmp ult i64 1, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setVars(i64 %value)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %5 = icmp ule i64 2, %1
  br i1 %5, label %inbounds1, label %out_of_bounds2

inbounds1:                                        ; preds = %func_1_dispatch
  %start3 = getelementptr i64, ptr %2, i64 0
  %value4 = load i64, ptr %start3, align 4
  %start5 = getelementptr i64, ptr %2, i64 1
  %value6 = load i64, ptr %start5, align 4
  %6 = icmp ult i64 2, %1
  br i1 %6, label %not_all_bytes_read7, label %buffer_read8

out_of_bounds2:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read7:                              ; preds = %inbounds1
  unreachable

buffer_read8:                                     ; preds = %inbounds1
  %7 = call i64 @add(i64 %value4, i64 %value6)
  %8 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %8, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start9 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %7, ptr %start9, align 4
  %start10 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start10, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 1
  mov r7 10
  mstore [r9,-1] r7
  mload r7 [r9,-1]
  add r5 r7 20
  add r6 r7 30
  mul r8 r5 r6
  not r7 r6
  add r7 r7 1
  add r0 r8 r7
  add r9 r9 -1
  end
"
        );
    }

    #[test]
    fn codegen_caller_test() {
        // LLVM Assembly
        let asm = r#"
define void @delegatecall_test([4 x i64] %0) {
entry:
  %set_data = alloca i64, align 8
  %_contract = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %_contract, align 4
  store i64 66, ptr %set_data, align 4
  %1 = load i64, ptr %set_data, align 4
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 1, ptr %start, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %1, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 1, ptr %start2, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 2371037854, ptr %start3, align 4
  %3 = load [4 x i64], ptr %_contract, align 4
  %4 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %4, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %5 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  %6 = extractvalue [4 x i64] %3, 0
  store i64 %6, ptr %5, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  %8 = extractvalue [4 x i64] %3, 1
  store i64 %8, ptr %7, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  %10 = extractvalue [4 x i64] %3, 2
  store i64 %10, ptr %9, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  %12 = extractvalue [4 x i64] %3, 3
  store i64 %12, ptr %11, align 4
  %payload_len = load i64, ptr %heap_to_ptr, align 4
  %tape_size = add i64 %payload_len, 2
  %13 = ptrtoint ptr %heap_to_ptr to i64
  %payload_start = add i64 %13, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(i64 %heap_start4, i64 1)
  %14 = call i64 @vector_new(i64 1)
  %heap_start6 = sub i64 %14, 1
  %heap_to_ptr7 = inttoptr i64 %heap_start6 to ptr
  call void @get_tape_data(i64 %heap_start6, i64 1)
  %return_length = load i64, ptr %heap_to_ptr7, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size8 = add i64 %return_length, 1
  %15 = call i64 @vector_new(i64 %heap_size)
  %heap_start9 = sub i64 %15, %heap_size
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %return_length, ptr %heap_to_ptr10, align 4
  %16 = add i64 %heap_start9, 1
  call void @get_tape_data(i64 %16, i64 %tape_size8)
  %17 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %18 = extractvalue [4 x i64] %17, 3
  %19 = icmp eq i64 %18, 66
  %20 = zext i1 %19 to i64
  call void @builtin_assert(i64 %20)
  ret void
}

define void @call_test([4 x i64] %0) {
entry:
  %result = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %_contract = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %_contract, align 4
  store i64 100, ptr %a, align 4
  store i64 200, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %3, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 2, ptr %start, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %1, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %2, ptr %start2, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 2, ptr %start3, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 2062500454, ptr %start4, align 4
  %4 = load [4 x i64], ptr %_contract, align 4
  %5 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %5, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %6 = getelementptr i64, ptr %heap_to_ptr6, i64 0
  %7 = extractvalue [4 x i64] %4, 0
  store i64 %7, ptr %6, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  %9 = extractvalue [4 x i64] %4, 1
  store i64 %9, ptr %8, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  %11 = extractvalue [4 x i64] %4, 2
  store i64 %11, ptr %10, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %13 = extractvalue [4 x i64] %4, 3
  store i64 %13, ptr %12, align 4
  %payload_len = load i64, ptr %heap_to_ptr, align 4
  %tape_size = add i64 %payload_len, 2
  %14 = ptrtoint ptr %heap_to_ptr to i64
  %payload_start = add i64 %14, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(i64 %heap_start5, i64 0)
  %15 = call i64 @vector_new(i64 1)
  %heap_start7 = sub i64 %15, 1
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @get_tape_data(i64 %heap_start7, i64 1)
  %return_length = load i64, ptr %heap_to_ptr8, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size9 = add i64 %return_length, 1
  %16 = call i64 @vector_new(i64 %heap_size)
  %heap_start10 = sub i64 %16, %heap_size
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  store i64 %return_length, ptr %heap_to_ptr11, align 4
  %17 = add i64 %heap_start10, 1
  call void @get_tape_data(i64 %17, i64 %tape_size9)
  %length = load i64, ptr %heap_to_ptr11, align 4
  %18 = ptrtoint ptr %heap_to_ptr11 to i64
  %19 = add i64 %18, 1
  %vector_data = inttoptr i64 %19 to ptr
  %20 = icmp ule i64 1, %length
  br i1 %20, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %entry
  %start12 = getelementptr i64, ptr %vector_data, i64 0
  %value = load i64, ptr %start12, align 4
  %21 = icmp ult i64 1, %length
  br i1 %21, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %entry
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  store i64 %value, ptr %result, align 4
  %22 = load i64, ptr %result, align 4
  %23 = icmp eq i64 %22, 300
  %24 = zext i1 %23 to i64
  call void @builtin_assert(i64 %24)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3965482278, label %func_0_dispatch
    i64 1607480800, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 4, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = insertvalue [4 x i64] undef, i64 %value, 0
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %5 = insertvalue [4 x i64] %4, i64 %value2, 1
  %start3 = getelementptr i64, ptr %2, i64 2
  %value4 = load i64, ptr %start3, align 4
  %6 = insertvalue [4 x i64] %5, i64 %value4, 2
  %start5 = getelementptr i64, ptr %2, i64 3
  %value6 = load i64, ptr %start5, align 4
  %7 = insertvalue [4 x i64] %6, i64 %value6, 3
  %8 = icmp ult i64 4, %1
  br i1 %8, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @delegatecall_test([4 x i64] %7)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %9 = icmp ule i64 4, %1
  br i1 %9, label %inbounds7, label %out_of_bounds8

inbounds7:                                        ; preds = %func_1_dispatch
  %start9 = getelementptr i64, ptr %2, i64 0
  %value10 = load i64, ptr %start9, align 4
  %10 = insertvalue [4 x i64] undef, i64 %value10, 0
  %start11 = getelementptr i64, ptr %2, i64 1
  %value12 = load i64, ptr %start11, align 4
  %11 = insertvalue [4 x i64] %10, i64 %value12, 1
  %start13 = getelementptr i64, ptr %2, i64 2
  %value14 = load i64, ptr %start13, align 4
  %12 = insertvalue [4 x i64] %11, i64 %value14, 2
  %start15 = getelementptr i64, ptr %2, i64 3
  %value16 = load i64, ptr %start15, align 4
  %13 = insertvalue [4 x i64] %12, i64 %value16, 3
  %14 = icmp ult i64 4, %1
  br i1 %14, label %not_all_bytes_read17, label %buffer_read18

out_of_bounds8:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read17:                             ; preds = %inbounds7
  unreachable

buffer_read18:                                    ; preds = %inbounds7
  call void @call_test([4 x i64] %13)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
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
        println!("{:#?}", code.prophets);
        assert_eq!(
            format!("{}", code.program),
            "delegatecall_test:
.LBL0_0:
  add r9 r9 13
  mov r7 r1
  mov r1 r2
  mov r2 r3
  mov r3 r4
  mstore [r9,-5] r3
  mstore [r9,-4] r2
  mstore [r9,-3] r1
  mstore [r9,-2] r7
  mov r7 66
  mstore [r9,-1] r7
  mload r2 [r9,-1]
  mov r1 4
.PROPHET0_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r8 r1 r7
  mov r7 1
  mstore [r8] r7
  mstore [r8,+1] r2
  mov r7 1
  mstore [r8,+2] r7
  mov r7 2371037854
  mstore [r8,+3] r7
  mload r2 [r9,-2]
  mload r3 [r9,-3]
  mload r7 [r9,-4]
  mstore [r9,-12] r7
  mload r7 [r9,-5]
  mstore [r9,-13] r7
  mov r1 4
.PROPHET0_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r7 r1 r7
  mstore [r9,-6] r7
  mload r7 [r9,-6]
  mov r1 r2
  mstore [r7] r1
  mov r1 r3
  mstore [r7,+1] r1
  mload r1 [r9,-12]
  mstore [r7,+2] r1
  mload r1 [r9,-13]
  mstore [r7,+3] r1
  mload r7 [r8]
  add r5 r8 1
  add r6 r7 2
  tstore r5 r6
  mload r8 [r9,-6]
  sccall r8 1
  mov r1 1
.PROPHET0_2:
  mov r0 psp
  mload r0 [r0]
  mov r8 r0
  mov r6 1
  not r7 1
  add r7 r7 1
  add r8 r8 r7
  mstore [r9,-7] r8
  tload r8 r6 1
  mstore [r9,-7] r8
  mload r8 [r9,-7]
  mload r8 [r8]
  add r7 r8 2
  mstore [r9,-8] r7
  mload r7 [r9,-8]
  mov r1 r7
.PROPHET0_3:
  mov r0 psp
  mload r0 [r0]
  mov r6 r0
  mload r7 [r9,-8]
  not r7 r7
  add r7 r7 1
  add r7 r6 r7
  mstore [r9,-9] r7
  mload r7 [r9,-9]
  mstore [r7] r8
  mov r7 1
  mload r6 [r9,-9]
  add r6 r6 1
  mstore [r9,-11] r6
  add r8 r8 1
  mstore [r9,-10] r8
  mload r8 [r9,-10]
  tload r8 r7 r8
  mstore [r9,-11] r8
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  sload 
  mov r8 r1
  mov r8 r2
  mov r8 r3
  mov r8 r4
  eq r8 r8 66
  assert r8
  add r9 r9 -13
  ret
call_test:
.LBL1_0:
  add r9 r9 16
  mov r7 r1
  mov r1 r2
  mov r2 r3
  mov r3 r4
  mstore [r9,-7] r3
  mstore [r9,-6] r2
  mstore [r9,-5] r1
  mstore [r9,-4] r7
  mov r7 100
  mstore [r9,-3] r7
  mov r7 200
  mstore [r9,-2] r7
  mload r2 [r9,-3]
  mload r3 [r9,-2]
  mov r1 5
.PROPHET1_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 5
  add r7 r7 1
  add r8 r1 r7
  mov r7 2
  mstore [r8] r7
  mstore [r8,+1] r2
  mstore [r8,+2] r3
  mov r7 2
  mstore [r8,+3] r7
  mov r7 2062500454
  mstore [r8,+4] r7
  mload r2 [r9,-4]
  mload r3 [r9,-5]
  mload r7 [r9,-6]
  mstore [r9,-15] r7
  mload r7 [r9,-7]
  mstore [r9,-16] r7
  mov r1 4
.PROPHET1_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  not r7 4
  add r7 r7 1
  add r7 r1 r7
  mstore [r9,-8] r7
  mload r7 [r9,-8]
  mov r1 r2
  mstore [r7] r1
  mov r1 r3
  mstore [r7,+1] r1
  mload r1 [r9,-15]
  mstore [r7,+2] r1
  mload r1 [r9,-16]
  mstore [r7,+3] r1
  mload r7 [r8]
  add r5 r8 1
  add r6 r7 2
  tstore r5 r6
  mload r8 [r9,-8]
  sccall r8 0
  mov r1 1
.PROPHET1_2:
  mov r0 psp
  mload r0 [r0]
  mov r8 r0
  mov r6 1
  not r7 1
  add r7 r7 1
  add r8 r8 r7
  mstore [r9,-9] r8
  tload r8 r6 1
  mstore [r9,-9] r8
  mload r8 [r9,-9]
  mload r8 [r8]
  add r7 r8 2
  mstore [r9,-10] r7
  mload r7 [r9,-10]
  mov r1 r7
.PROPHET1_3:
  mov r0 psp
  mload r0 [r0]
  mov r6 r0
  mload r7 [r9,-10]
  not r7 r7
  add r7 r7 1
  add r7 r6 r7
  mstore [r9,-11] r7
  mload r7 [r9,-11]
  mstore [r7] r8
  mov r6 1
  mload r5 [r9,-11]
  add r5 r5 1
  mstore [r9,-13] r5
  add r8 r8 1
  mstore [r9,-12] r8
  mload r8 [r9,-12]
  tload r8 r6 r8
  mstore [r9,-13] r8
  mload r8 [r7]
  add r7 r7 1
  mstore [r9,-14] r7
  mload r7 [r9,-14]
  mov r6 1
  gte r6 r8 r6
  cjmp r6 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mload r7 [r7]
  mov r6 1
  gte r5 r8 r6
  neq r8 r6 r8
  and r5 r5 r8
  cjmp r5 .LBL1_3
  jmp .LBL1_4
.LBL1_2:
  ret
.LBL1_3:
  ret
.LBL1_4:
  mstore [r9,-1] r7
  mload r8 [r9,-1]
  eq r8 r8 300
  assert r8
  add r9 r9 -16
  ret
function_dispatch:
.LBL2_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r8 r1
  mov r7 r2
  mov r6 r3
  eq r1 r8 3965482278
  cjmp r1 .LBL2_2
  eq r1 r8 1607480800
  cjmp r1 .LBL2_7
  jmp .LBL2_1
.LBL2_1:
  ret
.LBL2_2:
  mov r8 4
  gte r8 r7 r8
  cjmp r8 .LBL2_3
  jmp .LBL2_4
.LBL2_3:
  mload r8 [r6]
  mload r5 [r6,+1]
  mload r1 [r6,+2]
  mload r6 [r6,+3]
  mov r8 r8
  mov r2 0
  mov r2 0
  mov r3 0
  mov r5 r5
  mov r2 r3
  mov r3 r1
  mov r1 r2
  mov r1 r8
  mov r2 r5
  mov r4 r6
  mov r8 4
  gte r6 r7 r8
  neq r8 r8 r7
  and r6 r6 r8
  cjmp r6 .LBL2_5
  jmp .LBL2_6
.LBL2_4:
  ret
.LBL2_5:
  ret
.LBL2_6:
  call delegatecall_test
  add r9 r9 -2
  ret
.LBL2_7:
  mov r8 4
  gte r8 r7 r8
  cjmp r8 .LBL2_8
  jmp .LBL2_9
.LBL2_8:
  mload r8 [r6]
  mload r5 [r6,+1]
  mload r1 [r6,+2]
  mload r6 [r6,+3]
  mov r8 r8
  mov r2 0
  mov r2 0
  mov r3 0
  mov r5 r5
  mov r2 r3
  mov r3 r1
  mov r1 r2
  mov r1 r8
  mov r2 r5
  mov r4 r6
  mov r8 4
  gte r6 r7 r8
  neq r8 r8 r7
  and r6 r6 r8
  cjmp r6 .LBL2_10
  jmp .LBL2_11
.LBL2_9:
  ret
.LBL2_10:
  ret
.LBL2_11:
  call call_test
  add r9 r9 -2
  ret
main:
.LBL3_0:
  add r9 r9 2
  mstore [r9,-2] r9
  mov r1 13
.PROPHET3_0:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r2 1
  not r7 13
  add r7 r7 1
  add r8 r1 r7
  tload r8 r2 13
  mload r8 [r8]
  mov r1 14
.PROPHET3_1:
  mov r0 psp
  mload r0 [r0]
  mov r1 r0
  mov r2 1
  not r7 14
  add r7 r7 1
  add r6 r1 r7
  tload r6 r2 14
  mov r7 r6
  mload r2 [r7]
  add r5 r2 14
  mov r1 r5
.PROPHET3_2:
  mov r0 psp
  mload r0 [r0]
  mov r6 r0
  mov r1 1
  not r7 r5
  add r7 r7 1
  add r3 r6 r7
  tload r3 r1 r5
  mov r1 r8
  call function_dispatch
  add r9 r9 -2
  end
"
        );
    }
}
