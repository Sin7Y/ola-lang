// SPDX-License-Identifier: Apache-2.0

use crate::{
    irgen::binary::Binary,
    sema::ast::{Namespace, Type},
};
use inkwell::{
    values::{FunctionValue, IntValue},
    IntPredicate,
};
use num_bigint::BigInt;
use num_traits::{ToPrimitive, Zero};
use std::ops::AddAssign;

/// When we are decoding serialized data from a bytes array, we must constantly
/// verify if we are not reading past its ending. This struct helps us decrease
/// the number of checks we do, by merging checks when we can determine the size
/// of what to read beforehand.
pub(crate) struct BufferValidator<'a> {
    /// Saves the codegen::Expression that contains the buffer length.
    buffer_length: IntValue<'a>,
    /// The types we are supposed to decode
    types: Vec<Type>,
    /// The argument whose size has already been accounted for when verifying
    /// the buffer
    verified_until: Option<usize>,
    /// The argument we are analysing presently
    current_arg: usize,
}

impl<'a> BufferValidator<'a> {
    pub fn new(buffer_size_var: IntValue<'a>, types: Vec<Type>) -> BufferValidator<'a> {
        BufferValidator {
            buffer_length: buffer_size_var,
            types,
            verified_until: None,
            current_arg: 0,
        }
    }

    /// Set which item we are currently reading from the buffer
    pub(super) fn set_argument_number(&mut self, arg_no: usize) {
        self.current_arg = arg_no;
    }

    /// Initialize the validator, by verifying every type that has a fixed size
    pub(super) fn initialize_validation(
        &mut self,
        bin: &Binary<'a>,
        offset: IntValue<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) {
        // -1 means nothing has been verified yet
        self.verified_until = None;
        self._verify_buffer(bin, offset, func_value, ns);
    }

    /// Validate the buffer for the current argument, if necessary.
    pub(super) fn validate_buffer(
        &mut self,
        bin: &Binary<'a>,
        offset: IntValue<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) {
        // We may have already verified this
        if self.verified_until.is_some() && self.current_arg <= self.verified_until.unwrap() {
            return;
        }

        self._verify_buffer(bin, offset, func_value, ns);
    }

    /// Validate if a given offset is within the buffer's bound.
    pub(super) fn validate_offset(
        &self,
        bin: &Binary<'a>,
        offset: IntValue<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) {
        self.build_out_of_bounds_fail_branch(bin, offset, func_value, ns);
    }

    /// Checks if a buffer validation is necessary
    pub(super) fn validation_necessary(&self) -> bool {
        self.verified_until.is_none() || self.current_arg > self.verified_until.unwrap()
    }

    /// After an array validation, we do not need to re-check its elements.
    pub(super) fn validate_array(&mut self) {
        self.verified_until = Some(self.current_arg);
    }

    /// Validate if offset + size is within the buffer's boundaries
    pub(super) fn validate_offset_plus_size(
        &mut self,
        bin: &Binary<'a>,
        offset: IntValue<'a>,
        size: IntValue<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) {
        if self.validation_necessary() {
            let offset_to_validate = bin.builder.build_int_add(offset, size, "");

            self.validate_offset(bin, offset_to_validate, func_value, ns);
        }
    }

    /// Validates if we have read all the bytes in a buffer
    pub(super) fn validate_all_bytes_read(
        &self,
        bin: &Binary<'a>,
        end_offset: IntValue<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) {
        let cond = bin
            .builder
            .build_int_compare(IntPredicate::ULT, end_offset, self.buffer_length, "")
            .into();

        let invaild = bin
            .context
            .append_basic_block(func_value, "not_all_bytes_read");
        let valid = bin.context.append_basic_block(func_value, "buffer_read");

        bin.builder.build_conditional_branch(cond, invaild, valid);

        bin.builder.position_at_end(invaild);
        // TODO: This needs a proper error message

        bin.builder.position_at_end(valid);
    }

    /// Auxiliary function to verify if the offset is valid.
    fn _verify_buffer(
        &mut self,
        bin: &Binary<'a>,
        offset: IntValue<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) {
        // Calculate the what arguments we can validate
        let mut maximum_verifiable = self.current_arg;
        for i in self.current_arg..self.types.len() {
            if !self.types[i].is_dynamic(ns) {
                maximum_verifiable = i;
            } else {
                break;
            }
        }

        // It is not possible to validate anything
        if maximum_verifiable == self.current_arg {
            return;
        }

        // Create validation check
        let mut advance = BigInt::zero();
        for i in self.current_arg..=maximum_verifiable {
            advance.add_assign(self.types[i].memory_size_of(ns));
        }

        let reach = bin.builder.build_int_add(
            offset,
            bin.context
                .i64_type()
                .const_int(advance.to_u64().unwrap(), false),
            "",
        );

        self.verified_until = Some(maximum_verifiable);
        self.build_out_of_bounds_fail_branch(bin, reach, func_value, ns);
    }

    /// Builds a branch for failing if we are out of bounds
    fn build_out_of_bounds_fail_branch(
        &self,
        bin: &Binary<'a>,
        offset: IntValue<'a>,
        func_value: FunctionValue<'a>,
        ns: &Namespace,
    ) {
        let cond = bin
            .builder
            .build_int_compare(IntPredicate::ULE, offset, self.buffer_length, "")
            .into();

        let inbounds_block = bin.context.append_basic_block(func_value, "inbounds");
        let out_of_bounds_block = bin.context.append_basic_block(func_value, "out_of_bounds");
        bin.builder
            .build_conditional_branch(cond, inbounds_block, out_of_bounds_block);
        bin.builder.position_at_end(out_of_bounds_block);
        // TODO: Add an error message here

        bin.builder.position_at_end(inbounds_block);
    }

    /// Create a new buffer validator to validate struct fields.
    pub(crate) fn create_sub_validator(&self, types: Vec<Type>) -> BufferValidator<'a> {
        // If the struct has been previously validated, there is no need to validate it
        // again, so verified_until and current_arg are set to type.len() to
        // avoid any further validation.
        let len = types.len();
        BufferValidator {
            buffer_length: self.buffer_length.clone(),
            types,
            verified_until: if self.validation_necessary() {
                None
            } else {
                Some(len)
            },
            current_arg: if self.validation_necessary() { 0 } else { len },
        }
    }
}
