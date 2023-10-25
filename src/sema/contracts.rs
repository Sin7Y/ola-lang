// SPDX-License-Identifier: Apache-2.0

use crate::irgen;
use num_bigint::BigInt;
use num_traits::Zero;
use ola_parser::program::{self};
use std::collections::BTreeMap;
use std::convert::TryInto;
use tiny_keccak::{Hasher, Keccak};

use super::{ast, functions, statements, variables};

use crate::sema::unused_variable::emit_warning_local_variable;

impl ast::Contract {
    /// Create a new contract, abstract contract, interface or library
    pub fn new(name: &str, loc: program::Loc) -> Self {
        ast::Contract {
            loc,
            name: name.to_owned(),
            functions: Vec::new(),
            all_functions: BTreeMap::new(),
            variables: Vec::new(),
            initializer: None,
            code: Vec::new(),
            dispatch_no: 0,
            layout: Vec::new(),
            fixed_layout_size: BigInt::zero(),
        }
    }

    /// Generate contract code for this contract
    pub fn emit<'a>(
        &'a self,
        ns: &'a ast::Namespace,
        context: &'a inkwell::context::Context,
        filename: &'a str,
    ) -> irgen::binary::Binary {
        irgen::binary::Binary::build(context, self, ns, filename)
    }

    /// Selector for this contract. This is used by Solana contract bundle
    pub fn selector(&self) -> u32 {
        let mut hasher = Keccak::v256();
        let mut hash = [0u8; 32];
        hasher.update(self.name.as_bytes());
        hasher.finalize(&mut hash);

        u32::from_be_bytes(hash[0..4].try_into().unwrap())
    }
}

/// Resolve the following contract
pub fn resolve(
    contracts: &[(usize, &program::ContractDefinition)],
    file_no: usize,
    ns: &mut ast::Namespace,
) {
    // we need to resolve declarations first, so we call functions/constructors of
    // contracts before they are declared
    let mut delayed: ResolveLater = Default::default();

    for (contract_no, def) in contracts {
        resolve_declarations(def, file_no, *contract_no, ns, &mut delayed);
    }

    // Now we have all the declarations, we can add all functions
    for (contract_no, _) in contracts {
        for function_no in ns.contracts[*contract_no].functions.clone() {
            ns.contracts[*contract_no]
                .all_functions
                .insert(function_no, usize::MAX);
        }
    }

    // Now we can resolve the initializers
    variables::resolve_initializers(&delayed.initializers, file_no, ns);

    // Now we can resolve the bodies
    resolve_bodies(delayed.function_bodies, file_no, ns);
}

/// Function body which should be resolved.
/// List of function_no, contract_no, and function parse tree
struct DelayedResolveFunction<'a> {
    function_no: usize,
    contract_no: usize,
    function: &'a program::FunctionDefinition,
}

#[derive(Default)]

/// Function bodies and state variable initializers can only be resolved once
/// all function prototypes, bases contracts and state variables are resolved.
struct ResolveLater<'a> {
    function_bodies: Vec<DelayedResolveFunction<'a>>,
    initializers: Vec<variables::DelayedResolveInitializer<'a>>,
}

/// Resolve functions declarations, constructor declarations, and contract
/// variables This returns a list of function bodies to resolve
fn resolve_declarations<'a>(
    def: &'a program::ContractDefinition,
    file_no: usize,
    contract_no: usize,
    ns: &mut ast::Namespace,
    delayed: &mut ResolveLater<'a>,
) {
    ns.diagnostics.push(ast::Diagnostic::debug(
        def.loc,
        format!("found {} ", def.name.as_ref().unwrap().name),
    ));

    let mut function_no_bodies = Vec::new();

    // resolve state variables. We may need a constant to resolve the array
    // dimension of a function argument.
    delayed
        .initializers
        .extend(variables::contract_variables(def, file_no, contract_no, ns));

    for part in &def.parts {
        if let program::ContractPart::FunctionDefinition(ref f) = part {
            if let Some(function_no) = functions::contract_function(f, file_no, contract_no, ns) {
                if f.body.is_some() {
                    delayed.function_bodies.push(DelayedResolveFunction {
                        contract_no,
                        function_no,
                        function: f.as_ref(),
                    });
                } else {
                    function_no_bodies.push(function_no);
                }
            }
        }
    }

    if !function_no_bodies.is_empty() {
        let notes = function_no_bodies
            .into_iter()
            .map(|function_no| ast::Note {
                loc: ns.functions[function_no].loc,
                message: format!(
                    "location of function '{}' with no body",
                    ns.functions[function_no].name
                ),
            })
            .collect::<Vec<ast::Note>>();

        ns.diagnostics.push(ast::Diagnostic::error_with_notes(
                    def.loc,
                    format!(
                        "contract should be marked 'abstract contract' since it has {} functions with no body",
                        notes.len()
                    ),
                    notes,
                ));
    }
}

/// Resolve contract functions bodies
fn resolve_bodies(
    bodies: Vec<DelayedResolveFunction>,
    file_no: usize,
    ns: &mut ast::Namespace,
) -> bool {
    let mut broken = false;

    for DelayedResolveFunction {
        contract_no,
        function_no,
        function,
    } in bodies
    {
        if statements::resolve_function_body(function, file_no, Some(contract_no), function_no, ns)
            .is_err()
        {
            broken = true;
        } else if !ns.diagnostics.any_errors() {
            for variable in ns.functions[function_no].symtable.vars.values() {
                if let Some(warning) = emit_warning_local_variable(variable, ns) {
                    ns.diagnostics.push(warning);
                }
            }
        }
    }

    broken
}
