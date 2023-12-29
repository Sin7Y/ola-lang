; ModuleID = 'NonceHolder'
source_filename = "NonceHolder"

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
  br i1 %compare, label %done, label %cond

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
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
  br i1 %compare, label %done, label %cond

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
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
  br i1 %compare, label %done, label %cond

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
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

cond:                                             ; preds = %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %right_high, align 4
  %5 = load i64, ptr %left_low, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %4, %3
  br i1 %compare_high, label %done, label %low_compare_block

low_compare_block:                                ; preds = %low_compare_block, %body
  %compare_low = icmp uge i64 %6, %5
  br i1 %compare_low, label %done, label %low_compare_block

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
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
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %right_high, align 4
  %5 = load i64, ptr %left_low, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %4
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %5, %6
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

cond:                                             ; preds = %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %right_high, align 4
  %5 = load i64, ptr %left_low, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %4, %3
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %low_compare_block, %body
  %compare_low = icmp uge i64 %6, %5
  br i1 %compare_low, label %low_compare_block, label %done

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

cond:                                             ; preds = %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %right_high, align 4
  %5 = load i64, ptr %left_low, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %4
  br i1 %compare_high, label %done, label %low_compare_block

low_compare_block:                                ; preds = %low_compare_block, %body
  %compare_low = icmp uge i64 %5, %6
  br i1 %compare_low, label %done, label %low_compare_block

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
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

define void @onlyEntrypointCall() {
entry:
  %ENTRY_POINT_ADDRESS = alloca ptr, align 8
  %0 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %0, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %0, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %0, i64 3
  store i64 32769, ptr %index_access3, align 4
  store ptr %0, ptr %ENTRY_POINT_ADDRESS, align 8
  %1 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %1, i64 12)
  %2 = load ptr, ptr %ENTRY_POINT_ADDRESS, align 8
  %3 = call i64 @memcmp_eq(ptr %1, ptr %2, i64 4)
  call void @builtin_assert(i64 %3)
  ret void
}

define i64 @isNonceUsed(ptr %0, i64 %1) {
entry:
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
  %3 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 3
  store i64 0, ptr %6, align 4
  %7 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %3, ptr %7, i64 4)
  %8 = getelementptr i64, ptr %7, i64 4
  call void @memcpy(ptr %2, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  %10 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %7, ptr %10, i64 8)
  %11 = load i64, ptr %_nonce, align 4
  %12 = call ptr @heap_malloc(i64 4)
  store i64 %11, ptr %12, align 4
  %13 = getelementptr i64, ptr %12, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %12, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %12, i64 3
  store i64 0, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %10, ptr %16, i64 4)
  %17 = getelementptr i64, ptr %16, i64 4
  call void @memcpy(ptr %12, ptr %17, i64 4)
  %18 = getelementptr i64, ptr %17, i64 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %16, ptr %19, i64 8)
  %20 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %19, ptr %20)
  %storage_value = load i64, ptr %20, align 4
  %slot_value = load i64, ptr %19, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %19, align 4
  ret i64 %storage_value
}

define void @setNonce(ptr %0, i64 %1) {
entry:
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  call void @onlyEntrypointCall()
  %2 = load ptr, ptr %_address, align 8
  %3 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 3
  store i64 0, ptr %6, align 4
  %7 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %3, ptr %7, i64 4)
  %8 = getelementptr i64, ptr %7, i64 4
  call void @memcpy(ptr %2, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  %10 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %7, ptr %10, i64 8)
  %11 = load i64, ptr %_nonce, align 4
  %12 = call ptr @heap_malloc(i64 4)
  store i64 %11, ptr %12, align 4
  %13 = getelementptr i64, ptr %12, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %12, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %12, i64 3
  store i64 0, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %10, ptr %16, i64 4)
  %17 = getelementptr i64, ptr %16, i64 4
  call void @memcpy(ptr %12, ptr %17, i64 4)
  %18 = getelementptr i64, ptr %17, i64 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %16, ptr %19, i64 8)
  %20 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %19, ptr %20)
  %storage_value = load i64, ptr %20, align 4
  %slot_value = load i64, ptr %19, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %19, align 4
  %21 = icmp eq i64 %storage_value, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  %23 = load ptr, ptr %_address, align 8
  %24 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %24, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %24, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %24, i64 3
  store i64 0, ptr %27, align 4
  %28 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %24, ptr %28, i64 4)
  %29 = getelementptr i64, ptr %28, i64 4
  call void @memcpy(ptr %23, ptr %29, i64 4)
  %30 = getelementptr i64, ptr %29, i64 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %28, ptr %31, i64 8)
  %32 = load i64, ptr %_nonce, align 4
  %33 = call ptr @heap_malloc(i64 4)
  store i64 %32, ptr %33, align 4
  %34 = getelementptr i64, ptr %33, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %33, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %33, i64 3
  store i64 0, ptr %36, align 4
  %37 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %31, ptr %37, i64 4)
  %38 = getelementptr i64, ptr %37, i64 4
  call void @memcpy(ptr %33, ptr %38, i64 4)
  %39 = getelementptr i64, ptr %38, i64 4
  %40 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %37, ptr %40, i64 8)
  %41 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %41, align 4
  %42 = getelementptr i64, ptr %41, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %41, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %41, i64 3
  store i64 0, ptr %44, align 4
  call void @set_storage(ptr %40, ptr %41)
  %45 = load ptr, ptr %_address, align 8
  %46 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %46, align 4
  %47 = getelementptr i64, ptr %46, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %46, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %46, i64 3
  store i64 0, ptr %49, align 4
  %50 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %46, ptr %50, i64 4)
  %51 = getelementptr i64, ptr %50, i64 4
  call void @memcpy(ptr %45, ptr %51, i64 4)
  %52 = getelementptr i64, ptr %51, i64 4
  %53 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %50, ptr %53, i64 8)
  %54 = load ptr, ptr %_address, align 8
  %55 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %55, align 4
  %56 = getelementptr i64, ptr %55, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %55, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %55, i64 3
  store i64 0, ptr %58, align 4
  %59 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %55, ptr %59, i64 4)
  %60 = getelementptr i64, ptr %59, i64 4
  call void @memcpy(ptr %54, ptr %60, i64 4)
  %61 = getelementptr i64, ptr %60, i64 4
  %62 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %59, ptr %62, i64 8)
  %63 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %62, ptr %63)
  %storage_value1 = load i64, ptr %63, align 4
  %slot_value2 = load i64, ptr %62, align 4
  %slot_offset3 = add i64 %slot_value2, 1
  store i64 %slot_offset3, ptr %62, align 4
  %64 = add i64 %storage_value1, 1
  call void @builtin_range_check(i64 %64)
  %65 = call ptr @heap_malloc(i64 4)
  store i64 %64, ptr %65, align 4
  %66 = getelementptr i64, ptr %65, i64 1
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %65, i64 2
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %65, i64 3
  store i64 0, ptr %68, align 4
  call void @set_storage(ptr %53, ptr %65)
  ret void
}

define i64 @usedNonces(ptr %0) {
entry:
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = load ptr, ptr %_address, align 8
  %2 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %2, align 4
  %3 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 3
  store i64 0, ptr %5, align 4
  %6 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %2, ptr %6, i64 4)
  %7 = getelementptr i64, ptr %6, i64 4
  call void @memcpy(ptr %1, ptr %7, i64 4)
  %8 = getelementptr i64, ptr %7, i64 4
  %9 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %6, ptr %9, i64 8)
  %10 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %9, ptr %10)
  %storage_value = load i64, ptr %10, align 4
  %slot_value = load i64, ptr %9, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %9, align 4
  ret i64 %storage_value
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3726813225, label %func_0_dispatch
    i64 3775522898, label %func_1_dispatch
    i64 1093482716, label %func_2_dispatch
    i64 3868785611, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @onlyEntrypointCall()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %4 = getelementptr ptr, ptr %2, i64 0
  %5 = getelementptr ptr, ptr %4, i64 4
  %6 = load i64, ptr %5, align 4
  %7 = call i64 @isNonceUsed(ptr %4, i64 %6)
  %8 = call ptr @heap_malloc(i64 2)
  store i64 %7, ptr %8, align 4
  %9 = getelementptr ptr, ptr %8, i64 1
  store i64 1, ptr %9, align 4
  call void @set_tape_data(ptr %8, i64 2)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %10 = getelementptr ptr, ptr %2, i64 0
  %11 = getelementptr ptr, ptr %10, i64 4
  %12 = load i64, ptr %11, align 4
  call void @setNonce(ptr %10, i64 %12)
  %13 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %13, align 4
  call void @set_tape_data(ptr %13, i64 1)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %14 = getelementptr ptr, ptr %2, i64 0
  %15 = call i64 @usedNonces(ptr %14)
  %16 = call ptr @heap_malloc(i64 2)
  store i64 %15, ptr %16, align 4
  %17 = getelementptr ptr, ptr %16, i64 1
  store i64 1, ptr %17, align 4
  call void @set_tape_data(ptr %16, i64 2)
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
