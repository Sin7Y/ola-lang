use crate::program::*;
use std::fmt;

// #[derive(Copy, Clone, PartialEq, Eq, Debug)]
// pub enum Token {
//     Identifier(&'input str),
//     StringLiteral(bool, &'input str),
//     AddressLiteral(&'input str),
//     HexLiteral(&'input str),
//     Number(&'input str, &'input str),
//     RationalNumber(&'input str, &'input str, &'input str),
//     HexNumber(&'input str),
//     Divide,
//     Contract,
//     Library,
//     Interface,
//     Function,
//     Pragma,
//     Import,

//     Struct,
//     Event,
//     Error,
//     Enum,
//     Type,

//     Memory,
//     Storage,
//     Calldata,

//     Public,
//     Private,
//     Internal,
//     External,

//     Constant,

//     New,
//     Delete,

//     Pure,
//     View,
//     Payable,

//     Do,
//     Continue,
//     Break,

//     Throw,
//     Emit,
//     Return,
//     Returns,
//     Revert,

//     Uint(u16),
//     Int(u16),
//     Bytes(u8),
//     // prior to 0.8.0 `byte` used to be an alias for `bytes1`
//     Byte,
//     DynamicBytes,
//     Bool,
//     Address,
//     String,

//     Semicolon,
//     Comma,
//     OpenParenthesis,
//     CloseParenthesis,
//     OpenCurlyBrace,
//     CloseCurlyBrace,

//     BitwiseOr,
//     BitwiseOrAssign,
//     Or,

//     BitwiseXor,
//     BitwiseXorAssign,

//     BitwiseAnd,
//     BitwiseAndAssign,
//     And,

//     AddAssign,
//     Increment,
//     Add,

//     SubtractAssign,
//     Decrement,
//     Subtract,

//     MulAssign,
//     Mul,
//     Power,
//     DivideAssign,
//     ModuloAssign,
//     Modulo,

//     Equal,
//     Assign,
//     ColonAssign,

//     NotEqual,
//     Not,

//     True,
//     False,
//     Else,
//     Anonymous,
//     For,
//     While,
//     If,

//     ShiftRight,
//     ShiftRightAssign,
//     Less,
//     LessEqual,

//     ShiftLeft,
//     ShiftLeftAssign,
//     More,
//     MoreEqual,

//     Constructor,
//     Indexed,

//     Member,
//     Colon,
//     OpenBracket,
//     CloseBracket,
//     Complement,
//     Question,

//     Mapping,
//     Arrow,

//     Try,
//     Catch,

//     Receive,
//     Fallback,

//     Seconds,
//     Minutes,
//     Hours,
//     Days,
//     Weeks,
//     Gwei,
//     Wei,
//     Ether,

//     This,
//     As,
//     Is,
//     Abstract,
//     Virtual,
//     Override,
//     Using,
//     Modifier,
//     Immutable,
//     Unchecked,

//     Assembly,
//     Let,
//     Leave,
//     Switch,
//     Case,
//     Default,
//     YulArrow,
// }

// impl fmt::Display for Token {
//     fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
//         match self {
//             Token::Identifier(id) => write!(f, "{}", id),
//             Token::StringLiteral(false, s) => write!(f, "\"{}\"", s),
//             Token::StringLiteral(true, s) => write!(f, "unicode\"{}\"", s),
//             Token::HexLiteral(hex) => write!(f, "{}", hex),
//             Token::AddressLiteral(address) => write!(f, "{}", address),
//             Token::Number(integer, exp) if exp.is_empty() => write!(f, "{}", integer),
//             Token::Number(integer, exp) => write!(f, "{}e{}", integer, exp),
//             Token::RationalNumber(integer, fraction, exp) if exp.is_empty() => {
//                 write!(f, "{}.{}", integer, fraction)
//             }
//             Token::RationalNumber(integer, fraction, exp) => {
//                 write!(f, "{}.{}e{}", integer, fraction, exp)
//             }
//             Token::HexNumber(n) => write!(f, "{}", n),
//             Token::Uint(w) => write!(f, "uint{}", w),
//             Token::Int(w) => write!(f, "int{}", w),
//             Token::Bytes(w) => write!(f, "bytes{}", w),
//             Token::Byte => write!(f, "byte"),
//             Token::DynamicBytes => write!(f, "bytes"),
//             Token::Semicolon => write!(f, ";"),
//             Token::Comma => write!(f, ","),
//             Token::OpenParenthesis => write!(f, "("),
//             Token::CloseParenthesis => write!(f, ")"),
//             Token::OpenCurlyBrace => write!(f, "{{"),
//             Token::CloseCurlyBrace => write!(f, "}}"),
//             Token::BitwiseOr => write!(f, "|"),
//             Token::BitwiseOrAssign => write!(f, "|="),
//             Token::Or => write!(f, "||"),
//             Token::BitwiseXor => write!(f, "^"),
//             Token::BitwiseXorAssign => write!(f, "^="),
//             Token::BitwiseAnd => write!(f, "&"),
//             Token::BitwiseAndAssign => write!(f, "&="),
//             Token::And => write!(f, "&&"),
//             Token::AddAssign => write!(f, "+="),
//             Token::Increment => write!(f, "++"),
//             Token::Add => write!(f, "+"),
//             Token::SubtractAssign => write!(f, "-="),
//             Token::Decrement => write!(f, "--"),
//             Token::Subtract => write!(f, "-"),
//             Token::MulAssign => write!(f, "*="),
//             Token::Mul => write!(f, "*"),
//             Token::Power => write!(f, "**"),
//             Token::Divide => write!(f, "/"),
//             Token::DivideAssign => write!(f, "/="),
//             Token::ModuloAssign => write!(f, "%="),
//             Token::Modulo => write!(f, "%"),
//             Token::Equal => write!(f, "=="),
//             Token::Assign => write!(f, "="),
//             Token::ColonAssign => write!(f, ":="),
//             Token::NotEqual => write!(f, "!="),
//             Token::Not => write!(f, "!"),
//             Token::ShiftLeft => write!(f, "<<"),
//             Token::ShiftLeftAssign => write!(f, "<<="),
//             Token::More => write!(f, ">"),
//             Token::MoreEqual => write!(f, ">="),
//             Token::Member => write!(f, "."),
//             Token::Colon => write!(f, ":"),
//             Token::OpenBracket => write!(f, "["),
//             Token::CloseBracket => write!(f, "]"),
//             Token::Complement => write!(f, "~"),
//             Token::Question => write!(f, "?"),
//             Token::ShiftRightAssign => write!(f, "<<="),
//             Token::ShiftRight => write!(f, "<<"),
//             Token::Less => write!(f, "<"),
//             Token::LessEqual => write!(f, "<="),
//             Token::Bool => write!(f, "bool"),
//             Token::Address => write!(f, "address"),
//             Token::String => write!(f, "string"),
//             Token::Contract => write!(f, "contract"),
//             Token::Library => write!(f, "library"),
//             Token::Interface => write!(f, "interface"),
//             Token::Function => write!(f, "function"),
//             Token::Pragma => write!(f, "pragma"),
//             Token::Import => write!(f, "import"),
//             Token::Struct => write!(f, "struct"),
//             Token::Event => write!(f, "event"),
//             Token::Error => write!(f, "error"),
//             Token::Enum => write!(f, "enum"),
//             Token::Type => write!(f, "type"),
//             Token::Memory => write!(f, "memory"),
//             Token::Storage => write!(f, "storage"),
//             Token::Calldata => write!(f, "calldata"),
//             Token::Public => write!(f, "public"),
//             Token::Private => write!(f, "private"),
//             Token::Internal => write!(f, "internal"),
//             Token::External => write!(f, "external"),
//             Token::Constant => write!(f, "constant"),
//             Token::New => write!(f, "new"),
//             Token::Delete => write!(f, "delete"),
//             Token::Pure => write!(f, "pure"),
//             Token::View => write!(f, "view"),
//             Token::Payable => write!(f, "payable"),
//             Token::Do => write!(f, "do"),
//             Token::Continue => write!(f, "continue"),
//             Token::Break => write!(f, "break"),
//             Token::Throw => write!(f, "throw"),
//             Token::Emit => write!(f, "emit"),
//             Token::Return => write!(f, "return"),
//             Token::Returns => write!(f, "returns"),
//             Token::Revert => write!(f, "revert"),
//             Token::True => write!(f, "true"),
//             Token::False => write!(f, "false"),
//             Token::Else => write!(f, "else"),
//             Token::Anonymous => write!(f, "anonymous"),
//             Token::For => write!(f, "for"),
//             Token::While => write!(f, "while"),
//             Token::If => write!(f, "if"),
//             Token::Constructor => write!(f, "constructor"),
//             Token::Indexed => write!(f, "indexed"),
//             Token::Mapping => write!(f, "mapping"),
//             Token::Arrow => write!(f, "=>"),
//             Token::Try => write!(f, "try"),
//             Token::Catch => write!(f, "catch"),
//             Token::Receive => write!(f, "receive"),
//             Token::Fallback => write!(f, "fallback"),
//             Token::Seconds => write!(f, "seconds"),
//             Token::Minutes => write!(f, "minutes"),
//             Token::Hours => write!(f, "hours"),
//             Token::Days => write!(f, "days"),
//             Token::Weeks => write!(f, "weeks"),
//             Token::Gwei => write!(f, "gwei"),
//             Token::Wei => write!(f, "wei"),
//             Token::Ether => write!(f, "ether"),
//             Token::This => write!(f, "this"),
//             Token::As => write!(f, "as"),
//             Token::Is => write!(f, "is"),
//             Token::Abstract => write!(f, "abstract"),
//             Token::Virtual => write!(f, "virtual"),
//             Token::Override => write!(f, "override"),
//             Token::Using => write!(f, "using"),
//             Token::Modifier => write!(f, "modifier"),
//             Token::Immutable => write!(f, "immutable"),
//             Token::Unchecked => write!(f, "unchecked"),
//             Token::Assembly => write!(f, "assembly"),
//             Token::Let => write!(f, "let"),
//             Token::Leave => write!(f, "leave"),
//             Token::Switch => write!(f, "switch"),
//             Token::Case => write!(f, "case"),
//             Token::Default => write!(f, "default"),
//             Token::YulArrow => write!(f, "->"),
//         }
//     }
// }

#[derive(Debug, PartialEq, Eq, Clone)]
pub enum LexicalError {
    EndOfFileInComment(Loc),
    EndOfFileInString(Loc),
    EndofFileInHex(Loc),
    MissingNumber(Loc),
    InvalidCharacterInHexLiteral(Loc, char),
    UnrecognisedToken(Loc, String),
    MissingExponent(Loc),
    ExpectedFrom(Loc, String),
}

impl fmt::Display for LexicalError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            LexicalError::EndOfFileInComment(..) => write!(f, "end of file found in comment"),
            LexicalError::EndOfFileInString(..) => {
                write!(f, "end of file found in string literal")
            }
            LexicalError::EndofFileInHex(..) => {
                write!(f, "end of file found in hex literal string")
            }
            LexicalError::MissingNumber(..) => write!(f, "missing number"),
            LexicalError::InvalidCharacterInHexLiteral(_, ch) => {
                write!(f, "invalid character '{}' in hex literal string", ch)
            }
            LexicalError::UnrecognisedToken(_, t) => write!(f, "unrecognised token '{}'", t),
            LexicalError::ExpectedFrom(_, t) => write!(f, "'{}' found where 'from' expected", t),
            LexicalError::MissingExponent(..) => write!(f, "missing number"),
        }
    }
}

impl CodeLocation for LexicalError {
    fn loc(&self) -> Loc {
        match self {
            LexicalError::EndOfFileInComment(loc, ..)
            | LexicalError::EndOfFileInString(loc, ..)
            | LexicalError::EndofFileInHex(loc, ..)
            | LexicalError::MissingNumber(loc, ..)
            | LexicalError::InvalidCharacterInHexLiteral(loc, _)
            | LexicalError::UnrecognisedToken(loc, ..)
            | LexicalError::ExpectedFrom(loc, ..)
            | LexicalError::MissingExponent(loc, ..) => *loc,
        }
    }
}
