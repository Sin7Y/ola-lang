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
  mov r1 r2
  mov r1 r3
  mov r2 r4
  add r0 r1 r2
  ret
main:
.LBL12_0:
  add r9 r9 5
  mstore [r9,-2] r9
  call inc_simple
  call get
  mstore [r9,-3] r0
  add r9 r9 -5
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
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r9 r9 2
  mov r1 3
.PROPHET0_0:
  mov r0 psp
  mload r0 [r0,0]
  mov r1 3
  mstore [r9,-2] r1
  mstore [r9,-1] r0
  mload r0 [r9,-1]
  mov r1 1
  mstore [r0,+0] r1
  mov r1 2
  mstore [r0,+1] r1
  mov r1 3
  mstore [r0,+2] r1
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
  add r9 r9 10
  mov r0 r1
  mov r1 r2
  mov r2 r3
  mov r3 r4
  mov r4 r5
  mstore [r9,-1] r4
  mov r4 0
  mov r5 0
  mov r6 0
  mstore [r9,-2] r6
  mov r6 0
  mstore [r9,-3] r6
  mov r6 0
  mstore [r9,-4] r6
  mov r6 0
  mstore [r9,-5] r6
  mov r6 0
  mstore [r9,-6] r6
  mov r8 r3
  mov r3 r4
  mov r4 r5
  mload r5 [r9,-2]
  mload r6 [r9,-3]
  mstore [r9,-7] r6
  mload r6 [r9,-4]
  mstore [r9,-8] r6
  mload r6 [r9,-5]
  mstore [r9,-9] r6
  mov r7 r2
  mov r2 r3
  mov r3 r4
  mov r4 r5
  mload r5 [r9,-7]
  mload r6 [r9,-8]
  mstore [r9,-10] r6
  mov r6 r1
  mov r1 r2
  mov r2 r3
  mov r3 r4
  mov r4 r5
  mov r5 r0
  mov r0 r1
  mov r1 r2
  mov r2 r3
  mov r4 0
  mov r3 0
  mov r2 0
  mov r1 0
  poseidon 
  mov r5 0
  mov r6 0
  mov r7 0
  mload r0 [r9,-1]
  mov r8 r0
  sstore 
  add r9 r9 -10
  ret
main:
.LBL12_0:
  add r9 r9 4
  mstore [r9,-2] r9
  mov r1 402443140940559753
  mov r2 13008216018185724768
  mov r3 6500940582073311439
  mov r4 11734851560397297678
  mov r5 1
  call add_mapping
  add r9 r9 -4
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
  mov r0 r1
  mstore [r9,-1] r0
  mload r0 [r9,-1]
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
  mov r0 r1
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
  mov r0 r1
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
  add r9 r9 2
  mov r7 r1
  mov r0 r2
  add r8 r7 666
  mov r0 0
  mov r1 0
  mov r2 0
  mov r3 0
  mov r4 0
  mov r5 0
  mov r6 0
  mstore [r9,-1] r6
  mov r6 r8
  mstore [r9,-2] r6
  mload r5 [r9,-2]
  mov r6 r8
  mov r8 r5
  mov r5 100
  mov r4 200
  mov r3 30
  mov r2 20
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
  add r9 r9 -2
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

    #[ignore]
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
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r8 r8 7
  mstore [r8,-2] r8
  mov r0 10
  mstore [r8,-5] r0
  mov r0 20
  mstore [r8,-4] r0
  mov r0 100
  mstore [r8,-3] r0
  mload r1 [r8,-5]
  mload r2 [r8,-4]
  call bar
  mstore [r8,-3] r0
  mload r0 [r8,-3]
  add r8 r8 -7
  end
bar:
.LBL1_0:
  add r8 r8 3
  mstore [r8,-3] r1
  mstore [r8,-2] r2
  mov r1 200
  mstore [r8,-1] r1
  mload r1 [r8,-3]
  mload r2 [r8,-2]
  add r0 r1 r2
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  add r8 r8 -3
  ret
"
        );
    }

    #[ignore]
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
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r8 r8 7
  mstore [r8,-2] r8
  mov r0 10
  mstore [r8,-5] r0
  mov r0 20
  mstore [r8,-4] r0
  mov r0 100
  mstore [r8,-3] r0
  mload r1 [r8,-5]
  mload r2 [r8,-4]
  call bar
  mstore [r8,-3] r0
  mload r0 [r8,-3]
  add r8 r8 -7
  end
bar:
.LBL1_0:
  add r8 r8 3
  mstore [r8,-3] r1
  mstore [r8,-2] r2
  mov r1 200
  mstore [r8,-1] r1
  mload r1 [r8,-3]
  mload r2 [r8,-2]
  add r0 r1 r2
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  add r8 r8 -3
  ret
"
        );
    }

    #[ignore]
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
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r8 r8 4
  mstore [r8,-2] r8
  mov r1 10
  call fib_non_recursive
  add r8 r8 -4
  end
fib_recursive:
.LBL1_0:
  add r8 r8 9
  mstore [r8,-2] r8
  mov r0 r1
  mstore [r8,-7] r0
  mload r0 [r8,-7]
  mov r7 2
  gte r0 r7 r0
  cjmp r0 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 1
  add r8 r8 -9
  ret
.LBL1_2:
  mload r0 [r8,-7]
  not r7 1
  add r7 r7 1
  add r1 r0 r7
  call fib_recursive
  mstore [r8,-3] r0
  mload r0 [r8,-7]
  not r7 2
  add r7 r7 1
  add r0 r0 r7
  mstore [r8,-5] r0
  mload r1 [r8,-5]
  call fib_recursive
  mload r1 [r8,-3]
  add r0 r1 r0
  mstore [r8,-6] r0
  mload r0 [r8,-6]
  add r8 r8 -9
  ret
fib_non_recursive:
.LBL2_0:
  add r8 r8 5
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 0
  mstore [r8,-2] r0
  mov r0 1
  mstore [r8,-3] r0
  mov r0 1
  mstore [r8,-4] r0
  mov r0 2
  mstore [r8,-5] r0
  jmp .LBL2_1
.LBL2_1:
  mload r0 [r8,-5]
  mload r1 [r8,-1]
  gte r0 r1 r0
  cjmp r0 .LBL2_2
  jmp .LBL2_4
.LBL2_2:
  mload r1 [r8,-2]
  mload r2 [r8,-3]
  add r0 r1 r2
  mstore [r8,-4] r0
  mload r0 [r8,-3]
  mstore [r8,-2] r0
  mload r0 [r8,-4]
  mstore [r8,-3] r0
  jmp .LBL2_3
.LBL2_3:
  mload r1 [r8,-5]
  add r0 r1 1
  mstore [r8,-5] r0
  jmp .LBL2_1
.LBL2_4:
  mload r0 [r8,-4]
  add r8 r8 -5
  ret
"
        );
    }

    #[ignore]
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
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL0_0:
  add r8 r8 4
  mstore [r8,-2] r8
  mov r1 1
  call eq_rr
  add r8 r8 -4
  end
eq_ri:
.LBL1_0:
  add r8 r8 1
  mov r0 r1
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  eq r0 r0 1
  cjmp r0 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 2
  add r8 r8 -1
  ret
.LBL1_2:
  mov r0 3
  add r8 r8 -1
  ret
eq_rr:
.LBL2_0:
  add r8 r8 2
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 1
  mstore [r8,-2] r0
  mload r0 [r8,-1]
  mload r1 [r8,-2]
  eq r0 r0 r1
  cjmp r0 .LBL2_1
  jmp .LBL2_2
.LBL2_1:
  mov r0 2
  add r8 r8 -2
  ret
.LBL2_2:
  mov r0 3
  add r8 r8 -2
  ret
neq_ri:
.LBL3_0:
  add r8 r8 1
  mov r0 r1
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  neq r0 r0 1
  cjmp r0 .LBL3_1
  jmp .LBL3_2
.LBL3_1:
  mov r0 2
  add r8 r8 -1
  ret
.LBL3_2:
  mov r0 3
  add r8 r8 -1
  ret
neq_rr:
.LBL4_0:
  add r8 r8 2
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 1
  mstore [r8,-2] r0
  mload r0 [r8,-1]
  mload r1 [r8,-2]
  neq r0 r0 r1
  cjmp r0 .LBL4_1
  jmp .LBL4_2
.LBL4_1:
  mov r0 2
  add r8 r8 -2
  ret
.LBL4_2:
  mov r0 3
  add r8 r8 -2
  ret
lt_ri:
.LBL5_0:
  add r8 r8 1
  mov r0 r1
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  mov r1 1
  gte r1 r1 r0
  neq r0 r0 1
  and r1 r1 r0
  cjmp r1 .LBL5_1
  jmp .LBL5_2
.LBL5_1:
  mov r0 2
  add r8 r8 -1
  ret
.LBL5_2:
  mov r0 3
  add r8 r8 -1
  ret
lt_rr:
.LBL6_0:
  add r8 r8 2
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 1
  mstore [r8,-2] r0
  mload r0 [r8,-1]
  mload r1 [r8,-2]
  gte r2 r1 r0
  neq r0 r0 r1
  and r2 r2 r0
  cjmp r2 .LBL6_1
  jmp .LBL6_2
.LBL6_1:
  mov r0 2
  add r8 r8 -2
  ret
.LBL6_2:
  mov r0 3
  add r8 r8 -2
  ret
lte_ri:
.LBL7_0:
  add r8 r8 1
  mov r0 r1
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  mov r7 1
  gte r0 r7 r0
  cjmp r0 .LBL7_1
  jmp .LBL7_2
.LBL7_1:
  mov r0 2
  add r8 r8 -1
  ret
.LBL7_2:
  mov r0 3
  add r8 r8 -1
  ret
lte_rr:
.LBL8_0:
  add r8 r8 2
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 1
  mstore [r8,-2] r0
  mload r0 [r8,-1]
  mload r1 [r8,-2]
  gte r0 r1 r0
  cjmp r0 .LBL8_1
  jmp .LBL8_2
.LBL8_1:
  mov r0 2
  add r8 r8 -2
  ret
.LBL8_2:
  mov r0 3
  add r8 r8 -2
  ret
gt_ri:
.LBL9_0:
  add r8 r8 1
  mov r0 r1
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  gte r1 r0 1
  neq r0 r0 1
  and r1 r1 r0
  cjmp r1 .LBL9_1
  jmp .LBL9_2
.LBL9_1:
  mov r0 2
  add r8 r8 -1
  ret
.LBL9_2:
  mov r0 3
  add r8 r8 -1
  ret
gt_rr:
.LBL10_0:
  add r8 r8 2
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 1
  mstore [r8,-2] r0
  mload r0 [r8,-1]
  mload r1 [r8,-2]
  gte r2 r0 r1
  neq r0 r0 r1
  and r2 r2 r0
  cjmp r2 .LBL10_1
  jmp .LBL10_2
.LBL10_1:
  mov r0 2
  add r8 r8 -2
  ret
.LBL10_2:
  mov r0 3
  add r8 r8 -2
  ret
gte_ri:
.LBL11_0:
  add r8 r8 1
  mov r0 r1
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  gte r0 r0 1
  cjmp r0 .LBL11_1
  jmp .LBL11_2
.LBL11_1:
  mov r0 2
  add r8 r8 -1
  ret
.LBL11_2:
  mov r0 3
  add r8 r8 -1
  ret
gte_rr:
.LBL12_0:
  add r8 r8 2
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 1
  mstore [r8,-2] r0
  mload r0 [r8,-1]
  mload r1 [r8,-2]
  gte r0 r0 r1
  cjmp r0 .LBL12_1
  jmp .LBL12_2
.LBL12_1:
  mov r0 2
  add r8 r8 -2
  ret
.LBL12_2:
  mov r0 3
  add r8 r8 -2
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
  mov r3 r1
  mov r1 r3
.PROPHET3_0:
  mov r0 psp
  mload r0 [r0,0]
  range r0
  mul r2 r0 r0
  assert r2 r3
  ret
main:
.LBL4_0:
  add r9 r9 4
  mstore [r9,-2] r9
  mov r1 4
  call sqrt_test
  add r9 r9 -4
  end
sqrt_test:
.LBL5_0:
  add r9 r9 6
  mstore [r9,-2] r9
  mov r0 r1
  mstore [r9,-4] r0
  mload r1 [r9,-4]
  call u32_sqrt
  mstore [r9,-3] r0
  mload r0 [r9,-3]
  add r9 r9 -6
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

    #[ignore]
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
        assert_eq!(
            format!("{}", code.program),
            "main:
.LBL5_0:
  add r8 r8 4
  mstore [r8,-2] r8
  mov r1 4
  call sqrt_test
  add r8 r8 -4
  end
sqrt_test:
.LBL6_0:
  add r8 r8 17
  mov r0 r1
  mstore [r8,-14] r0
  mov r0 0
  mstore [r8,-15] r0
  mload r0 [r8,-14]
  gte r1 r0 3
  neq r0 r0 3
  and r1 r1 r0
  cjmp r1 .LBL6_1
  jmp .LBL6_2
.LBL6_1:
  mload r0 [r8,-14]
  mstore [r8,-15] r0
  mload r0 [r8,-14]
  mstore [r8,-11] r0
  mload r0 [r8,-11]
  mov r1 r0
  mov r2 2
.PROPHET6_0:
  mov r0 psp
  mload r0 [r0,0]
  mstore [r8,-10] r0
  mload r0 [r8,-10]
  range r0
  mov r0 2
  mload r1 [r8,-10]
  add r3 r1 1
  not r7 r3
  add r7 r7 1
  add r4 r0 r7
  range r4
  mload r0 [r8,-11]
  mov r1 r0
  mov r2 2
.PROPHET6_1:
  mov r0 psp
  mload r0 [r0,0]
  range r0
  mul r5 r0 2
  mload r1 [r8,-10]
  add r1 r5 r1
  mstore [r8,-13] r1
  mload r1 [r8,-13]
  mload r2 [r8,-11]
  assert r1 r2
  add r0 r0 1
  mstore [r8,-12] r0
  mload r0 [r8,-12]
  range r0
  mload r0 [r8,-12]
  mstore [r8,-16] r0
  mov r0 0
  mstore [r8,-17] r0
  jmp .LBL6_4
.LBL6_2:
  mload r0 [r8,-14]
  neq r0 r0 0
  cjmp r0 .LBL6_10
  jmp .LBL6_11
.LBL6_3:
  mload r0 [r8,-15]
  add r8 r8 -17
  ret
.LBL6_4:
  mload r0 [r8,-17]
  mov r1 100
  gte r1 r1 r0
  neq r0 r0 100
  and r1 r1 r0
  cjmp r1 .LBL6_5
  jmp .LBL6_7
.LBL6_5:
  mload r0 [r8,-16]
  mload r1 [r8,-15]
  gte r0 r0 r1
  cjmp r0 .LBL6_8
  jmp .LBL6_9
.LBL6_6:
  mload r1 [r8,-17]
  add r0 r1 1
  mstore [r8,-17] r0
  jmp .LBL6_4
.LBL6_7:
  jmp .LBL6_3
.LBL6_8:
  jmp .LBL6_7
.LBL6_9:
  mload r0 [r8,-16]
  mstore [r8,-15] r0
  mload r0 [r8,-14]
  mstore [r8,-3] r0
  mload r0 [r8,-16]
  mstore [r8,-2] r0
  mload r0 [r8,-3]
  mov r1 r0
  mload r0 [r8,-2]
  mov r2 r0
.PROPHET6_2:
  mov r0 psp
  mload r0 [r0,0]
  mstore [r8,-1] r0
  mload r0 [r8,-1]
  range r0
  mload r0 [r8,-1]
  add r3 r0 1
  not r7 r3
  add r7 r7 1
  mload r0 [r8,-2]
  add r4 r0 r7
  range r4
  mload r0 [r8,-3]
  mov r1 r0
  mload r0 [r8,-2]
  mov r2 r0
.PROPHET6_3:
  mov r0 psp
  mload r0 [r0,0]
  range r0
  mload r1 [r8,-2]
  mul r5 r0 r1
  mload r1 [r8,-1]
  add r1 r5 r1
  mstore [r8,-9] r1
  mload r1 [r8,-9]
  mload r2 [r8,-3]
  assert r1 r2
  mload r1 [r8,-16]
  add r0 r0 r1
  mstore [r8,-5] r0
  mload r0 [r8,-5]
  range r0
  mload r0 [r8,-5]
  mov r1 r0
  mov r2 2
.PROPHET6_4:
  mov r0 psp
  mload r0 [r0,0]
  mov r3 r0
  range r3
  mov r0 2
  add r1 r3 1
  mstore [r8,-8] r1
  mload r1 [r8,-8]
  not r7 r1
  add r7 r7 1
  add r0 r0 r7
  mstore [r8,-7] r0
  mload r0 [r8,-7]
  range r0
  mload r0 [r8,-5]
  mov r1 r0
  mov r2 2
.PROPHET6_5:
  mov r0 psp
  mload r0 [r0,0]
  range r0
  mul r1 r0 2
  mstore [r8,-6] r1
  mload r1 [r8,-6]
  add r1 r1 r3
  mstore [r8,-4] r1
  mload r1 [r8,-5]
  mload r2 [r8,-4]
  assert r2 r1
  mstore [r8,-16] r0
  jmp .LBL6_6
.LBL6_10:
  mov r0 1
  mstore [r8,-15] r0
  jmp .LBL6_11
.LBL6_11:
  jmp .LBL6_3
"
        );
    }

    #[ignore]
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
            "
"
        );
    }
}
