; ModuleID = 'StringExample'
source_filename = "storage_string"

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

define void @setStringLiteral() {
entry:
  %0 = alloca ptr, align 8
<<<<<<< HEAD
<<<<<<< HEAD
  %index_alloca21 = alloca i64, align 8
=======
  %index_alloca20 = alloca i64, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  %index_alloca21 = alloca i64, align 8
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %1 = alloca ptr, align 8
  %index_alloca8 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %3 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 49, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 50, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 51, ptr %index_access2, align 4
  %4 = call ptr @heap_malloc(i64 4)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 0, ptr %9, align 4
  call void @get_storage(ptr %5, ptr %4)
  %length = getelementptr i64, ptr %4, i64 3
  %10 = load i64, ptr %length, align 4
  %vector_length = load i64, ptr %3, align 4
  %11 = call ptr @heap_malloc(i64 4)
  %12 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %11, i64 3
  store i64 0, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 4)
  %17 = getelementptr i64, ptr %16, i64 0
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %16, i64 1
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %16, i64 2
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %16, i64 3
  store i64 %vector_length, ptr %20, align 4
  call void @set_storage(ptr %11, ptr %16)
  %21 = call ptr @heap_malloc(i64 4)
  %22 = getelementptr i64, ptr %21, i64 0
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %21, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %21, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %21, i64 3
  store i64 0, ptr %25, align 4
  %26 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %21, ptr %26, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %26, ptr %2, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %27 = load ptr, ptr %2, align 8
  %vector_data3 = getelementptr i64, ptr %3, i64 1
  %index_access4 = getelementptr ptr, ptr %vector_data3, i64 %index_value
  %28 = load i64, ptr %index_access4, align 4
  %29 = call ptr @heap_malloc(i64 4)
  %30 = getelementptr i64, ptr %29, i64 0
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %29, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %29, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %29, i64 3
  store i64 %28, ptr %33, align 4
  call void @set_storage(ptr %27, ptr %29)
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %34 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %27, ptr %34, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %34, i64 3
  %35 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %35, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store ptr %34, ptr %2, align 8
<<<<<<< HEAD
=======
  %34 = getelementptr i64, ptr %27, i64 3
  %35 = load i64, ptr %34, align 4
  %slot_offset = add i64 %35, 1
  store i64 %slot_offset, ptr %34, align 4
  store ptr %27, ptr %2, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %vector_length, ptr %index_alloca8, align 4
  store ptr %26, ptr %1, align 8
  br label %cond5

cond5:                                            ; preds = %body6, %done
  %index_value9 = load i64, ptr %index_alloca8, align 4
  %loop_cond10 = icmp ult i64 %index_value9, %10
  br i1 %loop_cond10, label %body6, label %done7

body6:                                            ; preds = %cond5
  %36 = load ptr, ptr %1, align 8
  %37 = call ptr @heap_malloc(i64 4)
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %storage_zero_ptr = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %storage_zero_ptr, align 4
  %storage_zero_ptr11 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %storage_zero_ptr11, align 4
  %storage_zero_ptr12 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %storage_zero_ptr12, align 4
  %storage_zero_ptr13 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %storage_zero_ptr13, align 4
<<<<<<< HEAD
  call void @set_storage(ptr %36, ptr %37)
  %38 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %36, ptr %38, i64 4)
  %last_elem_ptr14 = getelementptr i64, ptr %38, i64 3
  %39 = load i64, ptr %last_elem_ptr14, align 4
  %last_elem15 = add i64 %39, 1
  store i64 %last_elem15, ptr %last_elem_ptr14, align 4
  store ptr %38, ptr %1, align 8
  %next_index16 = add i64 %index_value9, 1
  store i64 %next_index16, ptr %index_alloca8, align 4
=======
  %storage_key_ptr = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr11 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %storage_key_ptr11, align 4
  %storage_key_ptr12 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %storage_key_ptr12, align 4
  %storage_key_ptr13 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %storage_key_ptr13, align 4
  call void @set_storage(ptr %36, ptr %37)
  %38 = getelementptr i64, ptr %36, i64 3
  %39 = load i64, ptr %38, align 4
  %slot_offset14 = add i64 %39, 1
  store i64 %slot_offset14, ptr %38, align 4
  store ptr %36, ptr %1, align 8
  %next_index15 = add i64 %index_value9, 1
  store i64 %next_index15, ptr %index_alloca8, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  call void @set_storage(ptr %36, ptr %37)
  %38 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %36, ptr %38, i64 4)
  %last_elem_ptr14 = getelementptr i64, ptr %38, i64 3
  %39 = load i64, ptr %last_elem_ptr14, align 4
  %last_elem15 = add i64 %39, 1
  store i64 %last_elem15, ptr %last_elem_ptr14, align 4
  store ptr %38, ptr %1, align 8
  %next_index16 = add i64 %index_value9, 1
  store i64 %next_index16, ptr %index_alloca8, align 4
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  br label %cond5

done7:                                            ; preds = %cond5
  %40 = call ptr @heap_malloc(i64 4)
  %41 = call ptr @heap_malloc(i64 4)
  %42 = getelementptr i64, ptr %41, i64 0
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %41, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %41, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %41, i64 3
  store i64 0, ptr %45, align 4
  call void @get_storage(ptr %41, ptr %40)
<<<<<<< HEAD
<<<<<<< HEAD
  %length17 = getelementptr i64, ptr %40, i64 3
  %46 = load i64, ptr %length17, align 4
=======
  %length16 = getelementptr i64, ptr %40, i64 3
  %46 = load i64, ptr %length16, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  %length17 = getelementptr i64, ptr %40, i64 3
  %46 = load i64, ptr %length17, align 4
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %47 = call ptr @vector_new(i64 %46)
  %48 = call ptr @heap_malloc(i64 4)
  %49 = getelementptr i64, ptr %48, i64 0
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %48, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %48, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %48, i64 3
  store i64 0, ptr %52, align 4
  %53 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %48, ptr %53, i64 4)
<<<<<<< HEAD
<<<<<<< HEAD
  store i64 0, ptr %index_alloca21, align 4
  store ptr %53, ptr %0, align 8
  br label %cond18

cond18:                                           ; preds = %body19, %done7
  %index_value22 = load i64, ptr %index_alloca21, align 4
  %loop_cond23 = icmp ult i64 %index_value22, %46
  br i1 %loop_cond23, label %body19, label %done20

body19:                                           ; preds = %cond18
  %54 = load ptr, ptr %0, align 8
  %vector_data24 = getelementptr i64, ptr %47, i64 1
  %index_access25 = getelementptr ptr, ptr %vector_data24, i64 %index_value22
=======
  store i64 0, ptr %index_alloca20, align 4
=======
  store i64 0, ptr %index_alloca21, align 4
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  store ptr %53, ptr %0, align 8
  br label %cond18

cond18:                                           ; preds = %body19, %done7
  %index_value22 = load i64, ptr %index_alloca21, align 4
  %loop_cond23 = icmp ult i64 %index_value22, %46
  br i1 %loop_cond23, label %body19, label %done20

body19:                                           ; preds = %cond18
  %54 = load ptr, ptr %0, align 8
<<<<<<< HEAD
  %vector_data23 = getelementptr i64, ptr %47, i64 1
  %index_access24 = getelementptr ptr, ptr %vector_data23, i64 %index_value21
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  %vector_data24 = getelementptr i64, ptr %47, i64 1
  %index_access25 = getelementptr ptr, ptr %vector_data24, i64 %index_value22
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %55 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %54, ptr %55)
  %56 = getelementptr i64, ptr %55, i64 3
  %storage_value = load i64, ptr %56, align 4
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %57 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %54, ptr %57, i64 4)
  %last_elem_ptr26 = getelementptr i64, ptr %57, i64 3
  %58 = load i64, ptr %last_elem_ptr26, align 4
  %last_elem27 = add i64 %58, 1
  store i64 %last_elem27, ptr %last_elem_ptr26, align 4
  store i64 %storage_value, ptr %index_access25, align 4
  store ptr %57, ptr %0, align 8
  %next_index28 = add i64 %index_value22, 1
  store i64 %next_index28, ptr %index_alloca21, align 4
  br label %cond18
<<<<<<< HEAD

done20:                                           ; preds = %cond18
=======
  %57 = getelementptr i64, ptr %54, i64 3
  %58 = load i64, ptr %57, align 4
  %slot_offset25 = add i64 %58, 1
  store i64 %slot_offset25, ptr %57, align 4
  store i64 %storage_value, ptr %index_access24, align 4
  store ptr %54, ptr %0, align 8
  %next_index26 = add i64 %index_value21, 1
  store i64 %next_index26, ptr %index_alloca20, align 4
  br label %cond17

done19:                                           ; preds = %cond17
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======

done20:                                           ; preds = %cond18
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %string_start = ptrtoint ptr %47 to i64
  call void @prophet_printf(i64 %string_start, i64 1)
  ret void
}

define void @set(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca4 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %s = alloca ptr, align 8
  store ptr %0, ptr %s, align 8
  %3 = load ptr, ptr %s, align 8
  %4 = call ptr @heap_malloc(i64 4)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 0, ptr %9, align 4
  call void @get_storage(ptr %5, ptr %4)
<<<<<<< HEAD
<<<<<<< HEAD
  %length = getelementptr i64, ptr %4, i64 3
  %10 = load i64, ptr %length, align 4
  %vector_length = load i64, ptr %3, align 4
=======
  %10 = getelementptr i64, ptr %4, i64 3
  %storage_value = load i64, ptr %10, align 4
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %length = getelementptr i64, ptr %4, i64 3
  %10 = load i64, ptr %length, align 4
  %vector_length = load i64, ptr %3, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %11 = call ptr @heap_malloc(i64 4)
  %12 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %11, i64 3
  store i64 0, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 4)
  %17 = getelementptr i64, ptr %16, i64 0
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %16, i64 1
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %16, i64 2
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %16, i64 3
  store i64 %vector_length, ptr %20, align 4
  call void @set_storage(ptr %11, ptr %16)
  %21 = call ptr @heap_malloc(i64 4)
  %22 = getelementptr i64, ptr %21, i64 0
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %21, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %21, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %21, i64 3
  store i64 0, ptr %25, align 4
  %26 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %21, ptr %26, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %26, ptr %2, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %27 = load ptr, ptr %2, align 8
  %vector_data = getelementptr i64, ptr %3, i64 1
<<<<<<< HEAD
<<<<<<< HEAD
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
=======
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %28 = load i64, ptr %index_access, align 4
  %29 = call ptr @heap_malloc(i64 4)
  %30 = getelementptr i64, ptr %29, i64 0
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %29, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %29, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %29, i64 3
  store i64 %28, ptr %33, align 4
  call void @set_storage(ptr %27, ptr %29)
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %34 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %27, ptr %34, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %34, i64 3
  %35 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %35, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store ptr %34, ptr %2, align 8
<<<<<<< HEAD
=======
  %34 = getelementptr i64, ptr %27, i64 3
  %35 = load i64, ptr %34, align 4
  %slot_offset = add i64 %35, 1
  store i64 %slot_offset, ptr %34, align 4
  store ptr %27, ptr %2, align 8
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %vector_length, ptr %index_alloca4, align 4
  store ptr %26, ptr %1, align 8
  br label %cond1

cond1:                                            ; preds = %body2, %done
  %index_value5 = load i64, ptr %index_alloca4, align 4
  %loop_cond6 = icmp ult i64 %index_value5, %10
  br i1 %loop_cond6, label %body2, label %done3

body2:                                            ; preds = %cond1
  %36 = load ptr, ptr %1, align 8
  %37 = call ptr @heap_malloc(i64 4)
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %storage_zero_ptr = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %storage_zero_ptr, align 4
  %storage_zero_ptr7 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %storage_zero_ptr7, align 4
  %storage_zero_ptr8 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %storage_zero_ptr8, align 4
  %storage_zero_ptr9 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %storage_zero_ptr9, align 4
<<<<<<< HEAD
  call void @set_storage(ptr %36, ptr %37)
  %38 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %36, ptr %38, i64 4)
  %last_elem_ptr10 = getelementptr i64, ptr %38, i64 3
  %39 = load i64, ptr %last_elem_ptr10, align 4
  %last_elem11 = add i64 %39, 1
  store i64 %last_elem11, ptr %last_elem_ptr10, align 4
  store ptr %38, ptr %1, align 8
  %next_index12 = add i64 %index_value5, 1
  store i64 %next_index12, ptr %index_alloca4, align 4
=======
  %storage_key_ptr = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr7 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %storage_key_ptr7, align 4
  %storage_key_ptr8 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %storage_key_ptr8, align 4
  %storage_key_ptr9 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %storage_key_ptr9, align 4
  call void @set_storage(ptr %36, ptr %37)
  %38 = getelementptr i64, ptr %36, i64 3
  %39 = load i64, ptr %38, align 4
  %slot_offset10 = add i64 %39, 1
  store i64 %slot_offset10, ptr %38, align 4
  store ptr %36, ptr %1, align 8
  %next_index11 = add i64 %index_value5, 1
  store i64 %next_index11, ptr %index_alloca4, align 4
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  call void @set_storage(ptr %36, ptr %37)
  %38 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %36, ptr %38, i64 4)
  %last_elem_ptr10 = getelementptr i64, ptr %38, i64 3
  %39 = load i64, ptr %last_elem_ptr10, align 4
  %last_elem11 = add i64 %39, 1
  store i64 %last_elem11, ptr %last_elem_ptr10, align 4
  store ptr %38, ptr %1, align 8
  %next_index12 = add i64 %index_value5, 1
  store i64 %next_index12, ptr %index_alloca4, align 4
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  br label %cond1

done3:                                            ; preds = %cond1
  ret void
}

<<<<<<< HEAD
<<<<<<< HEAD
=======
define void @setStringLiteral() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca10 = alloca i64, align 8
  %1 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %2 = call ptr @vector_new(i64 5)
  %vector_data = getelementptr i64, ptr %2, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access4, align 4
  %vector_length = load i64, ptr %2, align 4
  %3 = call ptr @heap_malloc(i64 4)
  %4 = call ptr @heap_malloc(i64 4)
  %5 = getelementptr i64, ptr %4, i64 0
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %4, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %4, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %4, i64 3
  store i64 0, ptr %8, align 4
  call void @get_storage(ptr %4, ptr %3)
  %9 = getelementptr i64, ptr %3, i64 3
  %storage_value = load i64, ptr %9, align 4
  %10 = call ptr @heap_malloc(i64 4)
  %11 = getelementptr i64, ptr %10, i64 0
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %10, i64 1
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %10, i64 2
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %10, i64 3
  store i64 0, ptr %14, align 4
  %15 = call ptr @heap_malloc(i64 4)
  %16 = getelementptr i64, ptr %15, i64 0
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %15, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %15, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %15, i64 3
  store i64 %vector_length, ptr %19, align 4
  call void @set_storage(ptr %10, ptr %15)
  %20 = call ptr @heap_malloc(i64 4)
  %21 = getelementptr i64, ptr %20, i64 0
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %20, i64 1
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %20, i64 2
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %20, i64 3
  store i64 0, ptr %24, align 4
  %25 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %20, ptr %25, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %25, ptr %1, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %26 = load ptr, ptr %1, align 8
  %vector_data5 = getelementptr i64, ptr %2, i64 1
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 %index_value
  %27 = load i64, ptr %index_access6, align 4
  %28 = call ptr @heap_malloc(i64 4)
  %29 = getelementptr i64, ptr %28, i64 0
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %28, i64 1
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %28, i64 2
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %28, i64 3
  store i64 %27, ptr %32, align 4
  call void @set_storage(ptr %26, ptr %28)
  %33 = getelementptr i64, ptr %26, i64 3
  %34 = load i64, ptr %33, align 4
  %slot_offset = add i64 %34, 1
  store i64 %slot_offset, ptr %33, align 4
  store ptr %26, ptr %1, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %vector_length, ptr %index_alloca10, align 4
  store ptr %25, ptr %0, align 8
  br label %cond7

cond7:                                            ; preds = %body8, %done
  %index_value11 = load i64, ptr %index_alloca10, align 4
  %loop_cond12 = icmp ult i64 %index_value11, %storage_value
  br i1 %loop_cond12, label %body8, label %done9

body8:                                            ; preds = %cond7
  %35 = load ptr, ptr %0, align 8
  %36 = call ptr @heap_malloc(i64 4)
  %storage_key_ptr = getelementptr i64, ptr %36, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr13 = getelementptr i64, ptr %36, i64 1
  store i64 0, ptr %storage_key_ptr13, align 4
  %storage_key_ptr14 = getelementptr i64, ptr %36, i64 2
  store i64 0, ptr %storage_key_ptr14, align 4
  %storage_key_ptr15 = getelementptr i64, ptr %36, i64 3
  store i64 0, ptr %storage_key_ptr15, align 4
  call void @set_storage(ptr %35, ptr %36)
  %37 = getelementptr i64, ptr %35, i64 3
  %38 = load i64, ptr %37, align 4
  %slot_offset16 = add i64 %38, 1
  store i64 %slot_offset16, ptr %37, align 4
  store ptr %35, ptr %0, align 8
  %next_index17 = add i64 %index_value11, 1
  store i64 %next_index17, ptr %index_alloca10, align 4
  br label %cond7

done9:                                            ; preds = %cond7
  ret void
}

>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
>>>>>>> 7998cf0 (fixed llvm type bug.)
define ptr @get() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %1 = call ptr @heap_malloc(i64 4)
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %2, i64 3
  store i64 0, ptr %6, align 4
  call void @get_storage(ptr %2, ptr %1)
<<<<<<< HEAD
<<<<<<< HEAD
  %length = getelementptr i64, ptr %1, i64 3
  %7 = load i64, ptr %length, align 4
  %8 = call ptr @vector_new(i64 %7)
=======
  %7 = getelementptr i64, ptr %1, i64 3
  %storage_value = load i64, ptr %7, align 4
  %8 = call ptr @vector_new(i64 %storage_value)
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %length = getelementptr i64, ptr %1, i64 3
  %7 = load i64, ptr %length, align 4
  %8 = call ptr @vector_new(i64 %7)
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %9 = call ptr @heap_malloc(i64 4)
  %10 = getelementptr i64, ptr %9, i64 0
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %9, i64 3
  store i64 0, ptr %13, align 4
  %14 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %9, ptr %14, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %14, ptr %0, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %7
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %15 = load ptr, ptr %0, align 8
  %vector_data = getelementptr i64, ptr %8, i64 1
<<<<<<< HEAD
<<<<<<< HEAD
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %16 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %15, ptr %16)
  %17 = getelementptr i64, ptr %16, i64 3
  %storage_value = load i64, ptr %17, align 4
  %18 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %15, ptr %18, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %18, i64 3
  %19 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %19, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
<<<<<<< HEAD
  store i64 %storage_value, ptr %index_access, align 4
  store ptr %18, ptr %0, align 8
=======
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
=======
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %16 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %15, ptr %16)
  %17 = getelementptr i64, ptr %16, i64 3
  %storage_value = load i64, ptr %17, align 4
  %18 = getelementptr i64, ptr %15, i64 3
  %19 = load i64, ptr %18, align 4
  %slot_offset = add i64 %19, 1
  store i64 %slot_offset, ptr %18, align 4
  store i64 %storage_value, ptr %index_access, align 4
  store ptr %15, ptr %0, align 8
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  store i64 %storage_value, ptr %index_access, align 4
  store ptr %18, ptr %0, align 8
>>>>>>> 67fc4e1 (test: 💍 regenerate exmaple ir files)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %8
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1406646302, label %func_0_dispatch
    i64 1322485854, label %func_1_dispatch
    i64 1833756220, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @setStringLiteral()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %4 = getelementptr ptr, ptr %2, i64 0
  %vector_length = load i64, ptr %4, align 4
  %5 = add i64 %vector_length, 1
  call void @set(ptr %4)
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %7 = call ptr @get()
  %vector_length1 = load i64, ptr %7, align 4
  %8 = add i64 %vector_length1, 1
  %heap_size = add i64 %8, 1
  %9 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length2 = load i64, ptr %7, align 4
  %10 = add i64 %vector_length2, 1
  call void @memcpy(ptr %7, ptr %9, i64 %10)
  %11 = getelementptr ptr, ptr %9, i64 %10
  store i64 %8, ptr %11, align 4
  call void @set_tape_data(ptr %9, i64 %heap_size)
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
