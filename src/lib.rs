// SPDX-License-Identifier: Apache-2.0

extern crate core;

#[cfg(feature = "llvm")]
pub mod irgen;

pub mod file_resolver;

pub mod standard_json;

// In Sema, we use result unit for returning early
// when code-misparses. The error will be added to the namespace diagnostics, no need to have anything but unit
// as error.
#[allow(clippy::result_unit_err)]
pub mod sema;

use file_resolver::FileResolver;
use ola_parser::program;
use sema::diagnostics;
use std::ffi::OsStr;

/// Parse and resolve the Solidity source code provided in src, for the target chain as specified in target.
/// The result is a list of resolved contracts (if successful) and a list of compiler warnings, errors and
/// informational messages like `found contact N`.
///
/// Note that multiple contracts can be specified in on solidity source file.
pub fn parse_and_resolve(filename: &OsStr, resolver: &mut FileResolver) -> sema::ast::Namespace {
    let mut ns = sema::ast::Namespace::new();

    match resolver.resolve_file(None, filename) {
        Err(message) => {
            ns.diagnostics.push(sema::ast::Diagnostic {
                ty: sema::ast::ErrorType::ParserError,
                level: sema::ast::Level::Error,
                message,
                loc: program::Loc::CommandLine,
                notes: Vec::new(),
            });
        }
        Ok(file) => {
            sema::sema(&file, resolver, &mut ns);
        }
    }

    ns.diagnostics.sort_and_dedup();

    ns
}
