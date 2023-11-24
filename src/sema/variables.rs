// SPDX-License-Identifier: Apache-2.0

use super::{
    ast::{Diagnostic, Namespace, Symbol, Variable},
    diagnostics::Diagnostics,
    expression::{ExprContext, ResolveTo},
    symtable::Symtable,
};
use crate::sema::eval::check_term_for_constant_overflow;
use crate::sema::expression::resolve_expression::expression;
use crate::sema::Recurse;
use ola_parser::program::{self, CodeLocation};

pub struct DelayedResolveInitializer<'a> {
    var_no: usize,
    contract_no: usize,
    initializer: &'a program::Expression,
}

pub fn contract_variables<'a>(
    def: &'a program::ContractDefinition,
    file_no: usize,
    contract_no: usize,
    ns: &mut Namespace,
) -> Vec<DelayedResolveInitializer<'a>> {
    let mut symtable = Symtable::new();
    let mut delayed = Vec::new();

    for part in &def.parts {
        if let program::ContractPart::VariableDefinition(ref s) = &part {
            if let Some(delay) = variable_decl(s, file_no, Some(contract_no), ns, &mut symtable) {
                delayed.push(delay);
            }
        }
    }

    delayed
}

pub fn variable_decl<'a>(
    def: &'a program::VariableDefinition,
    file_no: usize,
    contract_no: Option<usize>,
    ns: &mut Namespace,
    symtable: &mut Symtable,
) -> Option<DelayedResolveInitializer<'a>> {
    let attrs = def.attrs.clone();
    let ty = def.ty.clone();
    let mut ret = None;

    let mut diagnostics = Diagnostics::default();

    let ty = match ns.resolve_type(file_no, contract_no, &ty, &mut diagnostics) {
        Ok(s) => s,
        Err(()) => {
            ns.diagnostics.extend(diagnostics);
            return None;
        }
    };

    let mut constant = false;

    for attr in attrs {
        if let program::VariableAttribute::Constant(loc) = &attr {
            if constant {
                ns.diagnostics.push(Diagnostic::error(
                    *loc,
                    "duplicate constant attribute".to_string(),
                ));
            }
            constant = true;
        }
    }

    let initializer = if constant {
        if let Some(initializer) = &def.initializer {
            let mut diagnostics = Diagnostics::default();
            let context = ExprContext {
                file_no,
                contract_no,
                function_no: None,
                constant,
                lvalue: false,
            };
            match expression(
                initializer,
                &context,
                ns,
                symtable,
                &mut diagnostics,
                ResolveTo::Type(&ty),
            ) {
                Ok(res) => {
                    // implicitly conversion to correct ty
                    match res.cast(&def.loc, &ty, ns, &mut diagnostics) {
                        Ok(res) => {
                            res.recurse(ns, check_term_for_constant_overflow);
                            Some(res)
                        }
                        Err(_) => {
                            ns.diagnostics.extend(diagnostics);
                            None
                        }
                    }
                }
                Err(()) => {
                    ns.diagnostics.extend(diagnostics);
                    None
                }
            }
        } else {
            ns.diagnostics.push(Diagnostic::decl_error(
                def.loc,
                "missing initializer for constant".to_string(),
            ));

            None
        }
    } else {
        None
    };

    let sdecl = Variable {
        name: def.name.as_ref().unwrap().name.to_string(),
        loc: def.loc,
        ty: ty.clone(),
        constant,
        assigned: def.initializer.is_some(),
        initializer,
        read: true,
    };

    let var_no = if let Some(contract_no) = contract_no {
        let var_no = ns.contracts[contract_no].variables.len();

        ns.contracts[contract_no].variables.push(sdecl);

        if !constant {
            if let Some(initializer) = &def.initializer {
                ret = Some(DelayedResolveInitializer {
                    var_no,
                    contract_no,
                    initializer,
                });
            }
        }

        var_no
    } else {
        let var_no = ns.constants.len();

        ns.constants.push(sdecl);

        var_no
    };

    ns.add_symbol(
        file_no,
        contract_no,
        def.name.as_ref().unwrap(),
        Symbol::Variable(def.loc, contract_no, var_no),
    );

    ret
}

pub fn resolve_initializers(
    initializers: &[DelayedResolveInitializer],
    file_no: usize,
    ns: &mut Namespace,
) {
    let mut symtable = Symtable::new();
    let mut diagnostics = Diagnostics::default();

    for DelayedResolveInitializer {
        var_no,
        contract_no,
        initializer,
    } in initializers
    {
        let var = &ns.contracts[*contract_no].variables[*var_no];
        let ty = var.ty.clone();

        let context = ExprContext {
            file_no,
            contract_no: Some(*contract_no),
            function_no: None,
            constant: false,
            lvalue: false,
        };

        if let Ok(res) = expression(
            initializer,
            &context,
            ns,
            &mut symtable,
            &mut diagnostics,
            ResolveTo::Type(&ty),
        ) {
            if let Ok(res) = res.cast(&initializer.loc(), &ty, ns, &mut diagnostics) {
                res.recurse(ns, check_term_for_constant_overflow);
                ns.contracts[*contract_no].variables[*var_no].initializer = Some(res);
            }
        }
    }

    ns.diagnostics.extend(diagnostics);
}
