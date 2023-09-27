use crate::irgen::binary::Binary;
use crate::sema::ast::Namespace;
use inkwell::AddressSpace;
use once_cell::sync::Lazy;

// const EPSILON: u64 = (1 << 32) - 1;
//
// /// A field selected to have fast reduction.
// ///
// /// Its order is 2^64 - 2^32 + 1.
// /// P = 2**64 - EPSILON
// ///   = 2**64 - 2**32 + 1
// ///   = 2**32 * (2**32 - 1) + 1
// ///
// pub const ORDER: u64 = 0xFFFFFFFF00000001;

static PROPHET_FUNCTIONS: Lazy<[&str; 12]> = Lazy::new(|| {
    [
        "prophet_u32_sqrt",
        "prophet_u32_div",
        "prophet_u32_mod",
        "prophet_u32_array_sort",
        "vector_new",
        "get_context_data",
        "get_tape_data",
        "set_tape_data",
        "get_storage",
        "set_storage",
        "poseidon_hash",
        "contract_call"
    ]
});

static BUILTIN_FUNCTIONS: Lazy<[&str; 2]> = Lazy::new(|| ["builtin_assert", "builtin_range_check"]);

// // These functions will be called implicitly by corelib
// // May later become corelib functions open to the user as well
// static IMPLICIT_CALLED_FUNCTIONS: Lazy<[&str; 1]> = Lazy::new(|| ["assert"]);

// Generate core lib functions ir
pub fn gen_lib_functions(bin: &mut Binary, ns: &Namespace) {
    declare_builtins(bin);

    declare_prophets(bin);

    // Generate core lib functions
    ns.called_lib_functions.iter().for_each(|p| {
        match p.as_str() {
            "u32_sqrt" => {
                // build u32_sqrt function
                let i64_type = bin.context.i64_type();
                let ftype = i64_type.fn_type(&[i64_type.into()], false);
                let func = bin.module.add_function("u32_sqrt", ftype, None);
                bin.builder
                    .position_at_end(bin.context.append_basic_block(func, "entry"));
                let value = func.get_first_param().unwrap().into();
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
                bin.builder.build_call(
                    bin.module
                        .get_function("builtin_range_check")
                        .expect("builtin_range_check should have been defined before"),
                    &[root.into()],
                    "",
                );
                let root_squared =
                    bin.builder
                        .build_int_mul(root.into_int_value(), root.into_int_value(), "");
                let equal = bin.builder.build_int_compare(
                    inkwell::IntPredicate::EQ,
                    root_squared,
                    value.into_int_value(),
                    "",
                );
                bin.builder.build_call(
                    bin.module
                        .get_function("builtin_assert")
                        .expect("builtin_assert should have been defined before"),
                    &[bin
                        .builder
                        .build_int_z_extend(equal, bin.context.i64_type(), "")
                        .into()],
                    "",
                );
                bin.builder.build_return(Some(&root));
            }
            _ => {}
        }
    });
}

// Declare the prophet functions
pub fn declare_prophets(bin: &mut Binary) {
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
        "vector_new" => {
            let ftype = bin
                .context
                .i64_type()
                .fn_type(&[bin.context.i64_type().into()], false);
            bin.module.add_function("vector_new", ftype, None);
        }

        "get_context_data" => {
            // first param is heap address.
            // sencond param is tape index.
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[bin.context.i64_type().into(), bin.context.i64_type().into()], false);
            bin.module.add_function("get_context_data", ftype, None);
        }

        "get_tape_data" => {
            // first param is heap address.
            // sencond param is tape index.
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[bin.context.i64_type().into(), bin.context.i64_type().into()], false);
            bin.module.add_function("get_tape_data", ftype, None);
        }
        "set_tape_data" => {
            // first param is heap address.
            // sencond param is data len.
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[bin.context.i64_type().into(), bin.context.i64_type().into()], false);
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
            let ftype = void_type.fn_type(&[ptr_type.into(), ptr_type.into(), i64_type.into()], false);
            bin.module.add_function("poseidon_hash", ftype, None);
        }
        "contract_call" => {
            let void_type = bin.context.void_type();
            let call_type = bin.context.i64_type();
            let address_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[address_type.into(), call_type.into()], false);
            bin.module.add_function("contract_call", ftype, None);
        }

        _ => {}
    });
}

// Declare the builtin functions without function body
pub fn declare_builtins(bin: &mut Binary) {
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
