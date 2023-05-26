use crate::codegen::{
    function::Function,
    isa::ola::{
        instruction::{Opcode, Operand, OperandData},
        register::reg_to_str,
        Ola,
    },
    module::{DisplayAsm, Module},
    register::Reg,
};
use std::{fmt, str};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct AsmProgram {
    pub program: String,
    pub prophets: Vec<Prophet>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Prophet {
    pub label: String,
    pub code: String,
    pub inputs: Vec<Input>,
    pub outputs: Vec<Output>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Input {
    pub name: String,
    pub length: u64,
    pub is_ref: bool,
    pub is_input_output: bool,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Output {
    pub name: String,
    pub length: u64,
    pub is_ref: bool,
    pub is_input_output: bool,
}

const SQRT: &'static str = "%{
    entry() {
        cid.y = sqrt(cid.x);
    }
%}";

const DIV: &'static str = "%{
    function div(felt x, felt y) -> felt {
        return x / y;
    }
    entry() {
        cid.q = div(cid.x, cid.y);
    }
%}";

const MOD: &'static str = "%{
    function mod(felt x, felt y) -> felt {
        return x % y;
    }
    entry() {
        cid.r = mod(cid.x, cid.y);
    }
%}";

const DIV_MOD: &'static str = "%{
    entry() {
        (cid.q, cid.r) = divmod(cid.x, cid.y);
    }
    function divmod(felt x, felt y) -> (felt, felt) {
        return (x / y, x % y);
    }
%}";

const ARR_SORT: &'static str = "%{
    entry() {
        cid.arrOut = sort(cid.arrIn, cid.len);
    }
    function sort(felt[] arr, felt len) -> felt[] {
        felt n = len;
        for (felt i = 0; i < n - 1; i++) {
            for (felt j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    felt temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                }
            }
        }
        return arr;
    }
%}";

pub fn from_prophet(name: &str, fn_idx: usize, pht_idx: usize) -> Prophet {
    match name {
        "prophet_u32_sqrt" => Prophet {
            code: SQRT.to_string(),
            label: format!(".PROPHET{}_{}", fn_idx.to_string(), pht_idx.to_string()),
            inputs: [Input {
                name: "cid.x".to_string(),
                length: 1,
                is_ref: false,
                is_input_output: false,
            }]
            .to_vec(),
            outputs: [Output {
                name: "cid.y".to_string(),
                length: 1,
                is_ref: false,
                is_input_output: false,
            }]
            .to_vec(),
        },
        "prophet_u32_div" => Prophet {
            code: DIV.to_string(),
            label: format!(".PROPHET{}_{}", fn_idx.to_string(), pht_idx.to_string()),
            inputs: [
                Input {
                    name: "cid.x".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
                Input {
                    name: "cid.y".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
            ]
            .to_vec(),
            outputs: [Output {
                name: "cid.q".to_string(),
                length: 1,
                is_ref: false,
                is_input_output: false,
            }]
            .to_vec(),
        },
        "prophet_u32_mod" => Prophet {
            code: MOD.to_string(),
            label: format!(".PROPHET{}_{}", fn_idx.to_string(), pht_idx.to_string()),
            inputs: [
                Input {
                    name: "cid.x".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
                Input {
                    name: "cid.y".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
            ]
            .to_vec(),
            outputs: [Output {
                name: "cid.r".to_string(),
                length: 1,
                is_ref: false,
                is_input_output: false,
            }]
            .to_vec(),
        },
        "prophet_div_mod" => Prophet {
            code: DIV_MOD.to_string(),
            label: format!(".PROPHET{}_{}", fn_idx.to_string(), pht_idx.to_string()),
            inputs: [
                Input {
                    name: "cid.x".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
                Input {
                    name: "cid.y".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
            ]
            .to_vec(),
            outputs: [
                Output {
                    name: "cid.q".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
                Output {
                    name: "cid.r".to_string(),
                    length: 1,
                    is_ref: false,
                    is_input_output: false,
                },
            ]
            .to_vec(),
        },
        "prophet_u32_array_sort" => Prophet {
            code: ARR_SORT.to_string(),
            label: format!(".PROPHET{}_{}", fn_idx.to_string(), pht_idx.to_string()),
            inputs: [
                Input {
                    name: "cid.arrIn".to_string(),
                    length: 1,
                    is_ref: true,
                    is_input_output: false,
                },
                Input {
                    name: "cid.len".to_string(),
                    length: 1,
                    is_ref: true,
                    is_input_output: false,
                },
            ]
            .to_vec(),
            outputs: [Output {
                name: "cid.arrOut".to_string(),
                length: 1,
                is_ref: true,
                is_input_output: false,
            }]
            .to_vec(),
        },
        e => todo!("{:?}", e),
    }
}

impl fmt::Display for DisplayAsm<'_, Ola> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        print(f, self.0)
    }
}

pub fn print(f: &mut fmt::Formatter<'_>, module: &Module<Ola>) -> fmt::Result {
    let mut prophets = vec![];
    let mut program = "".to_string();
    for (i, (_, func)) in module.functions.iter().enumerate() {
        let inst = print_function(func, i, &mut prophets);
        program.push_str(&format!("{}", inst));
    }
    let asm_program = AsmProgram { program, prophets };
    let serialized = serde_json::to_string_pretty(&asm_program).unwrap();
    writeln!(f, "{}", serialized)?;

    Ok(())
}

pub fn print_function(
    function: &Function<Ola>,
    fn_idx: usize,
    prophets: &mut Vec<Prophet>,
) -> String {
    if function.is_declaration {
        return "".to_string();
    }

    let mut prophet_index: usize = 0;
    let mut code = format!("{}:\n", function.ir.name());

    for block in function.layout.block_iter() {
        code.push_str(&format!(".LBL{}_{}:\n", fn_idx, block.index()));
        for inst in function.layout.inst_iter(block) {
            let inst = function.data.inst_ref(inst);
            if Opcode::MSTOREr == inst.data.opcode {
                if matches!(&inst.data.operands[0].data, OperandData::Reg(Reg(0, 8)))
                    && matches!(&inst.data.operands[1].data, OperandData::Reg(Reg(0, 8)))
                {
                    code.push_str(&format!("  mstore [r8,-2] r8\n"));
                    continue;
                }
            }

            if Opcode::RET == inst.data.opcode {
                let mut term = "  ret";
                if function.ir.name() == "main" {
                    term = "  end";
                }
                code.push_str(&format!("{}", term));
            } else if inst.data.opcode == Opcode::PROPHET {
                let name = write_operand(&inst.data.operands[1].data, fn_idx);
                code.push_str(&format!(".PROPHET{}_{}:\n", fn_idx, prophet_index));
                code.push_str(&format!("  mov r0 psp\n"));
                /* if name == "prophet_u32_array_sort" {
                    for idx in 1..7 {
                        code.push_str(&format!("  mload r{} [r{},{}]\n", idx, idx, idx));
                    }
                }
                code.push_str(&format!("  mload r0 [r0,0]\n")); */

                assert_eq!(inst.data.operands.len(), 2);
                prophets.push(from_prophet(name.as_str(), fn_idx, prophet_index));

                prophet_index += 1;

                continue;
            } else {
                code.push_str(&format!("  {} ", inst.data.opcode));
            }
            let mut i = 0;
            while i < inst.data.operands.len() {
                let operand = &inst.data.operands[i];
                if operand.implicit {
                    i += 1;
                    continue;
                }
                if matches!(operand.data, OperandData::MemStart) {
                    i += 1;
                    let sz = mem_size(&inst.data.opcode);
                    code.push_str(&format!("{}", sz));
                    if !sz.is_empty() {
                        code.push_str(&format!(" "));
                    }
                    code.push_str(&format!("{}", mem_op(&inst.data.operands[i..i + 6])));
                    i += 6 - 1;
                } else {
                    code.push_str(&format!("{}", write_operand(&operand.data, fn_idx)));
                }
                if i < inst.data.operands.len() - 1 {
                    code.push_str(&format!(" "))
                }
                i += 1;
            }
            code.push_str(&format!("\n"));
        }
    }

    code
}

impl fmt::Display for Opcode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Self::ADDri | Self::ADDrr => "add",
                Self::MULri | Self::MULrr => "mul",
                Self::MOVri | Self::MOVrr => "mov",
                Self::JMPi | Self::JMPr => "jmp",
                Self::CJMPi | Self::CJMPr => "cjmp",
                Self::CALL => "call",
                Self::RET => "ret",
                Self::Phi => "PHI",
                Self::PROPHET => "prophet",
                Self::MLOADi | Self::MLOADr => "mload",
                Self::MSTOREi | Self::MSTOREr => "mstore",
                Self::NOT => "not",
                Self::GTE => "gte",
                Self::NEQ => "neq",
                Self::EQri | Self::EQrr => "eq",
                Self::AND => "and",
                Self::OR => "or",
                Self::XOR => "xor",
                Self::RANGECHECK => "range",
                Self::ASSERTri | Self::ASSERTrr => "assert",
                e => todo!("{:?}", e),
            }
        )
    }
}

fn write_operand(op: &OperandData, fn_idx: usize) -> String {
    match op {
        OperandData::Reg(r) => format!("{}", reg_to_str(r)),
        OperandData::VReg(r) => format!("%{}", r.0),
        OperandData::Slot(slot) => format!("{:?}", slot),
        OperandData::Int8(i) => format!("{}", i),
        OperandData::Int32(i) => format!("{}", i),
        OperandData::Int64(i) => format!("{}", i),
        OperandData::Block(block) => format!(".LBL{}_{}", fn_idx, block.index()),
        OperandData::Label(name) => format!("{}", name),
        OperandData::MemStart => format!(""),
        OperandData::GlobalAddress(name) => format!("offset {}", name),
        OperandData::None => format!("none"),
    }
}

fn mem_size(_opcode: &Opcode) -> &'static str {
    ""
}

fn mem_op(args: &[Operand]) -> String {
    // return  format!("[{}]", "abc");
    assert!(matches!(&args[1].data, &OperandData::None)); // assure slot is eliminated
    match (
        &args[0].data,
        &args[2].data,
        &args[3].data,
        &args[4].data,
        &args[5].data,
    ) {
        (
            OperandData::Label(name),
            OperandData::None,
            OperandData::None,
            OperandData::None,
            OperandData::None,
        ) => {
            format!("[{}]", name)
        }
        (
            OperandData::None,
            OperandData::Int32(imm),
            OperandData::Reg(reg),
            OperandData::None,
            OperandData::None,
        ) => {
            format!(
                "[{},{}{}]",
                reg_to_str(reg),
                if *imm < 0 { "" } else { "+" },
                *imm
            )
        }
        (
            OperandData::None,
            OperandData::Int64(imm),
            OperandData::Reg(reg),
            OperandData::None,
            OperandData::None,
        ) => {
            format!(
                "[{},{}{}]",
                reg_to_str(reg),
                if *imm < 0 { "" } else { "+" },
                *imm
            )
        }
        (
            OperandData::None,
            OperandData::Int32(imm),
            OperandData::Reg(reg1),
            OperandData::Reg(reg2),
            OperandData::Int32(shift),
        ) => {
            format!(
                "[{}{}{}+{}*{}]",
                reg_to_str(reg1),
                if *imm < 0 { "" } else { "+" },
                *imm,
                reg_to_str(reg2),
                shift
            )
        }
        (
            OperandData::None,
            OperandData::None,
            OperandData::Reg(reg1),
            OperandData::None,
            OperandData::None,
        ) => {
            format!("[{}]", reg_to_str(reg1),)
        }
        (
            OperandData::None,
            OperandData::None,
            OperandData::Reg(reg1),
            OperandData::Reg(reg2),
            OperandData::Int32(mul),
        ) => {
            format!("[{}+{}*{}]", reg_to_str(reg1), reg_to_str(reg2), mul)
        }
        (
            OperandData::Label(lbl),
            OperandData::None,
            OperandData::Reg(reg1),
            OperandData::None,
            OperandData::None,
        ) => {
            format!("[{} + {lbl}]", reg_to_str(reg1))
        }
        e => todo!("{:?}", e),
    }
}
