use vicis_codegen::{self, isa::ola::Ola, lower::compile_module};
use vicis_core::ir::module::Module;

fn main() {
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

    // Compile the module for x86 and get a machine module
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
  eq r0 1
  cjmp .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 1
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
.LBL1_2:
  mload r0 [r8,-7]
  eq r0 2
  cjmp .LBL1_3
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
  mstore [r8,-3] r0
  not r7 2
  add r7 r7 1
  mload r0 [r8,-7]
  add r0 r0 r7
  mstore [r8,-5] r0
  mload r1 [r8,-5]
  call fib_recursive
  mload r1 [r8,-3]
  add r0 r1 r0
  mstore [r8,-6] r0
  mload r0 [r8,-6]
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
"
    );
}
