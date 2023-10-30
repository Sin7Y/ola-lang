use crate::codegen::{
    function::{basic_block::BasicBlockId, instruction::Instruction, Function},
    isa::ola::{
        instruction::{InstructionData, Opcode, Operand, OperandData},
        Ola,
    },
    module::Module,
    register::Reg,
};
use anyhow::Result;
use rustc_hash::FxHashMap;

pub fn run_on_module(module: &mut Module<Ola>) -> Result<()> {
    for (_, func) in &mut module.functions {
        run_on_function(func);
    }
    Ok(())
}

pub fn run_on_function(function: &mut Function<Ola>) {
    let mut worklist = vec![];
    let mut map: FxHashMap<Reg, Vec<(OperandData, BasicBlockId)>> = FxHashMap::default();

    for block_id in function.layout.block_iter() {
        for inst_id in function.layout.inst_iter(block_id) {
            let inst = function.data.inst_ref(inst_id);
            if !matches!(inst.data.opcode, Opcode::Phi) {
                continue;
            }
            worklist.push(inst_id);
            let output = *inst.data.operands[0].data.as_reg();
            for i in (0..inst.data.operands[1..].len()).step_by(2) {
                let val = inst.data.operands[1 + i].data.clone();
                let block = *inst.data.operands[1 + i + 1].data.as_block();
                map.entry(output)
                    .or_insert_with(Vec::new)
                    .push((val, block));
            }
        }
    }

    for (output, args) in map {
        for (arg, block) in args {
            let maybe_term = function.layout.last_inst_of(block).unwrap();
            let copy = match arg {
                OperandData::Int32(_) | OperandData::Int64(_) => Instruction::new(
                    InstructionData {
                        opcode: Opcode::MOVri,
                        operands: vec![
                            Operand::output(OperandData::Reg(output)),
                            Operand::new(arg),
                        ],
                    },
                    block,
                ),
                OperandData::Reg(_) => Instruction::new(
                    InstructionData {
                        opcode: Opcode::MOVrr,
                        operands: vec![
                            Operand::output(OperandData::Reg(output)),
                            Operand::input(arg),
                        ],
                    },
                    block,
                ),
                _ => todo!(),
            };
            let copy = function.data.create_inst(copy);
            function.layout.insert_inst_before(maybe_term, copy, block);
        }
    }

    for inst_id in worklist {
        function.remove_inst(inst_id);
    }
}

#[cfg(test)]
mod test {
    use crate::codegen::{
        core::ir::module::Module,
        isa::ola::{asm::AsmProgram, Ola},
        lower::compile_module,
    };
    #[test]
    fn codegen_phi_test() {
        // LLVM Assembly
        let asm = r#"

        define i32 @phi(i64 %0) {
        entry:
          %1 = add i64 %0, 1
          br label %bb0        
        bb0:                                                ; preds = %1
          br label %bb2       
        bb1:                                                ; preds = %1
          br label %bb2        
        bb2:                                                ; preds = %4, %3
          %phi = phi i64 [ 100, %bb0 ], [ %1, %bb1 ]
          ret i64 %phi
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
            "phi:
.LBL0_0:
  mov r6 r1
  add r5 r6 1
  jmp .LBL0_1
.LBL0_1:
  mov r0 100
  jmp .LBL0_3
.LBL0_2:
  mov r0 r5
  jmp .LBL0_3
.LBL0_3:
  ret
"
        );
    }
}
