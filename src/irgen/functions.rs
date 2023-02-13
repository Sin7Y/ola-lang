use crate::irgen::binary::Binary;
use crate::irgen::statements::statement;
use crate::sema::ast::Type;
use crate::sema::ast::{Function, FunctionAttributes, Namespace};
use inkwell::values::{BasicValueEnum, FunctionValue};
use std::collections::HashMap;

/// Emit all functions, constructors, fallback and receiver
pub(super) fn gen_functions<'a>(bin: &mut Binary<'a>, ns: &Namespace) {
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
        if let Some(func_val) = bin.module.get_function(&func.name) {
            gen_function(bin, func, func_val, ns);
        }
        if func.returns.is_empty() {
            bin.builder.build_return(None);
        }
    }
}

pub(super) fn gen_function<'a>(
    bin: &mut Binary<'a>,
    func: &Function,
    func_val: FunctionValue<'a>,
    ns: &Namespace,
) {
    // Create all the stack variables
    // let mut vars = HashMap::new();

    // for (no, v) in &cfg.vars {
    //
    //     let ty = bin.llvm_type(&v.ty, ns);
    //     vars.insert(
    //         *no,
    //         Variable {
    //             value: if ty.is_pointer_type() {
    //                 ty.into_pointer_type().const_zero().into()
    //             } else if ty.is_array_type() {
    //                 ty.into_array_type().const_zero().into()
    //             } else if ty.is_int_type() {
    //                 ty.into_int_type().const_zero().into()
    //             } else {
    //                 ty.into_struct_type().const_zero().into()
    //             },
    //         },
    //     );
    // }

    let bb = bin.context.append_basic_block(func_val, "entry");

    bin.builder.position_at_end(bb);

    let mut var_table: HashMap<usize, BasicValueEnum<'a>> = HashMap::new();
    // populate the argument variables
    populate_arguments(func, func_val, &mut var_table);

    for stmt in &func.body {
        statement(stmt, bin, func, func_val, &mut var_table, ns);
    }
}

/// Populate the arguments of a function
pub(crate) fn populate_arguments<'a>(
    func: &Function,
    func_val: FunctionValue<'a>,
    var_table: &mut HashMap<usize, BasicValueEnum<'a>>,
) {
    for (i, arg) in func.get_symbol_table().arguments.iter().enumerate() {
        if let Some(pos) = arg {
            let arg_val = func_val.get_nth_param(i as u32).unwrap();
            // let alloc =
            //     bin.build_alloca(func_val, bin.llvm_var_ty(&var.ty, ns), var.id.name.as_str());
            var_table.insert(*pos, arg_val);
        }
    }
}
