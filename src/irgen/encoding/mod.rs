use std::ops::{AddAssign, Sub};

use inkwell::{
    basic_block::BasicBlock,
    values::{BasicValue, BasicValueEnum, FunctionValue, IntValue, PointerValue},
    AddressSpace, IntPredicate,
};
use num_bigint::BigInt;
use num_integer::Integer;
use num_traits::{ToPrimitive, Zero};

use crate::sema::ast::{ArrayLength, Namespace, Type};

use self::{
    decode::read_from_buffer,
    encode::{encode_into_buffer, encode_uint},
};

use super::{binary::Binary, expression::array_subscript, storage::storage_load};

pub mod buffer_validator;

pub mod decode;

pub mod encode;

/// Insert encoding instructions into the `cfg` for any `Expression` in `args`.
/// Returns a pointer to the encoded data and the size as a 32bit integer.
pub(super) fn abi_encode<'a>(
    bin: &Binary<'a>,
    args: Vec<BasicValueEnum<'a>>,
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> PointerValue<'a> {
    let size = calculate_size_args(bin, &args, types, func_value, ns);

    let heap_start_ptr = bin.vector_new(size);

    let mut offset = bin.context.i64_type().const_int(1, false);

    for (arg_no, item) in args.iter().enumerate() {
        let advance = encode_into_buffer(
            heap_start_ptr,
            item.clone(),
            &types[arg_no],
            offset.clone(),
            bin,
            func_value,
            ns,
        );
        offset = bin.builder.build_int_add(advance, offset, "");
    }
    heap_start_ptr
}

/// Insert encoding instructions into the `cfg` for any `Expression` in `args`.
/// Returns a pointer to the encoded data and the size as a 32bit integer.
pub(super) fn abi_encode_store_tape<'a>(
    bin: &Binary<'a>,
    args: Vec<BasicValueEnum<'a>>,
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) {
    let size = calculate_size_args(bin, &args, types, func_value, ns);

    let heap_size = bin.builder.build_int_add(
        size,
        bin.context.i64_type().const_int(1, false),
        "heap_size",
    );

    let (heap_start_int, heap_start_ptr) = bin.heap_malloc(heap_size);

    let mut offset = bin.context.i64_type().const_zero();

    for (arg_no, item) in args.iter().enumerate() {
        let advance = encode_into_buffer(
            heap_start_ptr,
            item.clone(),
            &types[arg_no],
            offset.clone(),
            bin,
            func_value,
            ns,
        );
        offset = bin.builder.build_int_add(advance, offset, "");
    }
    // encode size to heap, the "size" here is only used for tape area
    // identification.
    encode_uint(heap_start_ptr, size.as_basic_value_enum(), offset, bin);

    bin.tape_data_store(heap_start_int, heap_size);
}

/// Insert encoding instructions into the `cfg` for any `Expression` in `args`.
/// Returns a pointer to the encoded data and the size as a 32bit integer.
pub(super) fn abi_encode_with_selector<'a>(
    bin: &Binary<'a>,
    selector: BasicValueEnum<'a>,
    args: Vec<BasicValueEnum<'a>>,
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> PointerValue<'a> {
    let size = calculate_size_args(bin, &args, types, func_value, ns);

    let heap_size = bin.builder.build_int_add(
        size,
        bin.context.i64_type().const_int(2, false),
        "heap_size",
    );

    let heap_start_ptr = bin.vector_new(heap_size);

    let mut offset = bin.context.i64_type().const_int(1, false);

    for (arg_no, item) in args.iter().enumerate() {
        let advance = encode_into_buffer(
            heap_start_ptr,
            item.clone(),
            &types[arg_no],
            offset,
            bin,
            func_value,
            ns,
        );
        offset = bin.builder.build_int_add(advance, offset, "");
    }
    // encode size to heap, the "size" here is used for tape area identification.
    encode_uint(heap_start_ptr, size.as_basic_value_enum(), offset, bin);

    offset = bin
        .builder
        .build_int_add(offset, bin.context.i64_type().const_int(1, false), "");

    // encode selector to heap
    encode_uint(heap_start_ptr, selector, offset, bin);

    heap_start_ptr
}

/// Insert decoding routines into the `cfg` for the `Expression`s in `args`.
/// Returns a vector containing the encoded data.
pub(super) fn abi_decode<'a>(
    bin: &Binary<'a>,
    _: IntValue<'a>,
    input: PointerValue<'a>,
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> Vec<BasicValueEnum<'a>> {
    let mut read_items = vec![];

    let mut input_start =
        bin.builder
            .build_ptr_to_int(input, bin.context.i64_type(), "input_start");

    // validator.initialize_validation(bin, offset, func_value, ns);

    for (item_no, item) in types.iter().enumerate() {
        // validator.set_argument_number(item_no);

        // validator.validate_buffer(bin, offset, func_value, ns);
        let (read_item, advance) = read_from_buffer(input_start, bin, item, func_value, ns);
        read_items.push(read_item);
        if item_no < types.len() - 1 {
            input_start = bin.builder.build_int_add(input_start, advance, "");
            // validator.validate_buffer_end(bin, offset, func_value, ns);
        }
    }

    // validator.validate_all_bytes_read(bin, offset, func_value);

    read_items
}

/// Calculate the size of a set of arguments to encoding functions
pub(super) fn calculate_size_args<'a>(
    bin: &Binary<'a>,
    args: &[BasicValueEnum<'a>],
    types: &Vec<Type>,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    let mut size = get_args_type_size(bin, args[0], &types[0], func_value, ns);
    for (i, item) in types.iter().enumerate().skip(1) {
        let additional = get_args_type_size(bin, args[i], item, func_value, ns);
        size = bin.builder.build_int_add(size, additional, "");
    }
    size
}

/// Calculate the size of a single arg value
fn get_args_type_size<'a>(
    bin: &Binary<'a>,
    arg_value: BasicValueEnum<'a>,
    ty: &Type,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    match &ty {
        Type::Uint(32) | Type::Bool | Type::Enum(_) | Type::Field => {
            bin.context.i64_type().const_int(1, false)
        }
        Type::Contract(_) | Type::Address | Type::Hash => {
            bin.context.i64_type().const_int(4, false)
        }

        Type::Struct(struct_no) => {
            calculate_struct_size(bin, arg_value, *struct_no, func_value, ns)
        }
        Type::Slice(elem_ty) => {
            let dims = vec![ArrayLength::Dynamic];
            calculate_array_size(bin, arg_value, ty, &elem_ty, &dims, func_value, ns)
        }
        Type::Array(elem_ty, dims) => {
            calculate_array_size(bin, arg_value, ty, &elem_ty, dims, func_value, ns)
        }

        Type::Ref(r) => {
            if let Type::Struct(struct_no) = &**r {
                return calculate_struct_size(bin, arg_value, *struct_no, func_value, ns);
            }

            let loaded = bin.builder.build_load(
                bin.llvm_type(ty.deref_memory(), ns),
                arg_value.into_pointer_value(),
                "",
            );

            get_args_type_size(bin, loaded, r, func_value, ns)
        }
        Type::StorageRef(r) => {
            let storage_var = storage_load(bin, r, &mut arg_value.clone(), func_value, ns);
            let size = get_args_type_size(bin, storage_var, r, func_value, ns);
            size
        }
        Type::String | Type::DynamicBytes => calculate_string_size(bin, arg_value),
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
        let size_var = bin.build_alloca(func_value, bin.context.i64_type(), "size_var");
        bin.builder
            .build_store(size_var, bin.context.i64_type().const_zero());
        calculate_complex_array_size(
            bin,
            array,
            array_ty,
            elem_ty,
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
            dims,
            indexes,
            func_value,
            ns,
        );
        let size = bin.vector_len(arr);
        let size = bin.builder.build_int_add(
            bin.builder
                .build_load(bin.context.i64_type(), size_var, "")
                .into_int_value(),
            size,
            "",
        );
        bin.builder.build_store(size_var, size);
    }

    let for_loop = set_array_loop(
        bin, array, array_ty, dims, dimension, indexes, func_value, ns,
    );
    bin.builder.position_at_end(for_loop.body_block);

    if 0 == dimension {
        let deref = index_array(
            bin,
            &mut array.clone(),
            &mut array_ty.clone(),
            dims,
            indexes,
            func_value,
            ns,
        );
        let elem_size = get_args_type_size(bin, deref, elem_ty, func_value, ns);

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

/// Retrieves the size of a struct
fn calculate_struct_size<'a>(
    bin: &Binary<'a>,
    struct_ptr: BasicValueEnum<'a>,
    struct_no: usize,
    func_value: FunctionValue<'a>,
    ns: &Namespace,
) -> IntValue<'a> {
    if let Some(struct_size) = calculate_struct_non_padded_size(struct_no, ns) {
        return bin
            .context
            .i64_type()
            .const_int(struct_size.to_u64().unwrap(), false);
    }

    let struct_start = bin.builder.build_ptr_to_int(
        struct_ptr.into_pointer_value(),
        bin.context.i64_type(),
        "struct_start",
    );

    let mut struct_offset = struct_start.clone();

    let mut struct_start_pointer = struct_ptr.into_pointer_value();
    for i in 0..ns.structs[struct_no].fields.len() {
        let field_ty = ns.structs[struct_no].fields[i].ty.clone();
        let expr_size =
            get_args_type_size(bin, struct_start_pointer.into(), &field_ty, func_value, ns).into();
        struct_offset = bin.builder.build_int_add(struct_offset, expr_size, "");
        struct_start_pointer = bin.builder.build_int_to_ptr(
            struct_offset,
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            "",
        );
    }
    let size = bin.builder.build_int_sub(struct_offset, struct_start, "");
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

    let struct_member = unsafe {
        bin.builder.build_gep(
            struct_ty,
            struct_ptr.into_pointer_value(),
            &[bin.context.i64_type().const_int(member as u64, false)],
            "struct_member",
        )
    };
    if field_ty.is_primitive() {
        bin.builder
            .build_load(bin.llvm_type(field_ty, ns), struct_member, "elem")
    } else {
        struct_member.into()
    }
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
            &Type::Uint(32),
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
fn finish_array_loop<'a>(bin: &Binary<'a>, for_loop: &ForLoop<'a>) {
    bin.builder.build_unconditional_branch(for_loop.next_block);
    bin.builder.position_at_end(for_loop.next_block);
    let index = bin
        .builder
        .build_load(bin.context.i64_type(), for_loop.index, "index")
        .into_int_value();
    let index_var =
        bin.builder
            .build_int_add(index, bin.context.i64_type().const_int(1, false), "");
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
