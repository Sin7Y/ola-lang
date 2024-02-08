; ModuleID = 'U256StorageContract'
source_filename = "storage_u256"

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

define void @set_value() {
entry:
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 100, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %0, i64 6
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %0, i64 5
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %0, i64 4
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %0, i64 3
  store i64 0, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %0, i64 2
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %0, i64 0
  store i64 0, ptr %index_access7, align 4
  %1 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %0, ptr %1, i64 4)
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %0, i64 4
  call void @memcpy(ptr %3, ptr %2, i64 4)
  %4 = call ptr @heap_malloc(i64 4)
  %5 = getelementptr i64, ptr %4, i64 0
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %4, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %4, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %4, i64 3
  store i64 0, ptr %8, align 4
  call void @set_storage(ptr %4, ptr %1)
  %9 = call ptr @heap_malloc(i64 4)
  %10 = getelementptr i64, ptr %9, i64 0
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %9, i64 3
  store i64 1, ptr %13, align 4
  call void @set_storage(ptr %9, ptr %2)
  ret void
}

define ptr @get_value() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = call ptr @heap_malloc(i64 4)
  %2 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %1, i64 3
  store i64 0, ptr %5, align 4
  call void @get_storage(ptr %1, ptr %0)
  %6 = call ptr @heap_malloc(i64 4)
  %7 = call ptr @heap_malloc(i64 4)
  %8 = getelementptr i64, ptr %7, i64 0
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %7, i64 1
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %7, i64 3
  store i64 1, ptr %11, align 4
  call void @get_storage(ptr %7, ptr %6)
  %12 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %0, ptr %12, i64 4)
  %13 = getelementptr i64, ptr %12, i64 4
  call void @memcpy(ptr %6, ptr %13, i64 4)
  ret ptr %12
}

define void @set_age(ptr %0) {
entry:
  %_age = alloca ptr, align 8
  store ptr %0, ptr %_age, align 8
  %1 = load ptr, ptr %_age, align 8
  %2 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %1, ptr %2, i64 4)
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %1, i64 4
  call void @memcpy(ptr %4, ptr %3, i64 4)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 2, ptr %9, align 4
  call void @set_storage(ptr %5, ptr %2)
  %10 = call ptr @heap_malloc(i64 4)
  %11 = getelementptr i64, ptr %10, i64 0
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %10, i64 1
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %10, i64 2
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %10, i64 3
  store i64 3, ptr %14, align 4
  call void @set_storage(ptr %10, ptr %3)
  ret void
}

define ptr @get_age() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = call ptr @heap_malloc(i64 4)
  %2 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %1, i64 3
  store i64 2, ptr %5, align 4
  call void @get_storage(ptr %1, ptr %0)
  %6 = call ptr @heap_malloc(i64 4)
  %7 = call ptr @heap_malloc(i64 4)
  %8 = getelementptr i64, ptr %7, i64 0
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %7, i64 1
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %7, i64 3
  store i64 3, ptr %11, align 4
  call void @get_storage(ptr %7, ptr %6)
  %12 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %0, ptr %12, i64 4)
  %13 = getelementptr i64, ptr %12, i64 4
  call void @memcpy(ptr %6, ptr %13, i64 4)
  ret ptr %12
}

define void @set_key(ptr %0) {
entry:
  %_key = alloca ptr, align 8
  store ptr %0, ptr %_key, align 8
  %1 = call ptr @heap_malloc(i64 4)
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %2, i64 3
  store i64 4, ptr %6, align 4
  call void @get_storage(ptr %2, ptr %1)
  %length = getelementptr i64, ptr %1, i64 3
  %7 = load i64, ptr %length, align 4
  %8 = call ptr @heap_malloc(i64 4)
  %9 = getelementptr i64, ptr %8, i64 0
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %8, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %8, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %8, i64 3
  store i64 4, ptr %12, align 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %8, ptr %13, i64 4)
  %hash_value_low = getelementptr i64, ptr %13, i64 3
  %14 = load i64, ptr %hash_value_low, align 4
  %15 = mul i64 %7, 2
  %storage_array_offset = add i64 %14, %15
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %16 = load ptr, ptr %_key, align 8
  %17 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %17, i64 4)
  %18 = call ptr @heap_malloc(i64 4)
  %19 = getelementptr i64, ptr %16, i64 4
  call void @memcpy(ptr %19, ptr %18, i64 4)
  call void @set_storage(ptr %13, ptr %17)
  %20 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %13, ptr %20, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %20, i64 3
  %21 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %21, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  call void @set_storage(ptr %20, ptr %18)
  %new_length = add i64 %7, 1
  %22 = call ptr @heap_malloc(i64 4)
  %23 = getelementptr i64, ptr %22, i64 0
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %22, i64 1
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %22, i64 2
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %22, i64 3
  store i64 4, ptr %26, align 4
  %27 = call ptr @heap_malloc(i64 4)
  %28 = getelementptr i64, ptr %27, i64 0
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %27, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %27, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %27, i64 3
  store i64 %new_length, ptr %31, align 4
  call void @set_storage(ptr %22, ptr %27)
  ret void
}

define ptr @get_key(i64 %0) {
entry:
  %_index = alloca i64, align 8
  store i64 %0, ptr %_index, align 4
  %1 = load i64, ptr %_index, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 4, ptr %7, align 4
  call void @get_storage(ptr %3, ptr %2)
  %8 = getelementptr i64, ptr %2, i64 3
  %storage_value = load i64, ptr %8, align 4
  %9 = sub i64 %storage_value, 1
  %10 = sub i64 %9, %1
  call void @builtin_range_check(i64 %10)
  %11 = call ptr @heap_malloc(i64 4)
  %12 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %11, i64 3
  store i64 4, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %11, ptr %16, i64 4)
  %hash_value_low = getelementptr i64, ptr %16, i64 3
  %17 = load i64, ptr %hash_value_low, align 4
  %18 = mul i64 %1, 2
  %storage_array_offset = add i64 %17, %18
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %16, ptr %19)
  %20 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %20, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %20, i64 3
  %21 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %21, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %22 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %20, ptr %22)
  %23 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %23, i64 4)
  %last_elem_ptr1 = getelementptr i64, ptr %23, i64 3
  %24 = load i64, ptr %last_elem_ptr1, align 4
  %last_elem2 = add i64 %24, 2
  store i64 %last_elem2, ptr %last_elem_ptr1, align 4
  %25 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %19, ptr %25, i64 4)
  %26 = getelementptr i64, ptr %25, i64 4
  call void @memcpy(ptr %22, ptr %26, i64 4)
  ret ptr %25
}

define void @remove_key() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = call ptr @heap_malloc(i64 4)
  %2 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %1, i64 3
  store i64 4, ptr %5, align 4
  call void @get_storage(ptr %1, ptr %0)
  %length = getelementptr i64, ptr %0, i64 3
  %6 = load i64, ptr %length, align 4
  %7 = call ptr @heap_malloc(i64 4)
  %8 = getelementptr i64, ptr %7, i64 0
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %7, i64 1
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %7, i64 3
  store i64 4, ptr %11, align 4
  %12 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %7, ptr %12, i64 4)
  %hash_value_low = getelementptr i64, ptr %12, i64 3
  %13 = load i64, ptr %hash_value_low, align 4
  %14 = mul i64 %6, 2
  %storage_array_offset = add i64 %13, %14
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %15 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %12, ptr %15)
  %16 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %12, ptr %16, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %16, i64 3
  %17 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %17, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %18 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %16, ptr %18)
  %19 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %12, ptr %19, i64 4)
  %last_elem_ptr1 = getelementptr i64, ptr %19, i64 3
  %20 = load i64, ptr %last_elem_ptr1, align 4
  %last_elem2 = add i64 %20, 2
  store i64 %last_elem2, ptr %last_elem_ptr1, align 4
  %21 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %15, ptr %21, i64 4)
  %22 = getelementptr i64, ptr %21, i64 4
  call void @memcpy(ptr %18, ptr %22, i64 4)
  %23 = call ptr @heap_malloc(i64 4)
  %storage_zero_ptr = getelementptr i64, ptr %23, i64 0
  store i64 0, ptr %storage_zero_ptr, align 4
  %storage_zero_ptr3 = getelementptr i64, ptr %23, i64 1
  store i64 0, ptr %storage_zero_ptr3, align 4
  %storage_zero_ptr4 = getelementptr i64, ptr %23, i64 2
  store i64 0, ptr %storage_zero_ptr4, align 4
  %storage_zero_ptr5 = getelementptr i64, ptr %23, i64 3
  store i64 0, ptr %storage_zero_ptr5, align 4
  call void @set_storage(ptr %12, ptr %23)
  %24 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %12, ptr %24, i64 4)
  %last_elem_ptr6 = getelementptr i64, ptr %24, i64 3
  %25 = load i64, ptr %last_elem_ptr6, align 4
  %last_elem7 = add i64 %25, 1
  store i64 %last_elem7, ptr %last_elem_ptr6, align 4
  %26 = call ptr @heap_malloc(i64 4)
  %storage_zero_ptr8 = getelementptr i64, ptr %26, i64 0
  store i64 0, ptr %storage_zero_ptr8, align 4
  %storage_zero_ptr9 = getelementptr i64, ptr %26, i64 1
  store i64 0, ptr %storage_zero_ptr9, align 4
  %storage_zero_ptr10 = getelementptr i64, ptr %26, i64 2
  store i64 0, ptr %storage_zero_ptr10, align 4
  %storage_zero_ptr11 = getelementptr i64, ptr %26, i64 3
  store i64 0, ptr %storage_zero_ptr11, align 4
  call void @set_storage(ptr %24, ptr %26)
  %new_length = sub i64 %6, 1
  %27 = call ptr @heap_malloc(i64 4)
  %28 = getelementptr i64, ptr %27, i64 0
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %27, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %27, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %27, i64 3
  store i64 4, ptr %31, align 4
  %32 = call ptr @heap_malloc(i64 4)
  %33 = getelementptr i64, ptr %32, i64 0
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %32, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %32, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %32, i64 3
  store i64 %new_length, ptr %36, align 4
  call void @set_storage(ptr %27, ptr %32)
  ret void
}

define void @set_person(ptr %0, ptr %1) {
entry:
  %_height = alloca ptr, align 8
  %_age = alloca ptr, align 8
  store ptr %0, ptr %_age, align 8
  store ptr %1, ptr %_height, align 8
  %2 = load ptr, ptr %_age, align 8
  %3 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %2, ptr %3, i64 4)
  %4 = call ptr @heap_malloc(i64 4)
  %5 = getelementptr i64, ptr %2, i64 4
  call void @memcpy(ptr %5, ptr %4, i64 4)
  %6 = call ptr @heap_malloc(i64 4)
  %7 = getelementptr i64, ptr %6, i64 0
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %6, i64 1
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %6, i64 2
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %6, i64 3
  store i64 6, ptr %10, align 4
  call void @set_storage(ptr %6, ptr %3)
  %11 = call ptr @heap_malloc(i64 4)
  %12 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %11, i64 3
  store i64 7, ptr %15, align 4
  call void @set_storage(ptr %11, ptr %4)
  %16 = load ptr, ptr %_height, align 8
  %17 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %17, i64 4)
  %18 = call ptr @heap_malloc(i64 4)
  %19 = getelementptr i64, ptr %16, i64 4
  call void @memcpy(ptr %19, ptr %18, i64 4)
  %20 = call ptr @heap_malloc(i64 4)
  %21 = getelementptr i64, ptr %20, i64 0
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %20, i64 1
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %20, i64 2
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %20, i64 3
  store i64 8, ptr %24, align 4
  call void @set_storage(ptr %20, ptr %17)
  %25 = call ptr @heap_malloc(i64 4)
  %26 = getelementptr i64, ptr %25, i64 0
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %25, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %25, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %25, i64 3
  store i64 9, ptr %29, align 4
  call void @set_storage(ptr %25, ptr %18)
  ret void
}

define ptr @get_person() {
entry:
  %0 = call ptr @heap_malloc(i64 2)
  %1 = call ptr @heap_malloc(i64 4)
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %2, i64 3
  store i64 6, ptr %6, align 4
  call void @get_storage(ptr %2, ptr %1)
  %7 = call ptr @heap_malloc(i64 4)
  %8 = call ptr @heap_malloc(i64 4)
  %9 = getelementptr i64, ptr %8, i64 0
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %8, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %8, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %8, i64 3
  store i64 7, ptr %12, align 4
  call void @get_storage(ptr %8, ptr %7)
  %13 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %1, ptr %13, i64 4)
  %14 = getelementptr i64, ptr %13, i64 4
  call void @memcpy(ptr %7, ptr %14, i64 4)
  %age = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 0
  store ptr %13, ptr %age, align 8
  %15 = call ptr @heap_malloc(i64 4)
  %16 = call ptr @heap_malloc(i64 4)
  %17 = getelementptr i64, ptr %16, i64 0
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %16, i64 1
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %16, i64 2
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %16, i64 3
  store i64 8, ptr %20, align 4
  call void @get_storage(ptr %16, ptr %15)
  %21 = call ptr @heap_malloc(i64 4)
  %22 = call ptr @heap_malloc(i64 4)
  %23 = getelementptr i64, ptr %22, i64 0
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %22, i64 1
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %22, i64 2
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %22, i64 3
  store i64 9, ptr %26, align 4
  call void @get_storage(ptr %22, ptr %21)
  %27 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %15, ptr %27, i64 4)
  %28 = getelementptr i64, ptr %27, i64 4
  call void @memcpy(ptr %21, ptr %28, i64 4)
  %height = getelementptr inbounds { ptr, ptr }, ptr %0, i32 0, i32 1
  store ptr %27, ptr %height, align 8
  ret ptr %0
}

define void @set_map(ptr %0, ptr %1) {
entry:
  %_value = alloca ptr, align 8
  %_key = alloca ptr, align 8
  store ptr %0, ptr %_key, align 8
  store ptr %1, ptr %_value, align 8
  %2 = load ptr, ptr %_key, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 10, ptr %7, align 4
  %8 = call ptr @heap_malloc(i64 12)
  call void @memcpy(ptr %3, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  call void @memcpy(ptr %2, ptr %9, i64 8)
  %10 = getelementptr i64, ptr %9, i64 8
  %11 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %8, ptr %11, i64 12)
  %12 = load ptr, ptr %_value, align 8
  %13 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %12, ptr %13, i64 4)
  %14 = call ptr @heap_malloc(i64 4)
  %15 = getelementptr i64, ptr %12, i64 4
  call void @memcpy(ptr %15, ptr %14, i64 4)
  call void @set_storage(ptr %11, ptr %13)
  %16 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %11, ptr %16, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %16, i64 3
  %17 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %17, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  call void @set_storage(ptr %16, ptr %14)
  ret void
}

define ptr @get_map(ptr %0) {
entry:
  %_key = alloca ptr, align 8
  store ptr %0, ptr %_key, align 8
  %1 = load ptr, ptr %_key, align 8
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %2, i64 3
  store i64 10, ptr %6, align 4
  %7 = call ptr @heap_malloc(i64 12)
  call void @memcpy(ptr %2, ptr %7, i64 4)
  %8 = getelementptr i64, ptr %7, i64 4
  call void @memcpy(ptr %1, ptr %8, i64 8)
  %9 = getelementptr i64, ptr %8, i64 8
  %10 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %7, ptr %10, i64 12)
  %11 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %11)
  %12 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %10, ptr %12, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %12, i64 3
  %13 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %13, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %14 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %12, ptr %14)
  %15 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %10, ptr %15, i64 4)
  %last_elem_ptr1 = getelementptr i64, ptr %15, i64 3
  %16 = load i64, ptr %last_elem_ptr1, align 4
  %last_elem2 = add i64 %16, 2
  store i64 %last_elem2, ptr %last_elem_ptr1, align 4
  %17 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %11, ptr %17, i64 4)
  %18 = getelementptr i64, ptr %17, i64 4
  call void @memcpy(ptr %14, ptr %18, i64 4)
  ret ptr %17
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 4047015750, label %func_0_dispatch
    i64 869224576, label %func_1_dispatch
    i64 1791121329, label %func_2_dispatch
    i64 850637514, label %func_3_dispatch
    i64 3266885237, label %func_4_dispatch
    i64 1361833047, label %func_5_dispatch
    i64 3267209490, label %func_6_dispatch
    i64 296848194, label %func_7_dispatch
    i64 3269226065, label %func_8_dispatch
    i64 949721515, label %func_9_dispatch
    i64 873416068, label %func_10_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @set_value()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %4 = call ptr @get_value()
  %5 = call ptr @heap_malloc(i64 9)
  %6 = getelementptr i64, ptr %4, i64 0
  %7 = load i64, ptr %6, align 4
  %8 = getelementptr i64, ptr %5, i64 0
  store i64 %7, ptr %8, align 4
  %9 = getelementptr i64, ptr %4, i64 1
  %10 = load i64, ptr %9, align 4
  %11 = getelementptr i64, ptr %5, i64 1
  store i64 %10, ptr %11, align 4
  %12 = getelementptr i64, ptr %4, i64 2
  %13 = load i64, ptr %12, align 4
  %14 = getelementptr i64, ptr %5, i64 2
  store i64 %13, ptr %14, align 4
  %15 = getelementptr i64, ptr %4, i64 3
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %5, i64 3
  store i64 %16, ptr %17, align 4
  %18 = getelementptr i64, ptr %4, i64 4
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %5, i64 4
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %4, i64 5
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %5, i64 5
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %4, i64 6
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %5, i64 6
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %4, i64 7
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %5, i64 7
  store i64 %28, ptr %29, align 4
  %30 = getelementptr ptr, ptr %5, i64 8
  store i64 8, ptr %30, align 4
  call void @set_tape_data(ptr %5, i64 9)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %31 = getelementptr ptr, ptr %2, i64 0
  call void @set_age(ptr %31)
  %32 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %32, align 4
  call void @set_tape_data(ptr %32, i64 1)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %33 = call ptr @get_age()
  %34 = call ptr @heap_malloc(i64 9)
  %35 = getelementptr i64, ptr %33, i64 0
  %36 = load i64, ptr %35, align 4
  %37 = getelementptr i64, ptr %34, i64 0
  store i64 %36, ptr %37, align 4
  %38 = getelementptr i64, ptr %33, i64 1
  %39 = load i64, ptr %38, align 4
  %40 = getelementptr i64, ptr %34, i64 1
  store i64 %39, ptr %40, align 4
  %41 = getelementptr i64, ptr %33, i64 2
  %42 = load i64, ptr %41, align 4
  %43 = getelementptr i64, ptr %34, i64 2
  store i64 %42, ptr %43, align 4
  %44 = getelementptr i64, ptr %33, i64 3
  %45 = load i64, ptr %44, align 4
  %46 = getelementptr i64, ptr %34, i64 3
  store i64 %45, ptr %46, align 4
  %47 = getelementptr i64, ptr %33, i64 4
  %48 = load i64, ptr %47, align 4
  %49 = getelementptr i64, ptr %34, i64 4
  store i64 %48, ptr %49, align 4
  %50 = getelementptr i64, ptr %33, i64 5
  %51 = load i64, ptr %50, align 4
  %52 = getelementptr i64, ptr %34, i64 5
  store i64 %51, ptr %52, align 4
  %53 = getelementptr i64, ptr %33, i64 6
  %54 = load i64, ptr %53, align 4
  %55 = getelementptr i64, ptr %34, i64 6
  store i64 %54, ptr %55, align 4
  %56 = getelementptr i64, ptr %33, i64 7
  %57 = load i64, ptr %56, align 4
  %58 = getelementptr i64, ptr %34, i64 7
  store i64 %57, ptr %58, align 4
  %59 = getelementptr ptr, ptr %34, i64 8
  store i64 8, ptr %59, align 4
  call void @set_tape_data(ptr %34, i64 9)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %60 = getelementptr ptr, ptr %2, i64 0
  call void @set_key(ptr %60)
  %61 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %61, align 4
  call void @set_tape_data(ptr %61, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %62 = getelementptr ptr, ptr %2, i64 0
  %63 = load i64, ptr %62, align 4
  %64 = call ptr @get_key(i64 %63)
  %65 = call ptr @heap_malloc(i64 9)
  %66 = getelementptr i64, ptr %64, i64 0
  %67 = load i64, ptr %66, align 4
  %68 = getelementptr i64, ptr %65, i64 0
  store i64 %67, ptr %68, align 4
  %69 = getelementptr i64, ptr %64, i64 1
  %70 = load i64, ptr %69, align 4
  %71 = getelementptr i64, ptr %65, i64 1
  store i64 %70, ptr %71, align 4
  %72 = getelementptr i64, ptr %64, i64 2
  %73 = load i64, ptr %72, align 4
  %74 = getelementptr i64, ptr %65, i64 2
  store i64 %73, ptr %74, align 4
  %75 = getelementptr i64, ptr %64, i64 3
  %76 = load i64, ptr %75, align 4
  %77 = getelementptr i64, ptr %65, i64 3
  store i64 %76, ptr %77, align 4
  %78 = getelementptr i64, ptr %64, i64 4
  %79 = load i64, ptr %78, align 4
  %80 = getelementptr i64, ptr %65, i64 4
  store i64 %79, ptr %80, align 4
  %81 = getelementptr i64, ptr %64, i64 5
  %82 = load i64, ptr %81, align 4
  %83 = getelementptr i64, ptr %65, i64 5
  store i64 %82, ptr %83, align 4
  %84 = getelementptr i64, ptr %64, i64 6
  %85 = load i64, ptr %84, align 4
  %86 = getelementptr i64, ptr %65, i64 6
  store i64 %85, ptr %86, align 4
  %87 = getelementptr i64, ptr %64, i64 7
  %88 = load i64, ptr %87, align 4
  %89 = getelementptr i64, ptr %65, i64 7
  store i64 %88, ptr %89, align 4
  %90 = getelementptr ptr, ptr %65, i64 8
  store i64 8, ptr %90, align 4
  call void @set_tape_data(ptr %65, i64 9)
  ret void

func_6_dispatch:                                  ; preds = %entry
  call void @remove_key()
  %91 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %91, align 4
  call void @set_tape_data(ptr %91, i64 1)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %92 = getelementptr ptr, ptr %2, i64 0
  %93 = getelementptr ptr, ptr %92, i64 8
  call void @set_person(ptr %92, ptr %93)
  %94 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %94, align 4
  call void @set_tape_data(ptr %94, i64 1)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %95 = call ptr @get_person()
  %96 = call ptr @heap_malloc(i64 17)
  %struct_member = getelementptr inbounds { ptr, ptr }, ptr %95, i32 0, i32 0
  %strcut_member = load ptr, ptr %struct_member, align 8
  %struct_offset = getelementptr ptr, ptr %96, i64 0
  %97 = getelementptr i64, ptr %strcut_member, i64 0
  %98 = load i64, ptr %97, align 4
  %99 = getelementptr i64, ptr %struct_offset, i64 0
  store i64 %98, ptr %99, align 4
  %100 = getelementptr i64, ptr %strcut_member, i64 1
  %101 = load i64, ptr %100, align 4
  %102 = getelementptr i64, ptr %struct_offset, i64 1
  store i64 %101, ptr %102, align 4
  %103 = getelementptr i64, ptr %strcut_member, i64 2
  %104 = load i64, ptr %103, align 4
  %105 = getelementptr i64, ptr %struct_offset, i64 2
  store i64 %104, ptr %105, align 4
  %106 = getelementptr i64, ptr %strcut_member, i64 3
  %107 = load i64, ptr %106, align 4
  %108 = getelementptr i64, ptr %struct_offset, i64 3
  store i64 %107, ptr %108, align 4
  %109 = getelementptr i64, ptr %strcut_member, i64 4
  %110 = load i64, ptr %109, align 4
  %111 = getelementptr i64, ptr %struct_offset, i64 4
  store i64 %110, ptr %111, align 4
  %112 = getelementptr i64, ptr %strcut_member, i64 5
  %113 = load i64, ptr %112, align 4
  %114 = getelementptr i64, ptr %struct_offset, i64 5
  store i64 %113, ptr %114, align 4
  %115 = getelementptr i64, ptr %strcut_member, i64 6
  %116 = load i64, ptr %115, align 4
  %117 = getelementptr i64, ptr %struct_offset, i64 6
  store i64 %116, ptr %117, align 4
  %118 = getelementptr i64, ptr %strcut_member, i64 7
  %119 = load i64, ptr %118, align 4
  %120 = getelementptr i64, ptr %struct_offset, i64 7
  store i64 %119, ptr %120, align 4
  %struct_member1 = getelementptr inbounds { ptr, ptr }, ptr %95, i32 0, i32 1
  %strcut_member2 = load ptr, ptr %struct_member1, align 8
  %struct_offset3 = getelementptr ptr, ptr %struct_offset, i64 8
  %121 = getelementptr i64, ptr %strcut_member2, i64 0
  %122 = load i64, ptr %121, align 4
  %123 = getelementptr i64, ptr %struct_offset3, i64 0
  store i64 %122, ptr %123, align 4
  %124 = getelementptr i64, ptr %strcut_member2, i64 1
  %125 = load i64, ptr %124, align 4
  %126 = getelementptr i64, ptr %struct_offset3, i64 1
  store i64 %125, ptr %126, align 4
  %127 = getelementptr i64, ptr %strcut_member2, i64 2
  %128 = load i64, ptr %127, align 4
  %129 = getelementptr i64, ptr %struct_offset3, i64 2
  store i64 %128, ptr %129, align 4
  %130 = getelementptr i64, ptr %strcut_member2, i64 3
  %131 = load i64, ptr %130, align 4
  %132 = getelementptr i64, ptr %struct_offset3, i64 3
  store i64 %131, ptr %132, align 4
  %133 = getelementptr i64, ptr %strcut_member2, i64 4
  %134 = load i64, ptr %133, align 4
  %135 = getelementptr i64, ptr %struct_offset3, i64 4
  store i64 %134, ptr %135, align 4
  %136 = getelementptr i64, ptr %strcut_member2, i64 5
  %137 = load i64, ptr %136, align 4
  %138 = getelementptr i64, ptr %struct_offset3, i64 5
  store i64 %137, ptr %138, align 4
  %139 = getelementptr i64, ptr %strcut_member2, i64 6
  %140 = load i64, ptr %139, align 4
  %141 = getelementptr i64, ptr %struct_offset3, i64 6
  store i64 %140, ptr %141, align 4
  %142 = getelementptr i64, ptr %strcut_member2, i64 7
  %143 = load i64, ptr %142, align 4
  %144 = getelementptr i64, ptr %struct_offset3, i64 7
  store i64 %143, ptr %144, align 4
  %145 = getelementptr ptr, ptr %96, i64 16
  store i64 16, ptr %145, align 4
  call void @set_tape_data(ptr %96, i64 17)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %146 = getelementptr ptr, ptr %2, i64 0
  %147 = getelementptr ptr, ptr %146, i64 8
  call void @set_map(ptr %146, ptr %147)
  %148 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %148, align 4
  call void @set_tape_data(ptr %148, i64 1)
  ret void

func_10_dispatch:                                 ; preds = %entry
  %149 = getelementptr ptr, ptr %2, i64 0
  %150 = call ptr @get_map(ptr %149)
  %151 = call ptr @heap_malloc(i64 9)
  %152 = getelementptr i64, ptr %150, i64 0
  %153 = load i64, ptr %152, align 4
  %154 = getelementptr i64, ptr %151, i64 0
  store i64 %153, ptr %154, align 4
  %155 = getelementptr i64, ptr %150, i64 1
  %156 = load i64, ptr %155, align 4
  %157 = getelementptr i64, ptr %151, i64 1
  store i64 %156, ptr %157, align 4
  %158 = getelementptr i64, ptr %150, i64 2
  %159 = load i64, ptr %158, align 4
  %160 = getelementptr i64, ptr %151, i64 2
  store i64 %159, ptr %160, align 4
  %161 = getelementptr i64, ptr %150, i64 3
  %162 = load i64, ptr %161, align 4
  %163 = getelementptr i64, ptr %151, i64 3
  store i64 %162, ptr %163, align 4
  %164 = getelementptr i64, ptr %150, i64 4
  %165 = load i64, ptr %164, align 4
  %166 = getelementptr i64, ptr %151, i64 4
  store i64 %165, ptr %166, align 4
  %167 = getelementptr i64, ptr %150, i64 5
  %168 = load i64, ptr %167, align 4
  %169 = getelementptr i64, ptr %151, i64 5
  store i64 %168, ptr %169, align 4
  %170 = getelementptr i64, ptr %150, i64 6
  %171 = load i64, ptr %170, align 4
  %172 = getelementptr i64, ptr %151, i64 6
  store i64 %171, ptr %172, align 4
  %173 = getelementptr i64, ptr %150, i64 7
  %174 = load i64, ptr %173, align 4
  %175 = getelementptr i64, ptr %151, i64 7
  store i64 %174, ptr %175, align 4
  %176 = getelementptr ptr, ptr %151, i64 8
  store i64 8, ptr %176, align 4
  call void @set_tape_data(ptr %151, i64 9)
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
