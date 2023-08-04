use std::ops::{AddAssign, Sub};

use inkwell::{
    basic_block::BasicBlock,
    values::{BasicValueEnum, FunctionValue, IntValue, PointerValue},
    IntPredicate,
};
use num_bigint::BigInt;
use num_integer::Integer;
use num_traits::{ToPrimitive, Zero};

use crate::sema::ast::{ArrayLength, Namespace, Type};

use self::{
    buffer_validator::BufferValidator,
    decode::read_from_buffer,
    encode::{calculate_size_args, encode_into_buffer},
};

use super::{binary::Binary, expression::array_subscript};

mod buffer_validator;

mod decode;

mod encode;

/// Insert encoding instructions into the `cfg` for any `Expression` in `args`.
/// Returns a pointer to the encoded data and the size as a 32bit integer.
pub(super) fn abi_encode<'a>(
    bin: &Binary<'a>,
    args: Vec<BasicValueEnum<'a>>,
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    // let size = calculate_size_args(bin, &args, types, func_value, ns);

    let mut offset = bin.context.i64_type().const_zero();

    for (arg_no, item) in args.iter().enumerate() {
        let advance = encode_into_buffer(
            item.clone(),
            &types[arg_no],
            offset.clone(),
            bin,
            func_value,
            ns,
        );
        offset = bin.builder.build_int_add(offset, advance, "");
    }
}

/// Insert decoding routines into the `cfg` for the `Expression`s in `args`.
/// Returns a vector containing the encoded data.
pub(super) fn abi_decode<'a>(
    bin: &Binary<'a>,
    input_length: IntValue<'a>,
    input: IntValue<'a>,
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> Vec<BasicValueEnum<'a>> {
    let mut validator = BufferValidator::new(input_length, types.clone());

    let mut read_items = vec![];
    let mut offset = bin.context.i64_type().const_zero();

    validator.initialize_validation(bin, offset, func_value, ns);

    for (item_no, item) in types.iter().enumerate() {
        validator.set_argument_number(item_no);
        validator.validate_buffer(bin, offset, func_value, ns);
        let (read_item, advance) =
            read_from_buffer(input, offset, bin, item, &mut validator, func_value, ns);
        read_items.push(read_item);
        offset = bin.builder.build_int_add(offset, advance, "");
    }

    validator.validate_all_bytes_read(bin, offset, func_value);

    read_items
}

/// Checks if struct contains only primitive types and returns its memory
/// non-padded size
pub fn calculate_struct_non_padded_size(struct_no: usize, ns: &Namespace) -> Option<BigInt> {
    let mut size = BigInt::from(0u8);
    for field in &ns.structs[struct_no].fields {
        let ty = field.ty.clone().unwrap_user_type(ns);
        if !ty.is_primitive() {
            // If a struct contains a non-primitive type, we cannot calculate its
            // size during compile time
            if let Type::Struct(no) = &field.ty {
                if let Some(struct_size) = calculate_struct_non_padded_size(*no, ns) {
                    size.add_assign(struct_size);
                    continue;
                }
            }
            return None;
        } else {
            size.add_assign(ty.memory_size_of(ns));
        }
    }

    Some(size)
}

/// Calculate a struct size in memory considering the padding, if necessary
pub fn struct_padded_size(struct_no: usize, ns: &Namespace) -> BigInt {
    let mut total = BigInt::zero();
    for item in &ns.structs[struct_no].fields {
        let ty_align = item.ty.struct_elem_alignment(ns);
        let remainder = total.mod_floor(&ty_align);
        if !remainder.is_zero() {
            let padding = ty_align.sub(remainder);
            total.add_assign(padding);
        }
        total.add_assign(item.ty.memory_size_of(ns));
    }
    total
}

pub(crate) fn index_array<'a>(
    bin: &Binary<'a>,
    arr: &mut BasicValueEnum<'a>,
    ty: &mut Type,
    dims: &[ArrayLength],
    indexes: &[IntValue<'a>],
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let elem_ty = ty.elem_ty();
    let begin = dims.len() - indexes.len();

    for i in (begin..dims.len()).rev() {
        // If we are indexing the last dimension, the type should be that of the array
        // element.
        let local_ty = if i == 0 {
            elem_ty.clone()
        } else {
            Type::Array(Box::new(elem_ty.clone()), dims[0..i].to_vec())
        };

        *arr = array_subscript(
            ty,
            arr.clone(),
            indexes[dims.len() - i - 1].into(),
            bin,
            func_value,
            ns,
        );

        // We should only load if the dimension is dynamic.
        if i > 0 && dims[i - 1] == ArrayLength::Dynamic {
            *arr = bin.builder.build_load(
                bin.llvm_type(&local_ty.clone(), ns),
                arr.into_pointer_value(),
                "arr",
            );
        }

        *ty = local_ty;
    }

    *arr
}

/// This struct manages for-loops created when iterating over arrays
struct ForLoop<'a> {
    pub cond_block: BasicBlock<'a>,
    pub next_block: BasicBlock<'a>,
    pub body_block: BasicBlock<'a>,
    pub end_block: BasicBlock<'a>,
    pub index: PointerValue<'a>,
}

/// Set up the loop to iterate over an array
fn set_array_loop<'a>(
    bin: &Binary<'a>,
    arr: BasicValueEnum<'a>,
    ty: &Type,
    dims: &[ArrayLength],
    dimension: usize,
    indexes: &mut Vec<IntValue<'a>>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> ForLoop<'a> {
    // Initialize index before the loop
    let index_ptr = bin
        .builder
        .build_alloca(bin.context.i64_type(), "index_ptr");
    bin.builder
        .build_store(index_ptr, bin.context.i64_type().const_zero());

    let index_temp = bin
        .builder
        .build_load(bin.context.i64_type(), index_ptr, "index")
        .into_int_value();

    indexes.push(index_temp);
    let cond_block = bin.context.append_basic_block(func_value, "cond");
    let next_block = bin.context.append_basic_block(func_value, "next");
    let body_block = bin.context.append_basic_block(func_value, "body");
    let end_block = bin.context.append_basic_block(func_value, "end_for");

    bin.builder.build_unconditional_branch(cond_block);
    bin.builder.position_at_end(cond_block);

    // Get the array length at dimension 'index'
    let bound = if let ArrayLength::Fixed(dim) = &dims[dimension] {
        bin.context
            .i64_type()
            .const_int(dim.to_u64().unwrap(), false)
    } else {
        let sub_array = index_array(
            bin,
            &mut arr.clone(),
            &mut ty.clone(),
            dims,
            &indexes[..indexes.len() - 1],
            func_value,
            ns,
        );

        bin.vector_len(sub_array)
    };

    let cond = bin
        .builder
        .build_int_compare(IntPredicate::ULT, index_temp, bound, "");

    bin.builder
        .build_conditional_branch(cond, body_block, end_block);

    ForLoop {
        cond_block,
        next_block,
        body_block,
        end_block,
        index: index_ptr,
    }
}

/// Closes the for-loop when iterating over an array
fn finish_array_loop<'a>(bin: &Binary<'a>, for_loop: &ForLoop) {
    bin.builder.build_unconditional_branch(for_loop.next_block);
    bin.builder.position_at_end(for_loop.next_block);

    let index_var = bin.builder.build_int_add(
        bin.builder
            .build_load(bin.context.i64_type(), for_loop.index, "index")
            .into_int_value(),
        bin.context.i64_type().const_int(1, false),
        "",
    );
    bin.builder.build_store(for_loop.index, index_var);
    bin.builder.build_unconditional_branch(for_loop.cond_block);

    bin.builder.position_at_end(for_loop.end_block);
}

/// Check if we can MemCpy a type to/from a buffer
pub fn allow_memcpy(ty: &Type, ns: &Namespace) -> bool {
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

/// Calculate the num of element a dynamic array, whose dynamic dimension is
/// the outer. It needs the variable saving the array's length.
pub fn calculate_array_size<'a>(
    bin: &Binary<'a>,
    length_var: IntValue<'a>,
    elem_ty: &Type,
    ns: &Namespace,
) -> IntValue<'a> {
    let elem_size = elem_ty.memory_size_of(ns);
    let elem_size = bin
        .context
        .i64_type()
        .const_int(elem_size.to_u64().unwrap(), false);
    bin.builder
        .build_int_mul(length_var, elem_size, "array_elem_num")
}
