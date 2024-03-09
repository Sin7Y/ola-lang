; ModuleID = 'Voting'
source_filename = "vote"

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

define void @contract_init(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca12 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %3 = load ptr, ptr %proposalNames_, align 8
  %4 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %4, i64 12)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 0, ptr %9, align 4
  call void @set_storage(ptr %5, ptr %4)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %10 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %3, align 4
  %11 = icmp ult i64 %10, %vector_length
  br i1 %11, label %body, label %endfor

body:                                             ; preds = %cond
  %12 = call ptr @heap_malloc(i64 4)
  %13 = call ptr @heap_malloc(i64 4)
  %14 = getelementptr i64, ptr %13, i64 0
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %13, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %13, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %13, i64 3
  store i64 2, ptr %17, align 4
  call void @get_storage(ptr %13, ptr %12)
  %length = getelementptr i64, ptr %12, i64 3
  %18 = load i64, ptr %length, align 4
  %19 = call ptr @heap_malloc(i64 4)
  %20 = getelementptr i64, ptr %19, i64 0
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %19, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %19, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %19, i64 3
  store i64 2, ptr %23, align 4
  %24 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %19, ptr %24, i64 4)
  %hash_value_low = getelementptr i64, ptr %24, i64 3
  %25 = load i64, ptr %hash_value_low, align 4
  %26 = mul i64 %18, 2
  %storage_array_offset = add i64 %25, %26
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %27 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 0
  %28 = load i64, ptr %i, align 4
  %vector_length1 = load i64, ptr %3, align 4
  %29 = sub i64 %vector_length1, 1
  %30 = sub i64 %29, %28
  call void @builtin_range_check(i64 %30)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %28
  %31 = load ptr, ptr %index_access, align 8
  store ptr %31, ptr %struct_member, align 8
  %struct_member2 = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 1
  store i64 0, ptr %struct_member2, align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 0
  %32 = load ptr, ptr %name, align 8
  %33 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %24, ptr %33)
  %length3 = getelementptr i64, ptr %33, i64 3
  %34 = load i64, ptr %length3, align 4
  %vector_length4 = load i64, ptr %32, align 4
  %35 = call ptr @heap_malloc(i64 4)
  %36 = getelementptr i64, ptr %35, i64 0
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %35, i64 1
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %35, i64 2
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %35, i64 3
  store i64 %vector_length4, ptr %39, align 4
  call void @set_storage(ptr %24, ptr %35)
  %40 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %24, ptr %40, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %40, ptr %2, align 8
  br label %cond5

next:                                             ; preds = %done11
  %41 = load i64, ptr %i, align 4
  %42 = add i64 %41, 1
  store i64 %42, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond5:                                            ; preds = %body6, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length4
  br i1 %loop_cond, label %body6, label %done

body6:                                            ; preds = %cond5
  %43 = load ptr, ptr %2, align 8
  %vector_data7 = getelementptr i64, ptr %32, i64 1
  %index_access8 = getelementptr ptr, ptr %vector_data7, i64 %index_value
  %44 = load i64, ptr %index_access8, align 4
  %45 = call ptr @heap_malloc(i64 4)
  %46 = getelementptr i64, ptr %45, i64 0
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %45, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %45, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %45, i64 3
  store i64 %44, ptr %49, align 4
  call void @set_storage(ptr %43, ptr %45)
  %50 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %43, ptr %50, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %50, i64 3
  %51 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %51, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store ptr %50, ptr %2, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond5

done:                                             ; preds = %cond5
  store i64 %vector_length4, ptr %index_alloca12, align 4
  store ptr %40, ptr %1, align 8
  br label %cond9

cond9:                                            ; preds = %body10, %done
  %index_value13 = load i64, ptr %index_alloca12, align 4
  %loop_cond14 = icmp ult i64 %index_value13, %34
  br i1 %loop_cond14, label %body10, label %done11

body10:                                           ; preds = %cond9
  %52 = load ptr, ptr %1, align 8
  %53 = call ptr @heap_malloc(i64 4)
  %storage_zero_ptr = getelementptr i64, ptr %53, i64 0
  store i64 0, ptr %storage_zero_ptr, align 4
  %storage_zero_ptr15 = getelementptr i64, ptr %53, i64 1
  store i64 0, ptr %storage_zero_ptr15, align 4
  %storage_zero_ptr16 = getelementptr i64, ptr %53, i64 2
  store i64 0, ptr %storage_zero_ptr16, align 4
  %storage_zero_ptr17 = getelementptr i64, ptr %53, i64 3
  store i64 0, ptr %storage_zero_ptr17, align 4
  call void @set_storage(ptr %52, ptr %53)
  %54 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %52, ptr %54, i64 4)
  %last_elem_ptr18 = getelementptr i64, ptr %54, i64 3
  %55 = load i64, ptr %last_elem_ptr18, align 4
  %last_elem19 = add i64 %55, 1
  store i64 %last_elem19, ptr %last_elem_ptr18, align 4
  store ptr %54, ptr %1, align 8
  %next_index20 = add i64 %index_value13, 1
  store i64 %next_index20, ptr %index_alloca12, align 4
  br label %cond9

done11:                                           ; preds = %cond9
  %56 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %24, ptr %56, i64 4)
  %last_elem_ptr21 = getelementptr i64, ptr %56, i64 3
  %57 = load i64, ptr %last_elem_ptr21, align 4
  %last_elem22 = add i64 %57, 1
  store i64 %last_elem22, ptr %last_elem_ptr21, align 4
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 1
  %58 = load i64, ptr %voteCount, align 4
  %59 = call ptr @heap_malloc(i64 4)
  %60 = getelementptr i64, ptr %59, i64 0
  store i64 0, ptr %60, align 4
  %61 = getelementptr i64, ptr %59, i64 1
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %59, i64 2
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %59, i64 3
  store i64 %58, ptr %63, align 4
  call void @set_storage(ptr %56, ptr %59)
  %new_length = add i64 %18, 1
  %64 = call ptr @heap_malloc(i64 4)
  %65 = getelementptr i64, ptr %64, i64 0
  store i64 0, ptr %65, align 4
  %66 = getelementptr i64, ptr %64, i64 1
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %64, i64 2
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %64, i64 3
  store i64 2, ptr %68, align 4
  %69 = call ptr @heap_malloc(i64 4)
  %70 = getelementptr i64, ptr %69, i64 0
  store i64 0, ptr %70, align 4
  %71 = getelementptr i64, ptr %69, i64 1
  store i64 0, ptr %71, align 4
  %72 = getelementptr i64, ptr %69, i64 2
  store i64 0, ptr %72, align 4
  %73 = getelementptr i64, ptr %69, i64 3
  store i64 %new_length, ptr %73, align 4
  call void @set_storage(ptr %64, ptr %69)
  br label %next
}

define void @vote_proposal(i64 %0) {
entry:
  %sender = alloca i64, align 8
  %msgSender = alloca ptr, align 8
  %proposal_ = alloca i64, align 8
  store i64 %0, ptr %proposal_, align 4
  %1 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %1, i64 12)
  store ptr %1, ptr %msgSender, align 8
  %2 = load ptr, ptr %msgSender, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 1, ptr %7, align 4
  %8 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %3, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = getelementptr i64, ptr %9, i64 4
  %11 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %8, ptr %11, i64 8)
  store ptr %11, ptr %sender, align 8
  %12 = load i64, ptr %sender, align 4
  %slot_offset = add i64 %12, 0
  %13 = call ptr @heap_malloc(i64 4)
  %14 = getelementptr i64, ptr %13, i64 0
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %13, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %13, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %13, i64 3
  store i64 %slot_offset, ptr %17, align 4
  %18 = call ptr @heap_malloc(i64 4)
  %19 = getelementptr i64, ptr %18, i64 0
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %18, i64 1
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %18, i64 2
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %18, i64 3
  store i64 1, ptr %22, align 4
  call void @set_storage(ptr %13, ptr %18)
  %23 = load i64, ptr %sender, align 4
  %slot_offset1 = add i64 %23, 1
  %24 = load i64, ptr %proposal_, align 4
  %25 = call ptr @heap_malloc(i64 4)
  %26 = getelementptr i64, ptr %25, i64 0
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %25, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %25, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %25, i64 3
  store i64 %slot_offset1, ptr %29, align 4
  %30 = call ptr @heap_malloc(i64 4)
  %31 = getelementptr i64, ptr %30, i64 0
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %30, i64 1
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %30, i64 2
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %30, i64 3
  store i64 %24, ptr %34, align 4
  call void @set_storage(ptr %25, ptr %30)
  %35 = load i64, ptr %proposal_, align 4
  %36 = call ptr @heap_malloc(i64 4)
  %37 = call ptr @heap_malloc(i64 4)
  %38 = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %37, i64 3
  store i64 2, ptr %41, align 4
  call void @get_storage(ptr %37, ptr %36)
  %42 = getelementptr i64, ptr %36, i64 3
  %storage_value = load i64, ptr %42, align 4
  %43 = sub i64 %storage_value, 1
  %44 = sub i64 %43, %35
  call void @builtin_range_check(i64 %44)
  %45 = call ptr @heap_malloc(i64 4)
  %46 = getelementptr i64, ptr %45, i64 0
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %45, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %45, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %45, i64 3
  store i64 2, ptr %49, align 4
  %50 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %45, ptr %50, i64 4)
  %hash_value_low = getelementptr i64, ptr %50, i64 3
  %51 = load i64, ptr %hash_value_low, align 4
  %52 = mul i64 %35, 2
  %storage_array_offset = add i64 %51, %52
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %53 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %50, ptr %53, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %53, i64 3
  %54 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %54, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %55 = load i64, ptr %proposal_, align 4
  %56 = call ptr @heap_malloc(i64 4)
  %57 = call ptr @heap_malloc(i64 4)
  %58 = getelementptr i64, ptr %57, i64 0
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %57, i64 1
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %57, i64 2
  store i64 0, ptr %60, align 4
  %61 = getelementptr i64, ptr %57, i64 3
  store i64 2, ptr %61, align 4
  call void @get_storage(ptr %57, ptr %56)
  %62 = getelementptr i64, ptr %56, i64 3
  %storage_value2 = load i64, ptr %62, align 4
  %63 = sub i64 %storage_value2, 1
  %64 = sub i64 %63, %55
  call void @builtin_range_check(i64 %64)
  %65 = call ptr @heap_malloc(i64 4)
  %66 = getelementptr i64, ptr %65, i64 0
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %65, i64 1
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %65, i64 2
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %65, i64 3
  store i64 2, ptr %69, align 4
  %70 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %65, ptr %70, i64 4)
  %hash_value_low3 = getelementptr i64, ptr %70, i64 3
  %71 = load i64, ptr %hash_value_low3, align 4
  %72 = mul i64 %55, 2
  %storage_array_offset4 = add i64 %71, %72
  store i64 %storage_array_offset4, ptr %hash_value_low3, align 4
  %73 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %70, ptr %73, i64 4)
  %last_elem_ptr5 = getelementptr i64, ptr %73, i64 3
  %74 = load i64, ptr %last_elem_ptr5, align 4
  %last_elem6 = add i64 %74, 1
  store i64 %last_elem6, ptr %last_elem_ptr5, align 4
  %75 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %73, ptr %75)
  %76 = getelementptr i64, ptr %75, i64 3
  %storage_value7 = load i64, ptr %76, align 4
  %77 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %73, ptr %77, i64 4)
  %last_elem_ptr8 = getelementptr i64, ptr %77, i64 3
  %78 = load i64, ptr %last_elem_ptr8, align 4
  %last_elem9 = add i64 %78, 1
  store i64 %last_elem9, ptr %last_elem_ptr8, align 4
  %79 = add i64 %storage_value7, 1
  call void @builtin_range_check(i64 %79)
  %80 = call ptr @heap_malloc(i64 4)
  %81 = getelementptr i64, ptr %80, i64 0
  store i64 0, ptr %81, align 4
  %82 = getelementptr i64, ptr %80, i64 1
  store i64 0, ptr %82, align 4
  %83 = getelementptr i64, ptr %80, i64 2
  store i64 0, ptr %83, align 4
  %84 = getelementptr i64, ptr %80, i64 3
  store i64 %79, ptr %84, align 4
  call void @set_storage(ptr %53, ptr %80)
  ret void
}

define i64 @winningProposal() {
entry:
  %p = alloca i64, align 8
  %winningVoteCount = alloca i64, align 8
  %winningProposal_ = alloca i64, align 8
  store i64 0, ptr %winningProposal_, align 4
  store i64 0, ptr %winningVoteCount, align 4
  store i64 0, ptr %p, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %0 = load i64, ptr %p, align 4
  %1 = call ptr @heap_malloc(i64 4)
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %2, i64 3
  store i64 2, ptr %6, align 4
  call void @get_storage(ptr %2, ptr %1)
  %7 = getelementptr i64, ptr %1, i64 3
  %storage_value = load i64, ptr %7, align 4
  %8 = icmp ult i64 %0, %storage_value
  br i1 %8, label %body, label %endfor

body:                                             ; preds = %cond
  %9 = load i64, ptr %p, align 4
  %10 = call ptr @heap_malloc(i64 4)
  %11 = call ptr @heap_malloc(i64 4)
  %12 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %11, i64 3
  store i64 2, ptr %15, align 4
  call void @get_storage(ptr %11, ptr %10)
  %16 = getelementptr i64, ptr %10, i64 3
  %storage_value1 = load i64, ptr %16, align 4
  %17 = sub i64 %storage_value1, 1
  %18 = sub i64 %17, %9
  call void @builtin_range_check(i64 %18)
  %19 = call ptr @heap_malloc(i64 4)
  %20 = getelementptr i64, ptr %19, i64 0
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %19, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %19, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %19, i64 3
  store i64 2, ptr %23, align 4
  %24 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %19, ptr %24, i64 4)
  %hash_value_low = getelementptr i64, ptr %24, i64 3
  %25 = load i64, ptr %hash_value_low, align 4
  %26 = mul i64 %9, 2
  %storage_array_offset = add i64 %25, %26
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %27 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %24, ptr %27, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %27, i64 3
  %28 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %28, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %29 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %27, ptr %29)
  %30 = getelementptr i64, ptr %29, i64 3
  %storage_value2 = load i64, ptr %30, align 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %27, ptr %31, i64 4)
  %last_elem_ptr3 = getelementptr i64, ptr %31, i64 3
  %32 = load i64, ptr %last_elem_ptr3, align 4
  %last_elem4 = add i64 %32, 1
  store i64 %last_elem4, ptr %last_elem_ptr3, align 4
  %33 = load i64, ptr %winningVoteCount, align 4
  %34 = icmp ugt i64 %storage_value2, %33
  br i1 %34, label %then, label %endif

next:                                             ; preds = %endif
  %35 = load i64, ptr %p, align 4
  %36 = add i64 %35, 1
  store i64 %36, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %37 = load i64, ptr %winningProposal_, align 4
  ret i64 %37

then:                                             ; preds = %body
  %38 = load i64, ptr %p, align 4
  %39 = call ptr @heap_malloc(i64 4)
  %40 = call ptr @heap_malloc(i64 4)
  %41 = getelementptr i64, ptr %40, i64 0
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %40, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %40, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %40, i64 3
  store i64 2, ptr %44, align 4
  call void @get_storage(ptr %40, ptr %39)
  %45 = getelementptr i64, ptr %39, i64 3
  %storage_value5 = load i64, ptr %45, align 4
  %46 = sub i64 %storage_value5, 1
  %47 = sub i64 %46, %38
  call void @builtin_range_check(i64 %47)
  %48 = call ptr @heap_malloc(i64 4)
  %49 = getelementptr i64, ptr %48, i64 0
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %48, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %48, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %48, i64 3
  store i64 2, ptr %52, align 4
  %53 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %48, ptr %53, i64 4)
  %hash_value_low6 = getelementptr i64, ptr %53, i64 3
  %54 = load i64, ptr %hash_value_low6, align 4
  %55 = mul i64 %38, 2
  %storage_array_offset7 = add i64 %54, %55
  store i64 %storage_array_offset7, ptr %hash_value_low6, align 4
  %56 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %53, ptr %56, i64 4)
  %last_elem_ptr8 = getelementptr i64, ptr %56, i64 3
  %57 = load i64, ptr %last_elem_ptr8, align 4
  %last_elem9 = add i64 %57, 1
  store i64 %last_elem9, ptr %last_elem_ptr8, align 4
  %58 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %56, ptr %58)
  %59 = getelementptr i64, ptr %58, i64 3
  %storage_value10 = load i64, ptr %59, align 4
  %60 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %56, ptr %60, i64 4)
  %last_elem_ptr11 = getelementptr i64, ptr %60, i64 3
  %61 = load i64, ptr %last_elem_ptr11, align 4
  %last_elem12 = add i64 %61, 1
  store i64 %last_elem12, ptr %last_elem_ptr11, align 4
  store i64 %storage_value10, ptr %winningVoteCount, align 4
  %62 = load i64, ptr %p, align 4
  store i64 %62, ptr %winningProposal_, align 4
  br label %endif

endif:                                            ; preds = %then, %body
  br label %next
}

define ptr @getWinnerName() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @winningProposal()
  %2 = call ptr @heap_malloc(i64 4)
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 2, ptr %7, align 4
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
  store i64 2, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %11, ptr %16, i64 4)
  %hash_value_low = getelementptr i64, ptr %16, i64 3
  %17 = load i64, ptr %hash_value_low, align 4
  %18 = mul i64 %1, 2
  %storage_array_offset = add i64 %17, %18
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %19, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %19, i64 3
  %20 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %20, 0
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %21 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %19, ptr %21)
  %length = getelementptr i64, ptr %21, i64 3
  %22 = load i64, ptr %length, align 4
  %23 = call ptr @vector_new(i64 %22)
  %24 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %19, ptr %24, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %24, ptr %0, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %22
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %25 = load ptr, ptr %0, align 8
  %vector_data = getelementptr i64, ptr %23, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %26 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %25, ptr %26)
  %27 = getelementptr i64, ptr %26, i64 3
  %storage_value1 = load i64, ptr %27, align 4
  %28 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %25, ptr %28, i64 4)
  %last_elem_ptr2 = getelementptr i64, ptr %28, i64 3
  %29 = load i64, ptr %last_elem_ptr2, align 4
  %last_elem3 = add i64 %29, 1
  store i64 %last_elem3, ptr %last_elem_ptr2, align 4
  store i64 %storage_value1, ptr %index_access, align 4
  store ptr %28, ptr %0, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %30 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %19, ptr %30, i64 4)
  %last_elem_ptr4 = getelementptr i64, ptr %30, i64 3
  %31 = load i64, ptr %last_elem_ptr4, align 4
  %last_elem5 = add i64 %31, 1
  store i64 %last_elem5, ptr %last_elem_ptr4, align 4
  ret ptr %23
}

define void @vote_test() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca82 = alloca i64, align 8
  %1 = alloca ptr, align 8
  %index_alloca63 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca54 = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %3 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %4 = call ptr @vector_new(i64 0)
  store ptr %4, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_length = load i64, ptr %3, align 4
  %5 = sub i64 %vector_length, 1
  %6 = sub i64 %5, 0
  call void @builtin_range_check(i64 %6)
  %vector_data1 = getelementptr i64, ptr %3, i64 1
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %7 = call ptr @vector_new(i64 10)
  %vector_data3 = getelementptr i64, ptr %7, i64 1
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 0
  store i64 80, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data3, i64 1
  store i64 114, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data3, i64 2
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data3, i64 3
  store i64 112, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data3, i64 4
  store i64 111, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data3, i64 5
  store i64 115, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data3, i64 6
  store i64 97, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data3, i64 7
  store i64 108, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data3, i64 8
  store i64 95, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data3, i64 9
  store i64 49, ptr %index_access13, align 4
  store ptr %7, ptr %index_access2, align 8
  %vector_length14 = load i64, ptr %3, align 4
  %8 = sub i64 %vector_length14, 1
  %9 = sub i64 %8, 1
  call void @builtin_range_check(i64 %9)
  %vector_data15 = getelementptr i64, ptr %3, i64 1
  %index_access16 = getelementptr ptr, ptr %vector_data15, i64 1
  %10 = call ptr @vector_new(i64 10)
  %vector_data17 = getelementptr i64, ptr %10, i64 1
  %index_access18 = getelementptr i64, ptr %vector_data17, i64 0
  store i64 80, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %vector_data17, i64 1
  store i64 114, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %vector_data17, i64 2
  store i64 111, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %vector_data17, i64 3
  store i64 112, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %vector_data17, i64 4
  store i64 111, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data17, i64 5
  store i64 115, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %vector_data17, i64 6
  store i64 97, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %vector_data17, i64 7
  store i64 108, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %vector_data17, i64 8
  store i64 95, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %vector_data17, i64 9
  store i64 50, ptr %index_access27, align 4
  store ptr %10, ptr %index_access16, align 8
  %vector_length28 = load i64, ptr %3, align 4
  %11 = sub i64 %vector_length28, 1
  %12 = sub i64 %11, 2
  call void @builtin_range_check(i64 %12)
  %vector_data29 = getelementptr i64, ptr %3, i64 1
  %index_access30 = getelementptr ptr, ptr %vector_data29, i64 2
  %13 = call ptr @vector_new(i64 10)
  %vector_data31 = getelementptr i64, ptr %13, i64 1
  %index_access32 = getelementptr i64, ptr %vector_data31, i64 0
  store i64 80, ptr %index_access32, align 4
  %index_access33 = getelementptr i64, ptr %vector_data31, i64 1
  store i64 114, ptr %index_access33, align 4
  %index_access34 = getelementptr i64, ptr %vector_data31, i64 2
  store i64 111, ptr %index_access34, align 4
  %index_access35 = getelementptr i64, ptr %vector_data31, i64 3
  store i64 112, ptr %index_access35, align 4
  %index_access36 = getelementptr i64, ptr %vector_data31, i64 4
  store i64 111, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %vector_data31, i64 5
  store i64 115, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %vector_data31, i64 6
  store i64 97, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %vector_data31, i64 7
  store i64 108, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %vector_data31, i64 8
  store i64 95, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %vector_data31, i64 9
  store i64 51, ptr %index_access41, align 4
  store ptr %13, ptr %index_access30, align 8
  store i64 0, ptr %i, align 4
  br label %cond42

cond42:                                           ; preds = %next, %done
  %14 = load i64, ptr %i, align 4
  %vector_length44 = load i64, ptr %3, align 4
  %15 = icmp ult i64 %14, %vector_length44
  br i1 %15, label %body43, label %endfor

body43:                                           ; preds = %cond42
  %16 = call ptr @heap_malloc(i64 4)
  %17 = call ptr @heap_malloc(i64 4)
  %18 = getelementptr i64, ptr %17, i64 0
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %17, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %17, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %17, i64 3
  store i64 2, ptr %21, align 4
  call void @get_storage(ptr %17, ptr %16)
  %length = getelementptr i64, ptr %16, i64 3
  %22 = load i64, ptr %length, align 4
  %23 = call ptr @heap_malloc(i64 4)
  %24 = getelementptr i64, ptr %23, i64 0
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %23, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %23, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %23, i64 3
  store i64 2, ptr %27, align 4
  %28 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %23, ptr %28, i64 4)
  %hash_value_low = getelementptr i64, ptr %28, i64 3
  %29 = load i64, ptr %hash_value_low, align 4
  %30 = mul i64 %22, 2
  %storage_array_offset = add i64 %29, %30
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %31 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { ptr, i64 }, ptr %31, i32 0, i32 0
  %32 = load i64, ptr %i, align 4
  %vector_length45 = load i64, ptr %3, align 4
  %33 = sub i64 %vector_length45, 1
  %34 = sub i64 %33, %32
  call void @builtin_range_check(i64 %34)
  %vector_data46 = getelementptr i64, ptr %3, i64 1
  %index_access47 = getelementptr ptr, ptr %vector_data46, i64 %32
  %35 = load ptr, ptr %index_access47, align 8
  store ptr %35, ptr %struct_member, align 8
  %struct_member48 = getelementptr inbounds { ptr, i64 }, ptr %31, i32 0, i32 1
  %36 = load i64, ptr %i, align 4
  store i64 %36, ptr %struct_member48, align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %31, i32 0, i32 0
  %37 = load ptr, ptr %name, align 8
  %38 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %28, ptr %38)
  %length49 = getelementptr i64, ptr %38, i64 3
  %39 = load i64, ptr %length49, align 4
  %vector_length50 = load i64, ptr %37, align 4
  %40 = call ptr @heap_malloc(i64 4)
  %41 = getelementptr i64, ptr %40, i64 0
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %40, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %40, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %40, i64 3
  store i64 %vector_length50, ptr %44, align 4
  call void @set_storage(ptr %28, ptr %40)
  %45 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %28, ptr %45, i64 4)
  store i64 0, ptr %index_alloca54, align 4
  store ptr %45, ptr %2, align 8
  br label %cond51

next:                                             ; preds = %done62
  %46 = load i64, ptr %i, align 4
  %47 = add i64 %46, 1
  store i64 %47, ptr %i, align 4
  br label %cond42

endfor:                                           ; preds = %cond42
  %48 = call ptr @heap_malloc(i64 4)
  %49 = call ptr @heap_malloc(i64 4)
  %50 = getelementptr i64, ptr %49, i64 0
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %49, i64 1
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %49, i64 2
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %49, i64 3
  store i64 2, ptr %53, align 4
  call void @get_storage(ptr %49, ptr %48)
  %54 = getelementptr i64, ptr %48, i64 3
  %storage_value = load i64, ptr %54, align 4
  %55 = sub i64 %storage_value, 1
  %56 = sub i64 %55, 0
  call void @builtin_range_check(i64 %56)
  %57 = call ptr @heap_malloc(i64 4)
  %58 = getelementptr i64, ptr %57, i64 0
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %57, i64 1
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %57, i64 2
  store i64 0, ptr %60, align 4
  %61 = getelementptr i64, ptr %57, i64 3
  store i64 2, ptr %61, align 4
  %62 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %57, ptr %62, i64 4)
  %hash_value_low74 = getelementptr i64, ptr %62, i64 3
  %63 = load i64, ptr %hash_value_low74, align 4
  %storage_array_offset75 = add i64 %63, 0
  store i64 %storage_array_offset75, ptr %hash_value_low74, align 4
  %64 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %62, ptr %64, i64 4)
  %last_elem_ptr76 = getelementptr i64, ptr %64, i64 3
  %65 = load i64, ptr %last_elem_ptr76, align 4
  %last_elem77 = add i64 %65, 0
  store i64 %last_elem77, ptr %last_elem_ptr76, align 4
  %66 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %64, ptr %66)
  %length78 = getelementptr i64, ptr %66, i64 3
  %67 = load i64, ptr %length78, align 4
  %68 = call ptr @vector_new(i64 %67)
  %69 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %64, ptr %69, i64 4)
  store i64 0, ptr %index_alloca82, align 4
  store ptr %69, ptr %0, align 8
  br label %cond79

cond51:                                           ; preds = %body52, %body43
  %index_value55 = load i64, ptr %index_alloca54, align 4
  %loop_cond56 = icmp ult i64 %index_value55, %vector_length50
  br i1 %loop_cond56, label %body52, label %done53

body52:                                           ; preds = %cond51
  %70 = load ptr, ptr %2, align 8
  %vector_data57 = getelementptr i64, ptr %37, i64 1
  %index_access58 = getelementptr ptr, ptr %vector_data57, i64 %index_value55
  %71 = load i64, ptr %index_access58, align 4
  %72 = call ptr @heap_malloc(i64 4)
  %73 = getelementptr i64, ptr %72, i64 0
  store i64 0, ptr %73, align 4
  %74 = getelementptr i64, ptr %72, i64 1
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %72, i64 2
  store i64 0, ptr %75, align 4
  %76 = getelementptr i64, ptr %72, i64 3
  store i64 %71, ptr %76, align 4
  call void @set_storage(ptr %70, ptr %72)
  %77 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %70, ptr %77, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %77, i64 3
  %78 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %78, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store ptr %77, ptr %2, align 8
  %next_index59 = add i64 %index_value55, 1
  store i64 %next_index59, ptr %index_alloca54, align 4
  br label %cond51

done53:                                           ; preds = %cond51
  store i64 %vector_length50, ptr %index_alloca63, align 4
  store ptr %45, ptr %1, align 8
  br label %cond60

cond60:                                           ; preds = %body61, %done53
  %index_value64 = load i64, ptr %index_alloca63, align 4
  %loop_cond65 = icmp ult i64 %index_value64, %39
  br i1 %loop_cond65, label %body61, label %done62

body61:                                           ; preds = %cond60
  %79 = load ptr, ptr %1, align 8
  %80 = call ptr @heap_malloc(i64 4)
  %storage_zero_ptr = getelementptr i64, ptr %80, i64 0
  store i64 0, ptr %storage_zero_ptr, align 4
  %storage_zero_ptr66 = getelementptr i64, ptr %80, i64 1
  store i64 0, ptr %storage_zero_ptr66, align 4
  %storage_zero_ptr67 = getelementptr i64, ptr %80, i64 2
  store i64 0, ptr %storage_zero_ptr67, align 4
  %storage_zero_ptr68 = getelementptr i64, ptr %80, i64 3
  store i64 0, ptr %storage_zero_ptr68, align 4
  call void @set_storage(ptr %79, ptr %80)
  %81 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %79, ptr %81, i64 4)
  %last_elem_ptr69 = getelementptr i64, ptr %81, i64 3
  %82 = load i64, ptr %last_elem_ptr69, align 4
  %last_elem70 = add i64 %82, 1
  store i64 %last_elem70, ptr %last_elem_ptr69, align 4
  store ptr %81, ptr %1, align 8
  %next_index71 = add i64 %index_value64, 1
  store i64 %next_index71, ptr %index_alloca63, align 4
  br label %cond60

done62:                                           ; preds = %cond60
  %83 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %28, ptr %83, i64 4)
  %last_elem_ptr72 = getelementptr i64, ptr %83, i64 3
  %84 = load i64, ptr %last_elem_ptr72, align 4
  %last_elem73 = add i64 %84, 1
  store i64 %last_elem73, ptr %last_elem_ptr72, align 4
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %31, i32 0, i32 1
  %85 = load i64, ptr %voteCount, align 4
  %86 = call ptr @heap_malloc(i64 4)
  %87 = getelementptr i64, ptr %86, i64 0
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %86, i64 1
  store i64 0, ptr %88, align 4
  %89 = getelementptr i64, ptr %86, i64 2
  store i64 0, ptr %89, align 4
  %90 = getelementptr i64, ptr %86, i64 3
  store i64 %85, ptr %90, align 4
  call void @set_storage(ptr %83, ptr %86)
  %new_length = add i64 %22, 1
  %91 = call ptr @heap_malloc(i64 4)
  %92 = getelementptr i64, ptr %91, i64 0
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %91, i64 1
  store i64 0, ptr %93, align 4
  %94 = getelementptr i64, ptr %91, i64 2
  store i64 0, ptr %94, align 4
  %95 = getelementptr i64, ptr %91, i64 3
  store i64 2, ptr %95, align 4
  %96 = call ptr @heap_malloc(i64 4)
  %97 = getelementptr i64, ptr %96, i64 0
  store i64 0, ptr %97, align 4
  %98 = getelementptr i64, ptr %96, i64 1
  store i64 0, ptr %98, align 4
  %99 = getelementptr i64, ptr %96, i64 2
  store i64 0, ptr %99, align 4
  %100 = getelementptr i64, ptr %96, i64 3
  store i64 %new_length, ptr %100, align 4
  call void @set_storage(ptr %91, ptr %96)
  br label %next

cond79:                                           ; preds = %body80, %endfor
  %index_value83 = load i64, ptr %index_alloca82, align 4
  %loop_cond84 = icmp ult i64 %index_value83, %67
  br i1 %loop_cond84, label %body80, label %done81

body80:                                           ; preds = %cond79
  %101 = load ptr, ptr %0, align 8
  %vector_data85 = getelementptr i64, ptr %68, i64 1
  %index_access86 = getelementptr ptr, ptr %vector_data85, i64 %index_value83
  %102 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %101, ptr %102)
  %103 = getelementptr i64, ptr %102, i64 3
  %storage_value87 = load i64, ptr %103, align 4
  %104 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %101, ptr %104, i64 4)
  %last_elem_ptr88 = getelementptr i64, ptr %104, i64 3
  %105 = load i64, ptr %last_elem_ptr88, align 4
  %last_elem89 = add i64 %105, 1
  store i64 %last_elem89, ptr %last_elem_ptr88, align 4
  store i64 %storage_value87, ptr %index_access86, align 4
  store ptr %104, ptr %0, align 8
  %next_index90 = add i64 %index_value83, 1
  store i64 %next_index90, ptr %index_alloca82, align 4
  br label %cond79

done81:                                           ; preds = %cond79
  %106 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %64, ptr %106, i64 4)
  %last_elem_ptr91 = getelementptr i64, ptr %106, i64 3
  %107 = load i64, ptr %last_elem_ptr91, align 4
  %last_elem92 = add i64 %107, 1
  store i64 %last_elem92, ptr %last_elem_ptr91, align 4
  %vector_length93 = load i64, ptr %68, align 4
  %vector_data94 = getelementptr i64, ptr %68, i64 1
  %108 = call ptr @vector_new(i64 10)
  %vector_data95 = getelementptr i64, ptr %108, i64 1
  %index_access96 = getelementptr i64, ptr %vector_data95, i64 0
  store i64 80, ptr %index_access96, align 4
  %index_access97 = getelementptr i64, ptr %vector_data95, i64 1
  store i64 114, ptr %index_access97, align 4
  %index_access98 = getelementptr i64, ptr %vector_data95, i64 2
  store i64 111, ptr %index_access98, align 4
  %index_access99 = getelementptr i64, ptr %vector_data95, i64 3
  store i64 112, ptr %index_access99, align 4
  %index_access100 = getelementptr i64, ptr %vector_data95, i64 4
  store i64 111, ptr %index_access100, align 4
  %index_access101 = getelementptr i64, ptr %vector_data95, i64 5
  store i64 115, ptr %index_access101, align 4
  %index_access102 = getelementptr i64, ptr %vector_data95, i64 6
  store i64 97, ptr %index_access102, align 4
  %index_access103 = getelementptr i64, ptr %vector_data95, i64 7
  store i64 108, ptr %index_access103, align 4
  %index_access104 = getelementptr i64, ptr %vector_data95, i64 8
  store i64 95, ptr %index_access104, align 4
  %index_access105 = getelementptr i64, ptr %vector_data95, i64 9
  store i64 49, ptr %index_access105, align 4
  %vector_length106 = load i64, ptr %108, align 4
  %vector_data107 = getelementptr i64, ptr %108, i64 1
  %109 = icmp eq i64 %vector_length93, %vector_length106
  %110 = zext i1 %109 to i64
  call void @builtin_assert(i64 %110)
  %111 = call i64 @memcmp_eq(ptr %vector_data94, ptr %vector_data107, i64 %vector_length93)
  call void @builtin_assert(i64 %111)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 3912413929, label %func_0_dispatch
    i64 597976998, label %func_1_dispatch
    i64 1621094845, label %func_2_dispatch
    i64 738043157, label %func_3_dispatch
    i64 665853700, label %func_4_dispatch
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
  %vector_length1 = load i64, ptr %12, align 4
  %13 = add i64 %vector_length1, 1
  %14 = load ptr, ptr %array_ptr, align 8
  %array_index = load i64, ptr %index_ptr, align 4
  %vector_length2 = load i64, ptr %14, align 4
  %15 = sub i64 %vector_length2, 1
  %16 = sub i64 %15, %array_index
  call void @builtin_range_check(i64 %16)
  %vector_data = getelementptr i64, ptr %14, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  store ptr %12, ptr %index_access, align 8
  %17 = add i64 %13, %11
  store i64 %17, ptr %offset_var, align 4
  br label %next

next:                                             ; preds = %body
  %index = load i64, ptr %index_ptr, align 4
  %18 = add i64 %index, 1
  store i64 %18, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %19 = load ptr, ptr %array_ptr, align 8
  %20 = load i64, ptr %offset_var, align 4
  call void @contract_init(ptr %19)
  %21 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %21, align 4
  call void @set_tape_data(ptr %21, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %22 = getelementptr ptr, ptr %2, i64 0
  %23 = load i64, ptr %22, align 4
  call void @vote_proposal(i64 %23)
  %24 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %24, align 4
  call void @set_tape_data(ptr %24, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %25 = call i64 @winningProposal()
  %26 = call ptr @heap_malloc(i64 2)
  store i64 %25, ptr %26, align 4
  %27 = getelementptr ptr, ptr %26, i64 1
  store i64 1, ptr %27, align 4
  call void @set_tape_data(ptr %26, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %28 = call ptr @getWinnerName()
  %vector_length3 = load i64, ptr %28, align 4
  %29 = add i64 %vector_length3, 1
  %heap_size = add i64 %29, 1
  %30 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length4 = load i64, ptr %28, align 4
  %31 = add i64 %vector_length4, 1
  call void @memcpy(ptr %28, ptr %30, i64 %31)
  %32 = getelementptr ptr, ptr %30, i64 %31
  store i64 %29, ptr %32, align 4
  call void @set_tape_data(ptr %30, i64 %heap_size)
  ret void

func_4_dispatch:                                  ; preds = %entry
  call void @vote_test()
  %33 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %33, align 4
  call void @set_tape_data(ptr %33, i64 1)
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
