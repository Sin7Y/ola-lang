use std::ops::MulAssign;

use inkwell::{
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    AddressSpace, IntPredicate,
};

use num_bigint::BigInt;
use num_traits::{One, ToPrimitive};

use crate::{
    irgen::binary::Binary,
    sema::ast::{ArrayLength, Namespace, Type},
};

use super::{
    allow_memcpy, buffer_validator::BufferValidator, calculate_array_size, finish_array_loop,
    index_array, set_array_loop,
};

/// Read a value of type 'ty' from the buffer at a given offset. Returns an
/// expression containing the read value and the number of bytes read.
pub(crate) fn read_from_buffer<'a>(
    buffer: IntValue<'a>,
    offset: IntValue<'a>,
    bin: &Binary<'a>,
    ty: &Type,
    validator: &mut BufferValidator<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    match ty {
        Type::Uint(32) | Type::Bool | Type::Enum(_) => {
            let size = bin.context.i64_type().const_int(1, false);
            validator.validate_offset_plus_size(bin, offset, size, func_value);
            let read_value = decode_uint(buffer, offset, bin);
            (read_value, size)
        }

        Type::Address | Type::Contract(_) => {
            let read_bytes = ty.memory_size_of(ns);

            let size = bin
                .context
                .i64_type()
                .const_int(read_bytes.to_u64().unwrap(), false);
            validator.validate_offset_plus_size(bin, offset, size, func_value);

            let read_value = decode_address(buffer, &mut offset.clone(), bin);
            (read_value, size)
        }

        Type::String => {
            // String and Dynamic bytes are encoded as size + elements
            let array_length = decode_uint(buffer, offset, bin);
            let total_size = bin.builder.build_int_add(
                bin.context.i64_type().const_int(1, false),
                array_length.into_int_value(),
                "",
            );
            let array_start =
                bin.builder
                    .build_int_add(offset, bin.context.i64_type().const_int(1, false), "");

            validator.validate_offset(bin, array_start, func_value);

            let total_size_offset = bin.builder.build_int_add(offset, total_size, "");
            validator.validate_offset(bin, total_size_offset, func_value);

            let allocated_array = bin.vector_new(
                func_value,
                ty,
                array_length.into_int_value(),
                None,
                false,
                ns,
            );
            let array_data = bin.vector_data(allocated_array.into());
            decode_dynamic_array_loop(
                buffer,
                &mut array_start.clone(),
                array_length.into_int_value(),
                &Type::Uint(32),
                array_data,
                bin,
                validator,
                func_value,
                ns,
            );
            (allocated_array.into(), total_size)
        }

        Type::UserType(type_no) => {
            let usr_type = ns.user_types[*type_no].ty.clone();
            read_from_buffer(buffer, offset, bin, &usr_type, validator, func_value, ns)
        }

        Type::Array(elem_ty, dims) => decode_array(
            buffer,
            &mut offset.clone(),
            ty,
            elem_ty,
            dims,
            validator,
            bin,
            func_value,
            ns,
        ),

        Type::Slice(elem_ty) => {
            let dims = vec![ArrayLength::Dynamic];
            decode_array(
                buffer,
                &mut offset.clone(),
                ty,
                elem_ty,
                &dims,
                validator,
                bin,
                func_value,
                ns,
            )
        }

        Type::Struct(no) => decode_struct(
            buffer,
            &mut offset.clone(),
            ty,
            *no,
            validator,
            bin,
            func_value,
            ns,
        ),

        _ => unreachable!("Type should not appear on an encoded buffer"),
    }
}

fn decode_uint<'a>(
    buffer: IntValue<'a>,
    offset: IntValue<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    bin.builder
        .build_call(
            bin.module.get_function("tape_load").unwrap(),
            &[buffer.into(), offset.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .unwrap()
}

fn decode_address<'a>(
    buffer: IntValue<'a>,
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let address = bin.context.i64_type().array_type(4).get_undef();

    for i in 0..4 {
        let value = decode_uint(buffer, *offset, bin);
        bin.builder.build_insert_value(address, value, i, "");
        *offset =
            bin.builder
                .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
    }
    address.into()
}

fn decode_array<'a>(
    buffer: IntValue<'a>,
    offset: &mut IntValue<'a>,
    array_ty: &Type,
    elem_ty: &Type,
    dims: &[ArrayLength],
    validator: &mut BufferValidator<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    // Checks if we can memcpy the elements from the buffer directly to the
    // allocated array
    if allow_memcpy(array_ty, ns) {
        // Calculate number of elements
        let (array_pointer, array_size) = if matches!(dims.last(), Some(&ArrayLength::Fixed(_))) {
            let dims = dims
                .iter()
                .map(|d| match d {
                    ArrayLength::Fixed(d) => d.to_u32().unwrap(),
                    _ => unreachable!(),
                })
                .collect::<Vec<_>>();
            fixed_array_decode(
                buffer,
                &mut offset.clone(),
                array_ty,
                elem_ty,
                &dims,
                bin,
                func_value,
                ns,
            )
        } else {
            let array_length = decode_uint(buffer, *offset, bin).into_int_value();
            let total_size = bin.builder.build_int_add(
                bin.context.i64_type().const_int(1, false),
                array_length,
                "",
            );
            let array_start =
                bin.builder
                    .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
            validator.validate_offset(bin, array_start, func_value);
            let allocated_array =
                bin.vector_new(func_value, array_ty, array_length, None, false, ns);

            let array_data = bin.vector_data(allocated_array.into());
            let array_bytes_size = calculate_array_size(bin, array_length, elem_ty, ns);
            decode_dynamic_array_loop(
                buffer,
                &mut array_start.clone(),
                array_length,
                elem_ty,
                array_data,
                bin,
                validator,
                func_value,
                ns,
            );
            validator.validate_offset_plus_size(bin, *offset, array_bytes_size, func_value);
            (allocated_array.into(), total_size)
        };

        validator.validate_offset_plus_size(bin, *offset, array_size, func_value);
        (array_pointer, array_size)
    } else {
        let mut indexes: Vec<IntValue<'a>> = Vec::new();
        let array_var = bin
            .context
            .i64_type()
            .ptr_type(AddressSpace::default())
            .const_null();
        // The function decode_complex_array assumes that, if the dimension is fixed,
        // there is no need to allocate an array
        if matches!(dims.last(), Some(ArrayLength::Fixed(_))) {
            let dims = dims
                .iter()
                .map(|d| match d {
                    ArrayLength::Fixed(d) => d.to_u32().unwrap(),
                    _ => unreachable!(),
                })
                .collect::<Vec<_>>();

            let values = vec![
                bin.context.i64_type().const_zero();
                array_ty.array_length().unwrap().to_usize().unwrap()
            ];
            let array_literal = alloca_array_literal(bin, array_ty, &dims, values, func_value, ns);
            bin.builder.build_store(array_var, array_literal);
        }
        let offset_var = bin
            .builder
            .build_alloca(bin.context.i64_type(), "offset_var");
        bin.builder.build_store(offset_var, offset.clone());
        decode_complex_array(
            bin,
            array_var,
            buffer,
            offset_var,
            dims.len() - 1,
            array_ty,
            elem_ty,
            dims,
            validator,
            func_value,
            ns,
            &mut indexes,
        );
        let array = bin.builder.build_load(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            array_var,
            "",
        );
        let offset_value = bin
            .builder
            .build_load(bin.context.i64_type(), offset_var, "");
        let size = bin
            .builder
            .build_int_sub(offset_value.into_int_value(), *offset, "");
        (array, size)
    }
}

fn decode_struct<'a>(
    buffer: IntValue<'a>,
    offset: &mut IntValue<'a>,
    ty: &Type,
    struct_no: usize,
    validator: &mut BufferValidator<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    let struct_tys = ns.structs[struct_no]
        .fields
        .iter()
        .map(|item| item.ty.clone())
        .collect::<Vec<Type>>();

    // If it was not possible to validate the struct beforehand, we validate each
    // field during recursive calls to 'read_from_buffer'
    let mut struct_validator = validator.create_sub_validator(struct_tys.clone());

    let qty = ns.structs[struct_no].fields.len();
    if validator.validation_necessary() {
        struct_validator.initialize_validation(bin, *offset, func_value, ns);
    }

    let (mut read_expr, mut advance) = read_from_buffer(
        buffer,
        *offset,
        bin,
        &struct_tys[0].clone(),
        &mut struct_validator,
        func_value,
        ns,
    );
    let mut runtime_size = advance;

    let mut read_items: Vec<BasicValueEnum<'_>> = vec![];
    read_items.push(read_expr);
    for i in 1..qty {
        struct_validator.set_argument_number(i);
        struct_validator.validate_buffer(bin, *offset, func_value, ns);
        *offset = bin.builder.build_int_add(*offset, advance, "");
        (read_expr, advance) = read_from_buffer(
            buffer,
            *offset,
            bin,
            &struct_tys[i].clone(),
            &mut struct_validator,
            func_value,
            ns,
        );
        read_items.push(read_expr);
        runtime_size = bin.builder.build_int_add(runtime_size, advance, "");
    }

    let struct_var = struct_literal_copy(ty, read_items, bin, func_value, ns);
    (struct_var, runtime_size)
}

pub fn fixed_array_decode<'a>(
    buffer: IntValue<'a>,
    offset: &mut IntValue<'a>,
    ty: &Type,
    elem_ty: &Type,
    dimensions: &Vec<u32>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicValueEnum<'a>, IntValue<'a>) {
    let array_ty = bin.llvm_type(ty, ns);
    let array_alloca = bin.build_alloca(func_value, array_ty, "array_literal");
    let size = dimensions.iter().product();

    for i in 0..size {
        let mut ind = vec![bin.context.i64_type().const_zero()];

        let mut e = i;

        // Mapping one-dimensional array indices to multi-dimensional array indices.
        for d in dimensions {
            ind.insert(1, bin.context.i64_type().const_int((e % *d).into(), false));

            e /= *d;
        }

        let elemptr = unsafe {
            bin.builder
                .build_gep(array_ty, array_alloca, &ind, &format!("elemptr{i}"))
        };

        let elem = decode_uint(buffer, *offset, bin);

        *offset = bin.builder.build_int_add(
            *offset,
            bin.context.i64_type().const_int(1, false),
            "offset",
        );

        let elem = if elem_ty.is_fixed_reference_type() {
            bin.builder.build_load(
                bin.llvm_type(elem_ty, ns),
                elem.into_pointer_value(),
                "elem",
            )
        } else {
            elem
        };

        bin.builder.build_store(elemptr, elem);
    }

    let size = bin.context.i64_type().const_int(size as u64, false);

    (array_alloca.into(), size)
}

pub fn struct_literal_copy<'a>(
    ty: &Type,
    values: Vec<BasicValueEnum<'a>>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let struct_ty = bin.llvm_type(ty, ns);

    let struct_alloca = bin.build_alloca(func_value, struct_ty, "struct_alloca");

    for (i, elem) in values.iter().enumerate() {
        let elemptr = bin
            .builder
            .build_struct_gep(struct_ty, struct_alloca, i as u32, "struct member")
            .unwrap();
        bin.builder.build_store(elemptr, *elem);
    }

    struct_alloca.into()
}

/// Currently, we can only handle one-dimensional arrays.
/// The situation of multi-dimensional arrays has not been processed yet.
pub(crate) fn decode_dynamic_array_loop<'a>(
    buffer: IntValue<'a>,
    offset: &mut IntValue<'a>,
    length: IntValue<'a>,
    elem_ty: &Type,
    dest: PointerValue<'a>,
    bin: &Binary<'a>,
    validator: &mut BufferValidator<'a>,
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
            dest,
            &[index.into_int_value()],
            "element",
        )
    };

    let (elem, read_size) =
        read_from_buffer(buffer, *offset, bin, elem_ty, validator, func_value, ns);

    *offset = bin.builder.build_int_add(*offset, read_size, "offset");

    let elem = if elem_ty.is_fixed_reference_type() {
        bin.builder.build_load(
            bin.llvm_type(elem_ty, ns),
            elem.into_pointer_value(),
            "elem",
        )
    } else {
        elem
    };

    bin.builder.build_store(elem_ptr, elem);

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

/// Decodes a complex array from a borsh encoded buffer
/// Complex arrays are either dynamic arrays or arrays of dynamic types, like
/// structs. If this is an array of structs, whose representation in memory is
/// padded, the array is also complex, because it cannot be memcpy'ed
fn decode_complex_array<'a>(
    bin: &Binary<'a>,
    array_var: PointerValue<'a>,
    buffer: IntValue<'a>,
    offset_var: PointerValue<'a>,
    dimension: usize,
    array_ty: &Type,
    elem_ty: &Type,
    dims: &[ArrayLength],
    validator: &mut BufferValidator<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
    indexes: &mut Vec<IntValue<'a>>,
) {
    let offset = bin
        .builder
        .build_load(bin.context.i64_type(), offset_var, "")
        .into_int_value();
    // If we have a 'int[3][4][] vec', we can only validate the buffer after we have
    // allocated the outer dimension, i.e., we are about to read a 'int[3][4]' item.
    // Arrays whose elements are dynamic cannot be verified.
    if validator.validation_necessary()
        && !dims[0..(dimension + 1)]
            .iter()
            .any(|d| *d == ArrayLength::Dynamic)
        && !elem_ty.is_dynamic(ns)
    {
        let mut elems = BigInt::one();
        for item in &dims[0..(dimension + 1)] {
            elems.mul_assign(item.array_length().unwrap());
        }
        elems.mul_assign(elem_ty.memory_size_of(ns));
        let elems_size = bin
            .context
            .i64_type()
            .const_int(elems.to_u64().unwrap(), false);
        validator.validate_offset_plus_size(bin, offset, elems_size, func_value);
        validator.validate_array();
    }

    // Dynamic dimensions mean that the subarray we are processing must be allocated
    // in memory.
    if dims[dimension] == ArrayLength::Dynamic {
        let length = decode_uint(buffer, offset, bin);

        let array_start =
            bin.builder
                .build_int_add(offset, bin.context.i64_type().const_int(1, false), "");
        validator.validate_offset(bin, array_start.clone(), func_value);

        bin.builder.build_store(offset_var, array_start);

        // let new_ty = Type::Array(Box::new(elem_ty.clone()), dims[0..(dimension +
        // 1)].to_vec());
        let allocated_array = bin.vector_new(
            func_value,
            array_ty,
            length.into_int_value(),
            None,
            false,
            ns,
        );

        if indexes.is_empty() {
            bin.builder.build_store(array_var, allocated_array);
        } else {
            let array = bin.builder.build_load(
                bin.context.i64_type().ptr_type(AddressSpace::default()),
                array_var,
                "",
            );
            let sub_arr = index_array(
                bin,
                &mut array.clone(),
                &mut array_ty.clone(),
                dims,
                indexes,
                func_value,
                ns,
            );
            bin.builder.build_store(array_var, sub_arr);
        }
    }

    let for_loop = set_array_loop(
        bin,
        array_var.into(),
        array_ty,
        dims,
        dimension,
        indexes,
        func_value,
        ns,
    );
    bin.builder.position_at_end(for_loop.body_block);

    if 0 == dimension {
        let (read_value, advance) =
            read_from_buffer(buffer, offset, bin, elem_ty, validator, func_value, ns);
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
        );

        bin.builder
            .build_store(ptr.into_pointer_value(), read_value);

        let offset = bin.builder.build_int_add(offset, advance, "");

        bin.builder.build_store(offset_var, offset);
    } else {
        decode_complex_array(
            bin,
            array_var,
            buffer,
            offset_var,
            dimension - 1,
            array_ty,
            elem_ty,
            dims,
            validator,
            func_value,
            ns,
            indexes,
        );
    }

    finish_array_loop(bin, &for_loop);
}

pub fn alloca_array_literal<'a>(
    bin: &Binary<'a>,
    array_ty: &Type,
    dimensions: &Vec<u32>,
    values: Vec<IntValue<'a>>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> PointerValue<'a> {
    let array_ty = bin.llvm_type(array_ty, ns);
    let array_alloca = bin.build_alloca(func_value, array_ty, "array_literal");

    for (i, value) in values.iter().enumerate() {
        let mut ind = vec![bin.context.i64_type().const_zero()];

        let mut e = i as u32;

        // Mapping one-dimensional array indices to multi-dimensional array indices.
        for d in dimensions {
            ind.insert(1, bin.context.i64_type().const_int((e % *d).into(), false));

            e /= *d;
        }

        let elemptr = unsafe {
            bin.builder
                .build_gep(array_ty, array_alloca, &ind, &format!("elemptr{i}"))
        };

        bin.builder.build_store(elemptr, value.clone());
    }

    array_alloca.into()
}
