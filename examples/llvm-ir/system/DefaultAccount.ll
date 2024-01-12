; ModuleID = 'DefaultAccount'
source_filename = "DefaultAccount"

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

define i64 @check_ecdsa(ptr %0, ptr %1, ptr %2) {
entry:
  %3 = call ptr @heap_malloc(i64 20)
  call void @memcpy(ptr %0, ptr %3, i64 4)
  %4 = getelementptr ptr, ptr %3, i64 4
  %vector_data = getelementptr i64, ptr %1, i64 1
  call void @memcpy(ptr %vector_data, ptr %4, i64 8)
  %5 = getelementptr ptr, ptr %4, i64 8
  %vector_data1 = getelementptr i64, ptr %2, i64 1
  call void @memcpy(ptr %vector_data1, ptr %5, i64 8)
  %6 = call i64 @builtin_check_ecdsa(ptr %3)
  ret i64 %6
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

define void @ignoreDelegateCall() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  call void @get_tape_data(ptr %0, i64 4)
  %1 = call ptr @heap_malloc(i64 8)
  call void @get_tape_data(ptr %1, i64 8)
  %2 = call i64 @memcmp_eq(ptr %0, ptr %1, i64 4)
  call void @builtin_assert(i64 %2)
  ret void
}

define void @setPubkey(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca8 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %addr = alloca ptr, align 8
  %_pk = alloca ptr, align 8
  store ptr %0, ptr %_pk, align 8
  %3 = load ptr, ptr %_pk, align 8
  %vector_length = load i64, ptr %3, align 4
  %4 = icmp eq i64 %vector_length, 8
  %5 = zext i1 %4 to i64
  call void @builtin_assert(i64 %5)
  %6 = call ptr @heap_malloc(i64 4)
  %7 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %7, i64 1
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %7, i64 3
  store i64 0, ptr %10, align 4
  call void @get_storage(ptr %7, ptr %6)
  %storage_value = load i64, ptr %6, align 4
  %11 = icmp eq i64 %storage_value, 0
  %12 = zext i1 %11 to i64
  call void @builtin_assert(i64 %12)
  %vector_length1 = load i64, ptr %3, align 4
  %vector_data = getelementptr i64, ptr %3, i64 1
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data, ptr %13, i64 %vector_length1)
  store ptr %13, ptr %addr, align 8
  %14 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %14, i64 12)
  %15 = load ptr, ptr %addr, align 8
  %16 = call i64 @memcmp_eq(ptr %14, ptr %15, i64 4)
  call void @builtin_assert(i64 %16)
  %vector_length2 = load i64, ptr %3, align 4
  %17 = call ptr @heap_malloc(i64 4)
  %18 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %18, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %18, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %18, i64 3
  store i64 0, ptr %21, align 4
  call void @get_storage(ptr %18, ptr %17)
  %storage_value3 = load i64, ptr %17, align 4
  %22 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %22, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %22, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %22, i64 3
  store i64 0, ptr %25, align 4
  %26 = call ptr @heap_malloc(i64 4)
  store i64 %vector_length2, ptr %26, align 4
  %27 = getelementptr i64, ptr %26, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %26, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %26, i64 3
  store i64 0, ptr %29, align 4
  call void @set_storage(ptr %22, ptr %26)
  %30 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %30, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %30, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %30, i64 3
  store i64 0, ptr %33, align 4
  %34 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %30, ptr %34, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %34, ptr %2, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %35 = load ptr, ptr %2, align 8
  %vector_data4 = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr i64, ptr %vector_data4, i64 %index_value
  %36 = load i64, ptr %index_access, align 4
  %37 = call ptr @heap_malloc(i64 4)
  store i64 %36, ptr %37, align 4
  %38 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %40, align 4
  call void @set_storage(ptr %35, ptr %37)
  %slot_value = load i64, ptr %35, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %35, align 4
  store ptr %35, ptr %2, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %vector_length2, ptr %index_alloca8, align 4
  store ptr %34, ptr %1, align 8
  br label %cond5

cond5:                                            ; preds = %body6, %done
  %index_value9 = load i64, ptr %index_alloca8, align 4
  %loop_cond10 = icmp ult i64 %index_value9, %storage_value3
  br i1 %loop_cond10, label %body6, label %done7

body6:                                            ; preds = %cond5
  %41 = load ptr, ptr %1, align 8
  %42 = call ptr @heap_malloc(i64 4)
  %storage_key_ptr = getelementptr i64, ptr %42, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr11 = getelementptr i64, ptr %42, i64 1
  store i64 0, ptr %storage_key_ptr11, align 4
  %storage_key_ptr12 = getelementptr i64, ptr %42, i64 2
  store i64 0, ptr %storage_key_ptr12, align 4
  %storage_key_ptr13 = getelementptr i64, ptr %42, i64 3
  store i64 0, ptr %storage_key_ptr13, align 4
  call void @set_storage(ptr %41, ptr %42)
  %slot_value14 = load i64, ptr %41, align 4
  %slot_offset15 = add i64 %slot_value14, 1
  store i64 %slot_offset15, ptr %41, align 4
  store ptr %41, ptr %1, align 8
  %next_index16 = add i64 %index_value9, 1
  store i64 %next_index16, ptr %index_alloca8, align 4
  br label %cond5

done7:                                            ; preds = %cond5
  ret void
}

define i64 @validateTransaction(ptr %0, ptr %1, ptr %2) {
entry:
  %3 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %expected = alloca i64, align 8
  %selector = alloca i64, align 8
  %len = alloca i64, align 8
  %magic = alloca i64, align 8
  %_tx = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  %_txHash = alloca ptr, align 8
  store ptr %0, ptr %_txHash, align 8
  store ptr %1, ptr %_signedHash, align 8
  store ptr %2, ptr %_tx, align 8
  %4 = load ptr, ptr %_tx, align 8
  call void @onlyEntrypointCall()
  call void @ignoreDelegateCall()
  store i64 3738116221, ptr %magic, align 4
  %5 = call ptr @heap_malloc(i64 4)
  %6 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %6, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %6, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %6, i64 3
  store i64 0, ptr %9, align 4
  call void @get_storage(ptr %6, ptr %5)
  %storage_value = load i64, ptr %5, align 4
  %10 = icmp eq i64 %storage_value, 0
  br i1 %10, label %then, label %else

then:                                             ; preds = %entry
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %4, i32 0, i32 2
  %11 = load ptr, ptr %struct_member, align 8
  %vector_length = load i64, ptr %11, align 4
  store i64 %vector_length, ptr %len, align 4
  %struct_member1 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %4, i32 0, i32 2
  %12 = load ptr, ptr %struct_member1, align 8
  %vector_length2 = load i64, ptr %12, align 4
  %13 = load i64, ptr %len, align 4
  %14 = sub i64 %13, 1
  call void @builtin_range_check(i64 %14)
  %15 = load i64, ptr %len, align 4
  %array_len_sub_one = sub i64 %vector_length2, 1
  %16 = sub i64 %array_len_sub_one, %14
  call void @builtin_range_check(i64 %16)
  %17 = sub i64 %vector_length2, %15
  call void @builtin_range_check(i64 %17)
  %slice_len = sub i64 %15, %14
  call void @builtin_range_check(i64 %slice_len)
  %18 = call ptr @vector_new(i64 %slice_len)
  %vector_data = getelementptr i64, ptr %18, i64 1
  %vector_data3 = getelementptr i64, ptr %12, i64 1
  %src_data_start = getelementptr i64, ptr %vector_data3, i64 %14
  call void @memcpy(ptr %src_data_start, ptr %vector_data, i64 %slice_len)
  %vector_data4 = getelementptr i64, ptr %18, i64 1
  %19 = getelementptr ptr, ptr %vector_data4, i64 0
  %20 = load i64, ptr %19, align 4
  store i64 %20, ptr %selector, align 4
  store i64 3925046215, ptr %expected, align 4
  %21 = load i64, ptr %selector, align 4
  %22 = load i64, ptr %expected, align 4
  %23 = icmp eq i64 %21, %22
  br i1 %23, label %then5, label %endif

else:                                             ; preds = %entry
  %24 = call ptr @vector_new(i64 8)
  %vector_data7 = getelementptr i64, ptr %24, i64 1
  %25 = getelementptr i64, ptr %vector_data7, i64 0
  call void @get_context_data(ptr %25, i64 13)
  %26 = getelementptr i64, ptr %vector_data7, i64 1
  call void @get_context_data(ptr %26, i64 14)
  %27 = getelementptr i64, ptr %vector_data7, i64 2
  call void @get_context_data(ptr %27, i64 15)
  %28 = getelementptr i64, ptr %vector_data7, i64 3
  call void @get_context_data(ptr %28, i64 16)
  %29 = getelementptr i64, ptr %vector_data7, i64 4
  call void @get_context_data(ptr %29, i64 17)
  %30 = getelementptr i64, ptr %vector_data7, i64 5
  call void @get_context_data(ptr %30, i64 18)
  %31 = getelementptr i64, ptr %vector_data7, i64 6
  call void @get_context_data(ptr %31, i64 19)
  %32 = getelementptr i64, ptr %vector_data7, i64 7
  call void @get_context_data(ptr %32, i64 20)
  %vector_length8 = load i64, ptr %24, align 4
  %33 = icmp eq i64 %vector_length8, 8
  %34 = zext i1 %33 to i64
  call void @builtin_assert(i64 %34)
  %35 = load ptr, ptr %_signedHash, align 8
  %36 = call ptr @heap_malloc(i64 4)
  %37 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %40, align 4
  call void @get_storage(ptr %37, ptr %36)
  %storage_value9 = load i64, ptr %36, align 4
  %41 = call ptr @vector_new(i64 %storage_value9)
  %42 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %42, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %42, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %42, i64 3
  store i64 0, ptr %45, align 4
  %46 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %42, ptr %46, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %46, ptr %3, align 8
  br label %cond

then5:                                            ; preds = %then
  %47 = load i64, ptr %magic, align 4
  ret i64 %47

endif:                                            ; preds = %then
  br label %endif6

endif6:                                           ; preds = %endif14, %endif
  ret i64 0

cond:                                             ; preds = %body, %else
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %storage_value9
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %48 = load ptr, ptr %3, align 8
  %vector_data10 = getelementptr i64, ptr %41, i64 1
  %index_access = getelementptr i64, ptr %vector_data10, i64 %index_value
  %49 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %48, ptr %49)
  %storage_value11 = load i64, ptr %49, align 4
  %slot_value = load i64, ptr %48, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %48, align 4
  store i64 %storage_value11, ptr %index_access, align 4
  store ptr %48, ptr %3, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %50 = call ptr @vector_new(i64 8)
  %vector_data12 = getelementptr i64, ptr %50, i64 1
  %51 = getelementptr i64, ptr %vector_data12, i64 0
  call void @get_context_data(ptr %51, i64 13)
  %52 = getelementptr i64, ptr %vector_data12, i64 1
  call void @get_context_data(ptr %52, i64 14)
  %53 = getelementptr i64, ptr %vector_data12, i64 2
  call void @get_context_data(ptr %53, i64 15)
  %54 = getelementptr i64, ptr %vector_data12, i64 3
  call void @get_context_data(ptr %54, i64 16)
  %55 = getelementptr i64, ptr %vector_data12, i64 4
  call void @get_context_data(ptr %55, i64 17)
  %56 = getelementptr i64, ptr %vector_data12, i64 5
  call void @get_context_data(ptr %56, i64 18)
  %57 = getelementptr i64, ptr %vector_data12, i64 6
  call void @get_context_data(ptr %57, i64 19)
  %58 = getelementptr i64, ptr %vector_data12, i64 7
  call void @get_context_data(ptr %58, i64 20)
  %59 = call i64 @check_ecdsa(ptr %35, ptr %41, ptr %50)
  %60 = trunc i64 %59 to i1
  br i1 %60, label %then13, label %endif14

then13:                                           ; preds = %done
  %61 = load i64, ptr %magic, align 4
  ret i64 %61

endif14:                                          ; preds = %done
  br label %endif6
}

define ptr @executeTransaction(ptr %0, ptr %1) {
entry:
  %_data = alloca ptr, align 8
  %_to = alloca ptr, align 8
  store ptr %0, ptr %_to, align 8
  store ptr %1, ptr %_data, align 8
  %2 = load ptr, ptr %_data, align 8
  call void @onlyEntrypointCall()
  call void @ignoreDelegateCall()
  %3 = load ptr, ptr %_to, align 8
  %vector_length = load i64, ptr %2, align 4
  %vector_data = getelementptr i64, ptr %2, i64 1
  call void @set_tape_data(ptr %vector_data, i64 %vector_length)
  call void @contract_call(ptr %3, i64 0)
  %4 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %4, i64 1)
  %return_length = load i64, ptr %4, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %5 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %5, align 4
  %return_data_start = getelementptr i64, ptr %5, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  ret ptr %5
}

define void @payForTransaction(ptr %0, ptr %1, ptr %2) {
entry:
  %_tx = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  %_txHash = alloca ptr, align 8
  store ptr %0, ptr %_txHash, align 8
  store ptr %1, ptr %_signedHash, align 8
  store ptr %2, ptr %_tx, align 8
  %3 = load ptr, ptr %_tx, align 8
  call void @onlyEntrypointCall()
  call void @ignoreDelegateCall()
  ret void
}

define void @prepareForPaymaster(ptr %0, ptr %1, ptr %2) {
entry:
  %_tx = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  %_txHash = alloca ptr, align 8
  store ptr %0, ptr %_txHash, align 8
  store ptr %1, ptr %_signedHash, align 8
  store ptr %2, ptr %_tx, align 8
  %3 = load ptr, ptr %_tx, align 8
  call void @onlyEntrypointCall()
  call void @ignoreDelegateCall()
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3726813225, label %func_0_dispatch
    i64 3602345202, label %func_1_dispatch
    i64 3925046215, label %func_2_dispatch
    i64 3825269561, label %func_3_dispatch
    i64 90807469, label %func_4_dispatch
    i64 2244673699, label %func_5_dispatch
    i64 1870522257, label %func_6_dispatch
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
  call void @ignoreDelegateCall()
  %4 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %4, align 4
  call void @set_tape_data(ptr %4, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %5 = getelementptr ptr, ptr %2, i64 0
  %vector_length = load i64, ptr %5, align 4
  %6 = add i64 %vector_length, 1
  call void @setPubkey(ptr %5)
  %7 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %7, align 4
  call void @set_tape_data(ptr %7, i64 1)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %8 = getelementptr ptr, ptr %2, i64 0
  %9 = getelementptr ptr, ptr %8, i64 4
  %10 = getelementptr ptr, ptr %9, i64 4
  %decode_struct_field = getelementptr ptr, ptr %10, i64 0
  %decode_struct_field1 = getelementptr ptr, ptr %10, i64 4
  %decode_struct_field2 = getelementptr ptr, ptr %10, i64 8
  %vector_length3 = load i64, ptr %decode_struct_field2, align 4
  %11 = add i64 %vector_length3, 1
  %decode_struct_offset = add i64 8, %11
  %decode_struct_field4 = getelementptr ptr, ptr %10, i64 %decode_struct_offset
  %vector_length5 = load i64, ptr %decode_struct_field4, align 4
  %12 = add i64 %vector_length5, 1
  %decode_struct_offset6 = add i64 %decode_struct_offset, %12
  %13 = call ptr @heap_malloc(i64 4)
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 0
  store ptr %decode_struct_field, ptr %struct_member, align 8
  %struct_member7 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 1
  store ptr %decode_struct_field1, ptr %struct_member7, align 8
  %struct_member8 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 2
  store ptr %decode_struct_field2, ptr %struct_member8, align 8
  %struct_member9 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 3
  store ptr %decode_struct_field4, ptr %struct_member9, align 8
  %14 = call i64 @validateTransaction(ptr %8, ptr %9, ptr %13)
  %15 = call ptr @heap_malloc(i64 2)
  store i64 %14, ptr %15, align 4
  %16 = getelementptr ptr, ptr %15, i64 1
  store i64 1, ptr %16, align 4
  call void @set_tape_data(ptr %15, i64 2)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %17 = getelementptr ptr, ptr %2, i64 0
  %18 = getelementptr ptr, ptr %17, i64 4
  %vector_length10 = load i64, ptr %18, align 4
  %19 = add i64 %vector_length10, 1
  %20 = call ptr @executeTransaction(ptr %17, ptr %18)
  %vector_length11 = load i64, ptr %20, align 4
  %21 = add i64 %vector_length11, 1
  %heap_size = add i64 %21, 1
  %22 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length12 = load i64, ptr %20, align 4
  %23 = add i64 %vector_length12, 1
  call void @memcpy(ptr %20, ptr %22, i64 %23)
  %24 = getelementptr ptr, ptr %22, i64 %23
  store i64 %21, ptr %24, align 4
  call void @set_tape_data(ptr %22, i64 %heap_size)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %25 = getelementptr ptr, ptr %2, i64 0
  %26 = getelementptr ptr, ptr %25, i64 4
  %27 = getelementptr ptr, ptr %26, i64 4
  %decode_struct_field13 = getelementptr ptr, ptr %27, i64 0
  %decode_struct_field14 = getelementptr ptr, ptr %27, i64 4
  %decode_struct_field15 = getelementptr ptr, ptr %27, i64 8
  %vector_length16 = load i64, ptr %decode_struct_field15, align 4
  %28 = add i64 %vector_length16, 1
  %decode_struct_offset17 = add i64 8, %28
  %decode_struct_field18 = getelementptr ptr, ptr %27, i64 %decode_struct_offset17
  %vector_length19 = load i64, ptr %decode_struct_field18, align 4
  %29 = add i64 %vector_length19, 1
  %decode_struct_offset20 = add i64 %decode_struct_offset17, %29
  %30 = call ptr @heap_malloc(i64 4)
  %struct_member21 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 0
  store ptr %decode_struct_field13, ptr %struct_member21, align 8
  %struct_member22 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 1
  store ptr %decode_struct_field14, ptr %struct_member22, align 8
  %struct_member23 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 2
  store ptr %decode_struct_field15, ptr %struct_member23, align 8
  %struct_member24 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 3
  store ptr %decode_struct_field18, ptr %struct_member24, align 8
  call void @payForTransaction(ptr %25, ptr %26, ptr %30)
  %31 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %31, align 4
  call void @set_tape_data(ptr %31, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %32 = getelementptr ptr, ptr %2, i64 0
  %33 = getelementptr ptr, ptr %32, i64 4
  %34 = getelementptr ptr, ptr %33, i64 4
  %decode_struct_field25 = getelementptr ptr, ptr %34, i64 0
  %decode_struct_field26 = getelementptr ptr, ptr %34, i64 4
  %decode_struct_field27 = getelementptr ptr, ptr %34, i64 8
  %vector_length28 = load i64, ptr %decode_struct_field27, align 4
  %35 = add i64 %vector_length28, 1
  %decode_struct_offset29 = add i64 8, %35
  %decode_struct_field30 = getelementptr ptr, ptr %34, i64 %decode_struct_offset29
  %vector_length31 = load i64, ptr %decode_struct_field30, align 4
  %36 = add i64 %vector_length31, 1
  %decode_struct_offset32 = add i64 %decode_struct_offset29, %36
  %37 = call ptr @heap_malloc(i64 4)
  %struct_member33 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 0
  store ptr %decode_struct_field25, ptr %struct_member33, align 8
  %struct_member34 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 1
  store ptr %decode_struct_field26, ptr %struct_member34, align 8
  %struct_member35 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 2
  store ptr %decode_struct_field27, ptr %struct_member35, align 8
  %struct_member36 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 3
  store ptr %decode_struct_field30, ptr %struct_member36, align 8
  call void @prepareForPaymaster(ptr %32, ptr %33, ptr %37)
  %38 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %38, align 4
  call void @set_tape_data(ptr %38, i64 1)
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
