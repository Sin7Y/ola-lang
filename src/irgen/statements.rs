use inkwell::values::{BasicValue, BasicValueEnum, FunctionValue};
use num_bigint::BigInt;
use std::collections::HashMap;

use super::expression::expression;
use crate::irgen::binary::Binary;
use crate::irgen::expression::emit_function_call;
use crate::sema::ast::{Expression, Function, Namespace, Statement, Type};
use ola_parser::program;

/// Resolve a statement, which might be a block of statements or an entire body of a function
pub(crate) fn statement<'a>(
    stmt: &Statement,
    bin: &Binary<'a>,
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
            var_table.insert(*pos, alloc.as_basic_value_enum());
            let var_value = expression(init, bin, Some(func), func_val, var_table, ns);
            var_table.insert(*pos, var_value);
            bin.builder.build_store(alloc, var_value);
        }

        Statement::Return(_, expr) => match expr {
            None => {
                let i32_type = bin.context.i32_type();
                bin.builder.build_return(Some(&i32_type.const_zero()));
            }
            Some(expr) => {
                let return_vals = returns(expr, bin, func, func_val, var_table, ns);
                let returns_offset = func.params.len();
                for (i, ret) in return_vals.iter().enumerate() {
                    let arg = func_val.get_nth_param((returns_offset + i) as u32).unwrap();
                    bin.builder.build_store(arg.into_pointer_value(), *ret);
                }

                let i32_type = bin.context.i32_type();
                bin.builder.build_return(Some(&i32_type.const_zero()));
            }
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

        _ => {}
    }
}

/// Generate if-then-no-else
fn if_then<'a>(
    cond: &Expression,
    bin: &Binary<'a>,
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
    bin: &Binary<'a>,
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
) -> Vec<BasicValueEnum<'a>> {
    // Can only be another function call without returns
    let values = match expr {
        Expression::List(_, exprs) => exprs
            .iter()
            .map(|e| expression(e, bin, Some(func), func_val, var_table, ns))
            .collect::<Vec<BasicValueEnum>>(),
        Expression::FunctionCall { .. } => {
            emit_function_call(expr, bin, Some(func), func_val, var_table, ns)
        }
        // Can be any other expression
        _ => {
            vec![expression(expr, bin, Some(func), func_val, var_table, ns)]
        }
    };
    values
}

impl Type {
    /// Default value for a type, e.g. an empty string. Some types cannot have a default value,
    /// for example a reference to a variable in storage.
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
