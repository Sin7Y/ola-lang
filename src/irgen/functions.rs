use crate::irgen::binary::Binary;
use crate::irgen::statements::statement;
use crate::sema;
use crate::sema::ast::{Contract, Type};
use crate::sema::ast::{Function, FunctionAttributes, Namespace};
use indexmap::IndexMap;
use inkwell::values::{BasicValueEnum, FunctionValue};
use ola_parser::program;
use ola_parser::program::CodeLocation;
use ola_parser::program::Loc;

// IndexMap <ArrayVariable res , res of temp variable>
pub type ArrayLengthVars<'a> = IndexMap<usize, BasicValueEnum<'a>>;

pub type Vartable<'a> = IndexMap<usize, BasicValueEnum<'a>>;

#[derive(Clone)]
pub struct FunctionContext<'a> {
    // A mapping between the res of an array and the res of the temp var holding its length.
    pub array_lengths_vars: ArrayLengthVars<'a>,
    pub var_table: Vartable<'a>,
    pub func: &'a Function,
    pub func_val: FunctionValue<'a>,
}

impl<'a> FunctionContext<'a> {
    pub fn new(func: &'a Function, func_val: FunctionValue<'a>) -> Self {
        Self {
            array_lengths_vars: IndexMap::new(),
            var_table: IndexMap::new(),
            func,
            func_val,
        }
    }
}

/// Emit all functions, constructors, fallback and receiver
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
        if let Some(func_val) = bin.module.get_function(&func.name) {
            let mut func_context = FunctionContext::new(func, func_val);
            gen_function(bin, &mut func_context, ns);
        }
        if func.returns.is_empty() {
            bin.builder.build_return(None);
        }
    }
}

pub(super) fn gen_function<'a>(
    bin: &mut Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) {
    let bb: inkwell::basic_block::BasicBlock = bin
        .context
        .append_basic_block(func_context.func_val, "entry");

    bin.builder.position_at_end(bb);

    // populate the argument variables
    populate_arguments(bin, func_context, ns);

    for stmt in &func_context.func.body {
        statement(stmt, bin, func_context, ns);
    }
}

/// Populate the arguments of a function
pub(crate) fn populate_arguments<'a>(
    bin: &mut Binary<'a>,
    func_context: &mut FunctionContext<'a>,
    ns: &Namespace,
) {
    for (i, arg) in func_context
        .func
        .get_symbol_table()
        .arguments
        .iter()
        .enumerate()
    {
        if let Some(pos) = arg {
            let var = &func_context.func.get_symbol_table().vars[pos];
            let arg_val = func_context.func_val.get_nth_param(i as u32).unwrap();
            let alloc = bin.build_alloca(
                func_context.func_val,
                bin.llvm_var_ty(&var.ty, ns),
                var.id.name.as_str(),
            );
            bin.builder.build_store(alloc, arg_val);
            func_context.var_table.insert(*pos, alloc.into());
        }
    }
}
