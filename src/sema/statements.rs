// SPDX-License-Identifier: Apache-2.0

use super::ast::*;
use super::diagnostics::Diagnostics;
use super::eval::check_term_for_constant_overflow;
use super::function_call::{call_expr, named_call_expr};
use super::symtable::{LoopScopes, Symtable};
use crate::sema::symtable::{VariableInitializer, VariableUsage};
use crate::sema::unused_variable::used_variable;
use crate::sema::Recurse;
use ola_parser::program;
use ola_parser::program::CodeLocation;
use std::sync::Arc;
use crate::sema::expression::{ExprContext, expression, ResolveTo};

pub fn resolve_function_body(
    def: &program::FunctionDefinition,
    file_no: usize,
    contract_no: Option<usize>,
    function_no: usize,
    ns: &mut Namespace,
) -> Result<(), ()> {
    let mut symtable = Symtable::new();
    let mut loops = LoopScopes::new();
    let mut res = Vec::new();
    let context = ExprContext {
        file_no,
        contract_no,
        function_no: Some(function_no),
        constant: false,
        lvalue: false,
    };

    // first add function parameters
    for (i, p) in def.params.iter().enumerate() {
        let p = p.1.as_ref().unwrap();
        if let Some(ref name) = p.name {
            if let Some(pos) = symtable.add(
                name,
                ns.functions[function_no].params[i].ty.clone(),
                ns,
                VariableInitializer::Ola(None),
                VariableUsage::Parameter,
            ) {
                ns.check_shadowing(file_no, contract_no, name);

                symtable.arguments.push(Some(pos));
            }
        } else {
            symtable.arguments.push(None);
        }
    }

    // a function with no return values does not need a return statement
    let mut return_required = !def.returns.is_empty();

    // If any of the return values are named, then the return statement can be
    // omitted at the end of the function, and return values may be omitted too.
    // Create variables to store the return values
    for (i, p) in def.returns.iter().enumerate() {
        let ret = &ns.functions[function_no].returns[i];

        if let Some(ref name) = p.1.as_ref().unwrap().name {
            return_required = false;

            if let Some(pos) = symtable.add(
                name,
                ret.ty.clone(),
                ns,
                VariableInitializer::Ola(None),
                VariableUsage::ReturnVariable,
            ) {
                ns.check_shadowing(file_no, contract_no, name);
                symtable.returns.push(pos);
            }
        } else {
            // anonymous return
            let id = program::Identifier {
                loc: p.0,
                name: "".to_owned(),
            };

            let pos = symtable
                .add(
                    &id,
                    ret.ty.clone(),
                    ns,
                    VariableInitializer::Ola(None),
                    VariableUsage::AnonymousReturnVariable,
                )
                .unwrap();

            symtable.returns.push(pos);
        }
    }

    let body = match def.body {
        None => return Ok(()),
        Some(ref body) => body,
    };

    let mut diagnostics = Diagnostics::default();

    let reachable = statement(
        body,
        &mut res,
        &context,
        &mut symtable,
        &mut loops,
        ns,
        &mut diagnostics,
    );

    ns.diagnostics.extend(diagnostics);

    if reachable? && return_required {
        ns.diagnostics.push(Diagnostic::error(
            body.loc().end_range(),
            "missing return statement".to_string(),
        ));
        return Err(());
    }

    ns.functions[function_no].body = res;

    std::mem::swap(&mut ns.functions[function_no].symtable, &mut symtable);

    Ok(())
}

/// Resolve a statement
#[allow(clippy::ptr_arg)]
fn statement(
    stmt: &program::Statement,
    res: &mut Vec<Statement>,
    context: &ExprContext,
    symtable: &mut Symtable,
    loops: &mut LoopScopes,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<bool, ()> {
    match stmt {
        program::Statement::VariableDefinition(loc, decl, initializer) => {
            let (var_ty, ty_loc) = resolve_var_decl_ty(&decl.ty, context, ns, diagnostics)?;

            let initializer = if let Some(init) = initializer {
                let expr = expression(
                    init,
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Type(&var_ty),
                )?;

                expr.recurse(ns, check_term_for_constant_overflow);
                used_variable(ns, &expr, symtable);

                Some(Arc::new(expr.cast(
                    &expr.loc(),
                    &var_ty,
                    ns,
                    diagnostics,
                )?))
            } else {
                None
            };

            if let Some(pos) = symtable.add(
                decl.name.as_ref().unwrap(),
                var_ty.clone(),
                ns,
                VariableInitializer::Ola(initializer.clone()),
                VariableUsage::LocalVariable,
            ) {
                ns.check_shadowing(
                    context.file_no,
                    context.contract_no,
                    decl.name.as_ref().unwrap(),
                );

                res.push(Statement::VariableDecl(
                    *loc,
                    pos,
                    Parameter {
                        loc: decl.loc,
                        ty: var_ty,
                        ty_loc: Some(ty_loc),
                        id: Some(decl.name.clone().unwrap()),
                        recursive: false,
                    },
                    initializer,
                ));
            }

            Ok(true)
        }
        program::Statement::Block { statements, .. } => {
            symtable.new_scope();
            let mut reachable = true;

            let context = context.clone();

            for stmt in statements {
                if !reachable {
                    ns.diagnostics.push(Diagnostic::error(
                        stmt.loc(),
                        "unreachable statement".to_string(),
                    ));
                    return Err(());
                }
                reachable = statement(stmt, res, &context, symtable, loops, ns, diagnostics)?;
            }

            symtable.leave_scope();

            Ok(reachable)
        }
        program::Statement::Break(loc) => {
            if loops.do_break() {
                res.push(Statement::Break(*loc));
                Ok(false)
            } else {
                diagnostics.push(Diagnostic::error(
                    stmt.loc(),
                    "break statement not in loop".to_string(),
                ));
                Err(())
            }
        }
        program::Statement::Continue(loc) => {
            if loops.do_continue() {
                res.push(Statement::Continue(*loc));
                Ok(false)
            } else {
                diagnostics.push(Diagnostic::error(
                    stmt.loc(),
                    "continue statement not in loop".to_string(),
                ));
                Err(())
            }
        }

        program::Statement::If(loc, cond_expr, then, else_) => {
            let expr = expression(
                cond_expr,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&Type::Bool),
            )?;
            used_variable(ns, &expr, symtable);

            let cond = expr.cast(&expr.loc(), &Type::Bool, ns, diagnostics)?;

            symtable.new_scope();
            let mut then_stmts = Vec::new();
            let mut reachable = statement(
                then,
                &mut then_stmts,
                context,
                symtable,
                loops,
                ns,
                diagnostics,
            )?;
            symtable.leave_scope();

            let mut else_stmts = Vec::new();
            if let Some(stmts) = else_ {
                symtable.new_scope();
                reachable |= statement(
                    stmts,
                    &mut else_stmts,
                    context,
                    symtable,
                    loops,
                    ns,
                    diagnostics,
                )?;

                symtable.leave_scope();
            } else {
                reachable = true;
            }

            res.push(Statement::If(*loc, reachable, cond, then_stmts, else_stmts));

            Ok(reachable)
        }
        program::Statement::Args(loc, _) => {
            ns.diagnostics.push(Diagnostic::error(
                *loc,
                "expected code block, not list of named arguments".to_string(),
            ));
            Err(())
        }
        program::Statement::For(loc, init_stmt, None, next_stmt, body_stmt) => {
            symtable.new_scope();

            let mut init = Vec::new();

            if let Some(init_stmt) = init_stmt {
                statement(
                    init_stmt,
                    &mut init,
                    context,
                    symtable,
                    loops,
                    ns,
                    diagnostics,
                )?;
            }

            loops.new_scope();

            let mut body = Vec::new();

            if let Some(body_stmt) = body_stmt {
                statement(
                    body_stmt,
                    &mut body,
                    context,
                    symtable,
                    loops,
                    ns,
                    diagnostics,
                )?;
            }

            let control = loops.leave_scope();
            let reachable = control.no_breaks > 0;
            let mut next = Vec::new();

            if let Some(next_stmt) = next_stmt {
                statement(
                    next_stmt,
                    &mut next,
                    context,
                    symtable,
                    loops,
                    ns,
                    diagnostics,
                )?;
            }

            symtable.leave_scope();

            res.push(Statement::For {
                loc: *loc,
                reachable,
                init,
                next,
                cond: None,
                body,
            });

            Ok(reachable)
        }
        program::Statement::For(loc, init_stmt, Some(cond_expr), next_stmt, body_stmt) => {
            symtable.new_scope();

            let mut init = Vec::new();
            let mut body = Vec::new();
            let mut next = Vec::new();

            if let Some(init_stmt) = init_stmt {
                statement(
                    init_stmt,
                    &mut init,
                    context,
                    symtable,
                    loops,
                    ns,
                    diagnostics,
                )?;
            }

            let expr = expression(
                cond_expr,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&Type::Bool),
            )?;

            let cond = expr.cast(&cond_expr.loc(), &Type::Bool, ns, diagnostics)?;

            // continue goes to next, and if that does exist, cond
            loops.new_scope();

            let mut body_reachable = match body_stmt {
                Some(body_stmt) => statement(
                    body_stmt,
                    &mut body,
                    context,
                    symtable,
                    loops,
                    ns,
                    diagnostics,
                )?,
                None => true,
            };

            let control = loops.leave_scope();

            if control.no_continues > 0 {
                body_reachable = true;
            }

            if body_reachable {
                if let Some(next_stmt) = next_stmt {
                    statement(
                        next_stmt,
                        &mut next,
                        context,
                        symtable,
                        loops,
                        ns,
                        diagnostics,
                    )?;
                }
            }

            symtable.leave_scope();

            res.push(Statement::For {
                loc: *loc,
                reachable: true,
                init,
                next,
                cond: Some(cond),
                body,
            });

            Ok(true)
        }
        program::Statement::Return(loc, None) => {
            let no_returns = ns.functions[context.function_no.unwrap()].returns.len();

            if symtable.returns.len() != no_returns {
                ns.diagnostics.push(Diagnostic::error(
                    *loc,
                    format!(
                        "missing return value, {} return values expected",
                        no_returns
                    ),
                ));
                return Err(());
            }

            res.push(Statement::Return(*loc, None));

            Ok(false)
        }
        program::Statement::Return(loc, Some(returns)) => {
            let expr = return_with_values(returns, loc, context, symtable, ns, diagnostics)?;

            expr.recurse(ns, check_term_for_constant_overflow);

            for offset in symtable.returns.iter() {
                let elem = symtable.vars.get_mut(offset).unwrap();
                elem.assigned = true;
            }

            res.push(Statement::Return(*loc, Some(expr)));

            Ok(false)
        }
        program::Statement::Expression(loc, expr) => {
            let expr = match expr {
                program::Expression::FunctionCall(loc, ty, args) => {
                    let ret = call_expr(
                        loc,
                        ty,
                        args,
                        true,
                        context,
                        ns,
                        symtable,
                        diagnostics,
                        ResolveTo::Discard,
                    )?;

                    ret.recurse(ns, check_term_for_constant_overflow);
                    ret
                }
                program::Expression::NamedFunctionCall(loc, ty, args) => {
                    let ret = named_call_expr(
                        loc,
                        ty,
                        args,
                        true,
                        context,
                        ns,
                        symtable,
                        diagnostics,
                        ResolveTo::Discard,
                    )?;
                    ret.recurse(ns, check_term_for_constant_overflow);
                    ret
                }
                _ => {
                    // the rest. We don't care about the result
                    expression(expr, context, ns, symtable, diagnostics, ResolveTo::Unknown)?
                }
            };

            let reachable = expr.tys() != vec![Type::Unreachable];

            res.push(Statement::Expression(*loc, reachable, expr));

            Ok(reachable)
        }

        program::Statement::Error(_) => unimplemented!(),
    }
}

/// Resolve the type of a variable declaration
fn resolve_var_decl_ty(
    ty: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<(Type, program::Loc), ()> {
    let loc_ty = ty.loc();
    let var_ty = ns.resolve_type(context.file_no, context.contract_no, ty, diagnostics)?;
    Ok((var_ty, loc_ty))
}

/// Resolve return statement
fn return_with_values(
    returns: &program::Expression,
    loc: &program::Loc,
    context: &ExprContext,
    symtable: &mut Symtable,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let function_no = context.function_no.unwrap();

    let no_returns = ns.functions[function_no].returns.len();
    let expr_returns = match returns.remove_parenthesis() {
        program::Expression::FunctionCall(loc, ty, args) => {
            let expr = call_expr(
                loc,
                ty,
                args,
                true,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Unknown,
            )?;
            used_variable(ns, &expr, symtable);
            expr
        }
        program::Expression::NamedFunctionCall(loc, ty, args) => {
            let expr = named_call_expr(
                loc,
                ty,
                args,
                true,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Unknown,
            )?;
            used_variable(ns, &expr, symtable);
            expr
        }
        program::Expression::ConditionalOperator(loc, cond, left, right) => {
            let cond = expression(
                cond,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&Type::Bool),
            )?;
            used_variable(ns, &cond, symtable);

            let left = return_with_values(left, &left.loc(), context, symtable, ns, diagnostics)?;
            used_variable(ns, &left, symtable);

            let right =
                return_with_values(right, &right.loc(), context, symtable, ns, diagnostics)?;
            used_variable(ns, &right, symtable);

            return Ok(Expression::ConditionalOperator(
                *loc,
                Type::Unreachable,
                Box::new(cond),
                Box::new(left),
                Box::new(right),
            ));
        }
        _ => {
            let returns = parameter_list_to_expr_list(returns, diagnostics)?;

            if no_returns > 0 && returns.is_empty() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!(
                        "missing return value, {} return values expected",
                        no_returns
                    ),
                ));
                return Err(());
            }

            if no_returns == 0 && !returns.is_empty() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "function has no return values".to_string(),
                ));
                return Err(());
            }

            if no_returns != returns.len() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!(
                        "incorrect number of return values, expected {} but got {}",
                        no_returns,
                        returns.len(),
                    ),
                ));
                return Err(());
            }

            let mut exprs = Vec::new();

            let return_tys = ns.functions[function_no]
                .returns
                .iter()
                .map(|r| r.ty.clone())
                .collect::<Vec<_>>();

            for (expr_return, return_ty) in returns.iter().zip(return_tys) {
                let expr = expression(
                    expr_return,
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Type(&return_ty),
                )?;
                let expr = expr.cast(loc, &return_ty, ns, diagnostics)?;
                used_variable(ns, &expr, symtable);
                exprs.push(expr);
            }

            return Ok(if exprs.len() == 1 {
                exprs[0].clone()
            } else {
                Expression::List(*loc, exprs)
            });
        }
    };

    let mut expr_return_tys = expr_returns.tys();
    // Return type void or unreachable are synthetic
    if expr_return_tys.len() == 1
        && (expr_return_tys[0] == Type::Unreachable || expr_return_tys[0] == Type::Void)
    {
        expr_return_tys.truncate(0);
    }

    if no_returns > 0 && expr_return_tys.is_empty() {
        diagnostics.push(Diagnostic::error(
            *loc,
            format!(
                "missing return value, {} return values expected",
                no_returns
            ),
        ));
        return Err(());
    }

    if no_returns == 0 && !expr_return_tys.is_empty() {
        diagnostics.push(Diagnostic::error(
            *loc,
            "function has no return values".to_string(),
        ));
        return Err(());
    }

    if no_returns != expr_return_tys.len() {
        diagnostics.push(Diagnostic::error(
            *loc,
            format!(
                "incorrect number of return values, expected {} but got {}",
                no_returns,
                expr_return_tys.len(),
            ),
        ));
        return Err(());
    }

    let func_returns_tys = ns.functions[function_no]
        .returns
        .iter()
        .map(|r| r.ty.clone())
        .collect::<Vec<_>>();

    // Check that the values can be cast
    let _ = expr_return_tys
        .into_iter()
        .zip(func_returns_tys)
        .enumerate()
        .map(|(i, (expr_return_ty, func_return_ty))| {
            Expression::Variable(expr_returns.loc(), expr_return_ty, i).cast(
                &expr_returns.loc(),
                &func_return_ty,
                ns,
                diagnostics,
            )
        })
        .collect::<Result<Vec<_>, _>>()?;

    Ok(expr_returns)
}

/// The parser generates parameter lists for lists. Sometimes this needs to be a
/// simple expression list.
pub fn parameter_list_to_expr_list<'a>(
    e: &'a program::Expression,
    diagnostics: &mut Diagnostics,
) -> Result<Vec<&'a program::Expression>, ()> {
    match e {
        program::Expression::List(_, v) => {
            let mut list = Vec::new();
            let mut broken = false;

            for e in v {
                match &e.1 {
                    None => {
                        diagnostics.push(Diagnostic::error(e.0, "stray comma".to_string()));
                        broken = true;
                    }
                    Some(program::Parameter {
                        name: Some(name), ..
                    }) => {
                        diagnostics.push(Diagnostic::error(
                            name.loc,
                            "single value expected".to_string(),
                        ));
                        broken = true;
                    }
                    Some(program::Parameter { ty, .. }) => {
                        list.push(ty);
                    }
                }
            }

            if !broken {
                Ok(list)
            } else {
                Err(())
            }
        }
        program::Expression::Parenthesis(_, e) => Ok(vec![e]),
        e => Ok(vec![e]),
    }
}
