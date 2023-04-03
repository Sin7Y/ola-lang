#![feature(let_chains)]
// SPDX-License-Identifier: Apache-2.0

extern crate core;

pub mod irgen;

pub mod codegen;

pub mod file_resolver;

pub mod standard_json;

pub mod sema;

use file_resolver::FileResolver;
use ola_parser::program;
use sema::diagnostics;
use std::ffi::OsStr;

/// Parse and resolve the Ola source code provided in src, for the target chain
/// as specified in target. The result is a list of resolved contracts (if
/// successful) and a list of compiler warnings, errors and informational
/// messages like `found contact N`.
///
/// Note that multiple contracts can be specified in on ola source file.
pub fn parse_and_resolve(filename: &OsStr, resolver: &mut FileResolver) -> sema::ast::Namespace {
    let mut ns = sema::ast::Namespace::default();

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
