use crate::irgen::binary::Binary;
use crate::sema::ast::{Expression, Function, Namespace};
use inkwell::values::{BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue};
use inkwell::IntPredicate;
use std::collections::HashMap;

pub fn expression<'a>(
    expr: &Expression,
    bin: &Binary<'a>,
    func: Option<&Function>,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    match expr {
        Expression::Add(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns);
            let right = expression(r, bin, func, func_val, var_table, ns);
            bin.builder
                .build_int_add(left.into_int_value(), right.into_int_value(), "")
                .into()
        }
        Expression::Subtract(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_sub(left, right, "").into()
        }
        Expression::Multiply(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_mul(left, right, "").into()
        }
        Expression::Divide(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_unsigned_div(left, right, "").into()
        }
        Expression::Modulo(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();
            bin.builder.build_int_unsigned_rem(left, right, "").into()
        }
        Expression::BitwiseOr(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_or(left, right, "").into()
        }
        Expression::BitwiseAnd(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_and(left, right, "").into()
        }
        Expression::BitwiseXor(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_xor(left, right, "").into()
        }
        Expression::ShiftLeft(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_left_shift(left, right, "").into()
        }
        Expression::ShiftRight(_, _, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_right_shift(left, right, false, "").into()
        }
        Expression::Equal(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::EQ, left, right, "")
                .into()
        }
        Expression::NotEqual(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::NE, left, right, "")
                .into()
        }
        Expression::More(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::UGT, left, right, "")
                .into()
        }
        Expression::MoreEqual(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::UGE, left, right, "")
                .into()
        }
        Expression::Less(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::ULT, left, right, "")
                .into()
        }
        Expression::LessEqual(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns).into_int_value();
            let right = expression(r, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::ULE, left, right, "")
                .into()
        }
        Expression::Not(_, expr) => {
            let e = expression(expr, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder
                .build_int_compare(IntPredicate::EQ, e, e.get_type().const_zero(), "")
                .into()
        }
        Expression::Complement(_, _, expr) => {
            let e = expression(expr, bin, func, func_val, var_table, ns).into_int_value();

            bin.builder.build_not(e, "").into()
        }
        Expression::Assign(_, _, l, r) => {
            let right = expression(r, bin, func, func_val, var_table, ns);
            let left = match **l {
                Expression::Variable(_, _, pos) => {
                    let ret = *var_table.get(&pos).unwrap();
                    var_table.insert(pos, right);
                    ret
                }
                _ => unreachable!(),
            };
            bin.builder.build_store(left.into_pointer_value(), right);
            left
        }
        Expression::FunctionCall { .. } => {
            emit_function_call(expr, bin, func, func_val, var_table, ns)
        }

        Expression::Or(_, l, r) => {
            let left = expression(l, bin, func, func_val, var_table, ns);
            let right = expression(r, bin, func, func_val, var_table, ns);
            bin.builder
                .build_or(left.into_int_value(), right.into_int_value(), "")
                .into()
        }

        Expression::NumberLiteral(_, ty, n) => bin.number_literal(ty.bits(ns) as u32, n, ns).into(),

        Expression::Variable(_, _, var_no) => var_table.get(var_no).unwrap().as_basic_value_enum(),
        _ => unreachable!(),
    }
}
//
// fn pre_incdec(
//     vartab: &mut Vartable,
//     ty: &Type,
//     var: &Expression,
//     cfg: &mut ControlFlowGraph,
//     contract_no: usize,
//     func: Option<&Function>,
//     ns: &Namespace,
//     loc: &pt::Loc,
//     expr: &Expression,
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
//         Expression::PreDecrement { .. } => {
//             Expression::Subtract(*loc, ty.clone(), *unchecked, Box::new(v), one)
//         }
//         Expression::PreIncrement { .. } => {
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
//         Expression::Variable(loc, _, pos) => {
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
//     left: &Expression,
//     right: &Expression,
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
    expr: &Expression,
    bin: &Binary<'a>,
    func: Option<&Function>,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let mut ret_value = bin.context.i32_type().const_zero().as_basic_value_enum();
    match expr {
        Expression::FunctionCall { function, args, .. } => {
            if let Expression::Function { function_no, .. } = function.as_ref() {
                let callee = &ns.functions[*function_no];
                if let Some(callee_value) = bin.module.get_function(&callee.name) {
                    let params = args
                        .iter()
                        .map(|a| expression(a, bin, func, func_val, var_table, ns).into())
                        .collect::<Vec<BasicMetadataValueEnum>>();

                    ret_value = bin
                        .builder
                        .build_call(callee_value, &params, "")
                        .try_as_basic_value()
                        .left()
                        .unwrap();
                }
            }
            ret_value
        }
        _ => unreachable!(),
    }
}
