use inkwell::{
    basic_block::BasicBlock,
    values::{BasicMetadataValueEnum, BasicValueEnum, FunctionValue, IntValue},
};
use num_bigint::{BigInt, Sign};
use num_traits::ToPrimitive;

use crate::sema::ast::{Namespace, Type};

use super::{
    binary::Binary,
    encoding::{abi_decode, abi_encode},
};

fn public_function_prelude<'a>(
    binary: &Binary<'a>,
    function: FunctionValue,
) -> (IntValue<'a>, IntValue<'a>, IntValue<'a>) {
    let entry = binary.context.append_basic_block(function, "entry");

    binary.builder.position_at_end(entry);

    let input = binary
        .builder
        .build_call(
            binary.module.get_function("contract_input").unwrap(),
            &[],
            "",
        )
        .try_as_basic_value()
        .left()
        .unwrap();

    binary.contract_input(input)
}

/// Emits the "deploy" function if `init` is `Some`, otherwise emits the "call"
/// function.
pub fn gen_contract_entrance(init: Option<FunctionValue>, bin: &mut Binary) {
    let ty = bin.context.void_type().fn_type(&[], false);
    let name = if init.is_some() { "deploy" } else { "call" };
    let func = bin.module.add_function(name, ty, None);
    let (selector, input_length, input) = public_function_prelude(bin, func);
    if let Some(initializer) = init {
        bin.builder.build_call(initializer, &[], "");
    }
    let function_dispatch = bin.module.get_function("function_dispatch").unwrap();
    let args = vec![
        BasicMetadataValueEnum::IntValue(selector),
        BasicMetadataValueEnum::IntValue(input_length),
        BasicMetadataValueEnum::IntValue(input),
    ];
    bin.builder
        .build_call(function_dispatch, &args, "function_dispatch");
    bin.builder.build_unreachable();
}

/// Emits the "function_dispatch" function.
/// This function is called by the "deploy" and "call" functions.
/// It dispatches the call to the appropriate function.
/// It is called with the following arguments:
/// - selector: the first 4 bytes of the input data
/// - input_length: the length of the input data
/// - input: a pointer to the input data
/// It returns the following values:

pub fn gen_func_dispatch(bin: &mut Binary, ns: &Namespace) {
    let ty = bin.context.void_type().fn_type(
        &[
            bin.context.i64_type().into(),
            bin.context.i64_type().into(),
            bin.context.i64_type().into(),
        ],
        false,
    );
    let func_value = bin.module.add_function("function_dispatch", ty, None);
    let entry = bin.context.append_basic_block(func_value, "entry");

    let selector = func_value.get_nth_param(0).unwrap().into_int_value();
    let input_length = func_value.get_nth_param(1).unwrap().into_int_value();
    let input = func_value.get_nth_param(2).unwrap().into_int_value();

    bin.builder.position_at_end(entry);

    let default_case = bin
        .context
        .append_basic_block(func_value, "missing_function");

    let selector_cases = ns
        .functions
        .iter()
        .enumerate()
        .filter_map(|(func_no, func)| {
            let selector = BigInt::from_bytes_le(Sign::Plus, &func.selector());
            let case = bin
                .context
                .i64_type()
                .const_int(selector.to_u64().unwrap(), false);
            Some((
                case,
                dispatch_case(input_length, input, func_no, bin, func_value, ns),
            ))
        })
        .collect::<Vec<(IntValue, inkwell::basic_block::BasicBlock)>>();
    bin.builder.position_at_end(entry);
    bin.builder
        .build_switch(selector, default_case, selector_cases.as_ref());

    bin.builder.position_at_end(default_case);
    bin.builder.build_unreachable();

    // build switch statement
}

/// Insert the dispatch logic for `func_no`. `func_no` may be a function or
/// constructor. Returns the basic block number in which the dispatch logic
/// inserted.
fn dispatch_case<'a>(
    input_length: IntValue<'a>,
    input: IntValue<'a>,
    func_no: usize,
    bin: &mut Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicBlock<'a> {
    let case_bb = bin
        .context
        .append_basic_block(func_value, &format!("func_{func_no}_dispatch"));
    bin.builder.position_at_end(case_bb);
    let mut args = vec![];
    // Decode input data if necessary
    let func = &ns.functions[func_no];
    if !func.params.is_empty() {
        args = abi_decode(
            bin,
            input_length,
            input,
            &func.params.iter().map(|p| p.ty.clone()).collect::<Vec<_>>(),
            func_value,
            ns,
        );
    }

    let mut return_tys: Vec<Type> = Vec::with_capacity(func.returns.len());
    let mut returns: Vec<BasicValueEnum> = Vec::with_capacity(func.returns.len());

    for item in func.returns.iter() {
        return_tys.push(item.ty.clone());
    }

    // build call function
    let callee = &ns.functions[func_no];
    let callee_value = bin.module.get_function(&callee.name).unwrap();
    let ret = bin
        .builder
        .build_call(
            callee_value,
            &args
                .iter()
                .map(|arg| (*arg).into())
                .collect::<Vec<BasicMetadataValueEnum>>(),
            "",
        )
        .try_as_basic_value()
        .left();
    if !func.returns.is_empty() {
        returns.push(ret.unwrap());
        abi_encode(bin, returns, &return_tys, func_value, ns);
    }
    bin.builder.build_return(None);

    case_bb
}