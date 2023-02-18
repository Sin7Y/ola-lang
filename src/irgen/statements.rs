use inkwell::values::{BasicValue, BasicValueEnum, FunctionValue};
use num_bigint::BigInt;
use std::collections::HashMap;

use super::expression::expression;
use crate::irgen::binary::Binary;
use crate::irgen::expression::emit_function_call;
use crate::sema::ast::{Expression, Function, Namespace, Statement, Type};
use ola_parser::program;

/// Resolve a statement, which might be a block of statements or an entire body
/// of a function
pub(crate) fn statement<'a>(
    stmt: &Statement,
    bin: &mut Binary<'a>,
    func: &Function,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) {
    match stmt {
        Statement::Block { statements, .. } => {
            for stmt in statements {
                statement(stmt, bin, func, func_val, var_table, ns);
            }
        }
        Statement::VariableDecl(_, pos, param, Some(init)) => {
            let alloc = bin.build_alloca(
                func_val,
                bin.llvm_var_ty(&param.ty, ns),
                param.name_as_str(),
            );
            let var_value = expression(init, bin, Some(func), func_val, var_table, ns);
            var_table.insert(*pos, alloc.as_basic_value_enum());
            bin.builder.build_store(alloc, var_value);
        }

        Statement::Return(_, expr) => match expr {
            Some(expr) => {
                let ret_value = returns(expr, bin, func, func_val, var_table, ns);
                bin.builder.build_return(Some(&ret_value));
            }
            None => {}
        },
        Statement::Expression(_, _, expr) => {
            expression(expr, bin, Some(func), func_val, var_table, ns);
        }

        Statement::If(_, _, cond, then_stmt, else_stmt) if else_stmt.is_empty() => {
            if_then(cond, bin, then_stmt, func, func_val, var_table, ns);
        }
        Statement::If(_, _, cond, then_stmt, else_stmt) => if_then_else(
            cond, then_stmt, else_stmt, bin, func, func_val, var_table, ns,
        ),

        Statement::For {
            init,
            cond: Some(cond_expr),
            next,
            body,
            ..
        } => {
            for stmt in init {
                statement(stmt, bin, func, func_val, var_table, ns);
            }

            let cond_block = bin.context.append_basic_block(func_val, "cond");
            let body_block = bin.context.append_basic_block(func_val, "body");
            let next_block = bin.context.append_basic_block(func_val, "next");
            let end_block = bin.context.append_basic_block(func_val, "endfor");

            bin.builder.build_unconditional_branch(cond_block);
            bin.builder.position_at_end(cond_block);

            let cond_expr = expression(cond_expr, bin, Some(func), func_val, var_table, ns);

            bin.builder
                .build_conditional_branch(cond_expr.into_int_value(), body_block, end_block);

            // compile loop body
            bin.builder.position_at_end(body_block);

            bin.loops.push((end_block, next_block));

            let mut body_reachable = true;

            for stmt in body {
                statement(stmt, bin, func, func_val, var_table, ns);

                body_reachable = stmt.reachable();
            }

            if body_reachable {
                // jump to next body
                bin.builder.build_unconditional_branch(next_block);
            }

            bin.loops.pop();

            bin.builder.position_at_end(next_block);

            let mut next_reachable = true;

            for stmt in next {
                statement(stmt, bin, func, func_val, var_table, ns);

                next_reachable = stmt.reachable();
            }

            if next_reachable {
                bin.builder.build_unconditional_branch(cond_block);
            }

            bin.builder.position_at_end(end_block);
        }
        Statement::Break(_) => {
            bin.builder
                .build_unconditional_branch(bin.loops.last().unwrap().0);
        }
        Statement::Continue(_) => {
            bin.builder
                .build_unconditional_branch(bin.loops.last().unwrap().1);
        }

        _ => {}
    }
}

/// Generate if-then-no-else
fn if_then<'a>(
    cond: &Expression,
    bin: &mut Binary<'a>,
    then_stmt: &[Statement],
    func: &Function,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) {
    let pos = bin.builder.get_insert_block().unwrap();
    let cond = expression(cond, bin, Some(func), func_val, var_table, ns);

    let then = bin.context.append_basic_block(func_val, "then");
    let endif = bin.context.append_basic_block(func_val, "enif");
    bin.builder.position_at_end(pos);

    bin.builder
        .build_conditional_branch(cond.into_int_value(), then, endif);
    bin.builder.position_at_end(then);
    let mut reachable = true;
    for stmt in then_stmt {
        statement(stmt, bin, func, func_val, var_table, ns);
        reachable = stmt.reachable();
    }

    if reachable {
        bin.builder.build_unconditional_branch(endif);
    }
    bin.builder.position_at_end(endif);
}

/// Generate if-then-else
fn if_then_else<'a>(
    cond: &Expression,
    then_stmt: &[Statement],
    else_stmt: &[Statement],
    bin: &mut Binary<'a>,
    func: &Function,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) {
    let pos = bin.builder.get_insert_block().unwrap();
    let cond = expression(cond, bin, Some(func), func_val, var_table, ns);

    let then = bin.context.append_basic_block(func_val, "then");
    let else_ = bin.context.append_basic_block(func_val, "else");
    let endif = bin.context.append_basic_block(func_val, "enif");
    bin.builder.position_at_end(pos);

    bin.builder
        .build_conditional_branch(cond.into_int_value(), then, else_);
    bin.builder.position_at_end(then);
    let mut reachable = true;
    for stmt in then_stmt {
        statement(stmt, bin, func, func_val, var_table, ns);
        reachable = stmt.reachable();
    }

    if reachable {
        bin.builder.build_unconditional_branch(endif);
    }

    bin.builder.position_at_end(else_);

    reachable = true;
    for stmt in else_stmt {
        statement(stmt, bin, func, func_val, var_table, ns);
        reachable = stmt.reachable();
    }
    if reachable {
        bin.builder.build_unconditional_branch(endif);
    }

    bin.builder.position_at_end(endif);
}

fn returns<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func: &Function,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    // Can only be another function call without returns
    let values = match expr {
        Expression::FunctionCall { .. } => {
            emit_function_call(expr, bin, Some(func), func_val, var_table, ns)
        }
        // Can be any other expression
        _ => expression(expr, bin, Some(func), func_val, var_table, ns),
    };
    values
}

impl Type {
    /// Default value for a type, e.g. an empty string. Some types cannot have a
    /// default value, for example a reference to a variable in storage.
    pub fn default(&self, ns: &Namespace) -> Option<Expression> {
        match self {
            Type::Uint(_) => Some(Expression::NumberLiteral(
                program::Loc::Codegen,
                self.clone(),
                BigInt::from(0),
            )),
            Type::Bool => Some(Expression::BoolLiteral(program::Loc::Codegen, false)),
            Type::Enum(e) => ns.enums[*e].ty.default(ns),
            Type::Struct(n) => {
                // make sure all our fields have default values
                for field in &ns.structs[*n].fields {
                    field.ty.default(ns)?;
                }

                Some(Expression::StructLiteral(
                    program::Loc::Codegen,
                    self.clone(),
                    Vec::new(),
                ))
            }
            Type::StorageRef(..) => None,
            Type::Function { .. } => None,
            _ => None,
        }
    }
}
