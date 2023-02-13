use vicis_codegen::{self, isa::ola::Ola, lower::compile_module};
use vicis_core::ir::module::Module;

fn main() {
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

    // Compile the module for x86 and get a machine module
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
