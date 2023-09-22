// SPDX-License-Identifier: Apache-2.0

use std::fmt::{self, Display, Formatter, Result};

/// file no, start offset, end offset (in bytes)
#[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Clone, Copy)]

pub enum Loc {
    Builtin,
    CommandLine,
    Implicit,
    IRgen,
    File(usize, usize, usize),
}

/// Structs can implement this trait to easily return their loc
pub trait CodeLocation {
    fn loc(&self) -> Loc;
}

/// Structs should implement this trait to return an optional location
pub trait OptionalCodeLocation {
    fn loc_opt(&self) -> Option<Loc>;
}

impl Loc {
    #[must_use]
    pub fn begin_range(&self) -> Self {
        match self {
            Loc::File(file_no, start, _) => Loc::File(*file_no, *start, *start),
            loc => *loc,
        }
    }

    #[must_use]
    pub fn end_range(&self) -> Self {
        match self {
            Loc::File(file_no, _, end) => Loc::File(*file_no, *end, *end),
            loc => *loc,
        }
    }

    pub fn file_no(&self) -> usize {
        match self {
            Loc::File(file_no, _, _) => *file_no,
            _ => unreachable!(),
        }
    }

    /// Return the file_no if the location is in a file
    pub fn try_file_no(&self) -> Option<usize> {
        match self {
            Loc::File(file_no, _, _) => Some(*file_no),
            _ => None,
        }
    }

    pub fn start(&self) -> usize {
        match self {
            Loc::File(_, start, _) => *start,
            _ => unreachable!(),
        }
    }

    pub fn end(&self) -> usize {
        match self {
            Loc::File(_, _, end) => *end,
            _ => unreachable!(),
        }
    }

    pub fn use_end_from(&mut self, other: &Loc) {
        match (self, other) {
            (Loc::File(_, _, end), Loc::File(_, _, other_end)) => {
                *end = *other_end;
            }
            _ => unreachable!(),
        }
    }

    pub fn use_start_from(&mut self, other: &Loc) {
        match (self, other) {
            (Loc::File(_, start, _), Loc::File(_, other_start, _)) => {
                *start = *other_start;
            }
            _ => unreachable!(),
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]

pub struct Identifier {
    pub loc: Loc,
    pub name: String,
}

impl Display for Identifier {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.name)
    }
}

/// A qualified identifier.
///
/// `<identifiers>.*`
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct IdentifierPath {
    /// The code location.
    pub loc: Loc,
    /// The list of identifiers.
    pub identifiers: Vec<Identifier>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct SourceUnit(pub Vec<SourceUnitPart>);

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum SourceUnitPart {
    ContractDefinition(Box<ContractDefinition>),
    ImportDirective(Import),
}

impl SourceUnitPart {
    pub fn loc(&self) -> &Loc {
        match self {
            SourceUnitPart::ContractDefinition(def) => &def.loc,
            SourceUnitPart::ImportDirective(import) => import.loc(),
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum Import {
    Plain(StringLiteral, Loc),
    GlobalSymbol(StringLiteral, Identifier, Loc),
}

impl Import {
    pub fn loc(&self) -> &Loc {
        match self {
            Import::Plain(_, loc) => loc,
            Import::GlobalSymbol(_, _, loc) => loc,
        }
    }
}

pub type ParameterList = Vec<(Loc, Option<Parameter>)>;

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum Type {
    Bool,
    Uint(u16),
    Address,
    String,
    Field,
    Hash,
    /// `Fields`
    DynamicBytes,
    /// `mapping(<key> [key_name] => <value> [value_name])`
    Mapping {
        /// The code location.
        loc: Loc,
        /// The key expression.
        ///
        /// This is only allowed to be an elementary type or a user defined
        /// type.
        key: Box<Expression>,
        /// The optional key identifier.
        key_name: Option<Identifier>,
        /// The value expression.
        value: Box<Expression>,
        /// The optional value identifier.
        value_name: Option<Identifier>,
    },
}

/// Dynamic type location.
#[derive(Debug, PartialEq, Eq, Clone)]
pub enum StorageLocation {
    /// `memory`
    Memory(Loc),

    /// `storage`
    Storage(Loc),
}

impl Display for StorageLocation {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        f.write_str(self.as_str())
    }
}
impl StorageLocation {
    /// Returns the string representation of this type.
    pub const fn as_str(&self) -> &'static str {
        match self {
            Self::Memory(_) => "memory",
            Self::Storage(_) => "storage",
        }
    }
}

impl CodeLocation for StorageLocation {
    fn loc(&self) -> Loc {
        match self {
            Self::Memory(loc) => *loc,
            Self::Storage(loc) => *loc,
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct VariableDeclaration {
    pub loc: Loc,
    pub ty: Expression,
    /// The optional memory location.
    pub storage: Option<StorageLocation>,
    pub name: Option<Identifier>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
#[allow(clippy::vec_box)]
pub struct StructDefinition {
    pub loc: Loc,
    pub name: Option<Identifier>,
    pub fields: Vec<VariableDeclaration>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum ContractPart {
    StructDefinition(Box<StructDefinition>),
    EnumDefinition(Box<EnumDefinition>),
    VariableDefinition(Box<VariableDefinition>),
    FunctionDefinition(Box<FunctionDefinition>),
    TypeDefinition(Box<TypeDefinition>),
    StraySemicolon(Loc),
}

impl ContractPart {
    // Return the location of the part. Note that this excluded the body of the
    // function
    pub fn loc(&self) -> &Loc {
        match self {
            ContractPart::StructDefinition(def) => &def.loc,
            ContractPart::EnumDefinition(def) => &def.loc,
            ContractPart::VariableDefinition(def) => &def.loc,
            ContractPart::FunctionDefinition(def) => &def.loc,
            ContractPart::TypeDefinition(def) => &def.loc,
            ContractPart::StraySemicolon(loc) => loc,
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct ContractDefinition {
    pub loc: Loc,
    pub name: Option<Identifier>,
    pub parts: Vec<ContractPart>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct EnumDefinition {
    pub loc: Loc,
    pub name: Option<Identifier>,
    pub values: Vec<Option<Identifier>>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum VariableAttribute {
    Constant(Loc),
    Mutable(Loc),
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct VariableDefinition {
    pub loc: Loc,
    pub ty: Expression,
    pub attrs: Vec<VariableAttribute>,
    pub name: Option<Identifier>,
    pub initializer: Option<Expression>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct TypeDefinition {
    pub loc: Loc,
    pub name: Identifier,
    pub ty: Expression,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct StringLiteral {
    pub loc: Loc,
    pub string: String,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct NamedArgument {
    pub loc: Loc,
    pub name: Identifier,
    pub expr: Expression,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum Expression {
    Increment(Loc, Box<Expression>),
    Decrement(Loc, Box<Expression>),
    New(Loc, Box<Expression>),
    ArraySubscript(Loc, Box<Expression>, Option<Box<Expression>>),
    ArraySlice(
        Loc,
        Box<Expression>,
        Option<Box<Expression>>,
        Option<Box<Expression>>,
    ),
    Parenthesis(Loc, Box<Expression>),
    MemberAccess(Loc, Box<Expression>, Identifier),
    FunctionCall(Loc, Box<Expression>, Vec<Expression>),
    FunctionCallBlock(Loc, Box<Expression>, Box<Statement>),
    NamedFunctionCall(Loc, Box<Expression>, Vec<NamedArgument>),
    Not(Loc, Box<Expression>),
    BitwiseNot(Loc, Box<Expression>),
    Delete(Loc, Box<Expression>),
    Power(Loc, Box<Expression>, Box<Expression>),
    Multiply(Loc, Box<Expression>, Box<Expression>),
    Divide(Loc, Box<Expression>, Box<Expression>),
    Modulo(Loc, Box<Expression>, Box<Expression>),
    Add(Loc, Box<Expression>, Box<Expression>),
    Subtract(Loc, Box<Expression>, Box<Expression>),
    ShiftLeft(Loc, Box<Expression>, Box<Expression>),
    ShiftRight(Loc, Box<Expression>, Box<Expression>),
    BitwiseAnd(Loc, Box<Expression>, Box<Expression>),
    BitwiseXor(Loc, Box<Expression>, Box<Expression>),
    BitwiseOr(Loc, Box<Expression>, Box<Expression>),
    Less(Loc, Box<Expression>, Box<Expression>),
    More(Loc, Box<Expression>, Box<Expression>),
    LessEqual(Loc, Box<Expression>, Box<Expression>),
    MoreEqual(Loc, Box<Expression>, Box<Expression>),
    Equal(Loc, Box<Expression>, Box<Expression>),
    NotEqual(Loc, Box<Expression>, Box<Expression>),
    And(Loc, Box<Expression>, Box<Expression>),
    Or(Loc, Box<Expression>, Box<Expression>),
    ConditionalOperator(Loc, Box<Expression>, Box<Expression>, Box<Expression>),
    Assign(Loc, Box<Expression>, Box<Expression>),
    AssignOr(Loc, Box<Expression>, Box<Expression>),
    AssignAnd(Loc, Box<Expression>, Box<Expression>),
    AssignXor(Loc, Box<Expression>, Box<Expression>),
    AssignShiftLeft(Loc, Box<Expression>, Box<Expression>),
    AssignShiftRight(Loc, Box<Expression>, Box<Expression>),
    AssignAdd(Loc, Box<Expression>, Box<Expression>),
    AssignSubtract(Loc, Box<Expression>, Box<Expression>),
    AssignMultiply(Loc, Box<Expression>, Box<Expression>),
    AssignDivide(Loc, Box<Expression>, Box<Expression>),
    AssignModulo(Loc, Box<Expression>, Box<Expression>),
    BoolLiteral(Loc, bool),
    NumberLiteral(Loc, String),
    HexNumberLiteral(Loc, String),
    StringLiteral(Vec<StringLiteral>),
    AddressLiteral(Loc, String),
    Type(Loc, Type),
    Variable(Identifier),
    List(Loc, ParameterList),
    ArrayLiteral(Loc, Vec<Expression>),
}

impl CodeLocation for Expression {
    fn loc(&self) -> Loc {
        match self {
            Expression::Increment(loc, _)
            | Expression::Decrement(loc, _)
            | Expression::New(loc, _)
            | Expression::Delete(loc, _)
            | Expression::Parenthesis(loc, _)
            | Expression::ArraySubscript(loc, ..)
            | Expression::ArraySlice(loc, ..)
            | Expression::MemberAccess(loc, ..)
            | Expression::FunctionCall(loc, ..)
            | Expression::FunctionCallBlock(loc, ..)
            | Expression::NamedFunctionCall(loc, ..)
            | Expression::Not(loc, _)
            | Expression::BitwiseNot(loc, _)
            | Expression::Power(loc, ..)
            | Expression::Multiply(loc, ..)
            | Expression::Divide(loc, ..)
            | Expression::Modulo(loc, ..)
            | Expression::Add(loc, ..)
            | Expression::Subtract(loc, ..)
            | Expression::ShiftLeft(loc, ..)
            | Expression::ShiftRight(loc, ..)
            | Expression::BitwiseAnd(loc, ..)
            | Expression::BitwiseXor(loc, ..)
            | Expression::BitwiseOr(loc, ..)
            | Expression::Less(loc, ..)
            | Expression::More(loc, ..)
            | Expression::LessEqual(loc, ..)
            | Expression::MoreEqual(loc, ..)
            | Expression::Equal(loc, ..)
            | Expression::NotEqual(loc, ..)
            | Expression::And(loc, ..)
            | Expression::Or(loc, ..)
            | Expression::ConditionalOperator(loc, ..)
            | Expression::Assign(loc, ..)
            | Expression::AssignOr(loc, ..)
            | Expression::AssignAnd(loc, ..)
            | Expression::AssignXor(loc, ..)
            | Expression::AssignShiftLeft(loc, ..)
            | Expression::AssignShiftRight(loc, ..)
            | Expression::AssignAdd(loc, ..)
            | Expression::AssignSubtract(loc, ..)
            | Expression::AssignMultiply(loc, ..)
            | Expression::AssignDivide(loc, ..)
            | Expression::AssignModulo(loc, ..)
            | Expression::BoolLiteral(loc, _)
            | Expression::NumberLiteral(loc, ..)
            | Expression::HexNumberLiteral(loc, _)
            | Expression::ArrayLiteral(loc, _)
            | Expression::List(loc, _)
            | Expression::Type(loc, _)
            | Expression::Variable(Identifier { loc, .. }) => *loc,
            Expression::StringLiteral(v) => v[0].loc,
            Expression::AddressLiteral(loc, _) => *loc,
        }
    }
}

impl Display for Expression {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Expression::Variable(id) => write!(f, "{}", id.name),
            Expression::MemberAccess(_, e, id) => write!(f, "{}.{}", e, id.name),
            _ => unimplemented!(),
        }
    }
}

impl Expression {
    #[inline]
    pub fn remove_parenthesis(&self) -> &Expression {
        if let Expression::Parenthesis(_, expr) = self {
            expr
        } else {
            self
        }
    }
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct Parameter {
    pub loc: Loc,
    pub ty: Expression,
    pub name: Option<Identifier>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
pub struct FunctionDefinition {
    pub loc: Loc,
    pub name: Option<Identifier>,
    pub name_loc: Loc,
    pub params: ParameterList,
    pub returns: ParameterList,
    pub body: Option<Statement>,
}

#[derive(Debug, PartialEq, Eq, Clone)]
#[allow(clippy::large_enum_variant, clippy::type_complexity)]
pub enum Statement {
    Block {
        loc: Loc,

        statements: Vec<Statement>,
    },
    Args(Loc, Vec<NamedArgument>),
    If(Loc, Expression, Box<Statement>, Option<Box<Statement>>),
    While(Loc, Expression, Box<Statement>),
    Expression(Loc, Expression),
    VariableDefinition(Loc, VariableDeclaration, Option<Expression>),
    For(
        Loc,
        Option<Box<Statement>>,
        Option<Box<Expression>>,
        Option<Box<Expression>>,
        Option<Box<Statement>>,
    ),
    DoWhile(Loc, Box<Statement>, Expression),
    Continue(Loc),
    Break(Loc),
    Error(Loc),
    Return(Loc, Option<Expression>),
}

impl CodeLocation for Statement {
    fn loc(&self) -> Loc {
        match self {
            Statement::Block { loc, .. }
            | Statement::Args(loc, ..)
            | Statement::If(loc, ..)
            | Statement::While(loc, ..)
            | Statement::Expression(loc, ..)
            | Statement::VariableDefinition(loc, ..)
            | Statement::For(loc, ..)
            | Statement::Continue(loc)
            | Statement::DoWhile(loc, ..)
            | Statement::Break(loc)
            | Statement::Error(loc)
            | Statement::Return(loc, ..) => *loc,
        }
    }
}
