//! Definitions of IR values, such as constants and instructions.

use crate::ir::program::{BasicBlock, Function, Value, ValueData, ValueKind};
use crate::ir::types::Type;
use std::fmt;

/// Uint32 constant.
#[derive(Clone, Debug)]
pub struct Uint32 {
    value: u32,
}

impl Uint32 {
    /// Set new uint32 value.
    pub(in crate::ir) fn new_data(value: u32) -> ValueData {
        ValueData::new(Type::get_u32(), ValueKind::Uint32(Self { value }))
    }

    /// Returns the uint32 value.
    pub fn value(&self) -> u32 {
        self.value
    }

    /// Returns a mutable reference to the uint32 value.
    pub fn value_mut(&mut self) -> &mut u32 {
        &mut self.value
    }
}

/// Uint64 constant.
#[derive(Clone, Debug)]
pub struct Uint64 {
    value: u64,
}

impl Uint64 {
    /// Set new uint64 value.
    pub(in crate::ir) fn new_data(value: u64) -> ValueData {
        ValueData::new(Type::get_u64(), ValueKind::Uint64(Self { value }))
    }

    /// Returns the uint64 value.
    pub fn value(&self) -> u64 {
        self.value
    }

    /// Returns a mutable reference to the uint64 value.
    pub fn value_mut(&mut self) -> &mut u64 {
        &mut self.value
    }
}

/// Uint256 constant.
#[derive(Clone, Debug)]
pub struct Uint256 {
    value_l: u128,
    value_h: u128,
}

impl Uint256 {
    /// Set new uint256 value.
    pub(in crate::ir) fn new_data(value_l: u128, value_h: u128) -> ValueData {
        ValueData::new(
            Type::get_u256(),
            ValueKind::Uint256(Self { value_l, value_h }),
        )
    }

    /// Returns the uint256 value.
    pub fn value(&self) -> (u128, u128) {
        (self.value_l, self.value_h)
    }

    /// Returns a mutable reference to the uint256 value.
    pub fn value_mut(&mut self) -> (&mut u128, &mut u128) {
        (&mut self.value_l, &mut self.value_h)
    }
}

/// field constant.
#[derive(Clone, Debug)]
pub struct Field {
    value: u64,
}

impl Field {
    /// Set new field value.
    pub(in crate::ir) fn new_data(value: u64) -> ValueData {
        ValueData::new(Type::get_field(), ValueKind::Field(Self { value }))
    }

    /// Returns the field value.
    pub fn value(&self) -> u64 {
        self.value
    }

    /// Returns a mutable reference to the field value.
    pub fn value_mut(&mut self) -> &mut u64 {
        &mut self.value
    }
}

/// Undefined value.
#[derive(Clone, Debug)]
pub struct Undef;

impl Undef {
    pub(in crate::ir) fn new_data(ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::Undef(Self))
    }
}

/// Aggregate constant.
#[derive(Clone, Debug)]
pub struct Aggregate {
    elems: Vec<Value>,
}

impl Aggregate {
    pub(in crate::ir) fn new_data(elems: Vec<Value>, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::Aggregate(Self { elems }))
    }

    /// Returns a reference to the aggregate elements.
    pub fn elems(&self) -> &[Value] {
        &self.elems
    }

    /// Returns a mutable reference to the aggregate elements.
    pub fn elems_mut(&mut self) -> &mut Vec<Value> {
        &mut self.elems
    }
}

/// Function argument reference.
#[derive(Clone, Debug)]
pub struct FuncArgRef {
    index: usize,
}

impl FuncArgRef {
    pub(in crate::ir) fn new_data(index: usize, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::FuncArgRef(Self { index }))
    }

    /// Returns the argument index.
    pub fn index(&self) -> usize {
        self.index
    }

    /// Returns a mutable reference to the argument index.
    pub fn index_mut(&mut self) -> &mut usize {
        &mut self.index
    }
}

/// Basic block argument reference.
#[derive(Clone, Debug)]
pub struct BlockArgRef {
    index: usize,
}

impl BlockArgRef {
    pub(in crate::ir) fn new_data(index: usize, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::BlockArgRef(Self { index }))
    }

    /// Returns the argument index.
    pub fn index(&self) -> usize {
        self.index
    }

    /// Returns a mutable reference to the argument index.
    pub fn index_mut(&mut self) -> &mut usize {
        &mut self.index
    }
}

/// Local memory allocation.
#[derive(Clone, Debug)]
pub struct Alloc;

impl Alloc {
    pub(in crate::ir) fn new_data(ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::Alloc(Self))
    }
}

/// Global memory allocation.
#[derive(Clone, Debug)]
pub struct GlobalAlloc {
    init: Value,
}

impl GlobalAlloc {
    pub(in crate::ir) fn new_data(init: Value, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::GlobalAlloc(Self { init }))
    }

    /// Returns the initializer.
    pub fn init(&self) -> Value {
        self.init
    }

    /// Returns a mutable reference to the initializer.
    pub fn init_mut(&mut self) -> &mut Value {
        &mut self.init
    }
}

/// Memory load.
#[derive(Clone, Debug)]
pub struct Load {
    src: Value,
}

impl Load {
    pub(in crate::ir) fn new_data(src: Value, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::Load(Self { src }))
    }

    /// Returns the source memory location.
    pub fn src(&self) -> Value {
        self.src
    }

    /// Returns a mutable reference to the source memory location.
    pub fn src_mut(&mut self) -> &mut Value {
        &mut self.src
    }
}

/// Memory store.
#[derive(Clone, Debug)]
pub struct Store {
    value: Value,
    dest: Value,
}

impl Store {
    pub(in crate::ir) fn new_data(value: Value, dest: Value) -> ValueData {
        ValueData::new(Type::get_unit(), ValueKind::Store(Self { value, dest }))
    }

    /// Returns the value of the memory store.
    pub fn value(&self) -> Value {
        self.value
    }

    /// Returns a mutable reference to the value of the memory store.
    pub fn value_mut(&mut self) -> &mut Value {
        &mut self.value
    }

    /// Returns the destination of the memory store.
    pub fn dest(&self) -> Value {
        self.dest
    }

    /// Returns a mutable reference to the destination of the memory store.
    pub fn dest_mut(&mut self) -> &mut Value {
        &mut self.dest
    }
}

/// Pointer calculation.
#[derive(Clone, Debug)]
pub struct GetPtr {
    src: Value,
    index: Value,
}

impl GetPtr {
    pub(in crate::ir) fn new_data(src: Value, index: Value, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::GetPtr(Self { src, index }))
    }

    /// Returns the source memory location.
    pub fn src(&self) -> Value {
        self.src
    }

    /// Returns a mutable reference to the source memory location.
    pub fn src_mut(&mut self) -> &mut Value {
        &mut self.src
    }

    /// Returns the index of pointer calculation.
    pub fn index(&self) -> Value {
        self.index
    }

    /// Returns a mutable reference to the index of pointer calculation.
    pub fn index_mut(&mut self) -> &mut Value {
        &mut self.index
    }
}

/// Element pointer calculation.
#[derive(Clone, Debug)]
pub struct GetElemPtr {
    src: Value,
    index: Value,
}

impl GetElemPtr {
    pub(in crate::ir) fn new_data(src: Value, index: Value, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::GetElemPtr(Self { src, index }))
    }

    /// Returns the source memory location.
    pub fn src(&self) -> Value {
        self.src
    }

    /// Returns a mutable reference to the source memory location.
    pub fn src_mut(&mut self) -> &mut Value {
        &mut self.src
    }

    /// Returns the index of element pointer calculation.
    pub fn index(&self) -> Value {
        self.index
    }

    /// Returns a mutable reference to the index of element pointer calculation.
    pub fn index_mut(&mut self) -> &mut Value {
        &mut self.index
    }
}

/// Unary operation.
#[derive(Clone, Debug)]
pub struct Unary {
    op: UnaryOp,
    val: Value,
}

impl Unary {
    pub(in crate::ir) fn new_data(op: UnaryOp, val: Value, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::Unary(Self { op, val }))
    }

    /// Returns the unary operator.
    pub fn op(&self) -> UnaryOp {
        self.op
    }

    /// Returns a mutable reference to the unary operator.
    pub fn op_mut(&mut self) -> &mut UnaryOp {
        &mut self.op
    }

    /// Returns the value.
    pub fn val(&self) -> Value {
        self.val
    }

    /// Returns a mutable reference to the value.
    pub fn val_mut(&mut self) -> &mut Value {
        &mut self.val
    }
}

/// Supported unary operators.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum UnaryOp {
    /// Not.
    Not,
    /// Complement.
    Comp,
}

impl fmt::Display for UnaryOp {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            UnaryOp::Not => f.write_str("not"),
            UnaryOp::Comp => f.write_str("comp"),
        }
    }
}

/// Binary operation.
#[derive(Clone, Debug)]
pub struct Binary {
    op: BinaryOp,
    lhs: Value,
    rhs: Value,
}

impl Binary {
    pub(in crate::ir) fn new_data(op: BinaryOp, lhs: Value, rhs: Value, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::Binary(Self { op, lhs, rhs }))
    }

    /// Returns the binary operator.
    pub fn op(&self) -> BinaryOp {
        self.op
    }

    /// Returns a mutable reference to the binary operator.
    pub fn op_mut(&mut self) -> &mut BinaryOp {
        &mut self.op
    }

    /// Returns the left-hand side use.
    pub fn lhs(&self) -> Value {
        self.lhs
    }

    /// Returns a mutable reference to the left-hand side use.
    pub fn lhs_mut(&mut self) -> &mut Value {
        &mut self.lhs
    }

    /// Returns the right-hand side use.
    pub fn rhs(&self) -> Value {
        self.rhs
    }

    /// Returns a mutable reference to the right-hand side use.
    pub fn rhs_mut(&mut self) -> &mut Value {
        &mut self.rhs
    }
}

/// Supported binary operators.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum BinaryOp {
    /// Not equal to.
    NotEq,
    /// Equal to.
    Eq,
    /// Greater than.
    Gt,
    /// Less than.
    Lt,
    /// Greater than or equal to.
    Ge,
    /// Less than or equal to.
    Le,
    /// Addition.
    Add,
    /// Subtraction.
    Sub,
    /// Multiplication.
    Mul,
    /// Division.
    Div,
    /// Modulo.
    Mod,
    /// Power.
    Pow,
    /// Bitwise AND.
    And,
    /// Bitwise OR.
    Or,
    /// Bitwise XOR.
    Xor,
    /// Shift left logical.
    Shl,
    /// Shift right logical.
    Shr,
}

impl fmt::Display for BinaryOp {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            BinaryOp::NotEq => f.write_str("ne"),
            BinaryOp::Eq => f.write_str("eq"),
            BinaryOp::Gt => f.write_str("gt"),
            BinaryOp::Lt => f.write_str("lt"),
            BinaryOp::Ge => f.write_str("ge"),
            BinaryOp::Le => f.write_str("le"),
            BinaryOp::Add => f.write_str("add"),
            BinaryOp::Sub => f.write_str("sub"),
            BinaryOp::Mul => f.write_str("mul"),
            BinaryOp::Div => f.write_str("div"),
            BinaryOp::Mod => f.write_str("mod"),
            BinaryOp::Pow => f.write_str("pow"),
            BinaryOp::And => f.write_str("and"),
            BinaryOp::Or => f.write_str("or"),
            BinaryOp::Xor => f.write_str("xor"),
            BinaryOp::Shl => f.write_str("shl"),
            BinaryOp::Shr => f.write_str("shr"),
        }
    }
}

/// Conditional branch.
#[derive(Clone, Debug)]
pub struct Branch {
    cond: Value,
    true_bb: BasicBlock,
    false_bb: BasicBlock,
    true_args: Vec<Value>,
    false_args: Vec<Value>,
}

impl Branch {
    pub(in crate::ir) fn new_data(
        cond: Value,
        true_bb: BasicBlock,
        false_bb: BasicBlock,
    ) -> ValueData {
        ValueData::new(
            Type::get_unit(),
            ValueKind::Branch(Self {
                cond,
                true_bb,
                false_bb,
                true_args: Vec::new(),
                false_args: Vec::new(),
            }),
        )
    }

    pub(in crate::ir) fn with_args(
        cond: Value,
        true_bb: BasicBlock,
        false_bb: BasicBlock,
        true_args: Vec<Value>,
        false_args: Vec<Value>,
    ) -> ValueData {
        ValueData::new(
            Type::get_unit(),
            ValueKind::Branch(Self {
                cond,
                true_bb,
                false_bb,
                true_args,
                false_args,
            }),
        )
    }

    /// Returns the branch condition.
    pub fn cond(&self) -> Value {
        self.cond
    }

    /// Returns a mutable reference to the branch condition.
    pub fn cond_mut(&mut self) -> &mut Value {
        &mut self.cond
    }

    /// Returns the true target basic block.
    pub fn true_bb(&self) -> BasicBlock {
        self.true_bb
    }

    /// Returns a mutable reference to the true target basic block.
    pub fn true_bb_mut(&mut self) -> &mut BasicBlock {
        &mut self.true_bb
    }

    /// Returns the false target basic block.
    pub fn false_bb(&self) -> BasicBlock {
        self.false_bb
    }

    /// Returns a mutable reference to the false target basic block.
    pub fn false_bb_mut(&mut self) -> &mut BasicBlock {
        &mut self.false_bb
    }

    /// Returns a reference to the arguments passed to
    /// the true target basic block.
    pub fn true_args(&self) -> &[Value] {
        &self.true_args
    }

    /// Returns a mutable reference to the arguments passed to
    /// the true target basic block.
    pub fn true_args_mut(&mut self) -> &mut Vec<Value> {
        &mut self.true_args
    }

    /// Returns a reference to the arguments passed to
    /// the false target basic block.
    pub fn false_args(&self) -> &[Value] {
        &self.false_args
    }

    /// Returns a mutable reference to the arguments passed to
    /// the false target basic block.
    pub fn false_args_mut(&mut self) -> &mut Vec<Value> {
        &mut self.false_args
    }
}

/// Unconditional jump.
#[derive(Clone, Debug)]
pub struct Jump {
    target: BasicBlock,
    args: Vec<Value>,
}

impl Jump {
    pub(in crate::ir) fn new_data(target: BasicBlock) -> ValueData {
        ValueData::new(
            Type::get_unit(),
            ValueKind::Jump(Self {
                target,
                args: Vec::new(),
            }),
        )
    }

    pub(in crate::ir) fn with_args(target: BasicBlock, args: Vec<Value>) -> ValueData {
        ValueData::new(Type::get_unit(), ValueKind::Jump(Self { target, args }))
    }

    /// Returns the target basic block.
    pub fn target(&self) -> BasicBlock {
        self.target
    }

    /// Returns a mutable reference to the target basic block.
    pub fn target_mut(&mut self) -> &mut BasicBlock {
        &mut self.target
    }

    /// Returns a reference to the arguments passed to the target basic block.
    pub fn args(&self) -> &[Value] {
        &self.args
    }

    /// Returns a mutable reference to the arguments passed to the target basic block.
    pub fn args_mut(&mut self) -> &mut Vec<Value> {
        &mut self.args
    }
}

/// Function call.
#[derive(Clone, Debug)]
pub struct Call {
    callee: Function,
    args: Vec<Value>,
}

impl Call {
    pub(in crate::ir) fn new_data(callee: Function, args: Vec<Value>, ty: Type) -> ValueData {
        ValueData::new(ty, ValueKind::Call(Self { callee, args }))
    }

    /// Returns the callee.
    pub fn callee(&self) -> Function {
        self.callee
    }

    /// Returns a mutable reference to the callee.
    pub fn callee_mut(&mut self) -> &mut Function {
        &mut self.callee
    }

    /// Returns a reference to the argument list.
    pub fn args(&self) -> &[Value] {
        &self.args
    }

    /// Returns a mutable reference to the argument list.
    pub fn args_mut(&mut self) -> &mut Vec<Value> {
        &mut self.args
    }
}

/// Function return.
#[derive(Clone, Debug)]
pub struct Return {
    value: Option<Value>,
}

impl Return {
    pub(in crate::ir) fn new_data(value: Option<Value>) -> ValueData {
        ValueData::new(Type::get_unit(), ValueKind::Return(Self { value }))
    }

    /// Returns the return value.
    pub fn value(&self) -> Option<Value> {
        self.value
    }

    /// Returns a mutable reference to the return value.
    pub fn value_mut(&mut self) -> &mut Option<Value> {
        &mut self.value
    }
}
