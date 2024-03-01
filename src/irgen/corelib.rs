use crate::irgen::binary::Binary;
use crate::sema::ast::Namespace;
use inkwell::values::{BasicValue, FunctionValue};
use inkwell::{AddressSpace, IntPredicate};
use once_cell::sync::Lazy;

use super::memory::{
    define_field_mem_compare, define_fields_concat, define_heap_malloc, define_mem_compare,
    define_memcpy, define_split_field, define_vector_new,
};
use super::u32_op::{define_u32_div_mod, define_u32_power, define_u32_sqrt};

static PROPHET_FUNCTIONS: Lazy<[&str; 15]> = Lazy::new(|| {
    [
        "prophet_u32_sqrt",
        "prophet_u32_div",
        "prophet_u32_mod",
        "prophet_u32_array_sort",
        "prophet_split_field_high",
        "prophet_split_field_low",
        "get_context_data",
        "get_tape_data",
        "set_tape_data",
        "get_storage",
        "set_storage",
        "poseidon_hash",
        "contract_call",
        "prophet_printf",
        "emit_event",
    ]
});

static BUILTIN_FUNCTIONS: Lazy<[&str; 3]> = Lazy::new(|| {
    [
        "builtin_assert",
        "builtin_range_check",
        "builtin_check_ecdsa",
    ]
});

static CORE_LIB_FUNCTIONS: Lazy<[&str; 16]> = Lazy::new(|| {
    [
        "heap_malloc",
        "vector_new",
        "split_field",
        "memcpy",
        "memcmp_eq",
        "memcmp_ne",
        "memcmp_ugt",
        "memcmp_uge",
        "memcmp_ult",
        "memcmp_ule",
        "field_memcmp_ugt",
        "field_memcmp_uge",
        "field_memcmp_ule",
        "field_memcmp_ult",
        "u32_div_mod",
        "u32_power",
    ]
});

// Generate core lib functions ir
pub fn gen_lib_functions(bin: &mut Binary, ns: &Namespace) {
    declare_builtins(bin);

    declare_prophets(bin);

    define_core_lib(bin);

    // Generate core lib functions
    ns.called_lib_functions.iter().for_each(|p| {
        if bin.module.get_function(p).is_some() {
            return;
        }
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
            "check_ecdsa" => {
                let i64_type = bin.context.i64_type();
                let ptr_type = i64_type.ptr_type(AddressSpace::default());
                let ftype =
                    i64_type.fn_type(&[ptr_type.into(), ptr_type.into(), ptr_type.into()], false);
                let func = bin.module.add_function("check_ecdsa", ftype, None);
                define_check_ecdsa(bin, func);
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
            bin.module.add_function(p, ftype, None);
        }
        "prophet_u32_div" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into(), i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "prophet_u32_mod" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into(), i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "prophet_split_field_low" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "prophet_split_field_high" => {
            let i64_type = bin.context.i64_type();
            let ftype = i64_type.fn_type(&[i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "get_context_data" => {
            // first param is heap address.
            // sencond param is tape index.
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }

        "get_tape_data" => {
            // first param is heap address.
            // sencond param is tape index.
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "set_tape_data" => {
            // first param is heap address.
            // sencond param is data len.
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[ptr_type.into(), i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }

        "prophet_u32_array_sort" => {
            let array_ptr_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let array_length_type = bin.context.i64_type();
            let ftype =
                array_ptr_type.fn_type(&[array_ptr_type.into(), array_length_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "get_storage" => {
            let void_type = bin.context.void_type();
            let param_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[param_type.into(), param_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "set_storage" => {
            let void_type = bin.context.void_type();
            let param_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[param_type.into(), param_type.into()], false);
            bin.module.add_function(p, ftype, None);
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
            bin.module.add_function(p, ftype, None);
        }
        "contract_call" => {
            let void_type = bin.context.void_type();
            let call_type = bin.context.i64_type();
            let address_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[address_type.into(), call_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }

        "prophet_printf" => {
            let void_type = bin.context.void_type();
            let i64_type = bin.context.i64_type();
            let ftype = void_type.fn_type(&[i64_type.into(), i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "emit_event" => {
            let void_type = bin.context.void_type();
            let ptr_type = bin.context.i64_type().ptr_type(AddressSpace::default());
            let ftype = void_type.fn_type(&[ptr_type.into(), ptr_type.into()], false);
            bin.module.add_function(p, ftype, None);
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
            bin.module.add_function(p, ftype, None);
        }
        "builtin_range_check" => {
            let i64_type = bin.context.i64_type();
            let void_type = bin.context.void_type();
            let ftype = void_type.fn_type(&[i64_type.into()], false);
            bin.module.add_function(p, ftype, None);
        }
        "builtin_check_ecdsa" => {
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype = i64_type.fn_type(&[ptr_type.into()], false);
            bin.module.add_function(p, ftype, None);
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
            let func = bin.module.add_function(p, ftype, None);
            define_heap_malloc(bin, func);
        }
        "vector_new" => {
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype = ptr_type.fn_type(&[i64_type.into()], false);
            let func = bin.module.add_function(p, ftype, None);
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

        "split_field" => {
            let i64_type = bin.context.i64_type();
            let void_type = bin.context.void_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype =
                void_type.fn_type(&[i64_type.into(), ptr_type.into(), ptr_type.into()], false);
            let func = bin.module.add_function(p, ftype, None);
            define_split_field(bin, func);
        }
        "memcmp_eq" | "memcmp_ne" | "memcmp_ugt" | "memcmp_uge" | "memcmp_ult" | "memcmp_ule"
        | "field_memcmp_ugt" | "field_memcmp_uge" | "field_memcmp_ult" | "field_memcmp_ule" => {
            let i64_type = bin.context.i64_type();
            let ptr_type = i64_type.ptr_type(AddressSpace::default());
            let ftype =
                i64_type.fn_type(&[ptr_type.into(), ptr_type.into(), i64_type.into()], false);
            let func = bin.module.add_function(p, ftype, None);
            match *p {
                "memcmp_eq" => define_mem_compare(bin, func, IntPredicate::EQ),
                "memcmp_ne" => define_mem_compare(bin, func, IntPredicate::NE),
                "memcmp_ugt" => define_mem_compare(bin, func, IntPredicate::UGT),
                "memcmp_uge" => define_mem_compare(bin, func, IntPredicate::UGE),
                "memcmp_ult" => define_mem_compare(bin, func, IntPredicate::ULT),
                "memcmp_ule" => define_mem_compare(bin, func, IntPredicate::ULE),
                "field_memcmp_ugt" => define_field_mem_compare(bin, func, IntPredicate::UGT),
                "field_memcmp_uge" => define_field_mem_compare(bin, func, IntPredicate::UGE),
                "field_memcmp_ult" => define_field_mem_compare(bin, func, IntPredicate::ULT),
                "field_memcmp_ule" => define_field_mem_compare(bin, func, IntPredicate::ULE),
                _ => unreachable!(),
            };
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

pub fn define_check_ecdsa<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let msg = function.get_nth_param(0).unwrap().into_pointer_value();
    let pubkey = function.get_nth_param(1).unwrap().into_pointer_value();
    let sig = function.get_nth_param(2).unwrap().into_pointer_value();

    let mut dest = bin.heap_malloc(bin.context.i64_type().const_int(20, false));

    let dest_origin = dest.clone();

    bin.memcpy(msg, dest, bin.context.i64_type().const_int(4, false));

    dest = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            dest,
            &[bin.context.i64_type().const_int(4, false)],
            "",
        )
    };

    let pubkey_data = bin.vector_data(pubkey.as_basic_value_enum());
    bin.memcpy(
        pubkey_data,
        dest,
        bin.context.i64_type().const_int(8, false),
    );

    dest = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            dest,
            &[bin.context.i64_type().const_int(8, false)],
            "",
        )
    };

    let sig_data = bin.vector_data(sig.as_basic_value_enum());
    bin.memcpy(sig_data, dest, bin.context.i64_type().const_int(8, false));

    let result = bin
        .builder
        .build_call(
            bin.module.get_function("builtin_check_ecdsa").unwrap(),
            &[dest_origin.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");

    bin.builder.build_return(Some(&result));
}
