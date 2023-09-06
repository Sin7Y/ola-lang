// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::{ArrayLength, Expression, Namespace, RetrieveType, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::expression::resolve_expression::expression;
use crate::sema::expression::{ExprContext, ResolveTo};
use crate::sema::symtable::Symtable;
use crate::sema::unused_variable::used_variable;
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;
use ola_parser::program::CodeLocation;

// Resolve an new expression
pub fn new(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let ty = if let program::Expression::New(_, ty) = ty.remove_parenthesis() {
        ty
    } else {
        ty
    };

    let ty = ns.resolve_type(context.file_no, context.contract_no, ty, diagnostics)?;

    match &ty {
        Type::Array(ty, dim) => {
            if matches!(dim.last(), Some(ArrayLength::Fixed(_))) {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!(
                        "new cannot allocate fixed array type '{}'",
                        ty.to_string(ns)
                    ),
                ));
                return Err(());
            }
        }
        Type::String | Type::DynamicBytes => {}
        _ => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("new cannot allocate type '{}'", ty.to_string(ns)),
            ));
            return Err(());
        }
    };

    if args.len() != 1 {
        diagnostics.push(Diagnostic::error(
            *loc,
            "new dynamic array should have a single length argument".to_string(),
        ));
        return Err(());
    }

    let size_loc = args[0].loc();
    let expected_ty = Type::Uint(32);

    let size_expr = expression(
        &args[0],
        context,
        ns,
        symtable,
        diagnostics,
        ResolveTo::Type(&expected_ty),
    )?;

    used_variable(ns, &size_expr, symtable);

    let size_ty = size_expr.ty();

    if !matches!(size_ty.deref_any(), Type::Uint(_)) {
        diagnostics.push(Diagnostic::error(
            size_expr.loc(),
            "new dynamic array should have an unsigned length argument".to_string(),
        ));
        return Err(());
    }

    let size = size_expr.cast(&size_loc, &expected_ty, ns, diagnostics)?;

    Ok(Expression::AllocDynamicBytes {
        loc: *loc,
        ty,
        length: Box::new(size),
        init: None,
    })
}
