pub mod ola;

use crate::codegen::core::ir::module::data_layout::DataLayout;
use crate::codegen::{
    call_conv::CallConvKind,
    function::instruction::TargetInst,
    lower,
    module::Module,
    register::{RegisterClass, RegisterInfo},
};
use anyhow::Result;

pub trait TargetIsa: Clone {
    type Inst: TargetInst;
    type RegClass: RegisterClass;
    type RegInfo: RegisterInfo;
    type Lower: lower::Lower<Self>;

    fn module_passes() -> Vec<for<'a, 'b> fn(&'b mut Module<'a, Self>) -> Result<()>>; // TODO: Implement a pass manager for machine modules
    fn default_call_conv() -> CallConvKind;
    fn data_layout(&self) -> &DataLayout;
}
