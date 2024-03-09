; ModuleID = 'Voting'
source_filename = "vote_simple"

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
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %1 = load ptr, ptr %proposalNames_, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %2 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %1, align 4
  %3 = icmp ult i64 %2, %vector_length
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = call ptr @heap_malloc(i64 4)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 1, ptr %9, align 4
  call void @get_storage(ptr %5, ptr %4)
  %length = getelementptr i64, ptr %4, i64 3
  %10 = load i64, ptr %length, align 4
  %11 = call ptr @heap_malloc(i64 4)
  %12 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %11, i64 3
  store i64 1, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %11, ptr %16, i64 4)
  %hash_value_low = getelementptr i64, ptr %16, i64 3
  %17 = load i64, ptr %hash_value_low, align 4
  %18 = mul i64 %10, 2
  %storage_array_offset = add i64 %17, %18
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %19 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %19, i32 0, i32 0
  %20 = load i64, ptr %i, align 4
  %vector_length1 = load i64, ptr %1, align 4
  %21 = sub i64 %vector_length1, 1
  %22 = sub i64 %21, %20
  call void @builtin_range_check(i64 %22)
  %vector_data = getelementptr i64, ptr %1, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 %20
  %23 = load i64, ptr %index_access, align 4
  store i64 %23, ptr %struct_member, align 4
  %struct_member2 = getelementptr inbounds { i64, i64 }, ptr %19, i32 0, i32 1
  store i64 0, ptr %struct_member2, align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %19, i32 0, i32 0
  %24 = load i64, ptr %name, align 4
  %25 = call ptr @heap_malloc(i64 4)
  %26 = getelementptr i64, ptr %25, i64 0
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %25, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %25, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %25, i64 3
  store i64 %24, ptr %29, align 4
  call void @set_storage(ptr %16, ptr %25)
  %30 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %30, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %30, i64 3
  %31 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %31, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %19, i32 0, i32 1
  %32 = load i64, ptr %voteCount, align 4
  %33 = call ptr @heap_malloc(i64 4)
  %34 = getelementptr i64, ptr %33, i64 0
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %33, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %33, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %33, i64 3
  store i64 %32, ptr %37, align 4
  call void @set_storage(ptr %30, ptr %33)
  %new_length = add i64 %10, 1
  %38 = call ptr @heap_malloc(i64 4)
  %39 = getelementptr i64, ptr %38, i64 0
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %38, i64 1
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %38, i64 2
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %38, i64 3
  store i64 1, ptr %42, align 4
  %43 = call ptr @heap_malloc(i64 4)
  %44 = getelementptr i64, ptr %43, i64 0
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %43, i64 1
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %43, i64 2
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %43, i64 3
  store i64 %new_length, ptr %47, align 4
  call void @set_storage(ptr %38, ptr %43)
  %48 = load i64, ptr %i, align 4
  %49 = call ptr @heap_malloc(i64 4)
  %50 = call ptr @heap_malloc(i64 4)
  %51 = getelementptr i64, ptr %50, i64 0
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %50, i64 1
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %50, i64 2
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %50, i64 3
  store i64 1, ptr %54, align 4
  call void @get_storage(ptr %50, ptr %49)
  %55 = getelementptr i64, ptr %49, i64 3
  %storage_value = load i64, ptr %55, align 4
  %56 = sub i64 %storage_value, 1
  %57 = sub i64 %56, %48
  call void @builtin_range_check(i64 %57)
  %58 = call ptr @heap_malloc(i64 4)
  %59 = getelementptr i64, ptr %58, i64 0
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %58, i64 1
  store i64 0, ptr %60, align 4
  %61 = getelementptr i64, ptr %58, i64 2
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %58, i64 3
  store i64 1, ptr %62, align 4
  %63 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %58, ptr %63, i64 4)
  %hash_value_low3 = getelementptr i64, ptr %63, i64 3
  %64 = load i64, ptr %hash_value_low3, align 4
  %65 = mul i64 %48, 2
  %storage_array_offset4 = add i64 %64, %65
  store i64 %storage_array_offset4, ptr %hash_value_low3, align 4
  %66 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %63, ptr %66, i64 4)
  %last_elem_ptr5 = getelementptr i64, ptr %66, i64 3
  %67 = load i64, ptr %last_elem_ptr5, align 4
  %last_elem6 = add i64 %67, 0
  store i64 %last_elem6, ptr %last_elem_ptr5, align 4
  %68 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %66, ptr %68)
  %69 = getelementptr i64, ptr %68, i64 3
  %storage_value7 = load i64, ptr %69, align 4
  %70 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %66, ptr %70, i64 4)
  %last_elem_ptr8 = getelementptr i64, ptr %70, i64 3
  %71 = load i64, ptr %last_elem_ptr8, align 4
  %last_elem9 = add i64 %71, 1
  store i64 %last_elem9, ptr %last_elem_ptr8, align 4
  call void @prophet_printf(i64 %storage_value7, i64 3)
  br label %next

next:                                             ; preds = %body
  %72 = load i64, ptr %i, align 4
  %73 = add i64 %72, 1
  store i64 %73, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
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
  store i64 0, ptr %7, align 4
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
  %14 = call ptr @heap_malloc(i64 4)
  %15 = getelementptr i64, ptr %14, i64 0
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %14, i64 1
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %14, i64 2
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %14, i64 3
  store i64 %slot_offset, ptr %18, align 4
  call void @get_storage(ptr %14, ptr %13)
  %19 = getelementptr i64, ptr %13, i64 3
  %storage_value = load i64, ptr %19, align 4
  %slot_offset1 = add i64 %slot_offset, 1
  %20 = icmp eq i64 %storage_value, 0
  %21 = zext i1 %20 to i64
  call void @builtin_assert(i64 %21)
  %22 = load i64, ptr %sender, align 4
  %slot_offset2 = add i64 %22, 0
  %23 = call ptr @heap_malloc(i64 4)
  %24 = getelementptr i64, ptr %23, i64 0
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %23, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %23, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %23, i64 3
  store i64 %slot_offset2, ptr %27, align 4
  %28 = call ptr @heap_malloc(i64 4)
  %29 = getelementptr i64, ptr %28, i64 0
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %28, i64 1
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %28, i64 2
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %28, i64 3
  store i64 1, ptr %32, align 4
  call void @set_storage(ptr %23, ptr %28)
  %33 = load i64, ptr %sender, align 4
  %slot_offset3 = add i64 %33, 1
  %34 = load i64, ptr %proposal_, align 4
  %35 = call ptr @heap_malloc(i64 4)
  %36 = getelementptr i64, ptr %35, i64 0
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %35, i64 1
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %35, i64 2
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %35, i64 3
  store i64 %slot_offset3, ptr %39, align 4
  %40 = call ptr @heap_malloc(i64 4)
  %41 = getelementptr i64, ptr %40, i64 0
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %40, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %40, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %40, i64 3
  store i64 %34, ptr %44, align 4
  call void @set_storage(ptr %35, ptr %40)
  %45 = load i64, ptr %proposal_, align 4
  %46 = call ptr @heap_malloc(i64 4)
  %47 = call ptr @heap_malloc(i64 4)
  %48 = getelementptr i64, ptr %47, i64 0
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %47, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %47, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %47, i64 3
  store i64 1, ptr %51, align 4
  call void @get_storage(ptr %47, ptr %46)
  %52 = getelementptr i64, ptr %46, i64 3
  %storage_value4 = load i64, ptr %52, align 4
  %53 = sub i64 %storage_value4, 1
  %54 = sub i64 %53, %45
  call void @builtin_range_check(i64 %54)
  %55 = call ptr @heap_malloc(i64 4)
  %56 = getelementptr i64, ptr %55, i64 0
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %55, i64 1
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %55, i64 2
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %55, i64 3
  store i64 1, ptr %59, align 4
  %60 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %55, ptr %60, i64 4)
  %hash_value_low = getelementptr i64, ptr %60, i64 3
  %61 = load i64, ptr %hash_value_low, align 4
  %62 = mul i64 %45, 2
  %storage_array_offset = add i64 %61, %62
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %63 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %60, ptr %63, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %63, i64 3
  %64 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %64, 0
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %65 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %63, ptr %65)
  %66 = getelementptr i64, ptr %65, i64 3
  %storage_value5 = load i64, ptr %66, align 4
  %67 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %63, ptr %67, i64 4)
  %last_elem_ptr6 = getelementptr i64, ptr %67, i64 3
  %68 = load i64, ptr %last_elem_ptr6, align 4
  %last_elem7 = add i64 %68, 1
  store i64 %last_elem7, ptr %last_elem_ptr6, align 4
  call void @prophet_printf(i64 %storage_value5, i64 3)
  %69 = load i64, ptr %proposal_, align 4
  %70 = call ptr @heap_malloc(i64 4)
  %71 = call ptr @heap_malloc(i64 4)
  %72 = getelementptr i64, ptr %71, i64 0
  store i64 0, ptr %72, align 4
  %73 = getelementptr i64, ptr %71, i64 1
  store i64 0, ptr %73, align 4
  %74 = getelementptr i64, ptr %71, i64 2
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %71, i64 3
  store i64 1, ptr %75, align 4
  call void @get_storage(ptr %71, ptr %70)
  %76 = getelementptr i64, ptr %70, i64 3
  %storage_value8 = load i64, ptr %76, align 4
  %77 = sub i64 %storage_value8, 1
  %78 = sub i64 %77, %69
  call void @builtin_range_check(i64 %78)
  %79 = call ptr @heap_malloc(i64 4)
  %80 = getelementptr i64, ptr %79, i64 0
  store i64 0, ptr %80, align 4
  %81 = getelementptr i64, ptr %79, i64 1
  store i64 0, ptr %81, align 4
  %82 = getelementptr i64, ptr %79, i64 2
  store i64 0, ptr %82, align 4
  %83 = getelementptr i64, ptr %79, i64 3
  store i64 1, ptr %83, align 4
  %84 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %79, ptr %84, i64 4)
  %hash_value_low9 = getelementptr i64, ptr %84, i64 3
  %85 = load i64, ptr %hash_value_low9, align 4
  %86 = mul i64 %69, 2
  %storage_array_offset10 = add i64 %85, %86
  store i64 %storage_array_offset10, ptr %hash_value_low9, align 4
  %87 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %84, ptr %87, i64 4)
  %last_elem_ptr11 = getelementptr i64, ptr %87, i64 3
  %88 = load i64, ptr %last_elem_ptr11, align 4
  %last_elem12 = add i64 %88, 0
  store i64 %last_elem12, ptr %last_elem_ptr11, align 4
  %89 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %87, ptr %89)
  %90 = getelementptr i64, ptr %89, i64 3
  %storage_value13 = load i64, ptr %90, align 4
  %91 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %87, ptr %91, i64 4)
  %last_elem_ptr14 = getelementptr i64, ptr %91, i64 3
  %92 = load i64, ptr %last_elem_ptr14, align 4
  %last_elem15 = add i64 %92, 1
  store i64 %last_elem15, ptr %last_elem_ptr14, align 4
  %93 = icmp ne i64 %storage_value13, 0
  %94 = zext i1 %93 to i64
  call void @builtin_assert(i64 %94)
  %95 = load i64, ptr %proposal_, align 4
  %96 = call ptr @heap_malloc(i64 4)
  %97 = call ptr @heap_malloc(i64 4)
  %98 = getelementptr i64, ptr %97, i64 0
  store i64 0, ptr %98, align 4
  %99 = getelementptr i64, ptr %97, i64 1
  store i64 0, ptr %99, align 4
  %100 = getelementptr i64, ptr %97, i64 2
  store i64 0, ptr %100, align 4
  %101 = getelementptr i64, ptr %97, i64 3
  store i64 1, ptr %101, align 4
  call void @get_storage(ptr %97, ptr %96)
  %102 = getelementptr i64, ptr %96, i64 3
  %storage_value16 = load i64, ptr %102, align 4
  %103 = sub i64 %storage_value16, 1
  %104 = sub i64 %103, %95
  call void @builtin_range_check(i64 %104)
  %105 = call ptr @heap_malloc(i64 4)
  %106 = getelementptr i64, ptr %105, i64 0
  store i64 0, ptr %106, align 4
  %107 = getelementptr i64, ptr %105, i64 1
  store i64 0, ptr %107, align 4
  %108 = getelementptr i64, ptr %105, i64 2
  store i64 0, ptr %108, align 4
  %109 = getelementptr i64, ptr %105, i64 3
  store i64 1, ptr %109, align 4
  %110 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %105, ptr %110, i64 4)
  %hash_value_low17 = getelementptr i64, ptr %110, i64 3
  %111 = load i64, ptr %hash_value_low17, align 4
  %112 = mul i64 %95, 2
  %storage_array_offset18 = add i64 %111, %112
  store i64 %storage_array_offset18, ptr %hash_value_low17, align 4
  %113 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %110, ptr %113, i64 4)
  %last_elem_ptr19 = getelementptr i64, ptr %113, i64 3
  %114 = load i64, ptr %last_elem_ptr19, align 4
  %last_elem20 = add i64 %114, 1
  store i64 %last_elem20, ptr %last_elem_ptr19, align 4
  %115 = load i64, ptr %proposal_, align 4
  %116 = call ptr @heap_malloc(i64 4)
  %117 = call ptr @heap_malloc(i64 4)
  %118 = getelementptr i64, ptr %117, i64 0
  store i64 0, ptr %118, align 4
  %119 = getelementptr i64, ptr %117, i64 1
  store i64 0, ptr %119, align 4
  %120 = getelementptr i64, ptr %117, i64 2
  store i64 0, ptr %120, align 4
  %121 = getelementptr i64, ptr %117, i64 3
  store i64 1, ptr %121, align 4
  call void @get_storage(ptr %117, ptr %116)
  %122 = getelementptr i64, ptr %116, i64 3
  %storage_value21 = load i64, ptr %122, align 4
  %123 = sub i64 %storage_value21, 1
  %124 = sub i64 %123, %115
  call void @builtin_range_check(i64 %124)
  %125 = call ptr @heap_malloc(i64 4)
  %126 = getelementptr i64, ptr %125, i64 0
  store i64 0, ptr %126, align 4
  %127 = getelementptr i64, ptr %125, i64 1
  store i64 0, ptr %127, align 4
  %128 = getelementptr i64, ptr %125, i64 2
  store i64 0, ptr %128, align 4
  %129 = getelementptr i64, ptr %125, i64 3
  store i64 1, ptr %129, align 4
  %130 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %125, ptr %130, i64 4)
  %hash_value_low22 = getelementptr i64, ptr %130, i64 3
  %131 = load i64, ptr %hash_value_low22, align 4
  %132 = mul i64 %115, 2
  %storage_array_offset23 = add i64 %131, %132
  store i64 %storage_array_offset23, ptr %hash_value_low22, align 4
  %133 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %130, ptr %133, i64 4)
  %last_elem_ptr24 = getelementptr i64, ptr %133, i64 3
  %134 = load i64, ptr %last_elem_ptr24, align 4
  %last_elem25 = add i64 %134, 1
  store i64 %last_elem25, ptr %last_elem_ptr24, align 4
  %135 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %133, ptr %135)
  %136 = getelementptr i64, ptr %135, i64 3
  %storage_value26 = load i64, ptr %136, align 4
  %137 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %133, ptr %137, i64 4)
  %last_elem_ptr27 = getelementptr i64, ptr %137, i64 3
  %138 = load i64, ptr %last_elem_ptr27, align 4
  %last_elem28 = add i64 %138, 1
  store i64 %last_elem28, ptr %last_elem_ptr27, align 4
  %139 = add i64 %storage_value26, 1
  call void @builtin_range_check(i64 %139)
  %140 = call ptr @heap_malloc(i64 4)
  %141 = getelementptr i64, ptr %140, i64 0
  store i64 0, ptr %141, align 4
  %142 = getelementptr i64, ptr %140, i64 1
  store i64 0, ptr %142, align 4
  %143 = getelementptr i64, ptr %140, i64 2
  store i64 0, ptr %143, align 4
  %144 = getelementptr i64, ptr %140, i64 3
  store i64 %139, ptr %144, align 4
  call void @set_storage(ptr %113, ptr %140)
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
  store i64 1, ptr %6, align 4
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
  store i64 1, ptr %15, align 4
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
  store i64 1, ptr %23, align 4
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
  call void @prophet_printf(i64 %37, i64 3)
  %38 = load i64, ptr %winningProposal_, align 4
  ret i64 %38

then:                                             ; preds = %body
  %39 = load i64, ptr %p, align 4
  %40 = call ptr @heap_malloc(i64 4)
  %41 = call ptr @heap_malloc(i64 4)
  %42 = getelementptr i64, ptr %41, i64 0
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %41, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %41, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %41, i64 3
  store i64 1, ptr %45, align 4
  call void @get_storage(ptr %41, ptr %40)
  %46 = getelementptr i64, ptr %40, i64 3
  %storage_value5 = load i64, ptr %46, align 4
  %47 = sub i64 %storage_value5, 1
  %48 = sub i64 %47, %39
  call void @builtin_range_check(i64 %48)
  %49 = call ptr @heap_malloc(i64 4)
  %50 = getelementptr i64, ptr %49, i64 0
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %49, i64 1
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %49, i64 2
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %49, i64 3
  store i64 1, ptr %53, align 4
  %54 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %49, ptr %54, i64 4)
  %hash_value_low6 = getelementptr i64, ptr %54, i64 3
  %55 = load i64, ptr %hash_value_low6, align 4
  %56 = mul i64 %39, 2
  %storage_array_offset7 = add i64 %55, %56
  store i64 %storage_array_offset7, ptr %hash_value_low6, align 4
  %57 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %54, ptr %57, i64 4)
  %last_elem_ptr8 = getelementptr i64, ptr %57, i64 3
  %58 = load i64, ptr %last_elem_ptr8, align 4
  %last_elem9 = add i64 %58, 1
  store i64 %last_elem9, ptr %last_elem_ptr8, align 4
  %59 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %57, ptr %59)
  %60 = getelementptr i64, ptr %59, i64 3
  %storage_value10 = load i64, ptr %60, align 4
  %61 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %57, ptr %61, i64 4)
  %last_elem_ptr11 = getelementptr i64, ptr %61, i64 3
  %62 = load i64, ptr %last_elem_ptr11, align 4
  %last_elem12 = add i64 %62, 1
  store i64 %last_elem12, ptr %last_elem_ptr11, align 4
  store i64 %storage_value10, ptr %winningVoteCount, align 4
  %63 = load i64, ptr %p, align 4
  store i64 %63, ptr %winningProposal_, align 4
  br label %endif

endif:                                            ; preds = %then, %body
  br label %next
}

define i64 @getWinnerName() {
entry:
  %winnerName = alloca i64, align 8
  %winnerP = alloca i64, align 8
  %0 = call i64 @winningProposal()
  store i64 %0, ptr %winnerP, align 4
  %1 = load i64, ptr %winnerP, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 1, ptr %7, align 4
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
  store i64 1, ptr %15, align 4
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
  %22 = getelementptr i64, ptr %21, i64 3
  %storage_value1 = load i64, ptr %22, align 4
  %23 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %19, ptr %23, i64 4)
  %last_elem_ptr2 = getelementptr i64, ptr %23, i64 3
  %24 = load i64, ptr %last_elem_ptr2, align 4
  %last_elem3 = add i64 %24, 1
  store i64 %last_elem3, ptr %last_elem_ptr2, align 4
  store i64 %storage_value1, ptr %winnerName, align 4
  %25 = load i64, ptr %winnerName, align 4
  call void @prophet_printf(i64 %25, i64 3)
  %26 = load i64, ptr %winnerName, align 4
  ret i64 %26
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3826510503, label %func_0_dispatch
    i64 597976998, label %func_1_dispatch
    i64 1621094845, label %func_2_dispatch
    i64 738043157, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %vector_length = load i64, ptr %3, align 4
  %4 = mul i64 %vector_length, 1
  %5 = add i64 %4, 1
  call void @contract_init(ptr %3)
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = getelementptr ptr, ptr %2, i64 0
  %8 = load i64, ptr %7, align 4
  call void @vote_proposal(i64 %8)
  %9 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %9, align 4
  call void @set_tape_data(ptr %9, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %10 = call i64 @winningProposal()
  %11 = call ptr @heap_malloc(i64 2)
  store i64 %10, ptr %11, align 4
  %12 = getelementptr ptr, ptr %11, i64 1
  store i64 1, ptr %12, align 4
  call void @set_tape_data(ptr %11, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %13 = call i64 @getWinnerName()
  %14 = call ptr @heap_malloc(i64 2)
  store i64 %13, ptr %14, align 4
  %15 = getelementptr ptr, ptr %14, i64 1
  store i64 1, ptr %15, align 4
  call void @set_tape_data(ptr %14, i64 2)
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
