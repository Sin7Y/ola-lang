// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::{
    ArrayLength, CallArgs, CallTy, Expression, Function, LibFunc, Namespace, RetrieveType, Type,
};
use crate::sema::diagnostics::Diagnostics;

use crate::sema::corelib;
use crate::sema::expression::constructor::new;
use crate::sema::expression::literals::{named_struct_literal, struct_literal};
use crate::sema::expression::resolve_expression::expression;
use crate::sema::expression::{ExprContext, ResolveTo};
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
                .filter(|func_no| ns.functions[**func_no].name == name)
                .filter_map(|func_no| {
                    let func = &ns.functions[*func_no];
                    if func.has_body {
                        return Some(*func_no);
                    }
                    None
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

    if context.constant {
        diagnostics.push(Diagnostic::error(
            *loc,
            "cannot call function in constant expression".to_string(),
        ));
        return Err(());
    }

    // try to resolve the arguments, give up if there are any errors
    if args.iter().fold(false, |acc, arg| {
        acc | expression(arg, context, ns, symtable, diagnostics, ResolveTo::Unknown).is_err()
    }) {
        return Err(());
    }
    

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

            matches &=
                evaluate_argument(arg, context, ns, symtable, &ty, &mut errors, &mut cast_args);
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
                "cannot find overloaded fn which matches signature".to_string(),
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

            matches &=
                evaluate_argument(arg, context, ns, symtable, &ty, &mut errors, &mut cast_args);
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
    call_args_loc: Option<program::Loc>,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Option<Expression>, ()> {
    if let program::Expression::Variable(namespace) = var {
        if corelib::is_lib_func_call(Some(&namespace.name), &func.name) {
            if let Some(loc) = call_args_loc {
                diagnostics.push(Diagnostic::error(
                    loc,
                    "call arguments not allowed on builtins".to_string(),
                ));
                return Err(());
            }

            return Ok(Some(corelib::resolve_namespace_call(
                loc,
                &namespace.name,
                &func.name,
                args,
                context,
                ns,
                symtable,
                diagnostics,
            )?));
        }

          // library or base contract call
          if let Some(call_contract_no) = ns.resolve_contract(context.file_no, namespace) {
            if ns.contracts[call_contract_no].is_library() {
                if let Some(loc) = call_args_loc {
                    diagnostics.push(Diagnostic::error(
                        loc,
                        "call arguments not allowed on library calls".to_string(),
                    ));
                    return Err(());
                }

                return Ok(Some(function_call_pos_args(
                    loc,
                    &func,
                    args,
                    available_functions(
                        &func.name,
                        Some(call_contract_no),
                        ns,
                    ),
                    context,
                    ns,
                    resolve_to,
                    symtable,
                    diagnostics,
                )?));
            }
        }


    }

    Ok(None)
}

/// Check if the function is a method of a storage reference
/// Returns:
/// 1. Err, when there is an error
/// 2. Ok(Some()), when we have indeed received a method of a storage reference
/// 3. Ok(None), when we have not received a function that is a method of a
/// storage reference
fn try_storage_reference(
    var_expr: &Expression,
    func: &program::Identifier,
    args: &[program::Expression],
    context: &ExprContext,
    diagnostics: &mut Diagnostics,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    resolve_to: &ResolveTo,
) -> Result<Option<Expression>, ()> {
    if let Type::StorageRef(ty) = &var_expr.ty() {
        match ty.as_ref() {
            Type::Array(_, dim) => {
                if func.name == "push" {
                    if matches!(dim.last(), Some(ArrayLength::Fixed(_))) {
                        diagnostics.push(Diagnostic::error(
                            func.loc,
                            "method 'push()' not allowed on fixed length array".to_string(),
                        ));
                        return Err(());
                    }

                    let elem_ty = ty.array_elem();
                    let mut builtin_args = vec![var_expr.clone()];

                    let ret_ty = match args.len() {
                        1 => {
                            let expr = expression(
                                &args[0],
                                context,
                                ns,
                                symtable,
                                diagnostics,
                                ResolveTo::Type(&elem_ty),
                            )?;

                            builtin_args.push(expr.cast(
                                &args[0].loc(),
                                &elem_ty,
                                ns,
                                diagnostics,
                            )?);

                            Type::Void
                        }
                        0 => {
                            if elem_ty.is_reference_type(ns) {
                                Type::StorageRef(Box::new(elem_ty))
                            } else {
                                elem_ty
                            }
                        }
                        _ => {
                            diagnostics.push(Diagnostic::error(
                                func.loc,
                                "method 'push()' takes at most 1 argument".to_string(),
                            ));
                            return Err(());
                        }
                    };

                    return Ok(Some(Expression::LibFunction {
                        loc: func.loc,
                        tys: vec![ret_ty],
                        kind: LibFunc::ArrayPush,
                        args: builtin_args,
                    }));
                }
                if func.name == "pop" {
                    if matches!(dim.last(), Some(ArrayLength::Fixed(_))) {
                        diagnostics.push(Diagnostic::error(
                            func.loc,
                            "method 'pop()' not allowed on fixed length array".to_string(),
                        ));

                        return Err(());
                    }

                    if !args.is_empty() {
                        diagnostics.push(Diagnostic::error(
                            func.loc,
                            "method 'pop()' does not take any arguments".to_string(),
                        ));
                        return Err(());
                    }

                    let storage_elem = ty.storage_array_elem();
                    let elem_ty = storage_elem.deref_any();

                    let return_ty = if *resolve_to == ResolveTo::Discard {
                        Type::Void
                    } else {
                        elem_ty.clone()
                    };

                    return Ok(Some(Expression::LibFunction {
                        loc: func.loc,
                        tys: vec![return_ty],
                        kind: LibFunc::ArrayPop,
                        args: vec![var_expr.clone()],
                    }));
                }
            }

            Type::DynamicBytes => {
                if func.name == "push" {
                    let mut builtin_args = vec![var_expr.clone()];

                    let elem_ty = Type::Uint(32);

                    let ret_ty = match args.len() {
                        1 => {
                            let expr = expression(
                                &args[0],
                                context,
                                ns,
                                symtable,
                                diagnostics,
                                ResolveTo::Type(&elem_ty),
                            )?;

                            builtin_args.push(expr.cast(
                                &args[0].loc(),
                                &elem_ty,
                                ns,
                                diagnostics,
                            )?);

                            Type::Void
                        }
                        0 => elem_ty,
                        _ => {
                            diagnostics.push(Diagnostic::error(
                                func.loc,
                                "method 'push()' takes at most 1 argument".to_string(),
                            ));
                            return Err(());
                        }
                    };
                    return Ok(Some(Expression::LibFunction {
                        loc: func.loc,
                        tys: vec![ret_ty],
                        kind: LibFunc::ArrayPush,
                        args: builtin_args,
                    }));
                }

                if func.name == "pop" {
                    if !args.is_empty() {
                        diagnostics.push(Diagnostic::error(
                            func.loc,
                            "method 'pop()' does not take any arguments".to_string(),
                        ));
                        return Err(());
                    }

                    return Ok(Some(Expression::LibFunction {
                        loc: func.loc,
                        tys: vec![Type::Uint(32)],
                        kind: LibFunc::ArrayPop,
                        args: vec![var_expr.clone()],
                    }));
                }
            }
            _ => {}
        }
    }

    Ok(None)
}

/// Check if the function call is to a type's method
/// Returns:
/// 1. Err, when there is an error
/// 2. Ok(Some()), when we have indeed received a method of a type
/// 3. Ok(None), when we have received a function that is not a method of a type
fn try_type_method(
    loc: &program::Loc,
    func: &program::Identifier,
    args: &[program::Expression],
    call_args: &[&program::NamedArgument],
    context: &ExprContext,
    var_expr: &Expression,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Option<Expression>, ()> {
    let var_ty = var_expr.ty();

    match var_ty.deref_any() {
        Type::Array(..) | Type::DynamicBytes if var_ty.is_dynamic(ns) => {
            if func.name == "push" {
                let elem_ty = var_ty.array_elem();

                let val = match args.len() {
                    0 => {
                        return Ok(Some(Expression::LibFunction {
                            loc: *loc,
                            tys: vec![elem_ty.clone()],
                            kind: LibFunc::ArrayPush,
                            args: vec![var_expr.clone()],
                        }));
                    }
                    1 => {
                        let val_expr = expression(
                            &args[0],
                            context,
                            ns,
                            symtable,
                            diagnostics,
                            ResolveTo::Type(&elem_ty),
                        )?;

                        val_expr.cast(&args[0].loc(), &elem_ty, ns, diagnostics)?
                    }
                    _ => {
                        diagnostics.push(Diagnostic::error(
                            func.loc,
                            "method 'push()' takes at most 1 argument".to_string(),
                        ));
                        return Err(());
                    }
                };

                return Ok(Some(Expression::LibFunction {
                    loc: *loc,
                    tys: vec![elem_ty.clone()],
                    kind: LibFunc::ArrayPush,
                    args: vec![var_expr.clone(), val],
                }));
            }
            if func.name == "pop" {
                if !args.is_empty() {
                    diagnostics.push(Diagnostic::error(
                        func.loc,
                        "method 'pop()' does not take any arguments".to_string(),
                    ));
                    return Err(());
                }

                let elem_ty = match &var_ty {
                    Type::Array(ty, _) => ty,
                    _ => unreachable!(),
                };

                return Ok(Some(Expression::LibFunction {
                    loc: *loc,
                    tys: vec![*elem_ty.clone()],
                    kind: LibFunc::ArrayPop,
                    args: vec![var_expr.clone()],
                }));
            }

            if func.name == "concat" {
                if args.len() != 2 {
                    diagnostics.push(Diagnostic::error(
                        func.loc,
                        "method 'concat()' takes exactly 1 argument".to_string(),
                    ));
                    return Err(());
                }
            }
        }
        Type::Array(..) if func.name == "push" || func.name == "pop" => {
            diagnostics.push(Diagnostic::error(
                func.loc,
                format!(
                    "method {}() is not available for fixed length arrays",
                    func.name
                ),
            ));
            return Err(());
        }
        Type::Address => {
            let ty = match func.name.as_str() {
                "call" => Some(CallTy::Regular),
                "delegatecall" => Some(CallTy::Delegate),
                "staticcall" => Some(CallTy::Static),
                _ => None,
            };

            if let Some(ty) = ty {
                let call_args = parse_call_args(call_args, context, ns, symtable, diagnostics)?;

                if ty != CallTy::Regular && call_args.value.is_some() {
                    diagnostics.push(Diagnostic::error(
                        *loc,
                        format!("'{}' cannot have value specified", func.name,),
                    ));

                    return Err(());
                }

                if ty == CallTy::Delegate && call_args.gas.is_some() {
                    diagnostics.push(Diagnostic::warning(
                        *loc,
                        "'gas' specified on 'delegatecall' will be ignored".into(),
                    ));
                }

                if args.len() != 1 {
                    diagnostics.push(Diagnostic::error(
                        *loc,
                        format!(
                            "'{}' expects 1 argument, {} provided",
                            func.name,
                            args.len()
                        ),
                    ));

                    return Err(());
                }

                let args = expression(
                    &args[0],
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Type(&Type::DynamicBytes),
                )?;

                let args_ty = args.ty();

                match args_ty.deref_any() {
                    Type::DynamicBytes => (),
                    Type::Array(..) | Type::Struct(..) if !args_ty.is_dynamic(ns) => {}
                    _ => {
                        diagnostics.push(Diagnostic::error(
                            args.loc(),
                            format!("'{}' is not fixed length type", args_ty.to_string(ns),),
                        ));

                        return Err(());
                    }
                }

                let args = args.cast(&args.loc(), args_ty.deref_any(), ns, diagnostics)?;

                return Ok(Some(Expression::ExternalFunctionCallRaw {
                    loc: *loc,
                    ty,
                    args: Box::new(args),
                    address: Box::new(var_expr.cast(
                        &var_expr.loc(),
                        &Type::Address,
                        ns,
                        diagnostics,
                    )?),
                    call_args,
                }));
            }
        }

        _ => (),
    }

    Ok(None)
}

/// Parse call arguments for external calls
pub(super) fn parse_call_args(
    call_args: &[&program::NamedArgument],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<CallArgs, ()> {
    let mut args: HashMap<&String, &program::NamedArgument> = HashMap::new();

    for arg in call_args {
        if let Some(prev) = args.get(&arg.name.name) {
            diagnostics.push(Diagnostic::error_with_note(
                arg.loc,
                format!("'{}' specified multiple times", arg.name.name),
                prev.loc,
                format!("location of previous declaration of '{}'", arg.name.name),
            ));
            return Err(());
        }

        args.insert(&arg.name.name, arg);
    }

    let mut res = CallArgs::default();

    for arg in args.values() {
        match arg.name.name.as_str() {
            "value" => {
                let ty = Type::Uint(32);
                let expr = expression(
                    &arg.expr,
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Type(&ty),
                )?;

                res.value = Some(Box::new(expr.cast(
                    &arg.expr.loc(),
                    &ty,
                    ns,
                    diagnostics,
                )?));
            }
            "gas" => {
                let ty = Type::Uint(32);

                let expr = expression(
                    &arg.expr,
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Type(&ty),
                )?;

                res.gas = Some(Box::new(expr.cast(
                    &arg.expr.loc(),
                    &ty,
                    ns,
                    diagnostics,
                )?));
            }
            _ => {
                diagnostics.push(Diagnostic::error(
                    arg.loc,
                    format!("'{}' not a valid call parameter", arg.name.name),
                ));
                return Err(());
            }
        }
    }

    Ok(res)
}

/// Resolve a method call with positional arguments
pub(super) fn method_call_pos_args(
    loc: &program::Loc,
    var: &program::Expression,
    func: &program::Identifier,
    args: &[program::Expression],
    call_args: &[&program::NamedArgument],
    call_args_loc: Option<program::Loc>,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    if let Some(resolved_call) = try_namespace(
        loc,
        var,
        func,
        args,
        call_args_loc,
        context,
        ns,
        symtable,
        diagnostics,
        resolve_to,
    )? {
        return Ok(resolved_call);
    }

    let var_expr = expression(var, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;

    if let Some(expr) =
        corelib::resolve_method_call(&var_expr, func, args, context, ns, symtable, diagnostics)?
    {
        return Ok(expr);
    }

    if let Some(resolved_call) = try_storage_reference(
        &var_expr,
        func,
        args,
        context,
        diagnostics,
        ns,
        symtable,
        &resolve_to,
    )? {
        return Ok(resolved_call);
    }

    let mut diagnostics_type: u8 = 0;
    let type_method_diagnostics = Diagnostics::default();

    match try_type_method(
        loc,
        func,
        args,
        call_args,
        context,
        &var_expr,
        ns,
        symtable,
        diagnostics,
    ) {
        Ok(Some(resolved_call)) => {
            diagnostics.extend(type_method_diagnostics);
            return Ok(resolved_call);
        }
        Ok(None) => (),
        Err(()) => {
            // Adding one means diagnostics from type method
            diagnostics_type += 1;
        }
    }

    match diagnostics_type {
        1 => diagnostics.extend(type_method_diagnostics),
        // If 'diagnostics_type' is 2, we have errors from both type_method and resolve_using.
        _ => diagnostics.push(Diagnostic::error(
            func.loc,
            format!("method '{}' does not exist", func.name),
        )),
    }

    Err(())
}

/// Function call arguments
pub fn collect_call_args<'a>(
    expr: &'a program::Expression,
    diagnostics: &mut Diagnostics,
) -> Result<
    (
        &'a program::Expression,
        Vec<&'a program::NamedArgument>,
        Option<program::Loc>,
    ),
    (),
> {
    let mut named_arguments = Vec::new();
    let mut expr = expr;
    let mut loc: Option<program::Loc> = None;

    while let program::Expression::FunctionCallBlock(_, e, block) = expr {
        match block.as_ref() {
            program::Statement::Args(_, args) => {
                if let Some(program::Loc::File(file_no, start, _)) = loc {
                    loc = Some(program::Loc::File(file_no, start, block.loc().end()));
                } else {
                    loc = Some(block.loc());
                }

                named_arguments.extend(args);
            }
            program::Statement::Block { statements, .. } if statements.is_empty() => {
                // {}
                diagnostics.push(Diagnostic::error(
                    block.loc(),
                    "missing call arguments".to_string(),
                ));
                return Err(());
            }
            _ => {
                diagnostics.push(Diagnostic::error(
                    block.loc(),
                    "code block found where list of call arguments expected, like '{gas: 5000}'"
                        .to_string(),
                ));
                return Err(());
            }
        }

        expr = e;
    }

    Ok((expr, named_arguments, loc))
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
        program::Expression::New(_, ty) => new(loc, ty, args, context, ns, symtable, diagnostics)?,
        program::Expression::FunctionCallBlock(loc, expr, _)
            if matches!(expr.remove_parenthesis(), program::Expression::New(..)) =>
        {
            new(loc, ty, args, context, ns, symtable, diagnostics)?
        }
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
    let (ty, call_args, call_args_loc) = collect_call_args(ty, diagnostics)?;
    match ty.remove_parenthesis() {
        program::Expression::MemberAccess(_, member, func) => {
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "cannot call function in constant expression".to_string(),
                ));
                return Err(());
            }

            method_call_pos_args(
                loc,
                member,
                func,
                args,
                &call_args,
                call_args_loc,
                context,
                ns,
                symtable,
                diagnostics,
                resolve_to,
            )
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
    let (ty, _, call_args_loc) = collect_call_args(ty, diagnostics)?;
    match ty {
        program::Expression::Variable(id) => {
            if let Some(loc) = call_args_loc {
                diagnostics.push(Diagnostic::error(
                    loc,
                    "call arguments not permitted for internal calls".to_string(),
                ));
                return Err(());
            }
            function_call_named_args(
                loc,
                id,
                args,
                available_functions(&id.name, context.contract_no, ns),
                context,
                resolve_to,
                ns,
                symtable,
                diagnostics,
            )
        }
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

/// This function evaluates the arguments of a function call with either
/// positional arguments or named arguments.
fn evaluate_argument(
    arg: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    arg_ty: &Type,
    errors: &mut Diagnostics,
    cast_args: &mut Vec<Expression>,
) -> bool {
    expression(arg, context, ns, symtable, errors, ResolveTo::Type(arg_ty))
        .and_then(|arg| arg.cast(&arg.loc(), arg_ty, ns, errors))
        .map(|expr| cast_args.push(expr))
        .is_ok()
}
