use inkwell::{
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    AddressSpace,
};

use num_traits::ToPrimitive;

use crate::{
    irgen::binary::Binary,
    sema::ast::{ArrayLength, Namespace, Type},
};

use super::{allow_memcpy, finish_array_loop, get_args_type_size, index_array, set_array_loop};

/// Read a value of type 'ty' from the buffer at a given offset. Returns an
/// expression containing the read value and the number of bytes read.
pub(crate) fn read_from_buffer<'a>(
    buffer: PointerValue<'a>,
    bin: &Binary<'a>,
    ty: &Type,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    match ty {
        Type::Uint(32) | Type::Bool | Type::Enum(_) | Type::Field => {
            let size = get_args_type_size(bin, None, ty, func_value, ns);
            let decode_value = bin.builder.build_load(bin.context.i64_type(), buffer, "");
            (decode_value, size)
        }

        Type::Address | Type::Contract(_) | Type::Hash => {
            let size = get_args_type_size(bin, None, ty, func_value, ns);
            (buffer.into(), size)
        }

        Type::Uint(256) => {
            let size = get_args_type_size(bin, None, ty, func_value, ns);
            (buffer.into(), size)
        }

        Type::String | Type::DynamicBytes => {
            // String and Dynamic bytes are encoded as size + elements.length
            let total_size = get_args_type_size(bin, Some(buffer.into()), ty, func_value, ns);

            (buffer.into(), total_size)
        }

        Type::UserType(type_no) => {
            let usr_type = ns.user_types[*type_no].ty.clone();
            read_from_buffer(buffer, bin, &usr_type, func_value, ns)
        }

        Type::Array(elem_ty, dims) => {
            decode_array(buffer.into(), ty, elem_ty, bin, &dims, func_value, ns)
        }

        Type::Slice(elem_ty) => {
            let dims = vec![ArrayLength::Dynamic];
            decode_array(buffer, ty, elem_ty, bin, &dims, func_value, ns)
        }

        Type::Struct(no) => decode_struct(buffer.clone(), ty, *no, bin, func_value, ns),

        _ => unreachable!("read_from_buffer: {:?}", ty),
    }
}

fn decode_array<'a>(
    buffer: PointerValue<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    bin: &Binary<'a>,
    dims: &[ArrayLength],
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    if allow_memcpy(array_ty, ns) {
        let size = get_args_type_size(bin, Some(buffer.into()), array_ty, func_value, ns);
        (buffer.into(), size)
    } else {
        let mut indexes: Vec<PointerValue> = Vec::new();
        let offset_var = bin.build_alloca(func_value, bin.context.i64_type(), "offset_var");
        bin.builder
            .build_store(offset_var, bin.context.i64_type().const_zero());
        let array_var = bin.build_alloca(
            func_value,
            bin.context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .ptr_type(AddressSpace::default()),
            "array_ptr",
        );
        // The function decode_complex_array assumes that, if the dimension is fixed,
        // there is no need to allocate an array
        // if matches!(dims.last(), Some(ArrayLength::Fixed(_))) {
        //     let array_literal = bin.heap_malloc(bin.context.i64_type().const_zero());
        //     bin.builder.build_store(array_var, array_literal);
        // }
        decode_complex_array(
            bin,
            buffer,
            array_var,
            array_ty,
            elem_ty,
            offset_var,
            dims,
            dims.len() - 1,
            func_value,
            ns,
            &mut indexes,
        );
        (
            bin.builder
                .build_load(bin.llvm_var_ty(array_ty, ns), array_var, ""),
            bin.builder
                .build_load(bin.context.i64_type(), offset_var, "")
                .into_int_value(),
        )
    }
}

fn decode_struct<'a>(
    buffer: PointerValue<'a>,
    ty: &Type,
    struct_no: usize,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    let struct_tys = ns.structs[struct_no]
        .fields
        .iter()
        .map(|item| item.ty.clone())
        .collect::<Vec<Type>>();

    let qty = ns.structs[struct_no].fields.len();

    let mut read_items: Vec<BasicValueEnum<'_>> = vec![];

    let mut struct_offset = bin.context.i64_type().const_zero();
    for i in 0..qty {
        let struct_field = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                buffer,
                &[struct_offset],
                "decode_struct_field",
            )
        };
        let (read_expr, advance) =
            read_from_buffer(struct_field, bin, &struct_tys[i], func_value, ns);
        read_items.push(read_expr);
        struct_offset = bin
            .builder
            .build_int_add(struct_offset, advance, "decode_struct_offset");
    }

    let struct_var = struct_literal_copy(ty, read_items, bin, ns);
    (struct_var, struct_offset)
}

pub fn struct_literal_copy<'a>(
    ty: &Type,
    values: Vec<BasicValueEnum<'a>>,
    bin: &Binary<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let struct_ty = bin.llvm_type(ty, ns);

    let struct_size = bin
        .context
        .i64_type()
        .const_int(ty.type_size_of(ns).to_u64().unwrap(), false);

    let struct_alloca = bin.heap_malloc(struct_size);

    for (i, elem) in values.iter().enumerate() {
        let elemptr = bin
            .builder
            .build_struct_gep(struct_ty, struct_alloca, i as u32, "struct_member")
            .unwrap();
        bin.builder.build_store(elemptr, *elem);
    }

    struct_alloca.into()
}

// /// Decodes a complex array from a encoded buffer
// /// Complex arrays are either dynamic arrays or arrays of dynamic types, like
// /// structs. If this is an array of structs, whose representation in memory
// is /// padded, the array is also complex, because it cannot be memcpy'ed
// fn decode_complex_array<'a>(
//     bin: &Binary<'a>,
//     buffer: PointerValue<'a>,
//     array_var: PointerValue<'a>,
//     array_ty: &Type,
//     elem_ty: &Type,
//     offset_var: PointerValue<'a>,
//     dims: &[ArrayLength],
//     dimension: usize,
//     func_value: FunctionValue<'a>,
//     ns: &Namespace,
//     indexes: &mut Vec<PointerValue<'a>>,
// ) { let offset = bin .builder .build_load(bin.context.i64_type(), offset_var,
//   "") .into_int_value(); // If we have a 'int[3][4][] vec', we can only
//   validate the buffer afte we have // allocated the outer dimension, i.e., we
//   are about to read a 'int[3][4]' item. // Arrays whose elements are dynamic
//   cannot be verified.

//     // Dynamic dimensions mean that the subarray we are processing must be
// allocated     // in memory.
//     if dims[dimension] == ArrayLength::Dynamic {
//         let length = bin
//             .builder
//             .build_load(bin.context.i64_type(), buffer, "array_length")
//             .into_int_value();

//         let array_start =
//             bin.builder
//                 .build_int_add(offset, bin.context.i64_type().const_int(1,
// false), "");

//         bin.builder.build_store(offset_var, array_start);

//         let new_ty = Type::Array(Box::new(elem_ty.clone()),
// dims[0..(dimension + 1)].to_vec());         println!("new_ty: {:?}", new_ty);
//         let allocated_array =
//             bin.alloca_dynamic_array(func_value, &new_ty, length, None,
// false, ns);

//         if indexes.is_empty() {
//             bin.builder.build_store(array_var, allocated_array);
//         } else {
//             let array = bin.builder.build_load(
//                 bin.context.i64_type().ptr_type(AddressSpace::default()),
//                 array_var,
//                 "",
//             );
//             println!("array_ty: {:?}", array_ty);
//             let sub_arr = index_array(
//                 bin,
//                 &mut array.clone(),
//                 &mut array_ty.clone(),
//                 dims,
//                 indexes,
//                 func_value,
//                 ns,
//             );
//             bin.builder
//                 .build_store(sub_arr.into_pointer_value(), allocated_array);
//         }
//     }

//     let for_loop = set_array_loop(
//         bin,
//         array_var.into(),
//         array_ty,
//         dims,
//         dimension,
//         indexes,
//         func_value,
//         ns,
//     );
//     bin.builder.position_at_end(for_loop.body_block);

//     if 1 == dimension {
//         println!("elem_ty: {:?}", elem_ty);
//         let (read_value, advance) = read_from_buffer(buffer, bin, elem_ty,
// func_value, ns);         let array = bin.builder.build_load(
//             bin.context.i64_type().ptr_type(AddressSpace::default()),
//             array_var,
//             "",
//         );
//         let ptr = index_array(
//             bin,
//             &mut array.clone(),
//             &mut array_ty.clone(),
//             dims,
//             indexes,
//             func_value,
//             ns,
//         );

//         bin.builder
//             .build_store(ptr.into_pointer_value(), read_value);

//         let offset = bin.builder.build_int_add(advance, offset, "");

//         bin.builder.build_store(offset_var, offset);
//     } else {
//         println!("else_array_ty: {:?}", array_ty);
//         println!("else_elem_ty: {:?}", elem_ty);
//         decode_complex_array(
//             bin,
//             buffer,
//             array_var,
//             array_ty,
//             elem_ty,
//             offset_var,
//             dims,
//             dimension - 1,
//             func_value,
//             ns,
//             indexes,
//         );
//     }

//     finish_array_loop(bin, &for_loop);
// }

/// Decodes a complex array from a encoded buffer
/// Complex arrays are either dynamic arrays or arrays of dynamic types, like
/// structs. If this is an array of structs, whose representation in memory is
/// padded, the array is also complex, because it cannot be memcpy'ed
fn decode_complex_array<'a>(
    bin: &Binary<'a>,
    buffer: PointerValue<'a>,
    array_var: PointerValue<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    offset_var: PointerValue<'a>,
    dims: &[ArrayLength],
    dimension: usize,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
    indexes: &mut Vec<PointerValue<'a>>,
) {
    let offset = bin
        .builder
        .build_load(bin.context.i64_type(), offset_var, "")
        .into_int_value();
    // If we have a 'int[3][4][] vec', we can only validate the buffer afte we have
    // allocated the outer dimension, i.e., we are about to read a 'int[3][4]' item.
    // Arrays whose elements are dynamic cannot be verified.

    // Dynamic dimensions mean that the subarray we are processing must be allocated
    // in memory.

    if dims[dimension] == ArrayLength::Dynamic {
        let length_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                buffer,
                &[offset],
                "array_length",
            )
        };

        let length = bin
            .builder
            .build_load(bin.context.i64_type(), length_ptr, "")
            .into_int_value();

        let array_start =
            bin.builder
                .build_int_add(offset, bin.context.i64_type().const_int(1, false), "");

        bin.builder.build_store(offset_var, array_start);

        let new_ty = Type::Array(Box::new(elem_ty.clone()), dims[0..(dimension + 1)].to_vec());
        let allocated_array =
            bin.alloca_dynamic_array(func_value, &new_ty, length, None, false, ns);

        if indexes.is_empty() {
            bin.builder.build_store(array_var, allocated_array);
        } else {
            let array = bin.builder.build_load(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                array_var,
                "load_array",
            );
            let sub_arr = index_array(
                bin,
                &mut array.clone(),
                &mut array_ty.clone(),
                dims,
                indexes,
                func_value,
                ns,
                true,
            );
            bin.builder
                .build_store(sub_arr.into_pointer_value(), allocated_array);
        }
    }

    let array = bin.builder.build_load(
        bin.context.i64_type().ptr_type(AddressSpace::default()),
        array_var,
        "",
    );

    let for_loop = set_array_loop(
        bin,
        array.into(),
        array_ty,
        dims,
        dimension,
        indexes,
        func_value,
        ns,
    );
    bin.builder.position_at_end(for_loop.body_block);

    let offset = bin
        .builder
        .build_load(bin.context.i64_type(), offset_var, "")
        .into_int_value();

    let buffer = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            buffer,
            &[offset],
            "",
        )
    };

    if 0 == dimension {
        let (read_value, advance) = read_from_buffer(buffer, bin, elem_ty, func_value, ns);
        let array = bin.builder.build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            array_var,
            "",
        );
        let ptr = index_array(
            bin,
            &mut array.clone(),
            &mut array_ty.clone(),
            dims,
            indexes,
            func_value,
            ns,
            true,
        );

        bin.builder
            .build_store(ptr.into_pointer_value(), read_value);

        let offset = bin.builder.build_int_add(advance, offset, "");

        bin.builder.build_store(offset_var, offset);
    } else {
        decode_complex_array(
            bin,
            buffer,
            array_var,
            array_ty,
            elem_ty,
            offset_var,
            dims,
            dimension - 1,
            func_value,
            ns,
            indexes,
        );
    }

    finish_array_loop(bin, &for_loop);
}
