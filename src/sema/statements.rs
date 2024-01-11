// SPDX-License-Identifier: Apache-2.0

use super::ast::*;
use super::diagnostics::Diagnostics;
use super::eval::check_term_for_constant_overflow;
use super::expression::{
    function_call::{call_expr, named_call_expr},
    ExprContext, ResolveTo,
};
use super::symtable::{LoopScopes, Symtable};
use crate::sema::expression::function_call::{function_call_expr, named_function_call_expr};
use crate::sema::expression::resolve_expression::expression;
use crate::sema::symtable::{VariableInitializer, VariableUsage};
use crate::sema::unused_variable::{assigned_variable, check_function_call, used_variable};
use crate::sema::Recurse;
use ola_parser::program;
use ola_parser::program::{CodeLocation, OptionalCodeLocation};
use std::sync::Arc;

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
    let mut context = ExprContext {
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
                None,
            ) {
                ns.check_shadowing(file_no, contract_no, name);

                symtable.arguments.push(Some(pos));
            }
        } else {
            symtable.arguments.push(None);
        }
    }

    // a function with no return values does not need a return statement
    let mut return_required = false;

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
                None,
            ) {
                ns.check_shadowing(file_no, contract_no, name);
                symtable.returns.push(pos);
            }
        } else {
            if ret.ty.is_contract_storage() {
                return_required = true;
            }
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
                    None,
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
        &mut context,
        &mut symtable,
        &mut loops,
        ns,
        &mut diagnostics,
    );

    ns.diagnostics.extend(diagnostics);

    if reachable? && return_required {
        for param in ns.functions[function_no].returns.iter() {
            if param.id.is_none() && param.ty.is_contract_storage() {
                ns.diagnostics.push(Diagnostic::error(
                    param.loc,
                    "storage reference must be given value with a return statement".to_string(),
                ));
            }
        }
    }

    ns.functions[function_no].body = res;

    std::mem::swap(&mut ns.functions[function_no].symtable, &mut symtable);

    Ok(())
}

/// Resolve a statement
fn statement(
    stmt: &program::Statement,
    res: &mut Vec<Statement>,
    context: &mut ExprContext,
    symtable: &mut Symtable,
    loops: &mut LoopScopes,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<bool, ()> {
    match stmt {
        program::Statement::VariableDefinition(loc, decl, initializer) => {
            let (var_ty, ty_loc) =
                resolve_var_decl_ty(&decl.ty, &decl.storage, context, ns, diagnostics)?;

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
                decl.storage.clone(),
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
                        infinite_size: false,
                        recursive: false,
                    },
                    initializer,
                ));
            }

            Ok(true)
        }
        program::Statement::Block { statements, loc } => {
            symtable.new_scope();
            let mut reachable = true;
            let mut already_unreachable = false;

            let mut context = context.clone();

            let mut resolved_stmts = Vec::new();

            for stmt in statements {
                if !reachable && !already_unreachable  {
                    ns.diagnostics.push(Diagnostic::error(
                        stmt.loc(),
                        "unreachable statement".to_string(),
                    ));
                    already_unreachable = true;
                }
                reachable = statement(stmt, &mut resolved_stmts, &mut context, symtable, loops, ns, diagnostics)?;
            }

            res.push(Statement::Block {
                loc: *loc,
                statements: resolved_stmts,
            });

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
        program::Statement::While(loc, cond_expr, body) => {
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
            let mut body_stmts = Vec::new();
            loops.new_scope();
            statement(
                body,
                &mut body_stmts,
                context,
                symtable,
                loops,
                ns,
                diagnostics,
            )?;
            symtable.leave_scope();
            loops.leave_scope();

            res.push(Statement::While(*loc, true, cond, body_stmts));

            Ok(true)
        }

        program::Statement::DoWhile(loc, body, cond_expr) => {
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
            let mut body_stmts = Vec::new();
            loops.new_scope();
            statement(
                body,
                &mut body_stmts,
                context,
                symtable,
                loops,
                ns,
                diagnostics,
            )?;
            symtable.leave_scope();
            loops.leave_scope();

            res.push(Statement::DoWhile(*loc, true, body_stmts, cond));
            Ok(true)
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
        program::Statement::For(loc, init_stmt, None, next_expr, body_stmt) => {
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
            let mut next = None;

            if let Some(next_expr) = next_expr {
                next = Some(expression(
                    next_expr,
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Type(&Type::Bool),
                )?);
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
        program::Statement::For(loc, init_stmt, Some(cond_expr), next_expr, body_stmt) => {
            symtable.new_scope();

            let mut init = Vec::new();
            let mut body = Vec::new();
            let mut next = None;

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
                if let Some(next_expr) = next_expr {
                    if body_reachable {
                        next = Some(expression(
                            next_expr,
                            context,
                            ns,
                            symtable,
                            diagnostics,
                            ResolveTo::Type(&Type::Bool),
                        )?);
                    }
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
                // delete statement
                program::Expression::Delete(_, expr) => {
                    let expr =
                        expression(expr, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;
                    used_variable(ns, &expr, symtable);
                    return if let Type::StorageRef(ty) = expr.ty() {
                        if expr.ty().is_mapping() {
                            ns.diagnostics.push(Diagnostic::error(
                                *loc,
                                "'delete' cannot be applied to mapping type".to_string(),
                            ));
                            return Err(());
                        }
                        res.push(Statement::Delete(*loc, ty.as_ref().clone(), expr));

                        Ok(true)
                    } else {
                        ns.diagnostics.push(Diagnostic::error(
                            *loc,
                            "argument to 'delete' should be storage reference".to_string(),
                        ));

                        Err(())
                    };
                }
                program::Expression::FunctionCall(loc, ty, args) => {
                    let ret = call_expr(
                        loc,
                        ty,
                        args,
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
                    // is it a destructure statement
                    if let program::Expression::Assign(_, var, expr) = expr {
                        if let program::Expression::List(_, var) = var.as_ref() {
                            res.push(destructure(
                                loc,
                                var,
                                expr,
                                context,
                                symtable,
                                ns,
                                diagnostics,
                            )?);

                            // if a noreturn function was called, then the destructure would not
                            // resolve
                            return Ok(true);
                        }
                    }
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

/// Resolve destructuring assignment
fn destructure(
    loc: &program::Loc,
    vars: &[(program::Loc, Option<program::Parameter>)],
    expr: &program::Expression,
    context: &mut ExprContext,
    symtable: &mut Symtable,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Statement, ()> {
    // first resolve the fields so we know the types
    let mut fields = Vec::new();
    let mut left_tys = Vec::new();

    let prev_lvalue = context.lvalue;
    context.lvalue = true;

    let mut context = scopeguard::guard(context, |context| {
        context.lvalue = prev_lvalue;
    });


    for (_, param) in vars {
        match param {
            None => {
                left_tys.push(None);
                fields.push(DestructureField::None);
            }
            Some(program::Parameter {
                loc,
                ty,
                name: None,
            }) => {
                // ty will just be a normal expression, not a type
                let e = expression(ty,  &mut context, ns, symtable, diagnostics, ResolveTo::Unknown)?;

                match &e {
                    Expression::ConstantVariable {
                        contract_no: Some(contract_no),
                        var_no,
                        ..
                    } => {
                        diagnostics.push(Diagnostic::error(
                            *loc,
                            format!(
                                "cannot assign to constant '{}'",
                                ns.contracts[*contract_no].variables[*var_no].name
                            ),
                        ));
                        return Err(());
                    }
                    Expression::ConstantVariable {
                        contract_no: None,
                        var_no,
                        ..
                    } => {
                        diagnostics.push(Diagnostic::error(
                            *loc,
                            format!("cannot assign to constant '{}'", ns.constants[*var_no].name),
                        ));
                        return Err(());
                    }

                    Expression::Variable { .. } => (),
                    _ => match e.ty() {
                        Type::Ref(_) | Type::StorageRef(_) => (),
                        _ => {
                            diagnostics.push(Diagnostic::error(
                                *loc,
                                "expression is not assignable".to_string(),
                            ));
                            return Err(());
                        }
                    },
                }

                assigned_variable(ns, &e, symtable);
                left_tys.push(Some(e.ty()));
                fields.push(DestructureField::Expression(e));
            }
            Some(program::Parameter {
                loc,
                ty,
                name: Some(name),
            }) => {
                let (ty, ty_loc) = resolve_var_decl_ty(ty, &None, &mut context, ns, diagnostics)?;

                if let Some(pos) = symtable.add(
                    name,
                    ty.clone(),
                    ns,
                    VariableInitializer::Ola(None),
                    VariableUsage::DestructureVariable,
                    None,
                ) {
                    ns.check_shadowing(context.file_no, context.contract_no, name);

                    left_tys.push(Some(ty.clone()));

                    fields.push(DestructureField::VariableDecl(
                        pos,
                        Parameter {
                            loc: *loc,
                            id: Some(name.clone()),
                            ty,
                            ty_loc: Some(ty_loc),
                            infinite_size: false,
                            recursive: false,
                        },
                    ));
                }
            }
        }
    }

    let expr = destructure_values(
        loc,
        expr,
        &left_tys,
        &fields,
        &mut context,
        symtable,
        ns,
        diagnostics,
    )?;

    Ok(Statement::Destructure(*loc, fields, expr))
}

fn destructure_values(
    loc: &program::Loc,
    expr: &program::Expression,
    left_tys: &[Option<Type>],
    fields: &[DestructureField],
    context: &mut ExprContext,
    symtable: &mut Symtable,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let expr = match expr.remove_parenthesis() {
        program::Expression::FunctionCall(loc, ty, args) => {
            let res = function_call_expr(
                loc,
                ty,
                args,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Unknown,
            )?;
            check_function_call(ns, &res, symtable);
            res
        }
        program::Expression::NamedFunctionCall(loc, ty, args) => {
            let res = named_function_call_expr(
                loc,
                ty,
                args,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Unknown,
            )?;
            check_function_call(ns, &res, symtable);
            res
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
            let left = destructure_values(
                &left.loc(),
                left,
                left_tys,
                fields,
                context,
                symtable,
                ns,
                diagnostics,
            )?;
            used_variable(ns, &left, symtable);
            let right = destructure_values(
                &right.loc(),
                right,
                left_tys,
                fields,
                context,
                symtable,
                ns,
                diagnostics,
            )?;
            used_variable(ns, &right, symtable);

            return Ok(Expression::ConditionalOperator {
                loc: *loc,
                ty: Type::Unreachable,
                cond: Box::new(cond),
                true_option: Box::new(left),
                false_option: Box::new(right),
            });
        }
        _ => {
            let mut list = Vec::new();

            let exprs = parameter_list_to_expr_list(expr, diagnostics)?;

            if exprs.len() != left_tys.len() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!(
                        "destructuring assignment has {} elements on the left and {} on the right",
                        left_tys.len(),
                        exprs.len(),
                    ),
                ));
                return Err(());
            }

            for (i, e) in exprs.iter().enumerate() {
                let e = expression(
                    e,
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    if let Some(ty) = left_tys[i].as_ref() {
                        ResolveTo::Type(ty)
                    } else {
                        ResolveTo::Unknown
                    },
                )?;
                match e.ty() {
                    Type::Void | Type::Unreachable => {
                        diagnostics.push(Diagnostic::error(
                            e.loc(),
                            "function does not return a value".to_string(),
                        ));
                        return Err(());
                    }
                    _ => {
                        used_variable(ns, &e, symtable);
                    }
                }

                list.push(e);
            }

            Expression::List { loc: *loc, list }
        }
    };

    let mut right_tys = expr.tys();

    // Return type void or unreachable are synthetic
    if right_tys.len() == 1 && (right_tys[0] == Type::Unreachable || right_tys[0] == Type::Void) {
        right_tys.truncate(0);
    }

    if left_tys.len() != right_tys.len() {
        diagnostics.push(Diagnostic::error(
            *loc,
            format!(
                "destructuring assignment has {} elements on the left and {} on the right",
                left_tys.len(),
                right_tys.len()
            ),
        ));
        return Err(());
    }

    // Check that the values can be cast
    for (i, field) in fields.iter().enumerate() {
        if let Some(left_ty) = &left_tys[i] {
            let loc = field.loc_opt().unwrap();
            let _ = Expression::Variable {
                loc,
                ty: right_tys[i].clone(),
                var_no: i,
            }
            .cast(&loc, left_ty.deref_memory(), ns, diagnostics)?;
        }
    }
    Ok(expr)
}

/// Resolve the type of a variable declaration
fn resolve_var_decl_ty(
    ty: &program::Expression,
    storage: &Option<program::StorageLocation>,
    context: &mut ExprContext,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<(Type, program::Loc), ()> {
    let mut loc_ty = ty.loc();
    let mut var_ty = ns.resolve_type(context.file_no, context.contract_no, ty, diagnostics)?;
    if let Some(storage) = storage {
        if !var_ty.can_have_data_location() {
            diagnostics.push(Diagnostic::error(
                storage.loc(),
                format!("data location '{storage}' only allowed for array, struct or mapping type"),
            ));
            return Err(());
        }

        if let program::StorageLocation::Storage(loc) = storage {
            loc_ty.use_end_from(loc);
            var_ty = Type::StorageRef(Box::new(var_ty));
        }

        // Note we are completely ignoring memory or calldata data locations.
        // Everything will be stored in memory.
    }

    if var_ty.contains_mapping(ns) && !var_ty.is_contract_storage() {
        diagnostics.push(Diagnostic::error(
            ty.loc(),
            "mapping only allowed in storage".to_string(),
        ));
        return Err(());
    }

    if !var_ty.is_contract_storage() && !var_ty.fits_in_memory(ns) {
        diagnostics.push(Diagnostic::error(
            ty.loc(),
            "type is too large to fit into memory".to_string(),
        ));
        return Err(());
    }
    Ok((var_ty, loc_ty))
}

/// Resolve return statement
fn return_with_values(
    returns: &program::Expression,
    loc: &program::Loc,
    context: &mut ExprContext,
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

            return Ok(Expression::ConditionalOperator {
                loc: *loc,
                ty: Type::Unreachable,
                cond: Box::new(cond),
                true_option: Box::new(left),
                false_option: Box::new(right),
            });
        }
        _ => {
            let returns = parameter_list_to_expr_list(returns, diagnostics)?;

            if no_returns > 0 && returns.is_empty() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("missing return value, {no_returns} return values expected",),
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
                Expression::List {
                    loc: *loc,
                    list: exprs,
                }
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
            Expression::Variable {
                loc: expr_returns.loc(),
                ty: expr_return_ty,
                var_no: i,
            }
            .cast(&expr_returns.loc(), &func_return_ty, ns, diagnostics)
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
