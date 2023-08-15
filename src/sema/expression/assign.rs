/// Resolve an assignment
use crate::sema::ast::{Expression, Namespace, RetrieveType, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::eval::check_term_for_constant_overflow;
use crate::sema::expression::integers::type_bits;
use crate::sema::expression::resolve_expression::expression;
use crate::sema::expression::{ExprContext, ResolveTo};
use crate::sema::symtable::Symtable;
use crate::sema::unused_variable::{assigned_variable, used_variable};
use crate::sema::Recurse;
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;
use ola_parser::program::CodeLocation;
pub(super) fn assign_single(
    loc: &program::Loc,
    left: &program::Expression,
    right: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let mut lcontext = context.clone();
    lcontext.lvalue = true;

    let var = expression(
        left,
        &lcontext,
        ns,
        symtable,
        diagnostics,
        ResolveTo::Unknown,
    )?;
    assigned_variable(ns, &var, symtable);

    let var_ty = var.ty();
    let val = expression(
        right,
        context,
        ns,
        symtable,
        diagnostics,
        ResolveTo::Type(var_ty.deref_any()),
    )?;

    val.recurse(ns, check_term_for_constant_overflow);

    used_variable(ns, &val, symtable);
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
        Expression::StorageVariable { loc, ty, .. } => {
            let ty = ty.deref_any();
            Ok(Expression::Assign {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(var.clone()),
                right: Box::new(val.cast(&right.loc(), ty, ns, diagnostics)?),
            })
        }
        Expression::Variable { ty: var_ty, .. } => Ok(Expression::Assign {
            loc: *loc,
            ty: var_ty.clone(),
            left: Box::new(var.clone()),
            right: Box::new(val.cast(&right.loc(), var_ty, ns, diagnostics)?),
        }),
        _ => match &var_ty {
            // If the variable is a Type::Ref(Type::Ref(..)), we must load it.
            Type::Ref(inner) if matches!(**inner, Type::Ref(_)) => Ok(Expression::Assign {
                loc: *loc,
                ty: inner.deref_memory().clone(),
                left: Box::new(var.cast(loc, inner, ns, diagnostics)?),
                right: Box::new(val.cast(&right.loc(), inner.deref_memory(), ns, diagnostics)?),
            }),
            Type::Ref(r_ty) => Ok(Expression::Assign {
                loc: *loc,
                ty: *r_ty.clone(),
                left: Box::new(var),
                right: Box::new(val.cast(&right.loc(), r_ty, ns, diagnostics)?),
            }),
            Type::StorageRef(r_ty) => Ok(Expression::Assign {
                loc: *loc,
                ty: var_ty.clone(),
                left: Box::new(var),
                right: Box::new(val.cast(&right.loc(), r_ty, ns, diagnostics)?),
            }),
            _ => {
                diagnostics.push(Diagnostic::error(
                    var.loc(),
                    "expression is not assignable".to_string(),
                ));
                Err(())
            }
        },
    }
}

/// Resolve an assignment with an operator
pub(super) fn assign_expr(
    loc: &program::Loc,
    left: &program::Expression,
    expr: &program::Expression,
    right: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let mut lcontext = context.clone();
    lcontext.lvalue = true;

    let var = expression(
        left,
        &lcontext,
        ns,
        symtable,
        diagnostics,
        ResolveTo::Unknown,
    )?;
    assigned_variable(ns, &var, symtable);
    let var_ty = var.ty();

    let resolve_to = if matches!(
        expr,
        program::Expression::AssignShiftLeft(..) | program::Expression::AssignShiftRight(..)
    ) {
        ResolveTo::Unknown
    } else {
        ResolveTo::Type(var_ty.deref_any())
    };

    let set = expression(right, context, ns, symtable, diagnostics, resolve_to)?;
    used_variable(ns, &set, symtable);
    let set_type = set.ty();

    let op = |assign: Expression,
              ty: &Type,
              ns: &Namespace,
              diagnostics: &mut Diagnostics|
     -> Result<Expression, ()> {
        let set = match expr {
            program::Expression::AssignShiftLeft(..)
            | program::Expression::AssignShiftRight(..) => {
                let left_length = type_bits(ty, loc, ns, diagnostics)?;
                let right_length = type_bits(&set_type, &left.loc(), ns, diagnostics)?;

                if left_length == right_length {
                    set
                } else if right_length < left_length {
                    Expression::ZeroExt {
                        loc: *loc,
                        to: ty.clone(),
                        expr: Box::new(set),
                    }
                } else {
                    Expression::Trunc {
                        loc: *loc,
                        to: ty.clone(),
                        expr: Box::new(set),
                    }
                }
            }
            _ => set.cast(&right.loc(), ty, ns, diagnostics)?,
        };

        Ok(match expr {
            program::Expression::AssignAdd(..) => Expression::Add {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },

            program::Expression::AssignSubtract(..) => Expression::Subtract {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignMultiply(..) => Expression::Multiply {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignOr(..) => Expression::BitwiseOr {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignAnd(..) => Expression::BitwiseAnd {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignXor(..) => Expression::BitwiseXor {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignShiftLeft(..) => Expression::ShiftLeft {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignShiftRight(..) => Expression::ShiftRight {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignDivide(..) => Expression::Divide {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            program::Expression::AssignModulo(..) => Expression::Modulo {
                loc: *loc,
                ty: ty.clone(),
                left: Box::new(assign),
                right: Box::new(set),
            },
            _ => unreachable!(),
        })
    };

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
        Expression::Variable { var_no, .. } => {
            match var_ty {
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
            Ok(Expression::Assign {
                loc: *loc,
                ty: Type::Void,
                left: Box::new(var.clone()),
                right: Box::new(op(var, &var_ty, ns, diagnostics)?),
            })
        }
        _ => match &var_ty {
            Type::Ref(r_ty) => match r_ty.as_ref() {
                Type::Uint(_) => Ok(Expression::Assign {
                    loc: *loc,
                    ty: *r_ty.clone(),
                    left: Box::new(var.clone()),
                    right: Box::new(op(
                        var.cast(loc, r_ty, ns, diagnostics)?,
                        r_ty,
                        ns,
                        diagnostics,
                    )?),
                }),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        var.loc(),
                        format!("assigning to incorrect type {}", r_ty.to_string(ns)),
                    ));
                    Err(())
                }
            },
            Type::StorageRef(r_ty) => match r_ty.as_ref() {
                Type::Uint(_) => Ok(Expression::Assign {
                    loc: *loc,
                    ty: *r_ty.clone(),
                    left: Box::new(var.clone()),
                    right: Box::new(op(
                        var.cast(loc, r_ty, ns, diagnostics)?,
                        r_ty,
                        ns,
                        diagnostics,
                    )?),
                }),
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
                    "expression is not assignable".to_string(),
                ));
                Err(())
            }
        },
    }
}
