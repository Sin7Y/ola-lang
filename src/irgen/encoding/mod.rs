use std::ops::{AddAssign, Sub};

use inkwell::{
    values::{BasicValue, BasicValueEnum, FunctionValue, IntValue, PointerValue},
    IntPredicate,
};
use num_bigint::BigInt;
use num_integer::Integer;
use num_traits::{ToPrimitive, Zero};

use crate::sema::ast::{ArrayLength, Namespace, Type};

use self::{buffer_validator::BufferValidator, decode::read_from_buffer};

use super::binary::Binary;

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
