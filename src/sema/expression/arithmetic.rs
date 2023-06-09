// SPDX-License-Identifier: Apache-2.0
use crate::sema::ast::{Expression, Namespace, RetrieveType, StringLocation, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::expression::integers::{coerce, coerce_number, type_bits};
use crate::sema::expression::resolve_expression::expression;
use crate::sema::expression::{ExprContext, ResolveTo};
use crate::sema::symtable::Symtable;
use crate::sema::unused_variable::{check_var_usage_expression, used_variable};
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;
use ola_parser::program::CodeLocation;

pub(super) fn subtract(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::Subtract {
        loc: *loc,
        ty: ty.clone(),
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

pub(super) fn bitwise_or(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::BitwiseOr {
        loc: *loc,
        ty: ty.clone(),
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

pub(super) fn bitwise_and(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::BitwiseAnd {
        loc: *loc,
        ty: ty.clone(),
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

pub(super) fn bitwise_xor(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::BitwiseXor {
        loc: *loc,
        ty: ty.clone(),
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

pub(super) fn shift_left(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;

    check_var_usage_expression(ns, &left, &right, symtable);
    // left hand side may be bytes/int/uint
    // right hand size may be int/uint
    let _ = type_bits(&left.ty(), &l.loc(), ns, diagnostics)?;
    let right_length = type_bits(&right.ty(), &r.loc(), ns, diagnostics)?;

    let left_type = left.ty().deref_any().clone();

    Ok(Expression::ShiftLeft {
        loc: *loc,
        ty: left_type.clone(),
        left: Box::new(left.cast(loc, &left_type, ns, diagnostics)?),
        right: Box::new(cast_shift_arg(loc, right, right_length, &left_type, ns)),
    })
}

pub(super) fn shift_right(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let left_type = left.ty();
    // left hand side may be bytes/int/uint
    // right hand size may be int/uint
    let _ = type_bits(&left_type, &l.loc(), ns, diagnostics)?;
    let right_length = type_bits(&right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::ShiftRight {
        loc: *loc,
        ty: left_type.clone(),
        left: Box::new(left),
        right: Box::new(cast_shift_arg(loc, right, right_length, &left_type, ns)),
    })
}

pub(super) fn multiply(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

    // If we don't know what type the result is going to be, make any possible
    // result fit.
    if resolve_to == ResolveTo::Unknown {
        let bits = std::cmp::min(256, ty.bits(ns) * 2);
        multiply(
            loc,
            l,
            r,
            context,
            ns,
            symtable,
            diagnostics,
            ResolveTo::Type(&Type::Uint(bits)),
        )
    } else {
        Ok(Expression::Multiply {
            loc: *loc,
            ty: ty.clone(),
            left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
            right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
        })
    }
}

pub(super) fn divide(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::Divide {
        loc: *loc,
        ty: ty.clone(),
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

pub(super) fn modulo(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::Modulo {
        loc: *loc,
        ty: ty.clone(),
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

pub(super) fn power(
    loc: &program::Loc,
    b: &program::Expression,
    e: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut base = expression(b, context, ns, symtable, diagnostics, resolve_to)?;

    // If we don't know what type the result is going to be, assume
    // the result is 256 bits
    if resolve_to == ResolveTo::Unknown {
        base = expression(
            b,
            context,
            ns,
            symtable,
            diagnostics,
            ResolveTo::Type(&Type::Uint(256)),
        )?;
    }

    let exp = expression(e, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &base, &exp, symtable);

    let base_type = base.ty();
    let exp_type = exp.ty();

    let ty = coerce_number(&base_type, &b.loc(), &exp_type, &e.loc(), ns, diagnostics)?;

    Ok(Expression::Power {
        loc: *loc,
        ty: ty.clone(),
        base: Box::new(base.cast(&b.loc(), &ty, ns, diagnostics)?),
        exp: Box::new(exp.cast(&e.loc(), &ty, ns, diagnostics)?),
    })
}

/// Test for equality; first check string equality, then integer equality
pub(super) fn equal(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
    let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let left_type = left.ty();
    let right_type = right.ty();

    let ty = coerce(&left_type, &l.loc(), &right_type, &r.loc(), ns, diagnostics)?;
    Ok(Expression::Equal {
        loc: *loc,
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

/// Test for equality; first check string equality, then integer equality
pub(super) fn not_equal(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
    let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;

    check_var_usage_expression(ns, &left, &right, symtable);

    let left_type = left.ty();
    let right_type = right.ty();

    let ty = coerce(&left_type, &l.loc(), &right_type, &r.loc(), ns, diagnostics)?;
    Ok(Expression::NotEqual {
        loc: *loc,
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

/// If the left and right arguments are part of string comparison, return
/// a string comparision expression, else None.
pub(super) fn is_string_equal(
    loc: &program::Loc,
    left: &Expression,
    left_type: &Type,
    right: &Expression,
    right_type: &Type,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Option<Expression>, ()> {
    // compare string
    match (&left_type.deref_any(), &right_type.deref_any()) {
        (Type::String, Type::String) => {
            return Ok(Some(Expression::StringCompare {
                loc: *loc,
                left: StringLocation::RunTime(Box::new(left.cast(
                    &left.loc(),
                    left_type.deref_any(),
                    ns,
                    diagnostics,
                )?)),
                right: StringLocation::RunTime(Box::new(right.cast(
                    &right.loc(),
                    right_type.deref_any(),
                    ns,
                    diagnostics,
                )?)),
            }));
        }
        _ => {}
    }

    Ok(None)
}

pub(super) fn addition(
    loc: &program::Loc,
    l: &program::Expression,
    r: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
    let mut right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;
    check_var_usage_expression(ns, &left, &right, symtable);

    let left_type = left.ty();
    let right_type = right.ty();

    let ty = coerce_number(&left_type, &l.loc(), &right_type, &r.loc(), ns, diagnostics)?;

    // If we don't know what type the result is going to be
    if resolve_to == ResolveTo::Unknown {
        let bits = std::cmp::min(256, ty.bits(ns) * 2);
        let resolve_to = Type::Uint(bits);

        left = expression(
            l,
            context,
            ns,
            symtable,
            diagnostics,
            ResolveTo::Type(&resolve_to),
        )?;
        right = expression(
            r,
            context,
            ns,
            symtable,
            diagnostics,
            ResolveTo::Type(&resolve_to),
        )?;
    }

    Ok(Expression::Add {
        loc: *loc,
        ty: ty.clone(),
        left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    })
}

/// Resolve an increment/decrement with an operator
pub(super) fn incr_decr(
    v: &program::Expression,
    expr: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let op = |e: Expression, ty: Type| -> Expression {
        match expr {
            program::Expression::Increment(loc, _) => Expression::Increment {
                loc: *loc,
                ty,
                expr: Box::new(e),
            },
            program::Expression::Decrement(loc, _) => Expression::Decrement {
                loc: *loc,
                ty,
                expr: Box::new(e),
            },
            _ => unreachable!(),
        }
    };

    let mut context = context.clone();

    context.lvalue = true;

    let var = expression(v, &context, ns, symtable, diagnostics, ResolveTo::Unknown)?;
    used_variable(ns, &var, symtable);
    let var_ty = var.ty();

    match &var {
        Expression::ConstantVariable {
            loc,
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
            Err(())
        }
        Expression::ConstantVariable {
            loc,
            contract_no: None,
            var_no,
            ..
        } => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("cannot assign to constant '{}'", ns.constants[*var_no].name),
            ));
            Err(())
        }
        Expression::Variable { ty, var_no, .. } => {
            match ty {
                Type::Uint(_) => (),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        var.loc(),
                        format!(
                            "variable '{}' of incorrect type {}",
                            symtable.get_name(*var_no),
                            var_ty.to_string(ns)
                        ),
                    ));
                    return Err(());
                }
            };
            Ok(op(var.clone(), ty.clone()))
        }
        _ => match &var_ty {
            Type::Ref(r_ty) => match r_ty.as_ref() {
                Type::Uint(_) => Ok(op(var, r_ty.as_ref().clone())),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        var.loc(),
                        format!("assigning to incorrect type {}", r_ty.to_string(ns)),
                    ));
                    Err(())
                }
            },
            Type::StorageRef(r_ty) => match r_ty.as_ref() {
                Type::Uint(_) => Ok(op(var, r_ty.as_ref().clone())),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        var.loc(),
                        format!("assigning to incorrect type {}", r_ty.to_string(ns)),
                    ));
                    Err(())
                }
            },
            _ => {
                diagnostics.push(Diagnostic::error(
                    var.loc(),
                    "expression is not modifiable".to_string(),
                ));
                Err(())
            }
        },
    }
}

// When generating shifts, llvm wants both arguments to have the same width. We
// want the result of the shift to be left argument, so this function coercies
// the right argument into the right length.
pub(super) fn cast_shift_arg(
    loc: &program::Loc,
    expr: Expression,
    from_width: u16,
    ty: &Type,
    ns: &Namespace,
) -> Expression {
    let to_width = ty.bits(ns);

    if from_width == to_width {
        expr
    } else if from_width < to_width {
        Expression::ZeroExt {
            loc: *loc,
            to: ty.clone(),
            expr: Box::new(expr),
        }
    } else {
        Expression::Trunc {
            loc: *loc,
            to: ty.clone(),
            expr: Box::new(expr),
        }
    }
}
