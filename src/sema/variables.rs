// SPDX-License-Identifier: Apache-2.0

use super::{
    ast::{
        Diagnostic, Expression, Function, Namespace, Parameter, Statement, Symbol,
        Type, Variable,
    },
    diagnostics::Diagnostics,
    expression::{expression, ExprContext, ResolveTo},
    symtable::Symtable,
    symtable::{VariableInitializer, VariableUsage},
};
use crate::sema::eval::check_term_for_constant_overflow;
use crate::sema::Recurse;
use ola_parser::{
    program::{self, CodeLocation, OptionalCodeLocation},
};
use ola_parser::program::VariableAttribute;

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
    let mut doc_comment_start = def.loc.start();

    for part in &def.parts {
        match part {
            program::ContractPart::VariableDefinition(ref s) => {

                if let Some(delay) = variable_decl(
                    Some(def),
                    s,
                    file_no,
                    Some(contract_no),
                    ns,
                    &mut symtable,
                ) {
                    delayed.push(delay);
                }
            }
            program::ContractPart::FunctionDefinition(f) => {
                if let Some(program::Statement::Block { loc, .. }) = &f.body {
                    doc_comment_start = loc.end();
                    continue;
                }
            }
            _ => (),
        }

        doc_comment_start = part.loc().end();
    }

    delayed
}

pub fn variable_decl<'a>(
    contract: Option<&program::ContractDefinition>,
    def: &'a program::VariableDefinition,
    file_no: usize,
    contract_no: Option<usize>,
    ns: &mut Namespace,
    symtable: &mut Symtable,
) -> Option<DelayedResolveInitializer<'a>> {
    let mut attrs = def.attrs.clone();
    let mut ty = def.ty.clone();
    let mut ret = None;


    let mut diagnostics = Diagnostics::default();

    let ty = match ns.resolve_type(file_no, contract_no, false, &ty, &mut diagnostics) {
        Ok(s) => s,
        Err(()) => {
            ns.diagnostics.extend(diagnostics);
            return None;
        }
    };

    let mut constant = false;

    for attr in attrs {
        match &attr {
            program::VariableAttribute::Constant(loc) => {
                if constant {
                    ns.diagnostics.push(Diagnostic::error(
                        *loc,
                        "duplicate constant attribute".to_string(),
                    ));
                }
                constant = true;
            }

            _ => {}
        }
    }


    let initializer = if constant {
        if let Some(initializer) = &def.initializer {
            let mut diagnostics = Diagnostics::default();
            let context = ExprContext {
                file_no,
                unchecked: false,
                contract_no,
                function_no: None,
                constant,
                lvalue: false,
                yul_function: false,
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
                    match res.cast(&def.loc, &ty, true, ns, &mut diagnostics) {
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

/// For accessor functions, create the parameter list and the return expression
fn collect_parameters<'a>(
    ty: &'a Type,
    symtable: &mut Symtable,
    params: &mut Vec<Parameter>,
    expr: &mut Expression,
    ns: &mut Namespace,
) -> &'a Type {
    match ty {
        Type::Array(elem_ty, dims) => {
            let mut ty = Type::StorageRef(false, Box::new(ty.clone()));
            for _ in 0..dims.len() {
                let map = (*expr).clone();

                let id = program::Identifier {
                    loc: program::Loc::Implicit,
                    name: "".to_owned(),
                };
                let arg_ty = Type::Uint(256);

                let var_no = symtable
                    .add(
                        &id,
                        arg_ty.clone(),
                        ns,
                        VariableInitializer::Solidity(None),
                        VariableUsage::Parameter,
                        None,
                    )
                    .unwrap();

                symtable.arguments.push(Some(var_no));

                *expr = Expression::Subscript(
                    program::Loc::Implicit,
                    ty.storage_array_elem(),
                    ty.clone(),
                    Box::new(map),
                    Box::new(Expression::Variable(
                        program::Loc::Implicit,
                        Type::Uint(256),
                        var_no,
                    )),
                );

                ty = ty.storage_array_elem();

                params.push(Parameter {
                    id: Some(id),
                    loc: program::Loc::Implicit,
                    ty: arg_ty,
                    ty_loc: None,
                    recursive: false,
                });
            }

            collect_parameters(elem_ty, symtable, params, expr, ns)
        }
        _ => ty,
    }
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
            unchecked: false,
            contract_no: Some(*contract_no),
            function_no: None,
            constant: false,
            lvalue: false,
            yul_function: false,
        };

        if let Ok(res) = expression(
            initializer,
            &context,
            ns,
            &mut symtable,
            &mut diagnostics,
            ResolveTo::Type(&ty),
        ) {
            if let Ok(res) = res.cast(&initializer.loc(), &ty, true, ns, &mut diagnostics) {
                res.recurse(ns, check_term_for_constant_overflow);
                ns.contracts[*contract_no].variables[*var_no].initializer = Some(res);
            }
        }
    }

    ns.diagnostics.extend(diagnostics);
}
