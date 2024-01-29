; ModuleID = 'TwoDArrayExample'
source_filename = "array_2d_1"

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
  %counter = alloca i64, align 8
  %result = alloca i64, align 8
  store i64 0, ptr %counter, align 4
  store i64 1, ptr %result, align 4
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = load i64, ptr %counter, align 4
  %3 = load i64, ptr %result, align 4
  %newCounter = add i64 %2, 1
  %newResult = mul i64 %3, %0
  store i64 %newCounter, ptr %counter, align 4
  store i64 %newResult, ptr %result, align 4
  %condition = icmp ult i64 %newCounter, %1
  br i1 %condition, label %loop, label %exit

exit:                                             ; preds = %loop
  %finalResult = load i64, ptr %result, align 4
  ret i64 %finalResult
}

define ptr @create2DArray() {
entry:
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
  ret ptr %0
}

define ptr @create2DArray2() {
entry:
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
  %vector_length = load i64, ptr %0, align 4
  %1 = sub i64 %vector_length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %vector_data1 = getelementptr i64, ptr %0, i64 1
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %index_access3 = getelementptr [3 x i64], ptr %index_access2, i64 0, i64 1
  store i64 2, ptr %index_access3, align 4
  ret ptr %0
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %_j = alloca i64, align 8
  %_i = alloca i64, align 8
  %_array2D = alloca ptr, align 8
  store ptr %0, ptr %_array2D, align 8
  %3 = load ptr, ptr %_array2D, align 8
  store i64 %1, ptr %_i, align 4
  store i64 %2, ptr %_j, align 4
  %4 = load i64, ptr %_i, align 4
  %5 = sub i64 2, %4
  call void @builtin_range_check(i64 %5)
  %index_access = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 %4
  %6 = load i64, ptr %_j, align 4
  %7 = sub i64 1, %6
  call void @builtin_range_check(i64 %7)
  %index_access1 = getelementptr [2 x i64], ptr %index_access, i64 0, i64 %6
  %8 = load i64, ptr %index_access1, align 4
  ret i64 %8
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr23 = alloca i64, align 8
  %index_ptr17 = alloca i64, align 8
  %buffer_offset15 = alloca i64, align 8
  %index_ptr3 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 425699498, label %func_0_dispatch
    i64 1886808922, label %func_1_dispatch
    i64 1554798078, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @create2DArray()
  %vector_length = load i64, ptr %3, align 4
  %4 = mul i64 %vector_length, 3
  %5 = mul i64 %4, 1
  %6 = add i64 %5, 1
  %heap_size = add i64 %6, 1
  %7 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %8 = load i64, ptr %buffer_offset, align 4
  %9 = add i64 %8, 1
  store i64 %9, ptr %buffer_offset, align 4
  %10 = getelementptr ptr, ptr %7, i64 %8
  %vector_length1 = load i64, ptr %3, align 4
  store i64 %vector_length1, ptr %10, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %vector_length2 = load i64, ptr %3, align 4
  %11 = load i64, ptr %index_ptr, align 4
  %12 = icmp ult i64 %11, %vector_length2
  br i1 %12, label %body, label %end_for

body:                                             ; preds = %cond
  store i64 0, ptr %index_ptr3, align 4
  br label %cond4

next:                                             ; preds = %end_for7
  %index12 = load i64, ptr %index_ptr, align 4
  %13 = add i64 %index12, 1
  store i64 %13, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %14 = load i64, ptr %buffer_offset, align 4
  %15 = getelementptr ptr, ptr %7, i64 %14
  store i64 %6, ptr %15, align 4
  call void @set_tape_data(ptr %7, i64 %heap_size)
  ret void

cond4:                                            ; preds = %next6, %body
  %16 = load i64, ptr %index_ptr3, align 4
  %17 = icmp ult i64 %16, 3
  br i1 %17, label %body5, label %end_for7

body5:                                            ; preds = %cond4
  %array_index = load i64, ptr %index_ptr, align 4
  %vector_length8 = load i64, ptr %3, align 4
  %18 = sub i64 %vector_length8, 1
  %19 = sub i64 %18, %array_index
  call void @builtin_range_check(i64 %19)
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %array_index9 = load i64, ptr %index_ptr3, align 4
  %20 = sub i64 2, %array_index9
  call void @builtin_range_check(i64 %20)
  %index_access10 = getelementptr [3 x i64], ptr %array_element, i64 0, i64 %array_index9
  %array_element11 = load i64, ptr %index_access10, align 4
  %21 = load i64, ptr %buffer_offset, align 4
  %22 = getelementptr ptr, ptr %7, i64 %21
  store i64 %array_element11, ptr %22, align 4
  %23 = load i64, ptr %buffer_offset, align 4
  %24 = add i64 %23, 1
  store i64 %24, ptr %buffer_offset, align 4
<<<<<<< HEAD
=======
  %index_access10 = getelementptr [3 x i64], ptr %index_access, i64 0, i64 %index4
  %20 = load i64, ptr %buffer_offset, align 4
  %21 = getelementptr ptr, ptr %7, i64 %20
  store ptr %index_access10, ptr %21, align 8
  %22 = load i64, ptr %buffer_offset, align 4
  %23 = add i64 %22, 1
  store i64 %23, ptr %buffer_offset, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  br label %next6

next6:                                            ; preds = %body5
  %index = load i64, ptr %index_ptr3, align 4
  %25 = add i64 %index, 1
  store i64 %25, ptr %index_ptr3, align 4
  br label %cond4

end_for7:                                         ; preds = %cond4
  br label %next

func_1_dispatch:                                  ; preds = %entry
  %26 = call ptr @create2DArray2()
  %vector_length13 = load i64, ptr %26, align 4
  %27 = mul i64 %vector_length13, 3
  %28 = mul i64 %27, 1
  %29 = add i64 %28, 1
  %heap_size14 = add i64 %29, 1
  %30 = call ptr @heap_malloc(i64 %heap_size14)
  store i64 0, ptr %buffer_offset15, align 4
  %31 = load i64, ptr %buffer_offset15, align 4
  %32 = add i64 %31, 1
  store i64 %32, ptr %buffer_offset15, align 4
  %33 = getelementptr ptr, ptr %30, i64 %31
  %vector_length16 = load i64, ptr %26, align 4
  store i64 %vector_length16, ptr %33, align 4
  store i64 0, ptr %index_ptr17, align 4
  br label %cond18

cond18:                                           ; preds = %next20, %func_1_dispatch
  %vector_length22 = load i64, ptr %26, align 4
  %34 = load i64, ptr %index_ptr17, align 4
  %35 = icmp ult i64 %34, %vector_length22
  br i1 %35, label %body19, label %end_for21

body19:                                           ; preds = %cond18
  store i64 0, ptr %index_ptr23, align 4
  br label %cond24

next20:                                           ; preds = %end_for27
  %index37 = load i64, ptr %index_ptr17, align 4
  %36 = add i64 %index37, 1
  store i64 %36, ptr %index_ptr17, align 4
  br label %cond18

end_for21:                                        ; preds = %cond18
  %37 = load i64, ptr %buffer_offset15, align 4
  %38 = getelementptr ptr, ptr %30, i64 %37
  store i64 %29, ptr %38, align 4
  call void @set_tape_data(ptr %30, i64 %heap_size14)
  ret void

cond24:                                           ; preds = %next26, %body19
  %39 = load i64, ptr %index_ptr23, align 4
  %40 = icmp ult i64 %39, 3
  br i1 %40, label %body25, label %end_for27

body25:                                           ; preds = %cond24
  %array_index28 = load i64, ptr %index_ptr17, align 4
  %vector_length29 = load i64, ptr %26, align 4
  %41 = sub i64 %vector_length29, 1
  %42 = sub i64 %41, %array_index28
  call void @builtin_range_check(i64 %42)
  %vector_data30 = getelementptr i64, ptr %26, i64 1
  %index_access31 = getelementptr ptr, ptr %vector_data30, i64 %array_index28
  %array_element32 = load ptr, ptr %index_access31, align 8
  %array_index33 = load i64, ptr %index_ptr23, align 4
  %43 = sub i64 2, %array_index33
  call void @builtin_range_check(i64 %43)
  %index_access34 = getelementptr [3 x i64], ptr %array_element32, i64 0, i64 %array_index33
  %array_element35 = load i64, ptr %index_access34, align 4
  %44 = load i64, ptr %buffer_offset15, align 4
  %45 = getelementptr ptr, ptr %30, i64 %44
  store i64 %array_element35, ptr %45, align 4
  %46 = load i64, ptr %buffer_offset15, align 4
  %47 = add i64 %46, 1
  store i64 %47, ptr %buffer_offset15, align 4
  br label %next26

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
next26:                                           ; preds = %body25
  %index36 = load i64, ptr %index_ptr23, align 4
  %48 = add i64 %index36, 1
  store i64 %48, ptr %index_ptr23, align 4
  br label %cond24
<<<<<<< HEAD
=======
body28:                                           ; preds = %cond26
  %vector_length30 = load i64, ptr %24, align 4
  %38 = sub i64 %vector_length30, 1
  %39 = sub i64 %38, %index18
  call void @builtin_range_check(i64 %39)
  %vector_data31 = getelementptr i64, ptr %24, i64 1
  %index_access32 = getelementptr ptr, ptr %vector_data31, i64 %index18
  %40 = sub i64 2, %index25
  call void @builtin_range_check(i64 %40)
  %index_access33 = getelementptr [3 x i64], ptr %index_access32, i64 0, i64 %index25
  %41 = load i64, ptr %buffer_offset15, align 4
  %42 = getelementptr ptr, ptr %28, i64 %41
  store ptr %index_access33, ptr %42, align 8
  %43 = load i64, ptr %buffer_offset15, align 4
  %44 = add i64 %43, 1
  store i64 %44, ptr %buffer_offset15, align 4
  br label %next27
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)

end_for27:                                        ; preds = %cond24
  br label %next20

func_2_dispatch:                                  ; preds = %entry
  %49 = getelementptr ptr, ptr %2, i64 0
  %50 = getelementptr ptr, ptr %49, i64 6
  %51 = load i64, ptr %50, align 4
  %52 = getelementptr ptr, ptr %50, i64 1
  %53 = load i64, ptr %52, align 4
  %54 = call i64 @getElement(ptr %49, i64 %51, i64 %53)
  %55 = call ptr @heap_malloc(i64 2)
  store i64 %54, ptr %55, align 4
  %56 = getelementptr ptr, ptr %55, i64 1
  store i64 1, ptr %56, align 4
  call void @set_tape_data(ptr %55, i64 2)
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
