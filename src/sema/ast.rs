// SPDX-License-Identifier: Apache-2.0

use super::symtable::Symtable;
use crate::diagnostics::Diagnostics;
use crate::sema::Recurse;
use indexmap::IndexMap;
use num_bigint::BigInt;
pub use ola_parser::diagnostics::*;
use ola_parser::program;
use ola_parser::program::CodeLocation;
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
    Field,

    Array(Box<Type>, Vec<ArrayLength>),
    /// The usize is an index into enums in the namespace
    Enum(usize),
    /// The usize is an index into contracts in the namespace
    Struct(usize),
    /// The usize is an index into contracts in the namespace
    Contract(usize),
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
            Type::Field => 64,
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
    /// Yul function parameters may not have a type identifier
    pub ty_loc: Option<program::Loc>,

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
            program::Type::Field => Type::Field,
            program::Type::Uint(n) => Type::Uint(*n),
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
    /// address length in bytes
    pub address_length: usize,

    pub diagnostics: Diagnostics,
    /// There is a separate namespace for functions and non-functions
    pub function_symbols: HashMap<(usize, Option<usize>, String), Symbol>,
    /// Symbol key is file_no, contract, identifier
    pub variable_symbols: HashMap<(usize, Option<usize>, String), Symbol>,
    // each variable in the symbol table should have a unique number
    pub next_id: usize,

    pub called_lib_functions: Vec<String>,
}

pub struct Contract {
    pub loc: program::Loc,
    pub name: String,

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
    BoolLiteral(program::Loc, bool),
    NumberLiteral(program::Loc, Type, BigInt),
    StructLiteral(program::Loc, Type, Vec<Expression>),
    ArrayLiteral(program::Loc, Type, Vec<u32>, Vec<Expression>),
    ConstArrayLiteral(program::Loc, Type, Vec<u32>, Vec<Expression>),
    Add(program::Loc, Type, Box<Expression>, Box<Expression>),
    Subtract(program::Loc, Type, Box<Expression>, Box<Expression>),
    Multiply(program::Loc, Type, Box<Expression>, Box<Expression>),
    Divide(program::Loc, Type, Box<Expression>, Box<Expression>),
    Modulo(program::Loc, Type, Box<Expression>, Box<Expression>),
    Power(program::Loc, Type, Box<Expression>, Box<Expression>),
    BitwiseOr(program::Loc, Type, Box<Expression>, Box<Expression>),
    BitwiseAnd(program::Loc, Type, Box<Expression>, Box<Expression>),
    BitwiseXor(program::Loc, Type, Box<Expression>, Box<Expression>),
    ShiftLeft(program::Loc, Type, Box<Expression>, Box<Expression>),
    ShiftRight(program::Loc, Type, Box<Expression>, Box<Expression>),
    Variable(program::Loc, Type, usize),
    ConstantVariable(program::Loc, Type, Option<usize>, usize),
    StorageVariable(program::Loc, Type, usize, usize),
    StorageLoad(program::Loc, Type, Box<Expression>),
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
    Increment(program::Loc, Type, Box<Expression>),
    Decrement(program::Loc, Type, Box<Expression>),
    Assign(program::Loc, Type, Box<Expression>, Box<Expression>),

    More(program::Loc, Box<Expression>, Box<Expression>),
    Less(program::Loc, Box<Expression>, Box<Expression>),
    MoreEqual(program::Loc, Box<Expression>, Box<Expression>),
    LessEqual(program::Loc, Box<Expression>, Box<Expression>),
    Equal(program::Loc, Box<Expression>, Box<Expression>),
    NotEqual(program::Loc, Box<Expression>, Box<Expression>),

    Not(program::Loc, Box<Expression>),
    Complement(program::Loc, Type, Box<Expression>),
    UnaryMinus(program::Loc, Type, Box<Expression>),

    ConditionalOperator(
        program::Loc,
        Type,
        Box<Expression>,
        Box<Expression>,
        Box<Expression>,
    ),
    Subscript(program::Loc, Type, Type, Box<Expression>, Box<Expression>),
    StructMember(program::Loc, Type, Box<Expression>, usize),

    StorageArrayLength {
        loc: program::Loc,
        ty: Type,
        array: Box<Expression>,
        elem_ty: Type,
    },

    Or(program::Loc, Box<Expression>, Box<Expression>),
    And(program::Loc, Box<Expression>, Box<Expression>),
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

    LibFunction(program::Loc, Vec<Type>, LibFunc, Vec<Expression>),
    List(program::Loc, Vec<Expression>),
}

impl Recurse for Expression {
    type ArgType = Expression;
    fn recurse<T>(&self, cx: &mut T, f: fn(expr: &Expression, ctx: &mut T) -> bool) {
        if f(self, cx) {
            match self {
                Expression::StructLiteral(_, _, exprs)
                | Expression::ArrayLiteral(_, _, _, exprs)
                | Expression::ConstArrayLiteral(_, _, _, exprs) => {
                    for e in exprs {
                        e.recurse(cx, f);
                    }
                }
                Expression::Add(_, _, left, right)
                | Expression::Subtract(_, _, left, right)
                | Expression::Multiply(_, _, left, right)
                | Expression::Divide(_, _, left, right)
                | Expression::Modulo(_, _, left, right)
                | Expression::Power(_, _, left, right)
                | Expression::BitwiseOr(_, _, left, right)
                | Expression::BitwiseAnd(_, _, left, right)
                | Expression::BitwiseXor(_, _, left, right)
                | Expression::ShiftLeft(_, _, left, right)
                | Expression::ShiftRight(_, _, left, right) => {
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::StorageLoad(_, _, expr)
                | Expression::ZeroExt { expr, .. }
                | Expression::Trunc { expr, .. }
                | Expression::Cast { expr, .. }
                | Expression::Increment(_, _, expr)
                | Expression::Decrement(_, _, expr) => expr.recurse(cx, f),

                Expression::Assign(_, _, left, right)
                | Expression::More(_, left, right)
                | Expression::Less(_, left, right)
                | Expression::MoreEqual(_, left, right)
                | Expression::LessEqual(_, left, right)
                | Expression::Equal(_, left, right)
                | Expression::NotEqual(_, left, right) => {
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::Not(_, expr)
                | Expression::Complement(_, _, expr)
                | Expression::UnaryMinus(_, _, expr) => expr.recurse(cx, f),

                Expression::ConditionalOperator(_, _, cond, left, right) => {
                    cond.recurse(cx, f);
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::Subscript(_, _, _, left, right) => {
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::StructMember(_, _, expr, _) => expr.recurse(cx, f),
                Expression::StorageArrayLength { array, .. } => array.recurse(cx, f),
                Expression::Or(_, left, right) | Expression::And(_, left, right) => {
                    left.recurse(cx, f);
                    right.recurse(cx, f);
                }
                Expression::FunctionCall { function, args, .. } => {
                    function.recurse(cx, f);

                    for e in args {
                        e.recurse(cx, f);
                    }
                }
                Expression::LibFunction(_, _, _, exprs) | Expression::List(_, exprs) => {
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
            Expression::BoolLiteral(loc, _)
            | Expression::NumberLiteral(loc, ..)
            | Expression::StructLiteral(loc, ..)
            | Expression::ArrayLiteral(loc, ..)
            | Expression::ConstArrayLiteral(loc, ..)
            | Expression::Add(loc, ..)
            | Expression::Subtract(loc, ..)
            | Expression::Multiply(loc, ..)
            | Expression::Divide(loc, ..)
            | Expression::Modulo(loc, ..)
            | Expression::Power(loc, ..)
            | Expression::BitwiseOr(loc, ..)
            | Expression::BitwiseAnd(loc, ..)
            | Expression::BitwiseXor(loc, ..)
            | Expression::ShiftLeft(loc, ..)
            | Expression::ShiftRight(loc, ..)
            | Expression::Variable(loc, ..)
            | Expression::ConstantVariable(loc, ..)
            | Expression::StorageVariable(loc, ..)
            | Expression::StorageLoad(loc, ..)
            | Expression::ZeroExt { loc, .. }
            | Expression::Trunc { loc, .. }
            | Expression::Cast { loc, .. }
            | Expression::More(loc, ..)
            | Expression::Less(loc, ..)
            | Expression::MoreEqual(loc, ..)
            | Expression::LessEqual(loc, ..)
            | Expression::Equal(loc, ..)
            | Expression::NotEqual(loc, ..)
            | Expression::Not(loc, _)
            | Expression::Complement(loc, ..)
            | Expression::UnaryMinus(loc, ..)
            | Expression::ConditionalOperator(loc, ..)
            | Expression::Subscript(loc, ..)
            | Expression::StructMember(loc, ..)
            | Expression::Or(loc, ..)
            | Expression::StorageArrayLength { loc, .. }
            | Expression::Function { loc, .. }
            | Expression::FunctionCall { loc, .. }
            | Expression::Increment(loc, ..)
            | Expression::Decrement(loc, ..)
            | Expression::LibFunction(loc, ..)
            | Expression::Assign(loc, ..)
            | Expression::List(loc, _)
            | Expression::And(loc, ..) => *loc,
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
            | Statement::Expression(loc, ..)
            | Statement::Continue(loc, ..)
            | Statement::Break(loc, ..)
            | Statement::Return(loc, ..)
            | Statement::Underscore(loc, ..) => *loc,
        }
    }
}

#[derive(PartialEq, Eq, Clone, Copy, Debug)]
pub enum LibFunc {
    U32_SQRT,
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
    For {
        loc: program::Loc,
        reachable: bool,
        init: Vec<Statement>,
        cond: Option<Expression>,
        next: Vec<Statement>,
        body: Vec<Statement>,
    },
    Expression(program::Loc, bool, Expression),
    Continue(program::Loc),
    Break(program::Loc),
    Return(program::Loc, Option<Expression>),
    Underscore(program::Loc),
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
                Statement::For {
                    init, next, body, ..
                } => {
                    for stmt in init {
                        stmt.recurse(cx, f);
                    }

                    for stmt in body {
                        stmt.recurse(cx, f);
                    }

                    for stmt in next {
                        stmt.recurse(cx, f);
                    }
                }
                _ => (),
            }
        }
    }
}

impl Statement {
    /// Shorthand for checking underscore
    pub fn is_underscore(&self) -> bool {
        matches!(&self, Statement::Underscore(_))
    }

    pub fn reachable(&self) -> bool {
        match self {
            Statement::Block { statements, .. } => statements.iter().all(|s| s.reachable()),
            Statement::Underscore(_) | Statement::VariableDecl(..) => true,

            Statement::Continue(_) | Statement::Break(_) | Statement::Return(..) => false,

            Statement::If(_, reachable, ..)
            | Statement::Expression(_, reachable, _)
            | Statement::For { reachable, .. } => *reachable,
        }
    }
}
