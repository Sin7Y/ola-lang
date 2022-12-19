// SPDX-License-Identifier: Apache-2.0

extern crate core;

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
use std::{ffi::OsStr, fmt};

/// Compile a solidity file to list of wasm files and their ABIs. The filename is only used for error messages;
/// the contents of the file is provided in the `src` argument.
///
/// This function only produces a single contract and abi, which is compiled for the `target` specified. Any
/// compiler warnings, errors and informational messages are also provided.
///
/// The ctx is the inkwell llvm context.
#[cfg(feature = "llvm")]
pub fn compile(
    filename: &OsStr,
    resolver: &mut FileResolver,
    opt_level: inkwell::OptimizationLevel,
    target: Target,
    math_overflow_check: bool,
    log_api_return_codes: bool,
) -> (Vec<(Vec<u8>, String)>, sema::ast::Namespace) {
    let mut ns = parse_and_resolve(filename, resolver, target);

    if ns.diagnostics.any_errors() {
        return (Vec::new(), ns);
    }

    // codegen all the contracts
    codegen::codegen(
        &mut ns,
        &codegen::Options {
            math_overflow_check,
            log_api_return_codes,
            opt_level: opt_level.into(),
            ..Default::default()
        },
    );

    let results = (0..ns.contracts.len())
        .filter(|c| ns.contracts[*c].instantiable)
        .map(|c| {
            // codegen has already happened
            assert!(!ns.contracts[c].code.is_empty());

            let code = &ns.contracts[c].code;
            let (abistr, _) = abi::generate_abi(c, &ns, code, false);

            (code.clone(), abistr)
        })
        .collect();

    (results, ns)
}

/// Build a single binary out of multiple contracts. This is only possible on Solana
#[cfg(feature = "llvm")]
pub fn compile_many<'a>(
    context: &'a inkwell::context::Context,
    namespaces: &'a [&sema::ast::Namespace],
    filename: &str,
    opt: inkwell::OptimizationLevel,
    math_overflow_check: bool,
    generate_debug_info: bool,
    log_api_return_codes: bool,
) -> emit::binary::Binary<'a> {
    emit::binary::Binary::build_bundle(
        context,
        namespaces,
        filename,
        opt,
        math_overflow_check,
        generate_debug_info,
        log_api_return_codes,
    )
}

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
