use inkwell::{
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    AddressSpace,
};

use num_traits::ToPrimitive;

use crate::{
    irgen::binary::Binary,
    sema::ast::{Namespace, Type},
};

use super::get_args_type_size;

/// Read a value of type 'ty' from the buffer at a given offset. Returns an
/// expression containing the read value and the number of bytes read.
pub(crate) fn read_from_buffer<'a>(
    buffer: IntValue<'a>,
    bin: &Binary<'a>,
    ty: &Type,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    match ty {
        Type::Uint(32) | Type::Bool | Type::Enum(_) | Type::Field => {
            let size = get_args_type_size(bin, buffer.into(), ty, func_value, ns);
            let buffer_ptr = bin.builder.build_int_to_ptr(
                buffer,
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                "",
            );
            let decode_value =
                bin.builder
                    .build_load(bin.context.i64_type(), buffer_ptr, "decode_value");
            (decode_value, size)
        }

        Type::Address | Type::Contract(_) | Type::Hash => {
            let size = get_args_type_size(bin, buffer.into(), ty, func_value, ns);
            let buffer = bin.builder.build_int_to_ptr(
                buffer,
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                "",
            );
            (buffer.into(), size)
        }

        Type::String | Type::DynamicBytes => {
            // String and Dynamic bytes are encoded as size + elements.length
            let buffer_ptr = bin.builder.build_int_to_ptr(
                buffer,
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                "",
            );
            let total_size = get_args_type_size(bin, buffer_ptr.into(), ty, func_value, ns);

            (buffer_ptr.into(), total_size)
        }

        Type::UserType(type_no) => {
            let usr_type = ns.user_types[*type_no].ty.clone();
            read_from_buffer(buffer, bin, &usr_type, func_value, ns)
        }

        Type::Array(..) => {
            let buffer = bin.builder.build_int_to_ptr(
                buffer,
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                "",
            );
            decode_array(buffer.into(), ty, bin, func_value, ns)
        }

        Type::Slice(..) => {
            let buffer = bin.builder.build_int_to_ptr(
                buffer,
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                "",
            );
            decode_array(buffer, ty, bin, func_value, ns)
        }

        Type::Struct(no) => decode_struct(&mut buffer.clone(), ty, *no, bin, func_value, ns),

        _ => unreachable!("read_from_buffer: {:?}", ty),
    }
}

fn decode_array<'a>(
    buffer: PointerValue<'a>,
    array_ty: &Type,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    let size = get_args_type_size(bin, buffer.into(), array_ty, func_value, ns);
    (buffer.into(), size)
}

fn decode_struct<'a>(
    buffer: &mut IntValue<'a>,
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

    let buffer_before = *buffer;
    let mut read_items: Vec<BasicValueEnum<'_>> = vec![];

    for i in 0..qty {
        let (read_expr, advance) = read_from_buffer(*buffer, bin, &struct_tys[i], func_value, ns);
        read_items.push(read_expr);
        *buffer = bin.build_int_add(*buffer, advance, "struct_offset");
    }
    let runtime_size = bin.build_int_sub(*buffer, buffer_before, "struct_decode_size");

    let struct_var = struct_literal_copy(ty, read_items, bin, ns);
    (struct_var, runtime_size)
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
        .const_int(ty.memory_size_of(ns).to_u64().unwrap(), false);

    let (_, struct_alloca) = bin.heap_malloc(struct_size);

    for (i, elem) in values.iter().enumerate() {
        let elemptr = unsafe {
            bin.builder.build_gep(
                struct_ty,
                struct_alloca,
                &[bin.context.i64_type().const_int(i as u64, false)],
                "struct_member",
            )
        };
        bin.builder.build_store(elemptr, *elem);
    }

    struct_alloca.into()
}

// /// Decodes a complex array from a borsh encoded buffer
// /// Complex arrays are either dynamic arrays or arrays of dynamic types, like
// /// structs. If this is an array of structs, whose representation in memory
// is /// padded, the array is also complex, because it cannot be memcpy'ed
// fn decode_complex_array<'a>(
//     bin: &Binary<'a>,
//     array_var: PointerValue<'a>,
//     buffer: PointerValue<'a>,
//     offset_var: PointerValue<'a>,
//     dimension: usize,
//     array_ty: &Type,
//     elem_ty: &Type,
//     dims: &[ArrayLength],
//     func_value: FunctionValue<'a>,
//     ns: &Namespace,
//     indexes: &mut Vec<IntValue<'a>>,
// ) {
//     let offset = bin
//         .builder
//         .build_load(bin.context.i64_type(), offset_var, "")
//         .into_int_value();
//     // If we have a 'int[3][4][] vec', we can only validate the buffer after
// we have     // allocated the outer dimension, i.e., we are about to read a
// 'int[3][4]' item.     // Arrays whose elements are dynamic cannot be
// verified.     if validator.validation_necessary()
//         && !dims[0..(dimension + 1)]
//             .iter()
//             .any(|d| *d == ArrayLength::Dynamic)
//         && !elem_ty.is_dynamic(ns)
//     {
//         let mut elems = BigInt::one();
//         for item in &dims[0..(dimension + 1)] {
//             elems.mul_assign(item.array_length().unwrap());
//         }
//         elems.mul_assign(elem_ty.memory_size_of(ns));
//         let elems_size = bin
//             .context
//             .i64_type()
//             .const_int(elems.to_u64().unwrap(), false);
//         validator.validate_offset_plus_size(bin, offset, elems_size,
// func_value);         validator.validate_array();
//     }

//     // Dynamic dimensions mean that the subarray we are processing must be
// allocated     // in memory.
//     if dims[dimension] == ArrayLength::Dynamic {
//         let length = decode_uint(buffer, offset, bin);

//         let array_start =
//             bin.builder
//                 .build_int_add(offset, bin.context.i64_type().const_int(1,
// false), "");         //validator.validate_offset(bin, array_start.clone(),
// func_value);

//         bin.builder.build_store(offset_var, array_start);

//         // let new_ty = Type::Array(Box::new(elem_ty.clone()),
// dims[0..(dimension +         // 1)].to_vec());
//         let allocated_array = bin.alloca_dynamic_array(
//             func_value,
//             array_ty,
//             length.into_int_value(),
//             None,
//             false,
//             ns,
//         );

//         if indexes.is_empty() {
//             bin.builder.build_store(array_var, allocated_array);
//         } else {
//             let array = bin.builder.build_load(
//                 bin.context.i64_type().ptr_type(AddressSpace::default()),
//                 array_var,
//                 "",
//             );
//             let sub_arr = index_array(
//                 bin,
//                 &mut array.clone(),
//                 &mut array_ty.clone(),
//                 dims,
//                 indexes,
//                 func_value,
//                 ns,
//             );
//             bin.builder.build_store(array_var, sub_arr);
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

//     if 0 == dimension {
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

//         let offset = bin.build_int_add(advance, offset, "");

//         bin.builder.build_store(offset_var, offset);
//     } else {
//         decode_complex_array(
//             bin,
//             array_var,
//             buffer,
//             offset_var,
//             dimension - 1,
//             array_ty,
//             elem_ty,
//             dims,
//             func_value,
//             ns,
//             indexes,
//         );
//     }

//     finish_array_loop(bin, &for_loop);
// }
