//! Data flow graph.

use crate::ir::builder::{BlockBuilder, LocalBuilder, ReplaceBuilder};
use crate::ir::program::{BasicBlock, BasicBlockData, Value, ValueData};
use crate::ir::program::{FuncTypeMapCell, GlobalValueMapCell};
use crate::ir::selector::{next_bb_id, next_local_value_id};
use std::collections::HashMap;

/// Returns a reference to the value data by the given value handle.
macro_rules! data {
    ($self:ident, $value:expr) => {
        $self
            .globals
            .upgrade()
            .unwrap()
            .borrow()
            .get(&$value)
            .or_else(|| $self.values.get(&$value))
            .expect("value does not exist")
    };
}

/// Returns a mutable reference to the value data by the given value handle.
macro_rules! data_mut {
    ($self:ident, $value:expr) => {
        $self
            .globals
            .upgrade()
            .unwrap()
            .borrow_mut()
            .get_mut(&$value)
            .or_else(|| $self.values.get_mut(&$value))
            .expect("value does not exist")
    };
}

/// Data flow graph of a function.
pub struct DataFlowGraph {
    pub(in crate::ir) globals: GlobalValueMapCell,
    pub(in crate::ir) func_tys: FuncTypeMapCell,
    values: HashMap<Value, ValueData>,
    bbs: HashMap<BasicBlock, BasicBlockData>,
}

impl DataFlowGraph {
    /// Creates a new data flow graph.
    pub(in crate::ir) fn new() -> Self {
        Self {
            globals: GlobalValueMapCell::new(),
            func_tys: FuncTypeMapCell::new(),
            values: HashMap::new(),
            bbs: HashMap::new(),
        }
    }

    /// Creates a new value in the current data flow graph.
    /// Returns a [`LocalBuilder`] for building the new local value.
    pub fn new_value(&mut self) -> LocalBuilder {
        LocalBuilder { dfg: self }
    }

    /// Creates a new local value by its value data. Returns the handle of
    /// the created value. This method will be called by [`LocalBuilder`].
    pub(in crate::ir) fn new_value_data(&mut self, data: ValueData) -> Value {
        let value = Value(next_local_value_id());
        for v in data.kind().value_uses() {
            data_mut!(self, v).used_by.insert(value);
        }
        for bb in data.kind().bb_uses() {
            self.bb_mut(bb).used_by.insert(value);
        }
        self.values.insert(value, data);
        value
    }

    /// Replaces the given value with a new value.
    pub fn replace_value_with(&mut self, value: Value) -> ReplaceBuilder {
        ReplaceBuilder { dfg: self, value }
    }

    /// Replaces the given value with a new value data.
    pub(in crate::ir) fn replace_value_with_data(&mut self, value: Value, data: ValueData) {
        let old = self.values.remove(&value).unwrap();
        for v in old.kind().value_uses() {
            data_mut!(self, v).used_by.remove(&value);
        }
        for bb in old.kind().bb_uses() {
            self.bb_mut(bb).used_by.remove(&value);
        }
        for v in data.kind().value_uses() {
            data_mut!(self, v).used_by.insert(value);
        }
        for bb in data.kind().bb_uses() {
            self.bb_mut(bb).used_by.insert(value);
        }
        self.values.insert(value, data);
    }

    /// Removes the given value. Returns the corresponding value data.
    pub fn remove_value(&mut self, value: Value) -> ValueData {
        let data = self.values.remove(&value).expect("`value` does not exist");
        assert!(data.used_by.is_empty(), "`value` is used by other values");
        for v in data.kind().value_uses() {
            data_mut!(self, v).used_by.remove(&value);
        }
        for bb in data.kind().bb_uses() {
            self.bb_mut(bb).used_by.remove(&value);
        }
        data
    }

    /// Sets the name of the given value.
    pub fn set_value_name(&mut self, value: Value, name: Option<String>) {
        self.values
            .get_mut(&value)
            .expect("`value` does not exist")
            .set_name(name);
    }

    /// Returns a reference to the given local value.
    pub fn value(&self, value: Value) -> &ValueData {
        self.values.get(&value).expect("`value` does not exist")
    }

    /// Returns a reference to the value map.
    pub fn values(&self) -> &HashMap<Value, ValueData> {
        &self.values
    }

    /// Checks if the two given values are equal.
    pub fn value_eq(&self, lhs: Value, rhs: Value) -> bool {
        self.data_eq(data!(self, lhs), data!(self, rhs))
    }

    /// Checks if the two given value data are equal.
    pub fn data_eq(&self, lhs: &ValueData, rhs: &ValueData) -> bool {
        use crate::ir::program::ValueKind::*;
        macro_rules! return_if {
            ($e:expr) => {
                if $e {
                    return false;
                }
            };
        }
        return_if!(lhs.ty() != rhs.ty());
        match (lhs.kind(), rhs.kind()) {
            (Uint32(l), Uint32(r)) => return_if!(l.value() != r.value()),
            (Uint64(l), Uint64(r)) => return_if!(l.value() != r.value()),
            (Uint256(l), Uint256(r)) => return_if!(l.value() != r.value()),
            (Field(l), Field(r)) => return_if!(l.value() != r.value()),
            (Undef(_), Undef(_)) => return true,
            (Aggregate(l), Aggregate(r)) => return_if!(l.elems().len() != r.elems().len()),
            (FuncArgRef(l), FuncArgRef(r)) => return_if!(l.index() != r.index()),
            (BlockArgRef(l), BlockArgRef(r)) => return_if!(l.index() != r.index()),
            (Alloc(_), Alloc(_)) => return true,
            (GlobalAlloc(_), GlobalAlloc(_)) => (),
            (Load(_), Load(_)) => (),
            (Store(_), Store(_)) => (),
            (GetPtr(_), GetPtr(_)) => (),
            (GetElemPtr(_), GetElemPtr(_)) => (),
            (Binary(l), Binary(r)) => return_if!(l.op() != r.op()),
            (Branch(l), Branch(r)) => {
                return_if!(
                    l.true_bb() != r.true_bb()
                        || l.false_bb() != r.false_bb()
                        || l.true_args().len() != r.true_args().len()
                        || l.false_args().len() != r.false_args().len()
                )
            }
            (Jump(l), Jump(r)) => {
                return_if!(l.target() != r.target() || l.args().len() != r.args().len())
            }
            (Call(l), Call(r)) => {
                return_if!(l.callee() != r.callee() || l.args().len() != r.args().len())
            }
            (Return(l), Return(r)) => return_if!(l.value().xor(r.value()).is_some()),
            _ => return false,
        }
        for (lu, ru) in lhs.kind().value_uses().zip(rhs.kind().value_uses()) {
            return_if!(!self.value_eq(lu, ru));
        }
        true
    }

    /// Creates a new basic block in the current data flow graph.
    pub fn new_bb(&mut self) -> BlockBuilder {
        BlockBuilder { dfg: self }
    }

    /// Creates a new basic block in the current data flow graph.
    /// Returns the handle of the created basic block.
    pub(in crate::ir) fn new_bb_data(&mut self, data: BasicBlockData) -> BasicBlock {
        let bb = BasicBlock(next_bb_id());
        self.bbs.insert(bb, data);
        bb
    }

    /// Removes the given basic block, also removes all basic block
    /// parameters. Returns the corresponding basic block data.
    pub fn remove_bb(&mut self, bb: BasicBlock) -> BasicBlockData {
        let data = self.bbs.remove(&bb).expect("`bb` does not exist");
        assert!(data.used_by.is_empty(), "`bb` is used by other values");
        for p in data.params() {
            let param = self
                .values
                .remove(p)
                .expect("basic block parameter does not exist");
            assert!(
                param.used_by.is_empty(),
                "basic block parameter is used by other values"
            );
        }
        data
    }

    /// Returns a reference to the given basic block.
    pub fn bb(&self, bb: BasicBlock) -> &BasicBlockData {
        self.bbs.get(&bb).expect("`bb` does not exist")
    }

    /// Returns a mutable reference to the given basic block.
    pub fn bb_mut(&mut self, bb: BasicBlock) -> &mut BasicBlockData {
        self.bbs.get_mut(&bb).expect("`bb` does not exist")
    }

    /// Returns a reference to the basic block map.
    pub fn bbs(&self) -> &HashMap<BasicBlock, BasicBlockData> {
        &self.bbs
    }

    /// Returns a mutable reference to the basic block map.
    pub fn bbs_mut(&mut self) -> &mut HashMap<BasicBlock, BasicBlockData> {
        &mut self.bbs
    }
}
