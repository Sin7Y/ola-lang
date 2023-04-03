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
use inkwell::types::{BasicMetadataTypeEnum, BasicType, BasicTypeEnum, FunctionType, StringRadix};
use inkwell::values::{IntValue, PointerValue};
use inkwell::AddressSpace;

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

    // /// Default empty value
    // pub(crate) fn default_value(&self, ty: &Type, ns: &Namespace) ->
    // BasicValueEnum<'a> {     let llvm_ty = self.llvm_var_ty(ty, ns);
    //
    //     // const_zero() on BasicTypeEnum yet. Should be coming to inkwell soon
    //     if llvm_ty.is_pointer_type() {
    //         llvm_ty.into_pointer_type().const_null().into()
    //     } else {
    //         llvm_ty.into_int_type().const_zero().into()
    //     }
    // }

    /// Convert a BigInt number to llvm const value
    /// we should slice and dice into pointer array types.
    /// Currently we only support u32 type data.
    pub(crate) fn number_literal(&self, ty: &Type, n: &BigInt, _ns: &Namespace) -> IntValue<'a> {
        match ty {
            // Map all i32 data to a field-based data type,
            // with the maximum value of field between u63 and u64.
            Type::Uint(32) => {
                let ty = self.context.i64_type();
                let s = n.to_string();
                ty.const_int_from_string(&s, StringRadix::Decimal).unwrap()
            }
            _ => panic!("not implemented"),
        }
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

        if returns.is_empty() {
            let void_type = self.context.void_type();
            return void_type.fn_type(&args, false);
        }
        let i64_type = self.context.i64_type();
        i64_type.fn_type(&args, false)
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
            _ => llvm_ty,
        }
    }

    /// Return the llvm type for the resolved type.
    pub(crate) fn llvm_type(&self, ty: &Type, ns: &Namespace) -> BasicTypeEnum<'a> {
        match ty {
            Type::Bool => BasicTypeEnum::IntType(self.context.bool_type()),
            // Map all i32 data to a field-based data type, with the maximum value of field between
            // u63 and u64
            Type::Uint(32) => BasicTypeEnum::IntType(self.context.i64_type()),
            Type::Enum(n) => self.llvm_type(&ns.enums[*n].ty, ns),
            Type::Array(base_ty, dims) => {
                let ty = self.llvm_field_ty(base_ty, ns);

                let mut dims = dims.iter();

                let mut aty = match dims.next().unwrap() {
                    ArrayLength::Fixed(d) => ty.array_type(d.to_u32().unwrap()),
                    ArrayLength::Dynamic => {
                        return self.module.get_struct_type("struct.vector").unwrap().into()
                    }
                    ArrayLength::AnyFixed => {
                        unreachable!()
                    }
                };

                for dim in dims {
                    match dim {
                        ArrayLength::Fixed(d) => aty = aty.array_type(d.to_u32().unwrap()),
                        ArrayLength::Dynamic => {
                            return self.module.get_struct_type("struct.vector").unwrap().into()
                        }
                        ArrayLength::AnyFixed => {
                            unreachable!()
                        }
                    }
                }

                BasicTypeEnum::ArrayType(aty)
            }
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
            Type::Function {
                params, returns, ..
            } => {
                let fn_type = self.function_type(params, returns, ns);

                BasicTypeEnum::PointerType(fn_type.ptr_type(AddressSpace::default()))
            }
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
}
