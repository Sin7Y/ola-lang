// SPDX-License-Identifier: Apache-2.0

use super::symtable::Symtable;
use crate::diagnostics::Diagnostics;
use crate::sema::Recurse;
use indexmap::IndexMap;
use num_bigint::BigInt;
pub use ola_parser::diagnostics::*;
use ola_parser::program;
use ola_parser::program::{CodeLocation, OptionalCodeLocation};
use std::hash;
use std::sync::Arc;
use std::{
    collections::{BTreeMap, HashMap},
    fmt,
    path::PathBuf,
};
use tiny_keccak::{Hasher, Keccak};

#[derive(PartialEq, Eq, Clone, Hash, Debug)]
pub enum Type {
    Bool,
    Uint(u16),
    Address,
    Hash,
    Field,
    DynamicBytes,
    String,
    Array(Box<Type>, Vec<ArrayLength>),
    /// The usize is an index into enums in the namespace
    Enum(usize),
    /// The usize is an index into contracts in the namespace
    Struct(usize),
    Mapping(Mapping),
    /// The usize is an index into contracts in the namespace
    Contract(usize),
    Ref(Box<Type>),
    /// Reference to storage
    StorageRef(Box<Type>),

    Function {
        params: Vec<Type>,
        returns: Vec<Type>,
    },

    /// User type definitions, e.g. `type Foo is int128;`. The usize
    /// is an index into user_types in the namespace.
    UserType(usize),
    Void,
    Unreachable,
    /// DynamicBytes and String are lowered to a vector.
    Slice(Box<Type>),
    /// We could not resolve this type
    Unresolved,
    /// When we advance a pointer, it cannot be any of the previous types.
    /// e.g. Type::Bytes is a pointer to struct.vector. When we advance it, it
    /// is a pointer to latter's data region.
    BufferPointer,
}

#[derive(Eq, Clone, Debug)]
pub struct Mapping {
    pub key: Box<Type>,
    pub key_name: Option<program::Identifier>,
    pub value: Box<Type>,
    pub value_name: Option<program::Identifier>,
}

// Ensure the key_name and value_name is not used for comparison or hashing
impl PartialEq for Mapping {
    fn eq(&self, other: &Mapping) -> bool {
        self.key == other.key && self.value == other.value
    }
}

impl hash::Hash for Mapping {
    fn hash<H: hash::Hasher>(&self, hasher: &mut H) {
        self.key.hash(hasher);
        self.value.hash(hasher);
    }
}

#[derive(PartialEq, Eq, Clone, Hash, Debug)]
pub enum ArrayLength {
    Fixed(BigInt),
    Dynamic,
    /// Fixed length arrays, any length permitted. This is useful for when we
    /// do not want dynamic length, but want to permit any length. For example
    /// the create_program_address() call takes any number of seeds as its
    /// first argument, and we don't want to allocate a dynamic array for
    /// this parameter as this would be wasteful to allocate a vector for
    /// this argument.
    AnyFixed,
}

impl ArrayLength {
    /// Get the length, if fixed
    pub fn array_length(&self) -> Option<&BigInt> {
        match self {
            ArrayLength::Fixed(len) => Some(len),
            _ => None,
        }
    }
}

pub trait RetrieveType {
    /// Return the type for this expression. This assumes the expression has a
    /// single value, panics will occur otherwise
    fn ty(&self) -> Type;
}

impl Type {
    pub fn get_type_size(&self) -> u16 {
        match self {
            Type::Uint(n) => *n,
            Type::Bool => 1,
            _ => unimplemented!("size of type not known"),
        }
    }

    pub fn unwrap_user_type(self, ns: &Namespace) -> Type {
        if let Type::UserType(type_no) = self {
            ns.user_types[type_no].ty.clone()
        } else {
            self
        }
    }
}

pub struct EnumDecl {
    pub name: String,
    pub contract: Option<String>,
    pub loc: program::Loc,
    pub ty: Type,
    pub values: IndexMap<String, program::Loc>,
}

impl fmt::Display for EnumDecl {
    /// Make the enum name into a string for printing. The enum can be declared
    /// either inside or outside a contract.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &self.contract {
            Some(c) => write!(f, "{}.{}", c, self.name),
            None => write!(f, "{}", self.name),
        }
    }
}

#[derive(PartialEq, Eq, Clone, Debug)]
pub struct StructDecl {
    pub name: String,
    pub loc: program::Loc,
    pub contract: Option<String>,
    pub fields: Vec<Parameter>,
    // List of offsets of the fields, last entry is the offset for the struct overall size
    pub offsets: Vec<BigInt>,
    // Same, but now in storage
    pub storage_offsets: Vec<BigInt>,
}

impl fmt::Display for StructDecl {
    /// Make the struct name into a string for printing. The struct can be
    /// declared either inside or outside a contract.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &self.contract {
            Some(c) => write!(f, "{}.{}", c, self.name),
            None => write!(f, "{}", self.name),
        }
    }
}

#[derive(PartialEq, Eq, Clone, Debug)]
pub struct Parameter {
    pub loc: program::Loc,
    /// The name can empty (e.g. in an event field or unnamed parameter/return)
    pub id: Option<program::Identifier>,
    pub ty: Type,
    pub ty_loc: Option<program::Loc>,
    /// A recursive struct may contain itself which make the struct infinite
    /// size in memory.
    pub infinite_size: bool,
    /// A struct may contain itself which make the struct infinite size in
    /// memory. This boolean specifies which field introduces the recursion.
    pub recursive: bool,
}

impl Parameter {
    pub fn name_as_str(&self) -> &str {
        if let Some(name) = &self.id {
            name.name.as_str()
        } else {
            ""
        }
    }
}

pub struct Function {
    /// The location of the prototype (not body)
    pub loc: program::Loc,
    pub name: String,
    pub contract_no: Option<usize>,
    pub signature: String,
    pub params: Arc<Vec<Parameter>>,
    pub returns: Arc<Vec<Parameter>>,

    /// The selector (known as discriminator on Solana/Anchor)
    pub selector: Option<Vec<u8>>,
    /// Was the function declared with a body
    pub has_body: bool,
    /// The resolved body (if any)
    pub body: Vec<Statement>,
    pub symtable: Symtable,
    // For overloaded functions this is the mangled (unique) name.
    pub mangled_name: String,
}

/// This trait provides a single interface for fetching paramenters, returns and
/// the symbol table
pub trait FunctionAttributes {
    fn get_symbol_table(&self) -> &Symtable;
    fn get_parameters(&self) -> &Vec<Parameter>;
    fn get_returns(&self) -> &Vec<Parameter>;
}

impl FunctionAttributes for Function {
    fn get_symbol_table(&self) -> &Symtable {
        &self.symtable
    }

    fn get_parameters(&self) -> &Vec<Parameter> {
        &self.params
    }

    fn get_returns(&self) -> &Vec<Parameter> {
        &self.returns
    }
}

impl Function {
    pub fn new(
        loc: program::Loc,
        name: String,
        contract_no: Option<usize>,
        params: Vec<Parameter>,
        returns: Vec<Parameter>,
        ns: &Namespace,
    ) -> Self {
        let signature = ns.signature(&name, &params);

        let mangled_name = signature
            .replace('(', "_")
            .replace(')', "")
            .replace(',', "_")
            .replace("[]", "Array")
            .replace('[', "Array")
            .replace(']', "");

        Function {
            loc,
            name,
            contract_no,
            signature,
            params: Arc::new(params),
            returns: Arc::new(returns),
            selector: None,
            has_body: false,
            body: Vec::new(),
            symtable: Symtable::new(),
            mangled_name,
        }
    }

    /// Generate selector for this function
    pub fn selector(&self) -> Vec<u8> {
        if let Some(selector) = &self.selector {
            selector.clone()
        } else {
            let mut res = [0u8; 32];

            let mut hasher = Keccak::v256();
            hasher.update(self.signature.as_bytes());
            hasher.finalize(&mut res);

            res[..4].to_vec()
        }
    }

    /// Print the contract name, and name
    pub fn print_name(&self, ns: &Namespace) -> String {
        if let Some(contract_no) = &self.contract_no {
            format!("{}.{}", ns.contracts[*contract_no].name, self.name)
        } else {
            format!("{} ", self.name)
        }
    }
}

impl From<&program::Type> for Type {
    fn from(p: &program::Type) -> Type {
        match p {
            program::Type::Bool => Type::Bool,
            program::Type::Address => Type::Address,
            program::Type::Uint(n) => Type::Uint(*n),
            program::Type::String => Type::String,
            program::Type::Mapping { .. } => unimplemented!(),
            program::Type::DynamicBytes => Type::DynamicBytes,
            program::Type::Field => Type::Field,
            program::Type::Hash => Type::Hash,
        }
    }
}

#[derive(PartialEq, Eq, Clone, Debug)]
pub struct UserTypeDecl {
    pub loc: program::Loc,
    pub name: String,
    pub ty: Type,
    pub contract: Option<String>,
}

impl fmt::Display for UserTypeDecl {
    /// Make the user type name into a string for printing. The user type can
    /// be declared either inside or outside a contract.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &self.contract {
            Some(c) => write!(f, "{}.{}", c, self.name),
            None => write!(f, "{}", self.name),
        }
    }
}

pub struct Variable {
    pub name: String,
    pub loc: program::Loc,
    pub ty: Type,
    pub constant: bool,
    pub initializer: Option<Expression>,
    pub assigned: bool,
    pub read: bool,
}

#[derive(Clone, PartialEq, Eq)]
pub enum Symbol {
    Enum(program::Loc, usize),
    Function(Vec<(program::Loc, usize)>),
    Variable(program::Loc, Option<usize>, usize),
    Struct(program::Loc, usize),
    Contract(program::Loc, usize),
    Import(program::Loc, usize),
    UserType(program::Loc, usize),
}

impl CodeLocation for Symbol {
    fn loc(&self) -> program::Loc {
        match self {
            Symbol::Enum(loc, _)
            | Symbol::Variable(loc, ..)
            | Symbol::Struct(loc, _)
            | Symbol::Contract(loc, _)
            | Symbol::Import(loc, _)
            | Symbol::UserType(loc, _) => *loc,
            Symbol::Function(items) => items[0].0,
        }
    }
}

#[derive(Clone, Debug)]
pub struct File {
    /// The on-disk filename
    pub path: PathBuf,
    /// Used for offset to line-column conversions
    pub line_starts: Vec<usize>,
    /// Indicates the file number in FileResolver.files
    pub cache_no: Option<usize>,
}

/// When resolving a ola file, this holds all the resolved items

pub struct Namespace {
    pub files: Vec<File>,
    pub enums: Vec<EnumDecl>,
    pub structs: Vec<StructDecl>,
    pub contracts: Vec<Contract>,
    /// All type declarations
    pub user_types: Vec<UserTypeDecl>,
    /// All functions
    pub functions: Vec<Function>,

    /// Global constants
    pub constants: Vec<Variable>,

    pub diagnostics: Diagnostics,
    /// There is a separate namespace for functions and non-functions
    pub function_symbols: HashMap<(usize, Option<usize>, String), Symbol>,
    /// Symbol key is file_no, contract, identifier
    pub variable_symbols: HashMap<(usize, Option<usize>, String), Symbol>,
    // each variable in the symbol table should have a unique number
    pub next_id: usize,

    pub called_lib_functions: Vec<String>,
}

pub struct Layout {
    pub slot: BigInt,
    pub contract_no: usize,
    pub var_no: usize,
    pub ty: Type,
}

pub struct Contract {
    pub loc: program::Loc,
    pub name: String,
    pub layout: Vec<Layout>,
    pub fixed_layout_size: BigInt,
    pub functions: Vec<usize>,
    pub all_functions: BTreeMap<usize, usize>,
    pub variables: Vec<Variable>,

    pub initializer: Option<usize>,
    pub code: Vec<u8>,
    /// CFG number of this contract's dispatch function
    pub dispatch_no: usize,
}

#[derive(PartialEq, Eq, Clone, Debug)]
pub enum Expression {
    BoolLiteral {
        loc: program::Loc,
        value: bool,
    },
    BytesLiteral {
        loc: program::Loc,
        ty: Type,
        value: Vec<u8>,
    },
    NumberLiteral {
        loc: program::Loc,
        ty: Type,
        value: BigInt,
    },
    StructLiteral {
        loc: program::Loc,
        ty: Type,
        values: Vec<Expression>,
    },

    // The address type is composed of 4 Filed elements in the underlying storage,
    // totaling 256 bits.
    AddressLiteral {
        loc: program::Loc,
        ty: Type,
        value: Vec<BigInt>,
    },

    ArrayLiteral {
        loc: program::Loc,
        ty: Type,
        dimensions: Vec<u32>,
        values: Vec<Expression>,
    },
    ConstArrayLiteral {
        loc: program::Loc,
        ty: Type,
        dimensions: Vec<u32>,
        values: Vec<Expression>,
    },
    Add {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Subtract {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Multiply {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Divide {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Modulo {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Power {
        loc: program::Loc,
        ty: Type,
        base: Box<Expression>,
        exp: Box<Expression>,
    },
    BitwiseOr {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    BitwiseAnd {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    BitwiseXor {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    ShiftLeft {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    ShiftRight {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Variable {
        loc: program::Loc,
        ty: Type,
        var_no: usize,
    },
    ConstantVariable {
        loc: program::Loc,
        ty: Type,
        contract_no: Option<usize>,
        var_no: usize,
    },
    StorageVariable {
        loc: program::Loc,
        ty: Type,
        contract_no: usize,
        var_no: usize,
    },
    Load {
        loc: program::Loc,
        ty: Type,
        expr: Box<Expression>,
    },
    GetRef {
        loc: program::Loc,
        ty: Type,
        expr: Box<Expression>,
    },
    StorageLoad {
        loc: program::Loc,
        ty: Type,
        expr: Box<Expression>,
    },
    ZeroExt {
        loc: program::Loc,
        to: Type,
        expr: Box<Expression>,
    },
    Trunc {
        loc: program::Loc,
        to: Type,
        expr: Box<Expression>,
    },
    Cast {
        loc: program::Loc,
        to: Type,
        expr: Box<Expression>,
    },
    Increment {
        loc: program::Loc,
        ty: Type,
        expr: Box<Expression>,
    },
    Decrement {
        loc: program::Loc,
        ty: Type,
        expr: Box<Expression>,
    },
    Assign {
        loc: program::Loc,
        ty: Type,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    More {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Less {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    MoreEqual {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    LessEqual {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Equal {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    NotEqual {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Not {
        loc: program::Loc,
        expr: Box<Expression>,
    },
    BitwiseNot {
        loc: program::Loc,
        ty: Type,
        expr: Box<Expression>,
    },
    ConditionalOperator {
        loc: program::Loc,
        ty: Type,
        cond: Box<Expression>,
        true_option: Box<Expression>,
        false_option: Box<Expression>,
    },
    Subscript {
        loc: program::Loc,
        ty: Type,
        array_ty: Type,
        array: Box<Expression>,
        index: Box<Expression>,
    },

    StructMember {
        loc: program::Loc,
        ty: Type,
        expr: Box<Expression>,
        field: usize,
    },

    AllocDynamicBytes {
        loc: program::Loc,
        ty: Type,
        length: Box<Expression>,
        init: Option<Vec<u32>>,
    },

    StorageArrayLength {
        loc: program::Loc,
        ty: Type,
        array: Box<Expression>,
        elem_ty: Type,
    },
    StringCompare {
        loc: program::Loc,
        left: StringLocation<Expression>,
        right: StringLocation<Expression>,
    },
    StringConcat {
        loc: program::Loc,
        ty: Type,
        left: StringLocation<Expression>,
        right: StringLocation<Expression>,
    },

    Or {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },

    And {
        loc: program::Loc,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    Function {
        loc: program::Loc,
        ty: Type,
        function_no: usize,
        signature: Option<String>,
    },

    FunctionCall {
        loc: program::Loc,
        returns: Vec<Type>,
        function: Box<Expression>,
        args: Vec<Expression>,
    },

    ExternalFunctionCallRaw {
        loc: program::Loc,
        ty: CallTy,
        address: Box<Expression>,
        args: Box<Expression>,
        call_args: CallArgs,
    },

    LibFunction {
        loc: program::Loc,
        tys: Vec<Type>,
        kind: LibFunc,
        args: Vec<Expression>,
    },
    List {
        loc: program::Loc,
        list: Vec<Expression>,
    },
}


#[derive(PartialEq, Eq, Clone, Default, Debug)]
pub struct CallArgs {
    pub gas: Option<Box<Expression>>,
    pub value: Option<Box<Expression>>,
    pub address: Option<Box<Expression>>,
}

impl Recurse for CallArgs {
    type ArgType = Expression;
    fn recurse<T>(&self, cx: &mut T, f: fn(expr: &Expression, ctx: &mut T) -> bool) {
        if let Some(gas) = &self.gas {
            gas.recurse(cx, f);
        }
        if let Some(value) = &self.value {
            value.recurse(cx, f);
        }

    }
}

impl Recurse for Expression {
    type ArgType = Expression;
    fn recurse<T>(&self, cx: &mut T, f: fn(expr: &Expression, ctx: &mut T) -> bool) {
        if f(self, cx) {
            match self {
                Expression::StructLiteral { values, .. }
                | Expression::ArrayLiteral { values, .. }
                | Expression::ConstArrayLiteral { values, .. } => {
                    for e in values {
                        e.recurse(cx, f);
                    }
                }
                Expression::Load { expr, .. }
                | Expression::StorageLoad { expr, .. }
                | Expression::ZeroExt { expr, .. }
                | Expression::Trunc { expr, .. }
                | Expression::Cast { expr, .. }
                | Expression::Increment { expr, .. }
                | Expression::Decrement { expr, .. }
                | Expression::StructMember { expr, .. }
                | Expression::Not { expr, .. }
                | Expression::BitwiseNot { expr, .. } => expr.recurse(cx, f),

                Expression::Add { left, right, .. }
                | Expression::Subtract { left, right, .. }
                | Expression::Multiply { left, right, .. }
                | Expression::Divide { left, right, .. }
                | Expression::Modulo { left, right, .. }
                | Expression::Power {
                    base: left,
                    exp: right,
                    ..
                }
                | Expression::BitwiseOr { left, right, .. }
                | Expression::BitwiseAnd { left, right, .. }
                | Expression::BitwiseXor { left, right, .. }
                | Expression::ShiftLeft { left, right, .. }
                | Expression::ShiftRight { left, right, .. }
                | Expression::Assign { left, right, .. }
                | Expression::More { left, right, .. }
                | Expression::Less { left, right, .. }
                | Expression::MoreEqual { left, right, .. }
                | Expression::LessEqual { left, right, .. }
                | Expression::Equal { left, right, .. }
                | Expression::NotEqual { left, right, .. }
                | Expression::Or { left, right, .. }
                | Expression::And { left, right, .. } => {
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::ConditionalOperator {
                    cond,
                    true_option: left,
                    false_option: right,
                    ..
                } => {
                    cond.recurse(cx, f);
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::Subscript {
                    array: left,
                    index: right,
                    ..
                } => {
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::AllocDynamicBytes { length, .. } => length.recurse(cx, f),
                Expression::StorageArrayLength { array, .. } => array.recurse(cx, f),
                Expression::StringCompare { left, right, .. }
                | Expression::StringConcat { left, right, .. } => {
                    if let StringLocation::RunTime(expr) = left {
                        expr.recurse(cx, f);
                    }
                    if let StringLocation::RunTime(expr) = right {
                        expr.recurse(cx, f);
                    }
                }

                Expression::FunctionCall { function, args, .. } => {
                    function.recurse(cx, f);

                    for e in args {
                        e.recurse(cx, f);
                    }
                }
                Expression::ExternalFunctionCallRaw {
                    address,
                    args,
                    call_args,
                    ..
                } => {
                    args.recurse(cx, f);
                    address.recurse(cx, f);
                    call_args.recurse(cx, f);
                }
                Expression::LibFunction { args: exprs, .. }
                | Expression::List { list: exprs, .. } => {
                    for e in exprs {
                        e.recurse(cx, f);
                    }
                }
                _ => (),
            }
        }
    }
}

impl CodeLocation for Expression {
    fn loc(&self) -> program::Loc {
        match self {
            Expression::BoolLiteral { loc, .. }
            | Expression::BytesLiteral { loc, .. }
            | Expression::NumberLiteral { loc, .. }
            | Expression::AddressLiteral { loc, .. }
            | Expression::StructLiteral { loc, .. }
            | Expression::ArrayLiteral { loc, .. }
            | Expression::ConstArrayLiteral { loc, .. }
            | Expression::Add { loc, .. }
            | Expression::Subtract { loc, .. }
            | Expression::Multiply { loc, .. }
            | Expression::Divide { loc, .. }
            | Expression::Modulo { loc, .. }
            | Expression::Power { loc, .. }
            | Expression::BitwiseOr { loc, .. }
            | Expression::BitwiseAnd { loc, .. }
            | Expression::BitwiseXor { loc, .. }
            | Expression::ShiftLeft { loc, .. }
            | Expression::ShiftRight { loc, .. }
            | Expression::Variable { loc, .. }
            | Expression::ConstantVariable { loc, .. }
            | Expression::StorageVariable { loc, .. }
            | Expression::Load { loc, .. }
            | Expression::GetRef { loc, .. }
            | Expression::StorageLoad { loc, .. }
            | Expression::ZeroExt { loc, .. }
            | Expression::Trunc { loc, .. }
            | Expression::Cast { loc, .. }
            | Expression::More { loc, .. }
            | Expression::Less { loc, .. }
            | Expression::MoreEqual { loc, .. }
            | Expression::LessEqual { loc, .. }
            | Expression::Equal { loc, .. }
            | Expression::NotEqual { loc, .. }
            | Expression::Not { loc, .. }
            | Expression::BitwiseNot { loc, .. }
            | Expression::ConditionalOperator { loc, .. }
            | Expression::Subscript { loc, .. }
            | Expression::StructMember { loc, .. }
            | Expression::Or { loc, .. }
            | Expression::AllocDynamicBytes { loc, .. }
            | Expression::StorageArrayLength { loc, .. }
            | Expression::StringCompare { loc, .. }
            | Expression::StringConcat { loc, .. }
            | Expression::Function { loc, .. }
            | Expression::FunctionCall { loc, .. }
            | Expression::ExternalFunctionCallRaw { loc, .. }
            | Expression::Increment { loc, .. }
            | Expression::Decrement { loc, .. }
            | Expression::LibFunction { loc, .. }
            | Expression::Assign { loc, .. }
            | Expression::List { loc, .. }
            | Expression::And { loc, .. } => *loc,
        }
    }
}

impl CodeLocation for Statement {
    fn loc(&self) -> program::Loc {
        match self {
            Statement::Block { loc, .. }
            | Statement::VariableDecl(loc, ..)
            | Statement::If(loc, ..)
            | Statement::For { loc, .. }
            | Statement::While(loc, ..)
            | Statement::DoWhile(loc, ..)
            | Statement::Destructure(loc, ..)
            | Statement::Delete(loc, ..)
            | Statement::Expression(loc, ..)
            | Statement::Continue(loc, ..)
            | Statement::Break(loc, ..)
            | Statement::Return(loc, ..) => *loc,
        }
    }
}

#[derive(PartialEq, Eq, Clone, Debug)]
pub enum StringLocation<T> {
    CompileTime(Vec<u8>),
    RunTime(Box<T>),
}

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
pub enum LibFunc {
    U32Sqrt,
    ArrayPush,
    ArrayPop,
    ArrayLength,
    ArraySort,
    Assert,
    CallerAddress,
    OriginAddress,
    CodeAddress,
    AbiDecode,
    AbiEncode,
    AbiEncodeWithSignature,
    PoseidonHash,
    ChainId,
    FieldsConcat,


}

#[derive(PartialEq, Eq, Clone, Debug)]
pub enum CallTy {
    Regular,
    Delegate,
    Static,
}

impl fmt::Display for CallTy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CallTy::Regular => write!(f, "regular"),
            CallTy::Static => write!(f, "static"),
            CallTy::Delegate => write!(f, "delegate"),
        }
    }
}

#[derive(Clone, Debug)]
#[allow(clippy::large_enum_variant)]
pub enum Statement {
    Block {
        loc: program::Loc,
        statements: Vec<Statement>,
    },
    VariableDecl(program::Loc, usize, Parameter, Option<Arc<Expression>>),
    If(
        program::Loc,
        bool,
        Expression,
        Vec<Statement>,
        Vec<Statement>,
    ),
    While(program::Loc, bool, Expression, Vec<Statement>),
    For {
        loc: program::Loc,
        reachable: bool,
        init: Vec<Statement>,
        cond: Option<Expression>,
        next: Option<Expression>,
        body: Vec<Statement>,
    },
    DoWhile(program::Loc, bool, Vec<Statement>, Expression),
    Delete(program::Loc, Type, Expression),
    Destructure(program::Loc, Vec<DestructureField>, Expression),
    Expression(program::Loc, bool, Expression),
    Continue(program::Loc),
    Break(program::Loc),
    Return(program::Loc, Option<Expression>),
}

#[derive(Clone, Debug)]
#[allow(clippy::large_enum_variant)]
pub enum DestructureField {
    None,
    Expression(Expression),
    VariableDecl(usize, Parameter),
}

impl OptionalCodeLocation for DestructureField {
    fn loc_opt(&self) -> Option<program::Loc> {
        match self {
            DestructureField::None => None,
            DestructureField::Expression(e) => Some(e.loc()),
            DestructureField::VariableDecl(_, p) => Some(p.loc),
        }
    }
}

impl Recurse for Statement {
    type ArgType = Statement;
    fn recurse<T>(&self, cx: &mut T, f: fn(stmt: &Statement, ctx: &mut T) -> bool) {
        if f(self, cx) {
            match self {
                Statement::Block { statements, .. } => {
                    for stmt in statements {
                        stmt.recurse(cx, f);
                    }
                }
                Statement::If(_, _, _, then_stmt, else_stmt) => {
                    for stmt in then_stmt {
                        stmt.recurse(cx, f);
                    }

                    for stmt in else_stmt {
                        stmt.recurse(cx, f);
                    }
                }
                Statement::For { init, body, .. } => {
                    for stmt in init {
                        stmt.recurse(cx, f);
                    }

                    for stmt in body {
                        stmt.recurse(cx, f);
                    }
                }
                _ => (),
            }
        }
    }
}

impl Statement {
    pub fn reachable(&self) -> bool {
        match self {
            Statement::Block { statements, .. } => statements.iter().all(|s| s.reachable()),
            Statement::VariableDecl(..) | Statement::Delete(..) | Statement::Destructure(..) => {
                true
            }

            Statement::Continue(_) | Statement::Break(_) | Statement::Return(..) => false,

            Statement::If(_, reachable, ..)
            | Statement::While(_, reachable, ..)
            | Statement::DoWhile(_, reachable, ..)
            | Statement::Expression(_, reachable, _)
            | Statement::For { reachable, .. } => *reachable,
        }
    }
}
