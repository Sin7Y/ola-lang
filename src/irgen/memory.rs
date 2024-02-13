use crate::irgen::binary::Binary;
use inkwell::values::{BasicValue, FunctionValue};
use inkwell::{AddressSpace, IntPredicate};

pub const TWO_POWER: u64 = u32::MAX as u64 + 1;

pub fn define_fields_concat<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let left_value = function.get_nth_param(0).unwrap().into();
    let right_value = function.get_nth_param(1).unwrap().into();
    let left_len = bin.vector_len(left_value);
    let left_data = bin.vector_data(right_value);
    let right_len = bin.vector_len(left_value);
    let right_data = bin.vector_data(right_value);
    let new_len = bin.builder.build_int_add(left_len, right_len, "new_len");
    let dest_fields = bin.vector_new(new_len);

    let mut new_fields_data = bin.vector_data(dest_fields.as_basic_value_enum());

    bin.memcpy(left_data, new_fields_data, left_len);

    new_fields_data = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type().ptr_type(AddressSpace::default()),
            new_fields_data,
            &[left_len],
            "new_fields_data",
        )
    };

    bin.memcpy(right_data, new_fields_data, right_len);
    bin.builder.build_return(Some(&dest_fields));
}

pub fn define_heap_malloc<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let size = function.get_first_param().unwrap().into_int_value();
    let current_heap_address = bin
        .builder
        .build_load(
            bin.context.i64_type(),
            bin.heap_address.as_pointer_value(),
            "current_address",
        )
        .into_int_value();
    let updated_address = bin
        .builder
        .build_int_add(current_heap_address, size, "updated_address");

    bin.builder
        .build_store(bin.heap_address.as_pointer_value(), updated_address);

    let current_heap_address = bin.builder.build_int_to_ptr(
        current_heap_address,
        bin.context.i64_type().ptr_type(AddressSpace::default()),
        "",
    );

    bin.builder.build_return(Some(&current_heap_address));
}

pub fn define_vector_new<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let size = function.get_first_param().unwrap().into_int_value();
    let size_add_one =
        bin.builder
            .build_int_add(size, bin.context.i64_type().const_int(1, false), "");
    let current_heap_address = bin
        .builder
        .build_load(
            bin.context.i64_type(),
            bin.heap_address.as_pointer_value(),
            "current_address",
        )
        .into_int_value();

    let updated_address =
        bin.builder
            .build_int_add(current_heap_address, size_add_one, "updated_address");

    bin.builder
        .build_store(bin.heap_address.as_pointer_value(), updated_address);

    let current_heap_address = bin.builder.build_int_to_ptr(
        current_heap_address,
        bin.context.i64_type().ptr_type(AddressSpace::default()),
        "",
    );
    bin.builder.build_store(current_heap_address, size);

    bin.builder.build_return(Some(&current_heap_address));
}

pub fn define_memcpy<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let src_ptr = function.get_nth_param(0).unwrap().into_pointer_value();

    let dest_ptr = function.get_nth_param(1).unwrap().into_pointer_value();

    let len = function.get_nth_param(2).unwrap().into_int_value();

    let cond = bin.context.append_basic_block(function, "cond");
    let body = bin.context.append_basic_block(function, "body");
    let done = bin.context.append_basic_block(function, "done");

    let loop_ty = bin.context.i64_type();
    // create an alloca for the loop variable
    let index_alloca = bin.build_alloca(function, loop_ty, "index_alloca");
    // initialize the loop variable with the starting value
    bin.builder.build_store(index_alloca, loop_ty.const_zero());

    bin.builder.build_unconditional_branch(cond);
    bin.builder.position_at_end(cond);

    // load current value of the loop variable
    let index_value = bin
        .builder
        .build_load(loop_ty, index_alloca, "index_value")
        .into_int_value();

    let comp = bin
        .builder
        .build_int_compare(IntPredicate::ULT, index_value, len, "loop_cond");
    bin.builder.build_conditional_branch(comp, body, done);

    // memory copy start
    bin.builder.position_at_end(body);

    let src_access = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            src_ptr,
            &[index_value],
            "src_index_access",
        )
    };

    let src_value = bin
        .builder
        .build_load(bin.context.i64_type(), src_access, "");

    let dest_access = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            dest_ptr,
            &[index_value],
            "dest_index_access",
        )
    };

    bin.builder.build_store(dest_access, src_value);

    // memory copy end
    let next_index =
        bin.builder
            .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");

    // store the incremented value back
    bin.builder.build_store(index_alloca, next_index);

    bin.builder.build_unconditional_branch(cond);

    bin.builder.position_at_end(done);
    bin.builder.build_return(None);
}

pub fn define_split_field<'a>(bin: &Binary<'a>, function: FunctionValue<'a>) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let field_input = function.get_nth_param(0).unwrap();
    let high_output = function.get_nth_param(1).unwrap();
    let low_output = function.get_nth_param(2).unwrap();

    let field_high = bin
        .builder
        .build_call(
            bin.module.get_function("prophet_split_field_high").unwrap(),
            &[field_input.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[field_high.into()],
        "",
    );

    let field_low = bin
        .builder
        .build_call(
            bin.module.get_function("prophet_split_field_low").unwrap(),
            &[field_input.into()],
            "",
        )
        .try_as_basic_value()
        .left()
        .expect("Should have a left return value");
    bin.builder.build_call(
        bin.module.get_function("builtin_range_check").unwrap(),
        &[field_low.into()],
        "",
    );

    let high_value = bin.builder.build_int_mul(
        field_high.into_int_value(),
        bin.context.i64_type().const_int(TWO_POWER, false),
        "",
    );

    let result = bin
        .builder
        .build_int_add(high_value, field_low.into_int_value(), "");

    let equal = bin.builder.build_int_compare(
        inkwell::IntPredicate::EQ,
        field_input.into_int_value(),
        result,
        "",
    );
    bin.builder.build_call(
        bin.module.get_function("builtin_assert").unwrap(),
        &[bin
            .builder
            .build_int_z_extend(equal, bin.context.i64_type(), "")
            .into()],
        "",
    );

    bin.builder
        .build_store(high_output.into_pointer_value(), field_high);
    bin.builder
        .build_store(low_output.into_pointer_value(), field_low);

    bin.builder.build_return(None);
}

pub fn define_mem_compare<'a>(bin: &Binary<'a>, function: FunctionValue<'a>, op: IntPredicate) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let left_ptr = function.get_nth_param(0).unwrap().into_pointer_value();
    let right_ptr = function.get_nth_param(1).unwrap().into_pointer_value();
    let len = function.get_nth_param(2).unwrap().into_int_value();

    let loop_ty = bin.context.i64_type();
    let index_alloca = bin.build_alloca(function, loop_ty, "index_alloca");
    bin.builder.build_store(index_alloca, loop_ty.const_zero());

    let cond = bin.context.append_basic_block(function, "cond");
    bin.builder.build_unconditional_branch(cond);
    bin.builder.position_at_end(cond);

    let index_value = bin
        .builder
        .build_load(loop_ty, index_alloca, "index_value")
        .into_int_value();
    let loop_check =
        bin.builder
            .build_int_compare(IntPredicate::ULT, index_value, len, "loop_check");
    let body = bin.context.append_basic_block(function, "body");
    let done = bin.context.append_basic_block(function, "done");
    bin.builder.build_conditional_branch(loop_check, body, done);

    bin.builder.position_at_end(body);
    let left_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            left_ptr,
            &[index_value],
            "left_elem_ptr",
        )
    };
    let left_elem = bin
        .builder
        .build_load(bin.context.i64_type(), left_elem_ptr, "left_elem")
        .into_int_value();
    let right_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            right_ptr,
            &[index_value],
            "right_elem_ptr",
        )
    };
    let right_elem = bin
        .builder
        .build_load(bin.context.i64_type(), right_elem_ptr, "right_elem")
        .into_int_value();

    let next_index =
        bin.builder
            .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");
    bin.builder.build_store(index_alloca, next_index);
    let phi_node = match op {
        IntPredicate::EQ | IntPredicate::UGE => {
            let compare = bin
                .builder
                .build_int_compare(op, left_elem, right_elem, "compare");
            bin.builder.build_conditional_branch(compare, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), cond),
                (&bin.context.i64_type().const_zero(), body),
            ]);
            phi_node
        }
        IntPredicate::NE => {
            let compare =
                bin.builder
                    .build_int_compare(IntPredicate::EQ, left_elem, right_elem, "compare");
            bin.builder.build_conditional_branch(compare, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), body),
                (&bin.context.i64_type().const_zero(), cond),
            ]);
            phi_node
        }

        IntPredicate::UGT => {
            let compare =
                bin.builder
                    .build_int_compare(IntPredicate::UGE, right_elem, left_elem, "compare");
            bin.builder.build_conditional_branch(compare, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), body),
                (&bin.context.i64_type().const_zero(), cond),
            ]);
            phi_node
        }
        IntPredicate::ULT => {
            let compare =
                bin.builder
                    .build_int_compare(IntPredicate::UGE, left_elem, right_elem, "compare");
            bin.builder.build_conditional_branch(compare, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), body),
                (&bin.context.i64_type().const_zero(), cond),
            ]);
            phi_node
        }
        IntPredicate::ULE => {
            let compare =
                bin.builder
                    .build_int_compare(IntPredicate::UGE, right_elem, left_elem, "compare");
            bin.builder.build_conditional_branch(compare, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), cond),
                (&bin.context.i64_type().const_zero(), body),
            ]);
            phi_node
        }
        _ => unreachable!(),
    };

    bin.builder.build_return(Some(&phi_node.as_basic_value()));
}

pub fn define_field_mem_compare<'a>(
    bin: &Binary<'a>,
    function: FunctionValue<'a>,
    op: IntPredicate,
) {
    bin.builder
        .position_at_end(bin.context.append_basic_block(function, "entry"));
    let left_ptr = function.get_nth_param(0).unwrap();
    let right_ptr = function.get_nth_param(1).unwrap();
    let len = function.get_nth_param(2).unwrap();

    let loop_ty = bin.context.i64_type();
    let index_alloca = bin.build_alloca(function, loop_ty, "index_alloca");
    bin.builder.build_store(index_alloca, loop_ty.const_zero());

    let cond = bin.context.append_basic_block(function, "cond");
    bin.builder.build_unconditional_branch(cond);
    bin.builder.position_at_end(cond);

    let index_value = bin
        .builder
        .build_load(loop_ty, index_alloca, "index_value")
        .into_int_value();
    let loop_check = bin.builder.build_int_compare(
        IntPredicate::ULT,
        index_value,
        len.into_int_value(),
        "loop_check",
    );
    let body = bin.context.append_basic_block(function, "body");
    let low_compare_block = bin
        .context
        .append_basic_block(function, "low_compare_block");
    let done = bin.context.append_basic_block(function, "done");

    bin.builder.build_conditional_branch(loop_check, body, done);

    bin.builder.position_at_end(body);
    let left_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            left_ptr.into_pointer_value(),
            &[index_value],
            "left_elem_ptr",
        )
    };
    let left_elem = bin
        .builder
        .build_load(bin.context.i64_type(), left_elem_ptr, "left_elem")
        .into_int_value();

    let right_elem_ptr = unsafe {
        bin.builder.build_gep(
            bin.context.i64_type(),
            right_ptr.into_pointer_value(),
            &[index_value],
            "right_elem_ptr",
        )
    };
    let right_elem = bin
        .builder
        .build_load(bin.context.i64_type(), right_elem_ptr, "right_elem")
        .into_int_value();

    let left_high = bin.build_alloca(function, bin.context.i64_type(), "left_high");
    let left_low = bin.build_alloca(function, bin.context.i64_type(), "left_low");

    bin.builder.build_call(
        bin.module.get_function("split_field").unwrap(),
        &[left_elem.into(), left_high.into(), left_low.into()],
        "",
    );

    let left_high = bin
        .builder
        .build_load(bin.context.i64_type(), left_high, "")
        .into_int_value();

    let left_low = bin
        .builder
        .build_load(bin.context.i64_type(), left_low, "")
        .into_int_value();

    let right_high = bin.build_alloca(function, bin.context.i64_type(), "right_high");
    let right_low = bin.build_alloca(function, bin.context.i64_type(), "right_low");

    bin.builder.build_call(
        bin.module.get_function("split_field").unwrap(),
        &[right_elem.into(), right_high.into(), right_low.into()],
        "",
    );

    let right_high = bin
        .builder
        .build_load(bin.context.i64_type(), right_high, "")
        .into_int_value();

    let right_low = bin
        .builder
        .build_load(bin.context.i64_type(), right_low, "")
        .into_int_value();

    let next_index =
        bin.builder
            .build_int_add(index_value, loop_ty.const_int(1, false), "next_index");
    bin.builder.build_store(index_alloca, next_index);

    let phi_node = match op {
        IntPredicate::UGE => {
            let compare_high =
                bin.builder
                    .build_int_compare(op, left_high, right_high, "compare_high");
            bin.builder
                .build_conditional_branch(compare_high, low_compare_block, done);

            bin.builder.position_at_end(low_compare_block);

            let compare_low = bin
                .builder
                .build_int_compare(op, left_low, right_low, "compare_low");
            bin.builder
                .build_conditional_branch(compare_low, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), cond),
                (&bin.context.i64_type().const_zero(), body),
                (&bin.context.i64_type().const_zero(), low_compare_block),
            ]);
            phi_node
        }

        IntPredicate::UGT => {
            let compare_high = bin.builder.build_int_compare(
                IntPredicate::UGE,
                right_high,
                left_high,
                "compare_high",
            );
            bin.builder
                .build_conditional_branch(compare_high, low_compare_block, done);

            bin.builder.position_at_end(low_compare_block);

            let compare_low = bin.builder.build_int_compare(
                IntPredicate::UGE,
                right_low,
                left_low,
                "compare_low",
            );
            bin.builder
                .build_conditional_branch(compare_low, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), body),
                (
                    &bin.context.i64_type().const_int(1, false),
                    low_compare_block,
                ),
                (&bin.context.i64_type().const_zero(), cond),
            ]);
            phi_node
        }
        IntPredicate::ULT => {
            let compare_high = bin.builder.build_int_compare(
                IntPredicate::UGE,
                left_high,
                right_high,
                "compare_high",
            );
            bin.builder
                .build_conditional_branch(compare_high, low_compare_block, done);

            bin.builder.position_at_end(low_compare_block);

            let compare_low = bin.builder.build_int_compare(
                IntPredicate::UGE,
                left_low,
                right_low,
                "compare_low",
            );
            bin.builder
                .build_conditional_branch(compare_low, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), body),
                (
                    &bin.context.i64_type().const_int(1, false),
                    low_compare_block,
                ),
                (&bin.context.i64_type().const_zero(), cond),
            ]);
            phi_node
        }

        IntPredicate::ULE => {
            let compare_high = bin.builder.build_int_compare(
                IntPredicate::UGE,
                right_high,
                left_high,
                "compare_high",
            );
            bin.builder
                .build_conditional_branch(compare_high, low_compare_block, done);

            bin.builder.position_at_end(low_compare_block);

            let compare_low = bin.builder.build_int_compare(
                IntPredicate::UGE,
                right_low,
                left_low,
                "compare_low",
            );
            bin.builder
                .build_conditional_branch(compare_low, cond, done);
            bin.builder.position_at_end(done);
            let phi_node = bin.builder.build_phi(bin.context.i64_type(), "result_phi");
            phi_node.add_incoming(&[
                (&bin.context.i64_type().const_int(1, false), cond),
                (&bin.context.i64_type().const_zero(), body),
                (&bin.context.i64_type().const_zero(), low_compare_block),
            ]);
            phi_node
        }
        _ => unreachable!(),
    };
    bin.builder.build_return(Some(&phi_node.as_basic_value()));
}
