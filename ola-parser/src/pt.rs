use lalrpop_util::ParseError;
use super::pt::*;
use super::lexer::{Token, LexicalError};
use lalrpop_util::ErrorRecovery;
grammar<'input, 'err>(input: &'input str, file_no: usize , parser_errors: &'err mut Vec<ErrorRecovery<usize, Token<'input>, LexicalError>> );


pub SourceUnitPart: SourceUnitPart = {
    ContractDefinition => SourceUnitPart::ContractDefinition(<>),
    ImportDirective => <>,
}

ImportDirective: SourceUnitPart = {
    <l:@L> "import" <s:StringLiteral> <r:@R> ";" => SourceUnitPart::ImportDirective(Import::Plain(s, Loc::File(file_no, l, r))),
    // TODO: global modify
    <l:@L> "import" <s:StringLiteral> "as" <id:Identifier> <r:@R> ";" => SourceUnitPart::ImportDirective(Import::GlobalSymbol(s, id, Loc::File(file_no, l, r))),
}

Type: Type = {
    "bool" => Type::Bool,
    // TODO 
    "field" => Type::Field,
    Uint => Type::Uint(<>)
}

Identifier: Identifier = {
    <l:@L> <n:identifier> <r:@R> => Identifier{loc: Loc::File(file_no, l, r), name: n.to_string()}
}

IdentifierOrError: Option<Identifier> = {
    Identifier => Some(<>),
    ! => {
        parser_errors.push(<>);
        None
    }
}

VariableDeclaration: VariableDeclaration = {
    <l:@L> <ty:Precedence0>  <name:IdentifierOrError> <r:@R> => VariableDeclaration {
        loc: Loc::File(file_no, l, r), ty, storage, name
    },
}

StructDefinition: Box<StructDefinition> = {
    <l:@L> "struct" <name:IdentifierOrError> "{" <fields:(<VariableDeclaration> ";")*> "}" <r:@R> => {
        Box::new(StructDefinition{loc: Loc::File(file_no, l, r), name, fields})
    }
}

ContractPart: ContractPart = {
    StructDefinition => ContractPart::StructDefinition(<>),
    EnumDefinition => ContractPart::EnumDefinition(<>),
    VariableDefinition => ContractPart::VariableDefinition(<>),
    FunctionDefinition => ContractPart::FunctionDefinition(<>),
    TypeDefinition => ContractPart::TypeDefinition(<>),
}

ContractDefinition: Box<ContractDefinition> = {
    <l:@L> "contract" <name:IdentifierOrError> 
    "{" <parts:(<ContractPart>)*> "}" <r:@R> => {
       // TODO; rm ty base
        Box::new(ContractDefinition{loc: Loc::File(file_no, l, r), ty, name, base, parts})
    }
}


EnumDefinition: Box<EnumDefinition> = {
    <l:@L> "enum" <name:IdentifierOrError> "{" <values:Comma<IdentifierOrError>> "}" <r:@R> => {
        Box::new(EnumDefinition{loc: Loc::File(file_no, l, r), name, values})
    }
}

VariableDefinition: Box<VariableDefinition> = {
    // add mut
    <l:@L> <ty:Precedence0>  <name:IdentifierOrError> <e:("=" <Expression>)?> <r:@R> ";" => {
        Box::new(VariableDefinition{
            loc: Loc::File(file_no, l, r), ty, attrs, name, initializer: e,
        })
    },
    <l:@L> <ty:Precedence0> <name:Identifier> <false_token:!> <r:@R> ";" => {
        parser_errors.push (false_token);
        Box::new(VariableDefinition{
            loc: Loc::File(file_no, l, r), ty, attrs, name: Some(name), initializer: None,
        })
    }
}

TypeDefinition: Box<TypeDefinition> = {
    <l:@L> "type" <name:Identifier> "=" <ty:Precedence0> <r:@R> ";" => {
        Box::new(TypeDefinition{
            loc: Loc::File(file_no, l, r), name, ty
        })
    },
}


Expression: Expression = {
    Precedence14,
}

Precedence14: Expression = {
    <a:@L> <l:Precedence13> "=" <r:Precedence14> <b:@R> => Expression::Assign(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "|=" <r:Precedence14> <b:@R> => Expression::AssignOr(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "^=" <r:Precedence14> <b:@R> => Expression::AssignXor(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "&=" <r:Precedence14> <b:@R> => Expression::AssignAnd(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "<<=" <r:Precedence14> <b:@R> => Expression::AssignShiftLeft(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> ">>=" <r:Precedence14> <b:@R> => Expression::AssignShiftRight(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "+=" <r:Precedence14> <b:@R> => Expression::AssignAdd(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "-=" <r:Precedence14> <b:@R> => Expression::AssignSubtract(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "*=" <r:Precedence14> <b:@R> => Expression::AssignMultiply(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "/=" <r:Precedence14> <b:@R> => Expression::AssignDivide(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence13> "%=" <r:Precedence14> <b:@R> => Expression::AssignModulo(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <c:Precedence13> "?" <l:Precedence14> ":" <r:Precedence14> <b:@R> => {
        Expression::ConditionalOperator(Loc::File(file_no, a, b), Box::new(c), Box::new(l), Box::new(r))
    },
    Precedence13,
}

Precedence13: Expression = {
    <a:@L> <l:Precedence13> "||" <r:Precedence12> <b:@R> => Expression::Or(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence12,
}

Precedence12: Expression = {
    <a:@L> <l:Precedence12> "&&" <r:Precedence11> <b:@R> => Expression::And(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence11,
}

Precedence11: Expression = {
    <a:@L> <l:Precedence11> "==" <r:Precedence10> <b:@R> => Expression::Equal(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence11> "!=" <r:Precedence10> <b:@R> => Expression::NotEqual(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence10,
}

Precedence10: Expression = {
    <a:@L> <l:Precedence10> "<" <r:Precedence9> <b:@R> => Expression::Less(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence10> ">" <r:Precedence9> <b:@R> => Expression::More(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence10> "<=" <r:Precedence9> <b:@R> => Expression::LessEqual(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence10> ">=" <r:Precedence9> <b:@R> => Expression::MoreEqual(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence9,
}

Precedence9: Expression = {
    <a:@L> <l:Precedence9> "|" <r:Precedence8> <b:@R> => Expression::BitwiseOr(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence8,
}

Precedence8: Expression = {
    <a:@L> <l:Precedence8> "^" <r:Precedence7> <b:@R> => Expression::BitwiseXor(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence7,
}

Precedence7: Expression = {
    <a:@L> <l:Precedence7> "&" <r:Precedence6> <b:@R> => Expression::BitwiseAnd(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence6,
}

Precedence6: Expression = {
    <a:@L> <l:Precedence6> "<<" <r:Precedence5> <b:@R> => Expression::ShiftLeft(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence6> ">>" <r:Precedence5> <b:@R> => Expression::ShiftRight(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence5,
}

Precedence5: Expression = {
    <a:@L> <l:Precedence5> "+" <r:Precedence4> <b:@R> => Expression::Add(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence5> "-" <r:Precedence4> <b:@R> => Expression::Subtract(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence4,
}

Precedence4: Expression = {
    <a:@L> <l:Precedence4> "*" <r:Precedence3> <b:@R> => Expression::Multiply(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence4> "/" <r:Precedence3> <b:@R> => Expression::Divide(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    <a:@L> <l:Precedence4> "%" <r:Precedence3> <b:@R> => Expression::Modulo(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence3,
}

Precedence3: Expression = {
    <a:@L> <l:Precedence2> "**" <r:Precedence3> <b:@R> => Expression::Power(Loc::File(file_no, a, b), Box::new(l), Box::new(r)),
    Precedence2,
}

Precedence2: Expression = {
    <a:@L> "!" <e:Precedence2> <b:@R> => Expression::Not(Loc::File(file_no, a, b), Box::new(e)),
    <a:@L> "~" <e:Precedence2> <b:@R> => Expression::Complement(Loc::File(file_no, a, b), Box::new(e)),
    Precedence0,
}

NamedArgument: NamedArgument = {
    <l:@L> <name:SolIdentifier> ":" <expr:Expression> <r:@R> => {
        NamedArgument{ loc: Loc::File(file_no, l, r), name, expr }
    }
}

FunctionCall: Expression = {
    <a:@L> <i:Precedence0> "(" <v:Comma<Expression>> ")" <b:@R> => {
        Expression::FunctionCall(Loc::File(file_no, a, b), Box::new(i), v)
    },
    <a:@L> <i:FunctionCallPrecedence> "(" "{" <v:Comma<NamedArgument>> "}" ")" <b:@R> => {
        Expression::NamedFunctionCall(Loc::File(file_no, a, b), Box::new(i), v)
    },
}

Precedence0: Expression = {
    <a:@L> <e:Precedence0> "++" <b:@R> => Expression::Increment(Loc::File(file_no, a, b), Box::new(e)),
    <a:@L> <e:Precedence0> "--" <b:@R> => Expression::Decrement(Loc::File(file_no, a, b), Box::new(e)),
    <FunctionCall> => <>,
    <a:@L> <e:Precedence0> "[" <i:Expression?> "]" <b:@R> => Expression::ArraySubscript(Loc::File(file_no, a, b), Box::new(e), i.map(Box::new)),
    <a:@L> <e:Precedence0> "[" <l:Expression?> ":" <r:Expression?> "]" <b:@R> => Expression::ArraySlice(Loc::File(file_no, a, b), Box::new(e), l.map(Box::new), r.map(Box::new)),
    <a:@L> <e:Precedence0> "." <i:Identifier> <b:@R> => Expression::MemberAccess(Loc::File(file_no, a, b), Box::new(e), i),
    <l:@L> <ty:Type> <r:@R> => Expression::Type(Loc::File(file_no, l, r), ty),
    <a:@L> "[" <v:CommaOne<Expression>> "]" <b:@R> => {
        Expression::ArrayLiteral(Loc::File(file_no, a, b), v)
    },
    <Identifier> => Expression::Variable(<>),
    <l:@L> <a:ParameterList> <r:@R> => {
        if a.len() == 1 {
            if let Some(Parameter{ ty, storage: None, name: None, .. }) = &a[0].1 {
                // this means "(" Expression ")"
                return Expression::Parenthesis(ty.loc(), Box::new(ty.clone()));
            }
        }

        Expression::List(Loc::File(file_no, l, r), a)
    },
    LiteralExpression
}

LiteralExpression: Expression = {
    <a:@L> "true" <b:@R> => Expression::BoolLiteral(Loc::File(file_no, a, b), true),
    <a:@L> "false" <b:@R> => Expression::BoolLiteral(Loc::File(file_no, a, b), false),
    <l:@L> <n:number> <r:@R> => {
        let integer: String = n.0.chars().filter(|v| *v != '_').collect();
         // remove exp
        Expression::NumberLiteral(Loc::File(file_no, l, r), integer, exp)
    },
    <l:@L> <n:hexnumber> <r:@R> => {
        Expression::HexNumberLiteral(Loc::File(file_no, l, r), n.to_owned())
    }
}

StringLiteral: StringLiteral = {
    <l:@L> <s:string> <r:@R> => {
        StringLiteral{ loc: Loc::File(file_no, l, r), unicode: s.0, string: s.1.to_string() }
    }
}

// A parameter list is used for function arguments, returns, and destructuring statements.
// In destructuring statements, parameters can be optional. So, we make parameters optional
// and as an added bonus we can generate error messages about missing parameters/returns
// to functions
Parameter: Parameter = {
    <l:@L> <ty:Expression> <name:Identifier?> <r:@R> => {
        let loc = Loc::File(file_no, l, r);
        Parameter{loc, ty, storage, name}
    }
}

OptParameter: (Loc, Option<Parameter>) = {
    <l:@L> <p:Parameter?> <r:@R> => (Loc::File(file_no, l, r), p),
}

ParameterList: Vec<(Loc, Option<Parameter>)> = {
    "(" ")" => Vec::new(),
    "(" <l:@L> <p:Parameter> <r:@R> ")" => vec!((Loc::File(file_no, l, r), Some(p))),
    "(" <CommaTwo<OptParameter>> ")" => <>,
    "(" <false_token:!> ")"=> {
        parser_errors.push(<>);
        Vec::new()
    }
}

returns: Option<Loc> = {
    "returns" => None,
    <l:@L> "return" <r:@R> => Some(Loc::File(file_no, l, r)),
}

FunctionDefinition: Box<FunctionDefinition> = {
    <l:@L> "fn" <nl:@L> <name:IdentifierOrError> <nr:@R> <params:ParameterList>
    <returns:(returns ParameterList)?> <r:@R> <body:BlockStatement> => {
        let (return_not_returns, returns) = returns.unwrap_or((None, Vec::new()));

        Box::new(FunctionDefinition{
            loc: Loc::File(file_no, l, r),
            ty: FunctionTy::Function,
            name,
            name_loc: Loc::File(file_no, nl, nr),
            params,
            attributes,
            return_not_returns,
            returns,
            body,
        })
    }
}


BlockStatement: Statement = {
    <l:@L> "{" <statements:Statement*> "}" <r:@R> => {
        Statement::Block { loc: Loc::File(file_no, l, r), statements }
    }
}

OpenStatement: Statement = {
    <l:@L> "if" "(" <cond:Expression> ")" <body:Statement> <r:@R> => {
        Statement::If(Loc::File(file_no, l, r), cond, Box::new(body), None)
    },
    <l:@L> "if" "(" <cond:Expression> ")" <body:ClosedStatement> "else" <o:OpenStatement> <r:@R> => {
        Statement::If(Loc::File(file_no, l, r), cond, Box::new(body), Some(Box::new(o)))
    },
    <l:@L> "for" "(" <b:SimpleStatement?> ";" <c:Expression?> ";" <n:SimpleStatement?> ")" <block:OpenStatement> <r:@R> => {
        Statement::For(Loc::File(file_no, l, r), b.map(Box::new), c.map(Box::new), n.map(Box::new), Some(Box::new(block)))
    },
}

ClosedStatement: Statement = {
    NonIfStatement,
    <l:@L> "if" "(" <cond:Expression> ")" <body:ClosedStatement> "else" <o:ClosedStatement> <r:@R> => {
        Statement::If(Loc::File(file_no, l, r), cond, Box::new(body), Some(Box::new(o)))
    },
    <l:@L> "for" "(" <b:SimpleStatement?> ";" <c:Expression?> ";" <n:SimpleStatement?> ")" <block:ClosedStatement> <r:@R> => {
        Statement::For(Loc::File(file_no, l, r), b.map(Box::new), c.map(Box::new), n.map(Box::new), Some(Box::new(block)))
    },
    <l:@L> "for" "(" <b:SimpleStatement?> ";" <c:Expression?> ";" <n:SimpleStatement?> ")" <r:@R> ";" => {
        Statement::For(Loc::File(file_no, l, r), b.map(Box::new), c.map(Box::new), n.map(Box::new), None)
    }
}

Statement: Statement = {
    OpenStatement,
    ClosedStatement,
    <l:@L> <false_token:!> <r:@R> => {
        parser_errors.push(false_token);
        Statement::Error(Loc::File(file_no, l, r))
    },
}

SimpleStatement: Statement = {
    <l:@L> <v:VariableDeclaration> <e:("=" <Expression>)?> <r:@R> => {
        Statement::VariableDefinition(Loc::File(file_no, l, r), v, e)
    },
    <l:@L> <e:Expression> <r:@R> => {
        Statement::Expression(Loc::File(file_no, l, r), e)
    }
}

NonIfStatement: Statement = {
    BlockStatement => <>,
    <SimpleStatement> ";" => <>,
    <l:@L> "continue" <r:@R> ";" => {
        Statement::Continue(Loc::File(file_no, l, r))
    },
    <l:@L> "break" <r:@R> ";" => {
        Statement::Break(Loc::File(file_no, l, r))
    },
    <l:@L> "return" <r:@R> ";" => {
        Statement::Return(Loc::File(file_no, l, r), None)
    },
    <l:@L> "return" <e:Expression> <r:@R> ";" => {
        Statement::Return(Loc::File(file_no, l, r), Some(e))
    }
}


Comma<T>: Vec<T> = {
    => Vec::new(),
    CommaOne<T> => <>,
};

CommaOne<T>: Vec<T> = {
    <e:T> <v:("," <T>)*> => {
        let mut v = v;
        v.insert(0, e);
        v
    }
};

CommaTwo<T>: Vec<T> = {
    <e:T> <v:("," <T>)+> => {
        let mut v = v;
        v.insert(0, e);
        v
    }
};

extern {
    type Location = usize;
    type Error = LexicalError;

    enum Token<'input> {
        identifier => Token::Identifier(<&'input str>),
        string => Token::StringLiteral(<&'input str>),
        number => Token::Number(<&'input str>, <&'input str>),
        hexnumber => Token::HexNumber(<&'input str>),
        Uint => Token::Uint(<u16>),
        ";" => Token::Semicolon,
        "{" => Token::OpenCurlyBrace,
        "}" => Token::CloseCurlyBrace,
        "(" => Token::OpenParenthesis,
        ")" => Token::CloseParenthesis,
        "=" => Token::Assign,
        "==" => Token::Equal,
        "|=" => Token::BitwiseOrAssign,
        "^=" => Token::BitwiseXorAssign,
        "&=" => Token::BitwiseAndAssign,
        "<<=" => Token::ShiftLeftAssign,
        ">>=" => Token::ShiftRightAssign,
        "+=" => Token::AddAssign,
        "-=" => Token::SubtractAssign,
        "*=" => Token::MulAssign,
        "/=" => Token::DivideAssign,
        "%=" => Token::ModuloAssign,
        "?" => Token::Question,
        ":" => Token::Colon,
        ":=" => Token::ColonAssign,
        "||" => Token::Or,
        "&&" => Token::And,
        "!=" => Token::NotEqual,
        "<" => Token::Less,
        "<=" => Token::LessEqual,
        ">" => Token::More,
        ">=" => Token::MoreEqual,
        "|" => Token::BitwiseOr,
        "&" => Token::BitwiseAnd,
        "^" => Token::BitwiseXor,
        "<<" => Token::ShiftLeft,
        ">>" => Token::ShiftRight,
        "+" => Token::Add,
        "-" => Token::Subtract,
        "*" => Token::Mul,
        "/" => Token::Divide,
        "%" => Token::Modulo,
        "**" => Token::Power,
        "!" => Token::Not,
        "~" => Token::Complement,
        "++" => Token::Increment,
        "--" => Token::Decrement,
        "[" => Token::OpenBracket,
        "]" => Token::CloseBracket,
        "." => Token::Member,
        "," => Token::Comma,
        "struct" => Token::Struct,
        "import" => Token::Import,
        "contract" => Token::Contract,
        "bool" => Token::Bool,
        "address" => Token::Address,
        "enum" => Token::Enum,
        "type" => Token::Type,
        "const" => Token::Constant,
        "true" => Token::True,
        "false" => Token::False,
        "fn" => Token::Function,
        "->" => Token::Returns,
        "return" => Token::Return,
        "if" => Token::If,
        "for" => Token::For,
        "else" => Token::Else,
        "continue" => Token::Continue,
        "break" => Token::Break,
	"field" => Token::Field;
        "as" => Token::As,
        "is" => Token::Is,
        "mut" => Token::Mutable,
    }
}