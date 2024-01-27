; ModuleID = 'Caller'
source_filename = "caller"

@heap_address = internal global i64 -12884901885

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @builtin_check_ecdsa(ptr)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @prophet_split_field_high(i64)

declare i64 @prophet_split_field_low(i64)

declare void @get_context_data(ptr, i64)

declare void @get_tape_data(ptr, i64)

declare void @set_tape_data(ptr, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define ptr @heap_malloc(i64 %0) {
entry:
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %0
  store i64 %updated_address, ptr @heap_address, align 4
  %1 = inttoptr i64 %current_address to ptr
  ret ptr %1
}

define ptr @vector_new(i64 %0) {
entry:
  %1 = add i64 %0, 1
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %1
  store i64 %updated_address, ptr @heap_address, align 4
  %2 = inttoptr i64 %current_address to ptr
  store i64 %0, ptr %2, align 4
  ret ptr %2
}

define void @split_field(i64 %0, ptr %1, ptr %2) {
entry:
  %3 = call i64 @prophet_split_field_high(i64 %0)
  call void @builtin_range_check(i64 %3)
  %4 = call i64 @prophet_split_field_low(i64 %0)
  call void @builtin_range_check(i64 %4)
  %5 = mul i64 %3, 4294967296
  %6 = add i64 %5, %4
  %7 = icmp eq i64 %0, %6
  %8 = zext i1 %7 to i64
  call void @builtin_assert(i64 %8)
  store i64 %3, ptr %1, align 4
  store i64 %4, ptr %2, align 4
  ret void
}

define void @memcpy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %0, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %1, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

define i64 @memcmp_eq(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ne(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %right_elem, %left_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ult(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_ule(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %right_elem, %left_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %5, %3
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %6, %4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 1, %low_compare_block ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @field_memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %4, %6
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ule(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %5, %3
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %6, %4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ult(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %4, %6
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 1, %low_compare_block ], [ 0, %cond ]
  ret i64 %result_phi
}

define void @u32_div_mod(i64 %0, i64 %1, ptr %2, ptr %3) {
entry:
  %4 = call i64 @prophet_u32_mod(i64 %0, i64 %1)
  call void @builtin_range_check(i64 %4)
  %5 = add i64 %4, 1
  %6 = sub i64 %1, %5
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @prophet_u32_div(i64 %0, i64 %1)
  call void @builtin_range_check(ptr %2)
  %8 = mul i64 %7, %1
  %9 = add i64 %8, %4
  %10 = icmp eq i64 %9, %0
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  store i64 %7, ptr %2, align 4
  store i64 %4, ptr %3, align 4
  ret void
}

define i64 @u32_power(i64 %0, i64 %1) {
entry:
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = phi i64 [ 0, %entry ], [ %inc, %loop ]
  %3 = phi i64 [ 1, %entry ], [ %multmp, %loop ]
  %inc = add i64 %2, 1
  %multmp = mul i64 %3, %0
  %loopcond = icmp ule i64 %inc, %1
  br i1 %loopcond, label %loop, label %exit

exit:                                             ; preds = %loop
  call void @builtin_range_check(i64 %3)
  ret i64 %3
}

define void @call_by_contract_1(ptr %0) {
entry:
  %result = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %addr = alloca ptr, align 8
  store ptr %0, ptr %addr, align 8
  %1 = load ptr, ptr %addr, align 8
  store i64 100, ptr %a, align 4
  store i64 200, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = call ptr @vector_new(i64 4)
  %vector_data = getelementptr i64, ptr %4, i64 1
  store i64 %2, ptr %vector_data, align 4
  %5 = getelementptr ptr, ptr %vector_data, i64 1
  store i64 %3, ptr %5, align 4
  %6 = getelementptr ptr, ptr %5, i64 1
  store i64 2, ptr %6, align 4
  %7 = getelementptr ptr, ptr %6, i64 1
  store i64 1715662714, ptr %7, align 4
  %vector_length = load i64, ptr %4, align 4
  %vector_data1 = getelementptr i64, ptr %4, i64 1
  call void @set_tape_data(ptr %vector_data1, i64 %vector_length)
  call void @contract_call(ptr %1, i64 0)
  %8 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %8, i64 1)
  %return_length = load i64, ptr %8, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %9 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %9, align 4
  %return_data_start = getelementptr i64, ptr %9, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %10 = getelementptr ptr, ptr %9, i64 0
  %11 = load i64, ptr %10, align 4
  store i64 %11, ptr %result, align 4
  %12 = load i64, ptr %result, align 4
  %13 = icmp eq i64 %12, 300
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @call_by_contract_2(ptr %0) {
entry:
  %result = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %addr = alloca ptr, align 8
  store ptr %0, ptr %addr, align 8
  store i64 100, ptr %a, align 4
  store i64 200, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = load ptr, ptr %addr, align 8
  %4 = call ptr @vector_new(i64 4)
  %vector_data = getelementptr i64, ptr %4, i64 1
  store i64 %1, ptr %vector_data, align 4
  %5 = getelementptr ptr, ptr %vector_data, i64 1
  store i64 %2, ptr %5, align 4
  %6 = getelementptr ptr, ptr %5, i64 1
  store i64 2, ptr %6, align 4
  %7 = getelementptr ptr, ptr %6, i64 1
  store i64 1715662714, ptr %7, align 4
  %vector_length = load i64, ptr %4, align 4
  %vector_data1 = getelementptr i64, ptr %4, i64 1
  call void @set_tape_data(ptr %vector_data1, i64 %vector_length)
  call void @contract_call(ptr %3, i64 0)
  %8 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %8, i64 1)
  %return_length = load i64, ptr %8, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %9 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %9, align 4
  %return_data_start = getelementptr i64, ptr %9, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %10 = getelementptr ptr, ptr %9, i64 0
  %11 = load i64, ptr %10, align 4
  store i64 %11, ptr %result, align 4
  %12 = load i64, ptr %result, align 4
  %13 = icmp eq i64 %12, 300
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @call_by_interface_1(ptr %0) {
entry:
  %result = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %callee = alloca ptr, align 8
  store ptr %0, ptr %callee, align 8
  store i64 100, ptr %a, align 4
  store i64 200, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = load ptr, ptr %callee, align 8
  %4 = call ptr @vector_new(i64 4)
  %vector_data = getelementptr i64, ptr %4, i64 1
  store i64 %1, ptr %vector_data, align 4
  %5 = getelementptr ptr, ptr %vector_data, i64 1
  store i64 %2, ptr %5, align 4
  %6 = getelementptr ptr, ptr %5, i64 1
  store i64 2, ptr %6, align 4
  %7 = getelementptr ptr, ptr %6, i64 1
  store i64 1715662714, ptr %7, align 4
  %vector_length = load i64, ptr %4, align 4
  %vector_data1 = getelementptr i64, ptr %4, i64 1
  call void @set_tape_data(ptr %vector_data1, i64 %vector_length)
  call void @contract_call(ptr %3, i64 0)
  %8 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %8, i64 1)
  %return_length = load i64, ptr %8, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %9 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %9, align 4
  %return_data_start = getelementptr i64, ptr %9, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %10 = getelementptr ptr, ptr %9, i64 0
  %11 = load i64, ptr %10, align 4
  store i64 %11, ptr %result, align 4
  %12 = load i64, ptr %result, align 4
  %13 = icmp eq i64 %12, 300
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @call_by_interface_2(ptr %0) {
entry:
  %result = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %addr = alloca ptr, align 8
  store ptr %0, ptr %addr, align 8
  %1 = load ptr, ptr %addr, align 8
  store i64 100, ptr %a, align 4
  store i64 200, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = call ptr @vector_new(i64 4)
  %vector_data = getelementptr i64, ptr %4, i64 1
  store i64 %2, ptr %vector_data, align 4
  %5 = getelementptr ptr, ptr %vector_data, i64 1
  store i64 %3, ptr %5, align 4
  %6 = getelementptr ptr, ptr %5, i64 1
  store i64 2, ptr %6, align 4
  %7 = getelementptr ptr, ptr %6, i64 1
  store i64 1715662714, ptr %7, align 4
  %vector_length = load i64, ptr %4, align 4
  %vector_data1 = getelementptr i64, ptr %4, i64 1
  call void @set_tape_data(ptr %vector_data1, i64 %vector_length)
  call void @contract_call(ptr %1, i64 0)
  %8 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %8, i64 1)
  %return_length = load i64, ptr %8, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %9 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %9, align 4
  %return_data_start = getelementptr i64, ptr %9, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %10 = getelementptr ptr, ptr %9, i64 0
  %11 = load i64, ptr %10, align 4
  store i64 %11, ptr %result, align 4
  %12 = load i64, ptr %result, align 4
  %13 = icmp eq i64 %12, 300
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 401660231, label %func_0_dispatch
    i64 2495086936, label %func_1_dispatch
    i64 479910104, label %func_2_dispatch
    i64 321852033, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  call void @call_by_contract_1(ptr %3)
  %4 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %4, align 4
  call void @set_tape_data(ptr %4, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %5 = getelementptr ptr, ptr %2, i64 0
  call void @call_by_contract_2(ptr %5)
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %7 = getelementptr ptr, ptr %2, i64 0
  call void @call_by_interface_1(ptr %7)
  %8 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %8, align 4
  call void @set_tape_data(ptr %8, i64 1)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %9 = getelementptr ptr, ptr %2, i64 0
  call void @call_by_interface_2(ptr %9)
  %10 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %10, align 4
  call void @set_tape_data(ptr %10, i64 1)
  ret void
}

define void @main() {
entry:
  %0 = call ptr @heap_malloc(i64 13)
  call void @get_tape_data(ptr %0, i64 13)
  %function_selector = load i64, ptr %0, align 4
  %1 = call ptr @heap_malloc(i64 14)
  call void @get_tape_data(ptr %1, i64 14)
  %input_length = load i64, ptr %1, align 4
  %2 = add i64 %input_length, 14
  %3 = call ptr @heap_malloc(i64 %2)
  call void @get_tape_data(ptr %3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %3)
  ret void
}
