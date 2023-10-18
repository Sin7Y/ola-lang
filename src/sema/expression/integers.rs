use std::cmp;

use crate::sema::ast::{Expression, Namespace, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::expression::ResolveTo;
use num_bigint::BigInt;
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;

pub(super) fn coerce(
    l: &Type,
    l_loc: &program::Loc,
    r: &Type,
    r_loc: &program::Loc,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Type, ()> {
    let l = match l {
        Type::Ref(ty) => ty,
        Type::StorageRef(ty) => ty,
        _ => l,
    };
    let r = match r {
        Type::Ref(ty) => ty,
        Type::StorageRef(ty) => ty,
        _ => r,
    };
    if *l == *r {
        return Ok(l.clone());
    }

    coerce_number(l, l_loc, r, r_loc, ns, diagnostics)
}

/// Calculate the number of bits and the sign of a type, or generate a
/// diagnostic that the type that is not allowed.
pub(super) fn type_bits(
    l: &Type,
    l_loc: &program::Loc,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<u16, ()> {
    match l {
        Type::Uint(n) => Ok(*n),
        Type::Field => Ok(32),
        Type::Enum(n) => {
            diagnostics.push(Diagnostic::error(
                *l_loc,
                format!("type enum {} not allowed", ns.enums[*n]),
            ));
            Err(())
        }
        Type::Struct(no) => {
            diagnostics.push(Diagnostic::error(
                *l_loc,
                format!("type struct {} not allowed", ns.structs[*no].name),
            ));
            Err(())
        }
        Type::Array(..) => {
            diagnostics.push(Diagnostic::error(
                *l_loc,
                format!("type array {} not allowed", l.to_string(ns)),
            ));
            Err(())
        }
        Type::Ref(n) => type_bits(n, l_loc, ns, diagnostics),
        Type::StorageRef(n) => type_bits(n, l_loc, ns, diagnostics),
        _ => {
            diagnostics.push(Diagnostic::error(
                *l_loc,
                format!("expression of type {} not allowed", l.to_string(ns)),
            ));
            Err(())
        }
    }
}

pub fn coerce_number(
    l: &Type,
    l_loc: &program::Loc,
    r: &Type,
    r_loc: &program::Loc,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Type, ()> {
    let l = match l {
        Type::Ref(ty) => ty,
        Type::StorageRef(ty) => ty,
        _ => l,
    };
    let r = match r {
        Type::Ref(ty) => ty,
        Type::StorageRef(ty) => ty,
        _ => r,
    };
    match (l, r) {
        (Type::Contract(left), Type::Contract(right)) if left == right => {
            return Ok(Type::Contract(*left));
        }
        (Type::Address, Type::Address) => {
            return Ok(Type::Address);
        }
        _ => (),
    }

    let left_len = type_bits(l, l_loc, ns, diagnostics)?;

    let right_len = type_bits(r, r_loc, ns, diagnostics)?;

    Ok(Type::Uint(cmp::max(left_len, right_len)))
}

/// Try to convert a BigInt into a Expression::NumberLiteral.
pub fn bigint_to_expression(
    loc: &program::Loc,
    n: &BigInt,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let bits = n.bits();

    if let ResolveTo::Type(resolve_to) = resolve_to {
        if *resolve_to != Type::Unresolved {
            if !resolve_to.is_integer(ns) {
                diagnostics.push(Diagnostic::cast_error(
                    *loc,
                    format!("expected '{}', found integer", resolve_to.to_string(ns)),
                ));
                return Err(());
            } else {
                return Ok(Expression::NumberLiteral {
                    loc: *loc,
                    ty: resolve_to.clone(),
                    value: n.clone(),
                });
            }
        }
    }

    // Return smallest type

    if bits > 256 {
        diagnostics.push(Diagnostic::error(*loc, format!("{} is too large", n)));
        Err(())
    } else {
        Ok(Expression::NumberLiteral {
            loc: *loc,
            ty: Type::Uint(32),
            value: n.clone(),
        })
    }
}
