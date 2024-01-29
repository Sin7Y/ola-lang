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

define void @array_input(ptr %0) {
entry:
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %1 = load ptr, ptr %array, align 8
  %index_access = getelementptr [3 x ptr], ptr %1, i64 0, i64 0
  %2 = load ptr, ptr %index_access, align 8
  ret void
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
  %index_ptr202 = alloca i64, align 8
  %index_ptr193 = alloca i64, align 8
  %buffer_offset192 = alloca i64, align 8
  %index_ptr172 = alloca i64, align 8
  %index_ptr167 = alloca i64, align 8
  %array_size166 = alloca i64, align 8
  %index_ptr154 = alloca i64, align 8
  %buffer_offset152 = alloca i64, align 8
  %index_ptr139 = alloca i64, align 8
  %array_size138 = alloca i64, align 8
  %index_ptr119 = alloca i64, align 8
  %index_ptr109 = alloca i64, align 8
  %array_ptr108 = alloca ptr, align 8
  %offset_var107 = alloca i64, align 8
  %index_ptr84 = alloca i64, align 8
  %index_ptr75 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr55 = alloca i64, align 8
  %index_ptr50 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr31 = alloca i64, align 8
  %index_ptr21 = alloca i64, align 8
  %array_ptr20 = alloca ptr, align 8
  %offset_var19 = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 518061708, label %func_0_dispatch
    i64 271119659, label %func_1_dispatch
    i64 2873489331, label %func_2_dispatch
    i64 3210415193, label %func_3_dispatch
    i64 208757611, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var, align 4
  %4 = load i64, ptr %offset_var, align 4
  %5 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %6 = load i64, ptr %index_ptr, align 4
  %7 = icmp ult i64 %6, 3
  br i1 %7, label %body, label %end_for

body:                                             ; preds = %cond
  %8 = load i64, ptr %offset_var, align 4
  %9 = getelementptr ptr, ptr %3, i64 %8
  %10 = load i64, ptr %offset_var, align 4
  %array_length = getelementptr ptr, ptr %9, i64 %10
  %11 = load i64, ptr %array_length, align 4
  %12 = add i64 %10, 1
  store i64 %12, ptr %offset_var, align 4
  %13 = call ptr @vector_new(i64 %11)
  %load_array = load ptr, ptr %array_ptr, align 8
  %array_index = load i64, ptr %index_ptr, align 4
  %14 = sub i64 2, %array_index
  call void @builtin_range_check(i64 %14)
  %index_access = getelementptr [3 x ptr], ptr %load_array, i64 0, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  store ptr %13, ptr %index_access, align 8
  %15 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

next:                                             ; preds = %end_for5
  %index16 = load i64, ptr %index_ptr, align 4
  %16 = add i64 %index16, 1
  store i64 %16, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %17 = load ptr, ptr %array_ptr, align 8
  %18 = load i64, ptr %offset_var, align 4
  %19 = getelementptr ptr, ptr %3, i64 %18
  %20 = load i64, ptr %19, align 4
  %21 = call ptr @array_input_u32(ptr %17, i64 %20)
  %vector_length17 = load i64, ptr %21, align 4
  %22 = mul i64 %vector_length17, 1
  %23 = add i64 %22, 1
  %heap_size = add i64 %23, 1
  %24 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length18 = load i64, ptr %21, align 4
  %25 = mul i64 %vector_length18, 1
  %26 = add i64 %25, 1
  call void @memcpy(ptr %21, ptr %24, i64 %26)
  %27 = getelementptr ptr, ptr %24, i64 %26
  store i64 %23, ptr %27, align 4
  call void @set_tape_data(ptr %24, i64 %heap_size)
  ret void

cond2:                                            ; preds = %next4, %body
  %array_index6 = load i64, ptr %index_ptr, align 4
  %28 = sub i64 2, %array_index6
  call void @builtin_range_check(i64 %28)
  %index_access7 = getelementptr [3 x ptr], ptr %15, i64 0, i64 %array_index6
  %array_element8 = load ptr, ptr %index_access7, align 8
  %vector_length = load i64, ptr %array_element8, align 4
  %29 = load i64, ptr %index_ptr1, align 4
  %30 = icmp ult i64 %29, %vector_length
  br i1 %30, label %body3, label %end_for5

body3:                                            ; preds = %cond2
  %31 = load i64, ptr %offset_var, align 4
  %32 = getelementptr ptr, ptr %9, i64 %31
  %33 = load i64, ptr %32, align 4
  %34 = load ptr, ptr %array_ptr, align 8
  %array_index9 = load i64, ptr %index_ptr, align 4
  %35 = sub i64 2, %array_index9
  call void @builtin_range_check(i64 %35)
  %index_access10 = getelementptr [3 x ptr], ptr %34, i64 0, i64 %array_index9
  %array_element11 = load ptr, ptr %index_access10, align 8
  %array_index12 = load i64, ptr %index_ptr1, align 4
  %vector_length13 = load i64, ptr %array_element11, align 4
  %36 = sub i64 %vector_length13, 1
  %37 = sub i64 %36, %array_index12
  call void @builtin_range_check(i64 %37)
  %vector_data = getelementptr i64, ptr %array_element11, i64 1
  %index_access14 = getelementptr i64, ptr %vector_data, i64 %array_index12
  %array_element15 = load i64, ptr %index_access14, align 4
  store i64 %33, ptr %index_access14, align 4
  %38 = add i64 1, %31
  store i64 %38, ptr %offset_var, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index = load i64, ptr %index_ptr1, align 4
  %39 = add i64 %index, 1
  store i64 %39, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  br label %next

func_1_dispatch:                                  ; preds = %entry
  %40 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var19, align 4
  %41 = load i64, ptr %offset_var19, align 4
  %42 = load ptr, ptr %array_ptr20, align 8
  store i64 0, ptr %index_ptr21, align 4
  br label %cond22

cond22:                                           ; preds = %next24, %func_1_dispatch
  %43 = load i64, ptr %index_ptr21, align 4
  %44 = icmp ult i64 %43, 3
  br i1 %44, label %body23, label %end_for25

body23:                                           ; preds = %cond22
  %45 = load i64, ptr %offset_var19, align 4
  %46 = getelementptr ptr, ptr %40, i64 %45
  %47 = load i64, ptr %offset_var19, align 4
  %array_length26 = getelementptr ptr, ptr %46, i64 %47
  %48 = load i64, ptr %array_length26, align 4
  %49 = add i64 %47, 1
  store i64 %49, ptr %offset_var19, align 4
  %50 = call ptr @vector_new(i64 %48)
  %load_array27 = load ptr, ptr %array_ptr20, align 8
  %array_index28 = load i64, ptr %index_ptr21, align 4
  %51 = sub i64 2, %array_index28
  call void @builtin_range_check(i64 %51)
  %index_access29 = getelementptr [3 x ptr], ptr %load_array27, i64 0, i64 %array_index28
  %array_element30 = load ptr, ptr %index_access29, align 8
  store ptr %50, ptr %index_access29, align 8
  %52 = load ptr, ptr %array_ptr20, align 8
  store i64 0, ptr %index_ptr31, align 4
  br label %cond32

next24:                                           ; preds = %end_for35
  %index49 = load i64, ptr %index_ptr21, align 4
  %53 = add i64 %index49, 1
  store i64 %53, ptr %index_ptr21, align 4
  br label %cond22

end_for25:                                        ; preds = %cond22
  %54 = load ptr, ptr %array_ptr20, align 8
  %55 = load i64, ptr %offset_var19, align 4
  call void @array_input(ptr %54)
  %56 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %56, align 4
  call void @set_tape_data(ptr %56, i64 1)
  ret void

cond32:                                           ; preds = %next34, %body23
  %array_index36 = load i64, ptr %index_ptr21, align 4
  %57 = sub i64 2, %array_index36
  call void @builtin_range_check(i64 %57)
  %index_access37 = getelementptr [3 x ptr], ptr %52, i64 0, i64 %array_index36
  %array_element38 = load ptr, ptr %index_access37, align 8
  %vector_length39 = load i64, ptr %array_element38, align 4
  %58 = load i64, ptr %index_ptr31, align 4
  %59 = icmp ult i64 %58, %vector_length39
  br i1 %59, label %body33, label %end_for35

body33:                                           ; preds = %cond32
  %60 = load i64, ptr %offset_var19, align 4
  %61 = getelementptr ptr, ptr %46, i64 %60
  %62 = load i64, ptr %61, align 4
  %63 = load ptr, ptr %array_ptr20, align 8
  %array_index40 = load i64, ptr %index_ptr21, align 4
  %64 = sub i64 2, %array_index40
  call void @builtin_range_check(i64 %64)
  %index_access41 = getelementptr [3 x ptr], ptr %63, i64 0, i64 %array_index40
  %array_element42 = load ptr, ptr %index_access41, align 8
  %array_index43 = load i64, ptr %index_ptr31, align 4
  %vector_length44 = load i64, ptr %array_element42, align 4
  %65 = sub i64 %vector_length44, 1
  %66 = sub i64 %65, %array_index43
  call void @builtin_range_check(i64 %66)
  %vector_data45 = getelementptr i64, ptr %array_element42, i64 1
  %index_access46 = getelementptr i64, ptr %vector_data45, i64 %array_index43
  %array_element47 = load i64, ptr %index_access46, align 4
  store i64 %62, ptr %index_access46, align 4
  %67 = add i64 1, %60
  store i64 %67, ptr %offset_var19, align 4
  br label %next34

next34:                                           ; preds = %body33
  %index48 = load i64, ptr %index_ptr31, align 4
  %68 = add i64 %index48, 1
  store i64 %68, ptr %index_ptr31, align 4
  br label %cond32

end_for35:                                        ; preds = %cond32
  br label %next24

func_2_dispatch:                                  ; preds = %entry
  %69 = call ptr @array_output_u32()
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr50, align 4
  br label %cond51

cond51:                                           ; preds = %next53, %func_2_dispatch
  %70 = load i64, ptr %index_ptr50, align 4
  %71 = icmp ult i64 %70, 3
  br i1 %71, label %body52, label %end_for54

body52:                                           ; preds = %cond51
  %72 = load i64, ptr %array_size, align 4
  %73 = add i64 %72, 1
  store i64 %73, ptr %array_size, align 4
  store i64 0, ptr %index_ptr55, align 4
  br label %cond56

next53:                                           ; preds = %end_for59
  %index73 = load i64, ptr %index_ptr50, align 4
  %74 = add i64 %index73, 1
  store i64 %74, ptr %index_ptr50, align 4
  br label %cond51

end_for54:                                        ; preds = %cond51
  %75 = load i64, ptr %array_size, align 4
  %heap_size74 = add i64 %75, 1
  %76 = call ptr @heap_malloc(i64 %heap_size74)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr75, align 4
  br label %cond76

cond56:                                           ; preds = %next58, %body52
  %array_index60 = load i64, ptr %index_ptr50, align 4
  %77 = sub i64 2, %array_index60
  call void @builtin_range_check(i64 %77)
  %index_access61 = getelementptr [3 x ptr], ptr %69, i64 0, i64 %array_index60
  %array_element62 = load ptr, ptr %index_access61, align 8
  %vector_length63 = load i64, ptr %array_element62, align 4
  %78 = load i64, ptr %index_ptr55, align 4
  %79 = icmp ult i64 %78, %vector_length63
  br i1 %79, label %body57, label %end_for59

body57:                                           ; preds = %cond56
  %array_index64 = load i64, ptr %index_ptr50, align 4
  %80 = sub i64 2, %array_index64
  call void @builtin_range_check(i64 %80)
  %index_access65 = getelementptr [3 x ptr], ptr %69, i64 0, i64 %array_index64
  %array_element66 = load ptr, ptr %index_access65, align 8
  %array_index67 = load i64, ptr %index_ptr55, align 4
  %vector_length68 = load i64, ptr %array_element66, align 4
  %81 = sub i64 %vector_length68, 1
  %82 = sub i64 %81, %array_index67
  call void @builtin_range_check(i64 %82)
  %vector_data69 = getelementptr i64, ptr %array_element66, i64 1
  %index_access70 = getelementptr i64, ptr %vector_data69, i64 %array_index67
  %array_element71 = load i64, ptr %index_access70, align 4
  %83 = load i64, ptr %array_size, align 4
  %84 = add i64 %83, 1
  store i64 %84, ptr %array_size, align 4
  br label %next58

next58:                                           ; preds = %body57
  %index72 = load i64, ptr %index_ptr55, align 4
  %85 = add i64 %index72, 1
  store i64 %85, ptr %index_ptr55, align 4
  br label %cond56

end_for59:                                        ; preds = %cond56
  br label %next53

cond76:                                           ; preds = %next78, %end_for54
  %86 = load i64, ptr %index_ptr75, align 4
  %87 = icmp ult i64 %86, 3
  br i1 %87, label %body77, label %end_for79

body77:                                           ; preds = %cond76
  %array_index80 = load i64, ptr %index_ptr75, align 4
  %88 = sub i64 2, %array_index80
  call void @builtin_range_check(i64 %88)
  %index_access81 = getelementptr [3 x ptr], ptr %69, i64 0, i64 %array_index80
  %array_element82 = load ptr, ptr %index_access81, align 8
  %89 = load i64, ptr %buffer_offset, align 4
  %90 = add i64 %89, 1
  store i64 %90, ptr %buffer_offset, align 4
  %91 = getelementptr ptr, ptr %76, i64 %89
  %vector_length83 = load i64, ptr %array_element82, align 4
  store i64 %vector_length83, ptr %91, align 4
  store i64 0, ptr %index_ptr84, align 4
  br label %cond85

next78:                                           ; preds = %end_for88
  %index106 = load i64, ptr %index_ptr75, align 4
  %92 = add i64 %index106, 1
  store i64 %92, ptr %index_ptr75, align 4
  br label %cond76

end_for79:                                        ; preds = %cond76
  %93 = load i64, ptr %buffer_offset, align 4
  %94 = getelementptr ptr, ptr %76, i64 %93
  store i64 %75, ptr %94, align 4
  call void @set_tape_data(ptr %76, i64 %heap_size74)
  ret void

cond85:                                           ; preds = %next87, %body77
  %array_index89 = load i64, ptr %index_ptr75, align 4
  %vector_length90 = load i64, ptr %69, align 4
  %95 = sub i64 %vector_length90, 1
  %96 = sub i64 %95, %array_index89
  call void @builtin_range_check(i64 %96)
  %vector_data91 = getelementptr i64, ptr %69, i64 1
  %index_access92 = getelementptr i64, ptr %vector_data91, i64 %array_index89
  %array_element93 = load ptr, ptr %index_access92, align 8
  %vector_length94 = load i64, ptr %array_element93, align 4
  %97 = load i64, ptr %index_ptr84, align 4
  %98 = icmp ult i64 %97, %vector_length94
  br i1 %98, label %body86, label %end_for88

body86:                                           ; preds = %cond85
  %array_index95 = load i64, ptr %index_ptr75, align 4
  %vector_length96 = load i64, ptr %69, align 4
  %99 = sub i64 %vector_length96, 1
  %100 = sub i64 %99, %array_index95
  call void @builtin_range_check(i64 %100)
  %vector_data97 = getelementptr i64, ptr %69, i64 1
  %index_access98 = getelementptr i64, ptr %vector_data97, i64 %array_index95
  %array_element99 = load ptr, ptr %index_access98, align 8
  %array_index100 = load i64, ptr %index_ptr84, align 4
  %vector_length101 = load i64, ptr %array_element99, align 4
  %101 = sub i64 %vector_length101, 1
  %102 = sub i64 %101, %array_index100
  call void @builtin_range_check(i64 %102)
  %vector_data102 = getelementptr i64, ptr %array_element99, i64 1
  %index_access103 = getelementptr i64, ptr %vector_data102, i64 %array_index100
  %array_element104 = load i64, ptr %index_access103, align 4
  %103 = load i64, ptr %buffer_offset, align 4
  %104 = getelementptr ptr, ptr %76, i64 %103
  store i64 %array_element104, ptr %104, align 4
  %105 = load i64, ptr %buffer_offset, align 4
  %106 = add i64 %105, 1
  store i64 %106, ptr %buffer_offset, align 4
  br label %next87

next87:                                           ; preds = %body86
  %index105 = load i64, ptr %index_ptr84, align 4
  %107 = add i64 %index105, 1
  store i64 %107, ptr %index_ptr84, align 4
  br label %cond85

end_for88:                                        ; preds = %cond85
  br label %next78

func_3_dispatch:                                  ; preds = %entry
  %108 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var107, align 4
  %109 = load i64, ptr %offset_var107, align 4
  %110 = load ptr, ptr %array_ptr108, align 8
  store i64 0, ptr %index_ptr109, align 4
  br label %cond110

cond110:                                          ; preds = %next112, %func_3_dispatch
  %111 = load i64, ptr %index_ptr109, align 4
  %112 = icmp ult i64 %111, 3
  br i1 %112, label %body111, label %end_for113

body111:                                          ; preds = %cond110
  %113 = load i64, ptr %offset_var107, align 4
  %114 = getelementptr ptr, ptr %108, i64 %113
  %115 = load i64, ptr %offset_var107, align 4
  %array_length114 = getelementptr ptr, ptr %114, i64 %115
  %116 = load i64, ptr %array_length114, align 4
  %117 = add i64 %115, 1
  store i64 %117, ptr %offset_var107, align 4
  %118 = call ptr @vector_new(i64 %116)
  %load_array115 = load ptr, ptr %array_ptr108, align 8
  %array_index116 = load i64, ptr %index_ptr109, align 4
  %119 = sub i64 2, %array_index116
  call void @builtin_range_check(i64 %119)
  %index_access117 = getelementptr [3 x ptr], ptr %load_array115, i64 0, i64 %array_index116
  %array_element118 = load ptr, ptr %index_access117, align 8
  store ptr %118, ptr %index_access117, align 8
  %120 = load ptr, ptr %array_ptr108, align 8
  store i64 0, ptr %index_ptr119, align 4
  br label %cond120

next112:                                          ; preds = %end_for123
  %index137 = load i64, ptr %index_ptr109, align 4
  %121 = add i64 %index137, 1
  store i64 %121, ptr %index_ptr109, align 4
  br label %cond110

end_for113:                                       ; preds = %cond110
  %122 = load ptr, ptr %array_ptr108, align 8
  %123 = load i64, ptr %offset_var107, align 4
  %124 = getelementptr ptr, ptr %108, i64 %123
  %125 = load i64, ptr %124, align 4
  %126 = call ptr @array_input_address(ptr %122, i64 %125)
  store i64 0, ptr %array_size138, align 4
  %127 = load i64, ptr %array_size138, align 4
  %128 = add i64 %127, 1
  store i64 %128, ptr %array_size138, align 4
  store i64 0, ptr %index_ptr139, align 4
  br label %cond140

cond120:                                          ; preds = %next122, %body111
  %array_index124 = load i64, ptr %index_ptr109, align 4
  %129 = sub i64 2, %array_index124
  call void @builtin_range_check(i64 %129)
  %index_access125 = getelementptr [3 x ptr], ptr %120, i64 0, i64 %array_index124
  %array_element126 = load ptr, ptr %index_access125, align 8
  %vector_length127 = load i64, ptr %array_element126, align 4
  %130 = load i64, ptr %index_ptr119, align 4
  %131 = icmp ult i64 %130, %vector_length127
  br i1 %131, label %body121, label %end_for123

body121:                                          ; preds = %cond120
  %132 = load i64, ptr %offset_var107, align 4
  %133 = getelementptr ptr, ptr %114, i64 %132
  %134 = load ptr, ptr %array_ptr108, align 8
  %array_index128 = load i64, ptr %index_ptr109, align 4
  %135 = sub i64 2, %array_index128
  call void @builtin_range_check(i64 %135)
  %index_access129 = getelementptr [3 x ptr], ptr %134, i64 0, i64 %array_index128
  %array_element130 = load ptr, ptr %index_access129, align 8
  %array_index131 = load i64, ptr %index_ptr119, align 4
  %vector_length132 = load i64, ptr %array_element130, align 4
  %136 = sub i64 %vector_length132, 1
  %137 = sub i64 %136, %array_index131
  call void @builtin_range_check(i64 %137)
  %vector_data133 = getelementptr i64, ptr %array_element130, i64 1
  %index_access134 = getelementptr ptr, ptr %vector_data133, i64 %array_index131
  %array_element135 = load ptr, ptr %index_access134, align 8
  store ptr %133, ptr %index_access134, align 8
  %138 = add i64 4, %132
  store i64 %138, ptr %offset_var107, align 4
  br label %next122

next122:                                          ; preds = %body121
  %index136 = load i64, ptr %index_ptr119, align 4
  %139 = add i64 %index136, 1
  store i64 %139, ptr %index_ptr119, align 4
  br label %cond120

end_for123:                                       ; preds = %cond120
  br label %next112

cond140:                                          ; preds = %next142, %end_for113
  %vector_length144 = load i64, ptr %126, align 4
  %140 = load i64, ptr %index_ptr139, align 4
  %141 = icmp ult i64 %140, %vector_length144
  br i1 %141, label %body141, label %end_for143

body141:                                          ; preds = %cond140
  %array_index145 = load i64, ptr %index_ptr139, align 4
  %vector_length146 = load i64, ptr %126, align 4
  %142 = sub i64 %vector_length146, 1
  %143 = sub i64 %142, %array_index145
  call void @builtin_range_check(i64 %143)
  %vector_data147 = getelementptr i64, ptr %126, i64 1
  %index_access148 = getelementptr ptr, ptr %vector_data147, i64 %array_index145
  %array_element149 = load ptr, ptr %index_access148, align 8
  %144 = load i64, ptr %array_size138, align 4
  %145 = add i64 %144, 4
  store i64 %145, ptr %array_size138, align 4
  br label %next142

next142:                                          ; preds = %body141
  %index150 = load i64, ptr %index_ptr139, align 4
  %146 = add i64 %index150, 1
  store i64 %146, ptr %index_ptr139, align 4
  br label %cond140

end_for143:                                       ; preds = %cond140
  %147 = load i64, ptr %array_size138, align 4
  %heap_size151 = add i64 %147, 1
  %148 = call ptr @heap_malloc(i64 %heap_size151)
  store i64 0, ptr %buffer_offset152, align 4
  %149 = load i64, ptr %buffer_offset152, align 4
  %150 = add i64 %149, 1
  store i64 %150, ptr %buffer_offset152, align 4
  %151 = getelementptr ptr, ptr %148, i64 %149
  %vector_length153 = load i64, ptr %126, align 4
  store i64 %vector_length153, ptr %151, align 4
  store i64 0, ptr %index_ptr154, align 4
  br label %cond155

cond155:                                          ; preds = %next157, %end_for143
  %vector_length159 = load i64, ptr %126, align 4
  %152 = load i64, ptr %index_ptr154, align 4
  %153 = icmp ult i64 %152, %vector_length159
  br i1 %153, label %body156, label %end_for158

body156:                                          ; preds = %cond155
  %array_index160 = load i64, ptr %index_ptr154, align 4
  %vector_length161 = load i64, ptr %126, align 4
  %154 = sub i64 %vector_length161, 1
  %155 = sub i64 %154, %array_index160
  call void @builtin_range_check(i64 %155)
  %vector_data162 = getelementptr i64, ptr %126, i64 1
  %index_access163 = getelementptr ptr, ptr %vector_data162, i64 %array_index160
  %array_element164 = load ptr, ptr %index_access163, align 8
  %156 = load i64, ptr %buffer_offset152, align 4
  %157 = getelementptr ptr, ptr %148, i64 %156
  %158 = getelementptr i64, ptr %array_element164, i64 0
  %159 = load i64, ptr %158, align 4
  %160 = getelementptr i64, ptr %157, i64 0
  store i64 %159, ptr %160, align 4
  %161 = getelementptr i64, ptr %array_element164, i64 1
  %162 = load i64, ptr %161, align 4
  %163 = getelementptr i64, ptr %157, i64 1
  store i64 %162, ptr %163, align 4
  %164 = getelementptr i64, ptr %array_element164, i64 2
  %165 = load i64, ptr %164, align 4
  %166 = getelementptr i64, ptr %157, i64 2
  store i64 %165, ptr %166, align 4
  %167 = getelementptr i64, ptr %array_element164, i64 3
  %168 = load i64, ptr %167, align 4
  %169 = getelementptr i64, ptr %157, i64 3
  store i64 %168, ptr %169, align 4
  %170 = load i64, ptr %buffer_offset152, align 4
  %171 = add i64 %170, 4
  store i64 %171, ptr %buffer_offset152, align 4
  br label %next157

next157:                                          ; preds = %body156
  %index165 = load i64, ptr %index_ptr154, align 4
  %172 = add i64 %index165, 1
  store i64 %172, ptr %index_ptr154, align 4
  br label %cond155

end_for158:                                       ; preds = %cond155
  %173 = load i64, ptr %buffer_offset152, align 4
  %174 = getelementptr ptr, ptr %148, i64 %173
  store i64 %147, ptr %174, align 4
  call void @set_tape_data(ptr %148, i64 %heap_size151)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %175 = call ptr @array_output_address()
  store i64 0, ptr %array_size166, align 4
  store i64 0, ptr %index_ptr167, align 4
  br label %cond168

cond168:                                          ; preds = %next170, %func_4_dispatch
  %176 = load i64, ptr %index_ptr167, align 4
  %177 = icmp ult i64 %176, 3
  br i1 %177, label %body169, label %end_for171

body169:                                          ; preds = %cond168
  %178 = load i64, ptr %array_size166, align 4
  %179 = add i64 %178, 1
  store i64 %179, ptr %array_size166, align 4
  store i64 0, ptr %index_ptr172, align 4
  br label %cond173

next170:                                          ; preds = %end_for176
  %index190 = load i64, ptr %index_ptr167, align 4
  %180 = add i64 %index190, 1
  store i64 %180, ptr %index_ptr167, align 4
  br label %cond168

end_for171:                                       ; preds = %cond168
  %181 = load i64, ptr %array_size166, align 4
  %heap_size191 = add i64 %181, 1
  %182 = call ptr @heap_malloc(i64 %heap_size191)
  store i64 0, ptr %buffer_offset192, align 4
  store i64 0, ptr %index_ptr193, align 4
  br label %cond194

cond173:                                          ; preds = %next175, %body169
  %array_index177 = load i64, ptr %index_ptr167, align 4
  %183 = sub i64 2, %array_index177
  call void @builtin_range_check(i64 %183)
  %index_access178 = getelementptr [3 x ptr], ptr %175, i64 0, i64 %array_index177
  %array_element179 = load ptr, ptr %index_access178, align 8
  %vector_length180 = load i64, ptr %array_element179, align 4
  %184 = load i64, ptr %index_ptr172, align 4
  %185 = icmp ult i64 %184, %vector_length180
  br i1 %185, label %body174, label %end_for176

body174:                                          ; preds = %cond173
  %array_index181 = load i64, ptr %index_ptr167, align 4
  %186 = sub i64 2, %array_index181
  call void @builtin_range_check(i64 %186)
  %index_access182 = getelementptr [3 x ptr], ptr %175, i64 0, i64 %array_index181
  %array_element183 = load ptr, ptr %index_access182, align 8
  %array_index184 = load i64, ptr %index_ptr172, align 4
  %vector_length185 = load i64, ptr %array_element183, align 4
  %187 = sub i64 %vector_length185, 1
  %188 = sub i64 %187, %array_index184
  call void @builtin_range_check(i64 %188)
  %vector_data186 = getelementptr i64, ptr %array_element183, i64 1
  %index_access187 = getelementptr ptr, ptr %vector_data186, i64 %array_index184
  %array_element188 = load ptr, ptr %index_access187, align 8
  %189 = load i64, ptr %array_size166, align 4
  %190 = add i64 %189, 4
  store i64 %190, ptr %array_size166, align 4
  br label %next175

next175:                                          ; preds = %body174
  %index189 = load i64, ptr %index_ptr172, align 4
  %191 = add i64 %index189, 1
  store i64 %191, ptr %index_ptr172, align 4
  br label %cond173

end_for176:                                       ; preds = %cond173
  br label %next170

cond194:                                          ; preds = %next196, %end_for171
  %192 = load i64, ptr %index_ptr193, align 4
  %193 = icmp ult i64 %192, 3
  br i1 %193, label %body195, label %end_for197

body195:                                          ; preds = %cond194
  %array_index198 = load i64, ptr %index_ptr193, align 4
  %194 = sub i64 2, %array_index198
  call void @builtin_range_check(i64 %194)
  %index_access199 = getelementptr [3 x ptr], ptr %175, i64 0, i64 %array_index198
  %array_element200 = load ptr, ptr %index_access199, align 8
  %195 = load i64, ptr %buffer_offset192, align 4
  %196 = add i64 %195, 1
  store i64 %196, ptr %buffer_offset192, align 4
  %197 = getelementptr ptr, ptr %182, i64 %195
  %vector_length201 = load i64, ptr %array_element200, align 4
  store i64 %vector_length201, ptr %197, align 4
  store i64 0, ptr %index_ptr202, align 4
  br label %cond203

next196:                                          ; preds = %end_for206
  %index224 = load i64, ptr %index_ptr193, align 4
  %198 = add i64 %index224, 1
  store i64 %198, ptr %index_ptr193, align 4
  br label %cond194

end_for197:                                       ; preds = %cond194
  %199 = load i64, ptr %buffer_offset192, align 4
  %200 = getelementptr ptr, ptr %182, i64 %199
  store i64 %181, ptr %200, align 4
  call void @set_tape_data(ptr %182, i64 %heap_size191)
  ret void

cond203:                                          ; preds = %next205, %body195
  %array_index207 = load i64, ptr %index_ptr193, align 4
  %vector_length208 = load i64, ptr %175, align 4
  %201 = sub i64 %vector_length208, 1
  %202 = sub i64 %201, %array_index207
  call void @builtin_range_check(i64 %202)
  %vector_data209 = getelementptr i64, ptr %175, i64 1
  %index_access210 = getelementptr ptr, ptr %vector_data209, i64 %array_index207
  %array_element211 = load ptr, ptr %index_access210, align 8
  %vector_length212 = load i64, ptr %array_element211, align 4
  %203 = load i64, ptr %index_ptr202, align 4
  %204 = icmp ult i64 %203, %vector_length212
  br i1 %204, label %body204, label %end_for206

body204:                                          ; preds = %cond203
  %array_index213 = load i64, ptr %index_ptr193, align 4
  %vector_length214 = load i64, ptr %175, align 4
  %205 = sub i64 %vector_length214, 1
  %206 = sub i64 %205, %array_index213
  call void @builtin_range_check(i64 %206)
  %vector_data215 = getelementptr i64, ptr %175, i64 1
  %index_access216 = getelementptr ptr, ptr %vector_data215, i64 %array_index213
  %array_element217 = load ptr, ptr %index_access216, align 8
  %array_index218 = load i64, ptr %index_ptr202, align 4
  %vector_length219 = load i64, ptr %array_element217, align 4
  %207 = sub i64 %vector_length219, 1
  %208 = sub i64 %207, %array_index218
  call void @builtin_range_check(i64 %208)
  %vector_data220 = getelementptr i64, ptr %array_element217, i64 1
  %index_access221 = getelementptr ptr, ptr %vector_data220, i64 %array_index218
  %array_element222 = load ptr, ptr %index_access221, align 8
  %209 = load i64, ptr %buffer_offset192, align 4
  %210 = getelementptr ptr, ptr %182, i64 %209
  %211 = getelementptr i64, ptr %array_element222, i64 0
  %212 = load i64, ptr %211, align 4
  %213 = getelementptr i64, ptr %210, i64 0
  store i64 %212, ptr %213, align 4
  %214 = getelementptr i64, ptr %array_element222, i64 1
  %215 = load i64, ptr %214, align 4
  %216 = getelementptr i64, ptr %210, i64 1
  store i64 %215, ptr %216, align 4
  %217 = getelementptr i64, ptr %array_element222, i64 2
  %218 = load i64, ptr %217, align 4
  %219 = getelementptr i64, ptr %210, i64 2
  store i64 %218, ptr %219, align 4
  %220 = getelementptr i64, ptr %array_element222, i64 3
  %221 = load i64, ptr %220, align 4
  %222 = getelementptr i64, ptr %210, i64 3
  store i64 %221, ptr %222, align 4
  %223 = load i64, ptr %buffer_offset192, align 4
  %224 = add i64 %223, 4
  store i64 %224, ptr %buffer_offset192, align 4
  br label %next205

next205:                                          ; preds = %body204
  %index223 = load i64, ptr %index_ptr202, align 4
  %225 = add i64 %index223, 1
  store i64 %225, ptr %index_ptr202, align 4
  br label %cond203

end_for206:                                       ; preds = %cond203
  br label %next196
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
