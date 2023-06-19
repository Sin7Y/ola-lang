use crate::sema::ast::{ArrayLength, Contract, Namespace, Type};
use std::path::Path;
use std::str;

use num_bigint::BigInt;
use num_traits::ToPrimitive;

use crate::irgen::corelib::gen_lib_functions;
use crate::irgen::functions::gen_functions;
use inkwell::basic_block::BasicBlock;
use inkwell::builder::Builder;
use inkwell::context::Context;
use inkwell::module::Module;
use inkwell::types::{
    ArrayType, BasicMetadataTypeEnum, BasicType, BasicTypeEnum, FunctionType, StringRadix,
};
use inkwell::values::{BasicValueEnum, FunctionValue, IntValue, PointerValue};
use inkwell::{AddressSpace, IntPredicate};

pub struct Binary<'a> {
    pub name: String,
    pub module: Module<'a>,
    pub builder: Builder<'a>,
    pub(crate) context: &'a Context,
    pub loops: Vec<(BasicBlock<'a>, BasicBlock<'a>)>,
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

        Binary {
            name: name.to_owned(),
            module,
            builder,
            context,
            loops: Vec::new(),
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
            Type::Uint(32) => {
                let ty = self.context.i64_type();
                let s = n.to_string();
                ty.const_int_from_string(&s, StringRadix::Decimal)
                    .unwrap()
                    .into()
            }
            _ => panic!("not implemented"),
        }
    }

    /// Convert a BigInt array to llvm const array value
    pub(crate) fn address_literal(&self, value: &Vec<BigInt>) -> BasicValueEnum<'a> {
        let ty = self.context.i64_type();
        let mut v = Vec::new();

        for i in 0..4 {
            let s = value[i].to_string();
            v.push(ty.const_int_from_string(&s, StringRadix::Decimal).unwrap());
        }

        ty.const_array(&v).into()
    }

    /// llvm address type
    pub(crate) fn address_type(&self) -> ArrayType<'a> {
        self.context.i64_type().array_type(4 as u32)
    }

    /// Emit function prototype
    pub(crate) fn function_type(
        &self,
        params: &[Type],
        returns: &[Type],
        ns: &Namespace,
    ) -> FunctionType<'a> {
        // function parameters
        let args = params
            .iter()
            .map(|ty| self.llvm_var_ty(ty, ns).into())
            .collect::<Vec<BasicMetadataTypeEnum>>();

        return if returns.is_empty() {
            let void_type = self.context.void_type();
            void_type.fn_type(&args, false)
        } else if returns.len() == 1 {
            let return_type = self.llvm_var_ty(&returns[0], ns);
            return_type.fn_type(&args, false)
        } else {
            // when function return multiple values, we need to return a struct
            let struct_returns = returns
                .iter()
                .map(|ty| self.llvm_var_ty(ty, ns).into())
                .collect::<Vec<BasicTypeEnum>>();
            let struct_type = self.context.struct_type(&struct_returns, false);
            struct_type.fn_type(&args, false)
        };
    }

    /// Return the llvm type for a variable holding the type, not the type
    /// itself
    pub(crate) fn llvm_var_ty(&self, ty: &Type, ns: &Namespace) -> BasicTypeEnum<'a> {
        let llvm_ty = self.llvm_type(ty, ns);
        match ty.deref_memory() {
            Type::Struct(_) | Type::Array(..) => llvm_ty
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
            Type::String => llvm_ty
                .ptr_type(AddressSpace::default())
                .as_basic_type_enum(),
            _ => llvm_ty,
        }
    }

    /// Return the llvm type for the resolved type.
    pub(crate) fn llvm_type(&self, ty: &Type, ns: &Namespace) -> BasicTypeEnum<'a> {
        match ty {
            Type::Bool => BasicTypeEnum::IntType(self.context.bool_type()),
            // Map all i32 data to a field-based data type, with the maximum value of field between
            // u63 and u64
            Type::Uint(32) => self.context.i64_type().into(),
            Type::Contract(_) | Type::Address => BasicTypeEnum::ArrayType(self.address_type()),
            Type::Enum(n) => self.llvm_type(&ns.enums[*n].ty, ns),
            Type::Array(base_ty, dims) => {
                let ty = self.llvm_field_ty(base_ty, ns);

                let mut dims = dims.iter();

                let mut aty = match dims.next().unwrap() {
                    ArrayLength::Fixed(d) => ty.array_type(d.to_u32().unwrap()),
                    ArrayLength::Dynamic => return self.create_struct_vector(),
                    ArrayLength::AnyFixed => {
                        unreachable!()
                    }
                };

                for dim in dims {
                    match dim {
                        ArrayLength::Fixed(d) => aty = aty.array_type(d.to_u32().unwrap()),
                        ArrayLength::Dynamic => return self.create_struct_vector(),
                        ArrayLength::AnyFixed => {
                            unreachable!()
                        }
                    }
                }

                BasicTypeEnum::ArrayType(aty)
            }
            Type::String => self.create_struct_vector(),
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

    pub(crate) fn build_array_alloca<T: BasicType<'a>>(
        &self,
        function: inkwell::values::FunctionValue<'a>,
        ty: T,
        length: IntValue<'a>,
        name: &str,
    ) -> PointerValue<'a> {
        let entry = function
            .get_first_basic_block()
            .expect("function missing entry block");
        let current = self.builder.get_insert_block().unwrap();

        if let Some(instr) = entry.get_first_instruction() {
            self.builder.position_before(&instr);
        } else {
            self.builder.position_at_end(entry);
        }

        let res = self.builder.build_array_alloca(ty, length, name);

        self.builder.position_at_end(current);

        res
    }

    /// Allocate vector
    pub(crate) fn vector_new(
        &self,
        size: IntValue<'a>,
        init: Option<&Vec<u32>>,
    ) -> PointerValue<'a> {
        if let Some(init) = init {
            if init.is_empty() {
                return self
                    .create_struct_vector()
                    .ptr_type(AddressSpace::default())
                    .const_null();
            }
        }

        let init = match init {
            None => self
                .context
                .i64_type()
                .ptr_type(AddressSpace::default())
                .const_null(),
            Some(..) => unimplemented!(),
        };

        self.builder
            .build_call(
                self.module.get_function("vector_new").unwrap(),
                &[size.into(), init.into()],
                "",
            )
            .try_as_basic_value()
            .left()
            .unwrap()
            .into_pointer_value()
    }

    pub(crate) fn create_struct_vector(&self) -> BasicTypeEnum<'a> {
        let length_type = self.context.i64_type();
        let data_array_type = self.context.i64_type().ptr_type(AddressSpace::default());
        let struct_type = self
            .context
            .struct_type(&[length_type.into(), data_array_type.into()], false);

        struct_type.as_basic_type_enum()
    }

    /// Number of element in a vector
    pub(crate) fn vector_len(&self, vector: BasicValueEnum<'a>) -> IntValue<'a> {
        if vector.is_struct_value() {
            // slice
            let slice = vector.into_struct_value();

            self.builder.build_int_truncate(
                self.builder
                    .build_extract_value(slice, 1, "slice_len")
                    .unwrap()
                    .into_int_value(),
                self.context.i64_type(),
                "len",
            )
        } else {
            // field 0 is the length
            let vector = vector.into_pointer_value();
            let vector_type = self.create_struct_vector();

            let len = self
                .builder
                .build_struct_gep(vector_type, vector, 0, "vector_len")
                .unwrap();

            self.builder
                .build_load(self.context.i64_type(), len, "length")
                .into_int_value()
        }
    }

    /// Return the pointer to the actual bytes in the vector
    pub(crate) fn vector_data(&self, vector: BasicValueEnum<'a>) -> PointerValue<'a> {
        if vector.is_struct_value() {
            // slice
            let slice = vector.into_struct_value();
            self.builder
                .build_extract_value(slice, 0, "slice_data")
                .unwrap()
                .into_pointer_value()
        } else {
            let vector_type = self.create_struct_vector();
            self.builder
                .build_struct_gep(vector_type, vector.into_pointer_value(), 1, "data")
                .unwrap()
        }
    }

    /// Emit a loop from `from` to `to`. The closure exists to insert the body
    /// of the loop; the closure gets the loop variable passed to it as an
    /// IntValue, and a userdata IntValue
    pub(crate) fn emit_static_loop_with_int<F>(
        &self,
        function: FunctionValue,
        from: IntValue<'a>,
        to: IntValue<'a>,
        data_ref: &mut BasicValueEnum<'a>,
        mut insert_body: F,
    ) where
        F: FnMut(IntValue<'a>, &mut BasicValueEnum<'a>),
    {
        let body = self.context.append_basic_block(function, "body");
        let done = self.context.append_basic_block(function, "done");
        let entry = self.builder.get_insert_block().unwrap();

        self.builder.build_unconditional_branch(body);
        self.builder.position_at_end(body);

        let loop_ty = from.get_type();
        let loop_phi = self.builder.build_phi(loop_ty, "index");
        let data_phi = self.builder.build_phi(data_ref.get_type(), "data");
        let mut data = data_phi.as_basic_value();

        let loop_var = loop_phi.as_basic_value().into_int_value();

        // add loop body
        insert_body(loop_var, &mut data);

        let next = self
            .builder
            .build_int_add(loop_var, loop_ty.const_int(1, false), "next_index");

        let comp = self
            .builder
            .build_int_compare(IntPredicate::ULT, next, to, "loop_cond");
        self.builder.build_conditional_branch(comp, body, done);

        let body = self.builder.get_insert_block().unwrap();
        loop_phi.add_incoming(&[(&from, entry), (&next, body)]);
        data_phi.add_incoming(&[(&*data_ref, entry), (&data, body)]);

        self.builder.position_at_end(done);

        *data_ref = data;
    }

    /// Emit a loop from `from` to `to`, checking the condition _before_ the
    /// body.
    pub fn emit_loop_cond_first_with_int<F>(
        &self,
        function: FunctionValue,
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
        let entry = self.builder.get_insert_block().unwrap();

        self.builder.build_unconditional_branch(cond);
        self.builder.position_at_end(cond);

        let loop_ty = from.get_type();
        let loop_phi = self.builder.build_phi(loop_ty, "index");
        let data_phi = self.builder.build_phi(data_ref.get_type(), "data");
        let mut data = data_phi.as_basic_value();

        let loop_var = loop_phi.as_basic_value().into_int_value();

        let next = self
            .builder
            .build_int_add(loop_var, loop_ty.const_int(1, false), "next_index");

        let comp = self
            .builder
            .build_int_compare(IntPredicate::ULT, loop_var, to, "loop_cond");
        self.builder.build_conditional_branch(comp, body, done);

        self.builder.position_at_end(body);
        // add loop body
        insert_body(loop_var, &mut data);

        let body = self.builder.get_insert_block().unwrap();

        loop_phi.add_incoming(&[(&from, entry), (&next, body)]);
        data_phi.add_incoming(&[(&*data_ref, entry), (&data, body)]);

        self.builder.build_unconditional_branch(cond);

        self.builder.position_at_end(done);

        *data_ref = data_phi.as_basic_value();
    }

    /// Dereference an array
    pub(crate) fn array_subscript(
        &self,
        array_ty: &Type,
        array: PointerValue<'a>,
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
                            array,
                            &[self.context.i64_type().const_zero(), index],
                            "index_access",
                        )
                    }
                } else {
                    let elem_ty = array_ty.array_deref();
                    let llvm_elem_ty = self.llvm_type(elem_ty.deref_memory(), ns);

                    let vector_type = self.create_struct_vector();

                    unsafe {
                        self.builder.build_gep(
                            vector_type,
                            array,
                            &[
                                self.context.i32_type().const_zero(),
                                self.context.i32_type().const_int(1, false),
                                index,
                            ],
                            "index_access",
                        )
                    }
                }
            }
            _ => unreachable!(),
        }
    }
}
