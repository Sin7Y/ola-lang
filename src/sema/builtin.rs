// SPDX-License-Identifier: Apache-2.0

use super::ast::{
    ArrayLength, Builtin, Diagnostic, Expression, File, Function, Namespace, Parameter, Symbol,
    Type,
};
use super::diagnostics::Diagnostics;
use super::eval::eval_const_number;
use super::expression::{expression, ExprContext, ResolveTo};
use super::symtable::Symtable;
use crate::sema::ast::{RetrieveType, UserTypeDecl};
use num_bigint::BigInt;
use num_traits::One;
use ola_parser::program::CodeLocation;
use ola_parser::program::{self, Identifier};
use once_cell::sync::Lazy;
use std::path::PathBuf;

pub struct Prototype {
    pub builtin: Builtin,
    pub namespace: Option<&'static str>,
    pub method: Option<Type>,
    pub name: &'static str,
    pub params: Vec<Type>,
    pub ret: Vec<Type>,
    pub doc: &'static str,
    // Can this function be called in constant context (e.g. hash functions)
    pub constant: bool,
}

// A list of all Solidity builtins functions
static BUILTIN_FUNCTIONS: Lazy<[Prototype; 1]> = Lazy::new(|| {
    [Prototype {
        builtin: Builtin::PoseidonHash,
        namespace: None,
        method: None,
        name: "hash",
        params: vec![Type::Bool],
        ret: vec![Type::U256],
        doc: "Abort execution if argument evaluates to false",
        constant: false,
    }]
});

// A list of all Solidity builtins variables
static BUILTIN_VARIABLE: Lazy<[Prototype; 0]> = Lazy::new(|| []);

// A list of all Solidity builtins methods
static BUILTIN_METHODS: Lazy<[Prototype; 0]> = Lazy::new(|| []);

/// Does function call match builtin
pub fn is_builtin_call(namespace: Option<&str>, fname: &str, ns: &Namespace) -> bool {
    BUILTIN_FUNCTIONS
        .iter()
        .any(|p| p.name == fname && p.namespace == namespace)
}

/// Get the prototype for a builtin. If the prototype has arguments, it is a function else
/// it is a variable.
pub fn get_prototype(builtin: Builtin) -> Option<&'static Prototype> {
    BUILTIN_FUNCTIONS
        .iter()
        .find(|p| p.builtin == builtin)
        .or_else(|| BUILTIN_VARIABLE.iter().find(|p| p.builtin == builtin))
        .or_else(|| BUILTIN_METHODS.iter().find(|p| p.builtin == builtin))
}

/// Does variable name match builtin
pub fn builtin_var(
    loc: &program::Loc,
    namespace: Option<&str>,
    fname: &str,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Option<(Builtin, Type)> {
    if let Some(p) = BUILTIN_VARIABLE
        .iter()
        .find(|p| p.name == fname && p.namespace == namespace)
    {
        return Some((p.builtin, p.ret[0].clone()));
    }

    None
}

/// Does variable name match any builtin namespace
pub fn builtin_namespace(namespace: &str) -> bool {
    BUILTIN_VARIABLE
        .iter()
        .any(|p| p.namespace == Some(namespace))
}

/// Is name reserved for builtins
pub fn is_reserved(fname: &str) -> bool {
    if fname == "type" || fname == "super" {
        return true;
    }

    let is_builtin_function = BUILTIN_FUNCTIONS.iter().any(|p| {
        (p.name == fname && p.namespace.is_none() && p.method.is_none())
            || (p.namespace == Some(fname))
    });

    if is_builtin_function {
        return true;
    }

    BUILTIN_VARIABLE.iter().any(|p| {
        (p.name == fname && p.namespace.is_none() && p.method.is_none())
            || (p.namespace == Some(fname))
    })
}

/// Resolve a builtin call
pub fn resolve_call(
    loc: &program::Loc,
    namespace: Option<&str>,
    id: &str,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let funcs = BUILTIN_FUNCTIONS
        .iter()
        .filter(|p| p.name == id && p.namespace == namespace && p.method.is_none())
        .collect::<Vec<&Prototype>>();
    let mut errors: Diagnostics = Diagnostics::default();

    for func in &funcs {
        let mut matches = true;

        if context.constant && !func.constant {
            errors.push(Diagnostic::cast_error(
                *loc,
                format!(
                    "cannot call function '{}' in constant expression",
                    func.name
                ),
            ));
            matches = false;
        }

        if func.params.len() != args.len() {
            errors.push(Diagnostic::cast_error(
                *loc,
                format!(
                    "builtin function '{}' expects {} arguments, {} provided",
                    func.name,
                    func.params.len(),
                    args.len()
                ),
            ));
            matches = false;
        }

        let mut cast_args = Vec::new();

        // check if arguments can be implicitly casted
        for (i, arg) in args.iter().enumerate() {
            let ty = func.params.get(i);

            let arg = match expression(
                arg,
                context,
                ns,
                symtable,
                &mut errors,
                ty.map(ResolveTo::Type).unwrap_or(ResolveTo::Unknown),
            ) {
                Ok(e) => e,
                Err(()) => {
                    matches = false;
                    continue;
                }
            };

            if let Some(ty) = ty {
                cast_args.push(arg);
            }
        }

        if !matches {
            if funcs.len() > 1 && diagnostics.extend_non_casting(&errors) {
                return Err(());
            }
        } else {
            return Ok(Expression::Builtin(
                *loc,
                func.ret.to_vec(),
                func.builtin,
                cast_args,
            ));
        }
    }

    if funcs.len() != 1 {
        diagnostics.push(Diagnostic::error(
            *loc,
            "cannot find overloaded function which matches signature".to_string(),
        ));
    } else {
        diagnostics.extend(errors);
    }

    Err(())
}

/// Resolve a builtin namespace call. The takes the unresolved arguments, since it has
/// to handle the special case "abi.decode(foo, (int32, bool, address))" where the
/// second argument is a type list. The generic expression resolver cannot deal with
/// this. It is only used in for this specific call.
pub fn resolve_namespace_call(
    loc: &program::Loc,
    namespace: &str,
    name: &str,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    // The abi.* functions need special handling, others do not
    if namespace != "abi" {
        return resolve_call(
            loc,
            Some(namespace),
            name,
            args,
            context,
            ns,
            symtable,
            diagnostics,
        );
    }

    let builtin = match name {
        "hash" => Builtin::PoseidonHash,
        _ => unreachable!(),
    };

    let mut resolved_args = Vec::new();
    let mut args_iter = args.iter();

    for arg in args_iter {
        let mut expr = expression(arg, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;

        resolved_args.push(expr);
    }

    Ok(Expression::Builtin(
        *loc,
        vec![Type::Bool],
        builtin,
        resolved_args,
    ))
}

/// Resolve a builtin call
pub fn resolve_method_call(
    expr: &Expression,
    id: &program::Identifier,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Option<Expression>, ()> {
    let expr_ty = expr.ty();
    let funcs: Vec<_> = BUILTIN_METHODS
        .iter()
        .filter(|func| func.name == id.name && func.method.as_ref() == Some(&expr_ty))
        .collect();
    let mut errors = Diagnostics::default();

    for func in &funcs {
        let mut matches = true;

        if context.constant && !func.constant {
            diagnostics.push(Diagnostic::cast_error(
                id.loc,
                format!(
                    "cannot call function '{}' in constant expression",
                    func.name
                ),
            ));
            matches = false;
        }

        if func.params.len() != args.len() {
            errors.push(Diagnostic::cast_error(
                id.loc,
                format!(
                    "builtin function '{}' expects {} arguments, {} provided",
                    func.name,
                    func.params.len(),
                    args.len()
                ),
            ));
            matches = false;
        }

        let mut cast_args = Vec::new();

        // check if arguments can be implicitly casted
        for (i, arg) in args.iter().enumerate() {
            // we may have arguments that parameters
            let ty = func.params.get(i);

            let arg = match expression(
                arg,
                context,
                ns,
                symtable,
                &mut errors,
                ty.map(ResolveTo::Type).unwrap_or(ResolveTo::Unknown),
            ) {
                Ok(e) => e,
                Err(()) => {
                    matches = false;
                    continue;
                }
            };

            if let Some(ty) = ty {
                cast_args.push(arg);
            }
        }

        if !matches {
            if funcs.len() > 1 && diagnostics.extend_non_casting(&errors) {
                return Err(());
            }
        } else {
            cast_args.insert(0, expr.clone());

            let returns = if func.ret.is_empty() {
                vec![Type::Void]
            } else {
                func.ret.to_vec()
            };

            return Ok(Some(Expression::Builtin(
                id.loc,
                returns,
                func.builtin,
                cast_args,
            )));
        }
    }

    match funcs.len() {
        0 => Ok(None),
        1 => {
            diagnostics.extend(errors);

            Err(())
        }
        _ => {
            diagnostics.push(Diagnostic::error(
                id.loc,
                "cannot find overloaded function which matches signature".to_string(),
            ));

            Err(())
        }
    }
}

impl Namespace {}
