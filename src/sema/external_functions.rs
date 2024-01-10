// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::{DestructureField, Expression, LibFunc, Namespace, Statement};
use crate::sema::Recurse;
use indexmap::IndexSet;
use ola_parser::program;

#[derive(Default)]
struct CallList {
    pub items: IndexSet<usize>,
}

/// After generating the AST for a contract, we should have a list of
/// all the functions a contract calls in `all_functions`. This should
/// include any libraries and global functions
pub fn add_external_functions(contract_no: usize, ns: &mut Namespace) {
    let mut call_list = CallList::default();

    for var in &ns.contracts[contract_no].variables {
        if let Some(init) = &var.initializer {
            init.recurse(&mut call_list, check_expression);
        }
    }

    for function_no in ns.contracts[contract_no].all_functions.keys() {
        let func = &ns.functions[*function_no];

        for stmt in &func.body {
            stmt.recurse(&mut call_list, check_statement);
        }
    }

    // we've now collected all the functions which are called.
    while !call_list.items.is_empty() {
        let mut new_call_list = CallList::default();

        for function_no in &call_list.items {
            let func = &ns.functions[*function_no];

            for stmt in &func.body {
                stmt.recurse(&mut new_call_list, check_statement);
            }
        }

        // add functions to contract functions list
        for function_no in &call_list.items {
            if ns.functions[*function_no].loc != program::Loc::Builtin {
                ns.contracts[contract_no]
                    .all_functions
                    .insert(*function_no, usize::MAX);
            }
        }
    }
}

fn check_expression(expr: &Expression, _: &mut CallList) -> bool {
    match expr {
        Expression::LibFunction {
            kind: LibFunc::GetSelector,
            ..
        } => return false,
        _ => (),
    }

    true
}

fn check_statement(stmt: &Statement, call_list: &mut CallList) -> bool {
    match stmt {
        Statement::VariableDecl(_, _, _, Some(expr)) => {
            expr.recurse(call_list, check_expression);
        }
        Statement::VariableDecl(_, _, _, None) => (),
        Statement::If(_, _, cond, _, _) => {
            cond.recurse(call_list, check_expression);
        }
        Statement::For {
            cond: Some(cond), ..
        } => {
            cond.recurse(call_list, check_expression);
        }
        Statement::For { cond: None, .. } => (),
        Statement::DoWhile(_, _, _, cond) | Statement::While(_, _, cond, _) => {
            cond.recurse(call_list, check_expression);
        }
        Statement::Expression(_, _, expr) => {
            expr.recurse(call_list, check_expression);
        }
        Statement::Delete(_, _, expr) => {
            expr.recurse(call_list, check_expression);
        }
        Statement::Destructure(_, fields, expr) => {
            // This is either a list or internal/external function call
            expr.recurse(call_list, check_expression);

            for field in fields {
                if let DestructureField::Expression(expr) = field {
                    expr.recurse(call_list, check_expression);
                }
            }
        }
        Statement::Return(_, exprs) => {
            for e in exprs {
                e.recurse(call_list, check_expression);
            }
        }

        Statement::Block { .. } | Statement::Break(_) | Statement::Continue(_) => (),
    }

    true
}
