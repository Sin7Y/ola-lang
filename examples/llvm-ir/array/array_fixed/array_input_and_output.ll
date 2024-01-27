; ModuleID = 'ArrayInputExample'
source_filename = "array_input_and_output"

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

define ptr @array_input_u32(ptr %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %2 = load ptr, ptr %array, align 8
  store i64 %1, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x i64]], ptr %2, i64 0, i64 %3
  ret ptr %index_access
}

define ptr @array_output_u32() {
entry:
  %0 = call ptr @heap_malloc(i64 6)
  ret ptr %0
}

define ptr @array_input_address(ptr %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %2 = load ptr, ptr %array, align 8
  store i64 %1, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %2, i64 0, i64 %3
  ret ptr %index_access
}

define ptr @array_input_address_1(ptr %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %2 = load ptr, ptr %array, align 8
  store i64 %1, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %2, i64 0, i64 %3
  %index_access1 = getelementptr [2 x ptr], ptr %index_access, i64 0, i64 1
  %5 = load ptr, ptr %index_access1, align 8
  ret ptr %5
}

define ptr @array_input_address_2(ptr %0) {
entry:
  %index_ptr32 = alloca i64, align 8
  %index_ptr26 = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  %index_ptr16 = alloca i64, align 8
  %index_ptr10 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_size = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %1 = load ptr, ptr %array, align 8
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %2 = icmp ult i64 %index, 3
  br i1 %2, label %body, label %end_for

next:                                             ; preds = %end_for6
  %index9 = load i64, ptr %index_ptr, align 4
  %3 = add i64 %index9, 1
  store i64 %3, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  store i64 0, ptr %index_ptr1, align 4
  %index2 = load i64, ptr %index_ptr1, align 4
  br label %cond3

end_for:                                          ; preds = %cond
  %4 = load i64, ptr %array_size, align 4
  %5 = call ptr @vector_new(i64 %4)
  %6 = getelementptr ptr, ptr %5, i64 1
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr10, align 4
  %index11 = load i64, ptr %index_ptr10, align 4
  br label %cond12

cond3:                                            ; preds = %next4, %body
  %7 = icmp ult i64 %index2, 2
  br i1 %7, label %body5, label %end_for6

next4:                                            ; preds = %body5
  %index8 = load i64, ptr %index_ptr1, align 4
  %8 = add i64 %index8, 1
  store i64 %8, ptr %index_ptr1, align 4
  br label %cond3

body5:                                            ; preds = %cond3
  %9 = sub i64 2, %index
  call void @builtin_range_check(i64 %9)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %1, i64 0, i64 %index
  %10 = sub i64 1, %index2
  call void @builtin_range_check(i64 %10)
  %index_access7 = getelementptr [2 x ptr], ptr %index_access, i64 0, i64 %index2
  %11 = load i64, ptr %array_size, align 4
  %12 = add i64 %11, 4
  store i64 %12, ptr %array_size, align 4
  br label %next4

end_for6:                                         ; preds = %cond3
  br label %next

cond12:                                           ; preds = %next13, %end_for
  %13 = icmp ult i64 %index11, 3
  br i1 %13, label %body14, label %end_for15

next13:                                           ; preds = %end_for21
  %index25 = load i64, ptr %index_ptr10, align 4
  %14 = add i64 %index25, 1
  store i64 %14, ptr %index_ptr10, align 4
  br label %cond12

body14:                                           ; preds = %cond12
  store i64 0, ptr %index_ptr16, align 4
  %index17 = load i64, ptr %index_ptr16, align 4
  br label %cond18

end_for15:                                        ; preds = %cond12
  %15 = load i64, ptr %buffer_offset, align 4
  %vector_data = getelementptr i64, ptr %5, i64 1
  %16 = getelementptr ptr, ptr %vector_data, i64 0
  store i64 0, ptr %array_offset, align 4
  %17 = call ptr @heap_malloc(i64 0)
  store ptr %17, ptr %array_ptr, align 8
  %18 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr26, align 4
  %index27 = load i64, ptr %index_ptr26, align 4
  br label %cond28

cond18:                                           ; preds = %next19, %body14
  %19 = icmp ult i64 %index17, 2
  br i1 %19, label %body20, label %end_for21

next19:                                           ; preds = %body20
  %index24 = load i64, ptr %index_ptr16, align 4
  %20 = add i64 %index24, 1
  store i64 %20, ptr %index_ptr16, align 4
  br label %cond18

body20:                                           ; preds = %cond18
  %21 = sub i64 2, %index11
  call void @builtin_range_check(i64 %21)
  %index_access22 = getelementptr [3 x [2 x ptr]], ptr %1, i64 0, i64 %index11
  %22 = sub i64 1, %index17
  call void @builtin_range_check(i64 %22)
  %index_access23 = getelementptr [2 x ptr], ptr %index_access22, i64 0, i64 %index17
  %23 = load i64, ptr %buffer_offset, align 4
  %24 = getelementptr ptr, ptr %6, i64 %23
  %25 = getelementptr i64, ptr %index_access23, i64 0
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %24, i64 0
  store i64 %26, ptr %27, align 4
  %28 = getelementptr i64, ptr %index_access23, i64 1
  %29 = load i64, ptr %28, align 4
  %30 = getelementptr i64, ptr %24, i64 1
  store i64 %29, ptr %30, align 4
  %31 = getelementptr i64, ptr %index_access23, i64 2
  %32 = load i64, ptr %31, align 4
  %33 = getelementptr i64, ptr %24, i64 2
  store i64 %32, ptr %33, align 4
  %34 = getelementptr i64, ptr %index_access23, i64 3
  %35 = load i64, ptr %34, align 4
  %36 = getelementptr i64, ptr %24, i64 3
  store i64 %35, ptr %36, align 4
  %37 = load i64, ptr %buffer_offset, align 4
  %38 = add i64 %37, 4
  store i64 %38, ptr %buffer_offset, align 4
  br label %next19

end_for21:                                        ; preds = %cond18
  br label %next13

cond28:                                           ; preds = %next29, %end_for15
  %39 = icmp ult i64 %index27, 3
  br i1 %39, label %body30, label %end_for31

next29:                                           ; preds = %end_for37
  %index41 = load i64, ptr %index_ptr26, align 4
  %40 = add i64 %index41, 1
  store i64 %40, ptr %index_ptr26, align 4
  br label %cond28

body30:                                           ; preds = %cond28
  %41 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr32, align 4
  %index33 = load i64, ptr %index_ptr32, align 4
  br label %cond34

end_for31:                                        ; preds = %cond28
  %42 = load ptr, ptr %array_ptr, align 8
  %43 = load i64, ptr %array_offset, align 4
  ret ptr %42

cond34:                                           ; preds = %next35, %body30
  %44 = icmp ult i64 %index33, 2
  br i1 %44, label %body36, label %end_for37

next35:                                           ; preds = %body36
  %index40 = load i64, ptr %index_ptr32, align 4
  %45 = add i64 %index40, 1
  store i64 %45, ptr %index_ptr32, align 4
  br label %cond34

body36:                                           ; preds = %cond34
  %46 = load ptr, ptr %array_ptr, align 8
  %47 = sub i64 2, %index27
  call void @builtin_range_check(i64 %47)
  %index_access38 = getelementptr [3 x [2 x ptr]], ptr %46, i64 0, i64 %index27
  %48 = sub i64 1, %index33
  call void @builtin_range_check(i64 %48)
  %index_access39 = getelementptr [2 x ptr], ptr %index_access38, i64 0, i64 %index33
  store ptr %16, ptr %index_access39, align 8
  %49 = add i64 4, %41
  store i64 %49, ptr %array_offset, align 4
  br label %next35

end_for37:                                        ; preds = %cond34
  br label %next29
}

define ptr @array_output_address() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %0, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %0, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %0, i64 3
  store i64 0, ptr %index_access3, align 4
  %1 = call ptr @heap_malloc(i64 6)
  ret ptr %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr122 = alloca i64, align 8
  %index_ptr116 = alloca i64, align 8
  %buffer_offset115 = alloca i64, align 8
  %index_ptr104 = alloca i64, align 8
  %index_ptr98 = alloca i64, align 8
  %array_size97 = alloca i64, align 8
  %index_ptr87 = alloca i64, align 8
  %index_ptr81 = alloca i64, align 8
  %buffer_offset80 = alloca i64, align 8
  %index_ptr69 = alloca i64, align 8
  %index_ptr63 = alloca i64, align 8
  %array_size62 = alloca i64, align 8
  %index_ptr52 = alloca i64, align 8
  %index_ptr46 = alloca i64, align 8
  %array_ptr45 = alloca ptr, align 8
  %array_offset44 = alloca i64, align 8
  %index_ptr34 = alloca i64, align 8
  %index_ptr28 = alloca i64, align 8
  %array_ptr27 = alloca ptr, align 8
  %array_offset26 = alloca i64, align 8
  %index_ptr18 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr10 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 2485437794, label %func_0_dispatch
    i64 2873489331, label %func_1_dispatch
    i64 318899924, label %func_2_dispatch
    i64 2341696685, label %func_3_dispatch
    i64 3697261626, label %func_4_dispatch
    i64 208757611, label %func_5_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = getelementptr ptr, ptr %3, i64 6
  %5 = load i64, ptr %4, align 4
  %6 = call ptr @array_input_u32(ptr %3, i64 %5)
  %7 = call ptr @heap_malloc(i64 3)
  call void @memcpy(ptr %6, ptr %7, i64 2)
  %8 = getelementptr ptr, ptr %7, i64 2
  store i64 2, ptr %8, align 4
  call void @set_tape_data(ptr %7, i64 3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %9 = call ptr @array_output_u32()
  %10 = call ptr @heap_malloc(i64 7)
  call void @memcpy(ptr %9, ptr %10, i64 6)
  %11 = getelementptr ptr, ptr %10, i64 6
  store i64 6, ptr %11, align 4
  call void @set_tape_data(ptr %10, i64 7)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %12 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset, align 4
  %13 = call ptr @heap_malloc(i64 0)
  store ptr %13, ptr %array_ptr, align 8
  %14 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_2_dispatch
  %15 = icmp ult i64 %index, 3
  br i1 %15, label %body, label %end_for

next:                                             ; preds = %end_for6
  %index9 = load i64, ptr %index_ptr, align 4
  %16 = add i64 %index9, 1
  store i64 %16, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %17 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr1, align 4
  %index2 = load i64, ptr %index_ptr1, align 4
  br label %cond3

end_for:                                          ; preds = %cond
  %18 = load ptr, ptr %array_ptr, align 8
  %19 = load i64, ptr %array_offset, align 4
  %20 = getelementptr ptr, ptr %12, i64 %19
  %21 = load i64, ptr %20, align 4
  %22 = call ptr @array_input_address(ptr %18, i64 %21)
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr10, align 4
  %index11 = load i64, ptr %index_ptr10, align 4
  br label %cond12

cond3:                                            ; preds = %next4, %body
  %23 = icmp ult i64 %index2, 2
  br i1 %23, label %body5, label %end_for6

next4:                                            ; preds = %body5
  %index8 = load i64, ptr %index_ptr1, align 4
  %24 = add i64 %index8, 1
  store i64 %24, ptr %index_ptr1, align 4
  br label %cond3

body5:                                            ; preds = %cond3
  %25 = load ptr, ptr %array_ptr, align 8
  %26 = sub i64 2, %index
  call void @builtin_range_check(i64 %26)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %25, i64 0, i64 %index
  %27 = sub i64 1, %index2
  call void @builtin_range_check(i64 %27)
  %index_access7 = getelementptr [2 x ptr], ptr %index_access, i64 0, i64 %index2
  store ptr %12, ptr %index_access7, align 8
  %28 = add i64 4, %17
  store i64 %28, ptr %array_offset, align 4
  br label %next4

end_for6:                                         ; preds = %cond3
  br label %next

cond12:                                           ; preds = %next13, %end_for
  %29 = icmp ult i64 %index11, 2
  br i1 %29, label %body14, label %end_for15

next13:                                           ; preds = %body14
  %index17 = load i64, ptr %index_ptr10, align 4
  %30 = add i64 %index17, 1
  store i64 %30, ptr %index_ptr10, align 4
  br label %cond12

body14:                                           ; preds = %cond12
  %31 = sub i64 1, %index11
  call void @builtin_range_check(i64 %31)
  %index_access16 = getelementptr [2 x ptr], ptr %22, i64 0, i64 %index11
  %32 = load i64, ptr %array_size, align 4
  %33 = add i64 %32, 4
  store i64 %33, ptr %array_size, align 4
  br label %next13

end_for15:                                        ; preds = %cond12
  %34 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %34, 1
  %35 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr18, align 4
  %index19 = load i64, ptr %index_ptr18, align 4
  br label %cond20

cond20:                                           ; preds = %next21, %end_for15
  %36 = icmp ult i64 %index19, 2
  br i1 %36, label %body22, label %end_for23

next21:                                           ; preds = %body22
  %index25 = load i64, ptr %index_ptr18, align 4
  %37 = add i64 %index25, 1
  store i64 %37, ptr %index_ptr18, align 4
  br label %cond20

body22:                                           ; preds = %cond20
  %38 = sub i64 1, %index19
  call void @builtin_range_check(i64 %38)
  %index_access24 = getelementptr [2 x ptr], ptr %22, i64 0, i64 %index19
  %39 = load i64, ptr %buffer_offset, align 4
  %40 = getelementptr ptr, ptr %35, i64 %39
  %41 = getelementptr i64, ptr %index_access24, i64 0
  %42 = load i64, ptr %41, align 4
  %43 = getelementptr i64, ptr %40, i64 0
  store i64 %42, ptr %43, align 4
  %44 = getelementptr i64, ptr %index_access24, i64 1
  %45 = load i64, ptr %44, align 4
  %46 = getelementptr i64, ptr %40, i64 1
  store i64 %45, ptr %46, align 4
  %47 = getelementptr i64, ptr %index_access24, i64 2
  %48 = load i64, ptr %47, align 4
  %49 = getelementptr i64, ptr %40, i64 2
  store i64 %48, ptr %49, align 4
  %50 = getelementptr i64, ptr %index_access24, i64 3
  %51 = load i64, ptr %50, align 4
  %52 = getelementptr i64, ptr %40, i64 3
  store i64 %51, ptr %52, align 4
  %53 = load i64, ptr %buffer_offset, align 4
  %54 = add i64 %53, 4
  store i64 %54, ptr %buffer_offset, align 4
  br label %next21

end_for23:                                        ; preds = %cond20
  %55 = load i64, ptr %buffer_offset, align 4
  %56 = getelementptr ptr, ptr %35, i64 %55
  store i64 %34, ptr %56, align 4
  call void @set_tape_data(ptr %35, i64 %heap_size)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %57 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset26, align 4
  %58 = call ptr @heap_malloc(i64 0)
  store ptr %58, ptr %array_ptr27, align 8
  %59 = load i64, ptr %array_offset26, align 4
  store i64 0, ptr %index_ptr28, align 4
  %index29 = load i64, ptr %index_ptr28, align 4
  br label %cond30

cond30:                                           ; preds = %next31, %func_3_dispatch
  %60 = icmp ult i64 %index29, 3
  br i1 %60, label %body32, label %end_for33

next31:                                           ; preds = %end_for39
  %index43 = load i64, ptr %index_ptr28, align 4
  %61 = add i64 %index43, 1
  store i64 %61, ptr %index_ptr28, align 4
  br label %cond30

body32:                                           ; preds = %cond30
  %62 = load i64, ptr %array_offset26, align 4
  store i64 0, ptr %index_ptr34, align 4
  %index35 = load i64, ptr %index_ptr34, align 4
  br label %cond36

end_for33:                                        ; preds = %cond30
  %63 = load ptr, ptr %array_ptr27, align 8
  %64 = load i64, ptr %array_offset26, align 4
  %65 = getelementptr ptr, ptr %57, i64 %64
  %66 = load i64, ptr %65, align 4
  %67 = call ptr @array_input_address_1(ptr %63, i64 %66)
  %68 = call ptr @heap_malloc(i64 5)
  %69 = getelementptr i64, ptr %67, i64 0
  %70 = load i64, ptr %69, align 4
  %71 = getelementptr i64, ptr %68, i64 0
  store i64 %70, ptr %71, align 4
  %72 = getelementptr i64, ptr %67, i64 1
  %73 = load i64, ptr %72, align 4
  %74 = getelementptr i64, ptr %68, i64 1
  store i64 %73, ptr %74, align 4
  %75 = getelementptr i64, ptr %67, i64 2
  %76 = load i64, ptr %75, align 4
  %77 = getelementptr i64, ptr %68, i64 2
  store i64 %76, ptr %77, align 4
  %78 = getelementptr i64, ptr %67, i64 3
  %79 = load i64, ptr %78, align 4
  %80 = getelementptr i64, ptr %68, i64 3
  store i64 %79, ptr %80, align 4
  %81 = getelementptr ptr, ptr %68, i64 4
  store i64 4, ptr %81, align 4
  call void @set_tape_data(ptr %68, i64 5)
  ret void

cond36:                                           ; preds = %next37, %body32
  %82 = icmp ult i64 %index35, 2
  br i1 %82, label %body38, label %end_for39

next37:                                           ; preds = %body38
  %index42 = load i64, ptr %index_ptr34, align 4
  %83 = add i64 %index42, 1
  store i64 %83, ptr %index_ptr34, align 4
  br label %cond36

body38:                                           ; preds = %cond36
  %84 = load ptr, ptr %array_ptr27, align 8
  %85 = sub i64 2, %index29
  call void @builtin_range_check(i64 %85)
  %index_access40 = getelementptr [3 x [2 x ptr]], ptr %84, i64 0, i64 %index29
  %86 = sub i64 1, %index35
  call void @builtin_range_check(i64 %86)
  %index_access41 = getelementptr [2 x ptr], ptr %index_access40, i64 0, i64 %index35
  store ptr %57, ptr %index_access41, align 8
  %87 = add i64 4, %62
  store i64 %87, ptr %array_offset26, align 4
  br label %next37

end_for39:                                        ; preds = %cond36
  br label %next31

func_4_dispatch:                                  ; preds = %entry
  %88 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset44, align 4
  %89 = call ptr @heap_malloc(i64 0)
  store ptr %89, ptr %array_ptr45, align 8
  %90 = load i64, ptr %array_offset44, align 4
  store i64 0, ptr %index_ptr46, align 4
  %index47 = load i64, ptr %index_ptr46, align 4
  br label %cond48

cond48:                                           ; preds = %next49, %func_4_dispatch
  %91 = icmp ult i64 %index47, 3
  br i1 %91, label %body50, label %end_for51

next49:                                           ; preds = %end_for57
  %index61 = load i64, ptr %index_ptr46, align 4
  %92 = add i64 %index61, 1
  store i64 %92, ptr %index_ptr46, align 4
  br label %cond48

body50:                                           ; preds = %cond48
  %93 = load i64, ptr %array_offset44, align 4
  store i64 0, ptr %index_ptr52, align 4
  %index53 = load i64, ptr %index_ptr52, align 4
  br label %cond54

end_for51:                                        ; preds = %cond48
  %94 = load ptr, ptr %array_ptr45, align 8
  %95 = load i64, ptr %array_offset44, align 4
  %96 = call ptr @array_input_address_2(ptr %94)
  store i64 0, ptr %array_size62, align 4
  store i64 0, ptr %index_ptr63, align 4
  %index64 = load i64, ptr %index_ptr63, align 4
  br label %cond65

cond54:                                           ; preds = %next55, %body50
  %97 = icmp ult i64 %index53, 2
  br i1 %97, label %body56, label %end_for57

next55:                                           ; preds = %body56
  %index60 = load i64, ptr %index_ptr52, align 4
  %98 = add i64 %index60, 1
  store i64 %98, ptr %index_ptr52, align 4
  br label %cond54

body56:                                           ; preds = %cond54
  %99 = load ptr, ptr %array_ptr45, align 8
  %100 = sub i64 2, %index47
  call void @builtin_range_check(i64 %100)
  %index_access58 = getelementptr [3 x [2 x ptr]], ptr %99, i64 0, i64 %index47
  %101 = sub i64 1, %index53
  call void @builtin_range_check(i64 %101)
  %index_access59 = getelementptr [2 x ptr], ptr %index_access58, i64 0, i64 %index53
  store ptr %88, ptr %index_access59, align 8
  %102 = add i64 4, %93
  store i64 %102, ptr %array_offset44, align 4
  br label %next55

end_for57:                                        ; preds = %cond54
  br label %next49

cond65:                                           ; preds = %next66, %end_for51
  %103 = icmp ult i64 %index64, 3
  br i1 %103, label %body67, label %end_for68

next66:                                           ; preds = %end_for74
  %index78 = load i64, ptr %index_ptr63, align 4
  %104 = add i64 %index78, 1
  store i64 %104, ptr %index_ptr63, align 4
  br label %cond65

body67:                                           ; preds = %cond65
  store i64 0, ptr %index_ptr69, align 4
  %index70 = load i64, ptr %index_ptr69, align 4
  br label %cond71

end_for68:                                        ; preds = %cond65
  %105 = load i64, ptr %array_size62, align 4
  %heap_size79 = add i64 %105, 1
  %106 = call ptr @heap_malloc(i64 %heap_size79)
  store i64 0, ptr %buffer_offset80, align 4
  store i64 0, ptr %index_ptr81, align 4
  %index82 = load i64, ptr %index_ptr81, align 4
  br label %cond83

cond71:                                           ; preds = %next72, %body67
  %107 = icmp ult i64 %index70, 2
  br i1 %107, label %body73, label %end_for74

next72:                                           ; preds = %body73
  %index77 = load i64, ptr %index_ptr69, align 4
  %108 = add i64 %index77, 1
  store i64 %108, ptr %index_ptr69, align 4
  br label %cond71

body73:                                           ; preds = %cond71
  %109 = sub i64 2, %index64
  call void @builtin_range_check(i64 %109)
  %index_access75 = getelementptr [3 x [2 x ptr]], ptr %96, i64 0, i64 %index64
  %110 = sub i64 1, %index70
  call void @builtin_range_check(i64 %110)
  %index_access76 = getelementptr [2 x ptr], ptr %index_access75, i64 0, i64 %index70
  %111 = load i64, ptr %array_size62, align 4
  %112 = add i64 %111, 4
  store i64 %112, ptr %array_size62, align 4
  br label %next72

end_for74:                                        ; preds = %cond71
  br label %next66

cond83:                                           ; preds = %next84, %end_for68
  %113 = icmp ult i64 %index82, 3
  br i1 %113, label %body85, label %end_for86

next84:                                           ; preds = %end_for92
  %index96 = load i64, ptr %index_ptr81, align 4
  %114 = add i64 %index96, 1
  store i64 %114, ptr %index_ptr81, align 4
  br label %cond83

body85:                                           ; preds = %cond83
  store i64 0, ptr %index_ptr87, align 4
  %index88 = load i64, ptr %index_ptr87, align 4
  br label %cond89

end_for86:                                        ; preds = %cond83
  %115 = load i64, ptr %buffer_offset80, align 4
  %116 = getelementptr ptr, ptr %106, i64 %115
  store i64 %105, ptr %116, align 4
  call void @set_tape_data(ptr %106, i64 %heap_size79)
  ret void

cond89:                                           ; preds = %next90, %body85
  %117 = icmp ult i64 %index88, 2
  br i1 %117, label %body91, label %end_for92

next90:                                           ; preds = %body91
  %index95 = load i64, ptr %index_ptr87, align 4
  %118 = add i64 %index95, 1
  store i64 %118, ptr %index_ptr87, align 4
  br label %cond89

body91:                                           ; preds = %cond89
  %119 = sub i64 2, %index82
  call void @builtin_range_check(i64 %119)
  %index_access93 = getelementptr [3 x [2 x ptr]], ptr %96, i64 0, i64 %index82
  %120 = sub i64 1, %index88
  call void @builtin_range_check(i64 %120)
  %index_access94 = getelementptr [2 x ptr], ptr %index_access93, i64 0, i64 %index88
  %121 = load i64, ptr %buffer_offset80, align 4
  %122 = getelementptr ptr, ptr %106, i64 %121
  %123 = getelementptr i64, ptr %index_access94, i64 0
  %124 = load i64, ptr %123, align 4
  %125 = getelementptr i64, ptr %122, i64 0
  store i64 %124, ptr %125, align 4
  %126 = getelementptr i64, ptr %index_access94, i64 1
  %127 = load i64, ptr %126, align 4
  %128 = getelementptr i64, ptr %122, i64 1
  store i64 %127, ptr %128, align 4
  %129 = getelementptr i64, ptr %index_access94, i64 2
  %130 = load i64, ptr %129, align 4
  %131 = getelementptr i64, ptr %122, i64 2
  store i64 %130, ptr %131, align 4
  %132 = getelementptr i64, ptr %index_access94, i64 3
  %133 = load i64, ptr %132, align 4
  %134 = getelementptr i64, ptr %122, i64 3
  store i64 %133, ptr %134, align 4
  %135 = load i64, ptr %buffer_offset80, align 4
  %136 = add i64 %135, 4
  store i64 %136, ptr %buffer_offset80, align 4
  br label %next90

end_for92:                                        ; preds = %cond89
  br label %next84

func_5_dispatch:                                  ; preds = %entry
  %137 = call ptr @array_output_address()
  store i64 0, ptr %array_size97, align 4
  store i64 0, ptr %index_ptr98, align 4
  %index99 = load i64, ptr %index_ptr98, align 4
  br label %cond100

cond100:                                          ; preds = %next101, %func_5_dispatch
  %138 = icmp ult i64 %index99, 3
  br i1 %138, label %body102, label %end_for103

next101:                                          ; preds = %end_for109
  %index113 = load i64, ptr %index_ptr98, align 4
  %139 = add i64 %index113, 1
  store i64 %139, ptr %index_ptr98, align 4
  br label %cond100

body102:                                          ; preds = %cond100
  store i64 0, ptr %index_ptr104, align 4
  %index105 = load i64, ptr %index_ptr104, align 4
  br label %cond106

end_for103:                                       ; preds = %cond100
  %140 = load i64, ptr %array_size97, align 4
  %heap_size114 = add i64 %140, 1
  %141 = call ptr @heap_malloc(i64 %heap_size114)
  store i64 0, ptr %buffer_offset115, align 4
  store i64 0, ptr %index_ptr116, align 4
  %index117 = load i64, ptr %index_ptr116, align 4
  br label %cond118

cond106:                                          ; preds = %next107, %body102
  %142 = icmp ult i64 %index105, 2
  br i1 %142, label %body108, label %end_for109

next107:                                          ; preds = %body108
  %index112 = load i64, ptr %index_ptr104, align 4
  %143 = add i64 %index112, 1
  store i64 %143, ptr %index_ptr104, align 4
  br label %cond106

body108:                                          ; preds = %cond106
  %144 = sub i64 2, %index99
  call void @builtin_range_check(i64 %144)
  %index_access110 = getelementptr [3 x [2 x ptr]], ptr %137, i64 0, i64 %index99
  %145 = sub i64 1, %index105
  call void @builtin_range_check(i64 %145)
  %index_access111 = getelementptr [2 x ptr], ptr %index_access110, i64 0, i64 %index105
  %146 = load i64, ptr %array_size97, align 4
  %147 = add i64 %146, 4
  store i64 %147, ptr %array_size97, align 4
  br label %next107

end_for109:                                       ; preds = %cond106
  br label %next101

cond118:                                          ; preds = %next119, %end_for103
  %148 = icmp ult i64 %index117, 3
  br i1 %148, label %body120, label %end_for121

next119:                                          ; preds = %end_for127
  %index131 = load i64, ptr %index_ptr116, align 4
  %149 = add i64 %index131, 1
  store i64 %149, ptr %index_ptr116, align 4
  br label %cond118

body120:                                          ; preds = %cond118
  store i64 0, ptr %index_ptr122, align 4
  %index123 = load i64, ptr %index_ptr122, align 4
  br label %cond124

end_for121:                                       ; preds = %cond118
  %150 = load i64, ptr %buffer_offset115, align 4
  %151 = getelementptr ptr, ptr %141, i64 %150
  store i64 %140, ptr %151, align 4
  call void @set_tape_data(ptr %141, i64 %heap_size114)
  ret void

cond124:                                          ; preds = %next125, %body120
  %152 = icmp ult i64 %index123, 2
  br i1 %152, label %body126, label %end_for127

next125:                                          ; preds = %body126
  %index130 = load i64, ptr %index_ptr122, align 4
  %153 = add i64 %index130, 1
  store i64 %153, ptr %index_ptr122, align 4
  br label %cond124

body126:                                          ; preds = %cond124
  %154 = sub i64 2, %index117
  call void @builtin_range_check(i64 %154)
  %index_access128 = getelementptr [3 x [2 x ptr]], ptr %137, i64 0, i64 %index117
  %155 = sub i64 1, %index123
  call void @builtin_range_check(i64 %155)
  %index_access129 = getelementptr [2 x ptr], ptr %index_access128, i64 0, i64 %index123
  %156 = load i64, ptr %buffer_offset115, align 4
  %157 = getelementptr ptr, ptr %141, i64 %156
  %158 = getelementptr i64, ptr %index_access129, i64 0
  %159 = load i64, ptr %158, align 4
  %160 = getelementptr i64, ptr %157, i64 0
  store i64 %159, ptr %160, align 4
  %161 = getelementptr i64, ptr %index_access129, i64 1
  %162 = load i64, ptr %161, align 4
  %163 = getelementptr i64, ptr %157, i64 1
  store i64 %162, ptr %163, align 4
  %164 = getelementptr i64, ptr %index_access129, i64 2
  %165 = load i64, ptr %164, align 4
  %166 = getelementptr i64, ptr %157, i64 2
  store i64 %165, ptr %166, align 4
  %167 = getelementptr i64, ptr %index_access129, i64 3
  %168 = load i64, ptr %167, align 4
  %169 = getelementptr i64, ptr %157, i64 3
  store i64 %168, ptr %169, align 4
  %170 = load i64, ptr %buffer_offset115, align 4
  %171 = add i64 %170, 4
  store i64 %171, ptr %buffer_offset115, align 4
  br label %next125

end_for127:                                       ; preds = %cond124
  br label %next119
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
