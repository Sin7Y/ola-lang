use std::ops::{AddAssign, Sub};

use inkwell::{
    values::{BasicValue, BasicValueEnum, FunctionValue, IntValue, PointerValue},
    IntPredicate,
};
use num_bigint::BigInt;
use num_integer::Integer;
use num_traits::{ToPrimitive, Zero};

use crate::{
    irgen::binary::Binary,
    sema::ast::{ArrayLength, Namespace, Type},
};

use super::buffer_validator::BufferValidator;

/// Read a value of type 'ty' from the buffer at a given offset. Returns an
/// expression containing the read value and the number of bytes read.
pub fn read_from_buffer<'a>(
    buffer: PointerValue<'a>,
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

            let allocated_array =
                bin.vector_new(func_value, array_length.into_int_value(), None, false);
            let array_data = bin.vector_data(allocated_array.into());
            set_dynamic_array_loop(
                buffer,
                array_start,
                array_length.into_int_value(),
                &Type::Uint(32),
                array_data,
                bin,
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
    buffer: PointerValue<'a>,
    offset: IntValue<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let start = unsafe {
        bin.builder
            .build_gep(bin.context.i64_type(), buffer, &[offset], "start")
    };

    bin.builder
        .build_load(bin.context.i64_type(), start, "value")
}

fn decode_address<'a>(
    buffer: PointerValue<'a>,
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
    buffer: PointerValue<'a>,
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
            fixed_array_copy(
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
            let array_length = decode_uint(buffer, *offset, bin);
            let total_size = bin.builder.build_int_add(
                bin.context.i64_type().const_int(1, false),
                array_length.into_int_value(),
                "",
            );
            let array_start =
                bin.builder
                    .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
            validator.validate_offset(bin, array_start, func_value);
            let allocated_array =
                bin.vector_new(func_value, array_length.into_int_value(), None, false);

            let array_data = bin.vector_data(allocated_array.into());
            set_dynamic_array_loop(
                buffer,
                array_start,
                array_length.into_int_value(),
                elem_ty,
                array_data,
                bin,
                func_value,
                ns,
            );
            (allocated_array.into(), total_size)
        };

        validator.validate_offset_plus_size(bin, *offset, array_size, func_value);
        (array_pointer, array_size)
    } else {
        unimplemented!("decode complex array not implemented.")
    }
}

fn decode_struct<'a>(
    buffer: PointerValue<'a>,
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

/// Check if we can MemCpy a type to/from a buffer
fn allow_memcpy(ty: &Type, ns: &Namespace) -> bool {
    match ty {
        Type::Struct(no) => {
            if let Some(no_padded_size) = calculate_struct_non_padded_size(*no, ns) {
                let padded_size = struct_padded_size(*no, ns);
                // This remainder tells us if padding is needed between the elements of an array
                let remainder = padded_size.mod_floor(&ty.struct_elem_alignment(ns));
                let ty_allowed = ns.structs[*no]
                    .fields
                    .iter()
                    .all(|f| allow_memcpy(&f.ty, ns));
                return no_padded_size == padded_size && remainder.is_zero() && ty_allowed;
            }

            false
        }
        Type::Array(t, dims) if ty.is_dynamic(ns) => dims.len() == 1 && allow_memcpy(t, ns),
        // If the array is not dynamic, we mempcy if its elements allow it
        Type::Array(t, _) => allow_memcpy(t, ns),
        Type::UserType(t) => allow_memcpy(&ns.user_types[*t].ty, ns),
        _ => ty.is_primitive(),
    }
}

pub fn fixed_array_copy<'a>(
    buffer: PointerValue<'a>,
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

        //

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
pub fn set_dynamic_array_loop<'a>(
    buffer: PointerValue<'a>,
    offset: IntValue<'a>,
    length: IntValue<'a>,
    elem_ty: &Type,
    dest: PointerValue<'a>,
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
    bin.builder.build_store(index_ptr, offset);

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

    let elem = decode_uint(buffer, index.into_int_value(), bin);

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

    let cond = bin.builder.build_int_compare(
        IntPredicate::ULT,
        next_index,
        bin.builder
            .build_int_add(offset, length, "array_end")
            .as_basic_value_enum()
            .into_int_value(),
        "index_cond",
    );

    bin.builder
        .build_conditional_branch(cond, loop_body, loop_end);

    bin.builder.position_at_end(loop_end);
}
