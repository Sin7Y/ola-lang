// SPDX-License-Identifier: Apache-2.0

use crate::file_resolver::{FileResolver, ResolvedFile};
use crate::sema::unused_variable::check_unused_namespace_variables;
use num_bigint::BigInt;
use ola_parser::{parse, program};
use std::ffi::OsStr;

pub mod ast;
pub(crate) mod contracts;
pub mod corelib;
pub mod diagnostics;
mod dotgraphviz;
pub(crate) mod eval;
pub(crate) mod expression;
mod file;
mod functions;
mod namespace;
mod statements;
pub mod symtable;
mod tests;
mod types;
mod unused_variable;
mod variables;

pub type ArrayDimension = Option<(program::Loc, BigInt)>;

/// Load a file file from the cache, parse and resolve it. The file must be
/// present in the cache.
pub fn sema(file: &ResolvedFile, resolver: &mut FileResolver, ns: &mut ast::Namespace) {
    sema_file(file, resolver, ns);

    if !ns.diagnostics.any_errors() {
        // Checks for unused variables
        check_unused_namespace_variables(ns);
    }
}

/// Parse and resolve a file and its imports in a recursive manner.
fn sema_file(file: &ResolvedFile, resolver: &mut FileResolver, ns: &mut ast::Namespace) {
    let file_no = ns.files.len();

    let (source_code, file_cache_no) = resolver.get_file_contents_and_number(&file.full_path);

    ns.files.push(ast::File::new(
        file.full_path.clone(),
        &source_code,
        file_cache_no,
    ));

    let pt = match parse(&source_code, file_no) {
        Ok(s) => s,
        Err(mut errors) => {
            ns.diagnostics.append(&mut errors);

            return;
        }
    };

    // We need to iterate over the parsed contracts a few times, so create a
    // temporary vector This should be done before the contract types are
    // created so the contract type numbers line up
    let contracts_to_resolve =
        pt.0.iter()
            .filter_map(|part| {
                if let program::SourceUnitPart::ContractDefinition(def) = part {
                    Some(def)
                } else {
                    None
                }
            })
            .enumerate()
            .map(|(no, def)| (no + ns.contracts.len(), def.as_ref()))
            .collect::<Vec<(usize, &program::ContractDefinition)>>();

    // first resolve all the types we can find
    let fields = types::resolve_typenames(&pt, file_no, ns);

    // resolve pragmas and imports
    for part in &pt.0 {
        if let program::SourceUnitPart::ImportDirective(import) = part {
            resolve_import(import, Some(file), file_no, resolver, ns);
        }
    }

    // once all the types are resolved, we can resolve the structs and events. This
    // is because struct fields or event fields can have types defined
    // elsewhere.
    types::resolve_fields(fields, file_no, ns);

    // now resolve the contracts
    contracts::resolve(&contracts_to_resolve, file_no, ns);
}

/// Find import file, resolve it by calling sema and add it to the namespace
fn resolve_import(
    import: &program::Import,
    parent: Option<&ResolvedFile>,
    file_no: usize,
    resolver: &mut FileResolver,
    ns: &mut ast::Namespace,
) {
    let filename = match import {
        program::Import::Plain(f, _) => f,
        program::Import::GlobalSymbol(f, _, _) => f,
    };

    let os_filename = OsStr::new(&filename.string);

    let import_file_no = if let Some(builtin_file_no) = ns
        .files
        .iter()
        .position(|file| file.cache_no.is_none() && file.path == os_filename)
    {
        // import "solana"
        builtin_file_no
    } else {
        match resolver.resolve_file(parent, os_filename) {
            Err(message) => {
                ns.diagnostics
                    .push(ast::Diagnostic::error(filename.loc, message));

                return;
            }
            Ok(file) => {
                if !ns.files.iter().any(|f| f.path == file.full_path) {
                    sema_file(&file, resolver, ns);

                    // give up if we failed
                    if ns.diagnostics.any_errors() {
                        return;
                    }
                }

                ns.files
                    .iter()
                    .position(|f| f.path == file.full_path)
                    .expect("import should be loaded by now")
            }
        }
    };

    match import {
        program::Import::Plain(..) => {
            // find all the exports for the file
            let exports = ns
                .variable_symbols
                .iter()
                .filter_map(|((file_no, contract_no, id), symbol)| {
                    if *file_no == import_file_no {
                        Some((id.clone(), *contract_no, symbol.clone()))
                    } else {
                        None
                    }
                })
                .collect::<Vec<(String, Option<usize>, ast::Symbol)>>();

            for (name, contract_no, symbol) in exports {
                let new_symbol = program::Identifier {
                    name: name.clone(),
                    loc: filename.loc,
                };

                // Only add symbol if it does not already exist with same definition
                if let Some(existing) =
                    ns.variable_symbols
                        .get(&(file_no, contract_no, name.clone()))
                {
                    if existing == &symbol {
                        continue;
                    }
                }

                ns.add_symbol(file_no, contract_no, &new_symbol, symbol);
            }

            let exports = ns
                .function_symbols
                .iter()
                .filter_map(|((file_no, contract_no, id), symbol)| {
                    if *file_no == import_file_no && contract_no.is_none() {
                        Some((id.clone(), symbol.clone()))
                    } else {
                        None
                    }
                })
                .collect::<Vec<(String, ast::Symbol)>>();

            for (name, symbol) in exports {
                let new_symbol = program::Identifier {
                    name: name.clone(),
                    loc: filename.loc,
                };

                // Only add symbol if it does not already exist with same definition
                if let Some(existing) = ns.function_symbols.get(&(file_no, None, name.clone())) {
                    if existing == &symbol {
                        continue;
                    }
                }

                ns.add_symbol(file_no, None, &new_symbol, symbol);
            }
        }
        program::Import::GlobalSymbol(_, symbol, _) => {
            ns.add_symbol(
                file_no,
                None,
                symbol,
                ast::Symbol::Import(symbol.loc, import_file_no),
            );
        }
    }
}

pub trait Recurse {
    type ArgType;
    /// recurse over a structure
    fn recurse<T>(&self, cx: &mut T, f: fn(expr: &Self::ArgType, ctx: &mut T) -> bool);
}
