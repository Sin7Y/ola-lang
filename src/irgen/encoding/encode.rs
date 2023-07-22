use inkwell::{
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    IntPredicate,
};
use num_traits::ToPrimitive;

use crate::{
    irgen::{binary::Binary, storage::storage_load},
    sema::ast::{ArrayLength, Namespace, Type},
};

use super::{
    allow_memcpy, calculate_struct_non_padded_size, finish_array_loop, index_array, set_array_loop,
};

/// Calculate the size of a set of arguments to encoding functions
pub fn calculate_size_args<'a>(
    bin: &Binary<'a>,
    args: &[BasicValueEnum<'a>],
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let mut size = get_args_type_size(bin, 0, args[0], &types[0], func_value, ns);
    for (i, item) in types.iter().enumerate().skip(1) {
        let additional = get_args_type_size(bin, i, args[i], item, func_value, ns);
        size = bin.builder.build_int_add(size, additional, "");
    }
    size
}

/// Calculate the size of a single arg value
fn get_args_type_size<'a>(
    bin: &Binary<'a>,
    arg_no: usize,
    arg_value: BasicValueEnum<'a>,
    ty: &Type,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    match &ty {
        Type::Uint(32) | Type::Bool | Type::Enum(_) => bin.context.i64_type().const_int(1, false),
        Type::Contract(_) | Type::Address => bin.context.i64_type().const_int(4, false),

        Type::Struct(struct_no) => {
            calculate_struct_size(bin, arg_no, arg_value, *struct_no, ty, func_value, ns)
        }
        Type::Slice(elem_ty) => {
            let dims = vec![ArrayLength::Dynamic];
            calculate_array_size(bin, arg_value, ty, &elem_ty, &dims, arg_no, func_value, ns)
        }
        Type::Array(elem_ty, dims) => {
            calculate_array_size(bin, arg_value, ty, &elem_ty, dims, arg_no, func_value, ns)
        }

        Type::Ref(r) => {
            if let Type::Struct(struct_no) = &**r {
                return calculate_struct_size(
                    bin, arg_no, arg_value, *struct_no, ty, func_value, ns,
                );
            }

            let loaded = bin.builder.build_load(
                bin.llvm_type(ty.deref_memory(), ns),
                arg_value.into_pointer_value(),
                "",
            );

            get_args_type_size(bin, arg_no, loaded, r, func_value, ns)
        }
        Type::StorageRef(r) => {
            let storage_var = storage_load(bin, r, &mut arg_value.clone(), func_value, ns);
            let size = get_args_type_size(bin, arg_no, storage_var, r, func_value, ns);
            size
        }
        Type::String => calculate_string_size(bin, arg_value),
        Type::Void
        | Type::Unreachable
        | Type::BufferPointer
        | Type::Mapping(..)
        | Type::Function { .. } => {
            unreachable!("This type cannot be encoded")
        }
        Type::UserType(_) | Type::Unresolved => {
            unreachable!("Type should not exist in irgen")
        }
        _ => unreachable!("Type should not exist in irgen"),
    }
}

/// Retrieves the size of a struct
fn calculate_struct_size<'a>(
    bin: &Binary<'a>,
    arg_no: usize,
    struct_ptr: BasicValueEnum<'a>,
    struct_no: usize,
    ty: &Type,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    if let Some(struct_size) = calculate_struct_non_padded_size(struct_no, ns) {
        return bin
            .context
            .i64_type()
            .const_int(struct_size.to_u64().unwrap(), false);
    }
    let first_type = ns.structs[struct_no].fields[0].ty.clone();
    let first_field = load_struct_member(bin, ty, &first_type, struct_ptr, 0, ns);
    let mut size = get_args_type_size(bin, arg_no, first_field, &first_type, func_value, ns);
    for i in 1..ns.structs[struct_no].fields.len() {
        let field_ty = ns.structs[struct_no].fields[i].ty.clone();
        let field = load_struct_member(bin, ty, &field_ty, struct_ptr, i, ns);
        let expr_size = get_args_type_size(bin, arg_no, field, &field_ty, func_value, ns).into();
        size = bin.builder.build_int_add(size, expr_size, "");
    }
    size
}

/// Loads a struct member
fn load_struct_member<'a>(
    bin: &Binary<'a>,
    struct_ty: &Type,
    field_ty: &Type,
    struct_ptr: BasicValueEnum<'a>,
    member: usize,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let struct_ty = bin.llvm_type(struct_ty.deref_memory(), ns);

    let struct_member = bin
        .builder
        .build_struct_gep(
            struct_ty,
            struct_ptr.into_pointer_value(),
            member as u32,
            "struct member",
        )
        .unwrap();
    if field_ty.is_fixed_reference_type() {
        return struct_member.into();
    }
    bin.builder
        .build_load(bin.llvm_type(field_ty, ns), struct_member, "")
}

fn calculate_string_size<'a>(bin: &Binary<'a>, string_value: BasicValueEnum<'a>) -> IntValue<'a> {
    // When encoding a variable length array, the total size is "compact encoded
    // array length + N elements"
    let length = bin.vector_len(string_value);
    bin.builder
        .build_int_add(length, bin.context.i64_type().const_int(1, false), "")
}

/// Calculate the size of an array
fn calculate_array_size<'a>(
    bin: &Binary<'a>,
    array: BasicValueEnum<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    dims: &Vec<ArrayLength>,
    arg_no: usize,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let dyn_dims = dims.iter().filter(|d| **d == ArrayLength::Dynamic).count();

    // If the array does not have variable length elements,
    // we can calculate its size using a simple multiplication (direct_assessment)
    // i.e. 'uint8[3][] vec' has size vec.length*2*size_of(uint8)
    // In cases like 'uint [3][][2] v' this is not possible, as v[0] and v[1] have
    // different sizes
    let direct_assessment =
        dyn_dims == 0 || (dyn_dims == 1 && dims.last() == Some(&ArrayLength::Dynamic));

    // Check if the array contains only fixed sized elements
    let primitive_size = if elem_ty.is_primitive() && direct_assessment {
        Some(elem_ty.memory_size_of(ns))
    } else if let Type::Struct(struct_no) = elem_ty {
        if direct_assessment {
            calculate_struct_non_padded_size(*struct_no, ns)
        } else {
            None
        }
    } else {
        None
    };

    if let Some(compile_type_size) = primitive_size {
        // If the array saves primitive-type elements, its size is
        // sizeof(type)*vec.length
        let mut size = if let ArrayLength::Fixed(dim) = &dims.last().unwrap() {
            bin.context
                .i64_type()
                .const_int(dim.to_u64().unwrap(), false)
        } else {
            bin.vector_len(array)
        };

        for item in dims.iter().take(dims.len() - 1) {
            let local_size = bin
                .context
                .i64_type()
                .const_int(item.array_length().unwrap().to_u64().unwrap(), false);
            size = bin.builder.build_int_mul(size, local_size, "");
        }

        let type_size = bin
            .context
            .i64_type()
            .const_int(compile_type_size.to_u64().unwrap(), false);
        let size = bin.builder.build_int_mul(size, type_size, "");

        if !matches!(&dims.last().unwrap(), ArrayLength::Dynamic) {
            return size;
        }

        // If the array is dynamic, we must save its size before all elements
        bin.builder
            .build_int_add(size, bin.context.i64_type().const_int(1, false), "")
    } else {
        let mut index_vec: Vec<IntValue<'a>> = Vec::new();
        let size_var = bin.builder.build_alloca(bin.context.i64_type(), "size_var");
        bin.builder
            .build_store(size_var, bin.context.i64_type().const_zero());
        calculate_complex_array_size(
            bin,
            array,
            array_ty,
            elem_ty,
            arg_no,
            dims,
            dims.len() - 1,
            size_var,
            func_value,
            ns,
            &mut index_vec,
        );
        bin.builder
            .build_load(bin.context.i64_type(), size_var, "")
            .into_int_value()
    }
}

/// Calculate the size of a complex array.
/// This function indexes an array from its outer dimension to its inner one and
/// accounts for the encoded length size for dynamic dimensions.
fn calculate_complex_array_size<'a>(
    bin: &Binary<'a>,
    array: BasicValueEnum<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    arg_no: usize,
    dims: &Vec<ArrayLength>,
    dimension: usize,
    size_var: PointerValue<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
    indexes: &mut Vec<IntValue<'a>>,
) {
    // If this dimension is dynamic, account for the encoded vector length variable.
    if dims[dimension] == ArrayLength::Dynamic {
        let arr = index_array(
            bin,
            &mut array.clone(),
            &mut array_ty.clone(),
            elem_ty,
            dims,
            indexes,
            func_value,
            ns,
        );
        let size = bin.vector_len(arr);
        let size = bin.builder.build_int_add(
            size,
            bin.builder
                .build_load(bin.context.i64_type(), size_var, "")
                .into_int_value(),
            "",
        );
        bin.builder.build_store(size_var, size);
    }

    let for_loop = set_array_loop(
        bin, array, array_ty, elem_ty, dims, dimension, indexes, func_value, ns,
    );
    bin.builder.position_at_end(for_loop.body_block);

    if 0 == dimension {
        let deref = index_array(
            bin,
            &mut array.clone(),
            &mut array_ty.clone(),
            elem_ty,
            dims,
            indexes,
            func_value,
            ns,
        );
        let elem_size = get_args_type_size(bin, arg_no, deref, elem_ty, func_value, ns);

        let size = bin.builder.build_int_add(
            bin.builder
                .build_load(bin.context.i64_type(), size_var, "")
                .into_int_value(),
            elem_size,
            "",
        );
        bin.builder.build_store(size_var, size);
    } else {
        calculate_complex_array_size(
            bin,
            array,
            array_ty,
            elem_ty,
            arg_no,
            dims,
            dimension - 1,
            size_var,
            func_value,
            ns,
            indexes,
        );
    }
    finish_array_loop(bin, &for_loop);
}

/// Provide generic encoding for any given `arg` into `buffer`.
pub(crate) fn encode_into_buffer<'a>(
    arg: BasicValueEnum<'a>,
    arg_ty: &Type,
    buffer: PointerValue<'a>,
    offset: IntValue<'a>,
    arg_no: usize,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    match arg_ty {
        Type::Contract(_) | Type::Address => {
            encode_address(arg, buffer, &mut offset.clone(), bin);
            bin.context.i64_type().const_int(4, false)
        }
        Type::Bool | Type::Uint(32) | Type::Enum(_) => {
            encode_uint(arg, buffer, offset, bin);
            bin.context.i64_type().const_int(1, false)
        }

        Type::String => encode_bytes(arg, buffer, &mut offset.clone(), bin, func_value, ns),

        Type::Struct(struct_no) => encode_struct(
            arg_no,
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
                arg_no,
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
            arg_no,
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
                    arg_no,
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
            encode_into_buffer(loaded, r, buffer, offset, arg_no, bin, func_value, ns)
        }
        Type::StorageRef(r) => {
            let loaded = storage_load(bin, r, &mut arg.clone(), func_value, ns);
            encode_into_buffer(loaded, r, buffer, offset, arg_no, bin, func_value, ns)
        }
        Type::UserType(_) | Type::Unresolved | Type::Unreachable => {
            unreachable!("Type should not exist in irgen")
        }
        Type::Void | Type::BufferPointer | Type::Mapping(..) | Type::Function { .. } => {
            unreachable!("This type cannot be encoded")
        }
        _ => unreachable!("Type should not exist in irgen"),
    }
}

/// Write whatever is inside the given `arg` into `buffer` without any
/// modification.
fn encode_uint<'a>(
    arg: BasicValueEnum<'a>,
    buffer: PointerValue<'a>,
    offset: IntValue<'a>,
    bin: &Binary<'a>,
) {
    let start = unsafe {
        bin.builder
            .build_gep(bin.context.i64_type(), buffer, &[offset], "start")
    };
    bin.builder.build_store(start, arg);
}

/// Encode `address` into `buffer` as an [4 * i64] array.
fn encode_address<'a>(
    address: BasicValueEnum<'a>,
    buffer: PointerValue<'a>,
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
) {
    for i in 0..4 {
        let value = bin
            .builder
            .build_extract_value(address.into_array_value(), i, "");
        encode_uint(value.unwrap(), buffer, *offset, bin);
        *offset =
            bin.builder
                .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
    }
}

/// Encode `string` into `buffer` as bytes.
fn encode_bytes<'a>(
    string_value: BasicValueEnum<'a>,
    buffer: PointerValue<'a>,
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let len = bin.vector_len(string_value);
    // First, we must save the length of the string
    encode_uint(len.into(), buffer, *offset, bin);
    *offset = bin.builder.build_int_add(
        *offset,
        bin.context.i64_type().const_int(1, false),
        "offset",
    );
    let data = bin.vector_data(string_value);

    encode_dynamic_array_loop(
        data,
        offset,
        len,
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
    elem_ty: &Type,
    buffer: PointerValue<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    let loop_body = bin.context.append_basic_block(func_value, "loop_body");
    let loop_end = bin.context.append_basic_block(func_value, "loop_end");

    // Initialize index before the loop
    let index_ptr = bin
        .builder
        .build_alloca(bin.context.i64_type(), "index_ptr");
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
            bin.llvm_type(elem_ty, ns),
            array,
            &[index.into_int_value()],
            "element",
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

    encode_uint(elem, buffer, *offset, bin);

    *offset = bin.builder.build_int_add(
        *offset,
        bin.context.i64_type().const_int(1, false),
        "offset",
    );

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
    arg_no: usize,
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

    let mut advance = encode_into_buffer(
        loaded, &first_ty, buffer, *offset, arg_no, bin, func_value, ns,
    );
    let mut runtime_size = advance.clone();
    for i in 1..qty {
        let ith_type = ns.structs[struct_no].fields[i].ty.clone();
        *offset = bin.builder.build_int_add(*offset, advance, "");
        let loaded = load_struct_member(bin, struct_ty, &ith_type, struct_value, i, ns);
        // After fetching the struct member, we can encode it
        advance = encode_into_buffer(
            loaded, &ith_type, buffer, *offset, arg_no, bin, func_value, ns,
        );
        runtime_size = bin.builder.build_int_add(runtime_size, advance, "");
    }

    runtime_size
}

/// Encode `array` into `buffer` as an array.
fn encode_array<'a>(
    bin: &Binary<'a>,
    array: BasicValueEnum<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    arg_no: usize,
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
            fixed_array_encode(array, buffer, offset, elem_ty, &dims, bin, ns)
        } else {
            // If the array is dynamic, we must save its size before all elements
            let length = bin.vector_len(array);
            encode_uint(length.into(), buffer, *offset, bin);
            *offset =
                bin.builder
                    .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
            encode_dynamic_array_loop(
                array.into_pointer_value(),
                offset,
                length,
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
        bin,
        array,
        buffer,
        array_ty,
        elem_ty,
        arg_no,
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

    bin.builder
        .build_int_sub(offset_var.into_int_value(), *offset, "")
}

/// Encode `array` into `buffer` as a complex array.
/// This function indexes an array from its outer dimension to its inner one.
///
/// Note: In the default implementation, `encode_array` decides when to use this
/// method for you.
fn encode_complex_array<'a>(
    bin: &Binary<'a>,
    array: BasicValueEnum<'a>,
    buffer: PointerValue<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    arg_no: usize,
    dims: &[ArrayLength],
    dimension: usize,
    offset_var: PointerValue<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
    indexes: &mut Vec<IntValue<'a>>,
) {
    // If this dimension is dynamic, we must save its length before all elements
    if dims[dimension] == ArrayLength::Dynamic {
        let sub_array = index_array(
            bin,
            &mut array.clone(),
            &mut array_ty.clone(),
            elem_ty,
            dims,
            indexes,
            func_value,
            ns,
        );

        let size = bin.vector_len(sub_array);

        let offset_value = bin
            .builder
            .build_load(bin.context.i64_type(), offset_var, "");

        encode_uint(size.into(), buffer, offset_value.into_int_value(), bin);

        let offset_value = bin.builder.build_int_add(
            offset_value.into_int_value(),
            bin.context.i64_type().const_int(1, false),
            "",
        );
        bin.builder.build_store(offset_var, offset_value);
    }
    let for_loop = set_array_loop(
        bin, array, array_ty, elem_ty, dims, dimension, indexes, func_value, ns,
    );
    bin.builder.position_at_end(for_loop.body_block);
    if 0 == dimension {
        // If we are indexing the last dimension, we have an element, so we can encode
        // it.
        let deref = index_array(
            bin,
            &mut array.clone(),
            &mut array_ty.clone(),
            elem_ty,
            dims,
            indexes,
            func_value,
            ns,
        );
        let offset_value = bin
            .builder
            .build_load(bin.context.i64_type(), offset_var, "");
        let elem_size = encode_into_buffer(
            deref,
            elem_ty,
            buffer,
            offset_value.into_int_value(),
            arg_no,
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
            bin,
            array,
            buffer,
            array_ty,
            elem_ty,
            arg_no,
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
                bin.context.i64_type(),
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

        encode_uint(elem, buffer, *offset, bin);

        *offset = bin.builder.build_int_add(
            *offset,
            bin.context.i64_type().const_int(1, false),
            "offset",
        );
    }

    let size = bin.context.i64_type().const_int(size as u64, false);

    size
}
