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
  %index_access = getelementptr [3 x ptr], ptr %2, i64 0, i64 %3
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
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
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
  %index_access8 = getelementptr ptr, ptr %vector_data1, i64 %index_value6
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
  %index_access17 = getelementptr ptr, ptr %vector_data10, i64 %index_value15
  store i64 0, ptr %index_access17, align 4
  %next_index18 = add i64 %index_value15, 1
  store i64 %next_index18, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  %3 = call ptr @heap_malloc(i64 3)
  %index_access19 = getelementptr [3 x ptr], ptr %3, i64 0, i64 0
  store ptr %0, ptr %index_access19, align 8
  %index_access20 = getelementptr [3 x ptr], ptr %3, i64 0, i64 1
  store ptr %1, ptr %index_access20, align 8
  %index_access21 = getelementptr [3 x ptr], ptr %3, i64 0, i64 2
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
  %index_access = getelementptr [3 x ptr], ptr %2, i64 0, i64 %3
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
  %index_ptr163 = alloca i64, align 8
  %index_ptr154 = alloca i64, align 8
  %buffer_offset153 = alloca i64, align 8
  %index_ptr136 = alloca i64, align 8
  %index_ptr127 = alloca i64, align 8
  %array_size126 = alloca i64, align 8
  %index_ptr115 = alloca i64, align 8
  %buffer_offset113 = alloca i64, align 8
  %index_ptr101 = alloca i64, align 8
  %array_size99 = alloca i64, align 8
  %index_ptr83 = alloca i64, align 8
  %index_ptr74 = alloca i64, align 8
  %array_ptr73 = alloca ptr, align 8
  %array_offset72 = alloca i64, align 8
  %index_ptr52 = alloca i64, align 8
  %index_ptr43 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr26 = alloca i64, align 8
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
  %index_access = getelementptr [3 x ptr], ptr %11, i64 0, i64 %index
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
  %index_access7 = getelementptr [3 x ptr], ptr %array_ptr, i64 0, i64 %index
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
  %index_access9 = getelementptr [3 x ptr], ptr %28, i64 0, i64 %index
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

next20:                                           ; preds = %end_for31
  %index41 = load i64, ptr %index_ptr17, align 4
  %35 = add i64 %index41, 1
  store i64 %35, ptr %index_ptr17, align 4
  br label %cond19

body21:                                           ; preds = %cond19
  %36 = sub i64 2, %index18
  call void @builtin_range_check(i64 %36)
  %index_access23 = getelementptr [3 x ptr], ptr %33, i64 0, i64 %index18
  %arr24 = load ptr, ptr %index_access23, align 8
  %vector_length25 = load i64, ptr %arr24, align 4
  %37 = load i64, ptr %array_size, align 4
  %38 = add i64 %37, %vector_length25
  store i64 %38, ptr %array_size, align 4
  store i64 0, ptr %index_ptr26, align 4
  %index27 = load i64, ptr %index_ptr26, align 4
  br label %cond28

end_for22:                                        ; preds = %cond19
  %39 = load i64, ptr %array_size, align 4
  %heap_size42 = add i64 %39, 1
  %40 = call ptr @heap_malloc(i64 %heap_size42)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr43, align 4
  %index44 = load i64, ptr %index_ptr43, align 4
  br label %cond45

cond28:                                           ; preds = %next29, %body21
  %41 = sub i64 2, %index18
  call void @builtin_range_check(i64 %41)
  %index_access32 = getelementptr [3 x ptr], ptr %33, i64 0, i64 %index18
  %arr33 = load ptr, ptr %index_access32, align 8
  %vector_length34 = load i64, ptr %arr33, align 4
  %42 = icmp ult i64 %index27, %vector_length34
  br i1 %42, label %body30, label %end_for31

next29:                                           ; preds = %body30
  %index40 = load i64, ptr %index_ptr26, align 4
  %43 = add i64 %index40, 1
  store i64 %43, ptr %index_ptr26, align 4
  br label %cond28

body30:                                           ; preds = %cond28
  %44 = sub i64 2, %index18
  call void @builtin_range_check(i64 %44)
  %index_access35 = getelementptr [3 x ptr], ptr %33, i64 0, i64 %index18
  %arr36 = load ptr, ptr %index_access35, align 8
  %vector_length37 = load i64, ptr %arr36, align 4
  %45 = sub i64 %vector_length37, 1
  %46 = sub i64 %45, %index27
  call void @builtin_range_check(i64 %46)
  %vector_data38 = getelementptr i64, ptr %arr36, i64 1
  %index_access39 = getelementptr i64, ptr %vector_data38, i64 %index27
  %47 = load i64, ptr %array_size, align 4
  %48 = add i64 %47, 1
  store i64 %48, ptr %array_size, align 4
  br label %next29

end_for31:                                        ; preds = %cond28
  br label %next20

cond45:                                           ; preds = %next46, %end_for22
  %49 = icmp ult i64 %index44, 3
  br i1 %49, label %body47, label %end_for48

next46:                                           ; preds = %end_for57
  %index71 = load i64, ptr %index_ptr43, align 4
  %50 = add i64 %index71, 1
  store i64 %50, ptr %index_ptr43, align 4
  br label %cond45

body47:                                           ; preds = %cond45
  %51 = sub i64 2, %index44
  call void @builtin_range_check(i64 %51)
  %index_access49 = getelementptr [3 x ptr], ptr %33, i64 0, i64 %index44
  %arr50 = load ptr, ptr %index_access49, align 8
  %52 = load i64, ptr %buffer_offset, align 4
  %53 = add i64 %52, 1
  store i64 %53, ptr %buffer_offset, align 4
  %54 = getelementptr ptr, ptr %40, i64 %52
  %vector_length51 = load i64, ptr %arr50, align 4
  store i64 %vector_length51, ptr %54, align 4
  store i64 0, ptr %index_ptr52, align 4
  %index53 = load i64, ptr %index_ptr52, align 4
  br label %cond54

end_for48:                                        ; preds = %cond45
  %55 = load i64, ptr %buffer_offset, align 4
  %56 = getelementptr ptr, ptr %40, i64 %55
  store i64 %39, ptr %56, align 4
  call void @set_tape_data(ptr %40, i64 %heap_size42)
  ret void

cond54:                                           ; preds = %next55, %body47
  %vector_length58 = load i64, ptr %33, align 4
  %57 = sub i64 %vector_length58, 1
  %58 = sub i64 %57, %index44
  call void @builtin_range_check(i64 %58)
  %vector_data59 = getelementptr i64, ptr %33, i64 1
  %index_access60 = getelementptr i64, ptr %vector_data59, i64 %index44
  %arr61 = load ptr, ptr %index_access60, align 8
  %vector_length62 = load i64, ptr %arr61, align 4
  %59 = icmp ult i64 %index53, %vector_length62
  br i1 %59, label %body56, label %end_for57

next55:                                           ; preds = %body56
  %index70 = load i64, ptr %index_ptr52, align 4
  %60 = add i64 %index70, 1
  store i64 %60, ptr %index_ptr52, align 4
  br label %cond54

body56:                                           ; preds = %cond54
  %vector_length63 = load i64, ptr %33, align 4
  %61 = sub i64 %vector_length63, 1
  %62 = sub i64 %61, %index44
  call void @builtin_range_check(i64 %62)
  %vector_data64 = getelementptr i64, ptr %33, i64 1
  %index_access65 = getelementptr i64, ptr %vector_data64, i64 %index44
  %arr66 = load ptr, ptr %index_access65, align 8
  %vector_length67 = load i64, ptr %arr66, align 4
  %63 = sub i64 %vector_length67, 1
  %64 = sub i64 %63, %index53
  call void @builtin_range_check(i64 %64)
  %vector_data68 = getelementptr i64, ptr %arr66, i64 1
  %index_access69 = getelementptr i64, ptr %vector_data68, i64 %index53
  %65 = load i64, ptr %buffer_offset, align 4
  %66 = getelementptr ptr, ptr %40, i64 %65
  store ptr %index_access69, ptr %66, align 8
  %67 = load i64, ptr %buffer_offset, align 4
  %68 = add i64 %67, 1
  store i64 %68, ptr %buffer_offset, align 4
  br label %next55

end_for57:                                        ; preds = %cond54
  br label %next46

func_2_dispatch:                                  ; preds = %entry
  %69 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset72, align 4
  %70 = call ptr @heap_malloc(i64 0)
  store ptr %70, ptr %array_ptr73, align 8
  %71 = load i64, ptr %array_offset72, align 4
  store i64 0, ptr %index_ptr74, align 4
  %index75 = load i64, ptr %index_ptr74, align 4
  br label %cond76

cond76:                                           ; preds = %next77, %func_2_dispatch
  %72 = icmp ult i64 %index75, 3
  br i1 %72, label %body78, label %end_for79

next77:                                           ; preds = %end_for88
  %index98 = load i64, ptr %index_ptr74, align 4
  %73 = add i64 %index98, 1
  store i64 %73, ptr %index_ptr74, align 4
  br label %cond76

body78:                                           ; preds = %cond76
  %74 = load i64, ptr %array_offset72, align 4
  %array_length80 = load i64, ptr %69, align 4
  %75 = add i64 %74, 1
  store i64 %75, ptr %array_offset72, align 4
  %76 = call ptr @vector_new(i64 %array_length80)
  %77 = load ptr, ptr %array_ptr73, align 8
  %78 = sub i64 2, %index75
  call void @builtin_range_check(i64 %78)
  %index_access81 = getelementptr [3 x ptr], ptr %77, i64 0, i64 %index75
  %arr82 = load ptr, ptr %index_access81, align 8
  store ptr %76, ptr %arr82, align 8
  store i64 0, ptr %index_ptr83, align 4
  %index84 = load i64, ptr %index_ptr83, align 4
  br label %cond85

end_for79:                                        ; preds = %cond76
  %79 = load ptr, ptr %array_ptr73, align 8
  %80 = load i64, ptr %array_offset72, align 4
  %81 = getelementptr ptr, ptr %69, i64 %80
  %82 = load i64, ptr %81, align 4
  %83 = call ptr @array_input_address(ptr %79, i64 %82)
  store i64 0, ptr %array_size99, align 4
  %vector_length100 = load i64, ptr %83, align 4
  %84 = load i64, ptr %array_size99, align 4
  %85 = add i64 %84, %vector_length100
  store i64 %85, ptr %array_size99, align 4
  store i64 0, ptr %index_ptr101, align 4
  %index102 = load i64, ptr %index_ptr101, align 4
  br label %cond103

cond85:                                           ; preds = %next86, %body78
  %86 = sub i64 2, %index75
  call void @builtin_range_check(i64 %86)
  %index_access89 = getelementptr [3 x ptr], ptr %array_ptr73, i64 0, i64 %index75
  %arr90 = load ptr, ptr %index_access89, align 8
  %vector_length91 = load i64, ptr %arr90, align 4
  %87 = icmp ult i64 %index84, %vector_length91
  br i1 %87, label %body87, label %end_for88

next86:                                           ; preds = %body87
  %index97 = load i64, ptr %index_ptr83, align 4
  %88 = add i64 %index97, 1
  store i64 %88, ptr %index_ptr83, align 4
  br label %cond85

body87:                                           ; preds = %cond85
  %89 = load ptr, ptr %array_ptr73, align 8
  %90 = sub i64 2, %index75
  call void @builtin_range_check(i64 %90)
  %index_access92 = getelementptr [3 x ptr], ptr %89, i64 0, i64 %index75
  %arr93 = load ptr, ptr %index_access92, align 8
  %vector_length94 = load i64, ptr %arr93, align 4
  %91 = sub i64 %vector_length94, 1
  %92 = sub i64 %91, %index84
  call void @builtin_range_check(i64 %92)
  %vector_data95 = getelementptr i64, ptr %arr93, i64 1
  %index_access96 = getelementptr ptr, ptr %vector_data95, i64 %index84
  store ptr %69, ptr %index_access96, align 8
  %93 = add i64 4, %74
  store i64 %93, ptr %array_offset72, align 4
  br label %next86

end_for88:                                        ; preds = %cond85
  br label %next77

cond103:                                          ; preds = %next104, %end_for79
  %vector_length107 = load i64, ptr %83, align 4
  %94 = icmp ult i64 %index102, %vector_length107
  br i1 %94, label %body105, label %end_for106

next104:                                          ; preds = %body105
  %index111 = load i64, ptr %index_ptr101, align 4
  %95 = add i64 %index111, 1
  store i64 %95, ptr %index_ptr101, align 4
  br label %cond103

body105:                                          ; preds = %cond103
  %vector_length108 = load i64, ptr %83, align 4
  %96 = sub i64 %vector_length108, 1
  %97 = sub i64 %96, %index102
  call void @builtin_range_check(i64 %97)
  %vector_data109 = getelementptr i64, ptr %83, i64 1
  %index_access110 = getelementptr ptr, ptr %vector_data109, i64 %index102
  %98 = load i64, ptr %array_size99, align 4
  %99 = add i64 %98, 4
  store i64 %99, ptr %array_size99, align 4
  br label %next104

end_for106:                                       ; preds = %cond103
  %100 = load i64, ptr %array_size99, align 4
  %heap_size112 = add i64 %100, 1
  %101 = call ptr @heap_malloc(i64 %heap_size112)
  store i64 0, ptr %buffer_offset113, align 4
  %102 = load i64, ptr %buffer_offset113, align 4
  %103 = add i64 %102, 1
  store i64 %103, ptr %buffer_offset113, align 4
  %104 = getelementptr ptr, ptr %101, i64 %102
  %vector_length114 = load i64, ptr %83, align 4
  store i64 %vector_length114, ptr %104, align 4
  store i64 0, ptr %index_ptr115, align 4
  %index116 = load i64, ptr %index_ptr115, align 4
  br label %cond117

cond117:                                          ; preds = %next118, %end_for106
  %vector_length121 = load i64, ptr %83, align 4
  %105 = icmp ult i64 %index116, %vector_length121
  br i1 %105, label %body119, label %end_for120

next118:                                          ; preds = %body119
  %index125 = load i64, ptr %index_ptr115, align 4
  %106 = add i64 %index125, 1
  store i64 %106, ptr %index_ptr115, align 4
  br label %cond117

body119:                                          ; preds = %cond117
  %vector_length122 = load i64, ptr %83, align 4
  %107 = sub i64 %vector_length122, 1
  %108 = sub i64 %107, %index116
  call void @builtin_range_check(i64 %108)
  %vector_data123 = getelementptr i64, ptr %83, i64 1
  %index_access124 = getelementptr ptr, ptr %vector_data123, i64 %index116
  %109 = load i64, ptr %buffer_offset113, align 4
  %110 = getelementptr ptr, ptr %101, i64 %109
  %111 = getelementptr i64, ptr %index_access124, i64 0
  %112 = load i64, ptr %111, align 4
  %113 = getelementptr i64, ptr %110, i64 0
  store i64 %112, ptr %113, align 4
  %114 = getelementptr i64, ptr %index_access124, i64 1
  %115 = load i64, ptr %114, align 4
  %116 = getelementptr i64, ptr %110, i64 1
  store i64 %115, ptr %116, align 4
  %117 = getelementptr i64, ptr %index_access124, i64 2
  %118 = load i64, ptr %117, align 4
  %119 = getelementptr i64, ptr %110, i64 2
  store i64 %118, ptr %119, align 4
  %120 = getelementptr i64, ptr %index_access124, i64 3
  %121 = load i64, ptr %120, align 4
  %122 = getelementptr i64, ptr %110, i64 3
  store i64 %121, ptr %122, align 4
  %123 = load i64, ptr %buffer_offset113, align 4
  %124 = add i64 %123, 4
  store i64 %124, ptr %buffer_offset113, align 4
  br label %next118

end_for120:                                       ; preds = %cond117
  %125 = load i64, ptr %buffer_offset113, align 4
  %126 = getelementptr ptr, ptr %101, i64 %125
  store i64 %100, ptr %126, align 4
  call void @set_tape_data(ptr %101, i64 %heap_size112)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %127 = call ptr @array_output_address()
  store i64 0, ptr %array_size126, align 4
  store i64 0, ptr %index_ptr127, align 4
  %index128 = load i64, ptr %index_ptr127, align 4
  br label %cond129

cond129:                                          ; preds = %next130, %func_3_dispatch
  %128 = icmp ult i64 %index128, 3
  br i1 %128, label %body131, label %end_for132

next130:                                          ; preds = %end_for141
  %index151 = load i64, ptr %index_ptr127, align 4
  %129 = add i64 %index151, 1
  store i64 %129, ptr %index_ptr127, align 4
  br label %cond129

body131:                                          ; preds = %cond129
  %130 = sub i64 2, %index128
  call void @builtin_range_check(i64 %130)
  %index_access133 = getelementptr [3 x ptr], ptr %127, i64 0, i64 %index128
  %arr134 = load ptr, ptr %index_access133, align 8
  %vector_length135 = load i64, ptr %arr134, align 4
  %131 = load i64, ptr %array_size126, align 4
  %132 = add i64 %131, %vector_length135
  store i64 %132, ptr %array_size126, align 4
  store i64 0, ptr %index_ptr136, align 4
  %index137 = load i64, ptr %index_ptr136, align 4
  br label %cond138

end_for132:                                       ; preds = %cond129
  %133 = load i64, ptr %array_size126, align 4
  %heap_size152 = add i64 %133, 1
  %134 = call ptr @heap_malloc(i64 %heap_size152)
  store i64 0, ptr %buffer_offset153, align 4
  store i64 0, ptr %index_ptr154, align 4
  %index155 = load i64, ptr %index_ptr154, align 4
  br label %cond156

cond138:                                          ; preds = %next139, %body131
  %135 = sub i64 2, %index128
  call void @builtin_range_check(i64 %135)
  %index_access142 = getelementptr [3 x ptr], ptr %127, i64 0, i64 %index128
  %arr143 = load ptr, ptr %index_access142, align 8
  %vector_length144 = load i64, ptr %arr143, align 4
  %136 = icmp ult i64 %index137, %vector_length144
  br i1 %136, label %body140, label %end_for141

next139:                                          ; preds = %body140
  %index150 = load i64, ptr %index_ptr136, align 4
  %137 = add i64 %index150, 1
  store i64 %137, ptr %index_ptr136, align 4
  br label %cond138

body140:                                          ; preds = %cond138
  %138 = sub i64 2, %index128
  call void @builtin_range_check(i64 %138)
  %index_access145 = getelementptr [3 x ptr], ptr %127, i64 0, i64 %index128
  %arr146 = load ptr, ptr %index_access145, align 8
  %vector_length147 = load i64, ptr %arr146, align 4
  %139 = sub i64 %vector_length147, 1
  %140 = sub i64 %139, %index137
  call void @builtin_range_check(i64 %140)
  %vector_data148 = getelementptr i64, ptr %arr146, i64 1
  %index_access149 = getelementptr ptr, ptr %vector_data148, i64 %index137
  %141 = load i64, ptr %array_size126, align 4
  %142 = add i64 %141, 4
  store i64 %142, ptr %array_size126, align 4
  br label %next139

end_for141:                                       ; preds = %cond138
  br label %next130

cond156:                                          ; preds = %next157, %end_for132
  %143 = icmp ult i64 %index155, 3
  br i1 %143, label %body158, label %end_for159

next157:                                          ; preds = %end_for168
  %index182 = load i64, ptr %index_ptr154, align 4
  %144 = add i64 %index182, 1
  store i64 %144, ptr %index_ptr154, align 4
  br label %cond156

body158:                                          ; preds = %cond156
  %145 = sub i64 2, %index155
  call void @builtin_range_check(i64 %145)
  %index_access160 = getelementptr [3 x ptr], ptr %127, i64 0, i64 %index155
  %arr161 = load ptr, ptr %index_access160, align 8
  %146 = load i64, ptr %buffer_offset153, align 4
  %147 = add i64 %146, 1
  store i64 %147, ptr %buffer_offset153, align 4
  %148 = getelementptr ptr, ptr %134, i64 %146
  %vector_length162 = load i64, ptr %arr161, align 4
  store i64 %vector_length162, ptr %148, align 4
  store i64 0, ptr %index_ptr163, align 4
  %index164 = load i64, ptr %index_ptr163, align 4
  br label %cond165

end_for159:                                       ; preds = %cond156
  %149 = load i64, ptr %buffer_offset153, align 4
  %150 = getelementptr ptr, ptr %134, i64 %149
  store i64 %133, ptr %150, align 4
  call void @set_tape_data(ptr %134, i64 %heap_size152)
  ret void

cond165:                                          ; preds = %next166, %body158
  %vector_length169 = load i64, ptr %127, align 4
  %151 = sub i64 %vector_length169, 1
  %152 = sub i64 %151, %index155
  call void @builtin_range_check(i64 %152)
  %vector_data170 = getelementptr i64, ptr %127, i64 1
  %index_access171 = getelementptr ptr, ptr %vector_data170, i64 %index155
  %arr172 = load ptr, ptr %index_access171, align 8
  %vector_length173 = load i64, ptr %arr172, align 4
  %153 = icmp ult i64 %index164, %vector_length173
  br i1 %153, label %body167, label %end_for168

next166:                                          ; preds = %body167
  %index181 = load i64, ptr %index_ptr163, align 4
  %154 = add i64 %index181, 1
  store i64 %154, ptr %index_ptr163, align 4
  br label %cond165

body167:                                          ; preds = %cond165
  %vector_length174 = load i64, ptr %127, align 4
  %155 = sub i64 %vector_length174, 1
  %156 = sub i64 %155, %index155
  call void @builtin_range_check(i64 %156)
  %vector_data175 = getelementptr i64, ptr %127, i64 1
  %index_access176 = getelementptr ptr, ptr %vector_data175, i64 %index155
  %arr177 = load ptr, ptr %index_access176, align 8
  %vector_length178 = load i64, ptr %arr177, align 4
  %157 = sub i64 %vector_length178, 1
  %158 = sub i64 %157, %index164
  call void @builtin_range_check(i64 %158)
  %vector_data179 = getelementptr i64, ptr %arr177, i64 1
  %index_access180 = getelementptr ptr, ptr %vector_data179, i64 %index164
  %159 = load i64, ptr %buffer_offset153, align 4
  %160 = getelementptr ptr, ptr %134, i64 %159
  %161 = getelementptr i64, ptr %index_access180, i64 0
  %162 = load i64, ptr %161, align 4
  %163 = getelementptr i64, ptr %160, i64 0
  store i64 %162, ptr %163, align 4
  %164 = getelementptr i64, ptr %index_access180, i64 1
  %165 = load i64, ptr %164, align 4
  %166 = getelementptr i64, ptr %160, i64 1
  store i64 %165, ptr %166, align 4
  %167 = getelementptr i64, ptr %index_access180, i64 2
  %168 = load i64, ptr %167, align 4
  %169 = getelementptr i64, ptr %160, i64 2
  store i64 %168, ptr %169, align 4
  %170 = getelementptr i64, ptr %index_access180, i64 3
  %171 = load i64, ptr %170, align 4
  %172 = getelementptr i64, ptr %160, i64 3
  store i64 %171, ptr %172, align 4
  %173 = load i64, ptr %buffer_offset153, align 4
  %174 = add i64 %173, 4
  store i64 %174, ptr %buffer_offset153, align 4
  br label %next166

end_for168:                                       ; preds = %cond165
  br label %next157
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
