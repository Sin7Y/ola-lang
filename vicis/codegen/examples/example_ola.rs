use vicis_codegen::{self, isa::ola::Ola, lower::compile_module};
use vicis_core::ir::module::Module;

fn main() {
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

    // Compile the module for x86 and get a machine module
    let isa = Ola::default();
    let mach_module = compile_module(&isa, &module).expect("failed to compile");
    println!("{}",mach_module.display_asm());

    // Display the machine module as assembly
    assert_eq!(
        format!("{}", mach_module.display_asm()),
        "main:
.LBL0_0:
  add r8 r8 1
  mstore [r8,-1] 10
  mload r4 [r8,-1]
  add r0 r4 20
  add r1 r4 30
  mul r2 r0 r1
  not r6 r1
  add r6 r6 1
  add r3 r2 r6
  mov r0 r3
  not r6 1
  add r6 r6 1
  add r8 r8 r6
  ret 
"
    );
}
