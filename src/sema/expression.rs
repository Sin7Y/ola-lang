// SPDX-License-Identifier: Apache-2.0

use super::ast::{
    ArrayLength, Builtin, Diagnostic, Expression, Function,
    Namespace, RetrieveType,  Symbol, Type,
};
use super::builtin;
use super::diagnostics::Diagnostics;
use super::eval::check_term_for_constant_overflow;
use super::eval::eval_const_number;
use super::{symtable::Symtable};
use crate::sema::unused_variable::{
    assigned_variable, check_function_call, check_var_usage_expression, used_variable,
};
use crate::sema::Recurse;
use num_bigint::{BigInt, Sign};
use num_traits::{FromPrimitive, Num, One, Pow, ToPrimitive, Zero};
use ola_parser::program::{self, CodeLocation, Loc};
use std::{
    cmp,
    cmp::Ordering,
    collections::{BTreeMap, HashMap},
    ops::{Mul, Shl, Sub},
    str::FromStr,
};

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
            | Expression::Complement(_, ty, _)
            | Expression::UnaryMinus(_, ty, _)
            | Expression::ConditionalOperator(_, ty, ..)
            | Expression::StructMember(_, ty, ..)
            | Expression::Increment(_, ty, ..)
            | Expression::Decrement(_, ty, ..)
            | Expression::Assign(_, ty, ..) => ty.clone(),
            Expression::Subscript(_, ty, ..) => ty.clone(),

            Expression::StorageArrayLength { ty, .. } => ty.clone(),
            Expression::Builtin(_, returns, ..)
            | Expression::FunctionCall { returns, .. } => {
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
    /// Is this expression 0
    fn const_zero(&self, ns: &Namespace) -> bool {
        if let Ok((_, value)) = eval_const_number(self, ns) {
            value == BigInt::zero()
        } else {
            false
        }
    }

    /// Return the type for this expression.
    pub fn tys(&self) -> Vec<Type> {
        match self {
            Expression::Builtin(_, returns, ..)
            | Expression::FunctionCall { returns, .. } => returns.to_vec(),
            Expression::List(_, list) => list.iter().map(|e| e.ty()).collect(),
            _ => vec![self.ty()],
        }
    }

    // /// Cast from one type to another, which also automatically derefs any Type::Ref() type.
    // /// if the cast is explicit (e.g. bytes32(bar) then implicit should be set to false.
    // pub fn cast(
    //     &self,
    //     loc: &program::Loc,
    //     to: &Type,
    //     implicit: bool,
    //     ns: &Namespace,
    //     diagnostics: &mut Diagnostics,
    // ) -> Result<Expression, ()> {
    //     let from = self.ty();
    //     if &from == to {
    //         return Ok(self.clone());
    //     }
    //
    //     if from == Type::Unresolved || *to == Type::Unresolved {
    //         return Ok(self.clone());
    //     }
    //
    //     // Special case: when converting literal sign can change if it fits
    //     match (self, &from, to) {
    //         (&Expression::NumberLiteral(_, _, ref n), p, &Type::Uint(to_len))
    //             if p.is_primitive() =>
    //         {
    //             return if n.sign() == Sign::Minus {
    //                 if implicit {
    //                     diagnostics.push(Diagnostic::cast_error(
    //                         *loc,
    //                         format!(
    //                             "implicit conversion cannot change negative number to '{}'",
    //                             to.to_string(ns)
    //                         ),
    //                     ));
    //                     Err(())
    //                 } else {
    //                     // Convert to little endian so most significant bytes are at the end; that way
    //                     // we can simply resize the vector to the right size
    //                     let mut bs = n.to_signed_bytes_le();
    //
    //                     bs.resize(to_len as usize / 8, 0xff);
    //                     Ok(Expression::NumberLiteral(
    //                         *loc,
    //                         Type::Uint(to_len),
    //                         BigInt::from_bytes_le(Sign::Plus, &bs),
    //                     ))
    //                 }
    //             } else if n.bits() >= to_len as u64 {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion would truncate from '{}' to '{}'",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::NumberLiteral(
    //                     *loc,
    //                     Type::Uint(to_len),
    //                     n.clone(),
    //                 ))
    //             };
    //         }
    //         (&Expression::NumberLiteral(_, _, ref n), p, &Type::Int(to_len))
    //             if p.is_primitive() =>
    //         {
    //             return if n.bits() >= to_len as u64 {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion would truncate from '{}' to '{}'",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::NumberLiteral(
    //                     *loc,
    //                     Type::Int(to_len),
    //                     n.clone(),
    //                 ))
    //             };
    //         }
    //         (&Expression::NumberLiteral(_, _, ref n), p, &Type::Bytes(to_len))
    //             if p.is_primitive() =>
    //         {
    //             // round up the number of bits to bytes
    //             let bytes = (n.bits() + 7) / 8;
    //             return if n.sign() == Sign::Minus {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "negative number cannot be converted to type '{}'",
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if n.sign() == Sign::Plus && bytes != to_len as u64 {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "number of {} bytes cannot be converted to type '{}'",
    //                         bytes,
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::NumberLiteral(
    //                     *loc,
    //                     Type::Bytes(to_len),
    //                     n.clone(),
    //                 ))
    //             };
    //         }
    //         (&Expression::NumberLiteral(_, _, ref n), p, &Type::Address(payable))
    //             if p.is_primitive() =>
    //         {
    //             // note: negative values are allowed
    //             return if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     String::from("implicit conversion from int to address not allowed"),
    //                 ));
    //                 Err(())
    //             } else if n.bits() > ns.address_length as u64 * 8 {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "number larger than possible in {} byte address",
    //                         ns.address_length,
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::NumberLiteral(
    //                     *loc,
    //                     Type::Address(payable),
    //                     n.clone(),
    //                 ))
    //             };
    //         }
    //         // Literal strings can be implicitly lengthened
    //         (&Expression::BytesLiteral(_, _, ref bs), p, &Type::Bytes(to_len))
    //             if p.is_primitive() =>
    //         {
    //             return if bs.len() > to_len as usize && implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion would truncate from '{}' to '{}'",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 let mut bs = bs.to_owned();
    //
    //                 // Add zero's at the end as needed
    //                 bs.resize(to_len as usize, 0);
    //
    //                 Ok(Expression::BytesLiteral(*loc, Type::Bytes(to_len), bs))
    //             };
    //         }
    //         (&Expression::BytesLiteral(loc, _, ref init), _, &Type::DynamicBytes)
    //         | (&Expression::BytesLiteral(loc, _, ref init), _, &Type::String) => {
    //             return Ok(Expression::AllocDynamicBytes(
    //                 loc,
    //                 to.clone(),
    //                 Box::new(Expression::NumberLiteral(
    //                     loc,
    //                     Type::Uint(32),
    //                     BigInt::from(init.len()),
    //                 )),
    //                 Some(init.clone()),
    //             ));
    //         }
    //         (&Expression::NumberLiteral(_, _, ref n), _, &Type::Rational) => {
    //             return Ok(Expression::RationalNumberLiteral(
    //                 *loc,
    //                 Type::Rational,
    //                 BigRational::from(n.clone()),
    //             ));
    //         }
    //
    //         (
    //             &Expression::ArrayLiteral(..),
    //             Type::Array(from_ty, from_dims),
    //             Type::Array(to_ty, to_dims),
    //         ) => {
    //             if from_ty == to_ty
    //                 && from_dims.len() == to_dims.len()
    //                 && from_dims.len() == 1
    //                 && matches!(to_dims.last().unwrap(), ArrayLength::Dynamic)
    //             {
    //                 return Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 });
    //             }
    //         }
    //
    //         _ => (),
    //     };
    //
    //     self.cast_types(loc, &from, to, implicit, ns, diagnostics)
    // }

    // fn cast_types(
    //     &self,
    //     loc: &program::Loc,
    //     from: &Type,
    //     to: &Type,
    //     implicit: bool,
    //     ns: &Namespace,
    //     diagnostics: &mut Diagnostics,
    // ) -> Result<Expression, ()> {
    //     let address_bits = ns.address_length as u16 * 8;
    //
    //     #[allow(clippy::comparison_chain)]
    //     match (&from, &to) {
    //         // Solana builtin AccountMeta struct wants a pointer to an address for the pubkey field,
    //         // not an address. For this specific field we have a special Expression::GetRef() which
    //         // gets the pointer to an address
    //         (Type::Address(_), Type::Ref(to)) if matches!(to.as_ref(), Type::Address(..)) => {
    //             Ok(Expression::GetRef(
    //                 *loc,
    //                 Type::Ref(Box::new(from.clone())),
    //                 Box::new(self.clone()),
    //             ))
    //         }
    //         (Type::Uint(from_width), Type::Enum(enum_no))
    //         | (Type::Int(from_width), Type::Enum(enum_no)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion from {} to {} not allowed",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 return Err(());
    //             }
    //
    //             let enum_ty = &ns.enums[*enum_no];
    //
    //             // TODO would be help to have current contract to resolve contract constants
    //             if let Ok((_, big_number)) = eval_const_number(self, ns) {
    //                 if let Some(number) = big_number.to_usize() {
    //                     if enum_ty.values.len() > number {
    //                         return Ok(Expression::NumberLiteral(
    //                             self.loc(),
    //                             to.clone(),
    //                             big_number,
    //                         ));
    //                     }
    //                 }
    //
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "enum {} has no value with ordinal {}",
    //                         to.to_string(ns),
    //                         big_number
    //                     ),
    //                 ));
    //                 return Err(());
    //             }
    //
    //             let to_width = enum_ty.ty.bits(ns);
    //
    //             // TODO needs runtime checks
    //             match from_width.cmp(&to_width) {
    //                 Ordering::Greater => Ok(Expression::Trunc {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //                 Ordering::Less => Ok(Expression::ZeroExt {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //                 Ordering::Equal => Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //             }
    //         }
    //         (Type::Enum(enum_no), Type::Uint(to_width))
    //         | (Type::Enum(enum_no), Type::Int(to_width)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion from {} to {} not allowed",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 return Err(());
    //             }
    //             let enum_ty = &ns.enums[*enum_no];
    //             let from_width = enum_ty.ty.bits(ns);
    //
    //             match from_width.cmp(to_width) {
    //                 Ordering::Greater => Ok(Expression::Trunc {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //                 Ordering::Less => Ok(Expression::ZeroExt {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //                 Ordering::Equal => Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //             }
    //         }
    //         (Type::Bytes(1), Type::Uint(8)) | (Type::Uint(8), Type::Bytes(1)) => Ok(self.clone()),
    //         (Type::Uint(from_len), Type::Uint(to_len)) => match from_len.cmp(to_len) {
    //             Ordering::Greater => {
    //                 if implicit {
    //                     diagnostics.push(Diagnostic::cast_error(
    //                         *loc,
    //                         format!(
    //                             "implicit conversion would truncate from {} to {}",
    //                             from.to_string(ns),
    //                             to.to_string(ns)
    //                         ),
    //                     ));
    //                     Err(())
    //                 } else {
    //                     Ok(Expression::Trunc {
    //                         loc: *loc,
    //                         to: to.clone(),
    //                         expr: Box::new(self.clone()),
    //                     })
    //                 }
    //             }
    //             Ordering::Less => Ok(Expression::ZeroExt {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 expr: Box::new(self.clone()),
    //             }),
    //             Ordering::Equal => Ok(Expression::Cast {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 expr: Box::new(self.clone()),
    //             }),
    //         },
    //         (Type::Int(from_len), Type::Int(to_len)) => match from_len.cmp(to_len) {
    //             Ordering::Greater => {
    //                 if implicit {
    //                     diagnostics.push(Diagnostic::cast_error(
    //                         *loc,
    //                         format!(
    //                             "implicit conversion would truncate from {} to {}",
    //                             from.to_string(ns),
    //                             to.to_string(ns)
    //                         ),
    //                     ));
    //                     Err(())
    //                 } else {
    //                     Ok(Expression::Trunc {
    //                         loc: *loc,
    //                         to: to.clone(),
    //                         expr: Box::new(self.clone()),
    //                     })
    //                 }
    //             }
    //             Ordering::Less => Ok(Expression::SignExt {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 expr: Box::new(self.clone()),
    //             }),
    //             Ordering::Equal => Ok(Expression::Cast {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 expr: Box::new(self.clone()),
    //             }),
    //         },
    //         (Type::Uint(from_len), Type::Int(to_len)) if to_len > from_len => {
    //             Ok(Expression::ZeroExt {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 expr: Box::new(self.clone()),
    //             })
    //         }
    //         (Type::Int(from_len), Type::Uint(to_len)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion would change sign from {} to {}",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if from_len > to_len {
    //                 Ok(Expression::Trunc {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             } else if from_len < to_len {
    //                 Ok(Expression::SignExt {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         (Type::Uint(from_len), Type::Int(to_len)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion would change sign from {} to {}",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if from_len > to_len {
    //                 Ok(Expression::Trunc {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             } else if from_len < to_len {
    //                 Ok(Expression::ZeroExt {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // Casting value to uint
    //         (Type::Value, Type::Uint(to_len)) => {
    //             let from_len = ns.value_length * 8;
    //             let to_len = *to_len as usize;
    //
    //             match from_len.cmp(&to_len) {
    //                 Ordering::Greater => {
    //                     if implicit {
    //                         diagnostics.push(Diagnostic::cast_error(
    //                             *loc,
    //                             format!(
    //                                 "implicit conversion would truncate from {} to {}",
    //                                 from.to_string(ns),
    //                                 to.to_string(ns)
    //                             ),
    //                         ));
    //                         Err(())
    //                     } else {
    //                         Ok(Expression::Trunc {
    //                             loc: *loc,
    //                             to: to.clone(),
    //                             expr: Box::new(self.clone()),
    //                         })
    //                     }
    //                 }
    //                 Ordering::Less => Ok(Expression::SignExt {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //                 Ordering::Equal => Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //             }
    //         }
    //         (Type::Value, Type::Int(to_len)) => {
    //             let from_len = ns.value_length * 8;
    //             let to_len = *to_len as usize;
    //
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion would change sign from {} to {}",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if from_len > to_len {
    //                 Ok(Expression::Trunc {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             } else if from_len < to_len {
    //                 Ok(Expression::ZeroExt {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // Casting value to uint
    //         (Type::Uint(from_len), Type::Value) => {
    //             let from_len = *from_len as usize;
    //             let to_len = ns.value_length * 8;
    //
    //             match from_len.cmp(&to_len) {
    //                 Ordering::Greater => {
    //                     diagnostics.push(Diagnostic::cast_warning(
    //                         *loc,
    //                         format!(
    //                             "conversion truncates {} to {}, as value is type {} on target {}",
    //                             from.to_string(ns),
    //                             to.to_string(ns),
    //                             Type::Value.to_string(ns),
    //                             ns.target
    //                         ),
    //                     ));
    //
    //                     Ok(Expression::CheckingTrunc {
    //                         loc: *loc,
    //                         to: to.clone(),
    //                         expr: Box::new(self.clone()),
    //                     })
    //                 }
    //                 Ordering::Less => Ok(Expression::SignExt {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //                 Ordering::Equal => Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 }),
    //             }
    //         }
    //         // Casting int to address
    //         (Type::Uint(from_len), Type::Address(_)) | (Type::Int(from_len), Type::Address(_)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion from {} to address not allowed",
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //
    //                 Err(())
    //             } else {
    //                 // cast integer it to integer of the same size of address with sign ext etc
    //                 let address_to_int = if from.is_signed_int() {
    //                     Type::Int(address_bits)
    //                 } else {
    //                     Type::Uint(address_bits)
    //                 };
    //
    //                 let expr = if *from_len > address_bits {
    //                     Expression::Trunc {
    //                         loc: *loc,
    //                         to: address_to_int,
    //                         expr: Box::new(self.clone()),
    //                     }
    //                 } else if *from_len < address_bits {
    //                     if from.is_signed_int() {
    //                         Expression::ZeroExt {
    //                             loc: *loc,
    //                             to: address_to_int,
    //                             expr: Box::new(self.clone()),
    //                         }
    //                     } else {
    //                         Expression::SignExt {
    //                             loc: *loc,
    //                             to: address_to_int,
    //                             expr: Box::new(self.clone()),
    //                         }
    //                     }
    //                 } else {
    //                     self.clone()
    //                 };
    //
    //                 // Now cast integer to address
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(expr),
    //                 })
    //             }
    //         }
    //         // Casting address to int
    //         (Type::Address(_), Type::Uint(to_len)) | (Type::Address(_), Type::Int(to_len)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion to {} from {} not allowed",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //
    //                 Err(())
    //             } else {
    //                 // first convert address to int/uint
    //                 let address_to_int = if to.is_signed_int() {
    //                     Type::Int(address_bits)
    //                 } else {
    //                     Type::Uint(address_bits)
    //                 };
    //
    //                 let expr = Expression::Cast {
    //                     loc: *loc,
    //                     to: address_to_int,
    //                     expr: Box::new(self.clone()),
    //                 };
    //                 // now resize int to request size with sign extension etc
    //                 if *to_len < address_bits {
    //                     Ok(Expression::Trunc {
    //                         loc: *loc,
    //                         to: to.clone(),
    //                         expr: Box::new(expr),
    //                     })
    //                 } else if *to_len > address_bits {
    //                     if to.is_signed_int() {
    //                         Ok(Expression::ZeroExt {
    //                             loc: *loc,
    //                             to: to.clone(),
    //                             expr: Box::new(expr),
    //                         })
    //                     } else {
    //                         Ok(Expression::SignExt {
    //                             loc: *loc,
    //                             to: to.clone(),
    //                             expr: Box::new(expr),
    //                         })
    //                     }
    //                 } else {
    //                     Ok(expr)
    //                 }
    //             }
    //         }
    //         // Lengthing or shorting a fixed bytes array
    //         (Type::Bytes(from_len), Type::Bytes(to_len)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion would truncate from {} to {}",
    //                         from.to_string(ns),
    //                         to.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if to_len > from_len {
    //                 let shift = (to_len - from_len) * 8;
    //
    //                 Ok(Expression::ShiftLeft(
    //                     *loc,
    //                     to.clone(),
    //                     Box::new(Expression::ZeroExt {
    //                         loc: self.loc(),
    //                         to: to.clone(),
    //                         expr: Box::new(self.clone()),
    //                     }),
    //                     Box::new(Expression::NumberLiteral(
    //                         *loc,
    //                         Type::Uint(*to_len as u16 * 8),
    //                         BigInt::from_u8(shift).unwrap(),
    //                     )),
    //                 ))
    //             } else {
    //                 let shift = (from_len - to_len) * 8;
    //
    //                 Ok(Expression::Trunc {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(Expression::ShiftRight(
    //                         self.loc(),
    //                         from.clone(),
    //                         Box::new(self.clone()),
    //                         Box::new(Expression::NumberLiteral(
    //                             self.loc(),
    //                             Type::Uint(*from_len as u16 * 8),
    //                             BigInt::from_u8(shift).unwrap(),
    //                         )),
    //                         false,
    //                     )),
    //                 })
    //             }
    //         }
    //         (Type::Rational, Type::Uint(_) | Type::Int(_) | Type::Value) => {
    //             match eval_const_rational(self, ns) {
    //                 Ok((_, big_number)) => {
    //                     if big_number.is_integer() {
    //                         return Ok(Expression::Cast {
    //                             loc: *loc,
    //                             to: to.clone(),
    //                             expr: Box::new(self.clone()),
    //                         });
    //                     }
    //
    //                     diagnostics.push(Diagnostic::cast_error(
    //                         *loc,
    //                         format!(
    //                             "conversion to {} from {} not allowed",
    //                             to.to_string(ns),
    //                             from.to_string(ns)
    //                         ),
    //                     ));
    //
    //                     Err(())
    //                 }
    //                 Err(diag) => {
    //                     diagnostics.push(diag);
    //                     Err(())
    //                 }
    //             }
    //         }
    //         (Type::Uint(_) | Type::Int(_) | Type::Value, Type::Rational) => Ok(Expression::Cast {
    //             loc: *loc,
    //             to: to.clone(),
    //             expr: Box::new(self.clone()),
    //         }),
    //         (Type::Bytes(_), Type::DynamicBytes) | (Type::DynamicBytes, Type::Bytes(_)) => {
    //             Ok(Expression::BytesCast {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 from: from.clone(),
    //                 expr: Box::new(self.clone()),
    //             })
    //         }
    //         // Explicit conversion from bytesN to int/uint only allowed with expliciy
    //         // cast and if it is the same size (i.e. no conversion required)
    //         (Type::Bytes(from_len), Type::Uint(to_len))
    //         | (Type::Bytes(from_len), Type::Int(to_len)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if *from_len as u16 * 8 != *to_len {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // Explicit conversion to bytesN from int/uint only allowed with expliciy
    //         // cast and if it is the same size (i.e. no conversion required)
    //         (Type::Uint(from_len), Type::Bytes(to_len))
    //         | (Type::Int(from_len), Type::Bytes(to_len)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if *to_len as u16 * 8 != *from_len {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // Explicit conversion from bytesN to address only allowed with expliciy
    //         // cast and if it is the same size (i.e. no conversion required)
    //         (Type::Bytes(from_len), Type::Address(_)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if *from_len as usize != ns.address_length {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // Explicit conversion between contract and address is allowed
    //         (Type::Address(false), Type::Address(true))
    //         | (Type::Address(_), Type::Contract(_))
    //         | (Type::Contract(_), Type::Address(_)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // Conversion between contracts is allowed if it is a base
    //         (Type::Contract(contract_no_from), Type::Contract(contract_no_to)) => {
    //             if implicit && !is_base(*contract_no_to, *contract_no_from, ns) {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion not allowed since {} is not a base contract of {}",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // conversion from address payable to address is implicitly allowed (not vice versa)
    //         (Type::Address(true), Type::Address(false)) => Ok(Expression::Cast {
    //             loc: *loc,
    //             to: to.clone(),
    //             expr: Box::new(self.clone()),
    //         }),
    //         // Explicit conversion to bytesN from int/uint only allowed with expliciy
    //         // cast and if it is the same size (i.e. no conversion required)
    //         (Type::Address(_), Type::Bytes(to_len)) => {
    //             if implicit {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "implicit conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if *to_len as usize != ns.address_length {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "conversion to {} from {} not allowed",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         (Type::String, Type::DynamicBytes) | (Type::DynamicBytes, Type::String)
    //             if !implicit =>
    //         {
    //             Ok(Expression::Cast {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 expr: Box::new(self.clone()),
    //             })
    //         }
    //         // string conversions
    //         // (Type::Bytes(_), Type::String) => Ok(Expression::Cast(self.loc(), to.clone(), Box::new(self.clone()))),
    //         /*
    //         (Type::String, Type::Bytes(to_len)) => {
    //             if let Expression::BytesLiteral(_, from_str) = self {
    //                 if from_str.len() > to_len as usize {
    //                     diagnostics.push(Output::type_error(
    //                         self.loc(),
    //                         format!(
    //                             "string of {} bytes is too long to fit into {}",
    //                             from_str.len(),
    //                             to.to_string(ns)
    //                         ),
    //                     ));
    //                     return Err(());
    //                 }
    //             }
    //             Ok(Expression::Cast(self.loc(), to.clone(), Box::new(self.clone()))
    //         }
    //         */
    //         (Type::Void, _) => {
    //             diagnostics.push(Diagnostic::cast_error(
    //                 self.loc(),
    //                 "function or method does not return a value".to_string(),
    //             ));
    //             Err(())
    //         }
    //         (
    //             Type::ExternalFunction {
    //                 params: from_params,
    //                 mutability: from_mutablity,
    //                 returns: from_returns,
    //             },
    //             Type::ExternalFunction {
    //                 params: to_params,
    //                 mutability: to_mutablity,
    //                 returns: to_returns,
    //             },
    //         )
    //         | (
    //             Type::InternalFunction {
    //                 params: from_params,
    //                 mutability: from_mutablity,
    //                 returns: from_returns,
    //             },
    //             Type::InternalFunction {
    //                 params: to_params,
    //                 mutability: to_mutablity,
    //                 returns: to_returns,
    //             },
    //         ) => {
    //             if from_params != to_params {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "function arguments do not match in conversion from '{}' to '{}'",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if from_returns != to_returns {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "function returns do not match in conversion from '{}' to '{}'",
    //                         to.to_string(ns),
    //                         from.to_string(ns)
    //                     ),
    //                 ));
    //                 Err(())
    //             } else if !compatible_mutability(from_mutablity, to_mutablity) {
    //                 diagnostics.push(Diagnostic::cast_error(
    //                     *loc,
    //                     format!(
    //                         "function mutability not compatible in conversion from '{}' to '{}'",
    //                         from.to_string(ns),
    //                         to.to_string(ns),
    //                     ),
    //                 ));
    //                 Err(())
    //             } else {
    //                 Ok(Expression::Cast {
    //                     loc: *loc,
    //                     to: to.clone(),
    //                     expr: Box::new(self.clone()),
    //                 })
    //             }
    //         }
    //         // Match any array with ArrayLength::AnyFixed if is it fixed for that dimension, and the
    //         // element type and other dimensions also match
    //         (Type::Array(from_elem, from_dim), Type::Array(to_elem, to_dim))
    //             if from_elem == to_elem
    //                 && from_dim.len() == to_dim.len()
    //                 && from_dim.iter().zip(to_dim.iter()).all(|(f, t)| {
    //                     f == t || matches!((f, t), (ArrayLength::Fixed(_), ArrayLength::AnyFixed))
    //                 }) =>
    //         {
    //             Ok(self.clone())
    //         }
    //         (Type::DynamicBytes, Type::Slice(ty)) if ty.as_ref() == &Type::Bytes(1) => {
    //             Ok(Expression::Cast {
    //                 loc: *loc,
    //                 to: to.clone(),
    //                 expr: Box::new(self.clone()),
    //             })
    //         }
    //         _ => {
    //             diagnostics.push(Diagnostic::cast_error(
    //                 *loc,
    //                 format!(
    //                     "conversion from {} to {} not possible",
    //                     from.to_string(ns),
    //                     to.to_string(ns)
    //                 ),
    //             ));
    //             Err(())
    //         }
    //     }
    // }
}




fn coerce(
    l: &Type,
    r: &Type,
) -> Result<Type, ()> {

    if *l == *r {
        return Ok(l.clone());
    }
    coerce_number(l, r, true)
}

fn get_int_length(
    l: &Type,
    l_loc: &program::Loc,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
) -> Result<u16, ()> {
    match l {
        Type::U32 => Ok(32),
        Type::U64 => Ok(64),
        Type::Field => Ok(64),
        Type::U256 => Ok(256),
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
    r: &Type,
    for_compare: bool,
) -> Result<Type, ()> {

    match (l, r) {
        (Type::Contract(left), Type::Contract(right)) if left == right && for_compare => {
            return Ok(Type::Contract(*left));
        }

        (Type::U32,  Type::U64 | Type::Field) => {
            return Ok(Type::U64);
        }
        (Type::U32 , Type::U256) => {
            return Ok(Type::U256);
        }
        (Type::U64 , Type::U32 | Type::Field) => {
            return Ok(Type::U64);
        }
        (Type::U256, Type::U32 | Type::U64 | Type::Field | Type::U256) => {
            return Ok(Type::U256);
        }
    }

}

// TODO Resolve u32、u64、u256、field number
/// Resolve the given number literal, multiplied by value of unit
fn number_literal(
    loc: &program::Loc,
    integer: &str,
    ns: &Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let integer = BigInt::from_str(integer).unwrap();

    bigint_to_expression(loc, &integer, ns, diagnostics, resolve_to)
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

    let int_size = if bits < 7 { 8 } else { (bits + 7) & !7 } as u16;

     if bits > 256 {
        diagnostics.push(Diagnostic::error(*loc, format!("{} is too large", n)));
        Err(())
    } else {
        Ok(Expression::NumberLiteral(
            *loc,
            Type::Field,
            n.clone(),
        ))
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

/// Resolve a parsed expression into an AST expression. The resolve_to argument is a hint to what
/// type the result should be.
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
        program::Expression::U32Literal(loc, integer) => number_literal(
            loc,
            integer,
            ns,
            diagnostics,
            resolve_to,
        ),
        program::Expression::U64Literal(loc, integer) => number_literal(
            loc,
            integer,
            ns,
            diagnostics,
            resolve_to,
        ),
        program::Expression::FieldLiteral(loc, integer) => number_literal(
            loc,
            integer,
            ns,
            diagnostics,
            resolve_to,
        ),
        program::Expression::U256Literal(loc, integer) => number_literal(
            loc,
            integer,
            ns,
            diagnostics,
            resolve_to,
        ),

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

            Ok(Expression::More(
                *loc,
                Box::new(left),
                Box::new(right),
            ))
        }
        program::Expression::Less(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;

            check_var_usage_expression(ns, &left, &right, symtable);

            Ok(Expression::Less(
                *loc,
                Box::new(left),
                Box::new(right),
            ))
        }
        program::Expression::MoreEqual(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            check_var_usage_expression(ns, &left, &right, symtable);

            Ok(Expression::MoreEqual(
                *loc,
                Box::new(left),
                Box::new(right),
            ))
        }
        program::Expression::LessEqual(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            check_var_usage_expression(ns, &left, &right, symtable);


            Ok(Expression::LessEqual(
                *loc,
                Box::new(left),
                Box::new(right),
            ))
        }
        program::Expression::Equal(loc, l, r) => equal(loc, l, r, context, ns, symtable, diagnostics),

        program::Expression::NotEqual(loc, l, r) => Ok(Expression::Not(
            *loc,
            Box::new(equal(loc, l, r, context, ns, symtable, diagnostics)?),
        )),
        // unary expressions
        program::Expression::Not(loc, e) => {
            let expr = expression(e, context, ns, symtable, diagnostics, resolve_to)?;

            used_variable(ns, &expr, symtable);
            Ok(Expression::Not(
                *loc,
                Box::new(expr),
            ))
        }
        program::Expression::Complement(loc, e) => {
            let expr = expression(e, context, ns, symtable, diagnostics, resolve_to)?;

            used_variable(ns, &expr, symtable);
            let expr_ty = expr.ty();

            get_int_length(&expr_ty, loc, ns, diagnostics)?;

            Ok(Expression::Complement(*loc, expr_ty, Box::new(expr)))
        }

        program::Expression::ConditionalOperator(loc, c, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, resolve_to)?;
            let right = expression(r, context, ns, symtable, diagnostics, resolve_to)?;
            check_var_usage_expression(ns, &left, &right, symtable);
            let cond = expression(c, context, ns, symtable, diagnostics, resolve_to)?;
            used_variable(ns, &cond, symtable);


            let ty = coerce(&left.ty(),  &right.ty())?;

            Ok(Expression::ConditionalOperator(
                *loc,
                ty,
                Box::new(cond),
                Box::new(left),
                Box::new(right),
            ))
        }

        // pre/post decrement/increment
        program::Expression::Increment(loc, var)
        | program::Expression::Decrement(loc, var) => {
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
        program::Expression::FunctionCall(loc, ty, args) => call_expr(
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
            )?;
            let r = expression(
                right,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&boolty),
            )?;

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
            )?;
            let r = expression(
                right,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Type(&boolty),
            )?;
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
    loc: &program::Loc,
    n: &str,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {

    // from_str_radix does not like the 0x prefix
    let s: String = n.chars().skip(2).filter(|v| *v != '_').collect();

    bigint_to_expression(
        loc,
        &BigInt::from_str_radix(&s, 16).unwrap(),
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

    if let Some((builtin, ty)) = builtin::builtin_var(&id.loc, None, &id.name, ns, diagnostics) {
        return Ok(Expression::Builtin(id.loc, vec![ty], builtin, vec![]));
    }

    // are we trying to resolve a function type?
    let function_first = if let ResolveTo::Type(resolve_to) = resolve_to {
        matches!(
            resolve_to,
            Type::Function { .. }
        )
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
            } else {
                diagnostics.push(Diagnostic::error(
                    id.loc,
                    format!(
                        "cannot read contract variable '{}' in constant expression",
                        id.name
                    ),
                ));
                Err(())
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

            for function_no in
                available_functions(&id.name, true, context.file_no, context.contract_no, ns)
            {
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

    let ty = coerce_number(
        &left.ty(),
        &right.ty(),
        false,
    )?;

    Ok(Expression::Subtract(
        *loc,
        ty.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn bitwise_or(
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

    let ty = coerce_number(
        &left.ty(),
        &right.ty(),
        true,
    )?;

    Ok(Expression::BitwiseOr(
        *loc,
        ty.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn bitwise_and(
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

    let ty = coerce_number(
        &left.ty(),
        &right.ty(),
        true,
    )?;

    Ok(Expression::BitwiseAnd(
        *loc,
        ty.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn bitwise_xor(
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

    let ty = coerce_number(
        &left.ty(),
        &right.ty(),
        true,
    )?;

    Ok(Expression::BitwiseXor(
        *loc,
        ty.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn shift_left(
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
    let _ = get_int_length(&left.ty(), &l.loc(),  ns, diagnostics)?;
    let right_length = get_int_length(&right.ty(), &r.loc(),  ns, diagnostics)?;

    let left_type = left.ty();

    Ok(Expression::ShiftLeft(
        *loc,
        left_type.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn shift_right(
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
    let _ = get_int_length(&left_type, &l.loc(), ns, diagnostics)?;
    let right_length = get_int_length(&right.ty(), &r.loc(),ns, diagnostics)?;

    Ok(Expression::ShiftRight(
        *loc,
        left_type.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn multiply(
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

    let ty = coerce_number(
        &left.ty(),
        &right.ty(),
        false,
    )?;

    Ok(Expression::Multiply(
            *loc,
            ty.clone(),
            Box::new(left),
            Box::new(right),
    ))

}

fn divide(
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

    let ty = coerce_number(
        &left.ty(),
        &right.ty(),
        false,
    )?;

    Ok(Expression::Divide(
        *loc,
        ty.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn modulo(
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

    let ty = coerce_number(
        &left.ty(),
        &right.ty(),
        false,
    )?;

    Ok(Expression::Modulo(
        *loc,
        ty.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

fn power(
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

    let exp = expression(e, context, ns, symtable, diagnostics, resolve_to)?;

    check_var_usage_expression(ns, &base, &exp, symtable);

    let base_type = base.ty();
    let exp_type = exp.ty();


    let ty = coerce_number(
        &base_type,
        &exp_type,
        false,
    )?;

    Ok(Expression::Power(
        *loc,
        ty.clone(),
        Box::new(base),
        Box::new(exp),
    ))
}



/// check if from creates to, recursively
fn circular_reference(from: usize, to: usize, ns: &Namespace) -> bool {
    if ns.contracts[from].creates.contains(&to) {
        return true;
    }

    ns.contracts[from]
        .creates
        .iter()
        .any(|n| circular_reference(*n, to, ns))
}


/// Test for equality; first check string equality, then integer equality
fn equal(
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

    let ty = coerce(&left_type, &right_type)?;

    Ok(Expression::Equal(
        *loc,
        Box::new(left),
        Box::new(right),
    ))
}

/// Try string concatenation
fn addition(
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

    let ty = coerce_number(
        &left_type,
        &right_type,
        false,
    )?;

    Ok(Expression::Add(
        *loc,
        ty.clone(),
        Box::new(left),
        Box::new(right),
    ))
}

/// Resolve an assignment
fn assign_single(
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
        ResolveTo::Type(&var_ty),
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
        Expression::Variable(_, var_ty, _) => Ok(Expression::Assign(
            *loc,
            var_ty.clone(),
            Box::new(var.clone()),
            Box::new(val),
        )),

        _ => {
                diagnostics.push(Diagnostic::error(
                    var.loc(),
                    "expression is not assignable".to_string(),
                ));
                Err(())
            }
    }
}

/// Resolve an assignment with an operator
fn assign_expr(
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
        ResolveTo::Type(&var_ty)
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
            program::Expression::AssignShiftLeft(..) | program::Expression::AssignShiftRight(..) => {
                let left_length = get_int_length(ty, loc, ns, diagnostics)?;
                let right_length = get_int_length(&set_type, &left.loc(), ns, diagnostics)?;
                set
            }
            _ => set,
        };

        Ok(match expr {
            program::Expression::AssignAdd(..) => Expression::Add(
                *loc,
                ty.clone(),
                Box::new(assign),
                Box::new(set),
            ),
            program::Expression::AssignSubtract(..) => Expression::Subtract(
                *loc,
                ty.clone(),
                Box::new(assign),
                Box::new(set),
            ),
            program::Expression::AssignMultiply(..) => Expression::Multiply(
                *loc,
                ty.clone(),
                Box::new(assign),
                Box::new(set),
            ),
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
            program::Expression::AssignShiftRight(..) => Expression::ShiftRight(
                *loc,
                ty.clone(),
                Box::new(assign),
                Box::new(set),
            ),
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
                Type::U32| Type::U64 | Type::U256 | Type::Field => (),
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
        _ => {
            diagnostics.push(Diagnostic::error(
                var.loc(),
                "expression is not assignable".to_string(),
            ));
            Err(())
        }
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
            program::Expression::Increment(loc, _) => {
                Expression::Increment(*loc, ty,Box::new(e))
            }
            program::Expression::Decrement(loc, _) => {
                Expression::Decrement(*loc, ty,Box::new(e))
            }
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
                Type::U32| Type::U64 | Type::U256 | Type::Field => (),
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
        _ => {
            diagnostics.push(Diagnostic::error(
                var.loc(),
                "expression is not modifiable".to_string(),
            ));
            Err(())
        }
    }
}

/// Try to resolve expression as an enum value. An enum can be prefixed
/// with import symbols, contract namespace before the enum type
fn enum_value(
    loc: &program::Loc,
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
    loc: &program::Loc,
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
        if let Some((builtin, ty)) =
            builtin::builtin_var(loc, Some(&namespace.name), &id.name, ns, diagnostics)
        {
            return Ok(Expression::Builtin(*loc, vec![ty], builtin, vec![]));
        }

        if builtin::builtin_namespace(&namespace.name) {
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

    // is it a constant (unless basecontract is a local variable)
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

    if let Type::Struct(n) = &expr_ty {
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
                    ns.structs[*n],
                    id.name
                ),
            ));
            return Err(());
        }
    }

    diagnostics.push(Diagnostic::error(*loc, format!("'{}' not found", id.name)));

    Err(())
}

fn contract_constant(
    loc: &program::Loc,
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
                    matches!(
                        ty,
                        Type::Function { .. }
                    )
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



    let mut index = expression(
        index,
        context,
        ns,
        symtable,
        diagnostics,
        ResolveTo::Type(&Type::U32),
    )?;

    let index_ty = index.ty();

    index.recurse(ns, check_term_for_constant_overflow);

    match &index_ty {
        Type::U32 | Type::U64 | Type::U256 | Type::Field => (),
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



    match &array_ty {
         Type::Array(..) => {
                let elem_ty = array_ty.array_deref();

                Ok(Expression::Subscript(
                    *loc,
                    elem_ty,
                    array_ty,
                    Box::new(array),
                    Box::new(index),
                ))
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
fn struct_literal(
    loc: &program::Loc,
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
            fields.push(expr);
        }

        Ok(Expression::StructLiteral(*loc,  ty,fields))
    }
}

/// Create a list of functions that can be called in this context. If global is true, then
/// include functions outside of contracts
pub fn available_functions(
    name: &str,
    global: bool,
    file_no: usize,
    contract_no: Option<usize>,
    ns: &Namespace,
) -> Vec<usize> {
    let mut list = Vec::new();

    if global {
        if let Some(Symbol::Function(v)) =
            ns.function_symbols.get(&(file_no, None, name.to_owned()))
        {
            list.extend(v.iter().map(|(_, func_no)| *func_no));
        }
    }

    if let Some(contract_no) = contract_no {
        list.extend(
            ns.contracts[contract_no]
                .all_functions
                .keys()
                .filter_map(|func_no| {
                    if ns.functions[*func_no].name == name && ns.functions[*func_no].has_body {
                        Some(*func_no)
                    } else {
                        None
                    }
                }),
        );
    }

    list
}


/// Resolve a function call with positional arguments
pub fn function_call_pos_args(
    loc: &program::Loc,
    id: &program::Identifier,
    args: &[program::Expression],
    function_nos: Vec<usize>,
    context: &ExprContext,
    ns: &mut Namespace,
    resolve_to: ResolveTo,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let mut name_matches = 0;
    let mut errors = Diagnostics::default();

    // Try to resolve as a function call
    for function_no in &function_nos {
        let func = &ns.functions[*function_no];


        name_matches += 1;

        let params_len = func.params.len();

        if params_len != args.len() {
            errors.push(Diagnostic::error(
                *loc,
                format!(
                    "fn expects {} arguments, {} provided",
                    params_len,
                    args.len()
                ),
            ));
            continue;
        }

        // TODO refactor it
        let mut cast_args = Vec::new();


        let func = &ns.functions[*function_no];

        let returns = function_returns(func, resolve_to);
        let ty = function_type(func, resolve_to);

        return Ok(Expression::FunctionCall{
            loc: *loc,
            returns,
            function: Box::new(Expression::Function {
                loc: *loc,
                ty,
                function_no: *function_no,
                signature: None
            }),
            args: cast_args,
        });
    }

    match name_matches {
        0 => {
                diagnostics.push(Diagnostic::error(
                    id.loc,
                    format!("unknown fn or type '{}'", id.name),
                ));

        }
        1 => diagnostics.extend(errors),
        _ => {
            diagnostics.push(Diagnostic::error(
                *loc,
                format!("cannot find overloaded fn which matches signature"),
            ));
        }
    }

    Err(())
}

/// Resolve a function call with named arguments
fn function_call_named_args(
    loc: &program::Loc,
    id: &program::Identifier,
    args: &[program::NamedArgument],
    function_nos: Vec<usize>,
    virtual_call: bool,
    context: &ExprContext,
    resolve_to: ResolveTo,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
) -> Result<Expression, ()> {
    let mut arguments = HashMap::new();

    for arg in args {
        if arguments.contains_key(arg.name.name.as_str()) {
            diagnostics.push(Diagnostic::error(
                arg.name.loc,
                format!("duplicate argument with name '{}'", arg.name.name),
            ));

            let _ = expression(
                &arg.expr,
                context,
                ns,
                symtable,
                diagnostics,
                ResolveTo::Unknown,
            );
        }

        arguments.insert(arg.name.name.as_str(), &arg.expr);
    }
    // Try to resolve as a function call
    let mut errors = Diagnostics::default();

    // Try to resolve as a function call
    for function_no in &function_nos {
        let func = &ns.functions[*function_no];


        let unnamed_params = func.params.iter().filter(|p| p.id.is_none()).count();
        let params_len = func.params.len();
        let mut matches = true;

        if unnamed_params > 0 {
            errors.push(Diagnostic::cast_error_with_note(
                *loc,
                format!(
                    "function cannot be called with named arguments as {} of its parameters do not have names",
                    unnamed_params,
                ),
                func.loc,
                format!("definition of {}", func.name),
            ));
            matches = false;
        } else if params_len != args.len() {
            errors.push(Diagnostic::cast_error(
                *loc,
                format!(
                    "function expects {} arguments, {} provided",
                    params_len,
                    args.len()
                ),
            ));
            matches = false;
        }

        let mut cast_args = Vec::new();



        let func = &ns.functions[*function_no];


        let returns = function_returns(func, resolve_to);
        let ty = function_type(func,resolve_to);

        return Ok(Expression::FunctionCall {
            loc: *loc,
            returns,
            function: Box::new(Expression::Function {
                loc: *loc,
                ty,
                function_no: *function_no,
                signature: None

            }),
            args: cast_args,
        });
    }

    match function_nos.len() {
        0 => {
            diagnostics.push(Diagnostic::error(
                id.loc,
                format!("unknown function or type '{}'", id.name),
            ));
        }
        1 => diagnostics.extend(errors),
        _ => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "cannot find overloaded function which matches signature".to_string(),
            ));
        }
    }

    Err(())
}

/// Resolve a struct literal with named fields
fn named_struct_literal(
    loc: &program::Loc,
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
                    fields[i] = expr
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

/// Resolve a method call with positional arguments
fn method_call_pos_args(
    loc: &program::Loc,
    var: &program::Expression,
    func: &program::Identifier,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    if let program::Expression::Variable(namespace) = var {
        if builtin::is_builtin_call(Some(&namespace.name), &func.name, ns) {

            return builtin::resolve_namespace_call(
                loc,
                &namespace.name,
                &func.name,
                args,
                context,
                ns,
                symtable,
                diagnostics,
            );
        }

    }

    let var_expr = expression(var, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;

    if let Some(expr) =
        builtin::resolve_method_call(&var_expr, func, args, context, ns, symtable, diagnostics)?
    {
        return Ok(expr);
    }

    let var_ty = var_expr.ty();

    diagnostics.push(Diagnostic::error(
        func.loc,
        format!("method '{}' does not exist", func.name),
    ));

    Err(())
}

fn method_call_named_args(
    loc: &program::Loc,
    var: &program::Expression,
    func_name: &program::Identifier,
    args: &[program::NamedArgument],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {



    let var_expr = expression(var, context, ns, symtable, diagnostics, ResolveTo::Unknown)?;


    diagnostics.push(Diagnostic::error(
        func_name.loc,
        format!("method '{}' does not exist", func_name.name),
    ));

    Err(())
}


/// Given an parsed literal array, ensure that it is valid. All the elements in the array
/// must of the same type. The array might be a multidimensional array; all the leaf nodes
/// must match.
fn array_literal(
    loc: &program::Loc,
    exprs: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut dims = Box::new(Vec::new());
    let mut flattened = Vec::new();

    let resolve_to = match resolve_to {
        ResolveTo::Type(Type::Array(elem_ty, _)) => ResolveTo::Type(elem_ty),
        // Solana seeds are a slice of slice of bytes, e.g. [ [ "fo", "o" ], [ "b", "a", "r"]]. In this
        // case we want to resolve
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

    check_subarrays(exprs, &mut Some(&mut dims), &mut flattened, diagnostics)?;

    if flattened.is_empty() {
        diagnostics.push(Diagnostic::error(
            *loc,
            "array requires at least one element".to_string(),
        ));
        return Err(());
    }

    let mut flattened = flattened.iter();

    // We follow the solidity scheme were everthing gets implicitly converted to the
    // type of the first element
    let mut first = expression(
        flattened.next().unwrap(),
        context,
        ns,
        symtable,
        diagnostics,
        resolve_to,
    )?;

    let ty = if let ResolveTo::Type(ty) = resolve_to {
        ty.clone()
    } else {
        first.ty()
    };

    used_variable(ns, &first, symtable);
    let mut exprs = vec![first];

    for e in flattened {
        let mut other = expression(e, context, ns, symtable, diagnostics, ResolveTo::Type(&ty))?;
        used_variable(ns, &other, symtable);

        exprs.push(other);
    }

    let aty = Type::Array(
        Box::new(ty),
        dims.iter()
            .map(|n| ArrayLength::Fixed(BigInt::from_u32(*n).unwrap()))
            .collect::<Vec<ArrayLength>>(),
    );

    if context.constant {
        Ok(Expression::ConstArrayLiteral(*loc, aty, *dims, exprs))
    } else {
        Ok(Expression::ArrayLiteral(*loc, aty, *dims, exprs))
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



pub fn named_call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::NamedArgument],
    is_destructible: bool,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut nullsink = Diagnostics::default();

    // is it a struct literal
    match ns.resolve_type(
        context.file_no,
        context.contract_no,
        true,
        ty,
        &mut nullsink,
    ) {
        Ok(Type::Struct(n)) => {
            return named_struct_literal(loc, &n, args, context, ns, symtable, diagnostics);
        }
        Ok(_) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "struct or function expected".to_string(),
            ));
            return Err(());
        }
        _ => {}
    }

    // not a struct literal, remove those errors and try resolving as function call
    if context.constant {
        diagnostics.push(Diagnostic::error(
            *loc,
            "cannot call function in constant expression".to_string(),
        ));
        return Err(());
    }

    let expr = named_function_call_expr(
        loc,
        ty,
        args,
        context,
        ns,
        symtable,
        diagnostics,
        resolve_to,
    )?;

    check_function_call(ns, &expr, symtable);
    if expr.tys().len() > 1 && !is_destructible {
        diagnostics.push(Diagnostic::error(
            *loc,
            "destucturing statement needed for function that returns multiple values".to_string(),
        ));
        return Err(());
    }

    Ok(expr)
}

/// Resolve any callable expression
pub fn call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::Expression],
    is_destructible: bool,
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    let mut nullsink = Diagnostics::default();
    let ty = ty.remove_parenthesis();

    match ns.resolve_type(
        context.file_no,
        context.contract_no,
        true,
        ty,
        &mut nullsink,
    ) {
        Ok(Type::Struct(n)) => {
            return struct_literal(loc, &n, args, context, ns, symtable, diagnostics);
        }
        Ok(to) => {
            // Cast
            return if args.is_empty() {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "missing argument to cast".to_string(),
                ));
                Err(())
            } else if args.len() > 1 {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "too many arguments to cast".to_string(),
                ));
                Err(())
            } else {
                let expr = expression(
                    &args[0],
                    context,
                    ns,
                    symtable,
                    diagnostics,
                    ResolveTo::Unknown,
                )?;

                Ok(expr)
            };
        }
        Err(_) => (),
    }

    let expr = match ty.remove_parenthesis() {
        _ => function_call_expr(
            loc,
            ty,
            args,
            context,
            ns,
            symtable,
            diagnostics,
            resolve_to,
        )?,
    };

    check_function_call(ns, &expr, symtable);
    if expr.tys().len() > 1 && !is_destructible {
        diagnostics.push(Diagnostic::error(
            *loc,
            "destucturing statement needed for function that returns multiple values".to_string(),
        ));
        return Err(());
    }

    Ok(expr)
}

/// Resolve function call
pub fn function_call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::Expression],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {

    match ty.remove_parenthesis() {
        program::Expression::MemberAccess(_, member, func) => {
            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "cannot call function in constant expression".to_string(),
                ));
                return Err(());
            }

            method_call_pos_args(
                loc,
                member,
                func,
                args,
                context,
                ns,
                symtable,
                diagnostics,
                resolve_to,
            )
        }
        program::Expression::Variable(id) => {
            // is it a builtin
            if builtin::is_builtin_call(None, &id.name, ns) {
                return {
                    let expr = builtin::resolve_call(
                        &id.loc,
                        None,
                        &id.name,
                        args,
                        context,
                        ns,
                        symtable,
                        diagnostics,
                    )?;

                    if expr.tys().len() > 1 {
                        diagnostics.push(Diagnostic::error(
                            *loc,
                            format!("builtin function '{}' returns more than one value", id.name),
                        ));
                        Err(())
                    } else {
                        Ok(expr)
                    }
                };
            }

            if context.constant {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    "cannot call function in constant expression".to_string(),
                ));
                return Err(());
            }

            function_call_pos_args(
                    loc,
                    id,
                    args,
                    available_functions(&id.name, true, context.file_no, context.contract_no, ns),
                    context,
                    ns,
                    resolve_to,
                    symtable,
                    diagnostics,
                )

        }
        _ =>   {
            diagnostics.push(Diagnostic::error(
            *loc,
            "expression is not a function".to_string(),
        ));
        Err(())
        }
    }
}

/// Resolve function call expression with named arguments
pub fn named_function_call_expr(
    loc: &program::Loc,
    ty: &program::Expression,
    args: &[program::NamedArgument],
    context: &ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {

    match ty {
        program::Expression::MemberAccess(_, member, func) => method_call_named_args(
            loc,
            member,
            func,
            args,
            context,
            ns,
            symtable,
            diagnostics,
            resolve_to,
        ),
        program::Expression::Variable(id) => {
            function_call_named_args(
                loc,
                id,
                args,
                available_functions(&id.name, true, context.file_no, context.contract_no, ns),
                true,
                context,
                resolve_to,
                ns,
                symtable,
                diagnostics,
            )
        }
        program::Expression::ArraySubscript(..) => {
            diagnostics.push(Diagnostic::error(
                ty.loc(),
                "unexpected array type".to_string(),
            ));
            Err(())
        }
        _ => {
            diagnostics.push(Diagnostic::error(
                ty.loc(),
                "expression not expected here".to_string(),
            ));
            Err(())
        }
    }
}

/// Get the return values for a function call
pub(crate) fn function_returns(ftype: &Function, resolve_to: ResolveTo) -> Vec<Type> {
    if !ftype.returns.is_empty() && !matches!(resolve_to, ResolveTo::Discard) {
        ftype.returns.iter().map(|p| p.ty.clone()).collect()
    } else {
        vec![Type::Void]
    }
}

/// Get the function type for an internal.external function call
pub(crate) fn function_type(func: &Function,  resolve_to: ResolveTo) -> Type {
    let params = func.params.iter().map(|p| p.ty.clone()).collect();
    let returns = function_returns(func, resolve_to);

    Type::Function {
        params,
        returns,
        }

}


