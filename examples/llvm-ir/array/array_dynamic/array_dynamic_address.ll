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
  %index_ptr114 = alloca i64, align 8
  %index_ptr105 = alloca i64, align 8
  %buffer_offset104 = alloca i64, align 8
  %index_ptr87 = alloca i64, align 8
  %index_ptr78 = alloca i64, align 8
  %array_size77 = alloca i64, align 8
  %index_ptr61 = alloca i64, align 8
  %index_ptr53 = alloca i64, align 8
  %array_ptr52 = alloca ptr, align 8
  %array_offset51 = alloca i64, align 8
  %index_ptr39 = alloca i64, align 8
  %index_ptr32 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr19 = alloca i64, align 8
  %index_ptr12 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 4205487845, label %func_0_dispatch
    i64 781825070, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset, align 4
  %4 = load i64, ptr %array_offset, align 4
  %array_length = load i64, ptr %3, align 4
  %5 = add i64 %4, 1
  store i64 %5, ptr %array_offset, align 4
  %6 = call ptr @vector_new(i64 %array_length)
  store ptr %6, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %vector_length = load i64, ptr %array_ptr, align 4
  %7 = icmp ult i64 %index, %vector_length
  br i1 %7, label %body, label %end_for

next:                                             ; preds = %end_for6
  %index10 = load i64, ptr %index_ptr, align 4
  %8 = add i64 %index10, 1
  store i64 %8, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %9 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr1, align 4
  %index2 = load i64, ptr %index_ptr1, align 4
  br label %cond3

end_for:                                          ; preds = %cond
  %10 = load ptr, ptr %array_ptr, align 8
  %11 = load i64, ptr %array_offset, align 4
  %12 = call ptr @address_outer_dynamic(ptr %10)
  store i64 0, ptr %array_size, align 4
  %vector_length11 = load i64, ptr %12, align 4
  %13 = load i64, ptr %array_size, align 4
  %14 = add i64 %13, %vector_length11
  store i64 %14, ptr %array_size, align 4
  store i64 0, ptr %index_ptr12, align 4
  %index13 = load i64, ptr %index_ptr12, align 4
  br label %cond14

cond3:                                            ; preds = %next4, %body
  %15 = icmp ult i64 %index2, 2
  br i1 %15, label %body5, label %end_for6

next4:                                            ; preds = %body5
  %index9 = load i64, ptr %index_ptr1, align 4
  %16 = add i64 %index9, 1
  store i64 %16, ptr %index_ptr1, align 4
  br label %cond3

body5:                                            ; preds = %cond3
  %17 = load ptr, ptr %array_ptr, align 8
  %vector_length7 = load i64, ptr %17, align 4
  %18 = sub i64 %vector_length7, 1
  %19 = sub i64 %18, %index
  call void @builtin_range_check(i64 %19)
  %vector_data = getelementptr i64, ptr %17, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %20 = sub i64 1, %index2
  call void @builtin_range_check(i64 %20)
  %index_access8 = getelementptr [2 x ptr], ptr %index_access, i64 0, i64 %index2
  store ptr %3, ptr %index_access8, align 8
  %21 = add i64 4, %9
  store i64 %21, ptr %array_offset, align 4
  br label %next4

end_for6:                                         ; preds = %cond3
  br label %next

cond14:                                           ; preds = %next15, %end_for
  %vector_length18 = load i64, ptr %12, align 4
  %22 = icmp ult i64 %index13, %vector_length18
  br i1 %22, label %body16, label %end_for17

next15:                                           ; preds = %end_for24
  %index30 = load i64, ptr %index_ptr12, align 4
  %23 = add i64 %index30, 1
  store i64 %23, ptr %index_ptr12, align 4
  br label %cond14

body16:                                           ; preds = %cond14
  store i64 0, ptr %index_ptr19, align 4
  %index20 = load i64, ptr %index_ptr19, align 4
  br label %cond21

end_for17:                                        ; preds = %cond14
  %24 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %24, 1
  %25 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %26 = load i64, ptr %buffer_offset, align 4
  %27 = add i64 %26, 1
  store i64 %27, ptr %buffer_offset, align 4
  %28 = getelementptr ptr, ptr %25, i64 %26
  %vector_length31 = load i64, ptr %12, align 4
  store i64 %vector_length31, ptr %28, align 4
  store i64 0, ptr %index_ptr32, align 4
  %index33 = load i64, ptr %index_ptr32, align 4
  br label %cond34

cond21:                                           ; preds = %next22, %body16
  %29 = icmp ult i64 %index20, 2
  br i1 %29, label %body23, label %end_for24

next22:                                           ; preds = %body23
  %index29 = load i64, ptr %index_ptr19, align 4
  %30 = add i64 %index29, 1
  store i64 %30, ptr %index_ptr19, align 4
  br label %cond21

body23:                                           ; preds = %cond21
  %vector_length25 = load i64, ptr %12, align 4
  %31 = sub i64 %vector_length25, 1
  %32 = sub i64 %31, %index13
  call void @builtin_range_check(i64 %32)
  %vector_data26 = getelementptr i64, ptr %12, i64 1
  %index_access27 = getelementptr ptr, ptr %vector_data26, i64 %index13
  %33 = sub i64 1, %index20
  call void @builtin_range_check(i64 %33)
  %index_access28 = getelementptr [2 x ptr], ptr %index_access27, i64 0, i64 %index20
  %34 = load i64, ptr %array_size, align 4
  %35 = add i64 %34, 4
  store i64 %35, ptr %array_size, align 4
  br label %next22

end_for24:                                        ; preds = %cond21
  br label %next15

cond34:                                           ; preds = %next35, %end_for17
  %vector_length38 = load i64, ptr %12, align 4
  %36 = icmp ult i64 %index33, %vector_length38
  br i1 %36, label %body36, label %end_for37

next35:                                           ; preds = %end_for44
  %index50 = load i64, ptr %index_ptr32, align 4
  %37 = add i64 %index50, 1
  store i64 %37, ptr %index_ptr32, align 4
  br label %cond34

body36:                                           ; preds = %cond34
  store i64 0, ptr %index_ptr39, align 4
  %index40 = load i64, ptr %index_ptr39, align 4
  br label %cond41

end_for37:                                        ; preds = %cond34
  %38 = load i64, ptr %buffer_offset, align 4
  %39 = getelementptr ptr, ptr %25, i64 %38
  store i64 %24, ptr %39, align 4
  call void @set_tape_data(ptr %25, i64 %heap_size)
  ret void

cond41:                                           ; preds = %next42, %body36
  %40 = icmp ult i64 %index40, 2
  br i1 %40, label %body43, label %end_for44

next42:                                           ; preds = %body43
  %index49 = load i64, ptr %index_ptr39, align 4
  %41 = add i64 %index49, 1
  store i64 %41, ptr %index_ptr39, align 4
  br label %cond41

body43:                                           ; preds = %cond41
  %vector_length45 = load i64, ptr %12, align 4
  %42 = sub i64 %vector_length45, 1
  %43 = sub i64 %42, %index33
  call void @builtin_range_check(i64 %43)
  %vector_data46 = getelementptr i64, ptr %12, i64 1
  %index_access47 = getelementptr ptr, ptr %vector_data46, i64 %index33
  %44 = sub i64 1, %index40
  call void @builtin_range_check(i64 %44)
  %index_access48 = getelementptr [2 x ptr], ptr %index_access47, i64 0, i64 %index40
  %45 = load i64, ptr %buffer_offset, align 4
  %46 = getelementptr ptr, ptr %25, i64 %45
  %47 = getelementptr i64, ptr %index_access48, i64 0
  %48 = load i64, ptr %47, align 4
  %49 = getelementptr i64, ptr %46, i64 0
  store i64 %48, ptr %49, align 4
  %50 = getelementptr i64, ptr %index_access48, i64 1
  %51 = load i64, ptr %50, align 4
  %52 = getelementptr i64, ptr %46, i64 1
  store i64 %51, ptr %52, align 4
  %53 = getelementptr i64, ptr %index_access48, i64 2
  %54 = load i64, ptr %53, align 4
  %55 = getelementptr i64, ptr %46, i64 2
  store i64 %54, ptr %55, align 4
  %56 = getelementptr i64, ptr %index_access48, i64 3
  %57 = load i64, ptr %56, align 4
  %58 = getelementptr i64, ptr %46, i64 3
  store i64 %57, ptr %58, align 4
  %59 = load i64, ptr %buffer_offset, align 4
  %60 = add i64 %59, 4
  store i64 %60, ptr %buffer_offset, align 4
  br label %next42

end_for44:                                        ; preds = %cond41
  br label %next35

func_1_dispatch:                                  ; preds = %entry
  %61 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset51, align 4
  %62 = call ptr @heap_malloc(i64 0)
  store ptr %62, ptr %array_ptr52, align 8
  %63 = load i64, ptr %array_offset51, align 4
  store i64 0, ptr %index_ptr53, align 4
  %index54 = load i64, ptr %index_ptr53, align 4
  br label %cond55

cond55:                                           ; preds = %next56, %func_1_dispatch
  %64 = icmp ult i64 %index54, 2
  br i1 %64, label %body57, label %end_for58

next56:                                           ; preds = %end_for66
  %index76 = load i64, ptr %index_ptr53, align 4
  %65 = add i64 %index76, 1
  store i64 %65, ptr %index_ptr53, align 4
  br label %cond55

body57:                                           ; preds = %cond55
  %66 = load i64, ptr %array_offset51, align 4
  %array_length59 = load i64, ptr %61, align 4
  %67 = add i64 %66, 1
  store i64 %67, ptr %array_offset51, align 4
  %68 = call ptr @vector_new(i64 %array_length59)
  %69 = load ptr, ptr %array_ptr52, align 8
  %70 = sub i64 1, %index54
  call void @builtin_range_check(i64 %70)
  %index_access60 = getelementptr [2 x ptr], ptr %69, i64 0, i64 %index54
  %arr = load ptr, ptr %index_access60, align 8
  store ptr %68, ptr %arr, align 8
  store i64 0, ptr %index_ptr61, align 4
  %index62 = load i64, ptr %index_ptr61, align 4
  br label %cond63

end_for58:                                        ; preds = %cond55
  %71 = load ptr, ptr %array_ptr52, align 8
  %72 = load i64, ptr %array_offset51, align 4
  %73 = call ptr @address_inner_dynamic(ptr %71)
  store i64 0, ptr %array_size77, align 4
  store i64 0, ptr %index_ptr78, align 4
  %index79 = load i64, ptr %index_ptr78, align 4
  br label %cond80

cond63:                                           ; preds = %next64, %body57
  %74 = sub i64 1, %index54
  call void @builtin_range_check(i64 %74)
  %index_access67 = getelementptr [2 x ptr], ptr %array_ptr52, i64 0, i64 %index54
  %arr68 = load ptr, ptr %index_access67, align 8
  %vector_length69 = load i64, ptr %arr68, align 4
  %75 = icmp ult i64 %index62, %vector_length69
  br i1 %75, label %body65, label %end_for66

next64:                                           ; preds = %body65
  %index75 = load i64, ptr %index_ptr61, align 4
  %76 = add i64 %index75, 1
  store i64 %76, ptr %index_ptr61, align 4
  br label %cond63

body65:                                           ; preds = %cond63
  %77 = load ptr, ptr %array_ptr52, align 8
  %78 = sub i64 1, %index54
  call void @builtin_range_check(i64 %78)
  %index_access70 = getelementptr [2 x ptr], ptr %77, i64 0, i64 %index54
  %arr71 = load ptr, ptr %index_access70, align 8
  %vector_length72 = load i64, ptr %arr71, align 4
  %79 = sub i64 %vector_length72, 1
  %80 = sub i64 %79, %index62
  call void @builtin_range_check(i64 %80)
  %vector_data73 = getelementptr i64, ptr %arr71, i64 1
  %index_access74 = getelementptr ptr, ptr %vector_data73, i64 %index62
  store ptr %61, ptr %index_access74, align 8
  %81 = add i64 4, %66
  store i64 %81, ptr %array_offset51, align 4
  br label %next64

end_for66:                                        ; preds = %cond63
  br label %next56

cond80:                                           ; preds = %next81, %end_for58
  %82 = icmp ult i64 %index79, 2
  br i1 %82, label %body82, label %end_for83

next81:                                           ; preds = %end_for92
  %index102 = load i64, ptr %index_ptr78, align 4
  %83 = add i64 %index102, 1
  store i64 %83, ptr %index_ptr78, align 4
  br label %cond80

body82:                                           ; preds = %cond80
  %84 = sub i64 1, %index79
  call void @builtin_range_check(i64 %84)
  %index_access84 = getelementptr [2 x ptr], ptr %73, i64 0, i64 %index79
  %arr85 = load ptr, ptr %index_access84, align 8
  %vector_length86 = load i64, ptr %arr85, align 4
  %85 = load i64, ptr %array_size77, align 4
  %86 = add i64 %85, %vector_length86
  store i64 %86, ptr %array_size77, align 4
  store i64 0, ptr %index_ptr87, align 4
  %index88 = load i64, ptr %index_ptr87, align 4
  br label %cond89

end_for83:                                        ; preds = %cond80
  %87 = load i64, ptr %array_size77, align 4
  %heap_size103 = add i64 %87, 1
  %88 = call ptr @heap_malloc(i64 %heap_size103)
  store i64 0, ptr %buffer_offset104, align 4
  store i64 0, ptr %index_ptr105, align 4
  %index106 = load i64, ptr %index_ptr105, align 4
  br label %cond107

cond89:                                           ; preds = %next90, %body82
  %89 = sub i64 1, %index79
  call void @builtin_range_check(i64 %89)
  %index_access93 = getelementptr [2 x ptr], ptr %73, i64 0, i64 %index79
  %arr94 = load ptr, ptr %index_access93, align 8
  %vector_length95 = load i64, ptr %arr94, align 4
  %90 = icmp ult i64 %index88, %vector_length95
  br i1 %90, label %body91, label %end_for92

next90:                                           ; preds = %body91
  %index101 = load i64, ptr %index_ptr87, align 4
  %91 = add i64 %index101, 1
  store i64 %91, ptr %index_ptr87, align 4
  br label %cond89

body91:                                           ; preds = %cond89
  %92 = sub i64 1, %index79
  call void @builtin_range_check(i64 %92)
  %index_access96 = getelementptr [2 x ptr], ptr %73, i64 0, i64 %index79
  %arr97 = load ptr, ptr %index_access96, align 8
  %vector_length98 = load i64, ptr %arr97, align 4
  %93 = sub i64 %vector_length98, 1
  %94 = sub i64 %93, %index88
  call void @builtin_range_check(i64 %94)
  %vector_data99 = getelementptr i64, ptr %arr97, i64 1
  %index_access100 = getelementptr ptr, ptr %vector_data99, i64 %index88
  %95 = load i64, ptr %array_size77, align 4
  %96 = add i64 %95, 4
  store i64 %96, ptr %array_size77, align 4
  br label %next90

end_for92:                                        ; preds = %cond89
  br label %next81

cond107:                                          ; preds = %next108, %end_for83
  %97 = icmp ult i64 %index106, 2
  br i1 %97, label %body109, label %end_for110

next108:                                          ; preds = %end_for119
  %index133 = load i64, ptr %index_ptr105, align 4
  %98 = add i64 %index133, 1
  store i64 %98, ptr %index_ptr105, align 4
  br label %cond107

body109:                                          ; preds = %cond107
  %99 = sub i64 1, %index106
  call void @builtin_range_check(i64 %99)
  %index_access111 = getelementptr [2 x ptr], ptr %73, i64 0, i64 %index106
  %arr112 = load ptr, ptr %index_access111, align 8
  %100 = load i64, ptr %buffer_offset104, align 4
  %101 = add i64 %100, 1
  store i64 %101, ptr %buffer_offset104, align 4
  %102 = getelementptr ptr, ptr %88, i64 %100
  %vector_length113 = load i64, ptr %arr112, align 4
  store i64 %vector_length113, ptr %102, align 4
  store i64 0, ptr %index_ptr114, align 4
  %index115 = load i64, ptr %index_ptr114, align 4
  br label %cond116

end_for110:                                       ; preds = %cond107
  %103 = load i64, ptr %buffer_offset104, align 4
  %104 = getelementptr ptr, ptr %88, i64 %103
  store i64 %87, ptr %104, align 4
  call void @set_tape_data(ptr %88, i64 %heap_size103)
  ret void

cond116:                                          ; preds = %next117, %body109
  %vector_length120 = load i64, ptr %73, align 4
  %105 = sub i64 %vector_length120, 1
  %106 = sub i64 %105, %index106
  call void @builtin_range_check(i64 %106)
  %vector_data121 = getelementptr i64, ptr %73, i64 1
  %index_access122 = getelementptr ptr, ptr %vector_data121, i64 %index106
  %arr123 = load ptr, ptr %index_access122, align 8
  %vector_length124 = load i64, ptr %arr123, align 4
  %107 = icmp ult i64 %index115, %vector_length124
  br i1 %107, label %body118, label %end_for119

next117:                                          ; preds = %body118
  %index132 = load i64, ptr %index_ptr114, align 4
  %108 = add i64 %index132, 1
  store i64 %108, ptr %index_ptr114, align 4
  br label %cond116

body118:                                          ; preds = %cond116
  %vector_length125 = load i64, ptr %73, align 4
  %109 = sub i64 %vector_length125, 1
  %110 = sub i64 %109, %index106
  call void @builtin_range_check(i64 %110)
  %vector_data126 = getelementptr i64, ptr %73, i64 1
  %index_access127 = getelementptr ptr, ptr %vector_data126, i64 %index106
  %arr128 = load ptr, ptr %index_access127, align 8
  %vector_length129 = load i64, ptr %arr128, align 4
  %111 = sub i64 %vector_length129, 1
  %112 = sub i64 %111, %index115
  call void @builtin_range_check(i64 %112)
  %vector_data130 = getelementptr i64, ptr %arr128, i64 1
  %index_access131 = getelementptr ptr, ptr %vector_data130, i64 %index115
  %113 = load i64, ptr %buffer_offset104, align 4
  %114 = getelementptr ptr, ptr %88, i64 %113
  %115 = getelementptr i64, ptr %index_access131, i64 0
  %116 = load i64, ptr %115, align 4
  %117 = getelementptr i64, ptr %114, i64 0
  store i64 %116, ptr %117, align 4
  %118 = getelementptr i64, ptr %index_access131, i64 1
  %119 = load i64, ptr %118, align 4
  %120 = getelementptr i64, ptr %114, i64 1
  store i64 %119, ptr %120, align 4
  %121 = getelementptr i64, ptr %index_access131, i64 2
  %122 = load i64, ptr %121, align 4
  %123 = getelementptr i64, ptr %114, i64 2
  store i64 %122, ptr %123, align 4
  %124 = getelementptr i64, ptr %index_access131, i64 3
  %125 = load i64, ptr %124, align 4
  %126 = getelementptr i64, ptr %114, i64 3
  store i64 %125, ptr %126, align 4
  %127 = load i64, ptr %buffer_offset104, align 4
  %128 = add i64 %127, 4
  store i64 %128, ptr %buffer_offset104, align 4
  br label %next117

end_for119:                                       ; preds = %cond116
  br label %next108
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
