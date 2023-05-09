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

static PROPHET_FUNCTIONS: Lazy<[&str; 5]> = Lazy::new(|| {
    [
        "prophet_u32_sqrt",
        "prophet_u32_div",
        "prophet_u32_mod",
        "prophet_u32_array_sort",
        "__malloc",
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
                bin.builder.build_call(
                    bin.module
                        .get_function("builtin_assert")
                        .expect("builtin_assert should have been defined before"),
                    &[root_squared.into(), value],
                    "",
                );
                bin.builder.build_return(Some(&root));
            }
            "u32_array_sort" => {
                // build u32_array_sort function
                let array_ptr_type = bin.context.i64_type().ptr_type(AddressSpace::default());
                let array_length_type = bin.context.i64_type();
                let ftype = array_ptr_type
                    .fn_type(&[array_ptr_type.into(), array_length_type.into()], false);
                let func = bin.module.add_function("u32_array_sort", ftype, None);
                bin.builder
                    .position_at_end(bin.context.append_basic_block(func, "entry"));
                let array_value = func.get_first_param().unwrap().into();
                let array_length = func.get_last_param().unwrap().into();
                let array_sorted = bin
                    .builder
                    .build_call(
                        bin.module
                            .get_function("prophet_u32_array_sort")
                            .expect("prophet_u32_array_sort should have been defined before"),
                        &[array_value, array_length],
                        "",
                    )
                    .try_as_basic_value()
                    .left()
                    .expect("Should have a left return value");
                bin.builder.build_return(Some(&array_sorted));
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
        "__malloc" => {
            let i64_ptr_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = i64_ptr_type.fn_type(&[bin.context.i64_type().into()], false);
            bin.module.add_function("__malloc", ftype, None);
        }
        "prophet_u32_array_sort" => {
            let array_ptr_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let array_length_type = bin.context.i64_type();
            let ftype =
                array_ptr_type.fn_type(&[array_ptr_type.into(), array_length_type.into()], false);
            bin.module
                .add_function("prophet_u32_array_sort", ftype, None);
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
            let ftype = void_type.fn_type(&[i64_type.into(), i64_type.into()], false);
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
