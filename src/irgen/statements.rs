use indexmap::IndexMap;
use inkwell::basic_block::BasicBlock;
use inkwell::values::{BasicValue, BasicValueEnum, FunctionValue};
use num_bigint::BigInt;
use num_traits::ToPrimitive;

use super::expression::expression;
use super::functions::Vartable;
use super::storage::{storage_delete, storage_store};
use crate::irgen::binary::Binary;
use crate::irgen::expression::emit_function_call;
use crate::sema::ast::{
    self, ArrayLength, DestructureField, Expression, Function, Namespace, RetrieveType, Statement,
    Type,
};
use ola_parser::program::Loc::IRgen;

/// Resolve a statement, which might be a block of statements or an entire body
/// of a function
pub(crate) fn statement<'a>(
    stmt: &Statement,
    bin: &mut Binary<'a>,
    func_value: FunctionValue<'a>,
    func: &Function,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    match stmt {
        Statement::Block { statements, .. } => {
            for stmt in statements {
                statement(stmt, bin, func_value, func, var_table, ns);
                if !stmt.reachable() {
                    break;
                }
            }
        }
        Statement::VariableDecl(_, pos, param, init) => {
            let var_value = match init {
                Some(init) => expression(init, bin, func_value, var_table, ns),
                None => param.ty.default(bin, func_value, ns).unwrap(),
            };

            let alloca = if param.ty.is_reference_type(ns) && !param.ty.is_contract_storage() {
                var_value.into_pointer_value()
            } else {
                let alloca = bin.build_alloca(
                    func_value,
                    bin.llvm_type(&param.ty, ns),
                    param.name_as_str(),
                );

                bin.builder.build_store(alloca, var_value);
                alloca
            };

            var_table.insert(*pos, alloca.as_basic_value_enum());
        }

        Statement::Return(_, expr) => match expr {
            Some(expr) => {
                returns(expr, bin, func_value, func, var_table, ns);
            }
            None => {
                bin.builder.build_return(None);
            }
        },
        Statement::Expression(_, _, expr) => {
            expression(expr, bin, func_value, var_table, ns);
        }

        Statement::If(_, _, cond, then_stmt, else_stmt) if else_stmt.is_empty() => {
            if_then(cond, bin, then_stmt, func_value, func, var_table, ns);
        }
        Statement::If(_, _, cond, then_stmt, else_stmt) => if_then_else(
            cond, then_stmt, else_stmt, bin, func_value, func, var_table, ns,
        ),

        Statement::For {
            init,
            cond: Some(cond_expr),
            next,
            body,
            ..
        } => {
            let cond_block = bin.context.append_basic_block(func_value, "cond");
            let body_block = bin.context.append_basic_block(func_value, "body");
            let next_block = bin.context.append_basic_block(func_value, "next");
            let end_block = bin.context.append_basic_block(func_value, "endfor");
            for stmt in init {
                statement(stmt, bin, func_value, func, var_table, ns);
            }

            bin.builder.build_unconditional_branch(cond_block);
            bin.builder.position_at_end(cond_block);

            let cond_expr = expression(cond_expr, bin, func_value, var_table, ns);

            bin.builder
                .build_conditional_branch(cond_expr.into_int_value(), body_block, end_block);

            // compile loop body
            bin.builder.position_at_end(body_block);

            bin.loops.push((end_block, next_block));

            let mut body_reachable = true;

            for stmt in body {
                statement(stmt, bin, func_value, func, var_table, ns);

                body_reachable = stmt.reachable();
            }

            if body_reachable {
                // jump to next body
                bin.builder.build_unconditional_branch(next_block);
            }

            bin.loops.pop();

            bin.builder.position_at_end(next_block);

            let mut next_reachable = true;

            if let Some(next) = next {
                expression(next, bin, func_value, var_table, ns);

                next_reachable = next.ty() != Type::Unreachable;
            }

            if next_reachable {
                bin.builder.build_unconditional_branch(cond_block);
            }

            bin.builder.position_at_end(end_block);
        }
        Statement::For {
            init,
            cond: None,
            next,
            body,
            ..
        } => {
            let body_block = bin.context.append_basic_block(func_value, "body");
            let next_block = bin.context.append_basic_block(func_value, "next");
            let end_block = bin.context.append_basic_block(func_value, "endfor");

            for stmt in init {
                statement(stmt, bin, func_value, func, var_table, ns);
            }

            bin.builder.build_unconditional_branch(body_block);
            bin.builder.position_at_end(body_block);

            bin.loops.push((
                end_block,
                if next.is_none() {
                    body_block
                } else {
                    next_block
                },
            ));
            let mut body_reachable = true;
            for stmt in body {
                statement(stmt, bin, func_value, func, var_table, ns);

                body_reachable = stmt.reachable();
            }

            if body_reachable {
                // jump to next body
                bin.builder.build_unconditional_branch(next_block);
            }

            bin.loops.pop();

            if body_reachable {
                // jump to next body
                bin.builder.position_at_end(next_block);

                if let Some(next) = next {
                    expression(next, bin, func_value, var_table, ns);

                    body_reachable = next.ty() != Type::Unreachable;
                }
                if body_reachable {
                    bin.builder.build_unconditional_branch(body_block);
                }
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

        Statement::While(_, _, cond_expr, body_stmt) => {
            let body = bin.context.append_basic_block(func_value, "body");
            let cond = bin.context.append_basic_block(func_value, "cond");
            let end = bin.context.append_basic_block(func_value, "endwhile");

            bin.builder.build_unconditional_branch(cond);

            bin.builder.position_at_end(cond);

            let cond_expr = expression(cond_expr, bin, func_value, var_table, ns);
            let cond_expr = bin.builder.build_int_truncate(
                cond_expr.into_int_value(),
                bin.context.bool_type(),
                "",
            );

            bin.builder.build_conditional_branch(cond_expr, body, end);

            bin.builder.position_at_end(body);

            bin.loops.push((end, cond));

            let mut body_reachable = true;

            for stmt in body_stmt {
                statement(stmt, bin, func_value, func, var_table, ns);

                body_reachable = stmt.reachable();
            }

            if body_reachable {
                bin.builder.build_unconditional_branch(cond);
            }

            bin.loops.pop();

            bin.builder.position_at_end(end);
        }
        Statement::DoWhile(_, _, body_stmt, cond_expr) => {
            let body = bin.context.append_basic_block(func_value, "body");
            let cond = bin.context.append_basic_block(func_value, "cond");

            let end = bin.context.append_basic_block(func_value, "enddowhile");

            bin.builder.build_unconditional_branch(body);

            bin.builder.position_at_end(body);

            bin.loops.push((end, cond));

            let mut body_reachable = true;

            for stmt in body_stmt {
                statement(stmt, bin, func_value, func, var_table, ns);

                body_reachable = stmt.reachable();
            }

            if body_reachable {
                bin.builder.build_unconditional_branch(cond);
            }

            bin.builder.position_at_end(cond);

            let cond_expr = expression(cond_expr, bin, func_value, var_table, ns);
            let cond_expr = bin.builder.build_int_truncate(
                cond_expr.into_int_value(),
                bin.context.bool_type(),
                "",
            );

            bin.builder.build_conditional_branch(cond_expr, body, end);

            bin.builder.position_at_end(end);
        }
        Statement::Delete(_, ty, expr) => {
            let mut slot = expression(expr, bin, func_value, var_table, ns);
            storage_delete(bin, ty, &mut slot, func_value, ns);
        }

        Statement::Destructure(_, fields, expr) => {
            destructure(bin, fields, expr, func_value, var_table, ns)
        }
    }
}

/// Generate if-then-no-else
fn if_then<'a>(
    cond: &Expression,
    bin: &mut Binary<'a>,
    then_stmt: &[Statement],
    func_value: FunctionValue<'a>,
    func: &Function,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    let cond = expression(cond, bin, func_value, var_table, ns);

    let cond = bin
        .builder
        .build_int_truncate(cond.into_int_value(), bin.context.bool_type(), "");

    let then = bin.context.append_basic_block(func_value, "then");
    let endif = bin.context.append_basic_block(func_value, "endif");

    bin.builder.build_conditional_branch(cond, then, endif);
    bin.builder.position_at_end(then);
    let mut reachable = true;
    for stmt in then_stmt {
        statement(stmt, bin, func_value, func, var_table, ns);
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
    func_value: FunctionValue<'a>,
    func: &Function,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    let cond = expression(cond, bin, func_value, var_table, ns);
    let cond = bin
        .builder
        .build_int_truncate(cond.into_int_value(), bin.context.bool_type(), "");

    let then = bin.context.append_basic_block(func_value, "then");
    let else_ = bin.context.append_basic_block(func_value, "else");

    let mut endif: Option<BasicBlock> = None;

    bin.builder.build_conditional_branch(cond, then, else_);
    bin.builder.position_at_end(then);
    let mut then_reachable = true;
    for stmt in then_stmt {
        statement(stmt, bin, func_value, func, var_table, ns);
        then_reachable = stmt.reachable();
    }

    if then_reachable {
        if endif.is_none() {
            endif = Some(bin.context.append_basic_block(func_value, "endif"));
        }
        bin.builder.build_unconditional_branch(endif.unwrap());
    }

    bin.builder.position_at_end(else_);

    let mut else_reachable = true;
    for stmt in else_stmt {
        statement(stmt, bin, func_value, func, var_table, ns);
        else_reachable = stmt.reachable();
    }
    if else_reachable {
        if endif.is_none() {
            endif = Some(bin.context.append_basic_block(func_value, "endif"));
        }
        bin.builder.build_unconditional_branch(endif.unwrap());
    }
    if let Some(endif_block) = endif {
        bin.builder.position_at_end(endif_block);
    }
}

fn returns<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    func: &Function,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    // Can only be another function call without returns
    let uncast_values = match expr {
        // TODO ADD ConditionalOperator
        ast::Expression::LibFunction {
            kind: ast::LibFunc::AbiDecode,
            ..
        }
        | ast::Expression::FunctionCall { .. }
        | ast::Expression::ExternalFunctionCallRaw { .. } => {
            emit_function_call(expr, bin, func_value, var_table, ns)
        }
        ast::Expression::List { list, .. } => list
            .iter()
            .map(|e| expression(e, bin, func_value, var_table, ns))
            .collect::<Vec<BasicValueEnum>>(),

        // Can be any other expression
        _ => vec![expression(expr, bin, func_value, var_table, ns)],
    };

    // TODO Should we do type conversion here?

    if !uncast_values.is_empty() {
        if uncast_values.len() == 1 {
            bin.builder.build_return(Some(&uncast_values[0]));
        } else {
            let returns_offset = func.params.len();
            for (i, val) in uncast_values.iter().enumerate() {
                let arg = func_value
                    .get_nth_param((returns_offset + i) as u32)
                    .unwrap();
                bin.builder.build_store(arg.into_pointer_value(), *val);
            }
            bin.builder.build_return(None);
        }
    }
}

fn destructure<'a>(
    bin: &mut Binary<'a>,
    fields: &[DestructureField],
    expr: &Expression,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    if let ast::Expression::ConditionalOperator {
        cond,
        true_option: left,
        false_option: right,
        ..
    } = expr
    {
        let cond = expression(cond, bin, func_value, var_table, ns);
        let cond =
            bin.builder
                .build_int_truncate(cond.into_int_value(), bin.context.bool_type(), "");
        let left_block = bin.context.append_basic_block(func_value, "left_value");
        let right_block = bin.context.append_basic_block(func_value, "right_value");
        let done_block = bin
            .context
            .append_basic_block(func_value, "conditional_done");

        bin.builder
            .build_conditional_branch(cond, left_block, right_block);

        bin.builder.position_at_end(left_block);

        destructure(bin, fields, left, func_value, var_table, ns);
        bin.builder.build_unconditional_branch(done_block);

        bin.builder.position_at_end(right_block);

        destructure(bin, fields, right, func_value, var_table, ns);
        bin.builder.build_unconditional_branch(done_block);

        bin.builder.position_at_end(done_block);

        bin.builder.position_at_end(done_block);

        return;
    }

    let mut values = match expr {
        // When the value of the expression on the right side is a List
        // We need to return a struct, which corresponds to handling multiple return values in
        // functions.
        ast::Expression::List { list, .. } => {
            let mut values = Vec::new();
            for expr in list {
                let elem = expression(expr, bin, func_value, var_table, ns);
                // let elem_ty = bin.llvm_type(&expr.ty(), ns);
                // let elem = if expr.ty().is_fixed_reference_type() {
                //     bin.builder
                //         .build_load(elem_ty, elem.into_pointer_value(), "elem")
                // } else {
                //     elem
                // };
                values.push(elem);
            }
            values
        }
        _ => {
            // must be function call, either internal or external
            // function call may return multiple values, so we need to destructure them
            emit_function_call(expr, bin, func_value, var_table, ns)
        }
    };

    for (_, field) in fields.iter().enumerate() {
        let right_value = values.remove(0);
        match field {
            DestructureField::None => {
                // nothing to do
            }
            // (u32 a, u32 b) = returnTwoValues();
            DestructureField::VariableDecl(res, param) => {
                let alloc = bin.build_alloca(
                    func_value,
                    bin.llvm_type(&param.ty, ns),
                    param.name_as_str(),
                );

                var_table.insert(*res, alloc.as_basic_value_enum());
                bin.builder.build_store(alloc, right_value);
            }
            DestructureField::Expression(left) => match left {
                Expression::Variable { var_no, .. } => {
                    var_table.insert(*var_no, right_value);
                }
                _ => {
                    let left_ty = left.ty();
                    let ty = left_ty.deref_memory();

                    let mut dest = expression(left, bin, func_value, var_table, ns);

                    match left_ty {
                        Type::StorageRef(..) => {
                            storage_store(
                                bin,
                                &ty.deref_any().clone(),
                                &mut dest,
                                right_value,
                                func_value,
                                ns,
                            );
                        }
                        Type::Ref(..) => {
                            bin.builder
                                .build_store(dest.into_pointer_value(), right_value);
                        }
                        _ => unreachable!(),
                    }
                }
            },
        }
    }
}

impl Type {
    /// Default value for a type, e.g. an empty string. Some types cannot
    /// have a default value, for example a reference to a variable
    /// in storage.
    pub fn default<'a>(
        &self,
        bin: &Binary<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) -> Option<BasicValueEnum<'a>> {
        let mut var_table: Vartable = IndexMap::new();
        match self {
            Type::Uint(32) | Type::Field | Type::Uint(256) | Type::Address | Type::Contract(_) | Type::Hash => {
                let num_expr = Expression::NumberLiteral {
                    loc: IRgen,
                    ty: self.clone(),
                    value: BigInt::from(0),
                };
                Some(expression(&num_expr, bin, func_value, &mut var_table, ns))
            }
            Type::Bool => {
                let bool_expr = Expression::BoolLiteral {
                    loc: IRgen,
                    value: false,
                };
                Some(expression(&bool_expr, bin, func_value, &mut var_table, ns))
            }
            Type::Enum(e) => {
                let ty = &ns.enums[*e];
                let num_expr = Expression::NumberLiteral {
                    loc: IRgen,
                    ty: ty.ty.clone(),
                    value: BigInt::from(0),
                };
                Some(expression(&num_expr, bin, func_value, &mut var_table, ns))
            }
            Type::Struct(..) => {
                // make sure all our fields have default values
                // let struct_ty = bin.llvm_type(self, ns);

                let struct_size = bin
                    .context
                    .i64_type()
                    .const_int(self.type_size_of(ns).to_u64().unwrap(), false);

                let struct_alloca = bin.heap_malloc(struct_size);

                // TODO this is not correct, we need to call the default function
                // for (i, param) in ns.structs[*no].fields.iter().enumerate() {
                //     let elemptr = bin
                //         .builder
                //         .build_struct_gep(struct_ty, struct_alloca, i as u32,
                // "struct_member")         .unwrap();

                //     let elem = param.ty.default(bin, func_value, ns)?;

                //     bin.builder.build_store(elemptr, elem);
                // }

                Some(struct_alloca.into())
            }
            Type::Ref(ty) => {
                assert!(matches!(ty.as_ref(), Type::Address));

                let ref_expr = Expression::GetRef {
                    loc: IRgen,
                    ty: Type::Ref(Box::new(ty.as_ref().clone())),
                    expr: Box::new(Expression::NumberLiteral {
                        loc: IRgen,
                        ty: ty.as_ref().clone(),
                        value: BigInt::from(0),
                    }),
                };
                Some(expression(&ref_expr, bin, func_value, &mut var_table, ns))
            }
            Type::StorageRef(..) => None,
            Type::Array(ty, dims) => {
                ty.default(bin, func_value, ns)?;

                if dims.last() == Some(&ArrayLength::Dynamic) {
                    Some(
                        bin.vector_new(bin.context.i64_type().const_zero())
                            .as_basic_value_enum(),
                    )
                } else {
                    let array_size = bin
                        .context
                        .i64_type()
                        .const_int(self.type_size_of(ns).to_u64().unwrap(), false);

                    let array_alloca = bin.heap_malloc(array_size);

                    Some(array_alloca.into())
                }
            }
            Type::Function { .. } => None,
            Type::String | Type::DynamicBytes => Some(
                bin.vector_new(bin.context.i64_type().const_zero())
                    .as_basic_value_enum(),
            ),
            _ => None,
        }
    }
}
