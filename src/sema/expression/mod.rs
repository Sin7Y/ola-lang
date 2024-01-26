mod arithmetic;
mod assign;

pub(crate) mod function_call;
pub(crate) mod integers;
pub(crate) mod literals;

pub(crate) mod constructor;
mod member_access;
pub mod resolve_expression;
pub mod retrieve_type;
mod slice;
pub(crate) mod strings;
mod subscript;
mod variable;
use std::cmp::Ordering;

use num_bigint::BigInt;
use num_traits::Zero;
use ola_parser::program;

use super::ast::{ArrayLength, Diagnostic, Expression, Namespace, RetrieveType, Type};
use super::diagnostics::Diagnostics;

pub const FIELD_ORDER: u64 = 0xFFFFFFFF00000001;

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

impl Expression {
    /// Return the type for this expression.
    pub fn tys(&self) -> Vec<Type> {
        match self {
            Expression::LibFunction { tys: returns, .. }
            | Expression::FunctionCall { returns, .. } => returns.to_vec(),
            Expression::List { list, .. } => list.iter().map(|e| e.ty()).collect(),
            Expression::ExternalFunctionCallRaw { .. } => vec![Type::DynamicBytes],
            _ => vec![self.ty()],
        }
    }

    /// Cast from one type to another, which also automatically derefs any
    /// Type::Ref() type. if the cast is explicit (e.g. bytes32(bar) then
    /// implicit should be set to false.
    pub(crate) fn cast(
        &self,
        loc: &program::Loc,
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
                Expression::Load {
                    loc: *loc,
                    ty: r.as_ref().clone(),
                    expr: Box::new(self.clone()),
                }
                .cast(loc, to, ns, diagnostics)
            };
        }
        // If it's a storage reference then load the value. The expr is the storage slot
        if let Type::StorageRef(r) = from {
            if let Expression::Subscript { array_ty: ty, .. } = self {
                if ty.is_storage_bytes() {
                    return Ok(self.clone());
                }
            }
            return Expression::StorageLoad {
                loc: *loc,
                ty: *r,
                expr: Box::new(self.clone()),
            }
            .cast(loc, to, ns, diagnostics);
        }

        // Special case: when converting literal sign can change if it fits
        match (self, &from, to) {
            (Expression::NumberLiteral { value, .. }, .., &Type::Uint(to_len)) =>
            {
                return if value.bits() >= to_len as u64 {
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
                    Ok(Expression::NumberLiteral {
                        loc: *loc,
                        ty: Type::Uint(to_len),
                        value: value.clone(),
                    })
                };
            }

            (Expression::NumberLiteral { value, .. }, .., &Type::Field) => {
                return if from != Type::Uint(32) {
                    diagnostics.push(Diagnostic::cast_error(
                        *loc,
                        format!(
                            "type {} cannot be converted to type '{}'",
                            from.to_string(ns),
                            to.to_string(ns)
                        ),
                    ));
                    Err(())
                } else {
                    Ok(Expression::NumberLiteral {
                        loc: *loc,
                        ty: Type::Field,
                        value: value.clone(),
                    })
                };
            }

            (Expression::NumberLiteral { value, .. }, p, &Type::Address)
                if *p == Type::Uint(32) =>
            {
                let address = vec![
                    BigInt::zero(),
                    BigInt::zero(),
                    BigInt::zero(),
                    value.clone(),
                ];
                return Ok(Expression::AddressLiteral {
                    loc: *loc,
                    ty: Type::Address,
                    value: address,
                });
            }
            (Expression::NumberLiteral { value, .. }, p, &Type::Hash) if *p == Type::Uint(32) => {
                let hash = vec![
                    BigInt::zero(),
                    BigInt::zero(),
                    BigInt::zero(),
                    value.clone(),
                ];
                return Ok(Expression::HashLiteral {
                    loc: *loc,
                    ty: Type::Hash,
                    value: hash,
                });
            }

            (
                &Expression::ArrayLiteral { .. },
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
        loc: &program::Loc,
        from: &Type,
        to: &Type,
        ns: &Namespace,
        diagnostics: &mut Diagnostics,
    ) -> Result<Expression, ()> {
        #[allow(clippy::comparison_chain)]
        match (&from, &to) {
            (Type::Address, Type::Ref(to)) if matches!(to.as_ref(), Type::Address) => {
                Ok(Expression::GetRef {
                    loc: *loc,
                    ty: Type::Ref(Box::new(from.clone())),
                    expr: Box::new(self.clone()),
                })
            }
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
            (Type::Uint(32), Type::Field) => Ok(self.clone()),
            (Type::Field, Type::DynamicBytes) | (Type::DynamicBytes, Type::Field) => {
                Ok(Expression::BytesCast {
                    loc: *loc,
                    to: to.clone(),
                    from: from.clone(),
                    expr: Box::new(self.clone()),
                })
            }
            (Type::Hash, Type::Address) | (Type::Address, Type::Hash) => Ok(Expression::Cast {
                loc: *loc,
                to: to.clone(),
                expr: Box::new(self.clone()),
            }),
            (Type::Uint(32), Type::Address) => Ok(Expression::Cast {
                loc: *loc,
                to: to.clone(),
                expr: Box::new(self.clone()),
            }),
            (Type::Hash, Type::DynamicBytes) | (Type::Address, Type::DynamicBytes) => {
                Ok(Expression::Cast {
                    loc: *loc,
                    to: to.clone(),
                    expr: Box::new(self.clone()),
                })
            }

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

            (Type::DynamicBytes | Type::Field, Type::Slice(ty)) if ty.as_ref() == &Type::Field => {
                Ok(Expression::Cast {
                    loc: *loc,
                    to: to.clone(),
                    expr: Box::new(self.clone()),
                })
            }

            (Type::String, Type::DynamicBytes) | (Type::DynamicBytes, Type::String) => {
                Ok(Expression::Cast {
                    loc: *loc,
                    to: to.clone(),
                    expr: Box::new(self.clone()),
                })
            }

            (Type::Address, Type::Contract(_)) | (Type::Contract(_), Type::Address) => {
                Ok(Expression::Cast {
                    loc: *loc,
                    to: to.clone(),
                    expr: Box::new(self.clone()),
                })
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
