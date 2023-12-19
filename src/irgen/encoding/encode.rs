use inkwell::{
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    IntPredicate, AddressSpace,
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

        Type::Struct(struct_no) => encode_struct(
            arg,
            arg_ty,
            buffer,
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
                &mut buffer.clone(),
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
            &mut buffer.clone(),
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
                    *struct_no,
                    bin,
                    func_value,
                    ns,
                );
            }
            let loaded =
                bin.builder
                    .build_load(bin.llvm_var_ty(r, ns), arg.into_pointer_value(), "");
            encode_into_buffer(buffer, loaded, r, bin, func_value, ns)
        }
        Type::StorageRef(r) => {
            let loaded = storage_load(bin, r, &mut arg.clone(), func_value, ns);
            encode_into_buffer(buffer, loaded, r,  bin, func_value, ns)
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

/// Currently, we can only handle one-dimensional arrays.
/// The situation of multi-dimensional arrays has not been processed yet.
pub fn encode_dynamic_array_loop<'a>(
    array: PointerValue<'a>,
    length: IntValue<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    buffer: &mut PointerValue<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    let loop_body = bin.context.append_basic_block(func_value, "loop_body");
    let loop_end = bin.context.append_basic_block(func_value, "loop_end");

    // Initialize index before the loop
    let index_ptr = bin.build_alloca(func_value, bin.context.i64_type(), "index_ptr");

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

    let elem = bin
        .builder
        .build_load(bin.llvm_var_ty(elem_ty, ns), elem_ptr, "elem");


    let encode_len = encode_into_buffer(*buffer, elem, elem_ty, bin, func_value, ns);

    *buffer = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            *buffer,
            &[encode_len],
            "",
        )
    };

    let next_index = bin.builder.build_int_add(
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
        runtime_size = bin.builder.build_int_add(advance, runtime_size, "struct_size");
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
    buffer: &mut PointerValue<'a>,
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
            fixed_array_encode(array, buffer, array_ty, elem_ty, &dims, bin, ns)
        } else {
            // If the array is dynamic, we must save its size before all elements
            let length = bin.vector_len(array);
            bin.builder.build_store(*buffer, length);
            *buffer = unsafe {
                bin.builder.build_gep(
                    bin.context.i64_type().ptr_type(AddressSpace::default()),
                    *buffer,
                    &[bin.context.i64_type().const_int(1, false)],
                    "",
                )
            };
            encode_dynamic_array_loop(
                array.into_pointer_value(),
                length,
                array_ty,
                elem_ty,
                buffer,
                bin,
                func_value,
                ns,
            );
            // TODO When the elements of the array are not of type u32, such as hash type, the size should be recalculated.
            bin.builder
                .build_int_add(length, bin.context.i64_type().const_int(1, false), "")
        };
        return size;
    }

    // In all other cases, we must loop through the array
    let mut indexes: Vec<IntValue<'a>> = Vec::new();
    encode_complex_array(
        buffer,
        bin,
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
    bin.context.i64_type().const_int(1, false)
}

/// Encode `array` into `buffer` as a complex array.
/// This function indexes an array from its outer dimension to its inner one.
///
///
/// Note: In the default implementation, `encode_array` decides when to use this
/// method for you.
fn encode_complex_array<'a>(
    buffer: &mut PointerValue<'a>,
    bin: &Binary<'a>,
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
            &mut array,
            &mut array_ty,
            dims,
            indexes,
            func_value,
            ns,
        );

        let size = bin.vector_len(sub_array);

        bin.builder.build_store(*buffer, size);

        *buffer = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                *buffer,
                &[bin.context.i64_type().const_int(1, false)],
                "",
            )
        };
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
        let elem_size = encode_into_buffer(
            *buffer,
            deref,
            &array_ty,
            bin,
            func_value,
            ns,
        );

        *buffer = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                *buffer,
                &[elem_size],
                "",
            )
        };
    } else {
        encode_complex_array(
            buffer,
            bin,
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

pub fn fixed_array_encode<'a>(
    array: BasicValueEnum<'a>,
    buffer: &mut PointerValue<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    dimensions: &Vec<u32>,
    bin: &Binary<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let size = dimensions.iter().product();

    for i in 0..size {
        let mut ind = vec![];

        let mut e = i;

        // Mapping one-dimensional array indices to multi-dimensional array indices.
        for d in dimensions {
            ind.insert(0, bin.context.i64_type().const_int((e % *d).into(), false));

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
            .build_load(bin.llvm_var_ty(elem_ty, ns), elem_ptr, "");

        let buffer_ptr = unsafe {
            bin.builder.build_gep(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                *buffer,
                &[bin.context.i64_type().const_int(i as u64, false)],
                "",
            )
        };

        bin.builder.build_store(buffer_ptr, elem);
    }

    let size = bin.context.i64_type().const_int(size as u64, false);

    size
}
