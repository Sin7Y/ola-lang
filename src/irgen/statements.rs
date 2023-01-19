// SPDX-License-Identifier: Apache-2.0

use num_bigint::BigInt;
use inkwell::values::{BasicValueEnum, FunctionValue};

use super::expression::{expression};
use crate::sema::ast::Expression;
use crate::sema::ast::RetrieveType;
use crate::sema::ast::{
    ArrayLength, Function, Namespace, Parameter, Statement,
    Type,
};
use crate::sema::{ast, Recurse};
use ola_parser::program;
use crate::irgen::binary::Binary;

/// Resolve a statement, which might be a block of statements or an entire body of a function
pub(crate) fn statement<'a>(
    stmt: &Statement,
    bin: &Binary<'a>,
    func: &Function,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    match stmt {
        Statement::Block { statements, .. } => {
            for stmt in statements {
                statement(
                    stmt,
                    bin,
                    func,
                    func_value,
                    ns,
                );
            }
        }
        Statement::VariableDecl(loc, pos, param, Some(init)) => {
            let mut var_value = expression(init, bin, Some(func), func_value, ns);
            let alloc = bin.builder.build_alloca( bin.llvm_var_ty(&param.ty, ns), param.name_as_str())
                .into();
            bin.builder.build_store(alloc, var_value);
        }

        Statement::Return(_, expr) => {
                match expr {
                    None => {
                        let i32_type = bin.context.i32_type();
                        bin.builder
                            .build_return(Some(&i32_type.const_zero()));
                    }
                    Some(expr) => {
                        let return_vals = returns(expr, bin, func, func_value, ns);
                        let returns_offset = func.params.len();
                        for (i, ret) in return_vals.iter().enumerate() {
                            let arg = func_value.get_nth_param((returns_offset + i) as u32).unwrap();
                            bin.builder.build_store(arg.into_pointer_value(), ret.clone());
                        }

                        let i32_type = bin.context.i32_type();
                        bin.builder
                            .build_return(Some(&i32_type.const_zero()));
                    }
                }
        }
        Statement::Expression(_, _, expr) => {
            expression(expr, bin,  Some(func), func_value, ns);
        }


        Statement::If(_, _, cond, then_stmt, else_stmt) if else_stmt.is_empty() => {
            if_then(
                cond,
                bin,
                then_stmt,
                func,
                func_value,
                ns,
            );
        }
        Statement::If(_, _, cond, then_stmt, else_stmt) => if_then_else(
            cond,
            then_stmt,
            else_stmt,
            bin,
            func,
            func_value,
            ns,
        ),

        _ => {}
    }
}

/// Generate if-then-no-else
fn if_then<'a>(
    cond: &ast::Expression,
    bin: &Binary<'a>,
    then_stmt: &[Statement],
    func: &Function,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    let pos = bin.builder.get_insert_block().unwrap();
    let cond = expression(cond, bin, Some(func), func_value, ns);

    let then = bin.context.append_basic_block(func_value, "then");
    let endif = bin.context.append_basic_block(func_value, "enif");
    bin.builder.position_at_end(pos);

    bin.builder
        .build_conditional_branch(cond.into_int_value(), then, endif);
    bin.builder.position_at_end(then);
    let mut reachable = true;
    for stmt in then_stmt {
        statement(
            stmt,
            bin,
            func,
            func_value,
            ns,
        );
        reachable = stmt.reachable();
    }

    if reachable {
        bin.builder.build_unconditional_branch(endif);
    }
    bin.builder.position_at_end(endif);

}

/// Generate if-then-else
fn if_then_else<'a>(
    cond: &ast::Expression,
    then_stmt: &[Statement],
    else_stmt: &[Statement],
    bin: &Binary<'a>,
    func: &Function,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {

    let pos = bin.builder.get_insert_block().unwrap();
    let cond = expression(cond, bin, Some(func), func_value, ns);

    let then = bin.context.append_basic_block(func_value, "then");
    let else_ = bin.context.append_basic_block(func_value, "else");
    let endif = bin.context.append_basic_block(func_value, "enif");
    bin.builder.position_at_end(pos);

    bin.builder
        .build_conditional_branch(cond.into_int_value(), then, else_);
    bin.builder.position_at_end(then);
    let mut reachable = true;
    for stmt in then_stmt {
        statement(
            stmt,
            bin,
            func,
            func_value,
            ns,
        );
        reachable = stmt.reachable();
    }

    if reachable {
        bin.builder.build_unconditional_branch(endif);
    }

    bin.builder.position_at_end(else_);

    reachable = true;
    for stmt in else_stmt {
        statement(
            stmt,
            bin,
            func,
            func_value,
            ns,
        );
        reachable = stmt.reachable();
    }
    if reachable {
        bin.builder.build_unconditional_branch(endif);
    }

    bin.builder.position_at_end(endif);

}

fn returns<'a>(
    expr: &ast::Expression,
    bin: &Binary<'a>,
    func: &Function,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> Vec<BasicValueEnum<'a>> {
    // Can only be another function call without returns
    let values = match expr {
        ast::Expression::List(_, exprs) => exprs
            .iter()
            .map(|e| expression(e, bin, Some(func), func_value, ns))
            .collect::<Vec<BasicValueEnum>>(),

        // Can be any other expression
        _ => {
            vec![expression(
                expr,
                bin,
                Some(func),
                func_value,
                ns,
            )]
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
            Type::Function { .. }  => {
                None
            }
            _ => None,
        }
    }
}
