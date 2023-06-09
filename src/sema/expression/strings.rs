// SPDX-License-Identifier: Apache-2.0

use crate::sema::diagnostics::Diagnostics;
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;

/// Unescape a string literal
pub(crate) fn unescape(
    literal: &str,
    start: usize,
    file_no: usize,
    diagnostics: &mut Diagnostics,
) -> Vec<u32> {
    let mut s: Vec<u32> = Vec::new();
    let mut indeces = literal.char_indices();

    while let Some((_, ch)) = indeces.next() {
        if ch != '\\' {
            s.push(ch as u32);
            continue;
        }

        match indeces.next() {
            Some((_, '\n')) => (),
            Some((_, '\\')) => s.push(b'\\' as u32),
            Some((_, '\'')) => s.push(b'\'' as u32),
            Some((_, '"')) => s.push(b'"' as u32),
            Some((_, 'b')) => s.push(b'\x08' as u32),
            Some((_, 'f')) => s.push(b'\x0c' as u32),
            Some((_, 'n')) => s.push(b'\n' as u32),
            Some((_, 'r')) => s.push(b'\r' as u32),
            Some((_, 't')) => s.push(b'\t' as u32),
            Some((_, 'v')) => s.push(b'\x0b' as u32),
            Some((i, 'x')) => match get_digits(&mut indeces, 2) {
                Ok(ch) => s.push(ch as u32),
                Err(offset) => {
                    diagnostics.push(Diagnostic::error(
                        program::Loc::File(
                            file_no,
                            start + i,
                            start + std::cmp::min(literal.len(), offset),
                        ),
                        "\\x escape should be followed by two hex digits".to_string(),
                    ));
                }
            },
            Some((i, 'u')) => match get_digits(&mut indeces, 4) {
                Ok(codepoint) => match char::from_u32(codepoint) {
                    Some(ch) => {
                        s.push(ch as u32);
                    }
                    None => {
                        diagnostics.push(Diagnostic::error(
                            program::Loc::File(file_no, start + i, start + i + 6),
                            "Found an invalid unicode character".to_string(),
                        ));
                    }
                },
                Err(offset) => {
                    diagnostics.push(Diagnostic::error(
                        program::Loc::File(
                            file_no,
                            start + i,
                            start + std::cmp::min(literal.len(), offset),
                        ),
                        "\\u escape should be followed by four hex digits".to_string(),
                    ));
                }
            },
            Some((i, ch)) => {
                diagnostics.push(Diagnostic::error(
                    program::Loc::File(file_no, start + i, start + i + ch.len_utf8()),
                    format!("unknown escape character '{ch}'"),
                ));
            }
            None => unreachable!(),
        }
    }
    s
}

/// Get the hex digits for an escaped \x or \u. Returns either the value or
/// or the offset of the last character
pub(super) fn get_digits(input: &mut std::str::CharIndices, len: usize) -> Result<u32, usize> {
    let mut n: u32 = 0;
    let offset;

    for _ in 0..len {
        if let Some((_, ch)) = input.next() {
            if let Some(v) = ch.to_digit(16) {
                n = (n << 4) + v;
                continue;
            }
            offset = match input.next() {
                Some((i, _)) => i,
                None => std::usize::MAX,
            };
        } else {
            offset = std::usize::MAX;
        }

        return Err(offset);
    }

    Ok(n)
}
