pub mod asm;
pub mod instruction;
pub mod lower;
pub mod pass;
pub mod register;

use super::TargetIsa;
use crate::codegen::core::ir::module::data_layout::DataLayout;
use crate::codegen::{call_conv::CallConvKind, isa::ola, module::Module, pass::regalloc};
use anyhow::Result;

#[derive(Clone)]
pub struct Ola {
    data_layout: DataLayout,
}

impl Default for Ola {
    fn default() -> Self {
        Self {
            data_layout: DataLayout("".to_string()),
        }
    }
}

impl TargetIsa for Ola {
    type Inst = instruction::InstructionData;
    type Lower = ola::lower::Lower;
    type RegClass = register::RegClass;
    type RegInfo = register::RegInfo;

    fn module_passes() -> Vec<for<'a, 'b> fn(&'b mut Module<'a, Self>) -> Result<()>> {
        vec![
            regalloc::run_on_module,
            pass::add_peephole::run_on_module,
            pass::simple_reg_coalescing::run_on_module,
            pass::add_peephole::run_on_module,
            pass::eliminate_slot::run_on_module,
            pass::pro_epi_inserter::run_on_module,
        ]
    }

    fn default_call_conv() -> CallConvKind {
        CallConvKind::SystemV
    }

    fn data_layout(&self) -> &DataLayout {
        &self.data_layout
    }
}
