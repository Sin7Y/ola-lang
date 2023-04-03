// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::{Expression, Function, Namespace, Type};
use crate::sema::diagnostics::Diagnostics;

use crate::sema::corelib;
use crate::sema::expression::{
    expression, named_struct_literal, struct_literal, ExprContext, ResolveTo,
};
use crate::sema::symtable::Symtable;
use crate::sema::unused_variable::check_function_call;
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;
use ola_parser::program::{CodeLocation, Loc};
use std::collections::HashMap;

/// Create a list of functions that can be called in this context.
pub fn available_functions(name: &str, contract_no: Option<usize>, ns: &Namespace) -> Vec<usize> {
    let mut list = Vec::new();

    if let Some(contract_no) = contract_no {
        list.extend(
            ns.contracts[contract_no]
                .all_functions
                .keys()
                .filter_map(|func_no| {
                    if ns.functions[*func_no].name == name && ns.functions[*func_no].has_body {
                        Some(*func_no)
                    } else {
                        None
                    }
                }),
        );
    }

    list
}

/// Resolve a function call with positional arguments
pub fn function_call_pos_args(
    loc: &Loc,
    id: &program::Identifier,
    args: &[program::Expression],
    function_nos: Vec<usize>,
    context: &ExprContext,
    ns: &mut Namespace,
    resolve_to: ResolveTo,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let mut name_matches = 0;
    let mut errors = Diagnostics::default();

    // Try to resolve as a function call
    for function_no in &function_nos {
        let func = &ns.functions[*function_no];

        name_matches += 1;

        let params_len = func.params.len();

        if params_len != args.len() {
            errors.push(Diagnostic::error(
                *loc,
                format!(
                    "fn expects {} arguments, {} provided",
                    params_len,
                    args.len()
                ),
            ));
            continue;
        }

        let mut matches = true;
        let mut cast_args = Vec::new();

        // check if arguments can be implicitly casted
        for (i, arg) in args.iter().enumerate() {
            let ty = ns.functions[*function_no].params[i].ty.clone();

            let arg = match expression(
                arg,
                context,
                ns,
                symtable,
                &mut errors,
                ResolveTo::Type(&ty),
            ) {
                Ok(e) => e,
                Err(_) => {
                    matches = false;
                    continue;
                }
            };

            match arg.cast(&arg.loc(), &ty, ns, &mut errors) {
                Ok(expr) => cast_args.push(expr),
                Err(_) => {
                    matches = false;
                }
            }
        }

        if !matches {
            if function_nos.len() > 1 && diagnostics.extend_non_casting(&errors) {
                return Err(());
            }

            continue;
        }

        let func = &ns.functions[*function_no];

        let returns = function_returns(func, resolve_to);
        let ty = function_type(func, resolve_to);

        return Ok(Expression::FunctionCall {
            loc: *loc,
            returns,
            function: Box::new(Expression::Function {
                loc: *loc,
                ty,
                function_no: *function_no,
                signature: None,
            }),
            args: cast_args,
        });
    }

    match name_matches {
        0 => {
            diagnostics.push(Diagnostic::error(
                id.loc,
                format!("unknown fn or type with name '{}'", id.name),
            ));
        }
        1 => diagnostics.extend(errors),
        _ => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("cannot find overloaded fn which matches signature"),
            ));
        }
    }

    Err(())
}

/// Resolve a function call with named arguments
fn function_call_named_args(
    loc: &Loc,
    id: &program::Identifier,
    args: &[program::NamedArgument],
    function_nos: Vec<usize>,
    context: &ExprContext,
    resolve_to: ResolveTo,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let mut arguments = HashMap::new();

    for arg in args {
        if arguments.contains_key(arg.name.name.as_str()) {
            diagnostics.push(Diagnostic::error(
                arg.name.loc,
                format!("duplicate argument with name '{}'", arg.name.name),
            ));

            let _ = expression(
                &arg.expr,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Unknown,
            );
        }

        arguments.insert(arg.name.name.as_str(), &arg.expr);
    }
    // Try to resolve as a function call
    let mut errors = Diagnostics::default();

    // Try to resolve as a function call
    for function_no in &function_nos {
        let func = &ns.functions[*function_no];

        let unnamed_params = func.params.iter().filter(|p| p.id.is_none()).count();
        let params_len = func.params.len();
        let mut matches = true;

        if unnamed_params > 0 {
            errors.push(Diagnostic::cast_error_with_note(
                *loc,
                format!(
                    "function cannot be called with named arguments as {} of its parameters do not have names",
                    unnamed_params,
                ),
                func.loc,
                format!("definition of {}", func.name),
            ));
            matches = false;
        } else if params_len != args.len() {
            errors.push(Diagnostic::cast_error(
                *loc,
                format!(
                    "function expects {} arguments, {} provided",
                    params_len,
                    args.len()
                ),
            ));
            matches = false;
        }

        let mut cast_args = Vec::new();

        // check if arguments can be implicitly casted
        for i in 0..params_len {
            let param = &ns.functions[*function_no].params[i];
            if param.id.is_none() {
                continue;
            }
            let arg = match arguments.get(param.name_as_str()) {
                Some(a) => a,
                None => {
                    matches = false;
                    diagnostics.push(Diagnostic::cast_error(
                        *loc,
                        format!(
                            "missing argument '{}' to function '{}'",
                            param.name_as_str(),
                            id.name,
                        ),
                    ));
                    continue;
                }
            };

            let ty = param.ty.clone();

            let arg = match expression(
                arg,
                context,
                ns,
                symtable,
                &mut errors,
                ResolveTo::Type(&ty),
            ) {
                Ok(e) => e,
                Err(()) => {
                    matches = false;
                    continue;
                }
            };

            match arg.cast(&arg.loc(), &ty, ns, &mut errors) {
                Ok(expr) => cast_args.push(expr),
                Err(_) => {
                    matches = false;
                }
            }
        }

        if !matches {
            if diagnostics.extend_non_casting(&errors) {
                return Err(());
            }
            continue;
        }

        let func = &ns.functions[*function_no];

        let returns = function_returns(func, resolve_to);
        let ty = function_type(func, resolve_to);

        return Ok(Expression::FunctionCall {
            loc: *loc,
            returns,
            function: Box::new(Expression::Function {
                loc: *loc,
                ty,
                function_no: *function_no,
                signature: None,
            }),
            args: cast_args,
        });
    }

    match function_nos.len() {
        0 => {
            diagnostics.push(Diagnostic::error(
                id.loc,
                format!("unknown function or type '{}'", id.name),
            ));
        }
        1 => diagnostics.extend(errors),
        _ => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "cannot find overloaded function which matches signature".to_string(),
            ));
        }
    }

    Err(())
}

fn try_namespace(
    loc: &program::Loc,
    var: &program::Expression,
    func: &program::Identifier,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Option<Expression>, ()> {
    if let program::Expression::Variable(namespace) = var {
        if corelib::is_lib_func_call(Some(&namespace.name), &func.name) {
            return Ok(Some(corelib::resolve_call(
                loc,
                Some(namespace.name.as_str()),
                &func.name,
                args,
                context,
                ns,
                symtable,
                diagnostics,
            )?));
        }
    }

    Ok(None)
}

/// Resolve a method call with positional arguments
pub(super) fn method_call_pos_args(
    loc: &program::Loc,
    var: &program::Expression,
    func: &program::Identifier,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    if let Some(resolved_call) =
        try_namespace(loc, var, func, args, context, ns, symtable, diagnostics)?
    {
        return Ok(resolved_call);
    }

    let var_expr = expression(var, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;

    if let Some(expr) =
        corelib::resolve_method_call(&var_expr, func, args, context, ns, symtable, diagnostics)?
    {
        return Ok(expr);
    }

    diagnostics.push(Diagnostic::error(
        func.loc,
        format!("method '{}' does not exist", func.name),
    ));

    Err(())
}

pub fn named_call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::NamedArgument],
    is_destructible: bool,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut nullsink = Diagnostics::default();

    // is it a struct literal
    match ns.resolve_type(context.file_no, context.contract_no, ty, &mut nullsink) {
        Ok(Type::Struct(str_ty)) => {
            return named_struct_literal(loc, &str_ty, args, context, ns, symtable, diagnostics);
        }
        Ok(_) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "struct or function expected".to_string(),
            ));
            return Err(());
        }
        _ => {}
    }

    // not a struct literal, remove those errors and try resolving as function call
    if context.constant {
        diagnostics.push(Diagnostic::error(
            *loc,
            "cannot call function in constant expression".to_string(),
        ));
        return Err(());
    }

    let expr = named_function_call_expr(
        loc,
        ty,
        args,
        context,
        ns,
        symtable,
        diagnostics,
        resolve_to,
    )?;

    check_function_call(ns, &expr, symtable);
    if expr.tys().len() > 1 && !is_destructible {
        diagnostics.push(Diagnostic::error(
            *loc,
            "destucturing statement needed for function that returns multiple values".to_string(),
        ));
        return Err(());
    }

    Ok(expr)
}

/// Resolve any callable expression
pub fn call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::Expression],
    is_destructible: bool,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut nullsink = Diagnostics::default();
    let ty = ty.remove_parenthesis();

    match ns.resolve_type(context.file_no, context.contract_no, ty, &mut nullsink) {
        Ok(Type::Struct(str_ty)) => {
            return struct_literal(loc, &str_ty, args, context, ns, symtable, diagnostics);
        }
        Ok(to) => {
            // Cast
            return if args.is_empty() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "missing argument to cast".to_string(),
                ));
                Err(())
            } else if args.len() > 1 {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "too many arguments to cast".to_string(),
                ));
                Err(())
            } else {
                let expr = expression(
                    &args[0],
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Unknown,
                )?;

                expr.cast(loc, &to, ns, diagnostics)
            };
        }
        Err(_) => (),
    }

    let expr = match ty.remove_parenthesis() {
        _ => function_call_expr(
            loc,
            ty,
            args,
            context,
            ns,
            symtable,
            diagnostics,
            resolve_to,
        )?,
    };

    check_function_call(ns, &expr, symtable);
    if expr.tys().len() > 1 && !is_destructible {
        diagnostics.push(Diagnostic::error(
            *loc,
            "destucturing statement needed for function that returns multiple values".to_string(),
        ));
        return Err(());
    }

    Ok(expr)
}

/// Resolve function call
pub fn function_call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    match ty.remove_parenthesis() {
        program::Expression::MemberAccess(_, member, func) => {
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "cannot call function in constant expression".to_string(),
                ));
                return Err(());
            }

            method_call_pos_args(loc, member, func, args, context, ns, symtable, diagnostics)
        }
        program::Expression::Variable(id) => {
            // is it a lib function call
            if corelib::is_lib_func_call(None, &id.name) {
                return {
                    let expr = corelib::resolve_call(
                        &id.loc,
                        None,
                        &id.name,
                        args,
                        context,
                        ns,
                        symtable,
                        diagnostics,
                    )?;

                    if expr.tys().len() > 1 {
                        diagnostics.push(Diagnostic::error(
                            *loc,
                            format!(
                                "core lib function '{}' returns more than one value",
                                id.name
                            ),
                        ));
                        Err(())
                    } else {
                        Ok(expr)
                    }
                };
            }
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "cannot call function in constant expression".to_string(),
                ));
                return Err(());
            }

            function_call_pos_args(
                loc,
                id,
                args,
                available_functions(&id.name, context.contract_no, ns),
                context,
                ns,
                resolve_to,
                symtable,
                diagnostics,
            )
        }
        _ => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "expression is not a function".to_string(),
            ));
            Err(())
        }
    }
}

/// Resolve function call expression with named arguments
pub fn named_function_call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::NamedArgument],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    match ty {
        program::Expression::Variable(id) => function_call_named_args(
            loc,
            id,
            args,
            available_functions(&id.name, context.contract_no, ns),
            context,
            resolve_to,
            ns,
            symtable,
            diagnostics,
        ),
        program::Expression::ArraySubscript(..) => {
            diagnostics.push(Diagnostic::error(
                ty.loc(),
                "unexpected array type".to_string(),
            ));
            Err(())
        }
        _ => {
            diagnostics.push(Diagnostic::error(
                ty.loc(),
                "expression not expected here".to_string(),
            ));
            Err(())
        }
    }
}

/// Get the return values for a function call
pub(crate) fn function_returns(ftype: &Function, resolve_to: ResolveTo) -> Vec<Type> {
    if !ftype.returns.is_empty() && !matches!(resolve_to, ResolveTo::Discard) {
        ftype.returns.iter().map(|p| p.ty.clone()).collect()
    } else {
        vec![Type::Void]
    }
}

/// Get the function type for an internal.external function call
pub(crate) fn function_type(func: &Function, resolve_to: ResolveTo) -> Type {
    let params = func.params.iter().map(|p| p.ty.clone()).collect();
    let returns = function_returns(func, resolve_to);

    Type::Function { params, returns }
}
