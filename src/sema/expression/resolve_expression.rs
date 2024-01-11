// SPDX-License-Identifier: Apache-2.0

use crate::sema::expression::{
    arithmetic::{
        addition, bitwise_and, bitwise_or, bitwise_xor, divide, equal, incr_decr, modulo, multiply,
        not_equal, power, shift_left, shift_right, subtract,
    },
    assign::{assign_expr, assign_single},
    constructor::new,
    function_call::{call_expr, named_call_expr},
    integers::{coerce, coerce_number, type_bits},
    literals::{
        address_literal, array_literal, hash_literal, hex_number_literal, number_literal,
        string_literal,
    },
    member_access::member_access,
    subscript::array_subscript,
    variable::variable,
    {ExprContext, ResolveTo},
};
use crate::sema::{
    symtable::Symtable,
    unused_variable::{check_function_call, check_var_usage_expression, used_variable},
    Recurse,
    {
        ast::{Expression, Namespace, RetrieveType, Type},
        diagnostics::Diagnostics,
        eval::check_term_for_constant_overflow,
    },
};
use ola_parser::{diagnostics::Diagnostic, program, program::CodeLocation};

use super::{literals::fields_literal, slice::array_slice};
/// Resolve a parsed expression into an AST expression. The resolve_to argument
/// is a hint to what type the result should be.
pub fn expression(
    expr: &program::Expression,
    context: &mut ExprContext,
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
        program::Expression::BoolLiteral(loc, v) => Ok(Expression::BoolLiteral {
            loc: *loc,
            value: *v,
        }),
        program::Expression::StringLiteral(v) => {
            Ok(string_literal(v, context.file_no, diagnostics, resolve_to))
        }
        program::Expression::NumberLiteral(loc, integer) => {
            number_literal(loc, integer, ns, diagnostics, resolve_to)
        }

        program::Expression::HexNumberLiteral(loc, n) => {
            hex_number_literal(loc, n, ns, diagnostics, resolve_to)
        }

        program::Expression::FieldsLiteral(loc, n) => fields_literal(loc, n, diagnostics),
        program::Expression::AddressLiteral(loc, address) => {
            address_literal(loc, address, diagnostics)
        }

        program::Expression::HashLiteral(loc, hash) => hash_literal(loc, hash, diagnostics),

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

            if ty == Type::Field {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("operator is not allowed on type field",),
                ));
                return Err(());
            }

            let expr = Expression::More {
                loc: *loc,
                left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            };
            Ok(expr)
        }
        program::Expression::Less(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;

            check_var_usage_expression(ns, &left, &right, symtable);

            let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;

            if ty == Type::Field {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("operator is not allowed on type field",),
                ));
                return Err(());
            }

            let expr = Expression::Less {
                loc: *loc,
                left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            };
            Ok(expr)
        }
        program::Expression::MoreEqual(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            check_var_usage_expression(ns, &left, &right, symtable);

            let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;
            if ty == Type::Field {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("operator is not allowed on type field",),
                ));
                return Err(());
            }

            let expr = Expression::MoreEqual {
                loc: *loc,
                left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            };

            Ok(expr)
        }
        program::Expression::LessEqual(loc, l, r) => {
            let left = expression(l, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            let right = expression(r, context, ns, symtable, diagnostics, ResolveTo::Integer)?;
            check_var_usage_expression(ns, &left, &right, symtable);

            let ty = coerce_number(&left.ty(), &l.loc(), &right.ty(), &r.loc(), ns, diagnostics)?;
            if ty == Type::Field {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("operator is not allowed on type field",),
                ));
                return Err(());
            }

            let expr = Expression::LessEqual {
                loc: *loc,
                left: Box::new(left.cast(&l.loc(), &ty, ns, diagnostics)?),
                right: Box::new(right.cast(&r.loc(), &ty, ns, diagnostics)?),
            };
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
            let expr_ty = expr.ty();

            if expr_ty == Type::Field {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("operator is not allowed on type field",),
                ));
                return Err(());
            }
            Ok(Expression::Not {
                loc: *loc,
                expr: Box::new(expr.cast(loc, &Type::Bool, ns, diagnostics)?),
            })
        }
        program::Expression::BitwiseNot(loc, e) => {
            let expr = expression(e, context, ns, symtable, diagnostics, resolve_to)?;

            used_variable(ns, &expr, symtable);
            let expr_ty = expr.ty();

            if expr_ty == Type::Field {
                diagnostics.push(Diagnostic::error(
                    *loc,
                    format!("operator is not allowed on type field",),
                ));
                return Err(());
            }

            type_bits(&expr_ty, loc, ns, diagnostics)?;

            Ok(Expression::BitwiseNot {
                loc: *loc,
                ty: expr_ty,
                expr: Box::new(expr),
            })
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

            Ok(Expression::ConditionalOperator {
                loc: *loc,
                ty,
                cond: Box::new(cond),
                true_option: Box::new(left),
                false_option: Box::new(right),
            })
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
                    let res = new(loc, ty, args, context, ns, symtable, diagnostics);

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
        program::Expression::ArraySlice(loc, array, from, to) => {
            array_slice(loc, array, from, to, context, ns, symtable, diagnostics)
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

            Ok(Expression::Or {
                loc: *loc,
                left: Box::new(l),
                right: Box::new(r),
            })
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

            Ok(Expression::And {
                loc: *loc,
                left: Box::new(l),
                right: Box::new(r),
            })
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
        program::Expression::FunctionCallBlock(loc, ..) => {
            diagnostics.push(Diagnostic::error(
                *loc,
                "unexpect block encountered".to_owned(),
            ));
            Err(())
        }
    }
}
