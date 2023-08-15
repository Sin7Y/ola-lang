use crate::irgen::binary::Binary;
use crate::irgen::statements::statement;
use crate::sema;
use crate::sema::ast::Type;
use crate::sema::ast::{Function, FunctionAttributes, Namespace};
use indexmap::IndexMap;
use inkwell::values::{BasicValueEnum, FunctionValue};

pub type Vartable<'a> = IndexMap<usize, BasicValueEnum<'a>>;

/// Emit all functions
pub(super) fn gen_functions<'a>(bin: &mut Binary<'a>, ns: &'a sema::ast::Namespace) {
    // gen function prototype
    for (_, func) in ns.functions.iter().enumerate() {
        let ftype = bin.function_type(
            &func
                .params
                .iter()
                .map(|p| p.ty.clone())
                .collect::<Vec<Type>>(),
            &func
                .returns
                .iter()
                .map(|p| p.ty.clone())
                .collect::<Vec<Type>>(),
            ns,
        );

        if let Some(func) = bin.module.get_function(&func.name) {
            // must not have a body yet
            assert_eq!(func.get_first_basic_block(), None);
            func
        } else {
            bin.module.add_function(&func.name, ftype, None)
        };
    }

    // gen function definition
    for (_, func) in ns.functions.iter().enumerate() {
        if let Some(func_value) = bin.module.get_function(&func.name) {
            let mut var_table: Vartable = IndexMap::new();
            gen_function(bin, func_value, func, &mut var_table, ns);
        }
        if func.returns.is_empty() {
            bin.builder.build_return(None);
        }
    }
}

pub(super) fn gen_function<'a>(
    bin: &mut Binary<'a>,
    func_value: FunctionValue<'a>,
    func: &Function,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    let bb: inkwell::basic_block::BasicBlock = bin.context.append_basic_block(func_value, "entry");

    bin.builder.position_at_end(bb);

    // populate the argument variables
    populate_arguments(bin, func_value, func, var_table, ns);

    // named returns should be populated
    populate_named_returns(bin, func_value, func, var_table, ns);

    for stmt in &func.body {
        statement(stmt, bin, func_value, var_table, ns);
    }

    // if func_context
    //     .func
    //     .body
    //     .last()
    //     .map(|stmt| stmt.reachable())
    //     .unwrap_or(true)
    // {
    //     // TODO When multiple values are returned, they need to be converted
    // into struct     // for processing.
    //     if func_context.func.returns.len() != 0 {
    //         let pos = func_context.func.symtable.returns[0];
    //         let ret_expr = Expression::Variable {
    //             loc: program::Loc::IRgen,
    //             ty: func_context.func.symtable.vars[pos].ty.clone(),
    //             var_no: pos,
    //         };
    //         let ret_value = expression(&ret_expr, bin, func_context, ns);
    //         bin.builder.build_return(Some(&ret_value));
    //     }
    // }
}

/// Populate the arguments of a function
pub(crate) fn populate_arguments<'a>(
    bin: &mut Binary<'a>,
    func_value: FunctionValue<'a>,
    func: &Function,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    for (i, arg) in func.get_symbol_table().arguments.iter().enumerate() {
        if let Some(pos) = arg {
            let var = &func.get_symbol_table().vars[pos];
            let arg_val = func_value.get_nth_param(i as u32).unwrap();
            if var.ty.is_reference_type(ns) {
                // reference types are passed as pointers
                var_table.insert(*pos, arg_val.into());
                continue;
            }
            let alloc = bin.build_alloca(
                func_value,
                bin.llvm_var_ty(&var.ty, ns),
                var.id.name.as_str(),
            );
            bin.builder.build_store(alloc, arg_val);
            var_table.insert(*pos, alloc.into());
        }
    }
}

/// Populate the arguments of a function
pub(crate) fn populate_named_returns<'a>(
    bin: &mut Binary<'a>,
    func_value: FunctionValue<'a>,
    func: &Function,
    var_table: &mut Vartable<'a>,
    ns: &Namespace,
) {
    for (i, pos) in func.get_symbol_table().returns.iter().enumerate() {
        if let Some(name) = &func.get_returns()[i].id {
            let return_var = &func.get_returns()[i];
            if let Some(default_value) = return_var.ty.default(bin, func_value, ns) {
                let alloc = bin.build_alloca(
                    func_value,
                    bin.llvm_var_ty(&return_var.ty, ns),
                    name.name.as_str(),
                );
                bin.builder.build_store(alloc, default_value);
                var_table.insert(*pos, alloc.into());
            }
        }
    }
}
