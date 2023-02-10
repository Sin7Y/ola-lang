// SPDX-License-Identifier: Apache-2.0

//! ola file parser

pub mod diagnostics;
pub mod program;
use diagnostics::Diagnostic;
use lalrpop_util::{lexer::Token, ParseError};
use program::Loc;
#[cfg(test)]
mod test;

#[allow(clippy::all)]
mod ola {
    include!(concat!(env!("OUT_DIR"), "/ola.rs"));
}

/// Parse Ola file
pub fn parse(src: &str, file_no: usize) -> Result<program::SourceUnit, Vec<Diagnostic>> {
    let parser_errors = &mut Vec::new();
    let errors = &mut Vec::new();

    let s = ola::SourceUnitParser::new().parse(file_no, parser_errors, src);

    for e in parser_errors {
        errors.push(parser_error(&e.error, file_no));
    }

    if let Err(e) = s {
        errors.push(parser_error(&e, file_no));
        return Err(errors.to_vec());
    }

    if !errors.is_empty() {
        Err(errors.to_vec())
    } else {
        Ok(s.unwrap())
    }
}

fn parser_error(error: &ParseError<usize, Token, &str>, file_no: usize) -> Diagnostic {
    match &error {
        ParseError::InvalidToken { location } => Diagnostic::parser_error(
            Loc::File(file_no, *location, *location),
            "invalid token".to_string(),
        ),
        ParseError::UnrecognizedToken {
            token: (l, token, r),
            expected,
        } => Diagnostic::parser_error(
            Loc::File(file_no, *l, *r),
            format!(
                "unrecognised token '{}', expected {}",
                token,
                expected.join(", ")
            ),
        ),
        ParseError::User { error } => {
            Diagnostic::parser_error(Loc::File(file_no, 0, 0), error.to_string())
        }
        ParseError::ExtraToken { token } => Diagnostic::parser_error(
            Loc::File(file_no, token.0, token.2),
            format!("extra token '{}' encountered", token.0),
        ),
        ParseError::UnrecognizedEOF { expected, location } => Diagnostic::parser_error(
            Loc::File(file_no, *location, *location),
            format!("unexpected end of file, expecting {}", expected.join(", ")),
        ),
    }
}
