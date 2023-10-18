/// Resolve an array subscript expression
use crate::sema::ast::{Expression, Mapping, Namespace, RetrieveType, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::eval::check_term_for_constant_overflow;
use crate::sema::expression::resolve_expression::expression;
use crate::sema::expression::{ExprContext, ResolveTo};
use crate::sema::symtable::Symtable;
use crate::sema::Recurse;
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;
use ola_parser::program::CodeLocation;

pub(super) fn array_subscript(
    loc: &program::Loc,
    array: &program::Expression,
    index: &program::Expression,
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
        return mapping_subscript(loc, array, index, context, ns, symtable, diagnostics);
    }

    // TODO when indexing an array in storage, should the index be u256?
    let mut index = expression(
        index,
        context,
        ns,
        symtable,
        diagnostics,
        ResolveTo::Type(&Type::Uint(32)),
    )?;

    let index_ty = index.ty();

    index.recurse(ns, check_term_for_constant_overflow);

    match index_ty.deref_any() {
        Type::Uint(_) => (),
        _ => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!(
                    "array subscript must be an unsigned integer, not '{}'",
                    index.ty().to_string(ns)
                ),
            ));
            return Err(());
        }
    };

    // make sure we load the index value if needed
    index = index.cast(&index.loc(), index_ty.deref_any(), ns, diagnostics)?;
    let deref_ty = array_ty.deref_any();
    match deref_ty {
        Type::Array(..) | Type::Slice(_) | Type::String | Type::DynamicBytes => {
            if array_ty.is_contract_storage() {
                let elem_ty = array_ty.storage_array_elem();

                Ok(Expression::Subscript {
                    loc: *loc,
                    ty: elem_ty,
                    array_ty,
                    array: Box::new(array),
                    index: Box::new(index),
                })
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

                Ok(Expression::Subscript {
                    loc: *loc,
                    ty: elem_ty,
                    array_ty,
                    array: Box::new(array),
                    index: Box::new(index),
                })
            }
        }
        _ => {
            diagnostics.push(Diagnostic::error(
                array.loc(),
                "expression is not an array".to_string(),
            ));
            Err(())
        }
    }
}

// Calculate storage subscript
fn mapping_subscript(
    loc: &program::Loc,
    mapping: Expression,
    index: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let ty = mapping.ty();
    let elem_ty = ty.storage_array_elem();

    if let Type::Mapping(Mapping { key, .. }) = ty.deref_any() {
        let index_expr = expression(
            index,
            context,
            ns,
            symtable,
            diagnostics,
            ResolveTo::Type(key),
        )?
        .cast(&index.loc(), key, ns, diagnostics)?;

        Ok(Expression::Subscript {
            loc: *loc,
            ty: elem_ty,
            array_ty: ty,
            array: Box::new(mapping),
            index: Box::new(index_expr),
        })
    } else {
        unreachable!()
    }
}
