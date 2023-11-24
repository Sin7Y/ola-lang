use crate::sema::ast::{ArrayLength, Contract, Namespace, Type};
use crate::sema::expression::FIELD_ORDER;
use std::path::Path;
use std::str;

use num_bigint::BigInt;
use num_traits::ToPrimitive;

use crate::irgen::corelib::gen_lib_functions;
use crate::irgen::functions::gen_functions;
use inkwell::basic_block::BasicBlock;
use inkwell::builder::Builder;
use inkwell::context::Context;
use inkwell::module::{Linkage, Module};
use inkwell::types::{BasicMetadataTypeEnum, BasicType, BasicTypeEnum, FunctionType, StringRadix};
use inkwell::values::{
    BasicValue, BasicValueEnum, FunctionValue, GlobalValue, IntValue, PointerValue,
};
use inkwell::{AddressSpace, IntPredicate};

use super::dispatch::{gen_contract_entrance, gen_func_dispatch};

pub const SAPN: u64 = 2 ^ 32 - 1;

pub const HEAP_ADDRESS_START: u64 = FIELD_ORDER - 2 * SAPN;

pub struct Binary<'a> {
    pub name: String,
    pub module: Module<'a>,
    pub builder: Builder<'a>,
    pub(crate) context: &'a Context,
    pub loops: Vec<(BasicBlock<'a>, BasicBlock<'a>)>,
    pub heap_address: GlobalValue<'a>,
}

impl<'a> Binary<'a> {
    /// Build the LLVM IR for a single contract
    pub fn build(
        context: &'a Context,
        contract: &'a Contract,
        ns: &'a Namespace,
        filename: &'a str,
    ) -> Self {
        let mut binary = Binary::new(context, &contract.name, filename);
        gen_lib_functions(&mut binary, ns);
        gen_functions(&mut binary, ns);
        gen_func_dispatch(&mut binary, ns);
        gen_contract_entrance(None, &mut binary);
        binary
    }

    pub fn dump_llvm(&self, path: &Path) -> Result<(), String> {
        if let Err(s) = self.module.print_to_file(path) {
            return Err(s.to_string());
        }

        Ok(())
    }

    pub fn new(context: &'a Context, name: &str, filename: &str) -> Self {
        let module = context.create_module(name);

        let builder = context.create_builder();

        module.set_source_file_name(filename);
        let heap_address = module.add_global(
            context.i64_type(),
            Some(AddressSpace::default()),
            "heap_address",
        );
        heap_address.set_linkage(Linkage::Internal);
        heap_address.set_initializer(&context.i64_type().const_int(HEAP_ADDRESS_START, false));

        Binary {
            name: name.to_owned(),
            module,
            builder,
            context,
            loops: Vec::new(),
            heap_address,
        }
    }

    /// Convert a BigInt number to llvm const value
    pub(crate) fn number_literal(
        &self,
        ty: &Type,
        n: &BigInt,
        _ns: &Namespace,
    ) -> BasicValueEnum<'a> {
        match ty {
            // Map all i32 data to a field-based data type,
            // with the maximum value of field between u63 and u64.
            Type::Uint(32) | Type::Field => {
                let ty = self.context.i64_type();
                let s = n.to_string();
                ty.const_int_from_string(&s, StringRadix::Decimal)
                    .unwrap()
                    .into()
            }
            _ => panic!("not implemented"),
        }
    }

    pub(crate) fn address_literal(&self, value: &Vec<BigInt>) -> BasicValueEnum<'a> {
        let (_, address_heap_ptr) =
            self.heap_malloc(self.context.i64_type().const_int(value.len() as u64, false));
        let ty = self.context.i64_type();
        for (i, v) in value.iter().enumerate() {
            let index = self.context.i64_type().const_int(i as u64, false);
            let index_access =
                unsafe {
                    self.builder.build_gep(
                        self.context.i64_type(),
                        address_heap_ptr,
                        &[index],
                        "index_access",
                    )
                };
            self.builder
                .build_store(index_access, ty.const_int(v.to_u64().unwrap(), false));
        }
        address_heap_ptr.into()
    }

    pub(crate) fn hash_literal(&self, value: &Vec<BigInt>) -> BasicValueEnum<'a> {
        let (_, hash_heap_ptr) =
            self.heap_malloc(self.context.i64_type().const_int(value.len() as u64, false));
        let ty = self.context.i64_type();
        for (i, v) in value.iter().enumerate() {
            let index = self.context.i64_type().const_int(i as u64, false);
            let index_access = unsafe {
                self.builder.build_gep(
                    self.context.i64_type(),
                    hash_heap_ptr,
                    &[index],
                    "index_access",
                )
            };
            self.builder
                .build_store(index_access, ty.const_int(v.to_u64().unwrap(), false));
        }
        hash_heap_ptr.into()
    }

    /// Emit function prototype
    pub(crate) fn function_type(
        &self,
        params: &[Type],
        returns: &[Type],
        ns: &Namespace,
    ) -> FunctionType<'a> {
        // function parameters
        let mut args = params
            .iter()
            .map(|ty| self.llvm_var_ty(ty, ns).into())
            .collect::<Vec<BasicMetadataTypeEnum>>();

        return if returns.len() == 1 {
            let return_type = self.llvm_var_ty(&returns[0], ns);
            return_type.fn_type(&args, false)
        } else {
            // add return values
            for ty in returns {
                args.push(if ty.is_reference_type(ns) && !ty.is_contract_storage() {
                    self.llvm_type(ty, ns)
                        .ptr_type(AddressSpace::default())
                        .ptr_type(AddressSpace::default())
                        .into()
                } else {
                    self.llvm_type(ty, ns)
                        .ptr_type(AddressSpace::default())
                        .into()
                });
            }
            let void_type = self.context.void_type();
            void_type.fn_type(&args, false)
        };
    }

    /// Return the llvm type for a variable holding the type, not the type
    /// itself
    pub(crate) fn llvm_var_ty(&self, ty: &Type, ns: &Namespace) -> BasicTypeEnum<'a> {
        let llvm_ty = self.llvm_type(ty, ns);
        match ty.deref_memory() {
            Type::Struct(_) | Type::Array(..) | Type::String | Type::DynamicBytes => llvm_ty
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            _ => llvm_ty,
        }
    }

    /// Return the llvm type for field in struct or array
    pub(crate) fn llvm_field_ty(&self, ty: &Type, ns: &Namespace) -> BasicTypeEnum<'a> {
        let llvm_ty = self.llvm_type(ty, ns);
        match ty.deref_memory() {
            Type::Array(_, dim) if dim.last() == Some(&ArrayLength::Dynamic) => llvm_ty
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            Type::DynamicBytes | Type::String => llvm_ty
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            _ => llvm_ty,
        }
    }

    /// Return the llvm type for the resolved type.
    pub(crate) fn llvm_type(&self, ty: &Type, ns: &Namespace) -> BasicTypeEnum<'a> {
        match ty {
            Type::Bool => self.context.i64_type().into(),
            // Map all i32 data to a field-based data type, with the maximum value of field between
            // u63 and u64
            Type::Uint(32) => self.context.i64_type().into(),
            Type::Field => self.context.i64_type().into(),
            Type::Hash => self
                .context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            Type::Contract(_) | Type::Address => self
                .context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            Type::Enum(n) => self.llvm_type(&ns.enums[*n].ty, ns),
            Type::Array(base_ty, dims) => {
                let ty = self.llvm_field_ty(base_ty, ns);

                let mut dims = dims.iter();

                let mut aty = match dims.next().unwrap() {
                    ArrayLength::Fixed(d) => ty.array_type(d.to_u32().unwrap()),
                    ArrayLength::Dynamic => {
                        return self
                            .context
                            .i64_type()
                            .ptr_type(AddressSpace::default())
                            .as_basic_type_enum()
                    }
                    ArrayLength::AnyFixed => {
                        unreachable!()
                    }
                };

                for dim in dims {
                    match dim {
                        ArrayLength::Fixed(d) => aty = aty.array_type(d.to_u32().unwrap()),
                        ArrayLength::Dynamic => {
                            return self
                                .context
                                .i64_type()
                                .ptr_type(AddressSpace::default())
                                .as_basic_type_enum()
                        }
                        ArrayLength::AnyFixed => {
                            unreachable!()
                        }
                    }
                }

                BasicTypeEnum::ArrayType(aty)
            }
            Type::String | Type::DynamicBytes => self
                .context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            Type::Mapping(..) => self.llvm_type(&Type::Uint(32), ns),
            Type::Struct(n) => self
                .context
                .struct_type(
                    &ns.structs[*n]
                        .fields
                        .iter()
                        .map(|f| self.llvm_field_ty(&f.ty, ns))
                        .collect::<Vec<BasicTypeEnum>>(),
                    false,
                )
                .as_basic_type_enum(),
            Type::Ref(r) => self
                .llvm_type(r, ns)
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            Type::StorageRef(..) => self.llvm_type(&Type::Uint(32), ns),
            Type::Function {
                params, returns, ..
            } => {
                let fn_type = self.function_type(params, returns, ns);

                BasicTypeEnum::PointerType(fn_type.ptr_type(AddressSpace::default()))
            }
            Type::Slice(ty) => BasicTypeEnum::StructType(
                self.context.struct_type(
                    &[
                        self.llvm_type(ty, ns)
                            .ptr_type(AddressSpace::default())
                            .into(),
                        self.context.custom_width_int_type(64).into(),
                    ],
                    false,
                ),
            ),
            Type::UserType(no) => self.llvm_type(&ns.user_types[*no].ty, ns),
            Type::BufferPointer => self
                .context
                .i8_type()
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            _ => unreachable!(),
        }
    }

    // Creates a new stack allocation instruction in the entry block of the function
    pub(crate) fn build_alloca<T: BasicType<'a>>(
        &self,
        function: inkwell::values::FunctionValue<'a>,
        ty: T,
        name: &str,
    ) -> PointerValue<'a> {
        let entry = function
            .get_first_basic_block()
            .expect("function missing entry block");
        let current = self.builder.get_insert_block().unwrap();
        if let Some(instr) = &entry.get_first_instruction() {
            self.builder.position_before(instr);
        } else {
            // if there is no instruction yet, then nothing was built
            self.builder.position_at_end(entry);
        }

        let res = self.builder.build_alloca(ty, name);

        self.builder.position_at_end(current);

        res
    }

    /// Allocate vector on the heap and return heap address
    pub(crate) fn alloca_dynamic_array(
        &self,
        function: FunctionValue<'a>,
        ty: &Type,
        size: IntValue<'a>,
        init: Option<&Vec<u32>>,
        zero_init: bool,
        ns: &Namespace,
    ) -> PointerValue<'a> {
        let elem_ty = ty.array_elem();
        let memory_size = match ty {
            Type::Slice(_) | Type::String | Type::DynamicBytes => size,
            _ => self
                .context
                .i64_type()
                .const_int(ty.memory_size_of(ns).to_u64().unwrap(), false),
        };

        let heap_start_ptr = self.vector_new(memory_size);

        match init {
            None => {
                if zero_init {
                    let data = self.vector_data(heap_start_ptr.as_basic_value_enum());
                    self.vector_zero_init(
                        function,
                        &elem_ty,
                        self.context.i64_type().const_zero(),
                        size,
                        data,
                        ns,
                    );
                }
            }
            // TODO Is it possible for the initial value to be of type u32? It needs to be
            // determined based on the type.
            Some(init) => {
                let data = self.vector_data(heap_start_ptr.as_basic_value_enum());
                for (item_no, item) in init.iter().enumerate() {
                    let item = self.context.i64_type().const_int(*item as u64, false);
                    let index = self.context.i64_type().const_int(item_no as u64, false);
                    let index_access = unsafe {
                        self.builder.build_gep(
                            self.context.i64_type(),
                            data,
                            &[index],
                            "index_access",
                        )
                    };
                    self.builder.build_store(index_access, item);
                }
            }
        }

        heap_start_ptr
    }

    pub(crate) fn vector_new(&self, size: IntValue<'a>) -> PointerValue<'a> {
        let size_add_one = self.builder.build_int_add(
            size,
            self.context.i64_type().const_int(1, false),
            "length_and_data",
        );

        let (_, heap_start_ptr) = self.heap_malloc(size_add_one);

        self.builder.build_store(heap_start_ptr, size);
        heap_start_ptr
    }

    pub(crate) fn heap_malloc(&self, size: IntValue<'a>) -> (IntValue<'a>, PointerValue<'a>) {
        let heap_ptr_after = self
            .builder
            .build_call(
                self.module.get_function("vector_new").unwrap(),
                &[size.into()],
                "",
            )
            .try_as_basic_value()
            .left()
            .unwrap();

        let heap_start_int =
            self.builder
                .build_int_sub(heap_ptr_after.into_int_value(), size, "heap_start");

        let heap_start_ptr = self.builder.build_int_to_ptr(
            heap_start_int,
            self.context.i64_type().ptr_type(AddressSpace::default()),
            "heap_to_ptr",
        );

        (heap_start_int, heap_start_ptr)
    }

    pub(crate) fn context_data_load(&self, heap_address: IntValue<'a>, tape_index: IntValue<'a>) {
        let context_data_function = self.module.get_function("get_context_data").unwrap();
        self.builder.build_call(
            context_data_function,
            &[heap_address.into(), tape_index.into()],
            "",
        );
    }
    pub(crate) fn tape_data_load(&self, heap_address: IntValue<'a>, tape_index: IntValue<'a>) {
        let tape_data_function = self.module.get_function("get_tape_data").unwrap();
        self.builder.build_call(
            tape_data_function,
            &[heap_address.into(), tape_index.into()],
            "",
        );
    }

    pub(crate) fn tape_data_store(&self, heap_address: IntValue<'a>, length: IntValue<'a>) {
        let tape_data_function = self.module.get_function("set_tape_data").unwrap();
        self.builder.build_call(
            tape_data_function,
            &[heap_address.into(), length.into()],
            "",
        );
    }

    pub(crate) fn contract_input(&self) -> (IntValue<'a>, IntValue<'a>, PointerValue<'a>) {
        // contract input in tape
        // ｜ calldata ｜ calldata len(1 field) ｜ selector(1 field) ｜ caller_address(4
        // field) ｜ callee_address(4 field) | code_address(4 field)|

        let selector_index = self.context.i64_type().const_int(13, false);
        let (selector_start_int, selector_start_ptr) = self.heap_malloc(selector_index);
        self.tape_data_load(selector_start_int, selector_index);
        let function_selector = self.builder.build_load(
            self.context.i64_type(),
            selector_start_ptr,
            "function_selector",
        );
        let length_size = self.context.i64_type().const_int(1, false);
        let length_index = self.builder.build_int_add(selector_index, length_size, "");

        let (length_start_int, length_start_ptr) = self.heap_malloc(length_index);
        self.tape_data_load(length_start_int, length_index);
        let input_length =
            self.builder
                .build_load(self.context.i64_type(), length_start_ptr, "input_length");
        let calldata_index =
            self.builder
                .build_int_add(input_length.into_int_value(), length_index, "");
        let (data_start_int, data_start_ptr) = self.heap_malloc(calldata_index);
        self.tape_data_load(data_start_int, calldata_index);
        (
            function_selector.into_int_value(),
            input_length.into_int_value(),
            data_start_ptr,
        )
    }

    pub(crate) fn poseidon_hash(
        &self,
        hash_src: Vec<(BasicValueEnum<'a>, IntValue<'a>)>,
    ) -> BasicValueEnum<'a> {
        let (heap_src_ptr, src_len) = if hash_src.len() > 1 {
            let mut src_len = self.context.i64_type().const_zero();

            for (_, len) in hash_src.iter() {
                src_len = self.builder.build_int_add(src_len, *len, "");
            }
            let (heap_src_int, heap_src_ptr) = self.heap_malloc(src_len);
            let mut dest_offset = heap_src_int;
            let hash_src_len = hash_src.len();
            for (i, (v, len)) in hash_src.iter().enumerate() {
                let dest_ptr =
                    self.builder.build_int_to_ptr(
                        dest_offset,
                        self.context.i64_type().ptr_type(AddressSpace::default()),
                        "",
                    );
                self.memcpy(v.into_pointer_value(), dest_ptr, *len);
                // Check if this is the last iteration of the loop
                if i < hash_src_len - 1 {
                    dest_offset = self
                        .builder
                        .build_int_add(dest_offset, *len, "next_dest_offset");
                }
            }
            (heap_src_ptr, src_len)
        } else {
            let (heap_src_ptr, src_len) = hash_src[0];
            (heap_src_ptr.into_pointer_value(), src_len)
        };
        let return_size = self.context.i64_type().const_int(4, false);
        let (_, return_heap_ptr) = self.heap_malloc(return_size);
        let hash_function = self.module.get_function("poseidon_hash").unwrap();
        self.builder.build_call(
            hash_function,
            &[heap_src_ptr.into(), return_heap_ptr.into(), src_len.into()],
            "",
        );
        return_heap_ptr.as_basic_value_enum()
    }

    /// Number of element in a vector
    pub(crate) fn vector_len(&self, vector: BasicValueEnum<'a>) -> IntValue<'a> {
        self.builder
            .build_load(
                self.context.i64_type(),
                vector.into_pointer_value(),
                "length",
            )
            .into_int_value()
    }

    /// Return the pointer to the actual bytes in the vector
    pub(crate) fn vector_data(&self, vector: BasicValueEnum<'a>) -> PointerValue<'a> {
        let vector_int_value =
            self.builder
                .build_ptr_to_int(vector.into_pointer_value(), self.context.i64_type(), "");
        // field 1 is the data
        let vector_data = self.builder.build_int_add(
            vector_int_value,
            self.context.i64_type().const_int(1, false),
            "",
        );
        self.builder.build_int_to_ptr(
            vector_data,
            self.context.i64_type().ptr_type(AddressSpace::default()),
            "vector_data",
        )
    }

    pub fn vector_zero_init(
        &self,
        function: FunctionValue<'a>,
        ty: &Type,
        from: IntValue<'a>,
        to: IntValue<'a>,
        data_ref: PointerValue<'a>,
        ns: &Namespace,
    ) {
        let cond = self.context.append_basic_block(function, "cond");
        let body = self.context.append_basic_block(function, "body");
        let done = self.context.append_basic_block(function, "done");

        let loop_ty = from.get_type();
        // create an alloca for the loop variable
        let index_alloca = self.build_alloca(function, loop_ty, "index_alloca");
        // initialize the loop variable with the starting value
        self.builder.build_store(index_alloca, from);

        self.builder.build_unconditional_branch(cond);
        self.builder.position_at_end(cond);

        // load current value of the loop variable
        let index_value = self
            .builder
            .build_load(loop_ty, index_alloca, "index_value")
            .into_int_value();

        let comp = self
            .builder
            .build_int_compare(IntPredicate::ULT, index_value, to, "loop_cond");
        self.builder.build_conditional_branch(comp, body, done);

        // build the loop body
        self.builder.position_at_end(body);

        let index_access = unsafe {
            self.builder.build_gep(
                self.llvm_type(ty, ns),
                data_ref,
                &[index_value],
                "index_access",
            )
        };

        self.builder
            .build_store(index_access, ty.default(&self, function, ns).unwrap());

        let next_index =
            self.builder
                .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");

        // store the incremented value back
        self.builder.build_store(index_alloca, next_index);

        self.builder.build_unconditional_branch(cond);

        self.builder.position_at_end(done);
    }

    /// Emit a loop from `from` to `to`. The closure exists to insert the body
    /// of the loop; the closure gets the loop variable passed to it as an
    /// IntValue, and a userdata IntValue
    pub(crate) fn emit_static_loop_with_int<F>(
        &self,
        function: FunctionValue<'a>,
        from: IntValue<'a>,
        to: IntValue<'a>,
        data_ref: &mut BasicValueEnum<'a>,
        mut insert_body: F,
    ) where
        F: FnMut(IntValue<'a>, &mut BasicValueEnum<'a>),
    {
        let body = self.context.append_basic_block(function, "body");
        let done = self.context.append_basic_block(function, "done");

        let loop_ty = from.get_type();
        // create an alloca for the loop variable
        let index_alloca = self.build_alloca(function, loop_ty, "index_alloca");
        // initialize the loop variable with the starting value
        self.builder.build_store(index_alloca, from);

        // Allocate a local variable for slot
        let data = self.build_alloca(function, data_ref.get_type(), "");

        self.builder.build_store(data, *data_ref);

        self.builder.build_unconditional_branch(body);
        self.builder.position_at_end(body);
        // load current value of the loop variable
        let index_value = self
            .builder
            .build_load(loop_ty, index_alloca, "index_value")
            .into_int_value();

        // Load the slot
        let mut data_val = self.builder.build_load(data_ref.get_type(), data, "");
        insert_body(index_value, &mut data_val);

        // Store the new slot
        self.builder.build_store(data, data_val);

        let next_index =
            self.builder
                .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");
        // store the incremented value back
        self.builder.build_store(index_alloca, next_index);
        let comp = self
            .builder
            .build_int_compare(IntPredicate::ULT, next_index, to, "loop_cond");
        self.builder.build_conditional_branch(comp, body, done);

        // insert at end of done block
        self.builder.position_at_end(done);
    }

    /// Emit a loop from `from` to `to`, checking the condition _before_ the
    /// body.
    pub fn emit_loop_cond_first_with_int<F>(
        &self,
        function: FunctionValue<'a>,
        from: IntValue<'a>,
        to: IntValue<'a>,
        data_ref: &mut BasicValueEnum<'a>,
        mut insert_body: F,
    ) where
        F: FnMut(IntValue<'a>, &mut BasicValueEnum<'a>),
    {
        let cond = self.context.append_basic_block(function, "cond");
        let body = self.context.append_basic_block(function, "body");
        let done = self.context.append_basic_block(function, "done");

        let loop_ty = from.get_type();
        // create an alloca for the loop variable
        let index_alloca = self.build_alloca(function, loop_ty, "index_alloca");
        // initialize the loop variable with the starting value
        self.builder.build_store(index_alloca, from);

        // Allocate a local variable for slot
        let data = self.build_alloca(function, data_ref.get_type(), "");

        self.builder.build_store(data, *data_ref);

        self.builder.build_unconditional_branch(cond);
        self.builder.position_at_end(cond);

        // load current value of the loop variable
        let index_value = self
            .builder
            .build_load(loop_ty, index_alloca, "index_value")
            .into_int_value();

        let comp = self
            .builder
            .build_int_compare(IntPredicate::ULT, index_value, to, "loop_cond");
        self.builder.build_conditional_branch(comp, body, done);

        // build the loop body
        self.builder.position_at_end(body);

        // Load the slot
        let mut data_val = self.builder.build_load(data_ref.get_type(), data, "");
        insert_body(index_value, &mut data_val);

        // Store the new slot
        self.builder.build_store(data, data_val);

        let next_index =
            self.builder
                .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");

        // store the incremented value back
        self.builder.build_store(index_alloca, next_index);

        self.builder.build_unconditional_branch(cond);

        self.builder.position_at_end(done);
    }

    /// Dereference an array
    pub(crate) fn array_subscript(
        &self,
        array_ty: &Type,
        array: BasicValueEnum<'a>,
        index: IntValue<'a>,
        ns: &Namespace,
    ) -> PointerValue<'a> {
        match array_ty {
            Type::Array(_, dim) => {
                if matches!(dim.last(), Some(ArrayLength::Fixed(_))) {
                    // fixed size array
                    let llvm_ty = self.llvm_type(array_ty, ns);
                    unsafe {
                        self.builder.build_gep(
                            llvm_ty,
                            array.into_pointer_value(),
                            &[index],
                            "index_access",
                        )
                    }
                } else {
                    let elem_ty = array_ty.array_deref();
                    let llvm_elem_ty = self.llvm_type(elem_ty.deref_memory(), ns);
                    let vector_ptr = self.vector_data(array);
                    unsafe {
                        self.builder
                            .build_gep(llvm_elem_ty, vector_ptr, &[index], "index_access")
                    }
                }
            }
            Type::String => {
                let elem_ty = array_ty.array_deref();
                let llvm_elem_ty = self.llvm_type(elem_ty.deref_memory(), ns);
                let vector_ptr = self.vector_data(array.into());
                unsafe {
                    self.builder
                        .build_gep(llvm_elem_ty, vector_ptr, &[index], "index_access")
                }
            }
            _ => unreachable!(),
        }
    }

    pub fn memcpy(&self, src: PointerValue<'a>, dest: PointerValue<'a>, len: IntValue<'a>) {
        // call memory call function
        let mempcy_function = self.module.get_function("memcpy").unwrap();
        self.builder
            .build_call(mempcy_function, &[src.into(), dest.into(), len.into()], "");
    }
    pub fn memcmp(
        &self,
        left: PointerValue<'a>,
        right: PointerValue<'a>,
        len: IntValue<'a>,
        op: IntPredicate,
    ) -> IntValue<'a> {
        let func_name = match op {
            IntPredicate::EQ => "memcmp_eq",
            IntPredicate::NE => "memcmp_ne",
            IntPredicate::UGT => "memcmp_ugt",
            IntPredicate::UGE => "memcmp_uge",
            _ => panic!("not implemented"),
        };
        let mempcy_function = self.module.get_function(func_name).unwrap();

        self.builder
            .build_call(
                mempcy_function,
                &[left.into(), right.into(), len.into()],
                "",
            )
            .try_as_basic_value()
            .left()
            .unwrap()
            .into_int_value()
    }

    pub fn convert_uint_storage(&self, value: BasicValueEnum<'a>) -> BasicValueEnum<'a> {
        let (_, heap_ptr) = self.heap_malloc(self.context.i64_type().const_int(4, false));
        self.builder.build_store(heap_ptr, value);
        for i in 1..4 {
            let elem_ptr = unsafe {
                self.builder.build_gep(
                    self.context.i64_type(),
                    heap_ptr,
                    &[self.context.i64_type().const_int(i, false)],
                    "",
                )
            };
            self.builder
                .build_store(elem_ptr, self.context.i64_type().const_zero());
        }
        heap_ptr.into()
    }

    pub fn range_check(&self, value: IntValue<'a>) {
        if !value.is_const() {
            // check if value is out of bounds
            self.builder.build_call(
                self.module
                    .get_function("builtin_range_check")
                    .expect("builtin_range_check should have been defined before"),
                &[value.into()],
                "range_check",
            );
        }
    }
}
