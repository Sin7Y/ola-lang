; ModuleID = 'ArrayInputExample'
source_filename = "array_input_and_output"

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

define ptr @array_input_u32(ptr %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %2 = load ptr, ptr %array, align 8
  store i64 %1, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x i64]], ptr %2, i64 0, i64 %3
  ret ptr %index_access
}

define ptr @array_output_u32() {
entry:
  %0 = call ptr @heap_malloc(i64 6)
  ret ptr %0
}

define ptr @array_input_address(ptr %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %2 = load ptr, ptr %array, align 8
  store i64 %1, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %2, i64 0, i64 %3
  ret ptr %index_access
}

define ptr @array_input_address_1(ptr %0, i64 %1) {
entry:
  %a = alloca ptr, align 8
  %b = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %2 = load ptr, ptr %array, align 8
  store i64 %1, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %2, i64 0, i64 %3
  %index_access1 = getelementptr [2 x ptr], ptr %index_access, i64 0, i64 1
  %5 = load ptr, ptr %index_access1, align 8
  store ptr %5, ptr %a, align 8
  %6 = load ptr, ptr %a, align 8
  ret ptr %6
}

define ptr @array_input_address_2(ptr %0) {
entry:
  %index_ptr33 = alloca i64, align 8
  %index_ptr28 = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  %index_ptr15 = alloca i64, align 8
  %index_ptr10 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_size = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %1 = load ptr, ptr %array, align 8
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %2 = load i64, ptr %index_ptr, align 4
  %3 = icmp ult i64 %2, 3
  br i1 %3, label %body, label %end_for

body:                                             ; preds = %cond
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

next:                                             ; preds = %end_for5
  %index9 = load i64, ptr %index_ptr, align 4
  %4 = add i64 %index9, 1
  store i64 %4, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %5 = load i64, ptr %array_size, align 4
  %6 = call ptr @vector_new(i64 %5)
  %7 = getelementptr ptr, ptr %6, i64 1
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr10, align 4
  br label %cond11

cond2:                                            ; preds = %next4, %body
  %8 = load i64, ptr %index_ptr1, align 4
  %9 = icmp ult i64 %8, 2
  br i1 %9, label %body3, label %end_for5

body3:                                            ; preds = %cond2
  %array_index = load i64, ptr %index_ptr, align 4
  %10 = sub i64 2, %array_index
  call void @builtin_range_check(i64 %10)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %1, i64 0, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %array_index6 = load i64, ptr %index_ptr1, align 4
  %11 = sub i64 1, %array_index6
  call void @builtin_range_check(i64 %11)
  %index_access7 = getelementptr [2 x ptr], ptr %array_element, i64 0, i64 %array_index6
  %array_element8 = load ptr, ptr %index_access7, align 8
  %12 = load i64, ptr %array_size, align 4
  %13 = add i64 %12, 4
  store i64 %13, ptr %array_size, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index = load i64, ptr %index_ptr1, align 4
  %14 = add i64 %index, 1
  store i64 %14, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  br label %next

cond11:                                           ; preds = %next13, %end_for
  %15 = load i64, ptr %index_ptr10, align 4
  %16 = icmp ult i64 %15, 3
  br i1 %16, label %body12, label %end_for14

body12:                                           ; preds = %cond11
  store i64 0, ptr %index_ptr15, align 4
  br label %cond16

next13:                                           ; preds = %end_for19
  %index27 = load i64, ptr %index_ptr10, align 4
  %17 = add i64 %index27, 1
  store i64 %17, ptr %index_ptr10, align 4
  br label %cond11

end_for14:                                        ; preds = %cond11
  %18 = load i64, ptr %buffer_offset, align 4
  %vector_data = getelementptr i64, ptr %6, i64 1
  %19 = getelementptr ptr, ptr %vector_data, i64 0
  store i64 0, ptr %offset_var, align 4
  %20 = load i64, ptr %offset_var, align 4
  %21 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr28, align 4
  br label %cond29

cond16:                                           ; preds = %next18, %body12
  %22 = load i64, ptr %index_ptr15, align 4
  %23 = icmp ult i64 %22, 2
  br i1 %23, label %body17, label %end_for19

body17:                                           ; preds = %cond16
  %array_index20 = load i64, ptr %index_ptr10, align 4
  %24 = sub i64 2, %array_index20
  call void @builtin_range_check(i64 %24)
  %index_access21 = getelementptr [3 x [2 x ptr]], ptr %1, i64 0, i64 %array_index20
  %array_element22 = load ptr, ptr %index_access21, align 8
  %array_index23 = load i64, ptr %index_ptr15, align 4
  %25 = sub i64 1, %array_index23
  call void @builtin_range_check(i64 %25)
  %index_access24 = getelementptr [2 x ptr], ptr %array_element22, i64 0, i64 %array_index23
  %array_element25 = load ptr, ptr %index_access24, align 8
  %26 = load i64, ptr %buffer_offset, align 4
  %27 = getelementptr ptr, ptr %7, i64 %26
  %28 = getelementptr i64, ptr %array_element25, i64 0
  %29 = load i64, ptr %28, align 4
  %30 = getelementptr i64, ptr %27, i64 0
  store i64 %29, ptr %30, align 4
  %31 = getelementptr i64, ptr %array_element25, i64 1
  %32 = load i64, ptr %31, align 4
  %33 = getelementptr i64, ptr %27, i64 1
  store i64 %32, ptr %33, align 4
  %34 = getelementptr i64, ptr %array_element25, i64 2
  %35 = load i64, ptr %34, align 4
  %36 = getelementptr i64, ptr %27, i64 2
  store i64 %35, ptr %36, align 4
  %37 = getelementptr i64, ptr %array_element25, i64 3
  %38 = load i64, ptr %37, align 4
  %39 = getelementptr i64, ptr %27, i64 3
  store i64 %38, ptr %39, align 4
  %40 = load i64, ptr %buffer_offset, align 4
  %41 = add i64 %40, 4
  store i64 %41, ptr %buffer_offset, align 4
  br label %next18

next18:                                           ; preds = %body17
  %index26 = load i64, ptr %index_ptr15, align 4
  %42 = add i64 %index26, 1
  store i64 %42, ptr %index_ptr15, align 4
  br label %cond16

end_for19:                                        ; preds = %cond16
  br label %next13

cond29:                                           ; preds = %next31, %end_for14
  %43 = load i64, ptr %index_ptr28, align 4
  %44 = icmp ult i64 %43, 3
  br i1 %44, label %body30, label %end_for32

body30:                                           ; preds = %cond29
  %45 = load i64, ptr %offset_var, align 4
  %46 = getelementptr ptr, ptr %19, i64 %45
  %47 = load i64, ptr %offset_var, align 4
  %48 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr33, align 4
  br label %cond34

next31:                                           ; preds = %end_for37
  %index45 = load i64, ptr %index_ptr28, align 4
  %49 = add i64 %index45, 1
  store i64 %49, ptr %index_ptr28, align 4
  br label %cond29

end_for32:                                        ; preds = %cond29
  %50 = load ptr, ptr %array_ptr, align 8
  %51 = load i64, ptr %offset_var, align 4
  ret ptr %50

cond34:                                           ; preds = %next36, %body30
  %52 = load i64, ptr %index_ptr33, align 4
  %53 = icmp ult i64 %52, 2
  br i1 %53, label %body35, label %end_for37

body35:                                           ; preds = %cond34
  %54 = load i64, ptr %offset_var, align 4
  %55 = getelementptr ptr, ptr %46, i64 %54
  %56 = load ptr, ptr %array_ptr, align 8
  %array_index38 = load i64, ptr %index_ptr28, align 4
  %57 = sub i64 2, %array_index38
  call void @builtin_range_check(i64 %57)
  %index_access39 = getelementptr [3 x [2 x ptr]], ptr %56, i64 0, i64 %array_index38
  %array_element40 = load ptr, ptr %index_access39, align 8
  %array_index41 = load i64, ptr %index_ptr33, align 4
  %58 = sub i64 1, %array_index41
  call void @builtin_range_check(i64 %58)
  %index_access42 = getelementptr [2 x ptr], ptr %array_element40, i64 0, i64 %array_index41
  %array_element43 = load ptr, ptr %index_access42, align 8
  store ptr %55, ptr %index_access42, align 8
  %59 = add i64 4, %54
  store i64 %59, ptr %offset_var, align 4
  br label %next36

next36:                                           ; preds = %body35
  %index44 = load i64, ptr %index_ptr33, align 4
  %60 = add i64 %index44, 1
  store i64 %60, ptr %index_ptr33, align 4
  br label %cond34

end_for37:                                        ; preds = %cond34
  br label %next31
}

define ptr @array_output_address() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %0, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %0, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %0, i64 0
  store i64 0, ptr %index_access3, align 4
  %1 = call ptr @heap_malloc(i64 6)
  ret ptr %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr133 = alloca i64, align 8
  %index_ptr128 = alloca i64, align 8
  %buffer_offset127 = alloca i64, align 8
  %index_ptr113 = alloca i64, align 8
  %index_ptr108 = alloca i64, align 8
  %array_size107 = alloca i64, align 8
  %index_ptr94 = alloca i64, align 8
  %index_ptr89 = alloca i64, align 8
  %buffer_offset88 = alloca i64, align 8
  %index_ptr74 = alloca i64, align 8
  %index_ptr69 = alloca i64, align 8
  %array_size68 = alloca i64, align 8
  %index_ptr55 = alloca i64, align 8
  %index_ptr50 = alloca i64, align 8
  %array_ptr49 = alloca ptr, align 8
  %offset_var48 = alloca i64, align 8
  %index_ptr35 = alloca i64, align 8
  %index_ptr30 = alloca i64, align 8
  %array_ptr29 = alloca ptr, align 8
  %offset_var28 = alloca i64, align 8
  %index_ptr19 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr10 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 2485437794, label %func_0_dispatch
    i64 2873489331, label %func_1_dispatch
    i64 318899924, label %func_2_dispatch
    i64 2341696685, label %func_3_dispatch
    i64 3697261626, label %func_4_dispatch
    i64 208757611, label %func_5_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = getelementptr ptr, ptr %3, i64 6
  %5 = load i64, ptr %4, align 4
  %6 = call ptr @array_input_u32(ptr %3, i64 %5)
  %7 = call ptr @heap_malloc(i64 3)
  call void @memcpy(ptr %6, ptr %7, i64 2)
  %8 = getelementptr ptr, ptr %7, i64 2
  store i64 2, ptr %8, align 4
  call void @set_tape_data(ptr %7, i64 3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %9 = call ptr @array_output_u32()
  %10 = call ptr @heap_malloc(i64 7)
  call void @memcpy(ptr %9, ptr %10, i64 6)
  %11 = getelementptr ptr, ptr %10, i64 6
  store i64 6, ptr %11, align 4
  call void @set_tape_data(ptr %10, i64 7)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %12 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var, align 4
  %13 = load i64, ptr %offset_var, align 4
  %14 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_2_dispatch
  %15 = load i64, ptr %index_ptr, align 4
  %16 = icmp ult i64 %15, 3
  br i1 %16, label %body, label %end_for

body:                                             ; preds = %cond
  %17 = load i64, ptr %offset_var, align 4
  %18 = getelementptr ptr, ptr %12, i64 %17
  %19 = load i64, ptr %offset_var, align 4
  %20 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

next:                                             ; preds = %end_for5
  %index9 = load i64, ptr %index_ptr, align 4
  %21 = add i64 %index9, 1
  store i64 %21, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %22 = load ptr, ptr %array_ptr, align 8
  %23 = load i64, ptr %offset_var, align 4
  %24 = getelementptr ptr, ptr %12, i64 %23
  %25 = load i64, ptr %24, align 4
  %26 = call ptr @array_input_address(ptr %22, i64 %25)
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr10, align 4
  br label %cond11

cond2:                                            ; preds = %next4, %body
  %27 = load i64, ptr %index_ptr1, align 4
  %28 = icmp ult i64 %27, 2
  br i1 %28, label %body3, label %end_for5

body3:                                            ; preds = %cond2
  %29 = load i64, ptr %offset_var, align 4
  %30 = getelementptr ptr, ptr %18, i64 %29
  %31 = load ptr, ptr %array_ptr, align 8
  %array_index = load i64, ptr %index_ptr, align 4
  %32 = sub i64 2, %array_index
  call void @builtin_range_check(i64 %32)
  %index_access = getelementptr [3 x [2 x ptr]], ptr %31, i64 0, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %array_index6 = load i64, ptr %index_ptr1, align 4
  %33 = sub i64 1, %array_index6
  call void @builtin_range_check(i64 %33)
  %index_access7 = getelementptr [2 x ptr], ptr %array_element, i64 0, i64 %array_index6
  %array_element8 = load ptr, ptr %index_access7, align 8
  store ptr %30, ptr %index_access7, align 8
  %34 = add i64 4, %29
  store i64 %34, ptr %offset_var, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index = load i64, ptr %index_ptr1, align 4
  %35 = add i64 %index, 1
  store i64 %35, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  br label %next

cond11:                                           ; preds = %next13, %end_for
  %36 = load i64, ptr %index_ptr10, align 4
  %37 = icmp ult i64 %36, 2
  br i1 %37, label %body12, label %end_for14

body12:                                           ; preds = %cond11
  %array_index15 = load i64, ptr %index_ptr10, align 4
  %38 = sub i64 1, %array_index15
  call void @builtin_range_check(i64 %38)
  %index_access16 = getelementptr [2 x ptr], ptr %26, i64 0, i64 %array_index15
  %array_element17 = load ptr, ptr %index_access16, align 8
  %39 = load i64, ptr %array_size, align 4
  %40 = add i64 %39, 4
  store i64 %40, ptr %array_size, align 4
  br label %next13

next13:                                           ; preds = %body12
  %index18 = load i64, ptr %index_ptr10, align 4
  %41 = add i64 %index18, 1
  store i64 %41, ptr %index_ptr10, align 4
  br label %cond11

end_for14:                                        ; preds = %cond11
  %42 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %42, 1
  %43 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr19, align 4
  br label %cond20

cond20:                                           ; preds = %next22, %end_for14
  %44 = load i64, ptr %index_ptr19, align 4
  %45 = icmp ult i64 %44, 2
  br i1 %45, label %body21, label %end_for23

body21:                                           ; preds = %cond20
  %array_index24 = load i64, ptr %index_ptr19, align 4
  %46 = sub i64 1, %array_index24
  call void @builtin_range_check(i64 %46)
  %index_access25 = getelementptr [2 x ptr], ptr %26, i64 0, i64 %array_index24
  %array_element26 = load ptr, ptr %index_access25, align 8
  %47 = load i64, ptr %buffer_offset, align 4
  %48 = getelementptr ptr, ptr %43, i64 %47
  %49 = getelementptr i64, ptr %array_element26, i64 0
  %50 = load i64, ptr %49, align 4
  %51 = getelementptr i64, ptr %48, i64 0
  store i64 %50, ptr %51, align 4
  %52 = getelementptr i64, ptr %array_element26, i64 1
  %53 = load i64, ptr %52, align 4
  %54 = getelementptr i64, ptr %48, i64 1
  store i64 %53, ptr %54, align 4
  %55 = getelementptr i64, ptr %array_element26, i64 2
  %56 = load i64, ptr %55, align 4
  %57 = getelementptr i64, ptr %48, i64 2
  store i64 %56, ptr %57, align 4
  %58 = getelementptr i64, ptr %array_element26, i64 3
  %59 = load i64, ptr %58, align 4
  %60 = getelementptr i64, ptr %48, i64 3
  store i64 %59, ptr %60, align 4
  %61 = load i64, ptr %buffer_offset, align 4
  %62 = add i64 %61, 4
  store i64 %62, ptr %buffer_offset, align 4
  br label %next22

next22:                                           ; preds = %body21
  %index27 = load i64, ptr %index_ptr19, align 4
  %63 = add i64 %index27, 1
  store i64 %63, ptr %index_ptr19, align 4
  br label %cond20

end_for23:                                        ; preds = %cond20
  %64 = load i64, ptr %buffer_offset, align 4
  %65 = getelementptr ptr, ptr %43, i64 %64
  store i64 %42, ptr %65, align 4
  call void @set_tape_data(ptr %43, i64 %heap_size)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %66 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var28, align 4
  %67 = load i64, ptr %offset_var28, align 4
  %68 = load ptr, ptr %array_ptr29, align 8
  store i64 0, ptr %index_ptr30, align 4
  br label %cond31

cond31:                                           ; preds = %next33, %func_3_dispatch
  %69 = load i64, ptr %index_ptr30, align 4
  %70 = icmp ult i64 %69, 3
  br i1 %70, label %body32, label %end_for34

body32:                                           ; preds = %cond31
  %71 = load i64, ptr %offset_var28, align 4
  %72 = getelementptr ptr, ptr %66, i64 %71
  %73 = load i64, ptr %offset_var28, align 4
  %74 = load ptr, ptr %array_ptr29, align 8
  store i64 0, ptr %index_ptr35, align 4
  br label %cond36

next33:                                           ; preds = %end_for39
  %index47 = load i64, ptr %index_ptr30, align 4
  %75 = add i64 %index47, 1
  store i64 %75, ptr %index_ptr30, align 4
  br label %cond31

end_for34:                                        ; preds = %cond31
  %76 = load ptr, ptr %array_ptr29, align 8
  %77 = load i64, ptr %offset_var28, align 4
  %78 = getelementptr ptr, ptr %66, i64 %77
  %79 = load i64, ptr %78, align 4
  %80 = call ptr @array_input_address_1(ptr %76, i64 %79)
  %81 = call ptr @heap_malloc(i64 5)
  %82 = getelementptr i64, ptr %80, i64 0
  %83 = load i64, ptr %82, align 4
  %84 = getelementptr i64, ptr %81, i64 0
  store i64 %83, ptr %84, align 4
  %85 = getelementptr i64, ptr %80, i64 1
  %86 = load i64, ptr %85, align 4
  %87 = getelementptr i64, ptr %81, i64 1
  store i64 %86, ptr %87, align 4
  %88 = getelementptr i64, ptr %80, i64 2
  %89 = load i64, ptr %88, align 4
  %90 = getelementptr i64, ptr %81, i64 2
  store i64 %89, ptr %90, align 4
  %91 = getelementptr i64, ptr %80, i64 3
  %92 = load i64, ptr %91, align 4
  %93 = getelementptr i64, ptr %81, i64 3
  store i64 %92, ptr %93, align 4
  %94 = getelementptr ptr, ptr %81, i64 4
  store i64 4, ptr %94, align 4
  call void @set_tape_data(ptr %81, i64 5)
  ret void

cond36:                                           ; preds = %next38, %body32
  %95 = load i64, ptr %index_ptr35, align 4
  %96 = icmp ult i64 %95, 2
  br i1 %96, label %body37, label %end_for39

body37:                                           ; preds = %cond36
  %97 = load i64, ptr %offset_var28, align 4
  %98 = getelementptr ptr, ptr %72, i64 %97
  %99 = load ptr, ptr %array_ptr29, align 8
  %array_index40 = load i64, ptr %index_ptr30, align 4
  %100 = sub i64 2, %array_index40
  call void @builtin_range_check(i64 %100)
  %index_access41 = getelementptr [3 x [2 x ptr]], ptr %99, i64 0, i64 %array_index40
  %array_element42 = load ptr, ptr %index_access41, align 8
  %array_index43 = load i64, ptr %index_ptr35, align 4
  %101 = sub i64 1, %array_index43
  call void @builtin_range_check(i64 %101)
  %index_access44 = getelementptr [2 x ptr], ptr %array_element42, i64 0, i64 %array_index43
  %array_element45 = load ptr, ptr %index_access44, align 8
  store ptr %98, ptr %index_access44, align 8
  %102 = add i64 4, %97
  store i64 %102, ptr %offset_var28, align 4
  br label %next38

next38:                                           ; preds = %body37
  %index46 = load i64, ptr %index_ptr35, align 4
  %103 = add i64 %index46, 1
  store i64 %103, ptr %index_ptr35, align 4
  br label %cond36

end_for39:                                        ; preds = %cond36
  br label %next33

func_4_dispatch:                                  ; preds = %entry
  %104 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var48, align 4
  %105 = load i64, ptr %offset_var48, align 4
  %106 = load ptr, ptr %array_ptr49, align 8
  store i64 0, ptr %index_ptr50, align 4
  br label %cond51

cond51:                                           ; preds = %next53, %func_4_dispatch
  %107 = load i64, ptr %index_ptr50, align 4
  %108 = icmp ult i64 %107, 3
  br i1 %108, label %body52, label %end_for54

body52:                                           ; preds = %cond51
  %109 = load i64, ptr %offset_var48, align 4
  %110 = getelementptr ptr, ptr %104, i64 %109
  %111 = load i64, ptr %offset_var48, align 4
  %112 = load ptr, ptr %array_ptr49, align 8
  store i64 0, ptr %index_ptr55, align 4
  br label %cond56

next53:                                           ; preds = %end_for59
  %index67 = load i64, ptr %index_ptr50, align 4
  %113 = add i64 %index67, 1
  store i64 %113, ptr %index_ptr50, align 4
  br label %cond51

end_for54:                                        ; preds = %cond51
  %114 = load ptr, ptr %array_ptr49, align 8
  %115 = load i64, ptr %offset_var48, align 4
  %116 = call ptr @array_input_address_2(ptr %114)
  store i64 0, ptr %array_size68, align 4
  store i64 0, ptr %index_ptr69, align 4
  br label %cond70

cond56:                                           ; preds = %next58, %body52
  %117 = load i64, ptr %index_ptr55, align 4
  %118 = icmp ult i64 %117, 2
  br i1 %118, label %body57, label %end_for59

body57:                                           ; preds = %cond56
  %119 = load i64, ptr %offset_var48, align 4
  %120 = getelementptr ptr, ptr %110, i64 %119
  %121 = load ptr, ptr %array_ptr49, align 8
  %array_index60 = load i64, ptr %index_ptr50, align 4
  %122 = sub i64 2, %array_index60
  call void @builtin_range_check(i64 %122)
  %index_access61 = getelementptr [3 x [2 x ptr]], ptr %121, i64 0, i64 %array_index60
  %array_element62 = load ptr, ptr %index_access61, align 8
  %array_index63 = load i64, ptr %index_ptr55, align 4
  %123 = sub i64 1, %array_index63
  call void @builtin_range_check(i64 %123)
  %index_access64 = getelementptr [2 x ptr], ptr %array_element62, i64 0, i64 %array_index63
  %array_element65 = load ptr, ptr %index_access64, align 8
  store ptr %120, ptr %index_access64, align 8
  %124 = add i64 4, %119
  store i64 %124, ptr %offset_var48, align 4
  br label %next58

next58:                                           ; preds = %body57
  %index66 = load i64, ptr %index_ptr55, align 4
  %125 = add i64 %index66, 1
  store i64 %125, ptr %index_ptr55, align 4
  br label %cond56

end_for59:                                        ; preds = %cond56
  br label %next53

cond70:                                           ; preds = %next72, %end_for54
  %126 = load i64, ptr %index_ptr69, align 4
  %127 = icmp ult i64 %126, 3
  br i1 %127, label %body71, label %end_for73

body71:                                           ; preds = %cond70
  store i64 0, ptr %index_ptr74, align 4
  br label %cond75

next72:                                           ; preds = %end_for78
  %index86 = load i64, ptr %index_ptr69, align 4
  %128 = add i64 %index86, 1
  store i64 %128, ptr %index_ptr69, align 4
  br label %cond70

end_for73:                                        ; preds = %cond70
  %129 = load i64, ptr %array_size68, align 4
  %heap_size87 = add i64 %129, 1
  %130 = call ptr @heap_malloc(i64 %heap_size87)
  store i64 0, ptr %buffer_offset88, align 4
  store i64 0, ptr %index_ptr89, align 4
  br label %cond90

cond75:                                           ; preds = %next77, %body71
  %131 = load i64, ptr %index_ptr74, align 4
  %132 = icmp ult i64 %131, 2
  br i1 %132, label %body76, label %end_for78

body76:                                           ; preds = %cond75
  %array_index79 = load i64, ptr %index_ptr69, align 4
  %133 = sub i64 2, %array_index79
  call void @builtin_range_check(i64 %133)
  %index_access80 = getelementptr [3 x [2 x ptr]], ptr %116, i64 0, i64 %array_index79
  %array_element81 = load ptr, ptr %index_access80, align 8
  %array_index82 = load i64, ptr %index_ptr74, align 4
  %134 = sub i64 1, %array_index82
  call void @builtin_range_check(i64 %134)
  %index_access83 = getelementptr [2 x ptr], ptr %array_element81, i64 0, i64 %array_index82
  %array_element84 = load ptr, ptr %index_access83, align 8
  %135 = load i64, ptr %array_size68, align 4
  %136 = add i64 %135, 4
  store i64 %136, ptr %array_size68, align 4
  br label %next77

next77:                                           ; preds = %body76
  %index85 = load i64, ptr %index_ptr74, align 4
  %137 = add i64 %index85, 1
  store i64 %137, ptr %index_ptr74, align 4
  br label %cond75

end_for78:                                        ; preds = %cond75
  br label %next72

cond90:                                           ; preds = %next92, %end_for73
  %138 = load i64, ptr %index_ptr89, align 4
  %139 = icmp ult i64 %138, 3
  br i1 %139, label %body91, label %end_for93

body91:                                           ; preds = %cond90
  store i64 0, ptr %index_ptr94, align 4
  br label %cond95

next92:                                           ; preds = %end_for98
  %index106 = load i64, ptr %index_ptr89, align 4
  %140 = add i64 %index106, 1
  store i64 %140, ptr %index_ptr89, align 4
  br label %cond90

end_for93:                                        ; preds = %cond90
  %141 = load i64, ptr %buffer_offset88, align 4
  %142 = getelementptr ptr, ptr %130, i64 %141
  store i64 %129, ptr %142, align 4
  call void @set_tape_data(ptr %130, i64 %heap_size87)
  ret void

cond95:                                           ; preds = %next97, %body91
  %143 = load i64, ptr %index_ptr94, align 4
  %144 = icmp ult i64 %143, 2
  br i1 %144, label %body96, label %end_for98

body96:                                           ; preds = %cond95
  %array_index99 = load i64, ptr %index_ptr89, align 4
  %145 = sub i64 2, %array_index99
  call void @builtin_range_check(i64 %145)
  %index_access100 = getelementptr [3 x [2 x ptr]], ptr %116, i64 0, i64 %array_index99
  %array_element101 = load ptr, ptr %index_access100, align 8
  %array_index102 = load i64, ptr %index_ptr94, align 4
  %146 = sub i64 1, %array_index102
  call void @builtin_range_check(i64 %146)
  %index_access103 = getelementptr [2 x ptr], ptr %array_element101, i64 0, i64 %array_index102
  %array_element104 = load ptr, ptr %index_access103, align 8
  %147 = load i64, ptr %buffer_offset88, align 4
  %148 = getelementptr ptr, ptr %130, i64 %147
  %149 = getelementptr i64, ptr %array_element104, i64 0
  %150 = load i64, ptr %149, align 4
  %151 = getelementptr i64, ptr %148, i64 0
  store i64 %150, ptr %151, align 4
  %152 = getelementptr i64, ptr %array_element104, i64 1
  %153 = load i64, ptr %152, align 4
  %154 = getelementptr i64, ptr %148, i64 1
  store i64 %153, ptr %154, align 4
  %155 = getelementptr i64, ptr %array_element104, i64 2
  %156 = load i64, ptr %155, align 4
  %157 = getelementptr i64, ptr %148, i64 2
  store i64 %156, ptr %157, align 4
  %158 = getelementptr i64, ptr %array_element104, i64 3
  %159 = load i64, ptr %158, align 4
  %160 = getelementptr i64, ptr %148, i64 3
  store i64 %159, ptr %160, align 4
  %161 = load i64, ptr %buffer_offset88, align 4
  %162 = add i64 %161, 4
  store i64 %162, ptr %buffer_offset88, align 4
  br label %next97

next97:                                           ; preds = %body96
  %index105 = load i64, ptr %index_ptr94, align 4
  %163 = add i64 %index105, 1
  store i64 %163, ptr %index_ptr94, align 4
  br label %cond95

end_for98:                                        ; preds = %cond95
  br label %next92

func_5_dispatch:                                  ; preds = %entry
  %164 = call ptr @array_output_address()
  store i64 0, ptr %array_size107, align 4
  store i64 0, ptr %index_ptr108, align 4
  br label %cond109

cond109:                                          ; preds = %next111, %func_5_dispatch
  %165 = load i64, ptr %index_ptr108, align 4
  %166 = icmp ult i64 %165, 3
  br i1 %166, label %body110, label %end_for112

body110:                                          ; preds = %cond109
  store i64 0, ptr %index_ptr113, align 4
  br label %cond114

next111:                                          ; preds = %end_for117
  %index125 = load i64, ptr %index_ptr108, align 4
  %167 = add i64 %index125, 1
  store i64 %167, ptr %index_ptr108, align 4
  br label %cond109

end_for112:                                       ; preds = %cond109
  %168 = load i64, ptr %array_size107, align 4
  %heap_size126 = add i64 %168, 1
  %169 = call ptr @heap_malloc(i64 %heap_size126)
  store i64 0, ptr %buffer_offset127, align 4
  store i64 0, ptr %index_ptr128, align 4
  br label %cond129

cond114:                                          ; preds = %next116, %body110
  %170 = load i64, ptr %index_ptr113, align 4
  %171 = icmp ult i64 %170, 2
  br i1 %171, label %body115, label %end_for117

body115:                                          ; preds = %cond114
  %array_index118 = load i64, ptr %index_ptr108, align 4
  %172 = sub i64 2, %array_index118
  call void @builtin_range_check(i64 %172)
  %index_access119 = getelementptr [3 x [2 x ptr]], ptr %164, i64 0, i64 %array_index118
  %array_element120 = load ptr, ptr %index_access119, align 8
  %array_index121 = load i64, ptr %index_ptr113, align 4
  %173 = sub i64 1, %array_index121
  call void @builtin_range_check(i64 %173)
  %index_access122 = getelementptr [2 x ptr], ptr %array_element120, i64 0, i64 %array_index121
  %array_element123 = load ptr, ptr %index_access122, align 8
  %174 = load i64, ptr %array_size107, align 4
  %175 = add i64 %174, 4
  store i64 %175, ptr %array_size107, align 4
  br label %next116

next116:                                          ; preds = %body115
  %index124 = load i64, ptr %index_ptr113, align 4
  %176 = add i64 %index124, 1
  store i64 %176, ptr %index_ptr113, align 4
  br label %cond114

end_for117:                                       ; preds = %cond114
  br label %next111

cond129:                                          ; preds = %next131, %end_for112
  %177 = load i64, ptr %index_ptr128, align 4
  %178 = icmp ult i64 %177, 3
  br i1 %178, label %body130, label %end_for132

body130:                                          ; preds = %cond129
  store i64 0, ptr %index_ptr133, align 4
  br label %cond134

next131:                                          ; preds = %end_for137
  %index145 = load i64, ptr %index_ptr128, align 4
  %179 = add i64 %index145, 1
  store i64 %179, ptr %index_ptr128, align 4
  br label %cond129

end_for132:                                       ; preds = %cond129
  %180 = load i64, ptr %buffer_offset127, align 4
  %181 = getelementptr ptr, ptr %169, i64 %180
  store i64 %168, ptr %181, align 4
  call void @set_tape_data(ptr %169, i64 %heap_size126)
  ret void

cond134:                                          ; preds = %next136, %body130
  %182 = load i64, ptr %index_ptr133, align 4
  %183 = icmp ult i64 %182, 2
  br i1 %183, label %body135, label %end_for137

body135:                                          ; preds = %cond134
  %array_index138 = load i64, ptr %index_ptr128, align 4
  %184 = sub i64 2, %array_index138
  call void @builtin_range_check(i64 %184)
  %index_access139 = getelementptr [3 x [2 x ptr]], ptr %164, i64 0, i64 %array_index138
  %array_element140 = load ptr, ptr %index_access139, align 8
  %array_index141 = load i64, ptr %index_ptr133, align 4
  %185 = sub i64 1, %array_index141
  call void @builtin_range_check(i64 %185)
  %index_access142 = getelementptr [2 x ptr], ptr %array_element140, i64 0, i64 %array_index141
  %array_element143 = load ptr, ptr %index_access142, align 8
  %186 = load i64, ptr %buffer_offset127, align 4
  %187 = getelementptr ptr, ptr %169, i64 %186
  %188 = getelementptr i64, ptr %array_element143, i64 0
  %189 = load i64, ptr %188, align 4
  %190 = getelementptr i64, ptr %187, i64 0
  store i64 %189, ptr %190, align 4
  %191 = getelementptr i64, ptr %array_element143, i64 1
  %192 = load i64, ptr %191, align 4
  %193 = getelementptr i64, ptr %187, i64 1
  store i64 %192, ptr %193, align 4
  %194 = getelementptr i64, ptr %array_element143, i64 2
  %195 = load i64, ptr %194, align 4
  %196 = getelementptr i64, ptr %187, i64 2
  store i64 %195, ptr %196, align 4
  %197 = getelementptr i64, ptr %array_element143, i64 3
  %198 = load i64, ptr %197, align 4
  %199 = getelementptr i64, ptr %187, i64 3
  store i64 %198, ptr %199, align 4
  %200 = load i64, ptr %buffer_offset127, align 4
  %201 = add i64 %200, 4
  store i64 %201, ptr %buffer_offset127, align 4
  br label %next136

next136:                                          ; preds = %body135
  %index144 = load i64, ptr %index_ptr133, align 4
  %202 = add i64 %index144, 1
  store i64 %202, ptr %index_ptr133, align 4
  br label %cond134

end_for137:                                       ; preds = %cond134
  br label %next131
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
