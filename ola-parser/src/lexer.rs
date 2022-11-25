// SPDX-License-Identifier: Apache-2.0

//
// ola custom lexer.
//
use itertools::{peek_nth, PeekNth};
use phf::phf_map;
use std::{fmt, str::CharIndices};
use unicode_xid::UnicodeXID;

use crate::pt::{CodeLocation, Comment, Loc};

pub type Spanned<Token, Loc, Error> = Result<(Loc, Token, Loc), Error>;

#[derive(Copy, Clone, PartialEq, Eq, Debug)]
pub enum Token<'input> {
    Identifier(&'input str),
    Number(&'input str, &'input str),
    HexNumber(&'input str),
    Divide,
    Contract,
    Function,
    Import,

    Struct,
    Enum,
    Type,

    Continue,
    Break,

    Return,
    Returns,

    Uint(u16),
    Bool,

    Semicolon,
    Comma,
    OpenParenthesis,
    CloseParenthesis,
    OpenCurlyBrace,
    CloseCurlyBrace,

    BitwiseOr,
    BitwiseOrAssign,
    Or,

    BitwiseXor,
    BitwiseXorAssign,

    BitwiseAnd,
    BitwiseAndAssign,
    And,

    AddAssign,
    Increment,
    Add,

    SubtractAssign,
    Decrement,
    Subtract,

    MulAssign,
    Mul,
    Power,
    DivideAssign,
    ModuloAssign,
    Modulo,

    Equal,
    Assign,
    ColonAssign,

    NotEqual,
    Not,

    True,
    False,
    Else,
    Anonymous,
    For,
    While,
    If,

    ShiftRight,
    ShiftRightAssign,
    Less,
    LessEqual,

    ShiftLeft,
    ShiftLeftAssign,
    More,
    MoreEqual,

    Constructor,
    Indexed,

    Member,
    Colon,
    OpenBracket,
    CloseBracket,
    Complement,
    Question,

    Mapping,
    Arrow,

    Receive,
    Fallback,

    As,
    Is,

    Let,
    Field,
}

impl<'input> fmt::Display for Token<'input> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Token::Identifier(id) => write!(f, "{}", id),
            Token::Number(integer, exp) if exp.is_empty() => write!(f, "{}", integer),
            Token::Number(integer, exp) => write!(f, "{}e{}", integer, exp),
            Token::HexNumber(n) => write!(f, "{}", n),
            Token::Uint(w) => write!(f, "uint{}", w),
            Token::Semicolon => write!(f, ";"),
            Token::Comma => write!(f, ","),
            Token::OpenParenthesis => write!(f, "("),
            Token::CloseParenthesis => write!(f, ")"),
            Token::OpenCurlyBrace => write!(f, "{{"),
            Token::CloseCurlyBrace => write!(f, "}}"),
            Token::BitwiseOr => write!(f, "|"),
            Token::BitwiseOrAssign => write!(f, "|="),
            Token::Or => write!(f, "||"),
            Token::BitwiseXor => write!(f, "^"),
            Token::BitwiseXorAssign => write!(f, "^="),
            Token::BitwiseAnd => write!(f, "&"),
            Token::BitwiseAndAssign => write!(f, "&="),
            Token::And => write!(f, "&&"),
            Token::AddAssign => write!(f, "+="),
            Token::Increment => write!(f, "++"),
            Token::Add => write!(f, "+"),
            Token::SubtractAssign => write!(f, "-="),
            Token::Decrement => write!(f, "--"),
            Token::Subtract => write!(f, "-"),
            Token::MulAssign => write!(f, "*="),
            Token::Mul => write!(f, "*"),
            Token::Power => write!(f, "**"),
            Token::Divide => write!(f, "/"),
            Token::DivideAssign => write!(f, "/="),
            Token::ModuloAssign => write!(f, "%="),
            Token::Modulo => write!(f, "%"),
            Token::Equal => write!(f, "=="),
            Token::Assign => write!(f, "="),
            Token::ColonAssign => write!(f, ":="),
            Token::NotEqual => write!(f, "!="),
            Token::Not => write!(f, "!"),
            Token::ShiftLeft => write!(f, "<<"),
            Token::ShiftLeftAssign => write!(f, "<<="),
            Token::More => write!(f, ">"),
            Token::MoreEqual => write!(f, ">="),
            Token::Member => write!(f, "."),
            Token::Colon => write!(f, ":"),
            Token::OpenBracket => write!(f, "["),
            Token::CloseBracket => write!(f, "]"),
            Token::Complement => write!(f, "~"),
            Token::Question => write!(f, "?"),
            Token::ShiftRightAssign => write!(f, "<<="),
            Token::ShiftRight => write!(f, "<<"),
            Token::Less => write!(f, "<"),
            Token::LessEqual => write!(f, "<="),
            Token::Bool => write!(f, "bool"),
            Token::Contract => write!(f, "contract"),
            Token::Function => write!(f, "function"),
            Token::Import => write!(f, "import"),
            Token::Struct => write!(f, "struct"),
            Token::Enum => write!(f, "enum"),
            Token::Type => write!(f, "type"),
            Token::Continue => write!(f, "continue"),
            Token::Break => write!(f, "break"),
            Token::Return => write!(f, "return"),
            Token::Returns => write!(f, "returns"),
            Token::True => write!(f, "true"),
            Token::False => write!(f, "false"),
            Token::Else => write!(f, "else"),
            Token::Anonymous => write!(f, "anonymous"),
            Token::For => write!(f, "for"),
            Token::While => write!(f, "while"),
            Token::If => write!(f, "if"),
            Token::Constructor => write!(f, "constructor"),
            Token::Indexed => write!(f, "indexed"),
            Token::Mapping => write!(f, "mapping"),
            Token::Arrow => write!(f, "=>"),
            Token::Receive => write!(f, "receive"),
            Token::Fallback => write!(f, "fallback"),
            Token::As => write!(f, "as"),
            Token::Is => write!(f, "is"),
            Token::Let => write!(f, "let"),
            Token::Field => write!(f, "field"),
        }
    }
}

pub struct Lexer<'input> {
    input: &'input str,
    chars: PeekNth<CharIndices<'input>>,
    comments: &'input mut Vec<Comment>,
    file_no: usize,
    last_tokens: [Option<Token<'input>>; 2],
    pub errors: &'input mut Vec<LexicalError>,
}

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

/// Is this word a keyword in Solidity
pub fn is_keyword(word: &str) -> bool {
    KEYWORDS.contains_key(word)
}

static KEYWORDS: phf::Map<&'static str, Token> = phf_map! {
    "bool" => Token::Bool,
    "break" => Token::Break,
    "continue" => Token::Continue,
    "contract" => Token::Contract,
    "else" => Token::Else,
    "enum" => Token::Enum,
    "false" => Token::False,
    "for" => Token::For,
    "fn" => Token::Function,
    "if" => Token::If,
    "returns" => Token::Returns,
    "return" => Token::Return,
    "struct" => Token::Struct,
    "true" => Token::True,
    "type" => Token::Type,
    "uint8" => Token::Uint(8),
    "uint16" => Token::Uint(16),
    "uint24" => Token::Uint(24),
    "uint32" => Token::Uint(32),
    "uint40" => Token::Uint(40),
    "uint48" => Token::Uint(48),
    "uint56" => Token::Uint(56),
    "uint64" => Token::Uint(64),
    "uint72" => Token::Uint(72),
    "uint80" => Token::Uint(80),
    "uint88" => Token::Uint(88),
    "uint96" => Token::Uint(96),
    "uint104" => Token::Uint(104),
    "uint112" => Token::Uint(112),
    "uint120" => Token::Uint(120),
    "uint128" => Token::Uint(128),
    "uint136" => Token::Uint(136),
    "uint144" => Token::Uint(144),
    "uint152" => Token::Uint(152),
    "uint160" => Token::Uint(160),
    "uint168" => Token::Uint(168),
    "uint176" => Token::Uint(176),
    "uint184" => Token::Uint(184),
    "uint192" => Token::Uint(192),
    "uint200" => Token::Uint(200),
    "uint208" => Token::Uint(208),
    "uint216" => Token::Uint(216),
    "uint224" => Token::Uint(224),
    "uint232" => Token::Uint(232),
    "uint240" => Token::Uint(240),
    "uint248" => Token::Uint(248),
    "uint256" => Token::Uint(256),
    "uint" => Token::Uint(256),
    "as" => Token::As,
    "is" => Token::Is,
    "using" => Token::Using,
};

impl<'input> Lexer<'input> {
    pub fn new(
        input: &'input str,
        file_no: usize,
        comments: &'input mut Vec<Comment>,
        errors: &'input mut Vec<LexicalError>,
    ) -> Self {
        Lexer {
            input,
            chars: peek_nth(input.char_indices()),
            comments,
            file_no,
            last_tokens: [None, None],
            errors,
        }
    }

    fn parse_number(
        &mut self,
        start: usize,
        end: usize,
        ch: char,
    ) -> Result<(usize, Token<'input>, usize), LexicalError> {
        let mut is_rational = false;
        if ch == '0' {
            if let Some((_, 'x')) = self.chars.peek() {
                // hex number
                self.chars.next();

                let mut end = match self.chars.next() {
                    Some((end, ch)) if ch.is_ascii_hexdigit() => end,
                    Some((..)) => {
                        return Err(LexicalError::MissingNumber(Loc::File(
                            self.file_no,
                            start,
                            start + 1,
                        )));
                    }
                    None => {
                        return Err(LexicalError::EndofFileInHex(Loc::File(
                            self.file_no,
                            start,
                            self.input.len(),
                        )));
                    }
                };

                while let Some((i, ch)) = self.chars.peek() {
                    if !ch.is_ascii_hexdigit() && *ch != '_' {
                        break;
                    }
                    end = *i;
                    self.chars.next();
                }

                return Ok((start, Token::HexNumber(&self.input[start..=end]), end + 1));
            }
        }

        let mut start = start;
        if ch == '.' {
            is_rational = true;
            start -= 1;
        }

        let mut end = end;
        while let Some((i, ch)) = self.chars.peek() {
            if !ch.is_ascii_digit() && *ch != '_' {
                break;
            }
            end = *i;
            self.chars.next();
        }
        let mut rational_end = end;
        let mut end_before_rational = end;
        let mut rational_start = end;
        if is_rational {
            end_before_rational = start - 1;
            rational_start = start + 1;
        }

        if let Some((_, '.')) = self.chars.peek() {
            if let Some((i, ch)) = self.chars.peek_nth(1) {
                if ch.is_ascii_digit() && !is_rational {
                    rational_start = *i;
                    rational_end = *i;
                    is_rational = true;
                    self.chars.next(); // advance over '.'
                    while let Some((i, ch)) = self.chars.peek() {
                        if !ch.is_ascii_digit() && *ch != '_' {
                            break;
                        }
                        rational_end = *i;
                        end = *i;
                        self.chars.next();
                    }
                }
            }
        }

        let old_end = end;
        let mut exp_start = end + 1;

        if let Some((i, 'e' | 'E')) = self.chars.peek() {
            exp_start = *i + 1;
            self.chars.next();
            // Negative exponent
            while matches!(self.chars.peek(), Some((_, '-'))) {
                self.chars.next();
            }
            while let Some((i, ch)) = self.chars.peek() {
                if !ch.is_ascii_digit() && *ch != '_' {
                    break;
                }
                end = *i;
                self.chars.next();
            }

            if exp_start > end {
                return Err(LexicalError::MissingExponent(Loc::File(
                    self.file_no,
                    start,
                    self.input.len(),
                )));
            }
        }

        if is_rational {
            let integer = &self.input[start..=end_before_rational];
            let fraction = &self.input[rational_start..=rational_end];
            let exp = &self.input[exp_start..=end];

            return Ok((
                start,
                Token::RationalNumber(integer, fraction, exp),
                end + 1,
            ));
        }

        let integer = &self.input[start..=old_end];
        let exp = &self.input[exp_start..=end];

        Ok((start, Token::Number(integer, exp), end + 1))
    }

    fn string(
        &mut self,
        unicode: bool,
        token_start: usize,
        string_start: usize,
        quote_char: char,
    ) -> Result<(usize, Token<'input>, usize), LexicalError> {
        let mut end;

        let mut last_was_escape = false;

        loop {
            if let Some((i, ch)) = self.chars.next() {
                end = i;
                if !last_was_escape {
                    if ch == quote_char {
                        break;
                    }
                    last_was_escape = ch == '\\';
                } else {
                    last_was_escape = false;
                }
            } else {
                return Err(LexicalError::EndOfFileInString(Loc::File(
                    self.file_no,
                    token_start,
                    self.input.len(),
                )));
            }
        }

        Ok((
            token_start,
            Token::StringLiteral(unicode, &self.input[string_start..end]),
            end + 1,
        ))
    }

    fn next(&mut self) -> Option<Result<(usize, Token<'input>, usize), LexicalError>> {
        'toplevel: loop {
            match self.chars.next() {
                Some((start, ch)) if ch == '_' || ch == '$' || UnicodeXID::is_xid_start(ch) => {
                    let end;

                    loop {
                        if let Some((i, ch)) = self.chars.peek() {
                            if !UnicodeXID::is_xid_continue(*ch) && *ch != '$' {
                                end = *i;
                                break;
                            }
                            self.chars.next();
                        } else {
                            end = self.input.len();
                            break;
                        }
                    }

                    let id = &self.input[start..end];

                    if id == "unicode" {
                        match self.chars.peek() {
                            Some((_, quote_char @ '"')) | Some((_, quote_char @ '\'')) => {
                                let quote_char = *quote_char;

                                self.chars.next();
                                let str_res = self.string(true, start, start + 8, quote_char);
                                if let Err(lex_err) = str_res {
                                    self.errors.push(lex_err);
                                } else {
                                    return Some(str_res);
                                }
                            }
                            _ => (),
                        }
                    }

                    if id == "hex" {
                        match self.chars.peek() {
                            Some((_, quote_char @ '"')) | Some((_, quote_char @ '\'')) => {
                                let quote_char = *quote_char;

                                self.chars.next();

                                for (i, ch) in &mut self.chars {
                                    if ch == quote_char {
                                        return Some(Ok((
                                            start,
                                            Token::HexLiteral(&self.input[start..=i]),
                                            i + 1,
                                        )));
                                    }

                                    if !ch.is_ascii_hexdigit() && ch != '_' {
                                        // Eat up the remainer of the string
                                        for (_, ch) in &mut self.chars {
                                            if ch == quote_char {
                                                break;
                                            }
                                        }

                                        self.errors.push(
                                            LexicalError::InvalidCharacterInHexLiteral(
                                                Loc::File(self.file_no, i, i + 1),
                                                ch,
                                            ),
                                        );
                                        continue 'toplevel;
                                    }
                                }

                                self.errors.push(LexicalError::EndOfFileInString(Loc::File(
                                    self.file_no,
                                    start,
                                    self.input.len(),
                                )));
                                return None;
                            }
                            _ => (),
                        }
                    }

                    if id == "address" {
                        match self.chars.peek() {
                            Some((_, quote_char @ '"')) | Some((_, quote_char @ '\'')) => {
                                let quote_char = *quote_char;

                                self.chars.next();

                                for (i, ch) in &mut self.chars {
                                    if ch == quote_char {
                                        return Some(Ok((
                                            start,
                                            Token::AddressLiteral(&self.input[start..=i]),
                                            i + 1,
                                        )));
                                    }
                                }

                                self.errors.push(LexicalError::EndOfFileInString(Loc::File(
                                    self.file_no,
                                    start,
                                    self.input.len(),
                                )));
                                return None;
                            }
                            _ => (),
                        }
                    }

                    return if let Some(w) = KEYWORDS.get(id) {
                        Some(Ok((start, *w, end)))
                    } else {
                        Some(Ok((start, Token::Identifier(id), end)))
                    };
                }
                Some((start, quote_char @ '"')) | Some((start, quote_char @ '\'')) => {
                    let str_res = self.string(false, start, start + 1, quote_char);
                    if let Err(lex_err) = str_res {
                        self.errors.push(lex_err);
                    } else {
                        return Some(str_res);
                    }
                }
                Some((start, '/')) => {
                    match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            return Some(Ok((start, Token::DivideAssign, start + 2)));
                        }
                        Some((_, '/')) => {
                            // line comment
                            self.chars.next();

                            let mut newline = false;

                            let doc_comment = match self.chars.next() {
                                Some((_, '/')) => {
                                    // ///(/)+ is still a line comment
                                    !matches!(self.chars.peek(), Some((_, '/')))
                                }
                                Some((_, ch)) if ch == '\n' || ch == '\r' => {
                                    newline = true;
                                    false
                                }
                                _ => false,
                            };

                            let mut last = start + 3;

                            if !newline {
                                loop {
                                    match self.chars.next() {
                                        None => {
                                            last = self.input.len();
                                            break;
                                        }
                                        Some((offset, '\n' | '\r')) => {
                                            last = offset;
                                            break;
                                        }
                                        Some(_) => (),
                                    }
                                }
                            }

                            if doc_comment {
                                self.comments.push(Comment::DocLine(
                                    Loc::File(self.file_no, start, last),
                                    self.input[start..last].to_owned(),
                                ));
                            } else {
                                self.comments.push(Comment::Line(
                                    Loc::File(self.file_no, start, last),
                                    self.input[start..last].to_owned(),
                                ));
                            }
                        }
                        Some((_, '*')) => {
                            // multiline comment
                            self.chars.next();

                            let doc_comment_start = matches!(self.chars.peek(), Some((_, '*')));

                            let mut last = start + 3;
                            let mut seen_star = false;

                            loop {
                                if let Some((i, ch)) = self.chars.next() {
                                    if seen_star && ch == '/' {
                                        break;
                                    }
                                    seen_star = ch == '*';
                                    last = i;
                                } else {
                                    self.errors.push(LexicalError::EndOfFileInComment(Loc::File(
                                        self.file_no,
                                        start,
                                        self.input.len(),
                                    )));
                                    return None;
                                }
                            }

                            // `/**/` is not a doc comment
                            if doc_comment_start && last > start + 2 {
                                self.comments.push(Comment::DocBlock(
                                    Loc::File(self.file_no, start, last + 2),
                                    self.input[start..last + 2].to_owned(),
                                ));
                            } else {
                                self.comments.push(Comment::Block(
                                    Loc::File(self.file_no, start, last + 2),
                                    self.input[start..last + 2].to_owned(),
                                ));
                            }
                        }
                        _ => {
                            return Some(Ok((start, Token::Divide, start + 1)));
                        }
                    }
                }
                Some((start, ch)) if ch.is_ascii_digit() => {
                    let parse_result = self.parse_number(start, start, ch);
                    if let Err(lex_err) = parse_result {
                        self.errors.push(lex_err.clone());
                        if let LexicalError::EndofFileInHex(_) = lex_err {
                            return None;
                        }
                    } else {
                        return Some(parse_result);
                    }
                }
                Some((i, ';')) => return Some(Ok((i, Token::Semicolon, i + 1))),
                Some((i, ',')) => return Some(Ok((i, Token::Comma, i + 1))),
                Some((i, '(')) => return Some(Ok((i, Token::OpenParenthesis, i + 1))),
                Some((i, ')')) => return Some(Ok((i, Token::CloseParenthesis, i + 1))),
                Some((i, '{')) => return Some(Ok((i, Token::OpenCurlyBrace, i + 1))),
                Some((i, '}')) => return Some(Ok((i, Token::CloseCurlyBrace, i + 1))),
                Some((i, '~')) => return Some(Ok((i, Token::Complement, i + 1))),
                Some((i, '=')) => match self.chars.peek() {
                    Some((_, '=')) => {
                        self.chars.next();
                        return Some(Ok((i, Token::Equal, i + 2)));
                    }
                    Some((_, '>')) => {
                        self.chars.next();
                        return Some(Ok((i, Token::Arrow, i + 2)));
                    }
                    _ => {
                        return Some(Ok((i, Token::Assign, i + 1)));
                    }
                },
                Some((i, '!')) => {
                    if let Some((_, '=')) = self.chars.peek() {
                        self.chars.next();
                        return Some(Ok((i, Token::NotEqual, i + 2)));
                    } else {
                        return Some(Ok((i, Token::Not, i + 1)));
                    }
                }
                Some((i, '|')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::BitwiseOrAssign, i + 2)))
                        }
                        Some((_, '|')) => {
                            self.chars.next();
                            Some(Ok((i, Token::Or, i + 2)))
                        }
                        _ => Some(Ok((i, Token::BitwiseOr, i + 1))),
                    };
                }
                Some((i, '&')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::BitwiseAndAssign, i + 2)))
                        }
                        Some((_, '&')) => {
                            self.chars.next();
                            Some(Ok((i, Token::And, i + 2)))
                        }
                        _ => Some(Ok((i, Token::BitwiseAnd, i + 1))),
                    };
                }
                Some((i, '^')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::BitwiseXorAssign, i + 2)))
                        }
                        _ => Some(Ok((i, Token::BitwiseXor, i + 1))),
                    };
                }
                Some((i, '+')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::AddAssign, i + 2)))
                        }
                        Some((_, '+')) => {
                            self.chars.next();
                            Some(Ok((i, Token::Increment, i + 2)))
                        }
                        _ => Some(Ok((i, Token::Add, i + 1))),
                    };
                }
                Some((i, '-')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::SubtractAssign, i + 2)))
                        }
                        Some((_, '-')) => {
                            self.chars.next();
                            Some(Ok((i, Token::Decrement, i + 2)))
                        }
                        Some((_, '>')) => {
                            self.chars.next();
                            Some(Ok((i, Token::YulArrow, i + 2)))
                        }
                        _ => Some(Ok((i, Token::Subtract, i + 1))),
                    };
                }
                Some((i, '*')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::MulAssign, i + 2)))
                        }
                        Some((_, '*')) => {
                            self.chars.next();
                            Some(Ok((i, Token::Power, i + 2)))
                        }
                        _ => Some(Ok((i, Token::Mul, i + 1))),
                    };
                }
                Some((i, '%')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::ModuloAssign, i + 2)))
                        }
                        _ => Some(Ok((i, Token::Modulo, i + 1))),
                    };
                }
                Some((i, '<')) => {
                    return match self.chars.peek() {
                        Some((_, '<')) => {
                            self.chars.next();
                            if let Some((_, '=')) = self.chars.peek() {
                                self.chars.next();
                                Some(Ok((i, Token::ShiftLeftAssign, i + 3)))
                            } else {
                                Some(Ok((i, Token::ShiftLeft, i + 2)))
                            }
                        }
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::LessEqual, i + 2)))
                        }
                        _ => Some(Ok((i, Token::Less, i + 1))),
                    };
                }
                Some((i, '>')) => {
                    return match self.chars.peek() {
                        Some((_, '>')) => {
                            self.chars.next();
                            if let Some((_, '=')) = self.chars.peek() {
                                self.chars.next();
                                Some(Ok((i, Token::ShiftRightAssign, i + 3)))
                            } else {
                                Some(Ok((i, Token::ShiftRight, i + 2)))
                            }
                        }
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::MoreEqual, i + 2)))
                        }
                        _ => Some(Ok((i, Token::More, i + 1))),
                    };
                }
                Some((i, '.')) => {
                    if let Some((_, a)) = self.chars.peek() {
                        if a.is_ascii_digit() {
                            return Some(self.parse_number(i + 1, i + 1, '.'));
                        }
                    }
                    return Some(Ok((i, Token::Member, i + 1)));
                }
                Some((i, '[')) => return Some(Ok((i, Token::OpenBracket, i + 1))),
                Some((i, ']')) => return Some(Ok((i, Token::CloseBracket, i + 1))),
                Some((i, ':')) => {
                    return match self.chars.peek() {
                        Some((_, '=')) => {
                            self.chars.next();
                            Some(Ok((i, Token::ColonAssign, i + 2)))
                        }
                        _ => Some(Ok((i, Token::Colon, i + 1))),
                    };
                }
                Some((i, '?')) => return Some(Ok((i, Token::Question, i + 1))),
                Some((_, ch)) if ch.is_whitespace() => (),
                Some((start, _)) => {
                    let mut end;

                    loop {
                        if let Some((i, ch)) = self.chars.next() {
                            end = i;

                            if ch.is_whitespace() {
                                break;
                            }
                        } else {
                            end = self.input.len();
                            break;
                        }
                    }

                    self.errors.push(LexicalError::UnrecognisedToken(
                        Loc::File(self.file_no, start, end),
                        self.input[start..end].to_owned(),
                    ));
                }
                None => return None, // End of file
            }
        }
    }

    /// Next token is pragma value. Return it
    fn pragma_value(&mut self) -> Option<Result<(usize, Token<'input>, usize), LexicalError>> {
        // special parser for pragma solidity >=0.4.22 <0.7.0;
        let mut start = None;
        let mut end = 0;

        // solc will include anything upto the next semicolon, whitespace
        // trimmed on left and right
        loop {
            match self.chars.peek() {
                Some((_, ';')) | None => {
                    return if let Some(start) = start {
                        Some(Ok((
                            start,
                            Token::StringLiteral(false, &self.input[start..end]),
                            end,
                        )))
                    } else {
                        self.next()
                    };
                }
                Some((_, ch)) if ch.is_whitespace() => {
                    self.chars.next();
                }
                Some((i, _)) => {
                    if start.is_none() {
                        start = Some(*i);
                    }
                    self.chars.next();

                    // end should point to the byte _after_ the character
                    end = match self.chars.peek() {
                        Some((i, _)) => *i,
                        None => self.input.len(),
                    }
                }
            }
        }
    }
}

impl<'input> Iterator for Lexer<'input> {
    type Item = Spanned<Token<'input>, usize, LexicalError>;

    /// Return the next token
    fn next(&mut self) -> Option<Self::Item> {
        // Lexer should be aware of whether the last two tokens were
        // pragma followed by identifier. If this is true, then special parsing should be
        // done for the pragma value
        let token = if let [Some(Token::Pragma), Some(Token::Identifier(_))] = self.last_tokens {
            self.pragma_value()
        } else {
            self.next()
        };

        self.last_tokens = [
            self.last_tokens[1],
            match token {
                Some(Ok((_, n, _))) => Some(n),
                _ => None,
            },
        ];

        token
    }
}

#[test]
fn lexertest() {
    let mut comments = Vec::new();
    let mut errors = Vec::new();

    let multiple_errors = r#" 9ea -9e € bool hex uint8 hex"g"   /**  "#;
    let tokens = Lexer::new(multiple_errors, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();
    assert_eq!(
        tokens,
        vec![
            Ok((3, Token::Identifier("a"), 4)),
            Ok((5, Token::Subtract, 6)),
            Ok((13, Token::Bool, 17)),
            Ok((18, Token::Identifier("hex"), 21)),
            Ok((22, Token::Uint(8), 27)),
        ]
    );

    assert_eq!(
        errors,
        vec![
            LexicalError::MissingExponent(Loc::File(0, 1, 42)),
            LexicalError::MissingExponent(Loc::File(0, 6, 42)),
            LexicalError::UnrecognisedToken(Loc::File(0, 9, 12), '€'.to_string()),
            LexicalError::InvalidCharacterInHexLiteral(Loc::File(0, 32, 33), 'g'),
            LexicalError::EndOfFileInComment(Loc::File(0, 37, 42)),
        ]
    );

    let mut errors = Vec::new();
    let tokens = Lexer::new("bool", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(tokens, vec!(Ok((0, Token::Bool, 4))));

    let tokens = Lexer::new("uint8", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(tokens, vec!(Ok((0, Token::Uint(8), 5))));

    let tokens = Lexer::new("hex", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(tokens, vec!(Ok((0, Token::Identifier("hex"), 3))));

    let tokens = Lexer::new(
        "hex\"cafe_dead\" /* adad*** */",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(Ok((0, Token::HexLiteral("hex\"cafe_dead\""), 14)))
    );

    let tokens = Lexer::new(
        "// foo bar\n0x00fead0_12 00090 0_0",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((11, Token::HexNumber("0x00fead0_12"), 23)),
            Ok((24, Token::Number("00090", ""), 29)),
            Ok((30, Token::Number("0_0", ""), 33))
        )
    );

    let tokens = Lexer::new(
        "// foo bar\n0x00fead0_12 9.0008 0_0",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((11, Token::HexNumber("0x00fead0_12"), 23)),
            Ok((24, Token::RationalNumber("9", "0008", ""), 30)),
            Ok((31, Token::Number("0_0", ""), 34))
        )
    );

    let tokens = Lexer::new(
        "// foo bar\n0x00fead0_12 .0008 0.9e2",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((11, Token::HexNumber("0x00fead0_12"), 23)),
            Ok((24, Token::RationalNumber("", "0008", ""), 29)),
            Ok((30, Token::RationalNumber("0", "9", "2"), 35))
        )
    );

    let tokens = Lexer::new(
        "// foo bar\n0x00fead0_12 .0008 0.9e-2-2",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((11, Token::HexNumber("0x00fead0_12"), 23)),
            Ok((24, Token::RationalNumber("", "0008", ""), 29)),
            Ok((30, Token::RationalNumber("0", "9", "-2"), 36)),
            Ok((36, Token::Subtract, 37)),
            Ok((37, Token::Number("2", ""), 38))
        )
    );

    let tokens = Lexer::new("1.2_3e2-", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::RationalNumber("1", "2_3", "2"), 7)),
            Ok((7, Token::Subtract, 8))
        )
    );

    let tokens = Lexer::new("\"foo\"", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(Ok((0, Token::StringLiteral(false, "foo"), 5)),)
    );

    let tokens = Lexer::new(
        "pragma solidity >=0.5.0 <0.7.0;",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Pragma, 6)),
            Ok((7, Token::Identifier("solidity"), 15)),
            Ok((16, Token::StringLiteral(false, ">=0.5.0 <0.7.0"), 30)),
            Ok((30, Token::Semicolon, 31)),
        )
    );

    let tokens = Lexer::new(
        "pragma solidity \t>=0.5.0 <0.7.0 \n ;",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Pragma, 6)),
            Ok((7, Token::Identifier("solidity"), 15)),
            Ok((17, Token::StringLiteral(false, ">=0.5.0 <0.7.0"), 31)),
            Ok((34, Token::Semicolon, 35)),
        )
    );

    let tokens = Lexer::new("pragma solidity 赤;", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Pragma, 6)),
            Ok((7, Token::Identifier("solidity"), 15)),
            Ok((16, Token::StringLiteral(false, "赤"), 19)),
            Ok((19, Token::Semicolon, 20))
        )
    );

    let tokens = Lexer::new(">>= >> >= >", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::ShiftRightAssign, 3)),
            Ok((4, Token::ShiftRight, 6)),
            Ok((7, Token::MoreEqual, 9)),
            Ok((10, Token::More, 11)),
        )
    );

    let tokens = Lexer::new("<<= << <= <", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::ShiftLeftAssign, 3)),
            Ok((4, Token::ShiftLeft, 6)),
            Ok((7, Token::LessEqual, 9)),
            Ok((10, Token::Less, 11)),
        )
    );

    let tokens = Lexer::new("-16 -- - -=", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Subtract, 1)),
            Ok((1, Token::Number("16", ""), 3)),
            Ok((4, Token::Decrement, 6)),
            Ok((7, Token::Subtract, 8)),
            Ok((9, Token::SubtractAssign, 11)),
        )
    );

    let tokens = Lexer::new("-4 ", 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Subtract, 1)),
            Ok((1, Token::Number("4", ""), 2)),
        )
    );

    let mut errors = Vec::new();
    let _ = Lexer::new(r#"hex"abcdefg""#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        errors,
        vec![LexicalError::InvalidCharacterInHexLiteral(
            Loc::File(0, 10, 11),
            'g'
        )]
    );

    let mut errors = Vec::new();
    let _ = Lexer::new(r#" € "#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        errors,
        vec!(LexicalError::UnrecognisedToken(
            Loc::File(0, 1, 4),
            "€".to_owned()
        ))
    );

    let mut errors = Vec::new();
    let _ = Lexer::new(r#"€"#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        errors,
        vec!(LexicalError::UnrecognisedToken(
            Loc::File(0, 0, 3),
            "€".to_owned()
        ))
    );

    let tokens = Lexer::new(r#"pragma foo bar"#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Pragma, 6)),
            Ok((7, Token::Identifier("foo"), 10)),
            Ok((11, Token::StringLiteral(false, "bar"), 14)),
        )
    );

    comments.truncate(0);

    let tokens = Lexer::new(r#"/// foo"#, 0, &mut comments, &mut errors).count();

    assert_eq!(tokens, 0);
    assert_eq!(
        comments,
        vec![Comment::DocLine(Loc::File(0, 0, 7), "/// foo".to_owned())],
    );

    comments.truncate(0);

    let tokens = Lexer::new("/// jadajadadjada\n// bar", 0, &mut comments, &mut errors).count();

    assert_eq!(tokens, 0);
    assert_eq!(
        comments,
        vec!(
            Comment::DocLine(Loc::File(0, 0, 17), "/// jadajadadjada".to_owned()),
            Comment::Line(Loc::File(0, 18, 24), "// bar".to_owned())
        )
    );

    comments.truncate(0);

    let tokens = Lexer::new("/**/", 0, &mut comments, &mut errors).count();

    assert_eq!(tokens, 0);
    assert_eq!(
        comments,
        vec!(Comment::Block(Loc::File(0, 0, 4), "/**/".to_owned()))
    );

    comments.truncate(0);

    let tokens = Lexer::new(r#"/** foo */"#, 0, &mut comments, &mut errors).count();

    assert_eq!(tokens, 0);
    assert_eq!(
        comments,
        vec!(Comment::DocBlock(
            Loc::File(0, 0, 10),
            "/** foo */".to_owned()
        ))
    );

    comments.truncate(0);

    let tokens = Lexer::new(
        "/** jadajadadjada */\n/* bar */",
        0,
        &mut comments,
        &mut errors,
    )
    .count();

    assert_eq!(tokens, 0);
    assert_eq!(
        comments,
        vec!(
            Comment::DocBlock(Loc::File(0, 0, 20), "/** jadajadadjada */".to_owned()),
            Comment::Block(Loc::File(0, 21, 30), "/* bar */".to_owned())
        )
    );

    let tokens = Lexer::new("/************/", 0, &mut comments, &mut errors).next();
    assert_eq!(tokens, None);

    let mut errors = Vec::new();
    let _ = Lexer::new("/**", 0, &mut comments, &mut errors).next();
    assert_eq!(
        errors,
        vec!(LexicalError::EndOfFileInComment(Loc::File(0, 0, 3)))
    );

    let mut errors = Vec::new();
    let tokens = Lexer::new("//////////////", 0, &mut comments, &mut errors).next();
    assert_eq!(tokens, None);

    // some unicode tests
    let tokens = Lexer::new(
        ">=\u{a0} . très\u{2028}αβγδεζηθικλμνξοπρστυφχψω\u{85}カラス",
        0,
        &mut comments,
        &mut errors,
    )
    .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::MoreEqual, 2)),
            Ok((5, Token::Member, 6)),
            Ok((7, Token::Identifier("très"), 12)),
            Ok((15, Token::Identifier("αβγδεζηθικλμνξοπρστυφχψω"), 63)),
            Ok((65, Token::Identifier("カラス"), 74))
        )
    );

    let tokens = Lexer::new(r#"unicode"€""#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(tokens, vec!(Ok((0, Token::StringLiteral(true, "€"), 12)),));

    let tokens = Lexer::new(r#"unicode "€""#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Identifier("unicode"), 7)),
            Ok((8, Token::StringLiteral(false, "€"), 13)),
        )
    );

    // scientific notation
    let tokens = Lexer::new(r#" 1e0 "#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(tokens, vec!(Ok((1, Token::Number("1", "0"), 4)),));

    let tokens = Lexer::new(r#" -9e0123"#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((1, Token::Subtract, 2)),
            Ok((2, Token::Number("9", "0123"), 8)),
        )
    );

    let mut errors = Vec::new();
    let tokens = Lexer::new(r#" -9e"#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(tokens, vec!(Ok((1, Token::Subtract, 2)),));
    assert_eq!(
        errors,
        vec!(LexicalError::MissingExponent(Loc::File(0, 2, 4)))
    );

    let mut errors = Vec::new();
    let tokens = Lexer::new(r#"9ea"#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(tokens, vec!(Ok((2, Token::Identifier("a"), 3))));
    assert_eq!(
        errors,
        vec!(LexicalError::MissingExponent(Loc::File(0, 0, 3)))
    );

    let mut errors = Vec::new();
    let tokens = Lexer::new(r#"42.a"#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Number("42", ""), 2)),
            Ok((2, Token::Member, 3)),
            Ok((3, Token::Identifier("a"), 4))
        )
    );

    let tokens = Lexer::new(r#"42..a"#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();

    assert_eq!(
        tokens,
        vec!(
            Ok((0, Token::Number("42", ""), 2)),
            Ok((2, Token::Member, 3)),
            Ok((3, Token::Member, 4)),
            Ok((4, Token::Identifier("a"), 5))
        )
    );

    let mut errors = Vec::new();
    let _ = Lexer::new(r#"hex"g""#, 0, &mut comments, &mut errors)
        .collect::<Vec<Result<(usize, Token, usize), LexicalError>>>();
    assert_eq!(
        errors,
        vec!(LexicalError::InvalidCharacterInHexLiteral(
            Loc::File(0, 4, 5),
            'g'
        ),)
    );
}
