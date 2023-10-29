use inkwell::{
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    IntPredicate,
};
use num_traits::ToPrimitive;

use crate::{
    irgen::{binary::Binary, storage::storage_load},
    sema::ast::{ArrayLength, Namespace, Type},
};

use super::{allow_memcpy, finish_array_loop, index_array, load_struct_member, set_array_loop};

/// Provide generic encoding for any given `arg` into `buffer`.
pub(crate) fn encode_into_buffer<'a>(
    buffer: PointerValue<'a>,
    arg: BasicValueEnum<'a>,
    arg_ty: &Type,
    offset: IntValue<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    match arg_ty {
        Type::Contract(_) | Type::Address | Type::Hash => {
            encode_address_or_hash(buffer, arg, &mut offset.clone(), bin);
            bin.context.i64_type().const_int(4, false)
        }
        Type::Bool | Type::Uint(32) | Type::Enum(_) | Type::Field => {
            encode_uint(buffer, arg, offset, bin);
            bin.context.i64_type().const_int(1, false)
        }

        Type::String | Type::DynamicBytes => {
            encode_bytes(buffer, arg, &mut offset.clone(), bin, func_value, ns)
        }

        Type::Struct(struct_no) => encode_struct(
            arg,
            arg_ty,
            buffer,
            &mut offset.clone(),
            *struct_no,
            bin,
            func_value,
            ns,
        ),
        Type::Slice(ty) => {
            let dims = &[ArrayLength::Dynamic];
            encode_array(
                bin,
                arg,
                arg_ty,
                ty,
                dims,
                buffer,
                &mut offset.clone(),
                func_value,
                ns,
            )
        }
        Type::Array(ty, dims) => encode_array(
            bin,
            arg,
            arg_ty,
            ty,
            dims,
            buffer,
            &mut offset.clone(),
            func_value,
            ns,
        ),

        Type::Ref(r) => {
            if let Type::Struct(struct_no) = &**r {
                // Structs references should not be dereferenced
                return encode_struct(
                    arg,
                    arg_ty,
                    buffer,
                    &mut offset.clone(),
                    *struct_no,
                    bin,
                    func_value,
                    ns,
                );
            }
            let loaded = bin
                .builder
                .build_load(bin.llvm_type(r, ns), arg.into_pointer_value(), "");
            encode_into_buffer(buffer, loaded, r, offset, bin, func_value, ns)
        }
        Type::StorageRef(r) => {
            let loaded = storage_load(bin, r, &mut arg.clone(), func_value, ns);
            encode_into_buffer(buffer, loaded, r, offset, bin, func_value, ns)
        }
        Type::UserType(_) | Type::Unresolved | Type::Unreachable => {
            unreachable!("Type should not exist in irgen")
        }
        Type::Void | Type::BufferPointer | Type::Mapping(..) | Type::Function { .. } => {
            unreachable!("This type cannot be encoded")
        }
        _ => unreachable!("Type {:?} should not exist in irgen", arg_ty),
    }
}

/// Write whatever is inside the given `arg` into `buffer` without any
/// modification.
pub(crate) fn encode_uint<'a>(
    buffer: PointerValue<'a>,
    arg: BasicValueEnum<'a>,
    offset: IntValue<'a>,
    bin: &Binary<'a>,
) {
    let start = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            buffer,
            &[offset],
            "encode_value_ptr",
        )
    };
    bin.builder.build_store(start, arg);
}

// /// Write whatever is inside the given `arg` into `buffer` without any
// /// modification.
// pub(crate) fn encode_bool<'a>(
//     buffer: PointerValue<'a>,
//     arg: BasicValueEnum<'a>,
//     offset: IntValue<'a>,
//     bin: &Binary<'a>,
// ) {
//     let start = unsafe {
//         bin.builder
//             .build_gep(bin.context.bool_type(), buffer, &[offset], "start")
//     };
//     bin.builder.build_store(start, arg);
// }

/// Encode `address` into `buffer` as an [4 * i64] array.
fn encode_address_or_hash<'a>(
    buffer: PointerValue<'a>,
    address: BasicValueEnum<'a>,
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
) {
    for i in 0..4 {
        let value_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                address.into_pointer_value(),
                &[bin.context.i64_type().const_int(i, false)],
                "",
            )
        };
        let value = bin
            .builder
            .build_load(bin.context.i64_type(), value_ptr, "");
        encode_uint(buffer, value, *offset, bin);
        *offset =
            bin.builder
                .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
    }
}

/// Encode `string` into `buffer` as bytes.
fn encode_bytes<'a>(
    buffer: PointerValue<'a>,
    string_value: BasicValueEnum<'a>,
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let len = bin.vector_len(string_value);
    // First, we must save the length of the string
    encode_uint(buffer, len.into(), *offset, bin);
    *offset = bin.build_int_add(
        *offset,
        bin.context.i64_type().const_int(1, false),
        "offset",
    );
    let data = bin.vector_data(string_value);

    encode_dynamic_array_loop(
        data,
        offset,
        len,
        &Type::String,
        &Type::Uint(32),
        buffer,
        bin,
        func_value,
        ns,
    );
    bin.builder
        .build_int_add(len, bin.context.i64_type().const_int(1, false), "")
}

/// Currently, we can only handle one-dimensional arrays.
/// The situation of multi-dimensional arrays has not been processed yet.
pub fn encode_dynamic_array_loop<'a>(
    array: PointerValue<'a>,
    offset: &mut IntValue<'a>,
    length: IntValue<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    buffer: PointerValue<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    let loop_body = bin.context.append_basic_block(func_value, "loop_body");
    let loop_end = bin.context.append_basic_block(func_value, "loop_end");

    // Initialize index before the loop
    let index_ptr = bin.build_alloca(func_value, bin.context.i64_type(), "index_ptr");

    let offset_ptr = bin.build_alloca(func_value, bin.context.i64_type(), "offset_ptr");
    bin.builder.build_store(offset_ptr, *offset);
    bin.builder
        .build_store(index_ptr, bin.context.i64_type().const_zero());

    bin.builder.build_unconditional_branch(loop_body);
    bin.builder.position_at_end(loop_body);

    // Load index in every iteration
    let index = bin
        .builder
        .build_load(bin.context.i64_type(), index_ptr, "index");

    let elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.llvm_type(array_ty, ns),
            array,
            &[index.into_int_value()],
            "element",
        )
    };

    let elem = if elem_ty.is_primitive() {
        bin.builder
            .build_load(bin.llvm_type(elem_ty, ns), elem_ptr, "elem")
    } else {
        elem_ptr.into()
    };

    let offset = bin
        .builder
        .build_load(bin.context.i64_type(), offset_ptr, "offset")
        .into_int_value();
    let encode_len = encode_into_buffer(buffer, elem, elem_ty, offset, bin, func_value, ns);

    bin.builder.build_store(
        offset_ptr,
        bin.build_int_add(encode_len, offset, "next_offset"),
    );

    let next_index = bin.build_int_add(
        index.into_int_value(),
        bin.context.i64_type().const_int(1, false),
        "next_index",
    );

    // Store the next_index for the next iteration
    bin.builder.build_store(index_ptr, next_index);

    let cond = bin
        .builder
        .build_int_compare(IntPredicate::ULT, next_index, length, "index_cond");

    bin.builder
        .build_conditional_branch(cond, loop_body, loop_end);

    bin.builder.position_at_end(loop_end);
}

/// Encode `struct` into `buffer` as a struct type.
fn encode_struct<'a>(
    struct_value: BasicValueEnum<'a>,
    struct_ty: &Type,
    buffer: PointerValue<'a>,
    offset: &mut IntValue<'a>,
    struct_no: usize,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let qty = ns.structs[struct_no].fields.len();
    let first_ty = ns.structs[struct_no].fields[0].ty.clone();
    let loaded = load_struct_member(bin, struct_ty, &first_ty, struct_value, 0, ns);

    let mut advance = encode_into_buffer(buffer, loaded, &first_ty, *offset, bin, func_value, ns);
    let mut runtime_size = advance.clone();
    for i in 1..qty {
        let ith_type = ns.structs[struct_no].fields[i].ty.clone();
        *offset = bin.build_int_add(advance, *offset, "");
        let loaded = load_struct_member(bin, struct_ty, &ith_type, struct_value, i, ns);
        // After fetching the struct member, we can encode it
        advance = encode_into_buffer(buffer, loaded, &ith_type, *offset, bin, func_value, ns);
        runtime_size = bin.build_int_add(advance, runtime_size, "");
    }

    runtime_size
}

/// Encode `array` into `buffer` as an array.
fn encode_array<'a>(
    bin: &Binary<'a>,
    array: BasicValueEnum<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    dims: &[ArrayLength],
    buffer: PointerValue<'a>,
    offset: &mut IntValue<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    assert!(!dims.is_empty());

    if allow_memcpy(array_ty, ns) {
        // Calculate number of elements
        let size = if matches!(dims.last(), Some(&ArrayLength::Fixed(_))) {
            let dims = dims
                .iter()
                .map(|d| match d {
                    ArrayLength::Fixed(d) => d.to_u32().unwrap(),
                    _ => unreachable!(),
                })
                .collect::<Vec<_>>();
            fixed_array_encode(array, buffer, array_ty, offset, elem_ty, &dims, bin, ns)
        } else {
            // If the array is dynamic, we must save its size before all elements
            let length = bin.vector_len(array);
            encode_uint(buffer, length.into(), *offset, bin);
            *offset =
                bin.builder
                    .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
            encode_dynamic_array_loop(
                array.into_pointer_value(),
                offset,
                length,
                array_ty,
                elem_ty,
                buffer,
                bin,
                func_value,
                ns,
            );
            bin.builder
                .build_int_add(length, bin.context.i64_type().const_int(1, false), "")
        };
        return size;
    }

    // In all other cases, we must loop through the array
    let mut indexes: Vec<IntValue<'a>> = Vec::new();
    let offset_var_no = bin
        .builder
        .build_alloca(bin.context.i64_type(), "offset_var_no");
    bin.builder.build_store(offset_var_no, offset.clone());
    encode_complex_array(
        buffer,
        bin,
        array,
        array_ty,
        dims,
        dims.len() - 1,
        offset_var_no,
        func_value,
        ns,
        &mut indexes,
    );

    // The offset variable minus the original offset obtains the vector size in
    // bytes
    let offset_var = bin
        .builder
        .build_load(bin.context.i64_type(), offset_var_no, "");

    bin.build_int_sub(offset_var.into_int_value(), *offset, "")
}

/// Encode `array` into `buffer` as a complex array.
/// This function indexes an array from its outer dimension to its inner one.
///
///
/// Note: In the default implementation, `encode_array` decides when to use this
/// method for you.
fn encode_complex_array<'a>(
    buffer: PointerValue<'a>,
    bin: &Binary<'a>,
    array: BasicValueEnum<'a>,
    array_ty: &Type,
    dims: &[ArrayLength],
    dimension: usize,
    offset_var: PointerValue<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
    indexes: &mut Vec<IntValue<'a>>,
) {
    let mut array_ty = array_ty.clone();
    let mut array = array.clone();
    // If this dimension is dynamic, we must save its length before all elements
    if dims[dimension] == ArrayLength::Dynamic {
        let sub_array = index_array(
            bin,
            &mut array,
            &mut array_ty,
            dims,
            indexes,
            func_value,
            ns,
        );

        let size = bin.vector_len(sub_array);

        let offset_value = bin
            .builder
            .build_load(bin.context.i64_type(), offset_var, "");

        encode_uint(buffer, size.into(), offset_value.into_int_value(), bin);

        let offset_value = bin.build_int_add(
            offset_value.into_int_value(),
            bin.context.i64_type().const_int(1, false),
            "",
        );
        bin.builder.build_store(offset_var, offset_value);
    }
    let for_loop = set_array_loop(
        bin, array, &array_ty, dims, dimension, indexes, func_value, ns,
    );
    bin.builder.position_at_end(for_loop.body_block);
    if 0 == dimension {
        // If we are indexing the last dimension, we have an element, so we can encode
        // it.
        let deref = index_array(
            bin,
            &mut array,
            &mut array_ty,
            dims,
            indexes,
            func_value,
            ns,
        );
        let offset_value = bin
            .builder
            .build_load(bin.context.i64_type(), offset_var, "");
        let elem_size = encode_into_buffer(
            buffer,
            deref,
            &array_ty,
            offset_value.into_int_value(),
            bin,
            func_value,
            ns,
        );
        let offset_value = bin
            .builder
            .build_int_add(offset_value.into_int_value(), elem_size, "");
        bin.builder.build_store(offset_var, offset_value);
    } else {
        encode_complex_array(
            buffer,
            bin,
            array,
            &array_ty,
            dims,
            dimension - 1,
            offset_var,
            func_value,
            ns,
            indexes,
        )
    }

    finish_array_loop(bin, &for_loop);
}

pub fn fixed_array_encode<'a>(
    array: BasicValueEnum<'a>,
    buffer: PointerValue<'a>,
    array_ty: &Type,
    offset: &mut IntValue<'a>,
    elem_ty: &Type,
    dimensions: &Vec<u32>,
    bin: &Binary<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let size = dimensions.iter().product();

    for i in 0..size {
        let mut ind = vec![bin.context.i64_type().const_zero()];

        let mut e = i;

        // Mapping one-dimensional array indices to multi-dimensional array indices.
        for d in dimensions {
            ind.insert(1, bin.context.i64_type().const_int((e % *d).into(), false));

            e /= *d;
        }

        let elem_ptr = unsafe {
            bin.builder.build_gep(
                bin.llvm_type(array_ty, ns),
                array.into_pointer_value(),
                &ind,
                &format!("elemptr{i}"),
            )
        };

        let elem = bin
            .builder
            .build_load(bin.llvm_type(elem_ty, ns), elem_ptr, "");

        let elem = if elem_ty.is_fixed_reference_type() {
            bin.builder.build_load(
                bin.llvm_type(elem_ty, ns),
                elem.into_pointer_value(),
                "elem",
            )
        } else {
            elem
        };

        encode_uint(buffer, elem, *offset, bin);

        *offset = bin.build_int_add(
            *offset,
            bin.context.i64_type().const_int(1, false),
            "offset",
        );
    }

    let size = bin.context.i64_type().const_int(size as u64, false);

    size
}
