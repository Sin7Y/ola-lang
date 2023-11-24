use super::{
    super::module::name::Name,
    super::types::Types,
    basic_block::BasicBlockId,
    data::Data,
    instruction::{Instruction, InstructionId, Opcode},
    Function,
};
use crate::codegen::core::ir::types::Type;
use rustc_hash::FxHashMap;
use std::fmt;

pub type Index = usize;
pub type Indexes = FxHashMap<Ids, Name>;

pub struct FunctionAsmPrinter<'a, 'b: 'a> {
    fmt: &'a mut fmt::Formatter<'b>,
    indexes: Indexes,
    cur_index: Index,
}

#[derive(Debug, Copy, Clone, Hash, PartialEq, Eq)]
pub enum Ids {
    Block(BasicBlockId),
    Inst(InstructionId),
    Arg(usize),
}

impl<'a, 'b: 'a> FunctionAsmPrinter<'a, 'b> {
    pub fn new(fmt: &'a mut fmt::Formatter<'b>) -> Self {
        Self {
            fmt,
            indexes: FxHashMap::default(),
            cur_index: 0,
        }
    }

    pub fn print(&mut self, f: &Function) -> fmt::Result {
        if f.is_prototype() {
            write!(self.fmt, "declare ")?
        } else {
            write!(self.fmt, "define ")?
        }

        write!(self.fmt, "{:?} ", f.linkage)?;
        write!(self.fmt, "{:?} ", f.preemption_specifier)?;
        write!(self.fmt, "{:?} ", f.visibility)?;
        for attr in &f.ret_attrs {
            write!(self.fmt, "{} ", attr.to_string(&f.types))?
        }
        write!(self.fmt, "{} ", f.types.to_string(f.result_ty))?;
        write!(self.fmt, "@{}(", f.name)?;

        for (i, param) in f.params.iter().enumerate() {
            write!(self.fmt, "{} ", f.types.to_string(param.ty))?;
            for attr in &param.attrs {
                write!(self.fmt, "{} ", attr.to_string(&f.types))?;
            }
            match param.name.to_string() {
                Some(name) => {
                    write!(self.fmt, "%{}", name)?;
                    self.indexes.insert(Ids::Arg(i), Name::Name(name.clone()));
                }
                None => {
                    let name = self.new_name_for_arg(i);
                    write!(self.fmt, "%{:?}", name)?
                }
            }
            write!(
                self.fmt,
                "{}",
                if i == f.params.len() - 1 { "" } else { ", " }
            )?;
        }

        if f.is_var_arg {
            if f.params.is_empty() {
                write!(self.fmt, "...")?;
            } else {
                write!(self.fmt, ", ...")?;
            }
        }

        write!(self.fmt, ") ")?;

        if let Some(unnamed_addr) = f.unnamed_addr {
            write!(self.fmt, "{:?} ", unnamed_addr)?
        }

        for attr in &f.func_attrs {
            write!(self.fmt, "{:?} ", attr)?
        }

        if let Some(section) = &f.section {
            write!(self.fmt, "section \"{}\" ", section)?
        }

        if let Some((ty, func)) = &f.personality {
            write!(
                self.fmt,
                "personality {} {} ",
                f.types.to_string(*ty),
                func.to_string(&f.types)
            )?
        }

        if f.is_prototype() {
            return writeln!(self.fmt);
        }

        writeln!(self.fmt, "{{")?;

        for block_id in f.layout.block_iter() {
            if let Some(name) = &f.data.block_ref(block_id).name {
                match name.to_string() {
                    Some(name) => {
                        self.indexes
                            .insert(Ids::Block(block_id), Name::Name(name.clone()));
                    }
                    None => {
                        self.new_name_for_block(block_id);
                    }
                }
            } else {
                self.new_name_for_block(block_id);
            }

            for inst_id in f.layout.inst_iter(block_id) {
                let inst = f.data.inst_ref(inst_id);
                if matches!(
                    inst.opcode,
                    Opcode::Store
                        | Opcode::Br
                        | Opcode::CondBr
                        | Opcode::Switch
                        | Opcode::Ret
                        | Opcode::Resume
                ) || (inst
                    .operand
                    .call_result_ty()
                    .as_ref()
                    .map_or(false, Type::is_void))
                {
                    continue;
                }
                if let Some(name) = &inst.dest {
                    match name {
                        Name::Name(name) => {
                            self.indexes
                                .insert(Ids::Inst(inst_id), Name::Name(name.clone()));
                        }
                        Name::Number(_) => {
                            self.new_name_for_inst(inst_id);
                        }
                    }
                } else {
                    self.new_name_for_inst(inst_id);
                }
            }
        }

        for block_id in f.layout.block_iter() {
            writeln!(
                self.fmt,
                "{:?}:",
                self.indexes.get(&Ids::Block(block_id)).unwrap()
            )?;

            for inst_id in f.layout.inst_iter(block_id) {
                let inst = f.data.inst_ref(inst_id);
                write!(self.fmt, "    ")?;
                self.print_inst(inst, &f.types, &f.data)?;
                writeln!(self.fmt)?;
            }
        }

        writeln!(self.fmt, "}}")
    }

    fn print_inst(&mut self, inst: &Instruction, types: &Types, data: &Data) -> fmt::Result {
        write!(
            self.fmt,
            "{}",
            inst.display(data, types)
                .set_inst_name_fn(Box::new(|id| { self.indexes.get(&Ids::Inst(id)).cloned() }))
                .set_block_name_fn(Box::new(|id| {
                    self.indexes.get(&Ids::Block(id)).cloned()
                }))
        )?;

        for (kind, meta) in &inst.metadata {
            write!(self.fmt, ", !{} {}", kind, meta.display(types))?;
        }

        Ok(())
    }

    fn new_name_for_block(&mut self, id: BasicBlockId) -> Name {
        let idx = self.cur_index;
        self.cur_index += 1;
        self.indexes.insert(Ids::Block(id), Name::Number(idx));
        Name::Number(idx)
    }

    pub fn new_name_for_inst(&mut self, id: InstructionId) -> Name {
        let idx = self.cur_index;
        self.cur_index += 1;
        self.indexes.insert(Ids::Inst(id), Name::Number(idx));
        Name::Number(idx)
    }

    pub fn new_name_for_arg(&mut self, arg: usize) -> Name {
        let idx = self.cur_index;
        self.cur_index += 1;
        self.indexes.insert(Ids::Arg(arg), Name::Number(idx));
        Name::Number(idx)
    }
}
