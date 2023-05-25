// SPDX-License-Identifier: Apache-2.0

use super::ast::{ArrayLength, Diagnostic, Expression, LibFunc, Namespace, Type};
use super::diagnostics::Diagnostics;
use super::expression::{expression, ExprContext, ResolveTo};
use super::symtable::Symtable;

use ola_parser::program::{self, CodeLocation};
use once_cell::sync::Lazy;

pub struct Prototype {
    pub libfunc: LibFunc,
    pub namespace: Option<&'static str>,
    pub name: &'static str,
    pub params: Vec<Type>,
    pub ret: Vec<Type>,
}

// A list of all Ola lib functions
static LIB_FUNCTIONS: Lazy<[Prototype; 2]> = Lazy::new(|| {
    [
        Prototype {
            libfunc: LibFunc::U32Sqrt,
            namespace: None,
            name: "u32_sqrt",
            params: vec![Type::Uint(32)],
            ret: vec![Type::Uint(32)],
        },
        Prototype {
            libfunc: LibFunc::ArraySort,
            namespace: None,
            name: "u32_array_sort",
            params: vec![Type::Array(
                Box::new(Type::Uint(32)),
                vec![ArrayLength::AnyFixed],
            )],
            ret: vec![Type::Array(
                Box::new(Type::Uint(32)),
                vec![ArrayLength::AnyFixed],
            )],
        },
    ]
});

// A list of all Ola lib variables
static LIB_VARIABLE: Lazy<[Prototype; 0]> = Lazy::new(|| []);

// A list of all Ola lib methods
static LIB_METHODS: Lazy<[Prototype; 0]> = Lazy::new(|| []);

/// Does function call match lib function
pub fn is_lib_func_call(namespace: Option<&str>, fname: &str) -> bool {
    LIB_FUNCTIONS
        .iter()
        .any(|p| p.name == fname && p.namespace == namespace)
}

/// Does variable name match any builtin namespace
pub fn lib_namespace(namespace: &str) -> bool {
    LIB_VARIABLE.iter().any(|p| p.namespace == Some(namespace))
}

/// Is name reserved for lib function
pub fn is_reserved(fname: &str) -> bool {
    if fname == "type" || fname == "super" {
        return true;
    }

    let is_lib_function = LIB_FUNCTIONS
        .iter()
        .any(|p| (p.name == fname && p.namespace.is_none()) || (p.namespace == Some(fname)));

    if is_lib_function {
        return true;
    }

    LIB_VARIABLE
        .iter()
        .any(|p| (p.name == fname && p.namespace.is_none()) || (p.namespace == Some(fname)))
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
    let funcs = LIB_FUNCTIONS
        .iter()
        .filter(|p| p.name == id && p.namespace == namespace)
        .collect::<Vec<&Prototype>>();
    let mut errors: Diagnostics = Diagnostics::default();

    for func in &funcs {
        let mut matches = true;

        if context.constant {
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
                match arg.cast(&arg.loc(), ty, ns, &mut errors) {
                    Ok(expr) => cast_args.push(expr),
                    Err(()) => {
                        matches = false;
                    }
                }
            }
        }

        if !matches {
            if funcs.len() > 1 && diagnostics.extend_non_casting(&errors) {
                return Err(());
            }
        } else {
            ns.called_lib_functions.push(id.to_string());
            return Ok(Expression::LibFunction(
                *loc,
                func.ret.to_vec(),
                func.libfunc,
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
    let funcs: Vec<_> = LIB_METHODS
        .iter()
        .filter(|func| func.name == id.name)
        .collect();
    let mut errors = Diagnostics::default();

    for func in &funcs {
        let mut matches = true;

        if context.constant {
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

            if ty.is_some() {
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

            return Ok(Some(Expression::LibFunction(
                id.loc,
                returns,
                func.libfunc,
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
