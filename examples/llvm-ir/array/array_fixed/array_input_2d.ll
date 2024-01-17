; ModuleID = 'ArrayInputExample'
source_filename = "array_input_2d"

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
  %index_access = getelementptr ptr, ptr %2, i64 %3
  %5 = load ptr, ptr %index_access, align 8
  ret ptr %5
}

define ptr @array_output_u32() {
entry:
  %index_alloca14 = alloca i64, align 8
  %index_alloca5 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call ptr @vector_new(i64 2)
  %vector_data = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %1 = call ptr @vector_new(i64 2)
  %vector_data1 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_alloca5, align 4
  br label %cond2

cond2:                                            ; preds = %body3, %done
  %index_value6 = load i64, ptr %index_alloca5, align 4
  %loop_cond7 = icmp ult i64 %index_value6, 2
  br i1 %loop_cond7, label %body3, label %done4

body3:                                            ; preds = %cond2
  %index_access8 = getelementptr i64, ptr %vector_data1, i64 %index_value6
  store i64 0, ptr %index_access8, align 4
  %next_index9 = add i64 %index_value6, 1
  store i64 %next_index9, ptr %index_alloca5, align 4
  br label %cond2

done4:                                            ; preds = %cond2
  %2 = call ptr @vector_new(i64 2)
  %vector_data10 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_alloca14, align 4
  br label %cond11

cond11:                                           ; preds = %body12, %done4
  %index_value15 = load i64, ptr %index_alloca14, align 4
  %loop_cond16 = icmp ult i64 %index_value15, 2
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %index_access17 = getelementptr i64, ptr %vector_data10, i64 %index_value15
  store i64 0, ptr %index_access17, align 4
  %next_index18 = add i64 %index_value15, 1
  store i64 %next_index18, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  %3 = call ptr @heap_malloc(i64 3)
  %index_access19 = getelementptr ptr, ptr %3, i64 0
  store ptr %0, ptr %index_access19, align 8
  %index_access20 = getelementptr ptr, ptr %3, i64 1
  store ptr %1, ptr %index_access20, align 8
  %index_access21 = getelementptr ptr, ptr %3, i64 2
  store ptr %2, ptr %index_access21, align 8
  ret ptr %3
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
  %index_access = getelementptr ptr, ptr %2, i64 %3
  %5 = load ptr, ptr %index_access, align 8
  ret ptr %5
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
  %1 = call ptr @heap_malloc(i64 3)
  ret ptr %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr156 = alloca i64, align 8
  %index_ptr147 = alloca i64, align 8
  %buffer_offset146 = alloca i64, align 8
  %index_ptr129 = alloca i64, align 8
  %index_ptr123 = alloca i64, align 8
  %array_size122 = alloca i64, align 8
  %index_ptr111 = alloca i64, align 8
  %buffer_offset109 = alloca i64, align 8
  %index_ptr97 = alloca i64, align 8
  %array_size96 = alloca i64, align 8
  %index_ptr80 = alloca i64, align 8
  %index_ptr71 = alloca i64, align 8
  %array_ptr70 = alloca ptr, align 8
  %array_offset69 = alloca i64, align 8
  %index_ptr49 = alloca i64, align 8
  %index_ptr40 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr23 = alloca i64, align 8
  %index_ptr17 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 518061708, label %func_0_dispatch
    i64 2873489331, label %func_1_dispatch
    i64 3210415193, label %func_2_dispatch
    i64 208757611, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset, align 4
  %4 = call ptr @heap_malloc(i64 0)
  store ptr %4, ptr %array_ptr, align 8
  %5 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %6 = icmp ult i64 %index, 3
  br i1 %6, label %body, label %end_for

next:                                             ; preds = %end_for6
  %index14 = load i64, ptr %index_ptr, align 4
  %7 = add i64 %index14, 1
  store i64 %7, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %8 = load i64, ptr %array_offset, align 4
  %array_length = load i64, ptr %3, align 4
  %9 = add i64 %8, 1
  store i64 %9, ptr %array_offset, align 4
  %10 = call ptr @vector_new(i64 %array_length)
  %11 = load ptr, ptr %array_ptr, align 8
  %12 = sub i64 2, %index
  call void @builtin_range_check(i64 %12)
  %index_access = getelementptr ptr, ptr %11, i64 %index
  %arr = load ptr, ptr %index_access, align 8
  store ptr %10, ptr %arr, align 8
  store i64 0, ptr %index_ptr1, align 4
  %index2 = load i64, ptr %index_ptr1, align 4
  br label %cond3

end_for:                                          ; preds = %cond
  %13 = load ptr, ptr %array_ptr, align 8
  %14 = load i64, ptr %array_offset, align 4
  %15 = getelementptr ptr, ptr %3, i64 %14
  %16 = load i64, ptr %15, align 4
  %17 = call ptr @array_input_u32(ptr %13, i64 %16)
  %vector_length15 = load i64, ptr %17, align 4
  %18 = mul i64 %vector_length15, 1
  %19 = add i64 %18, 1
  %heap_size = add i64 %19, 1
  %20 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length16 = load i64, ptr %17, align 4
  %21 = mul i64 %vector_length16, 1
  %22 = add i64 %21, 1
  call void @memcpy(ptr %17, ptr %20, i64 %22)
  %23 = getelementptr ptr, ptr %20, i64 %22
  store i64 %19, ptr %23, align 4
  call void @set_tape_data(ptr %20, i64 %heap_size)
  ret void

cond3:                                            ; preds = %next4, %body
  %24 = sub i64 2, %index
  call void @builtin_range_check(i64 %24)
  %index_access7 = getelementptr ptr, ptr %array_ptr, i64 %index
  %arr8 = load ptr, ptr %index_access7, align 8
  %vector_length = load i64, ptr %arr8, align 4
  %25 = icmp ult i64 %index2, %vector_length
  br i1 %25, label %body5, label %end_for6

next4:                                            ; preds = %body5
  %index13 = load i64, ptr %index_ptr1, align 4
  %26 = add i64 %index13, 1
  store i64 %26, ptr %index_ptr1, align 4
  br label %cond3

body5:                                            ; preds = %cond3
  %27 = load i64, ptr %3, align 4
  %28 = load ptr, ptr %array_ptr, align 8
  %29 = sub i64 2, %index
  call void @builtin_range_check(i64 %29)
  %index_access9 = getelementptr ptr, ptr %28, i64 %index
  %arr10 = load ptr, ptr %index_access9, align 8
  %vector_length11 = load i64, ptr %arr10, align 4
  %30 = sub i64 %vector_length11, 1
  %31 = sub i64 %30, %index2
  call void @builtin_range_check(i64 %31)
  %vector_data = getelementptr i64, ptr %arr10, i64 1
  %index_access12 = getelementptr i64, ptr %vector_data, i64 %index2
  store i64 %27, ptr %index_access12, align 4
  %32 = add i64 1, %8
  store i64 %32, ptr %array_offset, align 4
  br label %next4

end_for6:                                         ; preds = %cond3
  br label %next

func_1_dispatch:                                  ; preds = %entry
  %33 = call ptr @array_output_u32()
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr17, align 4
  %index18 = load i64, ptr %index_ptr17, align 4
  br label %cond19

cond19:                                           ; preds = %next20, %func_1_dispatch
  %34 = icmp ult i64 %index18, 3
  br i1 %34, label %body21, label %end_for22

next20:                                           ; preds = %end_for28
  %index38 = load i64, ptr %index_ptr17, align 4
  %35 = add i64 %index38, 1
  store i64 %35, ptr %index_ptr17, align 4
  br label %cond19

body21:                                           ; preds = %cond19
  %36 = load i64, ptr %array_size, align 4
  %37 = add i64 %36, 1
  store i64 %37, ptr %array_size, align 4
  store i64 0, ptr %index_ptr23, align 4
  %index24 = load i64, ptr %index_ptr23, align 4
  br label %cond25

end_for22:                                        ; preds = %cond19
  %38 = load i64, ptr %array_size, align 4
  %heap_size39 = add i64 %38, 1
  %39 = call ptr @heap_malloc(i64 %heap_size39)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr40, align 4
  %index41 = load i64, ptr %index_ptr40, align 4
  br label %cond42

cond25:                                           ; preds = %next26, %body21
  %40 = sub i64 2, %index18
  call void @builtin_range_check(i64 %40)
  %index_access29 = getelementptr ptr, ptr %33, i64 %index18
  %arr30 = load ptr, ptr %index_access29, align 8
  %vector_length31 = load i64, ptr %arr30, align 4
  %41 = icmp ult i64 %index24, %vector_length31
  br i1 %41, label %body27, label %end_for28

next26:                                           ; preds = %body27
  %index37 = load i64, ptr %index_ptr23, align 4
  %42 = add i64 %index37, 1
  store i64 %42, ptr %index_ptr23, align 4
  br label %cond25

body27:                                           ; preds = %cond25
  %43 = sub i64 2, %index18
  call void @builtin_range_check(i64 %43)
  %index_access32 = getelementptr ptr, ptr %33, i64 %index18
  %arr33 = load ptr, ptr %index_access32, align 8
  %vector_length34 = load i64, ptr %arr33, align 4
  %44 = sub i64 %vector_length34, 1
  %45 = sub i64 %44, %index24
  call void @builtin_range_check(i64 %45)
  %vector_data35 = getelementptr i64, ptr %arr33, i64 1
  %index_access36 = getelementptr i64, ptr %vector_data35, i64 %index24
  %46 = load i64, ptr %array_size, align 4
  %47 = add i64 %46, 1
  store i64 %47, ptr %array_size, align 4
  br label %next26

end_for28:                                        ; preds = %cond25
  br label %next20

cond42:                                           ; preds = %next43, %end_for22
  %48 = icmp ult i64 %index41, 3
  br i1 %48, label %body44, label %end_for45

next43:                                           ; preds = %end_for54
  %index68 = load i64, ptr %index_ptr40, align 4
  %49 = add i64 %index68, 1
  store i64 %49, ptr %index_ptr40, align 4
  br label %cond42

body44:                                           ; preds = %cond42
  %50 = sub i64 2, %index41
  call void @builtin_range_check(i64 %50)
  %index_access46 = getelementptr ptr, ptr %33, i64 %index41
  %arr47 = load ptr, ptr %index_access46, align 8
  %51 = load i64, ptr %buffer_offset, align 4
  %52 = add i64 %51, 1
  store i64 %52, ptr %buffer_offset, align 4
  %53 = getelementptr ptr, ptr %39, i64 %51
  %vector_length48 = load i64, ptr %arr47, align 4
  store i64 %vector_length48, ptr %53, align 4
  store i64 0, ptr %index_ptr49, align 4
  %index50 = load i64, ptr %index_ptr49, align 4
  br label %cond51

end_for45:                                        ; preds = %cond42
  %54 = load i64, ptr %buffer_offset, align 4
  %55 = getelementptr ptr, ptr %39, i64 %54
  store i64 %38, ptr %55, align 4
  call void @set_tape_data(ptr %39, i64 %heap_size39)
  ret void

cond51:                                           ; preds = %next52, %body44
  %vector_length55 = load i64, ptr %33, align 4
  %56 = sub i64 %vector_length55, 1
  %57 = sub i64 %56, %index41
  call void @builtin_range_check(i64 %57)
  %vector_data56 = getelementptr i64, ptr %33, i64 1
  %index_access57 = getelementptr i64, ptr %vector_data56, i64 %index41
  %arr58 = load ptr, ptr %index_access57, align 8
  %vector_length59 = load i64, ptr %arr58, align 4
  %58 = icmp ult i64 %index50, %vector_length59
  br i1 %58, label %body53, label %end_for54

next52:                                           ; preds = %body53
  %index67 = load i64, ptr %index_ptr49, align 4
  %59 = add i64 %index67, 1
  store i64 %59, ptr %index_ptr49, align 4
  br label %cond51

body53:                                           ; preds = %cond51
  %vector_length60 = load i64, ptr %33, align 4
  %60 = sub i64 %vector_length60, 1
  %61 = sub i64 %60, %index41
  call void @builtin_range_check(i64 %61)
  %vector_data61 = getelementptr i64, ptr %33, i64 1
  %index_access62 = getelementptr i64, ptr %vector_data61, i64 %index41
  %arr63 = load ptr, ptr %index_access62, align 8
  %vector_length64 = load i64, ptr %arr63, align 4
  %62 = sub i64 %vector_length64, 1
  %63 = sub i64 %62, %index50
  call void @builtin_range_check(i64 %63)
  %vector_data65 = getelementptr i64, ptr %arr63, i64 1
  %index_access66 = getelementptr i64, ptr %vector_data65, i64 %index50
  %64 = load i64, ptr %buffer_offset, align 4
  %65 = getelementptr ptr, ptr %39, i64 %64
  store ptr %index_access66, ptr %65, align 8
  %66 = load i64, ptr %buffer_offset, align 4
  %67 = add i64 %66, 1
  store i64 %67, ptr %buffer_offset, align 4
  br label %next52

end_for54:                                        ; preds = %cond51
  br label %next43

func_2_dispatch:                                  ; preds = %entry
  %68 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset69, align 4
  %69 = call ptr @heap_malloc(i64 0)
  store ptr %69, ptr %array_ptr70, align 8
  %70 = load i64, ptr %array_offset69, align 4
  store i64 0, ptr %index_ptr71, align 4
  %index72 = load i64, ptr %index_ptr71, align 4
  br label %cond73

cond73:                                           ; preds = %next74, %func_2_dispatch
  %71 = icmp ult i64 %index72, 3
  br i1 %71, label %body75, label %end_for76

next74:                                           ; preds = %end_for85
  %index95 = load i64, ptr %index_ptr71, align 4
  %72 = add i64 %index95, 1
  store i64 %72, ptr %index_ptr71, align 4
  br label %cond73

body75:                                           ; preds = %cond73
  %73 = load i64, ptr %array_offset69, align 4
  %array_length77 = load i64, ptr %68, align 4
  %74 = add i64 %73, 1
  store i64 %74, ptr %array_offset69, align 4
  %75 = call ptr @vector_new(i64 %array_length77)
  %76 = load ptr, ptr %array_ptr70, align 8
  %77 = sub i64 2, %index72
  call void @builtin_range_check(i64 %77)
  %index_access78 = getelementptr ptr, ptr %76, i64 %index72
  %arr79 = load ptr, ptr %index_access78, align 8
  store ptr %75, ptr %arr79, align 8
  store i64 0, ptr %index_ptr80, align 4
  %index81 = load i64, ptr %index_ptr80, align 4
  br label %cond82

end_for76:                                        ; preds = %cond73
  %78 = load ptr, ptr %array_ptr70, align 8
  %79 = load i64, ptr %array_offset69, align 4
  %80 = getelementptr ptr, ptr %68, i64 %79
  %81 = load i64, ptr %80, align 4
  %82 = call ptr @array_input_address(ptr %78, i64 %81)
  store i64 0, ptr %array_size96, align 4
  %83 = load i64, ptr %array_size96, align 4
  %84 = add i64 %83, 1
  store i64 %84, ptr %array_size96, align 4
  store i64 0, ptr %index_ptr97, align 4
  %index98 = load i64, ptr %index_ptr97, align 4
  br label %cond99

cond82:                                           ; preds = %next83, %body75
  %85 = sub i64 2, %index72
  call void @builtin_range_check(i64 %85)
  %index_access86 = getelementptr ptr, ptr %array_ptr70, i64 %index72
  %arr87 = load ptr, ptr %index_access86, align 8
  %vector_length88 = load i64, ptr %arr87, align 4
  %86 = icmp ult i64 %index81, %vector_length88
  br i1 %86, label %body84, label %end_for85

next83:                                           ; preds = %body84
  %index94 = load i64, ptr %index_ptr80, align 4
  %87 = add i64 %index94, 1
  store i64 %87, ptr %index_ptr80, align 4
  br label %cond82

body84:                                           ; preds = %cond82
  %88 = load ptr, ptr %array_ptr70, align 8
  %89 = sub i64 2, %index72
  call void @builtin_range_check(i64 %89)
  %index_access89 = getelementptr ptr, ptr %88, i64 %index72
  %arr90 = load ptr, ptr %index_access89, align 8
  %vector_length91 = load i64, ptr %arr90, align 4
  %90 = sub i64 %vector_length91, 1
  %91 = sub i64 %90, %index81
  call void @builtin_range_check(i64 %91)
  %vector_data92 = getelementptr i64, ptr %arr90, i64 1
  %index_access93 = getelementptr ptr, ptr %vector_data92, i64 %index81
  store ptr %68, ptr %index_access93, align 8
  %92 = add i64 4, %73
  store i64 %92, ptr %array_offset69, align 4
  br label %next83

end_for85:                                        ; preds = %cond82
  br label %next74

cond99:                                           ; preds = %next100, %end_for76
  %vector_length103 = load i64, ptr %82, align 4
  %93 = icmp ult i64 %index98, %vector_length103
  br i1 %93, label %body101, label %end_for102

next100:                                          ; preds = %body101
  %index107 = load i64, ptr %index_ptr97, align 4
  %94 = add i64 %index107, 1
  store i64 %94, ptr %index_ptr97, align 4
  br label %cond99

body101:                                          ; preds = %cond99
  %vector_length104 = load i64, ptr %82, align 4
  %95 = sub i64 %vector_length104, 1
  %96 = sub i64 %95, %index98
  call void @builtin_range_check(i64 %96)
  %vector_data105 = getelementptr i64, ptr %82, i64 1
  %index_access106 = getelementptr ptr, ptr %vector_data105, i64 %index98
  %97 = load i64, ptr %array_size96, align 4
  %98 = add i64 %97, 4
  store i64 %98, ptr %array_size96, align 4
  br label %next100

end_for102:                                       ; preds = %cond99
  %99 = load i64, ptr %array_size96, align 4
  %heap_size108 = add i64 %99, 1
  %100 = call ptr @heap_malloc(i64 %heap_size108)
  store i64 0, ptr %buffer_offset109, align 4
  %101 = load i64, ptr %buffer_offset109, align 4
  %102 = add i64 %101, 1
  store i64 %102, ptr %buffer_offset109, align 4
  %103 = getelementptr ptr, ptr %100, i64 %101
  %vector_length110 = load i64, ptr %82, align 4
  store i64 %vector_length110, ptr %103, align 4
  store i64 0, ptr %index_ptr111, align 4
  %index112 = load i64, ptr %index_ptr111, align 4
  br label %cond113

cond113:                                          ; preds = %next114, %end_for102
  %vector_length117 = load i64, ptr %82, align 4
  %104 = icmp ult i64 %index112, %vector_length117
  br i1 %104, label %body115, label %end_for116

next114:                                          ; preds = %body115
  %index121 = load i64, ptr %index_ptr111, align 4
  %105 = add i64 %index121, 1
  store i64 %105, ptr %index_ptr111, align 4
  br label %cond113

body115:                                          ; preds = %cond113
  %vector_length118 = load i64, ptr %82, align 4
  %106 = sub i64 %vector_length118, 1
  %107 = sub i64 %106, %index112
  call void @builtin_range_check(i64 %107)
  %vector_data119 = getelementptr i64, ptr %82, i64 1
  %index_access120 = getelementptr ptr, ptr %vector_data119, i64 %index112
  %108 = load i64, ptr %buffer_offset109, align 4
  %109 = getelementptr ptr, ptr %100, i64 %108
  %110 = getelementptr i64, ptr %index_access120, i64 0
  %111 = load i64, ptr %110, align 4
  %112 = getelementptr i64, ptr %109, i64 0
  store i64 %111, ptr %112, align 4
  %113 = getelementptr i64, ptr %index_access120, i64 1
  %114 = load i64, ptr %113, align 4
  %115 = getelementptr i64, ptr %109, i64 1
  store i64 %114, ptr %115, align 4
  %116 = getelementptr i64, ptr %index_access120, i64 2
  %117 = load i64, ptr %116, align 4
  %118 = getelementptr i64, ptr %109, i64 2
  store i64 %117, ptr %118, align 4
  %119 = getelementptr i64, ptr %index_access120, i64 3
  %120 = load i64, ptr %119, align 4
  %121 = getelementptr i64, ptr %109, i64 3
  store i64 %120, ptr %121, align 4
  %122 = load i64, ptr %buffer_offset109, align 4
  %123 = add i64 %122, 4
  store i64 %123, ptr %buffer_offset109, align 4
  br label %next114

end_for116:                                       ; preds = %cond113
  %124 = load i64, ptr %buffer_offset109, align 4
  %125 = getelementptr ptr, ptr %100, i64 %124
  store i64 %99, ptr %125, align 4
  call void @set_tape_data(ptr %100, i64 %heap_size108)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %126 = call ptr @array_output_address()
  store i64 0, ptr %array_size122, align 4
  store i64 0, ptr %index_ptr123, align 4
  %index124 = load i64, ptr %index_ptr123, align 4
  br label %cond125

cond125:                                          ; preds = %next126, %func_3_dispatch
  %127 = icmp ult i64 %index124, 3
  br i1 %127, label %body127, label %end_for128

next126:                                          ; preds = %end_for134
  %index144 = load i64, ptr %index_ptr123, align 4
  %128 = add i64 %index144, 1
  store i64 %128, ptr %index_ptr123, align 4
  br label %cond125

body127:                                          ; preds = %cond125
  %129 = load i64, ptr %array_size122, align 4
  %130 = add i64 %129, 1
  store i64 %130, ptr %array_size122, align 4
  store i64 0, ptr %index_ptr129, align 4
  %index130 = load i64, ptr %index_ptr129, align 4
  br label %cond131

end_for128:                                       ; preds = %cond125
  %131 = load i64, ptr %array_size122, align 4
  %heap_size145 = add i64 %131, 1
  %132 = call ptr @heap_malloc(i64 %heap_size145)
  store i64 0, ptr %buffer_offset146, align 4
  store i64 0, ptr %index_ptr147, align 4
  %index148 = load i64, ptr %index_ptr147, align 4
  br label %cond149

cond131:                                          ; preds = %next132, %body127
  %133 = sub i64 2, %index124
  call void @builtin_range_check(i64 %133)
  %index_access135 = getelementptr ptr, ptr %126, i64 %index124
  %arr136 = load ptr, ptr %index_access135, align 8
  %vector_length137 = load i64, ptr %arr136, align 4
  %134 = icmp ult i64 %index130, %vector_length137
  br i1 %134, label %body133, label %end_for134

next132:                                          ; preds = %body133
  %index143 = load i64, ptr %index_ptr129, align 4
  %135 = add i64 %index143, 1
  store i64 %135, ptr %index_ptr129, align 4
  br label %cond131

body133:                                          ; preds = %cond131
  %136 = sub i64 2, %index124
  call void @builtin_range_check(i64 %136)
  %index_access138 = getelementptr ptr, ptr %126, i64 %index124
  %arr139 = load ptr, ptr %index_access138, align 8
  %vector_length140 = load i64, ptr %arr139, align 4
  %137 = sub i64 %vector_length140, 1
  %138 = sub i64 %137, %index130
  call void @builtin_range_check(i64 %138)
  %vector_data141 = getelementptr i64, ptr %arr139, i64 1
  %index_access142 = getelementptr ptr, ptr %vector_data141, i64 %index130
  %139 = load i64, ptr %array_size122, align 4
  %140 = add i64 %139, 4
  store i64 %140, ptr %array_size122, align 4
  br label %next132

end_for134:                                       ; preds = %cond131
  br label %next126

cond149:                                          ; preds = %next150, %end_for128
  %141 = icmp ult i64 %index148, 3
  br i1 %141, label %body151, label %end_for152

next150:                                          ; preds = %end_for161
  %index175 = load i64, ptr %index_ptr147, align 4
  %142 = add i64 %index175, 1
  store i64 %142, ptr %index_ptr147, align 4
  br label %cond149

body151:                                          ; preds = %cond149
  %143 = sub i64 2, %index148
  call void @builtin_range_check(i64 %143)
  %index_access153 = getelementptr ptr, ptr %126, i64 %index148
  %arr154 = load ptr, ptr %index_access153, align 8
  %144 = load i64, ptr %buffer_offset146, align 4
  %145 = add i64 %144, 1
  store i64 %145, ptr %buffer_offset146, align 4
  %146 = getelementptr ptr, ptr %132, i64 %144
  %vector_length155 = load i64, ptr %arr154, align 4
  store i64 %vector_length155, ptr %146, align 4
  store i64 0, ptr %index_ptr156, align 4
  %index157 = load i64, ptr %index_ptr156, align 4
  br label %cond158

end_for152:                                       ; preds = %cond149
  %147 = load i64, ptr %buffer_offset146, align 4
  %148 = getelementptr ptr, ptr %132, i64 %147
  store i64 %131, ptr %148, align 4
  call void @set_tape_data(ptr %132, i64 %heap_size145)
  ret void

cond158:                                          ; preds = %next159, %body151
  %vector_length162 = load i64, ptr %126, align 4
  %149 = sub i64 %vector_length162, 1
  %150 = sub i64 %149, %index148
  call void @builtin_range_check(i64 %150)
  %vector_data163 = getelementptr i64, ptr %126, i64 1
  %index_access164 = getelementptr ptr, ptr %vector_data163, i64 %index148
  %arr165 = load ptr, ptr %index_access164, align 8
  %vector_length166 = load i64, ptr %arr165, align 4
  %151 = icmp ult i64 %index157, %vector_length166
  br i1 %151, label %body160, label %end_for161

next159:                                          ; preds = %body160
  %index174 = load i64, ptr %index_ptr156, align 4
  %152 = add i64 %index174, 1
  store i64 %152, ptr %index_ptr156, align 4
  br label %cond158

body160:                                          ; preds = %cond158
  %vector_length167 = load i64, ptr %126, align 4
  %153 = sub i64 %vector_length167, 1
  %154 = sub i64 %153, %index148
  call void @builtin_range_check(i64 %154)
  %vector_data168 = getelementptr i64, ptr %126, i64 1
  %index_access169 = getelementptr ptr, ptr %vector_data168, i64 %index148
  %arr170 = load ptr, ptr %index_access169, align 8
  %vector_length171 = load i64, ptr %arr170, align 4
  %155 = sub i64 %vector_length171, 1
  %156 = sub i64 %155, %index157
  call void @builtin_range_check(i64 %156)
  %vector_data172 = getelementptr i64, ptr %arr170, i64 1
  %index_access173 = getelementptr ptr, ptr %vector_data172, i64 %index157
  %157 = load i64, ptr %buffer_offset146, align 4
  %158 = getelementptr ptr, ptr %132, i64 %157
  %159 = getelementptr i64, ptr %index_access173, i64 0
  %160 = load i64, ptr %159, align 4
  %161 = getelementptr i64, ptr %158, i64 0
  store i64 %160, ptr %161, align 4
  %162 = getelementptr i64, ptr %index_access173, i64 1
  %163 = load i64, ptr %162, align 4
  %164 = getelementptr i64, ptr %158, i64 1
  store i64 %163, ptr %164, align 4
  %165 = getelementptr i64, ptr %index_access173, i64 2
  %166 = load i64, ptr %165, align 4
  %167 = getelementptr i64, ptr %158, i64 2
  store i64 %166, ptr %167, align 4
  %168 = getelementptr i64, ptr %index_access173, i64 3
  %169 = load i64, ptr %168, align 4
  %170 = getelementptr i64, ptr %158, i64 3
  store i64 %169, ptr %170, align 4
  %171 = load i64, ptr %buffer_offset146, align 4
  %172 = add i64 %171, 4
  store i64 %172, ptr %buffer_offset146, align 4
  br label %next159

end_for161:                                       ; preds = %cond158
  br label %next150
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
