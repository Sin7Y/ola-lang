use crate::irgen::binary::Binary;
use crate::sema::ast::Namespace;
use inkwell::values::{BasicValue, FunctionValue};
use inkwell::{AddressSpace, IntPredicate};
use once_cell::sync::Lazy;

static PROPHET_FUNCTIONS: Lazy<[&str; 12]> = Lazy::new(|| {
    [
        "prophet_u32_sqrt",
        "prophet_u32_div",
        "prophet_u32_mod",
        "prophet_u32_array_sort",
        "get_context_data",
        "get_tape_data",
        "set_tape_data",
        "get_storage",
        "set_storage",
        "poseidon_hash",
        "contract_call",
        "prophet_printf",
    ]
});

static BUILTIN_FUNCTIONS: Lazy<[&str; 2]> = Lazy::new(|| ["builtin_assert", "builtin_range_check"]);

static CORE_LIB_FUNCTIONS: Lazy<[&str; 8]> = Lazy::new(|| {
    [
        "heap_malloc",
        "vector_new",
        "memcpy",
        "memcmp_eq",
        "memcmp_ugt",
        "memcmp_uge",
        "u32_div_mod",
        "u32_power",
    ]
});

// // These functions will be called implicitly by corelib
// // May later become corelib functions open to the user as well
// static IMPLICIT_CALLED_FUNCTIONS: Lazy<[&str; 1]> = Lazy::new(|| ["assert"]);

// Generate core lib functions ir
pub fn gen_lib_functions(bin: &mut Binary, ns: &Namespace) {
    declare_builtins(bin);

    declare_prophets(bin);

    define_core_lib(bin);

    // Generate core lib functions
    ns.called_lib_functions.iter().for_each(|p| {
        match p.as_str() {
            "u32_sqrt" => {
                // build u32_sqrt function
                let i64_type = bin.context.i64_type();
                let ftype = i64_type.fn_type(&[i64_type.into()], false);
                let func = bin.module.add_function("u32_sqrt", ftype, None);
                define_u32_sqrt(bin, func);
            }
            "fields_concat" => {
                let ptr_type = bin.context.i64_type().ptr_type(AddressSpace::default());
                let ftype = ptr_type.fn_type(&[ptr_type.into(), ptr_type.into()], false);
                let func = bin.module.add_function("fields_concat", ftype, None);
                define_fields_concat(bin, func);
            }
            _ => {}
        }
    });
}

// Declare the prophet functions
fn declare_prophets(bin: &mut Binary) {
    PROPHET_FUNCTIONS.iter().for_each(|p| match *p {
        "prophet_u32_sqrt" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into()], false);
            bin.module.add_function("prophet_u32_sqrt", ftype, None);
        }
        "prophet_u32_div" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into(), i64_type.into()], false);
            bin.module.add_function("prophet_u32_div", ftype, None);
        }
        "prophet_u32_mod" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into(), i64_type.into()], false);
            bin.module.add_function("prophet_u32_mod", ftype, None);
        }
        "get_context_data" => {
            // first param is heap address.
            // sencond param is tape index.
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
            bin.module.add_function("get_context_data", ftype, None);
        }

        "get_tape_data" => {
            // first param is heap address.
            // sencond param is tape index.
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
            bin.module.add_function("get_tape_data", ftype, None);
        }
        "set_tape_data" => {
            // first param is heap address.
            // sencond param is data len.
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
            bin.module.add_function("set_tape_data", ftype, None);
        }

        "prophet_u32_array_sort" => {
            let array_ptr_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let array_length_type = bin.context.i64_type();
            let ftype =
                array_ptr_type.fn_type(&[array_ptr_type.into(), array_length_type.into()], false);
            bin.module
                .add_function("prophet_u32_array_sort", ftype, None);
        }
        "get_storage" => {
            let void_type = bin.context.void_type();
            let param_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[param_type.into(), param_type.into()], false);
            bin.module.add_function("get_storage", ftype, None);
        }
        "set_storage" => {
            let void_type = bin.context.void_type();
            let param_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[param_type.into(), param_type.into()], false);
            bin.module.add_function("set_storage", ftype, None);
        }
        // @param input heap address
        // @param output heap address
        // @param input length
        "poseidon_hash" => {
            let void_type = bin.context.void_type();
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype =
                void_type.fn_type(&[ptr_type.into(), ptr_type.into(), i64_type.into()], false);
            bin.module.add_function("poseidon_hash", ftype, None);
        }
        "contract_call" => {
            let void_type = bin.context.void_type();
            let call_type = bin.context.i64_type();
            let address_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[address_type.into(), call_type.into()], false);
            bin.module.add_function("contract_call", ftype, None);
        }

        "prophet_printf" => {
            let void_type = bin.context.void_type();
            let i64_type = bin.context.i64_type();
            let ftype = void_type.fn_type(&[i64_type.into(), i64_type.into()], false);
            bin.module.add_function("prophet_printf", ftype, None);
        }

        _ => {}
    });
}

// Declare the builtin functions without function body
fn declare_builtins(bin: &mut Binary) {
    BUILTIN_FUNCTIONS.iter().for_each(|p| match *p {
        "builtin_assert" => {
            let i64_type = bin.context.i64_type();
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[i64_type.into()], false);
            bin.module.add_function("builtin_assert", ftype, None);
        }
        "builtin_range_check" => {
            let i64_type = bin.context.i64_type();
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[i64_type.into()], false);
            bin.module.add_function("builtin_range_check", ftype, None);
        }
        _ => {}
    });
}

// Declare the builtin functions without function body
fn define_core_lib(bin: &mut Binary) {
    CORE_LIB_FUNCTIONS.iter().for_each(|p| match *p {
        "heap_malloc" => {
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype = ptr_type.fn_type(&[i64_type.into()], false);
            let func = bin.module.add_function("heap_malloc", ftype, None);
            define_heap_malloc(bin, func);
        }
        "vector_new" => {
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype = ptr_type.fn_type(&[i64_type.into()], false);
            let func = bin.module.add_function("vector_new", ftype, None);
            define_vector_new(bin, func);
        }
        "memcpy" => {
            let void_type = bin.context.void_type();
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype =
                void_type.fn_type(&[ptr_type.into(), ptr_type.into(), i64_type.into()], false);
            let func = bin.module.add_function(p, ftype, None);
            define_memcpy(bin, func);
        }
        "memcmp_eq" | "memcmp_ugt" | "memcmp_uge" => {
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype =
                i64_type.fn_type(&[ptr_type.into(), ptr_type.into(), i64_type.into()], false);
            let func = bin.module.add_function(p, ftype, None);
            let op = match *p {
                "memcmp_eq" => IntPredicate::EQ,
                "memcmp_ugt" => IntPredicate::UGT,
                "memcmp_uge" => IntPredicate::UGE,
                _ => unreachable!(),
            };
            define_mem_compare(bin, func, op);
        }
        "u32_div_mod" => {
            let i64_type = bin.context.i64_type();
            let void_type = bin.context.void_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(
                &[
                    i64_type.into(),
                    i64_type.into(),
                    ptr_type.into(),
                    ptr_type.into(),
                ],
                false,
            );
            let func = bin.module.add_function(p, ftype, None);
            define_u32_div_mod(bin, func);
        }
        "u32_power" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into(), i64_type.into()], false);
            let func = bin.module.add_function(p, ftype, None);
            define_u32_power(bin, func);
        }

        _ => {}
    });
}

fn define_u32_sqrt<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let value = function.get_first_param().unwrap().into();
    let root = bin
        .builder
        .build_call(
            bin.module
                .get_function("prophet_u32_sqrt")
                .expect("prophet_u32_sqrt should have been defined before"),
            &[value],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    bin.range_check(root.into_int_value());
    let root_squared = bin
        .builder
        .build_int_mul(root.into_int_value(), root.into_int_value(), "");
    let equal = bin.builder.build_int_compare(
        inkwell::IntPredicate::EQ,
        root_squared,
        value.into_int_value(),
        "",
    );
    bin.builder.build_call(
        bin.module.get_function("builtin_assert").unwrap(),
        &[bin
            .builder
            .build_int_z_extend(equal, bin.context.i64_type(), "")
            .into()],
        "",
    );
    bin.builder.build_return(Some(&root));
}

fn define_fields_concat<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let left_value = function.get_nth_param(0).unwrap().into();
    let right_value = function.get_nth_param(1).unwrap().into();
    let left_len = bin.vector_len(left_value);
    let left_data = bin.vector_data(right_value);
    let right_len = bin.vector_len(left_value);
    let right_data = bin.vector_data(right_value);
    let new_len = bin.builder.build_int_add(left_len, right_len, "new_len");
    let dest_fields = bin.vector_new(new_len);

    let mut new_fields_data = bin.vector_data(dest_fields.as_basic_value_enum());

    bin.memcpy(left_data, new_fields_data, left_len);

    new_fields_data = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            new_fields_data,
            &[left_len],
            "new_fields_data",
        )
    };

    bin.memcpy(right_data, new_fields_data, right_len);
    bin.builder.build_return(Some(&dest_fields));
}

fn define_heap_malloc<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let size = function.get_first_param().unwrap();
    let size_alloca = bin.build_alloca(function, size.get_type(), "size_alloca");
    bin.builder.build_store(size_alloca, size);
    let size = bin
        .builder
        .build_load(bin.context.i64_type(), size_alloca, "size")
        .into_int_value();
    let current_heap_address = bin
        .builder
        .build_load(
            bin.context.i64_type(),
            bin.heap_address.as_pointer_value(),
            "current_address",
        )
        .into_int_value();
    let updated_address = bin
        .builder
        .build_int_add(current_heap_address, size, "updated_address");

    bin.builder
        .build_store(bin.heap_address.as_pointer_value(), updated_address);

    let current_heap_address = bin.builder.build_int_to_ptr(
        current_heap_address,
        bin.context.i64_type().ptr_type(AddressSpace::default()),
        "",
    );

    bin.builder.build_return(Some(&current_heap_address));
}

fn define_vector_new<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let size = function.get_first_param().unwrap();
    let size_alloca = bin.build_alloca(function, size.get_type(), "size_alloca");
    bin.builder.build_store(size_alloca, size);
    let size = bin
        .builder
        .build_load(bin.context.i64_type(), size_alloca, "size")
        .into_int_value();
    let size_add_one =
        bin.builder
            .build_int_add(size, bin.context.i64_type().const_int(1, false), "");
    let current_heap_address = bin
        .builder
        .build_load(
            bin.context.i64_type(),
            bin.heap_address.as_pointer_value(),
            "current_address",
        )
        .into_int_value();

    let updated_address =
        bin.builder
            .build_int_add(current_heap_address, size_add_one, "updated_address");

    bin.builder
        .build_store(bin.heap_address.as_pointer_value(), updated_address);

    let current_heap_address = bin.builder.build_int_to_ptr(
        current_heap_address,
        bin.context.i64_type().ptr_type(AddressSpace::default()),
        "",
    );
    bin.builder.build_store(current_heap_address, size);

    bin.builder.build_return(Some(&current_heap_address));
}

fn define_memcpy<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let src_ptr = function.get_nth_param(0).unwrap();
    let src_ptr_alloca = bin.build_alloca(function, src_ptr.get_type(), "src_ptr_alloca");
    bin.builder.build_store(src_ptr_alloca, src_ptr);
    let src_ptr = bin
        .builder
        .build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            src_ptr_alloca,
            "src_ptr",
        )
        .into_pointer_value();

    let dest_ptr = function.get_nth_param(1).unwrap();

    let dest_ptr_alloca = bin.build_alloca(function, dest_ptr.get_type(), "dest_ptr_alloca");
    bin.builder.build_store(dest_ptr_alloca, dest_ptr);
    let dest_ptr = bin
        .builder
        .build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            dest_ptr_alloca,
            "dest_ptr",
        )
        .into_pointer_value();

    let len = function.get_nth_param(2).unwrap();
    let len_alloca = bin.build_alloca(function, len.get_type(), "len_alloca");
    bin.builder.build_store(len_alloca, len);
    let len = bin
        .builder
        .build_load(bin.context.i64_type(), len_alloca, "len")
        .into_int_value();

    let cond = bin.context.append_basic_block(function, "cond");
    let body = bin.context.append_basic_block(function, "body");
    let done = bin.context.append_basic_block(function, "done");

    let loop_ty = bin.context.i64_type();
    // create an alloca for the loop variable
    let index_alloca = bin.build_alloca(function, loop_ty, "index_alloca");
    // initialize the loop variable with the starting value
    bin.builder.build_store(index_alloca, loop_ty.const_zero());

    bin.builder.build_unconditional_branch(cond);
    bin.builder.position_at_end(cond);

    // load current value of the loop variable
    let index_value = bin
        .builder
        .build_load(loop_ty, index_alloca, "index_value")
        .into_int_value();

    let comp = bin
        .builder
        .build_int_compare(IntPredicate::ULT, index_value, len, "loop_cond");
    bin.builder.build_conditional_branch(comp, body, done);

    // memory copy start
    bin.builder.position_at_end(body);

    let src_access = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            src_ptr,
            &[index_value],
            "src_index_access",
        )
    };

    let src_value = bin
        .builder
        .build_load(bin.context.i64_type(), src_access, "");

    let dest_access = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            dest_ptr,
            &[index_value],
            "dest_index_access",
        )
    };

    bin.builder.build_store(dest_access, src_value);

    // memory copy end
    let next_index =
        bin.builder
            .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");

    // store the incremented value back
    bin.builder.build_store(index_alloca, next_index);

    bin.builder.build_unconditional_branch(cond);

    bin.builder.position_at_end(done);
    bin.builder.build_return(None);
}

fn define_mem_compare<'a>(bin: &Binary<'a>, function: FunctionValue<'a>, op: IntPredicate) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let left_ptr = function.get_nth_param(0).unwrap();
    let left_ptr_alloca = bin.build_alloca(function, left_ptr.get_type(), "left_ptr_alloca");
    bin.builder.build_store(left_ptr_alloca, left_ptr);
    let left_ptr = bin
        .builder
        .build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            left_ptr_alloca,
            "left_ptr",
        )
        .into_pointer_value();

    let right_ptr = function.get_nth_param(1).unwrap();

    let right_ptr_alloca = bin.build_alloca(function, right_ptr.get_type(), "right_ptr_alloca");
    bin.builder.build_store(right_ptr_alloca, right_ptr);
    let right_ptr = bin
        .builder
        .build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            right_ptr_alloca,
            "right_ptr",
        )
        .into_pointer_value();

    let len = function.get_nth_param(2).unwrap();
    let len_alloca = bin.build_alloca(function, len.get_type(), "len_alloca");
    bin.builder.build_store(len_alloca, len);
    let len = bin
        .builder
        .build_load(bin.context.i64_type(), len_alloca, "len")
        .into_int_value();

    let loop_ty = bin.context.i64_type();
    let index_alloca = bin.build_alloca(function, loop_ty, "index_alloca");
    bin.builder.build_store(index_alloca, loop_ty.const_zero());

    let cond = bin.context.append_basic_block(function, "cond");
    bin.builder.build_unconditional_branch(cond);
    bin.builder.position_at_end(cond);

    let index_value = bin
        .builder
        .build_load(loop_ty, index_alloca, "index_value")
        .into_int_value();
    let loop_check =
        bin.builder
            .build_int_compare(IntPredicate::ULT, index_value, len, "loop_check");
    let body = bin.context.append_basic_block(function, "body");
    let done = bin.context.append_basic_block(function, "done");
    bin.builder.build_conditional_branch(loop_check, body, done);

    bin.builder.position_at_end(body);
    let left_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            left_ptr,
            &[index_value],
            "left_elem_ptr",
        )
    };
    let left_elem = bin
        .builder
        .build_load(bin.context.i64_type(), left_elem_ptr, "left_elem")
        .into_int_value();
    let right_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            right_ptr,
            &[index_value],
            "right_elem_ptr",
        )
    };
    let right_elem = bin
        .builder
        .build_load(bin.context.i64_type(), right_elem_ptr, "right_elem")
        .into_int_value();
    let compare = bin
        .builder
        .build_int_compare(op, left_elem, right_elem, "compare");

    let next_index =
        bin.builder
            .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");
    bin.builder.build_store(index_alloca, next_index);

    bin.builder.build_conditional_branch(compare, cond, done);

    bin.builder.position_at_end(done);
    let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
    phi_node.add_incoming(&[
        (&bin.context.i64_type().const_int(1, false), cond),
        (&bin.context.i64_type().const_zero(), body),
    ]);
    bin.builder.build_return(Some(&phi_node.as_basic_value()));
}

fn define_u32_div_mod<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let dividend = function.get_nth_param(0).unwrap();
    let divisor = function.get_nth_param(1).unwrap();
    let quotient = function.get_nth_param(2).unwrap();
    let remainder = function.get_nth_param(3).unwrap();
    let dividend_alloca = bin.build_alloca(function, dividend.get_type(), "dividend_alloca");
    bin.builder.build_store(dividend_alloca, dividend);
    let dividend = bin
        .builder
        .build_load(bin.context.i64_type(), dividend_alloca, "dividend");

    let divisor_alloca = bin.build_alloca(function, divisor.get_type(), "divisor_alloca");
    bin.builder.build_store(divisor_alloca, divisor);
    let divisor = bin
        .builder
        .build_load(bin.context.i64_type(), divisor_alloca, "divisor");
    let quotient_alloca = bin.build_alloca(function, quotient.get_type(), "quotient_alloca");
    bin.builder.build_store(quotient_alloca, quotient);
    let quotient = bin
        .builder
        .build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            quotient_alloca,
            "quotient",
        )
        .into_pointer_value();
    let remainder_alloca = bin.build_alloca(function, remainder.get_type(), "remainder_alloca");
    bin.builder.build_store(remainder_alloca, remainder);
    let remainder = bin
        .builder
        .build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            remainder_alloca,
            "remainder",
        )
        .into_pointer_value();

    let remainder_ret = bin
        .builder
        .build_call(
            bin.module.get_function("prophet_u32_mod").unwrap(),
            &[dividend.into(), divisor.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // remainder should be in the u32 range
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[remainder_ret.into()],
        "",
    );

    // 0 <= right - (remainder + 1)
    let one = bin.context.i64_type().const_int(1, false);
    let right_minus_remainder_minus_one = bin.builder.build_int_sub(
        divisor.into_int_value(),
        bin.builder
            .build_int_add(remainder_ret.into_int_value(), one, ""),
        "",
    );
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[right_minus_remainder_minus_one.into()],
        "",
    );

    let quotient_ret = bin
        .builder
        .build_call(
            bin.module.get_function("prophet_u32_div").unwrap(),
            &[dividend.into(), divisor.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    // quotient should be in the u32 range
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[quotient.into()],
        "",
    );

    // assert that quotient * right + remainder == left
    let quotient_mul_right_plus_remainder = bin.builder.build_int_add(
        bin.builder
            .build_int_mul(quotient_ret.into_int_value(), divisor.into_int_value(), ""),
        remainder_ret.into_int_value(),
        "",
    );

    let equal = bin.builder.build_int_compare(
        IntPredicate::EQ,
        quotient_mul_right_plus_remainder,
        dividend.into_int_value(),
        "",
    );

    bin.builder.build_call(
        bin.module.get_function("builtin_assert").unwrap(),
        &[bin
            .builder
            .build_int_z_extend(equal, bin.context.i64_type(), "")
            .into()],
        "",
    );
    bin.builder.build_store(quotient, quotient_ret);
    bin.builder.build_store(remainder, remainder_ret);
    bin.builder.build_return(None);
}

fn define_u32_power<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let loop_block = bin.context.append_basic_block(function, "loop");
    let exit_block = bin.context.append_basic_block(function, "exit");
    let base = function.get_nth_param(0).unwrap();
    let exponent = function.get_nth_param(1).unwrap();
    let i64_type = bin.context.i64_type();

    let base_alloca = bin.build_alloca(function, base.get_type(), "base_alloca");
    let exponent_alloca = bin.build_alloca(function, exponent.get_type(), "exponent_alloca");

    bin.builder.build_store(base_alloca, base);
    let base = bin
        .builder
        .build_load(bin.context.i64_type(), base_alloca, "base")
        .into_int_value();

    bin.builder.build_store(exponent_alloca, exponent);
    let exponent = bin
        .builder
        .build_load(bin.context.i64_type(), exponent_alloca, "exponent")
        .into_int_value();

    bin.builder.build_unconditional_branch(loop_block);
    bin.builder.position_at_end(loop_block);

    let counter_phi = bin.builder.build_phi(i64_type, "");
    counter_phi.add_incoming(&[(
        &i64_type.const_zero(),
        function.get_first_basic_block().unwrap(),
    )]);

    let result_phi = bin.builder.build_phi(i64_type, "");
    result_phi.add_incoming(&[(
        &i64_type.const_int(1, false),
        function.get_first_basic_block().unwrap(),
    )]);

    let counter_val = counter_phi.as_basic_value().into_int_value();
    let result_val = result_phi.as_basic_value().into_int_value();

    let new_counter = bin
        .builder
        .build_int_add(counter_val, i64_type.const_int(1, false), "inc");
    let new_result = bin.builder.build_int_mul(result_val, base, "multmp");

    let cond = bin.builder.build_int_compare(
        inkwell::IntPredicate::ULE,
        new_counter,
        exponent,
        "loopcond",
    );
    bin.builder
        .build_conditional_branch(cond, loop_block, exit_block);

    counter_phi.add_incoming(&[(&new_counter, loop_block)]);
    result_phi.add_incoming(&[(&new_result, loop_block)]);

    bin.builder.position_at_end(exit_block);
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[result_phi.as_basic_value().into()],
        "",
    );

    bin.builder.build_return(Some(&result_phi.as_basic_value()));
}
