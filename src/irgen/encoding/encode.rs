use inkwell::{
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    AddressSpace,
};
use num_traits::ToPrimitive;

use crate::{
    irgen::{
        binary::Binary,
        encoding::{calculate_array_bytes_size, calculate_direct_copy_bytes_size},
        storage::storage_load,
    },
    sema::ast::{ArrayLength, Namespace, Type},
};

use super::{allow_memcpy, finish_array_loop, index_array, load_struct_member, set_array_loop};

/// Provide generic encoding for any given `arg` into `buffer`.
pub(crate) fn encode_into_buffer<'a>(
    buffer: PointerValue<'a>,
    arg: BasicValueEnum<'a>,
    arg_ty: &Type,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    match arg_ty {
        Type::Contract(_) | Type::Address | Type::Hash => {
            encode_address_or_hash(buffer, arg, bin);
            bin.context.i64_type().const_int(4, false)
        }
        Type::Bool | Type::Uint(32) | Type::Enum(_) | Type::Field => {
            bin.builder.build_store(buffer, arg);
            bin.context.i64_type().const_int(1, false)
        }

        Type::String | Type::DynamicBytes => encode_bytes(buffer, arg, bin),

        Type::Struct(struct_no) => {
            encode_struct(arg, arg_ty, buffer, *struct_no, bin, func_value, ns)
        }
        Type::Slice(ty) => {
            let dims = &[ArrayLength::Dynamic];
            encode_array(bin, arg, arg_ty, ty, dims, buffer.clone(), func_value, ns)
        }
        Type::Array(ty, dims) => {
            encode_array(bin, arg, arg_ty, ty, dims, buffer.clone(), func_value, ns)
        }

        Type::Ref(r) => {
            if let Type::Struct(struct_no) = &**r {
                // Structs references should not be dereferenced
                return encode_struct(arg, arg_ty, buffer, *struct_no, bin, func_value, ns);
            }
            let loaded =
                bin.builder
                    .build_load(bin.llvm_var_ty(r, ns), arg.into_pointer_value(), "");
            encode_into_buffer(buffer, loaded, r, bin, func_value, ns)
        }
        Type::StorageRef(r) => {
            let loaded = storage_load(bin, r, &mut arg.clone(), func_value, ns);
            encode_into_buffer(buffer, loaded, r, bin, func_value, ns)
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

/// Encode `address` into `buffer` as an [4 * i64] array.
fn encode_address_or_hash<'a>(
    buffer: PointerValue<'a>,
    address: BasicValueEnum<'a>,
    bin: &Binary<'a>,
) {
    for i in 0..4 {
        let source_value_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                address.into_pointer_value(),
                &[bin.context.i64_type().const_int(i, false)],
                "",
            )
        };
        let source_value = bin
            .builder
            .build_load(bin.context.i64_type(), source_value_ptr, "");
        let dest_value_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type(),
                buffer,
                &[bin.context.i64_type().const_int(i, false)],
                "",
            )
        };
        bin.builder.build_store(dest_value_ptr, source_value);
    }
}

/// Encode `string` into `buffer` as bytes.
fn encode_bytes<'a>(
    buffer: PointerValue<'a>,
    string_value: BasicValueEnum<'a>,
    bin: &Binary<'a>,
) -> IntValue<'a> {
    let len = bin.vector_len(string_value);
    let total_len = bin
        .builder
        .build_int_add(len, bin.context.i64_type().const_int(1, false), "");
    bin.memcpy(string_value.into_pointer_value(), buffer, total_len);
    total_len
}

/// Encode `struct` into `buffer` as a struct type.
fn encode_struct<'a>(
    struct_value: BasicValueEnum<'a>,
    struct_ty: &Type,
    buffer: PointerValue<'a>,
    struct_no: usize,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let qty = ns.structs[struct_no].fields.len();
    let mut runtime_size = bin.context.i64_type().const_zero();
    let mut advance = bin.context.i64_type().const_zero();
    let mut buffer = buffer.clone();
    for i in 0..qty {
        let ith_type = ns.structs[struct_no].fields[i].ty.clone();
        let loaded = load_struct_member(bin, struct_ty, &ith_type, struct_value, i, ns);
        // After fetching the struct member, we can encode it
        buffer = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                buffer,
                &[advance],
                "struct_offset",
            )
        };
        advance = encode_into_buffer(buffer, loaded, &ith_type, bin, func_value, ns);
        runtime_size = bin
            .builder
            .build_int_add(advance, runtime_size, "struct_size");
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
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    assert!(!dims.is_empty());

    if allow_memcpy(array_ty, ns) {
        // Calculate number of elements
        let size = if matches!(dims.last(), Some(&ArrayLength::Fixed(_))) {
            let array_bytes_size = bin.context.i64_type().const_int(
                calculate_direct_copy_bytes_size(dims, elem_ty, ns)
                    .to_u64()
                    .unwrap(),
                false,
            );
            bin.memcpy(array.into_pointer_value(), buffer, array_bytes_size);
            array_bytes_size
        } else {
            // If the array is dynamic, we must save its size before all elements
            let length = bin.vector_len(array);
            let size = calculate_array_bytes_size(bin, length, elem_ty, ns);
            let copy_size =
                bin.builder
                    .build_int_add(size, bin.context.i64_type().const_int(1, false), "");
            bin.memcpy(array.into_pointer_value(), buffer, copy_size);
            copy_size
        };
        return size;
    }

    // In all other cases, we must loop through the array
    let mut indexes: Vec<IntValue<'a>> = Vec::new();
    let offset_var = bin.build_alloca(func_value, bin.context.i64_type(), "buffer_offset");
    bin.builder
        .build_store(offset_var, bin.context.i64_type().const_zero());
    encode_complex_array(
        buffer,
        bin,
        offset_var,
        array,
        array_ty,
        dims,
        dims.len() - 1,
        func_value,
        ns,
        &mut indexes,
    );

    // The offset variable minus the original offset obtains the vector size in
    // bytes
    // TODO The correct size should be returned here.
    bin.builder
        .build_load(bin.context.i64_type(), offset_var, "")
        .into_int_value()
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
    offset_var: PointerValue<'a>,
    array: BasicValueEnum<'a>,
    array_ty: &Type,
    dims: &[ArrayLength],
    dimension: usize,
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
            &mut array.clone(),
            &mut array_ty,
            dims,
            indexes,
            func_value,
            ns,
        );

        let offset = bin
            .builder
            .build_load(bin.context.i64_type(), offset_var, "")
            .into_int_value();

        bin.builder.build_store(
            offset_var,
            bin.builder
                .build_int_add(offset, bin.context.i64_type().const_int(1, false), ""),
        );

        let buffer_offset = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                buffer,
                &[offset],
                "",
            )
        };
        let size = bin.vector_len(sub_array);
        // Store the length at the first of the buffer.
        bin.builder.build_store(buffer_offset, size);
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

        let offset = bin
            .builder
            .build_load(bin.context.i64_type(), offset_var, "")
            .into_int_value();

        let buffer_offset = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                buffer,
                &[offset],
                "",
            )
        };
        let elem_size = encode_into_buffer(buffer_offset, deref, &array_ty, bin, func_value, ns);

        bin.builder.build_store(
            offset_var,
            bin.builder.build_int_add(
                bin.builder
                    .build_load(bin.context.i64_type(), offset_var, "")
                    .into_int_value(),
                elem_size,
                "",
            ),
        );
    } else {
        encode_complex_array(
            buffer,
            bin,
            offset_var,
            array,
            &array_ty,
            dims,
            dimension - 1,
            func_value,
            ns,
            indexes,
        )
    }

    finish_array_loop(bin, &for_loop);
}
