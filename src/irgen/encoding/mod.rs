use inkwell::values::{
    BasicMetadataValueEnum, BasicValue, BasicValueEnum, FunctionValue, IntValue, PointerValue,
};
use num_traits::ToPrimitive;

use crate::{
    codegen::isa::ola::lower::bin,
    sema::ast::{ArrayLength, Function, Namespace, Type},
};

use self::{buffer_validator::BufferValidator, encoding::ScaleEncoding};

use super::binary::Binary;

mod buffer_validator;

mod encoding;

/// Insert encoding instructions into the `cfg` for any `Expression` in `args`.
/// Returns a pointer to the encoded data and the size as a 32bit integer.
// pub(super) fn abi_encode(
//     args: Vec<Expression>,
//     ns: &Namespace,
//     vartab: &mut Vartable,
//     cfg: &mut ControlFlowGraph,
//     packed: bool,
// ) -> (Expression, Expression) {
//     let mut encoder = create_encoder(ns, packed);
//     let size = calculate_size_args(&mut encoder, &args, ns, vartab, cfg);
//     let encoded_bytes = vartab.temp_name("abi_encoded", &Type::DynamicBytes);
//     let expr = Expression::AllocDynamicBytes {
//         loc: *loc,
//         ty: Type::DynamicBytes,
//         size: size.clone().into(),
//         initializer: None,
//     };
//     cfg.add(
//         vartab,
//         Instr::Set {
//             loc: *loc,
//             res: encoded_bytes,
//             expr,
//         },
//     );

//     let mut offset = Expression::NumberLiteral {
//         loc: *loc,
//         ty: Uint(32),
//         value: BigInt::zero(),
//     };
//     let buffer = Expression::Variable {
//         loc: *loc,
//         ty: Type::DynamicBytes,
//         var_no: encoded_bytes,
//     };
//     for (arg_no, item) in args.iter().enumerate() {
//         let advance = encoder.encode(item, &buffer, &offset, arg_no, ns, vartab, cfg);
//         offset = Expression::Add {
//             loc: *loc,
//             ty: Uint(32),
//             overflowing: false,
//             left: offset.into(),
//             right: advance.into(),
//         };
//     }
//     (buffer, size)
// }

/// Insert decoding routines into the `cfg` for the `Expression`s in `args`.
/// Returns a vector containing the encoded data.
pub(super) fn abi_decode<'a>(
    bin: &Binary<'a>,
    input_length: IntValue<'a>,
    input: PointerValue<'a>,
    types: &'a [Type],
    func: &Function,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> Vec<BasicMetadataValueEnum<'a>> {
    let mut validator = BufferValidator::new(input_length, types);

    let mut read_items = vec![];
    let mut offset = bin.context.i64_type().const_zero();

    validator.initialize_validation(bin, offset, func_value, ns);

    for (item_no, item) in types.iter().enumerate() {
        validator.set_argument_number(item_no);
        validator.validate_buffer(bin, offset, func_value, ns);
        let (read_item, advance) =
            read_from_buffer(input, offset, bin, item, &mut validator, func_value, ns);
        read_items[item_no] = read_item;
        offset = bin.builder.build_int_add(offset, advance, "");
    }

    validator.validate_all_bytes_read(bin, offset, func_value, ns);

    read_items
}

/// Read a value of type 'ty' from the buffer at a given offset. Returns an
/// expression containing the read value and the number of bytes read.
fn read_from_buffer<'a>(
    buffer: PointerValue<'a>,
    offset: IntValue<'a>,
    bin: &Binary<'a>,
    ty: &Type,
    validator: &mut BufferValidator<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicMetadataValueEnum<'a>, IntValue<'a>) {
    match ty {
        Type::Uint(32) | Type::Bool | Type::Enum(_) => {
            let size = bin.context.i64_type().const_int(1, false);
            validator.validate_offset_plus_size(bin, offset, size, func_value, ns);
            let read_value = decode_uint(buffer, &mut offset.clone(), bin);
            (read_value.into(), size)
        }

        Type::Address | Type::Contract(_) => {
            let read_bytes = ty.memory_size_of(ns);

            let size = bin
                .context
                .i64_type()
                .const_int(read_bytes.to_u64().unwrap(), false);
            validator.validate_offset_plus_size(bin, offset, size, func_value, ns);

            let read_value = decode_address(buffer, &mut offset.clone(), bin);
            (read_value.into(), size)
        }

        Type::String => {
            // String and Dynamic bytes are encoded as size + elements
            let array_length = decode_uint(buffer, &mut offset.clone(), bin);
            let total_size = bin.builder.build_int_add(
                bin.context.i64_type().const_int(1, false),
                array_length.into_int_value(),
                "",
            );
            let array_start =
                bin.builder
                    .build_int_add(offset, bin.context.i64_type().const_int(1, false), "");

            validator.validate_offset(bin, array_start.clone(), func_value, ns);

            let total_size_offset = bin.builder.build_int_add(offset, total_size, "");
            validator.validate_offset(bin, total_size_offset, func_value, ns);

            let allocated_array =
                bin.vector_new(func_value, array_length.into_int_value(), None, false);

            let array_data = bin.vector_data(allocated_array.into());

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

        Type::Struct(struct_ty) => decode_struct(
            buffer,
            &mut offset.clone(),
            ty,
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
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let start = unsafe {
        bin.builder
            .build_gep(bin.context.i64_type(), buffer, &[*offset], "start")
    };

    bin.builder
        .build_load(bin.context.i64_type(), start, "value")
}

fn decode_address<'a>(
    buffer: PointerValue<'a>,
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
) -> BasicValueEnum<'a> {
    let mut address = bin.context.i64_type().array_type(4).get_undef();

    for i in 0..4 {
        let value = decode_uint(buffer, offset, bin);
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
    validator: &mut BufferValidator,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicMetadataValueEnum<'a>, IntValue<'a>) {
    unimplemented!()
}

fn decode_struct<'a>(
    buffer: PointerValue<'a>,
    offset: &mut IntValue<'a>,
    ty: &Type,
    validator: &mut BufferValidator,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> (BasicMetadataValueEnum<'a>, IntValue<'a>) {
    unimplemented!()
}
