use crate::sema::ast::{ArrayLength, Expression, Namespace, RetrieveType, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::expression::integers::bigint_to_expression;
use crate::sema::expression::resolve_expression::expression;
use crate::sema::expression::strings::unescape;
use crate::sema::expression::{ExprContext, ResolveTo};
use crate::sema::symtable::Symtable;
use crate::sema::unused_variable::used_variable;
use num_bigint::BigInt;
use num_traits::{FromPrimitive, Num};
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;
use ola_parser::program::{CodeLocation, Loc};
use std::str::FromStr;

use super::FIELD_ORDER;

pub(super) fn string_literal(
    v: &[program::StringLiteral],
    file_no: usize,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Expression {
    // Concatenate the strings
    let mut result = Vec::new();
    let mut loc = v[0].loc;
    for s in v {
        result.append(&mut unescape(
            &s.string,
            s.loc.start(),
            file_no,
            diagnostics,
        ));
        loc.use_end_from(&s.loc);
    }

    let length = result.len();

    match resolve_to {
        ResolveTo::Type(Type::String) => Expression::AllocDynamicBytes {
            loc,
            ty: Type::String,
            length: Box::new(Expression::NumberLiteral {
                loc,
                ty: Type::Uint(32),
                value: BigInt::from(length),
            }),
            init: Some(result),
        },
        _ => Expression::AllocDynamicBytes {
            loc,
            ty: Type::String,
            length: Box::new(Expression::NumberLiteral {
                loc,
                ty: Type::Uint(32),
                value: BigInt::from(length),
            }),
            init: Some(result),
        },
    }
}

pub(super) fn address_literal(
    loc: &program::Loc,
    address: &str,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let address = address.trim_end_matches("address");
    if !address.chars().any(|c| c == '_') && address.len() == 64 {
        let mut address_vec = Vec::new();
        for (_, chunk) in address.as_bytes().chunks(16).enumerate() {
            let address_chunk =
                u64::from_str_radix(std::str::from_utf8(chunk).unwrap(), 16).unwrap();
            // We need to check if each chunk exceeds the FIELD_ORDER.
            if address_chunk > FIELD_ORDER {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("address literal {} out of range", address),
                ));
                return Err(());
            } else {
                address_vec.push(BigInt::from_u64(address_chunk).unwrap());
            }
        }
        Ok(Expression::AddressLiteral {
            loc: *loc,
            ty: Type::Address,
            value: address_vec,
        })
    } else {
        diagnostics.push(Diagnostic::error(
            *loc,
            format!(
                "address literal {} incorrect length of {}",
                address,
                address.len()
            ),
        ));
        Err(())
    }
}

pub(super) fn hash_literal(
    loc: &program::Loc,
    hash: &str,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let hash = hash.trim_end_matches("hash");
    if !hash.chars().any(|c| c == '_') && hash.len() == 64 {
        let mut hash_vec = Vec::new();
        for (_, chunk) in hash.as_bytes().chunks(16).enumerate() {
            let hash_chunk = u64::from_str_radix(std::str::from_utf8(chunk).unwrap(), 16).unwrap();
            // We need to check if each chunk exceeds the FIELD_ORDER.
            if hash_chunk > FIELD_ORDER {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("hash literal {} out of range", hash),
                ));
                return Err(());
            } else {
                hash_vec.push(BigInt::from_u64(hash_chunk).unwrap());
            }
        }
        Ok(Expression::HashLiteral {
            loc: *loc,
            ty: Type::Hash,
            value: hash_vec,
        })
    } else {
        diagnostics.push(Diagnostic::error(
            *loc,
            format!("hash literal {} incorrect length of {}", hash, hash.len()),
        ));
        Err(())
    }
}

/// Resolve the given number literal, multiplied by value of unit
pub(super) fn number_literal(
    loc: &Loc,
    integer: &str,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let n = BigInt::from_str(integer).unwrap();
    bigint_to_expression(loc, &n, ns, diagnostics, resolve_to)
}

pub(super) fn hex_number_literal(
    loc: &Loc,
    n: &str,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    // from_str_radix does not like the 0x prefix

    bigint_to_expression(
        loc,
        &BigInt::from_str_radix(n, 16).unwrap(),
        ns,
        diagnostics,
        resolve_to,
    )
}

/// Resolve a function call with positional arguments
pub(super) fn struct_literal(
    loc: &Loc,
    n: &usize,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let struct_def = ns.structs[*n].clone();
    let ty = Type::Struct(*n);

    if args.len() != ns.structs[*n].fields.len() {
        diagnostics.push(Diagnostic::error(
            *loc,
            format!(
                "struct '{}' has {} fields, not {}",
                struct_def.name,
                struct_def.fields.len(),
                args.len()
            ),
        ));
        Err(())
    } else {
        let mut fields = Vec::new();

        for (i, a) in args.iter().enumerate() {
            let expr = expression(
                a,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&struct_def.fields[i].ty),
            )?;
            used_variable(ns, &expr, symtable);
            fields.push(expr.cast(loc, &struct_def.fields[i].ty, ns, diagnostics)?);
        }

        Ok(Expression::StructLiteral {
            loc: *loc,
            ty,
            values: fields,
        })
    }
}

/// Resolve a struct literal with named fields
pub(super) fn named_struct_literal(
    loc: &Loc,
    n: &usize,
    args: &[program::NamedArgument],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let struct_def = ns.structs[*n].clone();
    let ty = Type::Struct(*n);

    if args.len() != struct_def.fields.len() {
        diagnostics.push(Diagnostic::error(
            *loc,
            format!(
                "struct '{}' has {} fields, not {}",
                struct_def.name,
                struct_def.fields.len(),
                args.len()
            ),
        ));
        Err(())
    } else {
        let mut fields = Vec::new();
        fields.resize(
            args.len(),
            Expression::BoolLiteral {
                loc: Loc::Implicit,
                value: false,
            },
        );
        for a in args {
            match struct_def.fields.iter().enumerate().find(
                |(_, f)| f.id.as_ref().map(|id| id.name.as_str()) == Some(a.name.name.as_str())
            ) {
                Some((i, f)) => {
                    let expr = expression(
                        &a.expr,
                        context,
                        ns,
                        symtable,
                        diagnostics,
                        ResolveTo::Type(&f.ty),
                    )?;
                    used_variable(ns, &expr, symtable);
                    fields[i] = expr.cast(loc, &f.ty, ns, diagnostics)?;
                }
                None => {
                    diagnostics.push(Diagnostic::error(
                        a.name.loc,
                        format!(
                            "struct '{}' has no field '{}'",
                            struct_def.name, a.name.name,
                        ),
                    ));
                    return Err(());
                }
            }
        }
        Ok(Expression::StructLiteral {
            loc: *loc,
            ty,
            values: fields,
        })
    }
}

/// Given an parsed literal array, ensure that it is valid. All the elements in
/// the array must of the same type. The array might be a multidimensional
/// array; all the leaf nodes must match.
pub(super) fn array_literal(
    loc: &Loc,
    exprs: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut dimensions = Vec::new();
    let mut flattened = Vec::new();

    let resolve_to = match resolve_to {
        ResolveTo::Type(Type::Array(elem_ty, _)) => ResolveTo::Type(elem_ty),
        ResolveTo::Type(Type::Slice(slice)) if matches!(slice.as_ref(), Type::Slice(_)) => {
            let mut res = Vec::new();
            let mut has_errors = false;

            for expr in exprs {
                let expr = match expression(
                    expr,
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Type(&Type::Array(slice.clone(), vec![ArrayLength::Dynamic])),
                ) {
                    Ok(expr) => expr,
                    Err(_) => {
                        has_errors = true;
                        continue;
                    }
                };

                let ty = expr.ty();

                if let Type::Array(elem, dims) = &ty {
                    if elem != slice || dims.len() != 1 {
                        diagnostics.push(Diagnostic::error(
                            expr.loc(),
                            format!(
                                "type {} found where array {} expected",
                                elem.to_string(ns),
                                slice.to_string(ns)
                            ),
                        ));
                        has_errors = true;
                    }
                } else {
                    diagnostics.push(Diagnostic::error(
                        expr.loc(),
                        format!(
                            "type {} found where array of slices expected",
                            ty.to_string(ns)
                        ),
                    ));
                    has_errors = true;
                }

                res.push(expr);
            }

            return if has_errors {
                Err(())
            } else {
                let aty = Type::Array(
                    slice.clone(),
                    vec![ArrayLength::Fixed(BigInt::from(exprs.len()))],
                );

                Ok(Expression::ArrayLiteral {
                    loc: *loc,
                    ty: aty,
                    dimensions: vec![exprs.len() as u32],
                    values: res,
                })
            };
        }
        _ => resolve_to,
    };

    check_subarrays(
        exprs,
        &mut Some(&mut dimensions),
        &mut flattened,
        diagnostics,
    )?;

    if flattened.is_empty() {
        diagnostics
            .push(Diagnostic::error(*loc, "array requires at least one element".to_string()));
        return Err(());
    }

    let mut flattened = flattened.iter();

    let mut first = expression(
        flattened.next().unwrap(),
        context,
        ns,
        symtable,
        diagnostics,
        resolve_to,
    )?;

    let ty = if let ResolveTo::Type(ty) = resolve_to {
        first = first.cast(&first.loc(), ty, ns, diagnostics)?;

        ty.clone()
    } else {
        first.ty()
    };

    used_variable(ns, &first, symtable);
    let mut exprs = vec![first];

    for e in flattened {
        let mut other = expression(e, context, ns, symtable, diagnostics, ResolveTo::Type(&ty))?;
        used_variable(ns, &other, symtable);

        if other.ty() != ty {
            other = other.cast(&e.loc(), &ty, ns, diagnostics)?;
        }

        exprs.push(other);
    }

    let aty = Type::Array(
        Box::new(ty),
        dimensions
            .iter()
            .map(|n| ArrayLength::Fixed(BigInt::from_u32(*n).unwrap()))
            .collect::<Vec<ArrayLength>>(),
    );

    if context.constant {
        Ok(Expression::ConstArrayLiteral {
            loc: *loc,
            ty: aty,
            dimensions,
            values: exprs,
        })
    } else {
        Ok(Expression::ArrayLiteral {
            loc: *loc,
            ty: aty,
            dimensions,
            values: exprs,
        })
    }
}

/// Traverse the literal looking for sub arrays. Ensure that all the sub
/// arrays are the same length, and returned a flattened array of elements
pub(super) fn check_subarrays<'a>(
    exprs: &'a [program::Expression],
    dims: &mut Option<&mut Vec<u32>>,
    flatten: &mut Vec<&'a program::Expression>,
    diagnostics: &mut Diagnostics,
) -> Result<(), ()> {
    if let Some(program::Expression::ArrayLiteral(_, first)) = exprs.get(0) {
        // ensure all elements are array literals of the same length
        check_subarrays(first, dims, flatten, diagnostics)?;

        for (i, e) in exprs.iter().enumerate().skip(1) {
            if let program::Expression::ArrayLiteral(_, other) = e {
                if other.len() != first.len() {
                    diagnostics.push(Diagnostic::error(
                        e.loc(),
                        format!(
                            "array elements should be identical, sub array {} has {} elements rather than {}", i + 1, other.len(), first.len()
                        ),
                    ));
                    return Err(());
                }
                check_subarrays(other, &mut None, flatten, diagnostics)?;
            } else {
                diagnostics.push(Diagnostic::error(
                    e.loc(),
                    format!("array element {} should also be an array", i + 1),
                ));
                return Err(());
            }
        }
    } else {
        for (i, e) in exprs.iter().enumerate().skip(1) {
            if let program::Expression::ArrayLiteral(loc, _) = e {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!(
                        "array elements should be of the type, element {} is unexpected array",
                        i + 1
                    ),
                ));
                return Err(());
            }
        }
        flatten.extend(exprs);
    }

    if let Some(dims) = dims.as_deref_mut() {
        dims.push(exprs.len() as u32);
    }

    Ok(())
}
