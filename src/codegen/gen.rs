use super::builder::AsmBuilder;
use super::func::FunctionInfo;
use super::info::{cur_func, cur_func_mut, ProgramInfo};
use super::values::{asm_value, AsmValue, LocalValue};
use crate::ir::program::ValueData;
use crate::ir::values::*;
use crate::ir::{BasicBlock, Function, FunctionData, Program, TypeKind, Value, ValueKind};
use std::fs::File;
use std::io::{Result, Write};

/// Trait for generating Ola assembly.
pub trait GenerateToAsm<'p, 'i> {
    type Out;

    fn generate(&self, f: &mut File, info: &'i mut ProgramInfo<'p>) -> Result<Self::Out>;
}

/// Trait for generating Ola assembly (for values).
trait GenerateValueToAsm<'p, 'i> {
    type Out;

    fn generate(
        &self,
        f: &mut File,
        info: &'i mut ProgramInfo<'p>,
        v: &ValueData,
    ) -> Result<Self::Out>;
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Program {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        // generate global allocations
        for &value in self.inst_layout() {
            let data = self.borrow_value(value);
            let name = &data.name().as_ref().unwrap()[1..];
            info.insert_value(value, name.into());
            writeln!(f, "  .data")?;
            writeln!(f, "  .globl {name}")?;
            writeln!(f, "{name}:")?;
            data.generate(f, info)?;
            writeln!(f)?;
        }
        // generate functions
        for &func in self.func_layout() {
            info.set_cur_func(FunctionInfo::new(func));
            self.func(func).generate(f, info)?;
        }
        Ok(())
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Function {
    type Out = &'p str;

    fn generate(&self, _: &mut File, info: &mut ProgramInfo<'p>) -> Result<Self::Out> {
        Ok(&info.program().func(*self).name()[1..])
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for FunctionData {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        // skip declarations
        if self.layout().entry_bb().is_none() {
            return Ok(());
        }
        // allocation stack slots and log argument number
        let func = cur_func_mut!(info);
        for value in self.dfg().values().values() {
            // allocate stack slot
            if value.kind().is_local_inst() && !value.used_by().is_empty() {
                func.alloc_slot(value);
            }
            // log argument number
            if let ValueKind::Call(call) = value.kind() {
                func.log_arg_num(call.args().len());
            }
        }
        // generate basic block names
        for (&bb, data) in self.dfg().bbs() {
            // basic block parameters are not supported
            assert!(data.params().is_empty());
            func.log_bb_name(bb, data.name());
        }
        // generate prologue
        AsmBuilder::new(f, "r0").prologue(self.name(), func)?;
        // generate instructions in basic blocks
        for (bb, node) in self.layout().bbs() {
            let name = bb.generate(f, info)?;
            writeln!(f, "{name}:")?;
            for &inst in node.insts().keys() {
                self.dfg().value(inst).generate(f, info)?;
            }
        }
        writeln!(f)
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for BasicBlock {
    type Out = &'i str;

    fn generate(&self, _: &mut File, info: &'i mut ProgramInfo) -> Result<Self::Out> {
        Ok(cur_func!(info).bb_name(*self))
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Value {
    type Out = AsmValue<'i>;

    fn generate(&self, _: &mut File, info: &'i mut ProgramInfo) -> Result<Self::Out> {
        if self.is_global() {
            Ok(AsmValue::Global(info.value(*self)))
        } else {
            let func = cur_func!(info);
            let value = info.program().func(func.func()).dfg().value(*self);
            Ok(match value.kind() {
                ValueKind::Uint32(i) => AsmValue::Const(i.value()),
                ValueKind::FuncArgRef(i) => AsmValue::Arg(i.index()),
                _ => AsmValue::from(func.slot_offset(value)),
            })
        }
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for ValueData {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        match self.kind() {
            ValueKind::Uint32(v) => v.generate(f, info),
            ValueKind::Aggregate(v) => v.generate(f, info),
            ValueKind::GlobalAlloc(v) => v.generate(f, info),
            ValueKind::Load(v) => v.generate(f, info, self),
            ValueKind::Store(v) => v.generate(f, info),
            ValueKind::GetPtr(v) => v.generate(f, info, self),
            ValueKind::GetElemPtr(v) => v.generate(f, info, self),
            ValueKind::Binary(v) => v.generate(f, info, self),
            ValueKind::Branch(v) => v.generate(f, info),
            ValueKind::Jump(v) => v.generate(f, info),
            ValueKind::Call(v) => v.generate(f, info, self),
            ValueKind::Return(v) => v.generate(f, info),
            _ => Ok(()),
        }
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Uint32 {
    type Out = ();

    fn generate(&self, f: &mut File, _: &mut ProgramInfo) -> Result<Self::Out> {
        writeln!(f, "  .word {}", self.value())
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Aggregate {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        for &elem in self.elems() {
            info.program().borrow_value(elem).generate(f, info)?;
        }
        Ok(())
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for GlobalAlloc {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        info.program().borrow_value(self.init()).generate(f, info)
    }
}

impl<'p, 'i> GenerateValueToAsm<'p, 'i> for Load {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo, v: &ValueData) -> Result<Self::Out> {
        Ok(())
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Store {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        Ok(())
    }
}

impl<'p, 'i> GenerateValueToAsm<'p, 'i> for GetPtr {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo, v: &ValueData) -> Result<Self::Out> {
        Ok(())
    }
}

impl<'p, 'i> GenerateValueToAsm<'p, 'i> for GetElemPtr {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo, v: &ValueData) -> Result<Self::Out> {
        Ok(())
    }
}

impl<'p, 'i> GenerateValueToAsm<'p, 'i> for Binary {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo, v: &ValueData) -> Result<Self::Out> {
        self.lhs().generate(f, info)?.write_to(f, "r0")?;
        self.rhs().generate(f, info)?.write_to(f, "r1")?;
        let mut builder = AsmBuilder::new(f, "r2");
        match self.op() {
            BinaryOp::NotEq => {}
            BinaryOp::Eq => {}
            BinaryOp::Gt => {}
            BinaryOp::Lt => {}
            BinaryOp::Ge => {}
            BinaryOp::Le => {}
            BinaryOp::Add => {}
            BinaryOp::Sub => {}
            BinaryOp::Mul => {}
            BinaryOp::Div => {}
            BinaryOp::Mod => {}
            BinaryOp::And => {}
            BinaryOp::Or => {}
            BinaryOp::Xor => {}
            BinaryOp::Shl => {}
            BinaryOp::Shr => {}
            _ => {}
        }
        Ok(())
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Branch {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        Ok(())
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Jump {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        Ok(())
    }
}

impl<'p, 'i> GenerateValueToAsm<'p, 'i> for Call {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo, v: &ValueData) -> Result<Self::Out> {
        Ok(())
    }
}

impl<'p, 'i> GenerateToAsm<'p, 'i> for Return {
    type Out = ();

    fn generate(&self, f: &mut File, info: &mut ProgramInfo) -> Result<Self::Out> {
        if let Some(value) = self.value() {
            value.generate(f, info)?.write_to(f, "r0")?;
        }
        AsmBuilder::new(f, "r0").epilogue(cur_func!(info))
    }
}
