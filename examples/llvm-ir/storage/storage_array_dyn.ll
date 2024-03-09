; ModuleID = 's'
source_filename = "storage_array_dyn"

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

declare void @emit_event(ptr, ptr)

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

define ptr @u256_add(ptr %0, ptr %1) {
entry:
  %field_low18 = alloca i64, align 8
  %field_high17 = alloca i64, align 8
  %field_low15 = alloca i64, align 8
  %field_high14 = alloca i64, align 8
  %field_low12 = alloca i64, align 8
  %field_high11 = alloca i64, align 8
  %field_low9 = alloca i64, align 8
  %field_high8 = alloca i64, align 8
  %field_low6 = alloca i64, align 8
  %field_high5 = alloca i64, align 8
  %field_low3 = alloca i64, align 8
  %field_high2 = alloca i64, align 8
  %field_low = alloca i64, align 8
  %field_high = alloca i64, align 8
  %2 = call ptr @heap_malloc(i64 8)
  %3 = getelementptr i64, ptr %0, i64 7
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr i64, ptr %1, i64 7
  %6 = load i64, ptr %5, align 4
  %7 = add i64 %4, %6
  %sum_with_carry = add i64 %7, 0
  call void @split_field(i64 %sum_with_carry, ptr %field_high, ptr %field_low)
  %8 = load i64, ptr %field_high, align 4
  %9 = load i64, ptr %field_low, align 4
  %10 = getelementptr i64, ptr %2, i64 7
  store i64 %9, ptr %10, align 4
  %11 = getelementptr i64, ptr %0, i64 6
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %1, i64 6
  %14 = load i64, ptr %13, align 4
  %15 = add i64 %12, %14
  %sum_with_carry1 = add i64 %15, %8
  call void @split_field(i64 %sum_with_carry1, ptr %field_high2, ptr %field_low3)
  %16 = load i64, ptr %field_high2, align 4
  %17 = load i64, ptr %field_low3, align 4
  %18 = getelementptr i64, ptr %2, i64 6
  store i64 %17, ptr %18, align 4
  %19 = getelementptr i64, ptr %0, i64 5
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %1, i64 5
  %22 = load i64, ptr %21, align 4
  %23 = add i64 %20, %22
  %sum_with_carry4 = add i64 %23, %16
  call void @split_field(i64 %sum_with_carry4, ptr %field_high5, ptr %field_low6)
  %24 = load i64, ptr %field_high5, align 4
  %25 = load i64, ptr %field_low6, align 4
  %26 = getelementptr i64, ptr %2, i64 5
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %0, i64 4
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %1, i64 4
  %30 = load i64, ptr %29, align 4
  %31 = add i64 %28, %30
  %sum_with_carry7 = add i64 %31, %24
  call void @split_field(i64 %sum_with_carry7, ptr %field_high8, ptr %field_low9)
  %32 = load i64, ptr %field_high8, align 4
  %33 = load i64, ptr %field_low9, align 4
  %34 = getelementptr i64, ptr %2, i64 4
  store i64 %33, ptr %34, align 4
  %35 = getelementptr i64, ptr %0, i64 3
  %36 = load i64, ptr %35, align 4
  %37 = getelementptr i64, ptr %1, i64 3
  %38 = load i64, ptr %37, align 4
  %39 = add i64 %36, %38
  %sum_with_carry10 = add i64 %39, %32
  call void @split_field(i64 %sum_with_carry10, ptr %field_high11, ptr %field_low12)
  %40 = load i64, ptr %field_high11, align 4
  %41 = load i64, ptr %field_low12, align 4
  %42 = getelementptr i64, ptr %2, i64 3
  store i64 %41, ptr %42, align 4
  %43 = getelementptr i64, ptr %0, i64 2
  %44 = load i64, ptr %43, align 4
  %45 = getelementptr i64, ptr %1, i64 2
  %46 = load i64, ptr %45, align 4
  %47 = add i64 %44, %46
  %sum_with_carry13 = add i64 %47, %40
  call void @split_field(i64 %sum_with_carry13, ptr %field_high14, ptr %field_low15)
  %48 = load i64, ptr %field_high14, align 4
  %49 = load i64, ptr %field_low15, align 4
  %50 = getelementptr i64, ptr %2, i64 2
  store i64 %49, ptr %50, align 4
  %51 = getelementptr i64, ptr %0, i64 1
  %52 = load i64, ptr %51, align 4
  %53 = getelementptr i64, ptr %1, i64 1
  %54 = load i64, ptr %53, align 4
  %55 = add i64 %52, %54
  %sum_with_carry16 = add i64 %55, %48
  call void @split_field(i64 %sum_with_carry16, ptr %field_high17, ptr %field_low18)
  %56 = load i64, ptr %field_high17, align 4
  %57 = load i64, ptr %field_low18, align 4
  %58 = getelementptr i64, ptr %2, i64 1
  store i64 %57, ptr %58, align 4
  %59 = getelementptr i64, ptr %0, i64 0
  %60 = load i64, ptr %59, align 4
  %61 = getelementptr i64, ptr %1, i64 0
  %62 = load i64, ptr %61, align 4
  %63 = add i64 %60, %62
  %sum_with_carry19 = add i64 %63, %56
  call void @builtin_range_check(i64 %sum_with_carry19)
  %64 = getelementptr i64, ptr %2, i64 0
  store i64 %sum_with_carry19, ptr %64, align 4
  ret ptr %2
}

define ptr @u256_sub(ptr %0, ptr %1) {
entry:
  %2 = call ptr @heap_malloc(i64 8)
  %3 = getelementptr i64, ptr %0, i64 7
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr i64, ptr %1, i64 7
  %6 = load i64, ptr %5, align 4
  %borrow = icmp ugt i64 %6, %4
  %7 = zext i1 %borrow to i64
  %8 = mul i64 %7, 4294967296
  %9 = add i64 %4, %8
  %10 = sub i64 %9, %6
  %11 = getelementptr i64, ptr %2, i64 7
  store i64 %10, ptr %11, align 4
  %12 = getelementptr i64, ptr %0, i64 6
  %13 = load i64, ptr %12, align 4
  %14 = getelementptr i64, ptr %1, i64 6
  %15 = load i64, ptr %14, align 4
  %16 = sub i64 %13, %7
  %borrow1 = icmp ugt i64 %15, %16
  %17 = zext i1 %borrow1 to i64
  %18 = mul i64 %17, 4294967296
  %19 = add i64 %16, %18
  %20 = sub i64 %19, %15
  %21 = getelementptr i64, ptr %2, i64 6
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %0, i64 5
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %1, i64 5
  %25 = load i64, ptr %24, align 4
  %26 = sub i64 %23, %17
  %borrow2 = icmp ugt i64 %25, %26
  %27 = zext i1 %borrow2 to i64
  %28 = mul i64 %27, 4294967296
  %29 = add i64 %26, %28
  %30 = sub i64 %29, %25
  %31 = getelementptr i64, ptr %2, i64 5
  store i64 %30, ptr %31, align 4
  %32 = getelementptr i64, ptr %0, i64 4
  %33 = load i64, ptr %32, align 4
  %34 = getelementptr i64, ptr %1, i64 4
  %35 = load i64, ptr %34, align 4
  %36 = sub i64 %33, %27
  %borrow3 = icmp ugt i64 %35, %36
  %37 = zext i1 %borrow3 to i64
  %38 = mul i64 %37, 4294967296
  %39 = add i64 %36, %38
  %40 = sub i64 %39, %35
  %41 = getelementptr i64, ptr %2, i64 4
  store i64 %40, ptr %41, align 4
  %42 = getelementptr i64, ptr %0, i64 3
  %43 = load i64, ptr %42, align 4
  %44 = getelementptr i64, ptr %1, i64 3
  %45 = load i64, ptr %44, align 4
  %46 = sub i64 %43, %37
  %borrow4 = icmp ugt i64 %45, %46
  %47 = zext i1 %borrow4 to i64
  %48 = mul i64 %47, 4294967296
  %49 = add i64 %46, %48
  %50 = sub i64 %49, %45
  %51 = getelementptr i64, ptr %2, i64 3
  store i64 %50, ptr %51, align 4
  %52 = getelementptr i64, ptr %0, i64 2
  %53 = load i64, ptr %52, align 4
  %54 = getelementptr i64, ptr %1, i64 2
  %55 = load i64, ptr %54, align 4
  %56 = sub i64 %53, %47
  %borrow5 = icmp ugt i64 %55, %56
  %57 = zext i1 %borrow5 to i64
  %58 = mul i64 %57, 4294967296
  %59 = add i64 %56, %58
  %60 = sub i64 %59, %55
  %61 = getelementptr i64, ptr %2, i64 2
  store i64 %60, ptr %61, align 4
  %62 = getelementptr i64, ptr %0, i64 1
  %63 = load i64, ptr %62, align 4
  %64 = getelementptr i64, ptr %1, i64 1
  %65 = load i64, ptr %64, align 4
  %66 = sub i64 %63, %57
  %borrow6 = icmp ugt i64 %65, %66
  %67 = zext i1 %borrow6 to i64
  %68 = mul i64 %67, 4294967296
  %69 = add i64 %66, %68
  %70 = sub i64 %69, %65
  %71 = getelementptr i64, ptr %2, i64 1
  store i64 %70, ptr %71, align 4
  %72 = getelementptr i64, ptr %0, i64 0
  %73 = load i64, ptr %72, align 4
  %74 = getelementptr i64, ptr %1, i64 0
  %75 = load i64, ptr %74, align 4
  %76 = sub i64 %73, %67
  %77 = sub i64 %76, %75
  call void @builtin_range_check(i64 %77)
  %78 = getelementptr i64, ptr %2, i64 0
  store i64 %77, ptr %78, align 4
  ret ptr %2
}

define ptr @u256_bitwise_and(ptr %0, ptr %1) {
entry:
  %2 = call ptr @heap_malloc(i64 8)
  %3 = getelementptr i64, ptr %0, i64 7
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr i64, ptr %1, i64 7
  %6 = load i64, ptr %5, align 4
  %7 = and i64 %4, %6
  %8 = getelementptr i64, ptr %2, i64 7
  store i64 %7, ptr %8, align 4
  %9 = getelementptr i64, ptr %0, i64 6
  %10 = load i64, ptr %9, align 4
  %11 = getelementptr i64, ptr %1, i64 6
  %12 = load i64, ptr %11, align 4
  %13 = and i64 %10, %12
  %14 = getelementptr i64, ptr %2, i64 6
  store i64 %13, ptr %14, align 4
  %15 = getelementptr i64, ptr %0, i64 5
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %1, i64 5
  %18 = load i64, ptr %17, align 4
  %19 = and i64 %16, %18
  %20 = getelementptr i64, ptr %2, i64 5
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %0, i64 4
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %1, i64 4
  %24 = load i64, ptr %23, align 4
  %25 = and i64 %22, %24
  %26 = getelementptr i64, ptr %2, i64 4
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %0, i64 3
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %1, i64 3
  %30 = load i64, ptr %29, align 4
  %31 = and i64 %28, %30
  %32 = getelementptr i64, ptr %2, i64 3
  store i64 %31, ptr %32, align 4
  %33 = getelementptr i64, ptr %0, i64 2
  %34 = load i64, ptr %33, align 4
  %35 = getelementptr i64, ptr %1, i64 2
  %36 = load i64, ptr %35, align 4
  %37 = and i64 %34, %36
  %38 = getelementptr i64, ptr %2, i64 2
  store i64 %37, ptr %38, align 4
  %39 = getelementptr i64, ptr %0, i64 1
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %1, i64 1
  %42 = load i64, ptr %41, align 4
  %43 = and i64 %40, %42
  %44 = getelementptr i64, ptr %2, i64 1
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %0, i64 0
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %1, i64 0
  %48 = load i64, ptr %47, align 4
  %49 = and i64 %46, %48
  %50 = getelementptr i64, ptr %2, i64 0
  store i64 %49, ptr %50, align 4
  ret ptr %2
}

define ptr @u256_bitwise_or(ptr %0, ptr %1) {
entry:
  %2 = call ptr @heap_malloc(i64 8)
  %3 = getelementptr i64, ptr %0, i64 7
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr i64, ptr %1, i64 7
  %6 = load i64, ptr %5, align 4
  %7 = or i64 %4, %6
  %8 = getelementptr i64, ptr %2, i64 7
  store i64 %7, ptr %8, align 4
  %9 = getelementptr i64, ptr %0, i64 6
  %10 = load i64, ptr %9, align 4
  %11 = getelementptr i64, ptr %1, i64 6
  %12 = load i64, ptr %11, align 4
  %13 = or i64 %10, %12
  %14 = getelementptr i64, ptr %2, i64 6
  store i64 %13, ptr %14, align 4
  %15 = getelementptr i64, ptr %0, i64 5
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %1, i64 5
  %18 = load i64, ptr %17, align 4
  %19 = or i64 %16, %18
  %20 = getelementptr i64, ptr %2, i64 5
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %0, i64 4
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %1, i64 4
  %24 = load i64, ptr %23, align 4
  %25 = or i64 %22, %24
  %26 = getelementptr i64, ptr %2, i64 4
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %0, i64 3
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %1, i64 3
  %30 = load i64, ptr %29, align 4
  %31 = or i64 %28, %30
  %32 = getelementptr i64, ptr %2, i64 3
  store i64 %31, ptr %32, align 4
  %33 = getelementptr i64, ptr %0, i64 2
  %34 = load i64, ptr %33, align 4
  %35 = getelementptr i64, ptr %1, i64 2
  %36 = load i64, ptr %35, align 4
  %37 = or i64 %34, %36
  %38 = getelementptr i64, ptr %2, i64 2
  store i64 %37, ptr %38, align 4
  %39 = getelementptr i64, ptr %0, i64 1
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %1, i64 1
  %42 = load i64, ptr %41, align 4
  %43 = or i64 %40, %42
  %44 = getelementptr i64, ptr %2, i64 1
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %0, i64 0
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %1, i64 0
  %48 = load i64, ptr %47, align 4
  %49 = or i64 %46, %48
  %50 = getelementptr i64, ptr %2, i64 0
  store i64 %49, ptr %50, align 4
  ret ptr %2
}

define ptr @u256_bitwise_xor(ptr %0, ptr %1) {
entry:
  %2 = call ptr @heap_malloc(i64 8)
  %3 = getelementptr i64, ptr %0, i64 7
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr i64, ptr %1, i64 7
  %6 = load i64, ptr %5, align 4
  %7 = xor i64 %4, %6
  %8 = getelementptr i64, ptr %2, i64 7
  store i64 %7, ptr %8, align 4
  %9 = getelementptr i64, ptr %0, i64 6
  %10 = load i64, ptr %9, align 4
  %11 = getelementptr i64, ptr %1, i64 6
  %12 = load i64, ptr %11, align 4
  %13 = xor i64 %10, %12
  %14 = getelementptr i64, ptr %2, i64 6
  store i64 %13, ptr %14, align 4
  %15 = getelementptr i64, ptr %0, i64 5
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %1, i64 5
  %18 = load i64, ptr %17, align 4
  %19 = xor i64 %16, %18
  %20 = getelementptr i64, ptr %2, i64 5
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %0, i64 4
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %1, i64 4
  %24 = load i64, ptr %23, align 4
  %25 = xor i64 %22, %24
  %26 = getelementptr i64, ptr %2, i64 4
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %0, i64 3
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %1, i64 3
  %30 = load i64, ptr %29, align 4
  %31 = xor i64 %28, %30
  %32 = getelementptr i64, ptr %2, i64 3
  store i64 %31, ptr %32, align 4
  %33 = getelementptr i64, ptr %0, i64 2
  %34 = load i64, ptr %33, align 4
  %35 = getelementptr i64, ptr %1, i64 2
  %36 = load i64, ptr %35, align 4
  %37 = xor i64 %34, %36
  %38 = getelementptr i64, ptr %2, i64 2
  store i64 %37, ptr %38, align 4
  %39 = getelementptr i64, ptr %0, i64 1
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %1, i64 1
  %42 = load i64, ptr %41, align 4
  %43 = xor i64 %40, %42
  %44 = getelementptr i64, ptr %2, i64 1
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %0, i64 0
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %1, i64 0
  %48 = load i64, ptr %47, align 4
  %49 = xor i64 %46, %48
  %50 = getelementptr i64, ptr %2, i64 0
  store i64 %49, ptr %50, align 4
  ret ptr %2
}

define ptr @u256_bitwise_not(ptr %0) {
entry:
  %1 = call ptr @heap_malloc(i64 8)
  %2 = getelementptr i64, ptr %0, i64 7
  %3 = load i64, ptr %2, align 4
  %4 = sub i64 4294967295, %3
  call void @builtin_range_check(i64 %4)
  %5 = getelementptr i64, ptr %1, i64 7
  store i64 %4, ptr %5, align 4
  %6 = getelementptr i64, ptr %0, i64 6
  %7 = load i64, ptr %6, align 4
  %8 = sub i64 4294967295, %7
  call void @builtin_range_check(i64 %8)
  %9 = getelementptr i64, ptr %1, i64 6
  store i64 %8, ptr %9, align 4
  %10 = getelementptr i64, ptr %0, i64 5
  %11 = load i64, ptr %10, align 4
  %12 = sub i64 4294967295, %11
  call void @builtin_range_check(i64 %12)
  %13 = getelementptr i64, ptr %1, i64 5
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %0, i64 4
  %15 = load i64, ptr %14, align 4
  %16 = sub i64 4294967295, %15
  call void @builtin_range_check(i64 %16)
  %17 = getelementptr i64, ptr %1, i64 4
  store i64 %16, ptr %17, align 4
  %18 = getelementptr i64, ptr %0, i64 3
  %19 = load i64, ptr %18, align 4
  %20 = sub i64 4294967295, %19
  call void @builtin_range_check(i64 %20)
  %21 = getelementptr i64, ptr %1, i64 3
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %0, i64 2
  %23 = load i64, ptr %22, align 4
  %24 = sub i64 4294967295, %23
  call void @builtin_range_check(i64 %24)
  %25 = getelementptr i64, ptr %1, i64 2
  store i64 %24, ptr %25, align 4
  %26 = getelementptr i64, ptr %0, i64 1
  %27 = load i64, ptr %26, align 4
  %28 = sub i64 4294967295, %27
  call void @builtin_range_check(i64 %28)
  %29 = getelementptr i64, ptr %1, i64 1
  store i64 %28, ptr %29, align 4
  %30 = getelementptr i64, ptr %0, i64 0
  %31 = load i64, ptr %30, align 4
  %32 = sub i64 4294967295, %31
  call void @builtin_range_check(i64 %32)
  %33 = getelementptr i64, ptr %1, i64 0
  store i64 %32, ptr %33, align 4
  ret ptr %1
}

define void @test() {
entry:
  %v = alloca i64, align 8
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
<<<<<<< HEAD
  %6 = getelementptr i64, ptr %2, i64 3
  store i64 0, ptr %6, align 4
  call void @get_storage(ptr %2, ptr %1)
<<<<<<< HEAD
<<<<<<< HEAD
  %length = getelementptr i64, ptr %1, i64 3
  %7 = load i64, ptr %length, align 4
=======
  %7 = getelementptr i64, ptr %1, i64 3
  %storage_value = load i64, ptr %7, align 4
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %length = getelementptr i64, ptr %1, i64 3
  %7 = load i64, ptr %length, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %8 = call ptr @heap_malloc(i64 4)
  %9 = getelementptr i64, ptr %8, i64 0
=======
  call void @get_storage(ptr %1, ptr %0)
  %length = getelementptr i64, ptr %0, i64 3
  %6 = load i64, ptr %length, align 4
  %7 = call ptr @heap_malloc(i64 4)
  %8 = getelementptr i64, ptr %7, i64 0
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %7, i64 1
>>>>>>> 483a314 (fix: 🐛 fixed some u256 type bugs)
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %7, i64 3
  store i64 0, ptr %11, align 4
<<<<<<< HEAD
  %12 = getelementptr i64, ptr %8, i64 3
  store i64 0, ptr %12, align 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %8, ptr %13, i64 4)
  %hash_value_low = getelementptr i64, ptr %13, i64 3
  %14 = load i64, ptr %hash_value_low, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  %15 = mul i64 %7, 1
=======
  %15 = mul i64 %storage_value, 1
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %15 = mul i64 %7, 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %storage_array_offset = add i64 %14, %15
=======
  %12 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %7, ptr %12, i64 4)
  %hash_value_low = getelementptr i64, ptr %12, i64 3
  %13 = load i64, ptr %hash_value_low, align 4
  %14 = mul i64 %6, 1
  %storage_array_offset = add i64 %13, %14
>>>>>>> 483a314 (fix: 🐛 fixed some u256 type bugs)
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %15 = call ptr @heap_malloc(i64 4)
  %16 = getelementptr i64, ptr %15, i64 0
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %15, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %15, i64 2
  store i64 0, ptr %18, align 4
<<<<<<< HEAD
  %19 = getelementptr i64, ptr %17, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %17, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %17, i64 3
  store i64 %16, ptr %21, align 4
  call void @set_storage(ptr %13, ptr %17)
<<<<<<< HEAD
<<<<<<< HEAD
  %new_length = add i64 %7, 1
=======
  %new_length = add i64 %storage_value, 1
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %new_length = add i64 %7, 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %22 = call ptr @heap_malloc(i64 4)
  %23 = getelementptr i64, ptr %22, i64 0
=======
  %19 = getelementptr i64, ptr %15, i64 3
  store i64 128, ptr %19, align 4
  call void @set_storage(ptr %12, ptr %15)
  %new_length = add i64 %6, 1
  %20 = call ptr @heap_malloc(i64 4)
  %21 = getelementptr i64, ptr %20, i64 0
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %20, i64 1
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %20, i64 2
>>>>>>> 483a314 (fix: 🐛 fixed some u256 type bugs)
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %20, i64 3
  store i64 0, ptr %24, align 4
  %25 = call ptr @heap_malloc(i64 4)
  %26 = getelementptr i64, ptr %25, i64 0
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %25, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %25, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %25, i64 3
  store i64 %new_length, ptr %29, align 4
  call void @set_storage(ptr %20, ptr %25)
  %30 = call ptr @heap_malloc(i64 4)
  %31 = call ptr @heap_malloc(i64 4)
  %32 = getelementptr i64, ptr %31, i64 0
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %31, i64 1
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %31, i64 2
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %31, i64 3
  store i64 0, ptr %35, align 4
  call void @get_storage(ptr %31, ptr %30)
  %length1 = getelementptr i64, ptr %30, i64 3
  %36 = load i64, ptr %length1, align 4
  %37 = call ptr @heap_malloc(i64 4)
  %38 = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %41, align 4
  %42 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %37, ptr %42, i64 4)
  %hash_value_low2 = getelementptr i64, ptr %42, i64 3
  %43 = load i64, ptr %hash_value_low2, align 4
  %44 = mul i64 %36, 1
  %storage_array_offset3 = add i64 %43, %44
  store i64 %storage_array_offset3, ptr %hash_value_low2, align 4
  %new_length4 = add i64 %36, 1
  %45 = call ptr @heap_malloc(i64 4)
  %46 = getelementptr i64, ptr %45, i64 0
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %45, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %45, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %45, i64 3
  store i64 0, ptr %49, align 4
  %50 = call ptr @heap_malloc(i64 4)
  %51 = getelementptr i64, ptr %50, i64 0
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %50, i64 1
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %50, i64 2
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %50, i64 3
  store i64 %new_length4, ptr %54, align 4
  call void @set_storage(ptr %45, ptr %50)
  %55 = call ptr @heap_malloc(i64 4)
  %56 = call ptr @heap_malloc(i64 4)
  %57 = getelementptr i64, ptr %56, i64 0
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %56, i64 1
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %56, i64 2
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %56, i64 3
  store i64 0, ptr %60, align 4
  call void @get_storage(ptr %56, ptr %55)
  %61 = getelementptr i64, ptr %55, i64 3
  %storage_value = load i64, ptr %61, align 4
  %62 = icmp eq i64 %storage_value, 2
  %63 = zext i1 %62 to i64
  call void @builtin_assert(i64 %63)
  %64 = call ptr @heap_malloc(i64 4)
  %65 = call ptr @heap_malloc(i64 4)
  %66 = getelementptr i64, ptr %65, i64 0
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %65, i64 1
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %65, i64 2
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %65, i64 3
  store i64 0, ptr %69, align 4
  call void @get_storage(ptr %65, ptr %64)
  %70 = getelementptr i64, ptr %64, i64 3
  %storage_value5 = load i64, ptr %70, align 4
  %71 = sub i64 %storage_value5, 1
  %72 = sub i64 %71, 0
  call void @builtin_range_check(i64 %72)
  %73 = call ptr @heap_malloc(i64 4)
  %74 = getelementptr i64, ptr %73, i64 0
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %73, i64 1
  store i64 0, ptr %75, align 4
  %76 = getelementptr i64, ptr %73, i64 2
  store i64 0, ptr %76, align 4
  %77 = getelementptr i64, ptr %73, i64 3
  store i64 0, ptr %77, align 4
  %78 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %73, ptr %78, i64 4)
  %hash_value_low6 = getelementptr i64, ptr %78, i64 3
  %79 = load i64, ptr %hash_value_low6, align 4
  %storage_array_offset7 = add i64 %79, 0
  store i64 %storage_array_offset7, ptr %hash_value_low6, align 4
  %80 = call ptr @heap_malloc(i64 4)
  %81 = call ptr @heap_malloc(i64 4)
  %82 = getelementptr i64, ptr %81, i64 0
  store i64 0, ptr %82, align 4
  %83 = getelementptr i64, ptr %81, i64 1
  store i64 0, ptr %83, align 4
  %84 = getelementptr i64, ptr %81, i64 2
  store i64 0, ptr %84, align 4
  %85 = getelementptr i64, ptr %81, i64 3
  store i64 0, ptr %85, align 4
  call void @get_storage(ptr %81, ptr %80)
  %86 = getelementptr i64, ptr %80, i64 3
  %storage_value8 = load i64, ptr %86, align 4
  %87 = sub i64 %storage_value8, 1
  %88 = sub i64 %87, 0
  call void @builtin_range_check(i64 %88)
  %89 = call ptr @heap_malloc(i64 4)
  %90 = getelementptr i64, ptr %89, i64 0
  store i64 0, ptr %90, align 4
  %91 = getelementptr i64, ptr %89, i64 1
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %89, i64 2
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %89, i64 3
  store i64 0, ptr %93, align 4
  %94 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %89, ptr %94, i64 4)
  %hash_value_low9 = getelementptr i64, ptr %94, i64 3
  %95 = load i64, ptr %hash_value_low9, align 4
  %storage_array_offset10 = add i64 %95, 0
  store i64 %storage_array_offset10, ptr %hash_value_low9, align 4
  %96 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %94, ptr %96)
  %97 = getelementptr i64, ptr %96, i64 3
  %storage_value11 = load i64, ptr %97, align 4
  %98 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %94, ptr %98, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %98, i64 3
  %99 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %99, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %100 = or i64 %storage_value11, 64
  %101 = call ptr @heap_malloc(i64 4)
  %102 = getelementptr i64, ptr %101, i64 0
  store i64 0, ptr %102, align 4
  %103 = getelementptr i64, ptr %101, i64 1
  store i64 0, ptr %103, align 4
  %104 = getelementptr i64, ptr %101, i64 2
  store i64 0, ptr %104, align 4
  %105 = getelementptr i64, ptr %101, i64 3
  store i64 %100, ptr %105, align 4
  call void @set_storage(ptr %78, ptr %101)
  %106 = call ptr @heap_malloc(i64 4)
  %107 = call ptr @heap_malloc(i64 4)
  %108 = getelementptr i64, ptr %107, i64 0
  store i64 0, ptr %108, align 4
  %109 = getelementptr i64, ptr %107, i64 1
  store i64 0, ptr %109, align 4
  %110 = getelementptr i64, ptr %107, i64 2
  store i64 0, ptr %110, align 4
  %111 = getelementptr i64, ptr %107, i64 3
  store i64 0, ptr %111, align 4
  call void @get_storage(ptr %107, ptr %106)
  %length12 = getelementptr i64, ptr %106, i64 3
  %112 = load i64, ptr %length12, align 4
  %113 = call ptr @heap_malloc(i64 4)
  %114 = getelementptr i64, ptr %113, i64 0
  store i64 0, ptr %114, align 4
  %115 = getelementptr i64, ptr %113, i64 1
  store i64 0, ptr %115, align 4
  %116 = getelementptr i64, ptr %113, i64 2
  store i64 0, ptr %116, align 4
  %117 = getelementptr i64, ptr %113, i64 3
  store i64 0, ptr %117, align 4
  %118 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %113, ptr %118, i64 4)
  %hash_value_low13 = getelementptr i64, ptr %118, i64 3
  %119 = load i64, ptr %hash_value_low13, align 4
  %120 = mul i64 %112, 1
  %storage_array_offset14 = add i64 %119, %120
  store i64 %storage_array_offset14, ptr %hash_value_low13, align 4
  %121 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %118, ptr %121)
  %122 = getelementptr i64, ptr %121, i64 3
  %storage_value15 = load i64, ptr %122, align 4
  %123 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %118, ptr %123, i64 4)
  %last_elem_ptr16 = getelementptr i64, ptr %123, i64 3
  %124 = load i64, ptr %last_elem_ptr16, align 4
  %last_elem17 = add i64 %124, 1
  store i64 %last_elem17, ptr %last_elem_ptr16, align 4
  %125 = call ptr @heap_malloc(i64 4)
  %storage_zero_ptr = getelementptr i64, ptr %125, i64 0
  store i64 0, ptr %storage_zero_ptr, align 4
  %storage_zero_ptr18 = getelementptr i64, ptr %125, i64 1
  store i64 0, ptr %storage_zero_ptr18, align 4
  %storage_zero_ptr19 = getelementptr i64, ptr %125, i64 2
  store i64 0, ptr %storage_zero_ptr19, align 4
  %storage_zero_ptr20 = getelementptr i64, ptr %125, i64 3
  store i64 0, ptr %storage_zero_ptr20, align 4
  call void @set_storage(ptr %118, ptr %125)
  %new_length21 = sub i64 %112, 1
  %126 = call ptr @heap_malloc(i64 4)
  %127 = getelementptr i64, ptr %126, i64 0
  store i64 0, ptr %127, align 4
  %128 = getelementptr i64, ptr %126, i64 1
  store i64 0, ptr %128, align 4
  %129 = getelementptr i64, ptr %126, i64 2
  store i64 0, ptr %129, align 4
  %130 = getelementptr i64, ptr %126, i64 3
  store i64 0, ptr %130, align 4
  %131 = call ptr @heap_malloc(i64 4)
  %132 = getelementptr i64, ptr %131, i64 0
  store i64 0, ptr %132, align 4
  %133 = getelementptr i64, ptr %131, i64 1
  store i64 0, ptr %133, align 4
  %134 = getelementptr i64, ptr %131, i64 2
  store i64 0, ptr %134, align 4
  %135 = getelementptr i64, ptr %131, i64 3
  store i64 %new_length21, ptr %135, align 4
  call void @set_storage(ptr %126, ptr %131)
  %136 = call ptr @heap_malloc(i64 4)
  %137 = call ptr @heap_malloc(i64 4)
  %138 = getelementptr i64, ptr %137, i64 0
  store i64 0, ptr %138, align 4
  %139 = getelementptr i64, ptr %137, i64 1
  store i64 0, ptr %139, align 4
  %140 = getelementptr i64, ptr %137, i64 2
  store i64 0, ptr %140, align 4
  %141 = getelementptr i64, ptr %137, i64 3
  store i64 0, ptr %141, align 4
  call void @get_storage(ptr %137, ptr %136)
  %length22 = getelementptr i64, ptr %136, i64 3
  %142 = load i64, ptr %length22, align 4
  %143 = call ptr @heap_malloc(i64 4)
  %144 = getelementptr i64, ptr %143, i64 0
  store i64 0, ptr %144, align 4
  %145 = getelementptr i64, ptr %143, i64 1
  store i64 0, ptr %145, align 4
  %146 = getelementptr i64, ptr %143, i64 2
  store i64 0, ptr %146, align 4
  %147 = getelementptr i64, ptr %143, i64 3
  store i64 0, ptr %147, align 4
  %148 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %143, ptr %148, i64 4)
  %hash_value_low23 = getelementptr i64, ptr %148, i64 3
  %149 = load i64, ptr %hash_value_low23, align 4
  %150 = mul i64 %142, 1
  %storage_array_offset24 = add i64 %149, %150
  store i64 %storage_array_offset24, ptr %hash_value_low23, align 4
  %151 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %148, ptr %151)
  %152 = getelementptr i64, ptr %151, i64 3
  %storage_value25 = load i64, ptr %152, align 4
  %153 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %148, ptr %153, i64 4)
  %last_elem_ptr26 = getelementptr i64, ptr %153, i64 3
  %154 = load i64, ptr %last_elem_ptr26, align 4
  %last_elem27 = add i64 %154, 1
  store i64 %last_elem27, ptr %last_elem_ptr26, align 4
  %155 = call ptr @heap_malloc(i64 4)
  %storage_zero_ptr28 = getelementptr i64, ptr %155, i64 0
  store i64 0, ptr %storage_zero_ptr28, align 4
  %storage_zero_ptr29 = getelementptr i64, ptr %155, i64 1
  store i64 0, ptr %storage_zero_ptr29, align 4
  %storage_zero_ptr30 = getelementptr i64, ptr %155, i64 2
  store i64 0, ptr %storage_zero_ptr30, align 4
  %storage_zero_ptr31 = getelementptr i64, ptr %155, i64 3
  store i64 0, ptr %storage_zero_ptr31, align 4
  call void @set_storage(ptr %148, ptr %155)
  %new_length32 = sub i64 %142, 1
  %156 = call ptr @heap_malloc(i64 4)
  %157 = getelementptr i64, ptr %156, i64 0
  store i64 0, ptr %157, align 4
  %158 = getelementptr i64, ptr %156, i64 1
  store i64 0, ptr %158, align 4
  %159 = getelementptr i64, ptr %156, i64 2
  store i64 0, ptr %159, align 4
  %160 = getelementptr i64, ptr %156, i64 3
  store i64 0, ptr %160, align 4
  %161 = call ptr @heap_malloc(i64 4)
  %162 = getelementptr i64, ptr %161, i64 0
  store i64 0, ptr %162, align 4
  %163 = getelementptr i64, ptr %161, i64 1
  store i64 0, ptr %163, align 4
  %164 = getelementptr i64, ptr %161, i64 2
  store i64 0, ptr %164, align 4
  %165 = getelementptr i64, ptr %161, i64 3
  store i64 %new_length32, ptr %165, align 4
  call void @set_storage(ptr %156, ptr %161)
  store i64 %storage_value25, ptr %v, align 4
  %166 = load i64, ptr %v, align 4
  %167 = icmp eq i64 %166, 192
  %168 = zext i1 %167 to i64
  call void @builtin_assert(i64 %168)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 4171824493, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @test()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
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
