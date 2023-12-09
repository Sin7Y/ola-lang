use crate::irgen::binary::Binary;
use crate::irgen::statements::statement;
use crate::sema;
use crate::sema::ast::{Function, FunctionAttributes, Namespace};
use crate::sema::ast::{Statement, Type};
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
        statement(stmt, bin, func_value, func, var_table, ns);

        if !stmt.reachable() {
            break;
        }
    }

    if func.body.last().map(Statement::reachable).unwrap_or(true) {
        // return
        // add implicit return
        func.symtable.returns.iter().for_each(|pos| {
            let ret = var_table.get(pos).unwrap();
            let ty = func.symtable.vars[pos].ty.clone();
            let ret =
                bin.builder
                    .build_load(bin.llvm_var_ty(&ty, ns), ret.into_pointer_value(), "");
            bin.builder.build_return(Some(&ret));
        });
    }
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
            let alloc = bin.build_alloca(
                func_value,
                bin.llvm_var_ty(&var.ty, ns),
                var.id.name.as_str(),
            );
            bin.builder.build_store(alloc, arg_val);
            let value = if var.ty.is_reference_type(ns) {
                bin.builder
                    .build_load(bin.llvm_var_ty(&var.ty, ns), alloc, "")
            } else {
                alloc.into()
            };
            var_table.insert(*pos, value.into());
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
