// SPDX-License-Identifier: Apache-2.0

use super::ast::{ArrayLength, Diagnostic, Expression, Namespace, RetrieveType, Symbol, Type};
use super::corelib;
use super::diagnostics::Diagnostics;
use super::eval::check_term_for_constant_overflow;
use super::symtable::Symtable;
use crate::sema::ast::Expression::LibFunction;
use crate::sema::ast::LibFunc;
use crate::sema::function_call::{available_functions, call_expr, named_call_expr};
use crate::sema::unused_variable::{
    assigned_variable, check_function_call, check_var_usage_expression, used_variable,
};
use crate::sema::Recurse;
use num_bigint::BigInt;
use num_traits::{FromPrimitive, Num};
use ola_parser::program::{self, CodeLocation, Loc};
use std::{cmp, cmp::Ordering, str::FromStr};

impl RetrieveType for Expression {
    fn ty(&self) -> Type {
        match self {
            Expression::BoolLiteral(..)
            | Expression::More(..)
            | Expression::Less(..)
            | Expression::MoreEqual(..)
            | Expression::LessEqual(..)
            | Expression::Equal(..)
            | Expression::Or(..)
            | Expression::And(..)
            | Expression::NotEqual(..)
            | Expression::Not(..) => Type::Bool,
            Expression::NumberLiteral(_, ty, _)
            | Expression::StructLiteral(_, ty, _)
            | Expression::ArrayLiteral(_, ty, ..)
            | Expression::ConstArrayLiteral(_, ty, ..)
            | Expression::Add(_, ty, ..)
            | Expression::Subtract(_, ty, ..)
            | Expression::Multiply(_, ty, ..)
            | Expression::Divide(_, ty, ..)
            | Expression::Modulo(_, ty, ..)
            | Expression::Power(_, ty, ..)
            | Expression::BitwiseOr(_, ty, ..)
            | Expression::BitwiseAnd(_, ty, ..)
            | Expression::BitwiseXor(_, ty, ..)
            | Expression::ShiftLeft(_, ty, ..)
            | Expression::ShiftRight(_, ty, ..)
            | Expression::Variable(_, ty, _)
            | Expression::ConstantVariable(_, ty, ..)
            | Expression::StorageVariable(_, ty, ..)
            | Expression::StorageLoad(_, ty, _)
            | Expression::Load(_, ty, ..)
            | Expression::GetRef(_, ty, ..)
            | Expression::BitwiseNot(_, ty, _)
            | Expression::ConditionalOperator(_, ty, ..)
            | Expression::StructMember(_, ty, ..)
            | Expression::AllocDynamicArray { ty, .. }
            | Expression::Increment(_, ty, ..)
            | Expression::Decrement(_, ty, ..)
            | Expression::Assign(_, ty, ..) => ty.clone(),
            Expression::Subscript(_, ty, ..) => ty.clone(),
            Expression::ZeroExt { to, .. }
            | Expression::Trunc { to, .. }
            | Expression::Cast { to, .. } => to.clone(),

            Expression::StorageArrayLength { ty, .. } => ty.clone(),
            Expression::LibFunction(_, returns, ..) | Expression::FunctionCall { returns, .. } => {
                assert_eq!(returns.len(), 1);
                returns[0].clone()
            }
            Expression::List(_, list) => {
                assert_eq!(list.len(), 1);

                list[0].ty()
            }
            Expression::Function { ty, .. } => ty.clone(),
        }
    }
}

impl Expression {
    /// Return the type for this expression.
    pub fn tys(&self) -> Vec<Type> {
        match self {
            Expression::LibFunction(_, returns, ..) | Expression::FunctionCall { returns, .. } => {
                returns.to_vec()
            }
            Expression::List(_, list) => list.iter().map(|e| e.ty()).collect(),
            _ => vec![self.ty()],
        }
    }

    /// Cast from one type to another, which also automatically derefs any
    /// Type::Ref() type. if the cast is explicit (e.g. bytes32(bar) then
    /// implicit should be set to false.
    pub fn cast(
        &self,
        loc: &Loc,
        to: &Type,
        ns: &Namespace,
        diagnostics: &mut Diagnostics,
    ) -> Result<Expression, ()> {
        let from = self.ty();
        if &from == to {
            return Ok(self.clone());
        }

        if from == Type::Unresolved || *to == Type::Unresolved {
            return Ok(self.clone());
        }
        // First of all, if we have a ref then derefence it
        if let Type::Ref(r) = &from {
            return if r.is_fixed_reference_type() {
                // A struct/fixed array *value* is simply the type, e.g. Type::Struct(_)
                // An assignable struct value, e.g. member of another struct, is
                // Type::Ref(Type:Struct(_)). However, the underlying types are
                // identical: simply a pointer.
                //
                // So a Type::Ref(Type::Struct(_)) can be cast to Type::Struct(_).
                //
                // The Type::Ref(..) just means it can be used as an l-value and assigned
                // a new value, unlike say, a struct literal.
                if r.as_ref() == to {
                    Ok(self.clone())
                } else {
                    diagnostics.push(Diagnostic::cast_error(
                        *loc,
                        format!(
                            "conversion from {} to {} not possible",
                            from.to_string(ns),
                            to.to_string(ns)
                        ),
                    ));
                    Err(())
                }
            } else {
                Expression::Load(*loc, r.as_ref().clone(), Box::new(self.clone())).cast(
                    loc,
                    to,
                    ns,
                    diagnostics,
                )
            };
        }
        // If it's a storage reference then load the value. The expr is the storage slot
        if let Type::StorageRef(r) = from {
            return Expression::StorageLoad(*loc, *r, Box::new(self.clone())).cast(
                loc,
                to,
                ns,
                diagnostics,
            );
        }

        // Special case: when converting literal sign can change if it fits
        match (self, &from, to) {
            (&Expression::NumberLiteral(_, _, ref n), p, &Type::Uint(to_len))
                if p.is_primitive() =>
            {
                return if n.bits() >= to_len as u64 {
                    diagnostics.push(Diagnostic::cast_error(
                        *loc,
                        format!(
                            "implicit conversion would truncate from '{}' to '{}'",
                            from.to_string(ns),
                            to.to_string(ns)
                        ),
                    ));
                    Err(())
                } else {
                    Ok(Expression::NumberLiteral(
                        *loc,
                        Type::Uint(to_len),
                        n.clone(),
                    ))
                };
            }

            (
                &Expression::ArrayLiteral(..),
                Type::Array(from_ty, from_dims),
                Type::Array(to_ty, to_dims),
            ) => {
                if from_ty == to_ty
                    && from_dims.len() == to_dims.len()
                    && from_dims.len() == 1
                    && matches!(to_dims.last().unwrap(), ArrayLength::Dynamic)
                {
                    return Ok(Expression::Cast {
                        loc: *loc,
                        to: to.clone(),
                        expr: Box::new(self.clone()),
                    });
                }
            }

            _ => (),
        };

        self.cast_types(loc, &from, to, ns, diagnostics)
    }

    fn cast_types(
        &self,
        loc: &Loc,
        from: &Type,
        to: &Type,
        ns: &Namespace,
        diagnostics: &mut Diagnostics,
    ) -> Result<Expression, ()> {
        #[allow(clippy::comparison_chain)]
        match (&from, &to) {
            (Type::Uint(_), Type::Enum(_)) => {
                diagnostics.push(Diagnostic::cast_error(
                    *loc,
                    format!(
                        "implicit conversion from {} to {} not allowed",
                        from.to_string(ns),
                        to.to_string(ns)
                    ),
                ));
                Err(())
            }
            (Type::Enum(_), Type::Uint(_)) => {
                diagnostics.push(Diagnostic::cast_error(
                    *loc,
                    format!(
                        "implicit conversion from {} to {} not allowed",
                        from.to_string(ns),
                        to.to_string(ns)
                    ),
                ));
                Err(())
            }
            (Type::Uint(from_len), Type::Uint(to_len)) => match from_len.cmp(to_len) {
                Ordering::Greater => {
                    // TODO we do not support implicit conversion
                    diagnostics.push(Diagnostic::cast_error(
                        *loc,
                        format!(
                            "implicit conversion would truncate from {} to {}",
                            from.to_string(ns),
                            to.to_string(ns)
                        ),
                    ));
                    Err(())
                }
                Ordering::Less => Ok(Expression::ZeroExt {
                    loc: *loc,
                    to: to.clone(),
                    expr: Box::new(self.clone()),
                }),
                Ordering::Equal => Ok(Expression::Cast {
                    loc: *loc,
                    to: to.clone(),
                    expr: Box::new(self.clone()),
                }),
            },
            // Match any array with ArrayLength::AnyFixed if is it fixed for that dimension, and the
            // element type and other dimensions also match
            (Type::Array(from_elem, from_dim), Type::Array(to_elem, to_dim))
                if from_elem == to_elem
                    && from_dim.len() == to_dim.len()
                    && from_dim.iter().zip(to_dim.iter()).all(|(f, t)| {
                        f == t || matches!((f, t), (ArrayLength::Fixed(_), ArrayLength::AnyFixed))
                    }) =>
            {
                Ok(self.clone())
            }
            (Type::Array(from_elem, from_dim), Type::Array(to_elem, to_dim))
                if from_elem == to_elem
                    && from_dim.len() == to_dim.len()
                    && from_dim.len() == 1
                    && from_dim.iter().zip(to_dim.iter()).all(|(f, t)| {
                        f == t || matches!((f, t), (ArrayLength::AnyFixed, ArrayLength::Fixed(_)))
                    }) =>
            {
                if let Expression::LibFunction(loc, return_tys, LibFunc::ArraySort, args) = self {
                    // For the sqrt function, only one-dimensional arrays are currently supported.
                    let size = to_dim
                        .iter()
                        .map(|d| match d {
                            ArrayLength::Dynamic => panic!("unknown length"),
                            ArrayLength::Fixed(d) => d,
                            ArrayLength::AnyFixed => {
                                panic!("unknown length");
                            }
                        })
                        .product::<BigInt>();
                    let mut args = args.clone();
                    args.push(Expression::NumberLiteral(*loc, Type::Uint(32), size));
                    Ok(Expression::LibFunction(
                        *loc,
                        return_tys.clone(),
                        LibFunc::ArraySort,
                        args.clone(),
                    ))
                } else {
                    diagnostics.push(Diagnostic::cast_error(
                        *loc,
                        format!(
                            "conversion from {} to {} not possible",
                            from.to_string(ns),
                            to.to_string(ns)
                        ),
                    ));
                    Err(())
                }
            }

            _ => {
                diagnostics.push(Diagnostic::cast_error(
                    *loc,
                    format!(
                        "conversion from {} to {} not possible",
                        from.to_string(ns),
                        to.to_string(ns)
                    ),
                ));
                Err(())
            }
        }
    }
}

fn coerce(
    l: &Type,
    l_loc: &Loc,
    r: &Type,
    r_loc: &Loc,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Type, ()> {
    let l = match l {
        Type::StorageRef(ty) => ty,
        _ => l,
    };
    let r = match r {
        Type::StorageRef(ty) => ty,
        _ => r,
    };
    if l == r {
        return Ok(l.clone());
    }

    coerce_number(l, l_loc, r, r_loc, ns, diagnostics)
}

fn get_uint_length(
    l: &Type,
    l_loc: &Loc,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<u16, ()> {
    match l {
        Type::Uint(n) => Ok(*n),
        Type::Enum(n) => {
            diagnostics.push(Diagnostic::error(
                *l_loc,
                format!("type enum {} not allowed", ns.enums[*n]),
            ));
            Err(())
        }
        Type::Struct(n) => {
            diagnostics.push(Diagnostic::error(
                *l_loc,
                format!("type struct {} not allowed", ns.structs[*n]),
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
        Type::Ref(n) => get_uint_length(n, l_loc, ns, diagnostics),
        Type::StorageRef(n) => get_uint_length(n, l_loc, ns, diagnostics),
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
    l_loc: &Loc,
    r: &Type,
    r_loc: &Loc,
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
        _ => (),
    }

    let left_len = get_uint_length(l, l_loc, ns, diagnostics)?;

    let right_len = get_uint_length(r, r_loc, ns, diagnostics)?;

    Ok(Type::Uint(cmp::max(left_len, right_len)))
}

/// Resolve the given number literal, multiplied by value of unit
fn number_literal(
    loc: &Loc,
    integer: &str,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let n = BigInt::from_str(integer).unwrap();
    bigint_to_expression(loc, &n, ns, diagnostics, resolve_to)
}

/// Try to convert a BigInt into a Expression::NumberLiteral.
pub fn bigint_to_expression(
    loc: &Loc,
    n: &BigInt,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let bits = n.bits();

    if let ResolveTo::Type(resolve_to) = resolve_to {
        if *resolve_to != Type::Unresolved {
            if !resolve_to.is_integer() {
                diagnostics.push(Diagnostic::cast_error(
                    *loc,
                    format!("expected '{}', found integer", resolve_to.to_string(ns)),
                ));
                return Err(());
            } else {
                return Ok(Expression::NumberLiteral(
                    *loc,
                    resolve_to.clone(),
                    n.clone(),
                ));
            }
        }
    }

    // Return smallest type

    if bits > 256 {
        diagnostics.push(Diagnostic::error(*loc, format!("{} is too large", n)));
        Err(())
    } else {
        Ok(Expression::NumberLiteral(*loc, Type::Uint(32), n.clone()))
    }
}

/// When resolving an expression, what type are we looking for
#[derive(PartialEq, Eq, Clone, Copy, Debug)]
pub enum ResolveTo<'a> {
    Unknown,        // We don't know what we're looking for, best effort
    Integer,        // Try to resolve to an integer type value (signed or unsigned, any bit width)
    Discard,        // We won't be using the result. For example, an expression as a statement
    Type(&'a Type), // We will be wanting this type please, e.g. `int64 x = 1;`
}

#[derive(Clone, Default)]
pub struct ExprContext {
    /// What source file are we in
    pub file_no: usize,
    // Are we resolving a contract, and if so, which one
    pub contract_no: Option<usize>,
    /// Are resolving the body of a function, and if so, which one
    pub function_no: Option<usize>,
    /// Are we evaluating a constant expression
    pub constant: bool,
    /// Are we resolving an l-value
    pub lvalue: bool,
}

/// Resolve a parsed expression into an AST expression. The resolve_to argument
/// is a hint to what type the result should be.
pub fn expression(
    expr: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    match expr {
        program::Expression::Parenthesis(_, expr) => {
            expression(expr, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::ArrayLiteral(loc, exprs) => {
            let res = array_literal(loc, exprs, context, ns, symtable, diagnostics, resolve_to);

            if let Ok(exp) = &res {
                used_variable(ns, exp, symtable);
            }

            res
        }
        program::Expression::BoolLiteral(loc, v) => Ok(Expression::BoolLiteral(*loc, *v)),
        program::Expression::NumberLiteral(loc, integer) => {
            number_literal(loc, integer, ns, diagnostics, resolve_to)
        }

        program::Expression::HexNumberLiteral(loc, n) => {
            hex_number_literal(loc, n, ns, diagnostics, resolve_to)
        }

        program::Expression::Variable(id) => {
            variable(id, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::Add(loc, l, r) => {
            addition(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::Subtract(loc, l, r) => {
            subtract(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::BitwiseOr(loc, l, r) => {
            bitwise_or(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::BitwiseAnd(loc, l, r) => {
            bitwise_and(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::BitwiseXor(loc, l, r) => {
            bitwise_xor(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::ShiftLeft(loc, l, r) => {
            shift_left(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::ShiftRight(loc, l, r) => {
            shift_right(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::Multiply(loc, l, r) => {
            multiply(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::Divide(loc, l, r) => {
            divide(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::Modulo(loc, l, r) => {
            modulo(loc, l, r, context, ns, symtable, diagnostics, resolve_to)
        }
        program::Expression::Power(loc, b, e) => {
            power(loc, b, e, context, ns, symtable, diagnostics, resolve_to)
        }
        // compare
        program::Expression::More(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;

            check_var_usage_expression(ns, &left, &right, symtable);
            let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

            let expr = Expression::More(
                *loc,
                Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            );
            Ok(expr)
        }
        program::Expression::Less(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;

            check_var_usage_expression(ns, &left, &right, symtable);

            let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

            let expr = Expression::Less(
                *loc,
                Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            );
            Ok(expr)
        }
        program::Expression::MoreEqual(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            check_var_usage_expression(ns, &left, &right, symtable);

            let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

            let expr = Expression::MoreEqual(
                *loc,
                Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            );

            Ok(expr)
        }
        program::Expression::LessEqual(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            check_var_usage_expression(ns, &left, &right, symtable);

            let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

            let expr = Expression::LessEqual(
                *loc,
                Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            );
            Ok(expr)
        }
        program::Expression::Equal(loc, l, r) => {
            equal(loc, l, r, context, ns, symtable, diagnostics)
        }

        program::Expression::NotEqual(loc, l, r) => {
            not_equal(loc, l, r, context, ns, symtable, diagnostics)
        }
        // unary expressions
        program::Expression::Not(loc, e) => {
            let expr = expression(e, context, ns, symtable, diagnostics, resolve_to)?;

            used_variable(ns, &expr, symtable);
            Ok(Expression::Not(
                *loc,
                Box::new(expr.cast(loc, &Type::Bool, ns, diagnostics)?),
            ))
        }
        program::Expression::BitwiseNot(loc, e) => {
            let expr = expression(e, context, ns, symtable, diagnostics, resolve_to)?;

            used_variable(ns, &expr, symtable);
            let expr_ty = expr.ty();

            get_uint_length(&expr_ty, loc, ns, diagnostics)?;

            Ok(Expression::BitwiseNot(*loc, expr_ty, Box::new(expr)))
        }

        program::Expression::ConditionalOperator(loc, c, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
            let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;
            check_var_usage_expression(ns, &left, &right, symtable);
            let cond = expression(c, context, ns, symtable, diagnostics, resolve_to)?;
            used_variable(ns, &cond, symtable);

            let cond = cond.cast(&c.loc(), &Type::Bool, ns, diagnostics)?;

            let ty = coerce(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;
            let left = left.cast(&l.loc(), &ty, ns, diagnostics)?;
            let right = right.cast(&r.loc(), &ty, ns, diagnostics)?;

            Ok(Expression::ConditionalOperator(
                *loc,
                ty,
                Box::new(cond),
                Box::new(left),
                Box::new(right),
            ))
        }

        // decrement/increment
        program::Expression::Increment(loc, var) | program::Expression::Decrement(loc, var) => {
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "operator not allowed in constant context".to_string(),
                ));
                return Err(());
            };

            incr_decr(var, expr, context, ns, symtable, diagnostics)
        }

        // assignment
        program::Expression::Assign(loc, var, e) => {
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "assignment not allowed in constant context".to_string(),
                ));
                return Err(());
            };

            assign_single(loc, var, e, context, ns, symtable, diagnostics)
        }

        program::Expression::AssignAdd(loc, var, e)
        | program::Expression::AssignSubtract(loc, var, e)
        | program::Expression::AssignMultiply(loc, var, e)
        | program::Expression::AssignDivide(loc, var, e)
        | program::Expression::AssignModulo(loc, var, e)
        | program::Expression::AssignOr(loc, var, e)
        | program::Expression::AssignAnd(loc, var, e)
        | program::Expression::AssignXor(loc, var, e)
        | program::Expression::AssignShiftLeft(loc, var, e)
        | program::Expression::AssignShiftRight(loc, var, e) => {
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "assignment not allowed in constant context".to_string(),
                ));
                return Err(());
            };
            let expr = assign_expr(loc, var, expr, e, context, ns, symtable, diagnostics);
            if let Ok(expression) = &expr {
                expression.recurse(ns, check_term_for_constant_overflow);
            }
            expr
        }
        program::Expression::NamedFunctionCall(loc, ty, args) => named_call_expr(
            loc,
            ty,
            args,
            false,
            context,
            ns,
            symtable,
            diagnostics,
            resolve_to,
        ),
        program::Expression::New(loc, call) => {
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    expr.loc(),
                    "new not allowed in constant expression".to_string(),
                ));
                return Err(());
            }

            match call.remove_parenthesis() {
                program::Expression::FunctionCall(_, ty, args) => {
                    let res = new_array(loc, ty, args, context, ns, symtable, diagnostics);

                    if let Ok(exp) = &res {
                        check_function_call(ns, exp, symtable);
                    }
                    res
                }

                program::Expression::Variable(id) => {
                    diagnostics.push(Diagnostic::error(
                        *loc,
                        format!("missing constructor arguments to {}", id.name),
                    ));
                    Err(())
                }
                expr => {
                    diagnostics.push(Diagnostic::error(
                        expr.loc(),
                        "type with arguments expected".into(),
                    ));
                    Err(())
                }
            }
        }
        program::Expression::Delete(loc, _) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "delete not allowed in expression".to_string(),
            ));
            Err(())
        }

        program::Expression::FunctionCall(loc, ty, args) => call_expr(
            loc,
            ty,
            args,
            context,
            ns,
            symtable,
            diagnostics,
            resolve_to,
        ),
        program::Expression::ArraySubscript(loc, _, None) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "expected expression before ']' token".to_string(),
            ));

            Err(())
        }
        program::Expression::ArraySlice(loc, ..) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "slice not supported yet".to_string(),
            ));

            Err(())
        }
        program::Expression::ArraySubscript(loc, array, Some(index)) => {
            array_subscript(loc, array, index, context, ns, symtable, diagnostics)
        }
        program::Expression::MemberAccess(loc, e, id) => member_access(
            loc,
            e.remove_parenthesis(),
            id,
            context,
            ns,
            symtable,
            diagnostics,
            resolve_to,
        ),
        program::Expression::Or(loc, left, right) => {
            let boolty = Type::Bool;
            let l = expression(
                left,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&boolty),
            )?
            .cast(loc, &boolty, ns, diagnostics)?;
            let r = expression(
                right,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&boolty),
            )?
            .cast(loc, &boolty, ns, diagnostics)?;

            check_var_usage_expression(ns, &l, &r, symtable);

            Ok(Expression::Or(*loc, Box::new(l), Box::new(r)))
        }
        program::Expression::And(loc, left, right) => {
            let boolty = Type::Bool;
            let l = expression(
                left,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&boolty),
            )?
            .cast(loc, &boolty, ns, diagnostics)?;
            let r = expression(
                right,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&boolty),
            )?
            .cast(loc, &boolty, ns, diagnostics)?;
            check_var_usage_expression(ns, &l, &r, symtable);

            Ok(Expression::And(*loc, Box::new(l), Box::new(r)))
        }
        program::Expression::Type(loc, _) => {
            diagnostics.push(Diagnostic::error(*loc, "type not expected".to_owned()));
            Err(())
        }
        program::Expression::List(loc, _) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "lists only permitted in destructure statements".to_owned(),
            ));
            Err(())
        }
    }
}

fn hex_number_literal(
    loc: &Loc,
    n: &str,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    // from_str_radix does not like the 0x prefix
    let s: String = n.chars().skip(2).filter(|v| *v != '_').collect();

    bigint_to_expression(
        loc,
        &BigInt::from_str_radix(s.as_str(), 16).unwrap(),
        ns,
        diagnostics,
        resolve_to,
    )
}

fn variable(
    id: &program::Identifier,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    if let Some(v) = symtable.find(&id.name) {
        return if context.constant {
            diagnostics.push(Diagnostic::error(
                id.loc,
                format!("cannot read variable '{}' in constant expression", id.name),
            ));
            Err(())
        } else {
            Ok(Expression::Variable(id.loc, v.ty.clone(), v.pos))
        };
    }

    // are we trying to resolve a function type?
    let function_first = if let ResolveTo::Type(resolve_to) = resolve_to {
        matches!(resolve_to, Type::Function { .. })
    } else {
        false
    };

    match ns.resolve_var(context.file_no, context.contract_no, id, function_first) {
        Some(Symbol::Variable(_, Some(var_contract_no), var_no)) => {
            let var_contract_no = *var_contract_no;
            let var_no = *var_no;

            let var = &ns.contracts[var_contract_no].variables[var_no];

            if var.constant {
                Ok(Expression::ConstantVariable(
                    id.loc,
                    var.ty.clone(),
                    Some(var_contract_no),
                    var_no,
                ))
            } else if context.constant {
                diagnostics.push(Diagnostic::error(
                    id.loc,
                    format!(
                        "cannot read contract variable '{}' in constant expression",
                        id.name
                    ),
                ));
                Err(())
            } else {
                Ok(Expression::StorageVariable(
                    id.loc,
                    Type::StorageRef(Box::new(var.ty.clone())),
                    var_contract_no,
                    var_no,
                ))
            }
        }
        Some(Symbol::Variable(_, None, var_no)) => {
            let var_no = *var_no;

            let var = &ns.constants[var_no];

            Ok(Expression::ConstantVariable(
                id.loc,
                var.ty.clone(),
                None,
                var_no,
            ))
        }
        Some(Symbol::Function(_)) => {
            let mut name_matches = 0;
            let mut expr = None;

            for function_no in available_functions(&id.name, context.contract_no, ns) {
                let func = &ns.functions[function_no];

                let ty = Type::Function {
                    params: func.params.iter().map(|p| p.ty.clone()).collect(),
                    returns: func.returns.iter().map(|p| p.ty.clone()).collect(),
                };

                name_matches += 1;
                expr = Some(Expression::Function {
                    loc: id.loc,
                    ty,
                    function_no,
                    signature: None,
                });
            }

            if name_matches == 1 {
                Ok(expr.unwrap())
            } else {
                diagnostics.push(Diagnostic::error(
                    id.loc,
                    format!("function '{}' is overloaded", id.name),
                ));
                Err(())
            }
        }
        sym => {
            diagnostics.push(Namespace::wrong_symbol(sym, id));
            Err(())
        }
    }
}

fn subtract(
    loc: &Loc,
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

    Ok(Expression::Subtract(
        *loc,
        ty.clone(),
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

fn bitwise_or(
    loc: &Loc,
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

    Ok(Expression::BitwiseOr(
        *loc,
        ty.clone(),
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

fn bitwise_and(
    loc: &Loc,
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

    Ok(Expression::BitwiseAnd(
        *loc,
        ty.clone(),
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

fn bitwise_xor(
    loc: &Loc,
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

    Ok(Expression::BitwiseXor(
        *loc,
        ty.clone(),
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

fn shift_left(
    loc: &Loc,
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

    let _ = get_uint_length(&left.ty(), &l.loc(), ns, diagnostics)?;
    let right_length = get_uint_length(&right.ty(), &r.loc(), ns, diagnostics)?;

    let left_type = left.ty();

    Ok(Expression::ShiftLeft(
        *loc,
        left_type.clone(),
        Box::new(left),
        Box::new(cast_shift_arg(loc, right, right_length, &left_type, ns)),
    ))
}

fn shift_right(
    loc: &Loc,
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
    let _ = get_uint_length(&left_type, &l.loc(), ns, diagnostics)?;
    let right_length = get_uint_length(&right.ty(), &r.loc(), ns, diagnostics)?;

    Ok(Expression::ShiftRight(
        *loc,
        left_type.clone(),
        Box::new(left),
        Box::new(cast_shift_arg(loc, right, right_length, &left_type, ns)),
    ))
}

fn multiply(
    loc: &Loc,
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
        let bits = cmp::min(256, ty.bits(ns) * 2);
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
        Ok(Expression::Multiply(
            *loc,
            ty.clone(),
            Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
            Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
        ))
    }
}

fn divide(
    loc: &Loc,
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

    Ok(Expression::Divide(
        *loc,
        ty.clone(),
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

fn modulo(
    loc: &Loc,
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

    Ok(Expression::Modulo(
        *loc,
        ty.clone(),
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

fn power(
    loc: &Loc,
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

    Ok(Expression::Power(
        *loc,
        ty.clone(),
        Box::new(base.cast(&b.loc(), &ty, ns, diagnostics)?),
        Box::new(exp.cast(&e.loc(), &ty, ns, diagnostics)?),
    ))
}

/// Test for equality; first check string equality, then integer equality
fn equal(
    loc: &Loc,
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
    Ok(Expression::Equal(
        *loc,
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

/// Test for equality; first check string equality, then integer equality
fn not_equal(
    loc: &Loc,
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
    Ok(Expression::NotEqual(
        *loc,
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

fn addition(
    loc: &Loc,
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
        let bits = cmp::min(256, ty.bits(ns) * 2);
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

    Ok(Expression::Add(
        *loc,
        ty.clone(),
        Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
        Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
    ))
}

/// Resolve an assignment
fn assign_single(
    loc: &Loc,
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
        ResolveTo::Type(&var_ty.deref_any()),
    )?;

    val.recurse(ns, check_term_for_constant_overflow);

    used_variable(ns, &val, symtable);
    match &var {
        Expression::ConstantVariable(loc, _, Some(contract_no), var_no) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!(
                    "cannot assign to constant '{}'",
                    ns.contracts[*contract_no].variables[*var_no].name
                ),
            ));
            Err(())
        }
        Expression::ConstantVariable(loc, _, None, var_no) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("cannot assign to constant '{}'", ns.constants[*var_no].name),
            ));
            Err(())
        }
        Expression::StorageVariable(loc, ty, _, _) => Ok(Expression::Assign(
            *loc,
            ty.clone(),
            Box::new(var.clone()),
            Box::new(val.cast(&right.loc(), ty.deref_any(), ns, diagnostics)?),
        )),
        Expression::Variable(_, var_ty, _) => Ok(Expression::Assign(
            *loc,
            var_ty.clone(),
            Box::new(var.clone()),
            Box::new(val.cast(&right.loc(), var_ty, ns, diagnostics)?),
        )),
        _ => match &var_ty {
            Type::Ref(r_ty) => Ok(Expression::Assign(
                *loc,
                *r_ty.clone(),
                Box::new(var),
                Box::new(val.cast(&right.loc(), r_ty, ns, diagnostics)?),
            )),
            Type::StorageRef(r_ty) => Ok(Expression::Assign(
                *loc,
                var_ty.clone(),
                Box::new(var),
                Box::new(val.cast(&right.loc(), r_ty, ns, diagnostics)?),
            )),
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
fn assign_expr(
    loc: &Loc,
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
                let left_length = get_uint_length(ty, loc, ns, diagnostics)?;
                let right_length = get_uint_length(&set_type, &left.loc(), ns, diagnostics)?;

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
            program::Expression::AssignAdd(..) => {
                Expression::Add(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignSubtract(..) => {
                Expression::Subtract(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignMultiply(..) => {
                Expression::Multiply(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignOr(..) => {
                Expression::BitwiseOr(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignAnd(..) => {
                Expression::BitwiseAnd(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignXor(..) => {
                Expression::BitwiseXor(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignShiftLeft(..) => {
                Expression::ShiftLeft(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignShiftRight(..) => {
                Expression::ShiftRight(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignDivide(..) => {
                Expression::Divide(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            program::Expression::AssignModulo(..) => {
                Expression::Modulo(*loc, ty.clone(), Box::new(assign), Box::new(set))
            }
            _ => unreachable!(),
        })
    };

    match &var {
        Expression::ConstantVariable(loc, _, Some(contract_no), var_no) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!(
                    "cannot assign to constant '{}'",
                    ns.contracts[*contract_no].variables[*var_no].name
                ),
            ));
            Err(())
        }
        Expression::ConstantVariable(loc, _, None, var_no) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("cannot assign to constant '{}'", ns.constants[*var_no].name),
            ));
            Err(())
        }
        Expression::Variable(_, _, n) => {
            match var_ty {
                Type::Uint(_) => (),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        var.loc(),
                        format!(
                            "variable '{}' of incorrect type {}",
                            symtable.get_name(*n),
                            var_ty.to_string(ns)
                        ),
                    ));
                    return Err(());
                }
            };
            Ok(Expression::Assign(
                *loc,
                Type::Void,
                Box::new(var.clone()),
                Box::new(op(var, &var_ty, ns, diagnostics)?),
            ))
        }
        _ => match &var_ty {
            Type::Ref(r_ty) => match r_ty.as_ref() {
                Type::Uint(_) => Ok(Expression::Assign(
                    *loc,
                    *r_ty.clone(),
                    Box::new(var.clone()),
                    Box::new(op(
                        var.cast(loc, r_ty, ns, diagnostics)?,
                        r_ty,
                        ns,
                        diagnostics,
                    )?),
                )),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        var.loc(),
                        format!("assigning to incorrect type {}", r_ty.to_string(ns)),
                    ));
                    Err(())
                }
            },
            Type::StorageRef(r_ty) => match r_ty.as_ref() {
                Type::Uint(_) => Ok(Expression::Assign(
                    *loc,
                    *r_ty.clone(),
                    Box::new(var.clone()),
                    Box::new(op(
                        var.cast(loc, r_ty, ns, diagnostics)?,
                        r_ty,
                        ns,
                        diagnostics,
                    )?),
                )),
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

/// Resolve an increment/decrement with an operator
fn incr_decr(
    v: &program::Expression,
    expr: &program::Expression,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let op = |e: Expression, ty: Type| -> Expression {
        match expr {
            program::Expression::Increment(loc, _) => Expression::Increment(*loc, ty, Box::new(e)),
            program::Expression::Decrement(loc, _) => Expression::Decrement(*loc, ty, Box::new(e)),
            _ => unreachable!(),
        }
    };

    let mut context = context.clone();

    context.lvalue = true;

    let var = expression(v, &context, ns, symtable, diagnostics, ResolveTo::Unknown)?;
    used_variable(ns, &var, symtable);
    let var_ty = var.ty();

    match &var {
        Expression::ConstantVariable(loc, _, Some(contract_no), var_no) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!(
                    "cannot assign to constant '{}'",
                    ns.contracts[*contract_no].variables[*var_no].name
                ),
            ));
            Err(())
        }
        Expression::ConstantVariable(loc, _, None, var_no) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("cannot assign to constant '{}'", ns.constants[*var_no].name),
            ));
            Err(())
        }
        Expression::Variable(_, ty, n) => {
            match ty {
                Type::Uint(_) => (),
                _ => {
                    diagnostics.push(Diagnostic::error(
                        var.loc(),
                        format!(
                            "variable '{}' of incorrect type {}",
                            symtable.get_name(*n),
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

/// Try to resolve expression as an enum value. An enum can be prefixed
/// with import symbols, contract namespace before the enum type
fn enum_value(
    loc: &Loc,
    expr: &program::Expression,
    id: &program::Identifier,
    file_no: usize,
    contract_no: Option<usize>,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<Option<Expression>, ()> {
    let mut namespace = Vec::new();

    let mut expr = expr;

    // the first element of the path is the deepest in the parse tree,
    // so walk down and add to a list
    while let program::Expression::MemberAccess(_, member, name) = expr {
        namespace.push(name);

        expr = member.as_ref();
    }

    if let program::Expression::Variable(name) = expr {
        namespace.push(name);
    } else {
        return Ok(None);
    }

    // The leading part of the namespace can be import variables
    let mut file_no = file_no;

    // last element in our namespace vector is first element
    while let Some(name) = namespace.last().map(|f| f.name.clone()) {
        if let Some(Symbol::Import(_, import_file_no)) =
            ns.variable_symbols.get(&(file_no, None, name))
        {
            file_no = *import_file_no;
            namespace.pop();
        } else {
            break;
        }
    }

    if namespace.is_empty() {
        return Ok(None);
    }

    let mut contract_no = contract_no;

    if let Some(no) = ns.resolve_contract(file_no, namespace.last().unwrap()) {
        contract_no = Some(no);
        namespace.pop();
    }

    if namespace.len() != 1 {
        return Ok(None);
    }

    if let Some(e) = ns.resolve_enum(file_no, contract_no, namespace[0]) {
        match ns.enums[e].values.get_full(&id.name) {
            Some((val, _, _)) => Ok(Some(Expression::NumberLiteral(
                *loc,
                Type::Enum(e),
                BigInt::from_usize(val).unwrap(),
            ))),
            None => {
                diagnostics.push(Diagnostic::error(
                    id.loc,
                    format!("enum {} does not have value {}", ns.enums[e], id.name),
                ));
                Err(())
            }
        }
    } else {
        Ok(None)
    }
}

/// Resolve an member access expression
fn member_access(
    loc: &Loc,
    e: &program::Expression,
    id: &program::Identifier,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    // is it a builtin special variable like "block.timestamp"
    if let program::Expression::Variable(namespace) = e {
        if corelib::lib_namespace(&namespace.name) {
            diagnostics.push(Diagnostic::error(
                e.loc(),
                format!("builtin '{}.{}' does not exist", namespace.name, id.name),
            ));

            return Err(());
        }
    }

    // is it an enum value
    if let Some(expr) = enum_value(
        loc,
        e,
        id,
        context.file_no,
        context.contract_no,
        ns,
        diagnostics,
    )? {
        return Ok(expr);
    }

    if let Some(expr) = contract_constant(
        loc,
        e,
        id,
        context.file_no,
        ns,
        symtable,
        diagnostics,
        resolve_to,
    )? {
        return Ok(expr);
    }

    let expr = expression(e, context, ns, symtable, diagnostics, resolve_to)?;
    let expr_ty = expr.ty();

    if let Type::Struct(n) = &expr_ty.deref_memory() {
        if let Some((i, f)) = ns.structs[*n]
            .fields
            .iter()
            .enumerate()
            .find(|f| id.name == f.1.name_as_str())
        {
            return Ok(Expression::StructMember(
                id.loc,
                f.ty.clone(),
                Box::new(expr),
                i,
            ));
        } else {
            diagnostics.push(Diagnostic::error(
                id.loc,
                format!(
                    "struct '{}' does not have a field called '{}'",
                    ns.structs[*n], id.name
                ),
            ));
            return Err(());
        }
    }

    // Dereference if need to
    let (expr, expr_ty) = if let Type::Ref(ty) = &expr_ty {
        (
            Expression::Load(*loc, expr_ty.clone(), Box::new(expr)),
            ty.as_ref().clone(),
        )
    } else {
        (expr, expr_ty)
    };

    match expr_ty {
        Type::Array(_, dim) => {
            if id.name == "length" {
                return match dim.last().unwrap() {
                    ArrayLength::Dynamic => Ok(Expression::LibFunction(
                        *loc,
                        vec![Type::Uint(32)],
                        LibFunc::ArrayLength,
                        vec![expr],
                    )),
                    ArrayLength::Fixed(d) => {
                        //We should not eliminate an array from the code when 'length' is called
                        //So the variable is also assigned a value to be read from 'length'
                        assigned_variable(ns, &expr, symtable);
                        used_variable(ns, &expr, symtable);
                        bigint_to_expression(
                            loc,
                            d,
                            ns,
                            diagnostics,
                            ResolveTo::Type(&Type::Uint(32)),
                        )
                    }
                    ArrayLength::AnyFixed => unreachable!(),
                };
            }
        }
        Type::StorageRef(r) => match *r {
            Type::Struct(n) => {
                return if let Some((field_no, field)) = ns.structs[n]
                    .fields
                    .iter()
                    .enumerate()
                    .find(|(_, field)| id.name == field.name_as_str())
                {
                    Ok(Expression::StructMember(
                        id.loc,
                        Type::StorageRef(Box::new(field.ty.clone())),
                        Box::new(expr),
                        field_no,
                    ))
                } else {
                    diagnostics.push(Diagnostic::error(
                        id.loc,
                        format!(
                            "struct '{}' does not have a field called '{}'",
                            ns.structs[n].name, id.name
                        ),
                    ));
                    Err(())
                }
            }
            Type::Array(_, dim) => {
                if id.name == "length" {
                    let elem_ty = expr.ty().storage_array_elem().deref_into();

                    return Ok(Expression::StorageArrayLength {
                        loc: id.loc,
                        ty: Type::Uint(32),
                        array: Box::new(expr),
                        elem_ty,
                    });
                }
            }
            _ => {}
        },
        _ => (),
    }

    diagnostics.push(Diagnostic::error(*loc, format!("'{}' not found", id.name)));

    Err(())
}

fn contract_constant(
    loc: &Loc,
    e: &program::Expression,
    id: &program::Identifier,
    file_no: usize,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Option<Expression>, ()> {
    let namespace = match e {
        program::Expression::Variable(namespace) => namespace,
        _ => return Ok(None),
    };

    if symtable.find(&namespace.name).is_some() {
        return Ok(None);
    }

    if let Some(contract_no) = ns.resolve_contract(file_no, namespace) {
        if let Some((var_no, var)) = ns.contracts[contract_no]
            .variables
            .iter_mut()
            .enumerate()
            .find(|(_, variable)| variable.name == id.name)
        {
            if !var.constant {
                let resolve_function = if let ResolveTo::Type(ty) = resolve_to {
                    matches!(ty, Type::Function { .. })
                } else {
                    false
                };

                if resolve_function {
                    // requested function, fall through
                    return Ok(None);
                } else {
                    diagnostics.push(Diagnostic::error(
                        *loc,
                        format!(
                            "need instance of contract '{}' to get variable value '{}'",
                            ns.contracts[contract_no].name,
                            ns.contracts[contract_no].variables[var_no].name,
                        ),
                    ));
                    return Err(());
                }
            }

            var.read = true;

            return Ok(Some(Expression::ConstantVariable(
                *loc,
                var.ty.clone(),
                Some(contract_no),
                var_no,
            )));
        }
    }

    Ok(None)
}

/// Resolve an array subscript expression
fn array_subscript(
    loc: &Loc,
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

    if index_ty.is_contract_storage() {
        // make sure we load the index value from storage
        index = index.cast(&index.loc(), index_ty.deref_any(), ns, diagnostics)?;
    }

    match array_ty.deref_any() {
        Type::Array(..) => {
            if array_ty.is_contract_storage() {
                let elem_ty = array_ty.storage_array_elem();

                Ok(Expression::Subscript(
                    *loc,
                    elem_ty,
                    array_ty,
                    Box::new(array),
                    Box::new(index),
                ))
            } else {
                let elem_ty = array_ty.array_deref();

                let array = array.cast(
                    &array.loc(),
                    if array_ty.is_fixed_reference_type() {
                        &array_ty
                    } else {
                        array_ty.deref_any()
                    },
                    ns,
                    diagnostics,
                )?;

                Ok(Expression::Subscript(
                    *loc,
                    elem_ty,
                    array_ty,
                    Box::new(array),
                    Box::new(index),
                ))
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

/// Resolve a function call with positional arguments
pub fn struct_literal(
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

        Ok(Expression::StructLiteral(*loc, ty, fields))
    }
}

/// Resolve a struct literal with named fields
pub fn named_struct_literal(
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
        fields.resize(args.len(), Expression::BoolLiteral(Loc::Implicit, false));
        for a in args {
            match struct_def.fields.iter().enumerate().find(|(_, f)| {
                f.id.as_ref().map(|id| id.name.as_str()) == Some(a.name.name.as_str())
            }) {
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
        Ok(Expression::StructLiteral(*loc, ty, fields))
    }
}

// When generating shifts, llvm wants both arguments to have the same width. We
// want the result of the shift to be left argument, so this function coercies
// the right argument into the right length.
pub fn cast_shift_arg(
    loc: &Loc,
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

/// Given an parsed literal array, ensure that it is valid. All the elements in
/// the array must of the same type. The array might be a multidimensional
/// array; all the leaf nodes must match.
fn array_literal(
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

                Ok(Expression::ArrayLiteral(
                    *loc,
                    aty,
                    vec![exprs.len() as u32],
                    res,
                ))
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
        diagnostics.push(Diagnostic::error(
            *loc,
            "array requires at least one element".to_string(),
        ));
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
        Ok(Expression::ConstArrayLiteral(*loc, aty, dimensions, exprs))
    } else {
        Ok(Expression::ArrayLiteral(*loc, aty, dimensions, exprs))
    }
}

/// Traverse the literal looking for sub arrays. Ensure that all the sub
/// arrays are the same length, and returned a flattened array of elements
fn check_subarrays<'a>(
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

// Resolve an new expression
pub fn new_array(
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

    Ok(Expression::AllocDynamicArray {
        loc: *loc,
        ty,
        length: Box::new(size),
        init: None,
    })
}
