use indexmap::IndexMap;
use inkwell::types::BasicTypeEnum;
use inkwell::values::{BasicValue, BasicValueEnum, FunctionValue};
use inkwell::AddressSpace;
use num_bigint::BigInt;
use num_traits::{ToPrimitive, Zero};

use super::expression::expression;
use super::functions::Vartable;
use super::storage::storage_delete;
use crate::irgen::binary::Binary;
use crate::irgen::expression::emit_function_call;
use crate::sema::ast::{
    self, ArrayLength, DestructureField, Expression, Namespace, RetrieveType, Statement, Type,
};
use ola_parser::program::Loc::IRgen;

/// Resolve a statement, which might be a block of statements or an entire body
/// of a function
pub(crate) fn statement<'a>(
    stmt: &Statement,
    bin: &mut Binary<'a>,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    match stmt {
        Statement::Block { statements, .. } => {
            for stmt in statements {
                statement(stmt, bin, func_value, var_table, ns);
            }
        }
        Statement::VariableDecl(_, pos, param, Some(init)) => {
            let var_value = expression(init, bin, func_value, var_table, ns);

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

        Statement::VariableDecl(_, pos, param, None) => {
            let default_value = param.ty.default(bin, func_value, ns).unwrap();
            var_table.insert(*pos, default_value);
        }

        Statement::Return(_, expr) => match expr {
            Some(expr) => {
                let ret_value = returns(expr, bin, func_value, var_table, ns);
                bin.builder.build_return(Some(&ret_value.unwrap()));
            }
            None => {}
        },
        Statement::Expression(_, _, expr) => {
            expression(expr, bin, func_value, var_table, ns);
        }

        Statement::If(_, _, cond, then_stmt, else_stmt) if else_stmt.is_empty() => {
            if_then(cond, bin, then_stmt, func_value, var_table, ns);
        }
        Statement::If(_, _, cond, then_stmt, else_stmt) => {
            if_then_else(cond, then_stmt, else_stmt, bin, func_value, var_table, ns)
        }

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
                statement(stmt, bin, func_value, var_table, ns);
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
                statement(stmt, bin, func_value, var_table, ns);

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
                statement(stmt, bin, func_value, var_table, ns);
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
                statement(stmt, bin, func_value, var_table, ns);

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

            bin.builder
                .build_conditional_branch(cond_expr.into_int_value(), body, end);

            bin.builder.position_at_end(body);

            bin.loops.push((end, cond));

            let mut body_reachable = true;

            for stmt in body_stmt {
                statement(stmt, bin, func_value, var_table, ns);

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
                statement(stmt, bin, func_value, var_table, ns);

                body_reachable = stmt.reachable();
            }

            if body_reachable {
                bin.builder.build_unconditional_branch(cond);
            }

            bin.builder.position_at_end(cond);

            let cond_expr = expression(cond_expr, bin, func_value, var_table, ns);

            bin.builder
                .build_conditional_branch(cond_expr.into_int_value(), body, end);

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
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    let pos = bin.builder.get_insert_block().unwrap();
    let cond = expression(cond, bin, func_value, var_table, ns);

    let then = bin.context.append_basic_block(func_value, "then");
    let endif = bin.context.append_basic_block(func_value, "enif");
    bin.builder.position_at_end(pos);

    bin.builder
        .build_conditional_branch(cond.into_int_value(), then, endif);
    bin.builder.position_at_end(then);
    let mut reachable = true;
    for stmt in then_stmt {
        statement(stmt, bin, func_value, var_table, ns);
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
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    let pos = bin.builder.get_insert_block().unwrap();
    let cond = expression(cond, bin, func_value, var_table, ns);

    let then = bin.context.append_basic_block(func_value, "then");
    let else_ = bin.context.append_basic_block(func_value, "else");
    let endif = bin.context.append_basic_block(func_value, "enif");
    bin.builder.position_at_end(pos);

    bin.builder
        .build_conditional_branch(cond.into_int_value(), then, else_);
    bin.builder.position_at_end(then);
    let mut reachable = true;
    for stmt in then_stmt {
        statement(stmt, bin, func_value, var_table, ns);
        reachable = stmt.reachable();
    }

    if reachable {
        bin.builder.build_unconditional_branch(endif);
    }

    bin.builder.position_at_end(else_);

    reachable = true;
    for stmt in else_stmt {
        statement(stmt, bin, func_value, var_table, ns);
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
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) -> Option<BasicValueEnum<'a>> {
    // Can only be another function call without returns
    let uncast_values = match expr {
        // TODO ADD ConditionalOperator
        ast::Expression::FunctionCall { .. } => {
            let (ret, _) = emit_function_call(expr, bin, func_value, var_table, ns);
            ret
        }
        ast::Expression::List { list, .. } => {
            let res = list
                .iter()
                .map(|e| expression(e, bin, func_value, var_table, ns))
                .collect::<Vec<BasicValueEnum>>();
            // Create the struct type based on the list length
            let struct_type = bin.context.struct_type(
                &res.iter()
                    .map(|value| value.get_type())
                    .collect::<Vec<BasicTypeEnum>>(),
                false,
            );
            // Allocate the struct
            let struct_ptr = bin.build_alloca(func_value, struct_type, "list_struct");

            // Store the values in the struct
            for (index, value) in res.into_iter().enumerate() {
                let field_ptr = bin.builder.build_struct_gep(
                    struct_type,
                    struct_ptr,
                    index as u32,
                    &format!("field_{}", index),
                );
                bin.builder.build_store(field_ptr.unwrap(), value);
            }
            Some(struct_ptr.into())
        }
        // Can be any other expression
        _ => Some(expression(expr, bin, func_value, var_table, ns)),
    };

    uncast_values
}

fn destructure<'a>(
    bin: &mut Binary<'a>,
    fields: &[DestructureField],
    expr: &Expression,
    func_value: FunctionValue<'a>,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    let mut is_single_value = false;
    if let ast::Expression::ConditionalOperator {
        cond,
        true_option: left,
        false_option: right,
        ..
    } = expr
    {
        let cond = expression(cond, bin, func_value, var_table, ns);
        let left_block = bin.context.append_basic_block(func_value, "left_value");
        let right_block = bin.context.append_basic_block(func_value, "right_value");
        let done_block = bin
            .context
            .append_basic_block(func_value, "conditional_done");

        bin.builder
            .build_conditional_branch(cond.into_int_value(), left_block, right_block);

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

    let value = match expr {
        // When the value of the expression on the right side is a List
        // We need to return a struct, which corresponds to handling multiple return values in
        // functions.
        ast::Expression::List { list, .. } => {
            let mut values = Vec::new();
            for expr in list {
                let elem = expression(expr, bin, func_value, var_table, ns);
                let elem_ty = bin.llvm_type(&expr.ty(), ns);
                let elem = if expr.ty().is_fixed_reference_type() {
                    bin.builder
                        .build_load(elem_ty, elem.into_pointer_value(), "elem")
                } else {
                    elem
                };
                values.push(elem);
            }
            // Create the struct type based on the types of the values
            let struct_member_types: Vec<BasicTypeEnum> =
                values.iter().map(|val| val.get_type()).collect();
            let struct_type = bin.context.struct_type(&struct_member_types, false);
            // Create the struct instance and fill the members with the values
            let struct_alloca = bin.build_alloca(func_value, struct_type, "struct_alloca");
            for (i, value) in values.iter().enumerate() {
                let field_ptr = bin.builder.build_struct_gep(
                    struct_type,
                    struct_alloca,
                    i as u32,
                    &format!("field_ptr{}", i),
                );
                bin.builder.build_store(field_ptr.unwrap(), *value);
            }
            struct_alloca.into()
        }
        _ => {
            // must be function call, either internal or external
            // function call may return multiple values, so we need to destructure them
            let (value, single_flag) = emit_function_call(expr, bin, func_value, var_table, ns);
            is_single_value = single_flag;
            value.unwrap()
        }
    };

    for (i, field) in fields.iter().enumerate() {
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
                if is_single_value {
                    bin.builder.build_store(alloc, value);
                } else {
                    let field = bin
                        .builder
                        .build_extract_value(
                            value.into_struct_value(),
                            i as u32,
                            param.name_as_str(),
                        )
                        .unwrap();
                    bin.builder.build_store(alloc, field);
                }
            }
            DestructureField::Expression(left) => {
                let left = match left {
                    Expression::Variable { var_no, .. } => {
                        let ret = *var_table.get(var_no).unwrap();
                        ret
                    }
                    _ => unreachable!(),
                };
                if is_single_value {
                    bin.builder.build_store(left.into_pointer_value(), value);
                } else {
                    let field = bin
                        .builder
                        .build_extract_value(value.into_struct_value(), i as u32, "")
                        .unwrap();
                    bin.builder.build_store(left.into_pointer_value(), field);
                }
            }
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
            Type::Uint(..) => {
                let num_expr = Expression::NumberLiteral {
                    loc: IRgen,
                    ty: self.clone(),
                    value: BigInt::from(0),
                };
                Some(expression(&num_expr, bin, func_value, &mut var_table, ns))
            }
            Type::Address => {
                let address_expr = Expression::AddressLiteral {
                    loc: IRgen,
                    ty: self.clone(),
                    value: vec![BigInt::from(0); 4],
                };
                Some(expression(
                    &address_expr,
                    bin,
                    func_value,
                    &mut var_table,
                    ns,
                ))
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
            Type::Struct(n) => {
                // make sure all our fields have default values
                for field in &ns.structs[*n].fields {
                    field.ty.default(bin, func_value, ns)?;
                }

                let struct_expr = Expression::StructLiteral {
                    loc: IRgen,
                    ty: self.clone(),
                    values: Vec::new(),
                };
                Some(expression(
                    &struct_expr,
                    bin,
                    func_value,
                    &mut var_table,
                    ns,
                ))
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
                        bin.context
                            .i64_type()
                            .ptr_type(AddressSpace::default())
                            .const_null()
                            .into(),
                    )
                } else {
                    let dims = dims
                        .iter()
                        .map(|d| match d {
                            ArrayLength::Fixed(d) => d.to_u32().unwrap(),
                            _ => unreachable!(),
                        })
                        .collect::<Vec<_>>();

                    let values = vec![
                        Expression::NumberLiteral {
                            loc: IRgen,
                            ty: Type::Uint(32),
                            value: BigInt::zero(),
                        };
                        self.array_length().unwrap().to_usize().unwrap()
                    ];
                    let array_expr = Expression::ArrayLiteral {
                        loc: IRgen,
                        ty: self.clone(),
                        dimensions: dims,
                        values,
                    };
                    Some(expression(&array_expr, bin, func_value, &mut var_table, ns))
                }
            }
            Type::Function { .. } => None,
            Type::String => Some(
                bin.context
                    .i64_type()
                    .ptr_type(AddressSpace::default())
                    .const_null()
                    .into(),
            ),
            _ => None,
        }
    }
}
