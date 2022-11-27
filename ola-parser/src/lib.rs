// SPDX-License-Identifier: Apache-2.0

//! ola file parser
use crate::program::Loc;
use diagnostics::Diagnostic;
use lalrpop_util::ParseError;

pub mod diagnostics;
pub mod program;
#[cfg(test)]
mod test;

#[allow(clippy::all)]
mod ola {
    include!(concat!(env!("OUT_DIR"), "/ola.rs"));
}

/// Parse ola file
pub fn parse(src: &str, file_no: usize) -> Result<program::SourceUnit, Diagnostic> {
    ola::SourceUnitParser::new()
    
        .parse(file_no, src)
        .map_err(|parse_error| match parse_error {
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
            ParseError::ExtraToken { token } => Diagnostic::parser_error(
                Loc::File(file_no, token.0, token.2),
                format!("extra token '{}' encountered", token.0),
            ),
            ParseError::UnrecognizedEOF { expected, location } => Diagnostic::parser_error(
                Loc::File(file_no, *location, *location),
                format!("unexpected end of file, expecting {}", expected.join(", ")),
            ),
            // _ => Diagnostic::parser_error(Loc::File(file_no, 0, 0), format!("{:?}", parse_error)),
            _ => panic!(),
        })
}
