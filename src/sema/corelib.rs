// SPDX-License-Identifier: Apache-2.0

use super::ast::{ArrayLength, Diagnostic, Expression, LibFunc, Namespace, Type};
use super::diagnostics::Diagnostics;
use super::expression::{ExprContext, ResolveTo};
use super::symtable::Symtable;
use crate::sema::expression::resolve_expression::expression;
use crate::sema::ast::{RetrieveType};
use num_bigint::BigInt;
use ola_parser::program::{self, CodeLocation};
use once_cell::sync::Lazy;
use tiny_keccak::{Keccak, Hasher};

pub struct Prototype {
    pub libfunc: LibFunc,
    pub namespace: Option<&'static str>,
    pub name: &'static str,
    pub params: Vec<Type>,
    pub ret: Vec<Type>,
}

// A list of all Ola lib functions
static LIB_FUNCTIONS: Lazy<[Prototype; 13]> = Lazy::new(|| {
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
                vec![ArrayLength::Dynamic],
            )],
            ret: vec![Type::Array(
                Box::new(Type::Uint(32)),
                vec![ArrayLength::Dynamic],
            )],
        },
        Prototype {
            libfunc: LibFunc::Assert,
            namespace: None,
            name: "assert",
            params: vec![Type::Bool],
            ret: vec![Type::Void],
        },
        Prototype {
            libfunc: LibFunc::Assert,
            namespace: None,
            name: "assert",
            params: vec![Type::Bool, Type::String],
            ret: vec![Type::Void],
        },
        Prototype {
            libfunc: LibFunc::CallerAddress,
            namespace: None,
            name: "caller_address",
            params: vec![],
            ret: vec![Type::Address],
        },
        Prototype {
            libfunc: LibFunc::OriginAddress,
            namespace: None,
            name: "origin_address",
            params: vec![],
            ret: vec![Type::Address],
        },
        Prototype {
            libfunc: LibFunc::CodeAddress,
            namespace: None,
            name: "code_address",
            params: vec![],
            ret: vec![Type::Address],
        },
        Prototype {
            libfunc: LibFunc::PoseidonHash,
            namespace: None,
            name: "poseidon_hash",
            params: vec![Type::DynamicBytes],
            ret: vec![Type::Hash],
        },
        Prototype {
            libfunc: LibFunc::ChainId,
            namespace: None,
            name: "chain_id",
            params: vec![],
            ret: vec![Type::Uint(32)],
        },
        Prototype {
            libfunc: LibFunc::AbiEncode,
            namespace: Some("abi"),
            name: "encode",
            params: vec![],
            ret: vec![],
        },
        Prototype {
            libfunc: LibFunc::FieldsConcat,
            namespace: None,
            name: "fields_concat",
            params: vec![],
            ret: vec![],
        },
        Prototype {
            libfunc: LibFunc::AbiDecode,
            namespace: Some("abi"),
            name: "decode",
            params: vec![Type::DynamicBytes],
            ret: vec![],
        },
        Prototype {
            libfunc: LibFunc::AbiEncodeWithSignature,
            namespace: Some("abi"),
            name: "encodeWithSignature",
            params: vec![Type::String],
            ret: vec![],
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
            return Ok(Expression::LibFunction {
                loc: *loc,
                tys: func.ret.to_vec(),
                kind: func.libfunc,
                args: cast_args,
            });
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
pub(super) fn resolve_namespace_call(
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
        "decode" => LibFunc::AbiDecode,
        "encode" => LibFunc::AbiEncode,
        "encodeWithSignature" => LibFunc::AbiEncodeWithSignature,
    
        _ => unreachable!(),
    };

    if builtin == LibFunc::AbiDecode {
        if args.len() != 2 {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("function expects {} arguments, {} provided", 2, args.len()),
            ));

            return Err(());
        }

        // first args
        let data = expression(
            &args[0],
            context,
            ns,
            symtable,
            diagnostics,
            ResolveTo::Type(&Type::DynamicBytes),
        )?
        .cast(&args[0].loc(), &Type::DynamicBytes,  ns, diagnostics)?;

        let mut tys = Vec::new();
        let mut broken = false;

        match &args[1] {
            program::Expression::List(_, list) => {
                for (loc, param) in list {
                    if let Some(param) = param {
                        let ty = ns.resolve_type(
                            context.file_no,
                            context.contract_no,
                            &param.ty,
                            diagnostics,
                        )?;

                        if let Some(name) = &param.name {
                            diagnostics.push(Diagnostic::error(
                                name.loc,
                                format!("unexpected identifier '{}' in type", name.name),
                            ));
                            broken = true;
                        }

                        if ty.is_mapping() || ty.is_recursive(ns) {
                            diagnostics.push(Diagnostic::error(
                                *loc,
                        format!("Invalid type '{}': mappings and recursive types cannot be abi decoded or encoded", ty.to_string(ns)))
                            );
                            broken = true;
                        }

                        tys.push(ty);
                    } else {
                        diagnostics.push(Diagnostic::error(*loc, "missing type".to_string()));

                        broken = true;
                    }
                }
            }
            _ => {
                let ty = ns.resolve_type(
                    context.file_no,
                    context.contract_no,
                    args[1].remove_parenthesis(),
                    diagnostics,
                )?;

                if ty.is_mapping() || ty.is_recursive(ns) {
                    diagnostics.push(Diagnostic::error(
                        *loc,
                        format!("Invalid type '{}': mappings and recursive types cannot be abi decoded or encoded", ty.to_string(ns))
                    ));
                    broken = true;
                }

                tys.push(ty);
            }
        }

        return if broken {
            Err(())
        } else {
            Ok(Expression::LibFunction {
                loc: *loc,
                tys,
                kind: builtin,
                args: vec![data],
            })
        };
    }

    let mut resolved_args = Vec::new();
    let mut args_iter = args.iter();

    match builtin {

        LibFunc::AbiEncodeWithSignature => {
            // first argument is signature
            if let Some(signature) = args_iter.next() {
                let function_selector;
                match signature {
                    program::Expression::StringLiteral(s) => {
                        let function_name = &s[0].string;
                            // keccak hash the signature
                            let mut hasher = Keccak::v256();
                            let mut hash = [0u8; 32];
                            hasher.update(function_name.as_bytes());
                            hasher.finalize(&mut hash);
                    
                            function_selector = u32::from_le_bytes(hash[0..4].try_into().unwrap())
                        }
                    
                    _ => {
                        diagnostics.push(Diagnostic::error(
                            *loc,
                            "function signature must be a string literal".to_string(),
                        ));
                        return Err(());
                    }
                    
                }
                resolved_args.insert(
                    0,
                    Expression::NumberLiteral {
                        loc: *loc,
                        ty: Type::Uint(32),
                        value: BigInt::from(function_selector),
                    }
                );
            } else {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "function requires one 'string' signature argument".to_string(),
                ));

                return Err(());
            }
        }
        _ => (),
    }

    for arg in args_iter {
        let mut expr = expression(arg, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;
        let ty = expr.ty();

        if ty.is_mapping() || ty.is_recursive(ns) {
            diagnostics.push(Diagnostic::error(
                arg.loc(),
                format!("Invalid type '{}': mappings and recursive types cannot be abi decoded or encoded", ty.to_string(ns)),
            ));

            return Err(());
        }

        expr = expr.cast(&arg.loc(), ty.deref_any(),  ns, diagnostics)?;

        // A string or hex literal should be encoded as a string
        if let Expression::BytesLiteral { .. } = &expr {
            expr = expr.cast(&arg.loc(), &Type::String,  ns, diagnostics)?;
        }

        resolved_args.push(expr);
    }

    Ok(Expression::LibFunction {
        loc: *loc,
        tys: vec![Type::DynamicBytes],
        kind: builtin,
        args: resolved_args,
    })
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

            return Ok(Some(Expression::LibFunction {
                loc: id.loc,
                tys: returns,
                kind: func.libfunc,
                args: cast_args,
            }));
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
