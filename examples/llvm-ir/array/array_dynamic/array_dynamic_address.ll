; ModuleID = 'DynamicTwoDimensionalArrayInMemory'
source_filename = "array_dynamic_address"

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

define ptr @address_outer_dynamic(ptr %0) {
entry:
  %a = alloca ptr, align 8
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  ret ptr %1
}

define ptr @address_inner_dynamic(ptr %0) {
entry:
  %a = alloca ptr, align 8
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  ret ptr %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr120 = alloca i64, align 8
  %index_ptr111 = alloca i64, align 8
  %buffer_offset110 = alloca i64, align 8
  %index_ptr90 = alloca i64, align 8
  %index_ptr85 = alloca i64, align 8
  %array_size84 = alloca i64, align 8
  %index_ptr65 = alloca i64, align 8
  %index_ptr56 = alloca i64, align 8
  %array_ptr55 = alloca ptr, align 8
  %offset_var54 = alloca i64, align 8
  %index_ptr39 = alloca i64, align 8
  %index_ptr33 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr17 = alloca i64, align 8
  %index_ptr11 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 4205487845, label %func_0_dispatch
    i64 781825070, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var, align 4
  %4 = load i64, ptr %offset_var, align 4
  %array_length = getelementptr ptr, ptr %3, i64 %4
  %5 = load i64, ptr %array_length, align 4
  %6 = add i64 %4, 1
  store i64 %6, ptr %offset_var, align 4
  %7 = call ptr @vector_new(i64 %5)
  store ptr %7, ptr %array_ptr, align 8
  %8 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %vector_length = load i64, ptr %8, align 4
  %9 = load i64, ptr %index_ptr, align 4
  %10 = icmp ult i64 %9, %vector_length
  br i1 %10, label %body, label %end_for

body:                                             ; preds = %cond
  %11 = load i64, ptr %offset_var, align 4
  %12 = getelementptr ptr, ptr %3, i64 %11
  %13 = load i64, ptr %offset_var, align 4
  %14 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

next:                                             ; preds = %end_for5
  %index10 = load i64, ptr %index_ptr, align 4
  %15 = add i64 %index10, 1
  store i64 %15, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %16 = load ptr, ptr %array_ptr, align 8
  %17 = load i64, ptr %offset_var, align 4
  %18 = call ptr @address_outer_dynamic(ptr %16)
  store i64 0, ptr %array_size, align 4
  %19 = load i64, ptr %array_size, align 4
  %20 = add i64 %19, 1
  store i64 %20, ptr %array_size, align 4
  store i64 0, ptr %index_ptr11, align 4
  br label %cond12

cond2:                                            ; preds = %next4, %body
  %21 = load i64, ptr %index_ptr1, align 4
  %22 = icmp ult i64 %21, 2
  br i1 %22, label %body3, label %end_for5

body3:                                            ; preds = %cond2
  %23 = load i64, ptr %offset_var, align 4
  %24 = getelementptr ptr, ptr %12, i64 %23
  %25 = load ptr, ptr %array_ptr, align 8
  %array_index = load i64, ptr %index_ptr, align 4
  %vector_length6 = load i64, ptr %25, align 4
  %26 = sub i64 %vector_length6, 1
  %27 = sub i64 %26, %array_index
  call void @builtin_range_check(i64 %27)
  %vector_data = getelementptr i64, ptr %25, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %array_index7 = load i64, ptr %index_ptr1, align 4
  %28 = sub i64 1, %array_index7
  call void @builtin_range_check(i64 %28)
  %index_access8 = getelementptr [2 x ptr], ptr %array_element, i64 0, i64 %array_index7
  %array_element9 = load ptr, ptr %index_access8, align 8
  store ptr %24, ptr %index_access8, align 8
  %29 = add i64 4, %23
  store i64 %29, ptr %offset_var, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index = load i64, ptr %index_ptr1, align 4
  %30 = add i64 %index, 1
  store i64 %30, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  br label %next

cond12:                                           ; preds = %next14, %end_for
  %vector_length16 = load i64, ptr %18, align 4
  %31 = load i64, ptr %index_ptr11, align 4
  %32 = icmp ult i64 %31, %vector_length16
  br i1 %32, label %body13, label %end_for15

body13:                                           ; preds = %cond12
  store i64 0, ptr %index_ptr17, align 4
  br label %cond18

next14:                                           ; preds = %end_for21
  %index31 = load i64, ptr %index_ptr11, align 4
  %33 = add i64 %index31, 1
  store i64 %33, ptr %index_ptr11, align 4
  br label %cond12

end_for15:                                        ; preds = %cond12
  %34 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %34, 1
  %35 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %36 = load i64, ptr %buffer_offset, align 4
  %37 = add i64 %36, 1
  store i64 %37, ptr %buffer_offset, align 4
  %38 = getelementptr ptr, ptr %35, i64 %36
  %vector_length32 = load i64, ptr %18, align 4
  store i64 %vector_length32, ptr %38, align 4
  store i64 0, ptr %index_ptr33, align 4
  br label %cond34

cond18:                                           ; preds = %next20, %body13
  %39 = load i64, ptr %index_ptr17, align 4
  %40 = icmp ult i64 %39, 2
  br i1 %40, label %body19, label %end_for21

body19:                                           ; preds = %cond18
  %array_index22 = load i64, ptr %index_ptr11, align 4
  %vector_length23 = load i64, ptr %18, align 4
  %41 = sub i64 %vector_length23, 1
  %42 = sub i64 %41, %array_index22
  call void @builtin_range_check(i64 %42)
  %vector_data24 = getelementptr i64, ptr %18, i64 1
  %index_access25 = getelementptr ptr, ptr %vector_data24, i64 %array_index22
  %array_element26 = load ptr, ptr %index_access25, align 8
  %array_index27 = load i64, ptr %index_ptr17, align 4
  %43 = sub i64 1, %array_index27
  call void @builtin_range_check(i64 %43)
  %index_access28 = getelementptr [2 x ptr], ptr %array_element26, i64 0, i64 %array_index27
  %array_element29 = load ptr, ptr %index_access28, align 8
  %44 = load i64, ptr %array_size, align 4
  %45 = add i64 %44, 4
  store i64 %45, ptr %array_size, align 4
  br label %next20

next20:                                           ; preds = %body19
  %index30 = load i64, ptr %index_ptr17, align 4
  %46 = add i64 %index30, 1
  store i64 %46, ptr %index_ptr17, align 4
  br label %cond18

end_for21:                                        ; preds = %cond18
  br label %next14

cond34:                                           ; preds = %next36, %end_for15
  %vector_length38 = load i64, ptr %18, align 4
  %47 = load i64, ptr %index_ptr33, align 4
  %48 = icmp ult i64 %47, %vector_length38
  br i1 %48, label %body35, label %end_for37

body35:                                           ; preds = %cond34
  store i64 0, ptr %index_ptr39, align 4
  br label %cond40

next36:                                           ; preds = %end_for43
  %index53 = load i64, ptr %index_ptr33, align 4
  %49 = add i64 %index53, 1
  store i64 %49, ptr %index_ptr33, align 4
  br label %cond34

end_for37:                                        ; preds = %cond34
  %50 = load i64, ptr %buffer_offset, align 4
  %51 = getelementptr ptr, ptr %35, i64 %50
  store i64 %34, ptr %51, align 4
  call void @set_tape_data(ptr %35, i64 %heap_size)
  ret void

cond40:                                           ; preds = %next42, %body35
  %52 = load i64, ptr %index_ptr39, align 4
  %53 = icmp ult i64 %52, 2
  br i1 %53, label %body41, label %end_for43

body41:                                           ; preds = %cond40
  %array_index44 = load i64, ptr %index_ptr33, align 4
  %vector_length45 = load i64, ptr %18, align 4
  %54 = sub i64 %vector_length45, 1
  %55 = sub i64 %54, %array_index44
  call void @builtin_range_check(i64 %55)
  %vector_data46 = getelementptr i64, ptr %18, i64 1
  %index_access47 = getelementptr ptr, ptr %vector_data46, i64 %array_index44
  %array_element48 = load ptr, ptr %index_access47, align 8
  %array_index49 = load i64, ptr %index_ptr39, align 4
  %56 = sub i64 1, %array_index49
  call void @builtin_range_check(i64 %56)
  %index_access50 = getelementptr [2 x ptr], ptr %array_element48, i64 0, i64 %array_index49
  %array_element51 = load ptr, ptr %index_access50, align 8
  %57 = load i64, ptr %buffer_offset, align 4
  %58 = getelementptr ptr, ptr %35, i64 %57
  %59 = getelementptr i64, ptr %array_element51, i64 0
  %60 = load i64, ptr %59, align 4
  %61 = getelementptr i64, ptr %58, i64 0
  store i64 %60, ptr %61, align 4
  %62 = getelementptr i64, ptr %array_element51, i64 1
  %63 = load i64, ptr %62, align 4
  %64 = getelementptr i64, ptr %58, i64 1
  store i64 %63, ptr %64, align 4
  %65 = getelementptr i64, ptr %array_element51, i64 2
  %66 = load i64, ptr %65, align 4
  %67 = getelementptr i64, ptr %58, i64 2
  store i64 %66, ptr %67, align 4
  %68 = getelementptr i64, ptr %array_element51, i64 3
  %69 = load i64, ptr %68, align 4
  %70 = getelementptr i64, ptr %58, i64 3
  store i64 %69, ptr %70, align 4
  %71 = load i64, ptr %buffer_offset, align 4
  %72 = add i64 %71, 4
  store i64 %72, ptr %buffer_offset, align 4
  br label %next42

next42:                                           ; preds = %body41
  %index52 = load i64, ptr %index_ptr39, align 4
  %73 = add i64 %index52, 1
  store i64 %73, ptr %index_ptr39, align 4
  br label %cond40

end_for43:                                        ; preds = %cond40
  br label %next36

func_1_dispatch:                                  ; preds = %entry
  %74 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var54, align 4
  %75 = load i64, ptr %offset_var54, align 4
  %76 = load ptr, ptr %array_ptr55, align 8
  store i64 0, ptr %index_ptr56, align 4
  br label %cond57

cond57:                                           ; preds = %next59, %func_1_dispatch
  %77 = load i64, ptr %index_ptr56, align 4
  %78 = icmp ult i64 %77, 2
  br i1 %78, label %body58, label %end_for60

body58:                                           ; preds = %cond57
  %79 = load i64, ptr %offset_var54, align 4
  %80 = getelementptr ptr, ptr %74, i64 %79
  %81 = load i64, ptr %offset_var54, align 4
  %array_length61 = getelementptr ptr, ptr %80, i64 %81
  %82 = load i64, ptr %array_length61, align 4
  %83 = add i64 %81, 1
  store i64 %83, ptr %offset_var54, align 4
  %84 = call ptr @vector_new(i64 %82)
  %load_array = load ptr, ptr %array_ptr55, align 8
  %array_index62 = load i64, ptr %index_ptr56, align 4
  %85 = sub i64 1, %array_index62
  call void @builtin_range_check(i64 %85)
  %index_access63 = getelementptr [2 x ptr], ptr %load_array, i64 0, i64 %array_index62
  %array_element64 = load ptr, ptr %index_access63, align 8
  store ptr %84, ptr %index_access63, align 8
  %86 = load ptr, ptr %array_ptr55, align 8
  store i64 0, ptr %index_ptr65, align 4
  br label %cond66

next59:                                           ; preds = %end_for69
  %index83 = load i64, ptr %index_ptr56, align 4
  %87 = add i64 %index83, 1
  store i64 %87, ptr %index_ptr56, align 4
  br label %cond57

end_for60:                                        ; preds = %cond57
  %88 = load ptr, ptr %array_ptr55, align 8
  %89 = load i64, ptr %offset_var54, align 4
  %90 = call ptr @address_inner_dynamic(ptr %88)
  store i64 0, ptr %array_size84, align 4
  store i64 0, ptr %index_ptr85, align 4
  br label %cond86

cond66:                                           ; preds = %next68, %body58
  %array_index70 = load i64, ptr %index_ptr56, align 4
  %91 = sub i64 1, %array_index70
  call void @builtin_range_check(i64 %91)
  %index_access71 = getelementptr [2 x ptr], ptr %86, i64 0, i64 %array_index70
  %array_element72 = load ptr, ptr %index_access71, align 8
  %vector_length73 = load i64, ptr %array_element72, align 4
  %92 = load i64, ptr %index_ptr65, align 4
  %93 = icmp ult i64 %92, %vector_length73
  br i1 %93, label %body67, label %end_for69

body67:                                           ; preds = %cond66
  %94 = load i64, ptr %offset_var54, align 4
  %95 = getelementptr ptr, ptr %80, i64 %94
  %96 = load ptr, ptr %array_ptr55, align 8
  %array_index74 = load i64, ptr %index_ptr56, align 4
  %97 = sub i64 1, %array_index74
  call void @builtin_range_check(i64 %97)
  %index_access75 = getelementptr [2 x ptr], ptr %96, i64 0, i64 %array_index74
  %array_element76 = load ptr, ptr %index_access75, align 8
  %array_index77 = load i64, ptr %index_ptr65, align 4
  %vector_length78 = load i64, ptr %array_element76, align 4
  %98 = sub i64 %vector_length78, 1
  %99 = sub i64 %98, %array_index77
  call void @builtin_range_check(i64 %99)
  %vector_data79 = getelementptr i64, ptr %array_element76, i64 1
  %index_access80 = getelementptr ptr, ptr %vector_data79, i64 %array_index77
  %array_element81 = load ptr, ptr %index_access80, align 8
  store ptr %95, ptr %index_access80, align 8
  %100 = add i64 4, %94
  store i64 %100, ptr %offset_var54, align 4
  br label %next68

next68:                                           ; preds = %body67
  %index82 = load i64, ptr %index_ptr65, align 4
  %101 = add i64 %index82, 1
  store i64 %101, ptr %index_ptr65, align 4
  br label %cond66

end_for69:                                        ; preds = %cond66
  br label %next59

cond86:                                           ; preds = %next88, %end_for60
  %102 = load i64, ptr %index_ptr85, align 4
  %103 = icmp ult i64 %102, 2
  br i1 %103, label %body87, label %end_for89

body87:                                           ; preds = %cond86
  %104 = load i64, ptr %array_size84, align 4
  %105 = add i64 %104, 1
  store i64 %105, ptr %array_size84, align 4
  store i64 0, ptr %index_ptr90, align 4
  br label %cond91

next88:                                           ; preds = %end_for94
  %index108 = load i64, ptr %index_ptr85, align 4
  %106 = add i64 %index108, 1
  store i64 %106, ptr %index_ptr85, align 4
  br label %cond86

end_for89:                                        ; preds = %cond86
  %107 = load i64, ptr %array_size84, align 4
  %heap_size109 = add i64 %107, 1
  %108 = call ptr @heap_malloc(i64 %heap_size109)
  store i64 0, ptr %buffer_offset110, align 4
  store i64 0, ptr %index_ptr111, align 4
  br label %cond112

cond91:                                           ; preds = %next93, %body87
  %array_index95 = load i64, ptr %index_ptr85, align 4
  %109 = sub i64 1, %array_index95
  call void @builtin_range_check(i64 %109)
  %index_access96 = getelementptr [2 x ptr], ptr %90, i64 0, i64 %array_index95
  %array_element97 = load ptr, ptr %index_access96, align 8
  %vector_length98 = load i64, ptr %array_element97, align 4
  %110 = load i64, ptr %index_ptr90, align 4
  %111 = icmp ult i64 %110, %vector_length98
  br i1 %111, label %body92, label %end_for94

body92:                                           ; preds = %cond91
  %array_index99 = load i64, ptr %index_ptr85, align 4
  %112 = sub i64 1, %array_index99
  call void @builtin_range_check(i64 %112)
  %index_access100 = getelementptr [2 x ptr], ptr %90, i64 0, i64 %array_index99
  %array_element101 = load ptr, ptr %index_access100, align 8
  %array_index102 = load i64, ptr %index_ptr90, align 4
  %vector_length103 = load i64, ptr %array_element101, align 4
  %113 = sub i64 %vector_length103, 1
  %114 = sub i64 %113, %array_index102
  call void @builtin_range_check(i64 %114)
  %vector_data104 = getelementptr i64, ptr %array_element101, i64 1
  %index_access105 = getelementptr ptr, ptr %vector_data104, i64 %array_index102
  %array_element106 = load ptr, ptr %index_access105, align 8
  %115 = load i64, ptr %array_size84, align 4
  %116 = add i64 %115, 4
  store i64 %116, ptr %array_size84, align 4
  br label %next93

next93:                                           ; preds = %body92
  %index107 = load i64, ptr %index_ptr90, align 4
  %117 = add i64 %index107, 1
  store i64 %117, ptr %index_ptr90, align 4
  br label %cond91

end_for94:                                        ; preds = %cond91
  br label %next88

cond112:                                          ; preds = %next114, %end_for89
  %118 = load i64, ptr %index_ptr111, align 4
  %119 = icmp ult i64 %118, 2
  br i1 %119, label %body113, label %end_for115

body113:                                          ; preds = %cond112
  %array_index116 = load i64, ptr %index_ptr111, align 4
  %120 = sub i64 1, %array_index116
  call void @builtin_range_check(i64 %120)
  %index_access117 = getelementptr [2 x ptr], ptr %90, i64 0, i64 %array_index116
  %array_element118 = load ptr, ptr %index_access117, align 8
  %121 = load i64, ptr %buffer_offset110, align 4
  %122 = add i64 %121, 1
  store i64 %122, ptr %buffer_offset110, align 4
  %123 = getelementptr ptr, ptr %108, i64 %121
  %vector_length119 = load i64, ptr %array_element118, align 4
  store i64 %vector_length119, ptr %123, align 4
  store i64 0, ptr %index_ptr120, align 4
  br label %cond121

next114:                                          ; preds = %end_for124
  %index142 = load i64, ptr %index_ptr111, align 4
  %124 = add i64 %index142, 1
  store i64 %124, ptr %index_ptr111, align 4
  br label %cond112

end_for115:                                       ; preds = %cond112
  %125 = load i64, ptr %buffer_offset110, align 4
  %126 = getelementptr ptr, ptr %108, i64 %125
  store i64 %107, ptr %126, align 4
  call void @set_tape_data(ptr %108, i64 %heap_size109)
  ret void

cond121:                                          ; preds = %next123, %body113
  %array_index125 = load i64, ptr %index_ptr111, align 4
  %vector_length126 = load i64, ptr %90, align 4
  %127 = sub i64 %vector_length126, 1
  %128 = sub i64 %127, %array_index125
  call void @builtin_range_check(i64 %128)
  %vector_data127 = getelementptr i64, ptr %90, i64 1
  %index_access128 = getelementptr ptr, ptr %vector_data127, i64 %array_index125
  %array_element129 = load ptr, ptr %index_access128, align 8
  %vector_length130 = load i64, ptr %array_element129, align 4
  %129 = load i64, ptr %index_ptr120, align 4
  %130 = icmp ult i64 %129, %vector_length130
  br i1 %130, label %body122, label %end_for124

body122:                                          ; preds = %cond121
  %array_index131 = load i64, ptr %index_ptr111, align 4
  %vector_length132 = load i64, ptr %90, align 4
  %131 = sub i64 %vector_length132, 1
  %132 = sub i64 %131, %array_index131
  call void @builtin_range_check(i64 %132)
  %vector_data133 = getelementptr i64, ptr %90, i64 1
  %index_access134 = getelementptr ptr, ptr %vector_data133, i64 %array_index131
  %array_element135 = load ptr, ptr %index_access134, align 8
  %array_index136 = load i64, ptr %index_ptr120, align 4
  %vector_length137 = load i64, ptr %array_element135, align 4
  %133 = sub i64 %vector_length137, 1
  %134 = sub i64 %133, %array_index136
  call void @builtin_range_check(i64 %134)
  %vector_data138 = getelementptr i64, ptr %array_element135, i64 1
  %index_access139 = getelementptr ptr, ptr %vector_data138, i64 %array_index136
  %array_element140 = load ptr, ptr %index_access139, align 8
  %135 = load i64, ptr %buffer_offset110, align 4
  %136 = getelementptr ptr, ptr %108, i64 %135
  %137 = getelementptr i64, ptr %array_element140, i64 0
  %138 = load i64, ptr %137, align 4
  %139 = getelementptr i64, ptr %136, i64 0
  store i64 %138, ptr %139, align 4
  %140 = getelementptr i64, ptr %array_element140, i64 1
  %141 = load i64, ptr %140, align 4
  %142 = getelementptr i64, ptr %136, i64 1
  store i64 %141, ptr %142, align 4
  %143 = getelementptr i64, ptr %array_element140, i64 2
  %144 = load i64, ptr %143, align 4
  %145 = getelementptr i64, ptr %136, i64 2
  store i64 %144, ptr %145, align 4
  %146 = getelementptr i64, ptr %array_element140, i64 3
  %147 = load i64, ptr %146, align 4
  %148 = getelementptr i64, ptr %136, i64 3
  store i64 %147, ptr %148, align 4
  %149 = load i64, ptr %buffer_offset110, align 4
  %150 = add i64 %149, 4
  store i64 %150, ptr %buffer_offset110, align 4
  br label %next123

next123:                                          ; preds = %body122
  %index141 = load i64, ptr %index_ptr120, align 4
  %151 = add i64 %index141, 1
  store i64 %151, ptr %index_ptr120, align 4
  br label %cond121

end_for124:                                       ; preds = %cond121
  br label %next114
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
