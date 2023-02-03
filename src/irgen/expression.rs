// SPDX-License-Identifier: Apache-2.0

use std::borrow::Borrow;
use crate::irgen::binary::Binary;
use crate::sema::ast::Expression;
use crate::sema::{
    ast,
    ast::{ArrayLength, Function, Namespace, RetrieveType, Type},
    diagnostics::Diagnostics,
    eval::eval_const_number,
    expression::{bigint_to_expression, ResolveTo},
};
use inkwell::values::{
    BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue, PointerValue,
};
use inkwell::IntPredicate;
use num_bigint::BigInt;
use num_traits::{FromPrimitive, One, ToPrimitive, Zero};
use ola_parser::program;
use ola_parser::program::{CodeLocation, Loc};
use std::collections::HashMap;
use std::env::var;
use std::ops::Mul;

pub fn expression<'a>(
    expr: &ast::Expression,
    bin: &Binary<'a>,
    func: Option<&Function>,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match expr {
        ast::Expression::Add(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns);
            let right = expression(r, bin, func, func_val, var_table, ns);
            bin.builder.build_int_add(left.into_int_value(), right.into_int_value(), "").into()
        }
        ast::Expression::Subtract(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_sub(left, right, "").into()
        }
        ast::Expression::Multiply(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_mul(left, right, "").into()
        }
        ast::Expression::Divide(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_unsigned_div(left, right, "").into()
        }
        ast::Expression::Modulo(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_unsigned_rem(left, right, "").into()
        }
        ast::Expression::BitwiseOr(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_or(left, right, "").into()
        }
        ast::Expression::BitwiseAnd(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_and(left, right, "").into()
        }
        ast::Expression::BitwiseXor(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_xor(left, right, "").into()
        }
        ast::Expression::ShiftLeft(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_left_shift(left, right, "").into()
        }
        ast::Expression::ShiftRight(loc, ty, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_right_shift(left, right, false, "").into()
        }
        ast::Expression::Equal(loc, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::EQ, left, right, "")
                .into()
        }
        ast::Expression::NotEqual(loc, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::NE, left, right, "")
                .into()
        }
        ast::Expression::More(loc, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::UGT, left, right, "")
                .into()
        }
        ast::Expression::MoreEqual(loc, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::UGE, left, right, "")
                .into()
        }
        ast::Expression::Less(loc, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::ULT, left, right, "")
                .into()
        }
        ast::Expression::LessEqual(loc, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::ULE, left, right, "")
                .into()
        }
        ast::Expression::Not(loc, expr) => {
            let e = expression(expr, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::EQ, e, e.get_type().const_zero(), "")
                .into()
        }
        ast::Expression::Complement(loc, ty, expr) => {
            let e = expression(expr, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_not(e, "").into()
        }
        ast::Expression::Assign(_, _, l, r) => {
            let right = expression(r, bin, func, func_val, var_table, ns);
            let left = match **l {
                Expression::Variable(_,_, pos) => {
                    let ret = *var_table.get(&pos).unwrap();
                    var_table.insert(pos, right);
                     ret
                }
                _ => unreachable!()
            };
            bin.builder.build_store(left.into_pointer_value(), right);
            left
        }
        ast::Expression::FunctionCall { .. } => {
            let mut ret = emit_function_call(expr, bin, func, func_val, var_table, ns);
            ret.remove(0)
        }

        ast::Expression::Or(loc, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns);
            let right = expression(r, bin, func, func_val, var_table, ns);
            bin.builder.build_or(left.into_int_value(), right.into_int_value(), "").into()
        }

        ast::Expression::NumberLiteral(loc, ty, n) => {
            bin.number_literal(ty.bits(ns) as u32, n, ns).into()
        }

        ast::Expression::Variable(loc, ty, var_no) => {
            var_table.get(var_no).unwrap().as_basic_value_enum()
        }
        _ => unreachable!(),
    }
}
//
// fn pre_incdec(
//     vartab: &mut Vartable,
//     ty: &Type,
//     var: &ast::Expression,
//     cfg: &mut ControlFlowGraph,
//     contract_no: usize,
//     func: Option<&Function>,
//     ns: &Namespace,
//     loc: &pt::Loc,
//     expr: &ast::Expression,
//     unchecked: &bool,
//     opt: &Options,
// ) -> Expression {
//     let res = vartab.temp_anonymous(ty);
//     let v = expression(var, cfg, contract_no, func, ns, vartab, opt);
//     let v = match var.ty() {
//         Type::Ref(ty) => Expression::Load(var.loc(), ty.as_ref().clone(), Box::new(v)),
//         Type::StorageRef(_, ty) => load_storage(&var.loc(), ty.as_ref(), v, cfg, vartab),
//         _ => v,
//     };
//     let one = Box::new(Expression::NumberLiteral(*loc, ty.clone(), BigInt::one()));
//     let expr = match expr {
//         ast::Expression::PreDecrement { .. } => {
//             Expression::Subtract(*loc, ty.clone(), *unchecked, Box::new(v), one)
//         }
//         ast::Expression::PreIncrement { .. } => {
//             Expression::Add(*loc, ty.clone(), *unchecked, Box::new(v), one)
//         }
//         _ => unreachable!(),
//     };
//     cfg.add(
//         vartab,
//         Instr::Set {
//             loc: expr.loc(),
//             res,
//             expr,
//         },
//     );
//     match var {
//         ast::Expression::Variable(loc, _, pos) => {
//             cfg.add(
//                 vartab,
//                 Instr::Set {
//                     loc: *loc,
//                     res: *pos,
//                     expr: Expression::Variable(*loc, ty.clone(), res),
//                 },
//             );
//         }
//         _ => unreachable!()
//     }
//     Expression::Variable(*loc, ty.clone(), res)
// }

// fn expr_or<'a>(
//     left: &ast::Expression,
//     right: &ast::Expression,
//     bin: &Binary<'a>,
//     func: Option<&Function>,
//     func_val: FunctionValue<'a>,
//     ns: &Namespace,
//
// ) -> Expression {
//     let l = expression(left, bin, func, func_val, ns);
//     let alloc = bin.builder.build_alloca( bin.llvm_var_ty(&left.ty(), ns), "")
//         .into();
//     bin.builder.build_store(alloc, l);
//
//     cfg.add(
//         vartab,
//         Instr::BranchCond {
//             cond: l,
//             true_block: end_or,
//             false_block: right_side,
//         },
//     );
//   =
//     {
//         let cond = expression(target, bin, cond, &w.vars, function, ns);
//
//         let pos = bin.builder.get_insert_block().unwrap();
//
//         let bb_true =
//             add_or_retrieve_block(*true_, pos, bin, function, blocks, work, w, cfg, ns);
//
//         let bb_false =
//             add_or_retrieve_block(*false_, pos, bin, function, blocks, work, w, cfg, ns);
//
//         bin.builder.position_at_end(pos);
//         bin.builder
//             .build_conditional_branch(cond.into_int_value(), bb_true, bb_false);
//     }
//
//
//     let r = expression(right, bin, func, func_val, ns);
//     let alloc = bin.builder.build_alloca( bin.llvm_var_ty(&right.ty(), ns), "")
//         .into();
//     bin.builder.build_store(alloc, r);
//
//     cfg.add(vartab, Instr::Branch { block: end_or });
//
//     =
//     {
//         let pos = bin.builder.get_insert_block().unwrap();
//
//         let bb = add_or_retrieve_block(*dest, pos, bin, function, blocks, work, w, cfg, ns);
//
//         bin.builder.position_at_end(pos);
//         bin.builder.build_unconditional_branch(bb);
//     }
//
//     cfg.set_basic_block(end_or);
//     cfg.set_phis(end_or, vartab.pop_dirty_tracker());
//     Expression::Variable(*loc, Type::Bool, pos)
// }

//Convert a function call expression to CFG in expression context
pub fn emit_function_call<'a>(
    expr: &ast::Expression,
    bin: &Binary<'a>,
    func: Option<&Function>,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) -> Vec<BasicValueEnum<'a>> {
    let mut ret_value = Vec::new();
    match expr {
        ast::Expression::FunctionCall {
            function,
            returns,
            args,
            ..
        } => {
            if let ast::Expression::Function {
                function_no,
                signature,
                ..
            } = function.as_ref()
            {
                let mut params = args
                    .iter()
                    .map(|a| expression(a, bin, func, func_val, var_table, ns).into())
                    .collect::<Vec<BasicMetadataValueEnum>>();
                let callee = &ns.functions[*function_no];
                if !callee.returns.is_empty() {
                    for v in callee.returns.iter() {
                        params.push(
                            bin.builder
                                .build_alloca(bin.llvm_var_ty(&v.ty, ns), v.name_as_str())
                                .into(),
                        );
                    }
                }

                let ret = bin
                    .builder
                    .build_call(func_val, &params, "")
                    .try_as_basic_value()
                    .left()
                    .unwrap();

                 let success = bin.builder.build_int_compare(
                    IntPredicate::EQ,
                    ret.into_int_value(),
                    bin.context.i32_type().const_zero(),
                    "success",
                );

                let success_block = bin.context.append_basic_block(func_val, "success");
                let bail_block = bin.context.append_basic_block(func_val, "bail");
                bin.builder
                    .build_conditional_branch(success, success_block, bail_block);

                bin.builder.position_at_end(bail_block);

                bin.builder.build_return(Some(&ret));
                bin.builder.position_at_end(success_block);
                if !returns.is_empty() {
                    for (i, v) in func.unwrap().returns.iter().enumerate() {
                        ret_value.push(bin.builder.build_load(
                            params[args.len() + i].into_pointer_value(),
                            v.name_as_str(),
                        ));
                    }
                }
            }
            ret_value
        }
        _ => unreachable!(),
    }
}
