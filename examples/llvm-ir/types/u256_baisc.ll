; ModuleID = 'U256BasicTest'
source_filename = "u256_baisc"

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

define void @testU256DeclareUninitialized() {
entry:
  %a = alloca ptr, align 8
  %cc = alloca i64, align 8
  store i64 1, ptr %cc, align 4
  %0 = load i64, ptr %cc, align 4
  %1 = call ptr @heap_malloc(i64 8)
  %2 = getelementptr i64, ptr %1, i64 7
  store i64 %0, ptr %2, align 4
  store ptr %1, ptr %a, align 8
  %3 = load ptr, ptr %a, align 8
  %4 = load i64, ptr %3, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU256DeclareInitialized() {
entry:
  %a = alloca ptr, align 8
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 5, ptr %index_access, align 4
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
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  %2 = load i64, ptr %1, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @testU256DeclareThenInitialized() {
entry:
  %a = alloca ptr, align 8
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 0, ptr %index_access, align 4
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
  store ptr %0, ptr %a, align 8
  %1 = call ptr @heap_malloc(i64 8)
  %index_access8 = getelementptr i64, ptr %1, i64 7
  store i64 5, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %1, i64 6
  store i64 0, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %1, i64 5
  store i64 0, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %1, i64 4
  store i64 0, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %1, i64 3
  store i64 0, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %index_access15, align 4
  store ptr %1, ptr %a, align 8
  %2 = load ptr, ptr %a, align 8
  %3 = load i64, ptr %2, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU256InitializedByOther() {
entry:
  %b = alloca ptr, align 8
  %a = alloca ptr, align 8
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 5, ptr %index_access, align 4
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
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  store ptr %1, ptr %b, align 8
  %2 = load ptr, ptr %b, align 8
  %3 = load i64, ptr %2, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU256LeftValueExpression() {
entry:
  %a = alloca ptr, align 8
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 5, ptr %index_access, align 4
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
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  store ptr %1, ptr %a, align 8
  %2 = load ptr, ptr %a, align 8
  %3 = load i64, ptr %2, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU256AsParameter(ptr %0) {
entry:
  %x = alloca ptr, align 8
  store ptr %0, ptr %x, align 8
  %1 = load ptr, ptr %x, align 8
  %2 = load i64, ptr %1, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @testU256CallByValue() {
entry:
  %a = alloca ptr, align 8
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 5, ptr %index_access, align 4
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
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  call void @testU256AsParameter(ptr %1)
  ret void
}

define ptr @testU256AsReturnValue() {
entry:
  %a = alloca ptr, align 8
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 10, ptr %index_access, align 4
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
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  ret ptr %1
}

define ptr @testU256AsReturnConstValue() {
entry:
  %0 = call ptr @heap_malloc(i64 8)
  %index_access = getelementptr i64, ptr %0, i64 7
  store i64 5, ptr %index_access, align 4
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
  ret ptr %0
}

define void @testConvertU32ToU256() {
entry:
  %b = alloca ptr, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = call ptr @heap_malloc(i64 8)
  %2 = getelementptr i64, ptr %1, i64 7
  store i64 %0, ptr %2, align 4
  store ptr %1, ptr %b, align 8
  %3 = load ptr, ptr %b, align 8
  %4 = load i64, ptr %3, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 858749044, label %func_0_dispatch
    i64 1841075722, label %func_1_dispatch
    i64 3918194444, label %func_2_dispatch
    i64 774324956, label %func_3_dispatch
    i64 3660631713, label %func_4_dispatch
    i64 2721668621, label %func_5_dispatch
    i64 3836818197, label %func_6_dispatch
    i64 23882381, label %func_7_dispatch
    i64 2581119172, label %func_8_dispatch
    i64 2116184395, label %func_9_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @testU256DeclareUninitialized()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @testU256DeclareInitialized()
  %4 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %4, align 4
  call void @set_tape_data(ptr %4, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @testU256DeclareThenInitialized()
  %5 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %5, align 4
  call void @set_tape_data(ptr %5, i64 1)
  ret void

func_3_dispatch:                                  ; preds = %entry
  call void @testU256InitializedByOther()
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_4_dispatch:                                  ; preds = %entry
  call void @testU256LeftValueExpression()
  %7 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %7, align 4
  call void @set_tape_data(ptr %7, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %8 = getelementptr ptr, ptr %2, i64 0
  call void @testU256AsParameter(ptr %8)
  %9 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %9, align 4
  call void @set_tape_data(ptr %9, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  call void @testU256CallByValue()
  %10 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %10, align 4
  call void @set_tape_data(ptr %10, i64 1)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %11 = call ptr @testU256AsReturnValue()
  %12 = call ptr @heap_malloc(i64 9)
  %13 = getelementptr i64, ptr %11, i64 0
  %14 = load i64, ptr %13, align 4
  %15 = getelementptr i64, ptr %12, i64 0
  store i64 %14, ptr %15, align 4
  %16 = getelementptr i64, ptr %11, i64 1
  %17 = load i64, ptr %16, align 4
  %18 = getelementptr i64, ptr %12, i64 1
  store i64 %17, ptr %18, align 4
  %19 = getelementptr i64, ptr %11, i64 2
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %12, i64 2
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %11, i64 3
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %12, i64 3
  store i64 %23, ptr %24, align 4
  %25 = getelementptr i64, ptr %11, i64 4
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %12, i64 4
  store i64 %26, ptr %27, align 4
  %28 = getelementptr i64, ptr %11, i64 5
  %29 = load i64, ptr %28, align 4
  %30 = getelementptr i64, ptr %12, i64 5
  store i64 %29, ptr %30, align 4
  %31 = getelementptr i64, ptr %11, i64 6
  %32 = load i64, ptr %31, align 4
  %33 = getelementptr i64, ptr %12, i64 6
  store i64 %32, ptr %33, align 4
  %34 = getelementptr i64, ptr %11, i64 7
  %35 = load i64, ptr %34, align 4
  %36 = getelementptr i64, ptr %12, i64 7
  store i64 %35, ptr %36, align 4
  %37 = getelementptr ptr, ptr %12, i64 8
  store i64 8, ptr %37, align 4
  call void @set_tape_data(ptr %12, i64 9)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %38 = call ptr @testU256AsReturnConstValue()
  %39 = call ptr @heap_malloc(i64 9)
  %40 = getelementptr i64, ptr %38, i64 0
  %41 = load i64, ptr %40, align 4
  %42 = getelementptr i64, ptr %39, i64 0
  store i64 %41, ptr %42, align 4
  %43 = getelementptr i64, ptr %38, i64 1
  %44 = load i64, ptr %43, align 4
  %45 = getelementptr i64, ptr %39, i64 1
  store i64 %44, ptr %45, align 4
  %46 = getelementptr i64, ptr %38, i64 2
  %47 = load i64, ptr %46, align 4
  %48 = getelementptr i64, ptr %39, i64 2
  store i64 %47, ptr %48, align 4
  %49 = getelementptr i64, ptr %38, i64 3
  %50 = load i64, ptr %49, align 4
  %51 = getelementptr i64, ptr %39, i64 3
  store i64 %50, ptr %51, align 4
  %52 = getelementptr i64, ptr %38, i64 4
  %53 = load i64, ptr %52, align 4
  %54 = getelementptr i64, ptr %39, i64 4
  store i64 %53, ptr %54, align 4
  %55 = getelementptr i64, ptr %38, i64 5
  %56 = load i64, ptr %55, align 4
  %57 = getelementptr i64, ptr %39, i64 5
  store i64 %56, ptr %57, align 4
  %58 = getelementptr i64, ptr %38, i64 6
  %59 = load i64, ptr %58, align 4
  %60 = getelementptr i64, ptr %39, i64 6
  store i64 %59, ptr %60, align 4
  %61 = getelementptr i64, ptr %38, i64 7
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr i64, ptr %39, i64 7
  store i64 %62, ptr %63, align 4
  %64 = getelementptr ptr, ptr %39, i64 8
  store i64 8, ptr %64, align 4
  call void @set_tape_data(ptr %39, i64 9)
  ret void

func_9_dispatch:                                  ; preds = %entry
  call void @testConvertU32ToU256()
  %65 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %65, align 4
  call void @set_tape_data(ptr %65, i64 1)
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
