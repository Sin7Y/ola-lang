use std::ops::{AddAssign, Sub};

use inkwell::{
    basic_block::BasicBlock,
    values::{BasicValue, BasicValueEnum, FunctionValue, IntValue, PointerValue},
    IntPredicate,
};
use num_bigint::BigInt;
use num_integer::Integer;
use num_traits::{ToPrimitive, Zero};
use ola_parser::program;

use crate::{
    codegen::core::ir::function::basic_block::BasicBlock,
    sema::ast::{ArrayLength, Namespace, Type},
};

use self::{buffer_validator::BufferValidator, decode::read_from_buffer};

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
) -> (Expression, Expression) {
    let size = calculate_size_args(bin, &args, ns, vartab, cfg);
    let encoded_bytes = vartab.temp_name("abi_encoded", &Type::DynamicBytes);
    let expr = Expression::AllocDynamicBytes {
        loc: *loc,
        ty: Type::DynamicBytes,
        size: size.clone().into(),
        initializer: None,
    };
    cfg.add(
        vartab,
        Instr::Set {
            loc: *loc,
            res: encoded_bytes,
            expr,
        },
    );

    let mut offset = Expression::NumberLiteral {
        loc: *loc,
        ty: Uint(32),
        value: BigInt::zero(),
    };
    let buffer = Expression::Variable {
        loc: *loc,
        ty: Type::DynamicBytes,
        var_no: encoded_bytes,
    };
    for (arg_no, item) in args.iter().enumerate() {
        let advance = encoder.encode(item, &buffer, &offset, arg_no, ns, vartab, cfg);
        offset = Expression::Add {
            loc: *loc,
            ty: Uint(32),
            overflowing: false,
            left: offset.into(),
            right: advance.into(),
        };
    }
    (buffer, size)
}

/// Insert decoding routines into the `cfg` for the `Expression`s in `args`.
/// Returns a vector containing the encoded data.
pub(super) fn abi_decode<'a>(
    bin: &Binary<'a>,
    input_length: IntValue<'a>,
    input: PointerValue<'a>,
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

fn index_array<'a>(
    bin: &Binary<'a>,
    arr: &mut BasicValueEnum<'a>,
    ty: &mut Type,
    elem_ty: &Type,
    dims: &[ArrayLength],
    indexes: &[IntValue<'a>],
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> BasicValueEnum<'a> {
    let begin = dims.len() - indexes.len();

    for i in (begin..dims.len()).rev() {
        // If we are indexing the last dimension, the type should be that of the array
        // element.
        let local_ty = if i == 0 {
            elem_ty.clone()
        } else {
            Type::Array(Box::new(elem_ty.clone()), dims[0..i].to_vec())
        };

        let arr = array_subscript(
            &program::Loc::IRgen,
            ty,
            arr.clone(),
            indexes[dims.len() - i - 1].into(),
            bin,
            func_value,
            ns,
        );

        // We should only load if the dimension is dynamic.
        if i > 0 && dims[i - 1] == ArrayLength::Dynamic {
            bin.builder
                .build_load(bin.llvm_type(ty, ns), arr.into_pointer_value(), "arr");
        }

        *ty = local_ty;
    }

    arr
}

/// This struct manages for-loops created when iterating over arrays
struct ForLoop<'a> {
    pub cond_block: BasicBlock<'a>,
    pub next_block: BasicBlock<'a>,
    pub body_block: BasicBlock<'a>,
    pub end_block: BasicBlock<'a>,
    pub index: IntValue<'a>,
}

/// Set up the loop to iterate over an array
fn set_array_loop<'a>(
    bin: &Binary<'a>,
    arr: BasicValueEnum<'a>,
    ty: &Type,
    elem_ty: &Type,
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
            elem_ty,
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
        index: index_temp,
    }
}

/// Closes the for-loop when iterating over an array
fn finish_array_loop<'a>(bin: &Binary<'a>, func_value: FunctionValue<'a>, for_loop: &ForLoop) {
    bin.builder.build_unconditional_branch(for_loop.next_block);
    bin.builder.position_at_end(for_loop.next_block);

    let index_var = bin.builder.build_int_add(
        for_loop.index,
        bin.context.i64_type().const_int(1, false),
        "",
    );
    bin.builder.build_unconditional_branch(for_loop.cond_block);

    bin.builder.position_at_end(for_loop.end_block);
}
