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
    use crate::codegen::{core::ir::module::Module, isa::ola::Ola, lower::compile_module};
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
        assert_eq!(
            format!("{}", mach_module.display_asm()),
            "main:
.LBL0_0:
  add r8 r8 1
  mov r4 10
  mstore [r8,-1] r4
  mload r4 [r8,-1]
  add r0 r4 20
  add r1 r4 30
  mul r2 r0 r1
  not r7 r1
  add r7 r7 1
  add r3 r2 r7
  mov r0 r3
  not r7 1
  add r7 r7 1
  add r8 r8 r7
  ret 
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
        assert_eq!(
            format!("{}", mach_module.display_asm()),
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
  not r7 7
  add r7 r7 1
  add r8 r8 r7
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
  not r7 3
  add r7 r7 1
  add r8 r8 r7
  ret 
"
        );
    }

    #[test]
    fn codegen_fib_recursive_test() {
        // LLVM Assembly
        let asm = r#"
    ; ModuleID = 'Fibonacci'
    source_filename = "../../examples/fib.ola"
    
    define void @main() {
    entry:
      %0 = call i32 @fib_recursive(i32 10)
      ret void
    }
    
    define i32 @fib_recursive(i32 %0) {
    entry:
      %1 = icmp eq i32 %0, 1
      br i1 %1, label %then, label %enif
    
    then:                                             ; preds = %entry
      ret i32 1
    
    enif:                                             ; preds = %entry
      %2 = icmp eq i32 %0, 2
      br i1 %2, label %then1, label %enif2
    
    then1:                                            ; preds = %enif
      ret i32 1
    
    enif2:                                            ; preds = %enif
      %3 = sub i32 %0, 1
      %4 = call i32 @fib_recursive(i32 %3)
      %5 = sub i32 %0, 2
      %6 = call i32 @fib_recursive(i32 %5)
      %7 = add i32 %4, %6
      ret i32 %7
    }
"#;

        // Parse the assembly and get a module
        let module = Module::try_from(asm).expect("failed to parse LLVM IR");

        // Compile the module for Ola and get a machine module
        let isa = Ola::default();
        let mach_module = compile_module(&isa, &module).expect("failed to compile");
        // Display the machine module as assembly
        assert_eq!(
            format!("{}", mach_module.display_asm()),
            "main:
.LBL0_0:
  add r8 r8 4
  mstore [r8,-2] r8
  mov r1 10
  call fib_recursive
  not r7 4
  add r7 r7 1
  add r8 r8 r7
  end 
fib_recursive:
.LBL1_0:
  add r8 r8 9
  mstore [r8,-2] r8
  mov r0 r1
  mstore [r8,-7] r0
  mload r0 [r8,-7]
  eq r0 r0 1
  cjmp r0 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 1
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
.LBL1_2:
  mload r0 [r8,-7]
  eq r0 r0 2
  cjmp r0 .LBL1_3
  jmp .LBL1_4
.LBL1_3:
  mov r0 1
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
.LBL1_4:
  not r7 1
  add r7 r7 1
  mload r0 [r8,-7]
  add r1 r0 r7
  call fib_recursive
  mstore [r8,-4] r0
  not r7 2
  add r7 r7 1
  mload r0 [r8,-7]
  add r0 r0 r7
  mstore [r8,-6] r0
  mload r1 [r8,-6]
  call fib_recursive
  mload r1 [r8,-4]
  add r0 r1 r0
  mstore [r8,-5] r0
  mload r0 [r8,-5]
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
"
        );
    }
}
