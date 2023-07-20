use inkwell::values::{BasicValueEnum, FunctionValue, IntValue, PointerValue};
use num_traits::ToPrimitive;

use crate::{
    codegen::isa::ola::lower::bin,
    irgen::{binary::Binary, storage::storage_load},
    sema::ast::{ArrayLength, Namespace, Type},
};

use super::{
    calculate_struct_non_padded_size, dynamic_array_copy, finish_array_loop, index_array,
    set_array_loop,
};

/// Calculate the size of a set of arguments to encoding functions
pub fn calculate_size_args<'a>(
    bin: &Binary<'a>,
    args: Vec<BasicValueEnum<'a>>,
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

/// Calculate the size of a single codegen::Expression
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
            let storage_var = storage_load(bin, r, &mut arg_value, func_value, ns);
            let size = get_args_type_size(bin, arg_no, storage_var, r, func_value, ns);
            size
        }
        Type::String => calculate_string_size(bin, arg_value, ns),
        Type::Void | Type::Unreachable | Type::BufferPointer | Type::Mapping(..) => {
            unreachable!("This type cannot be encoded")
        }
        Type::UserType(_) | Type::Unresolved => {
            unreachable!("Type should not exist in irgen")
        }
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

fn calculate_string_size<'a>(
    bin: &Binary<'a>,
    string_value: BasicValueEnum<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
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
        let size = bin
            .builder
            .build_int_add(size, bin.context.i64_type().const_int(1, false), "");
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
    finish_array_loop(bin, func_value, &for_loop);
}

/// Provide generic encoding for any given `expr` into `buffer`, depending on
/// its `Type`. Relies on the methods encoding individual expressions
/// (`encode_*`) to return the encoded size.
fn encode<'a>(
    arg: BasicValueEnum<'a>,
    arg_ty: &Type,
    buffer: BasicValueEnum<'a>,
    offset: IntValue<'a>,
    arg_no: usize,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    match arg_ty {
        Type::Contract(_) | Type::Address => {
            encode_address(arg, buffer, &mut offset, bin);
            bin.context.i64_type().const_int(4, false)
        }
        Type::Bool | Type::Uint(32) | Type::Enum(_) => {
            encode_uint(arg, buffer, offset, bin);
            bin.context.i64_type().const_int(1, false)
        }

        Type::String => encode_bytes(expr, buffer, offset, ns, vartab, cfg),

        Type::Struct(ty) => {
            encode_struct(expr, buffer, offset.clone(), ty, arg_no, ns, vartab, cfg)
        }
        Type::Slice(ty) => {
            let dims = &[ArrayLength::Dynamic];
            encode_array(
                expr, expr_ty, ty, dims, arg_no, buffer, offset, ns, vartab, cfg,
            )
        }
        Type::Array(ty, dims) => encode_array(
            expr, expr_ty, ty, dims, arg_no, buffer, offset, ns, vartab, cfg,
        ),

        Type::Ref(r) => {
            if let Type::Struct(ty) = &**r {
                // Structs references should not be dereferenced
                return encode_struct(expr, buffer, offset.clone(), ty, arg_no, ns, vartab, cfg);
            }
            let loaded = Expression::Load {
                loc: Codegen,
                ty: *r.clone(),
                expr: expr.clone().into(),
            };
            encode(&loaded, buffer, offset, arg_no, ns, vartab, cfg)
        }
        Type::StorageRef(..) => {
            let loaded = self.storage_cache_remove(arg_no).unwrap();
            self.encode(&loaded, buffer, offset, arg_no, ns, vartab, cfg)
        }
        Type::UserType(_) | Type::Unresolved | Type::Unreachable => {
            unreachable!("Type should not exist in codegen")
        }
        Type::Void | Type::BufferPointer | Type::Mapping(..) => {
            unreachable!("This type cannot be encoded")
        }
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
        encode_uint(value.unwrap(), buffer, offset, bin);
        *offset =
            bin.builder
                .build_int_add(*offset, bin.context.i64_type().const_int(1, false), "");
    }
}

/// Encode `expr` into `buffer` as bytes.
fn encode_bytes<'a>(
    string_value: BasicValueEnum<'a>,
    buffer: BasicValueEnum<'a>,
    offset: &mut IntValue<'a>,
    bin: &Binary<'a>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let len = bin.vector_len(string_value);
    let data = bin.vector_data(string_value);

    dynamic_array_copy(
        buffer,
        array_start,
        len,
        &Type::Uint(32),
        buffer,
        bin,
        func_value,
        ns,
    );

    let (data_offset, size) = if self.is_packed() {
        (offset.clone(), None)
    } else {
        let size = self.encode_size(&len, buffer, offset, ns, vartab, cfg);
        (offset.clone().add_u32(size.clone()), Some(size))
    };
    // ptr + offset + size_of_integer
    let dest_address = Expression::AdvancePointer {
        pointer: buffer.clone().into(),
        bytes_offset: data_offset.into(),
    };
    cfg.add(
        vartab,
        Instr::MemCopy {
            source: expr.clone(),
            destination: dest_address,
            bytes: len.clone(),
        },
    );
    if let Some(size) = size {
        len.add_u32(size)
    } else {
        len
    }
}

/// Currently, we can only handle one-dimensional arrays.
/// The situation of multi-dimensional arrays has not been processed yet.
pub fn encode_dynamic_array_loop<'a>(
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

/// Encode `expr` into `buffer` as a struct type.
fn encode_struct(
    expr: &Expression,
    buffer: &Expression,
    mut offset: Expression,
    struct_ty: &StructType,
    arg_no: usize,
    ns: &Namespace,
    vartab: &mut Vartable,
    cfg: &mut ControlFlowGraph,
) -> Expression {
    let size = ns.calculate_struct_non_padded_size(struct_ty);
    // If the size without padding equals the size with padding, memcpy this struct
    // directly.
    if let Some(no_padding_size) = size.as_ref().filter(|no_pad| {
        *no_pad == &struct_ty.struct_padded_size(ns) && allow_memcpy(&expr.ty(), ns)
    }) {
        let size = Expression::NumberLiteral {
            loc: Codegen,
            ty: Uint(32),
            value: no_padding_size.clone(),
        };
        let dest_address = Expression::AdvancePointer {
            pointer: buffer.clone().into(),
            bytes_offset: offset.into(),
        };
        cfg.add(
            vartab,
            Instr::MemCopy {
                source: expr.clone(),
                destination: dest_address,
                bytes: size.clone(),
            },
        );
        return size;
    }
    let size = size.map(|no_pad| Expression::NumberLiteral {
        loc: Codegen,
        ty: Uint(32),
        value: no_pad,
    });

    let qty = struct_ty.definition(ns).fields.len();
    let first_ty = struct_ty.definition(ns).fields[0].ty.clone();
    let loaded = load_struct_member(first_ty, expr.clone(), 0, ns);

    let mut advance = self.encode(&loaded, buffer, &offset, arg_no, ns, vartab, cfg);
    let mut runtime_size = advance.clone();
    for i in 1..qty {
        let ith_type = struct_ty.definition(ns).fields[i].ty.clone();
        offset = Expression::Add {
            loc: Codegen,
            ty: Uint(32),
            overflowing: false,
            left: offset.clone().into(),
            right: advance.into(),
        };
        let loaded = load_struct_member(ith_type.clone(), expr.clone(), i, ns);
        // After fetching the struct member, we can encode it
        advance = self.encode(&loaded, buffer, &offset, arg_no, ns, vartab, cfg);
        runtime_size = Expression::Add {
            loc: Codegen,
            ty: Uint(32),
            overflowing: false,
            left: runtime_size.into(),
            right: advance.clone().into(),
        };
    }

    size.unwrap_or(runtime_size)
}

/// Encode `expr` into `buffer` as an array.
fn encode_array(
    array: &Expression,
    array_ty: &Type,
    elem_ty: &Type,
    dims: &[ArrayLength],
    arg_no: usize,
    buffer: &Expression,
    offset: &Expression,
    ns: &Namespace,
    vartab: &mut Vartable,
    cfg: &mut ControlFlowGraph,
) -> Expression {
    assert!(!dims.is_empty());

    if allow_memcpy(array_ty, ns) {
        // Calculate number of elements
        let (bytes_size, offset, size_length) =
            if matches!(dims.last(), Some(&ArrayLength::Fixed(_))) {
                let elem_no = calculate_direct_copy_bytes_size(dims, elem_ty, ns);
                (
                    Expression::NumberLiteral {
                        loc: Codegen,
                        ty: Uint(32),
                        value: elem_no,
                    },
                    offset.clone(),
                    None,
                )
            } else {
                let value = array_outer_length(array, vartab, cfg);

                let (new_offset, size_length) = if self.is_packed() {
                    (offset.clone(), None)
                } else {
                    let encoded_size = self.encode_size(&value, buffer, offset, ns, vartab, cfg);
                    (
                        offset.clone().add_u32(encoded_size.clone()),
                        Some(encoded_size),
                    )
                };

                if let Expression::Variable {
                    var_no: size_temp, ..
                } = value
                {
                    let size = calculate_array_bytes_size(size_temp, elem_ty, ns);
                    (size, new_offset, size_length)
                } else {
                    unreachable!()
                }
            };

        let dest_address = Expression::AdvancePointer {
            pointer: buffer.clone().into(),
            bytes_offset: offset.into(),
        };

        cfg.add(
            vartab,
            Instr::MemCopy {
                source: array.clone(),
                destination: dest_address,
                bytes: bytes_size.clone(),
            },
        );

        // If the array is dynamic, we have written into the buffer its size and its
        // elements
        return match (size_length, self.is_packed()) {
            (Some(len), false) => Expression::Add {
                loc: Codegen,
                ty: Uint(32),
                overflowing: false,
                left: bytes_size.into(),
                right: len.into(),
            },
            _ => bytes_size,
        };
    }

    // In all other cases, we must loop through the array
    let mut indexes: Vec<usize> = Vec::new();
    let offset_var_no = vartab.temp_anonymous(&Uint(32));
    cfg.add(
        vartab,
        Instr::Set {
            loc: Codegen,
            res: offset_var_no,
            expr: offset.clone(),
        },
    );
    self.encode_complex_array(
        array,
        arg_no,
        dims,
        buffer,
        offset_var_no,
        dims.len() - 1,
        ns,
        vartab,
        cfg,
        &mut indexes,
    );

    // The offset variable minus the original offset obtains the vector size in
    // bytes
    let offset_var = Expression::Variable {
        loc: Codegen,
        ty: Uint(32),
        var_no: offset_var_no,
    }
    .into();
    let sub = Expression::Subtract {
        loc: Codegen,
        ty: Uint(32),
        overflowing: false,
        left: offset_var,
        right: offset.clone().into(),
    };
    cfg.add(
        vartab,
        Instr::Set {
            loc: Codegen,
            res: offset_var_no,
            expr: sub,
        },
    );
    Expression::Variable {
        loc: Codegen,
        ty: Uint(32),
        var_no: offset_var_no,
    }
}

/// Encode `expr` into `buffer` as a complex array.
/// This function indexes an array from its outer dimension to its inner one.
///
/// Note: In the default implementation, `encode_array` decides when to use this
/// method for you.
fn encode_complex_array(
    arr: &Expression,
    arg_no: usize,
    dims: &[ArrayLength],
    buffer: &Expression,
    offset_var: usize,
    dimension: usize,
    ns: &Namespace,
    vartab: &mut Vartable,
    cfg: &mut ControlFlowGraph,
    indexes: &mut Vec<usize>,
) {
    // If this dimension is dynamic, we must save its length before all elements
    if dims[dimension] == ArrayLength::Dynamic && !self.is_packed() {
        // TODO: This is wired up for the support of dynamic multidimensional arrays,
        // like TODO: 'int[3][][4] vec', but it needs testing, as soon as Solang
        // works with them. TODO: A discussion about this is under way here: https://github.com/hyperledger/solang/issues/932
        // We only support dynamic arrays whose non-constant length is the outer one.
        let sub_array = index_array(arr.clone(), dims, indexes, false);

        let size = Expression::Builtin {
            loc: Codegen,
            tys: vec![Uint(32)],
            kind: Builtin::ArrayLength,
            args: vec![sub_array],
        };

        let offset_expr = Expression::Variable {
            loc: Codegen,
            ty: Uint(32),
            var_no: offset_var,
        };
        let encoded_size = self.encode_size(&size, buffer, &offset_expr, ns, vartab, cfg);
        cfg.add(
            vartab,
            Instr::Set {
                loc: Codegen,
                res: offset_var,
                expr: offset_expr.add_u32(encoded_size),
            },
        );
    }
    let for_loop = set_array_loop(arr, dims, dimension, indexes, vartab, cfg);
    cfg.set_basic_block(for_loop.body_block);
    if 0 == dimension {
        // If we are indexing the last dimension, we have an element, so we can encode
        // it.
        let deref = index_array(arr.clone(), dims, indexes, false);
        let offset_expr = Expression::Variable {
            loc: Codegen,
            ty: Uint(32),
            var_no: offset_var,
        };
        let elem_size = self.encode(&deref, buffer, &offset_expr, arg_no, ns, vartab, cfg);
        cfg.add(
            vartab,
            Instr::Set {
                loc: Codegen,
                res: offset_var,
                expr: Expression::Add {
                    loc: Codegen,
                    ty: Uint(32),
                    overflowing: false,
                    left: elem_size.into(),
                    right: offset_expr.into(),
                },
            },
        );
    } else {
        self.encode_complex_array(
            arr,
            arg_no,
            dims,
            buffer,
            offset_var,
            dimension - 1,
            ns,
            vartab,
            cfg,
            indexes,
        )
    }

    finish_array_loop(&for_loop, vartab, cfg);
}
