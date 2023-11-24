/// Resolve an array subscript expression
use crate::sema::ast::{Expression, Namespace, RetrieveType, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::eval::check_term_for_constant_overflow;
use crate::sema::expression::resolve_expression::expression;
use crate::sema::expression::{ExprContext, ResolveTo};
use crate::sema::symtable::Symtable;
use crate::sema::Recurse;

use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;
use ola_parser::program::CodeLocation;

pub(super) fn array_slice(
    loc: &program::Loc,
    array: &program::Expression,
    from: &Option<Box<program::Expression>>,
    to: &Option<Box<program::Expression>>,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let array = expression(
        array,
        context,
        ns,
        symtable,
        diagnostics,
        ResolveTo::Unknown,
    )?;
    let array_ty = array.ty();

    if array.ty().is_mapping() {
        diagnostics.push(Diagnostic::error(
            *loc,
            "The slice operation cannot be applied to mapping types.".to_string(),
        ));
        return Err(());
    }

    let from = match from {
        Some(from) => {
            let mut from_expr = expression(
                from,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&Type::Uint(32)),
            )?;
            let from_ty = from_expr.ty();

            match from_ty.deref_any() {
                Type::Uint(_) => (),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        *loc,
                        format!(
                            "array slice must be an unsigned integer, not '{}'",
                            from_expr.ty().to_string(ns)
                        ),
                    ));
                    return Err(());
                }
            };
            from_expr.recurse(ns, check_term_for_constant_overflow);

            // make sure we load the from index value if needed
            from_expr = from_expr.cast(&from_expr.loc(), from_ty.deref_any(), ns, diagnostics)?;

            Some(Box::new(from_expr))
        }
        None => None,
    };

    let to = match to {
        Some(to) => {
            let mut to_expr = expression(
                to,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&Type::Uint(32)),
            )?;
            let to_ty = to_expr.ty();

            match to_ty.deref_any() {
                Type::Uint(_) => (),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        *loc,
                        format!(
                            "array slice must be an unsigned integer, not '{}'",
                            to_expr.ty().to_string(ns)
                        ),
                    ));
                    return Err(());
                }
            };
            to_expr.recurse(ns, check_term_for_constant_overflow);

            // make sure we load the from index value if needed
            to_expr = to_expr.cast(&to_expr.loc(), to_ty.deref_any(), ns, diagnostics)?;

            Some(Box::new(to_expr))
        }
        None => None,
    };

    let deref_ty = array_ty.deref_any();
    match deref_ty {
        Type::Array(..) | Type::Slice(_) | Type::DynamicBytes | Type::String => {
            if array_ty.is_contract_storage() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "The slice operation cannot be applied to storage var.".to_string(),
                ));
                return Err(());
            } else {
                let elem_ty = array_ty.array_deref();

                let array = array.cast(
                    &array.loc(),
                    if array_ty.deref_memory().is_fixed_reference_type() {
                        &array_ty
                    } else {
                        array_ty.deref_any()
                    },
                    ns,
                    diagnostics,
                )?;

                Ok(Expression::ArraySlice {
                    loc: *loc,
                    ty: elem_ty,
                    array_ty,
                    array: Box::new(array),
                    start: from,
                    end: to,
                })
            }
        }
        _ => {
            diagnostics.push(
                Diagnostic::error(array.loc(), "expression is not an array".to_string())
            );
            Err(())
        }
    }
}
