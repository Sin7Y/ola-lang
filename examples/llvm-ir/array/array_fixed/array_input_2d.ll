; ModuleID = 'ArrayInputExample'
source_filename = "array_input_2d"

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
  %index_access = getelementptr [3 x ptr], ptr %2, i64 0, i64 %3
  %5 = load ptr, ptr %index_access, align 8
  ret ptr %5
}

define ptr @array_input(ptr %0) {
entry:
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %1 = load ptr, ptr %array, align 8
  %index_access = getelementptr [3 x ptr], ptr %1, i64 0, i64 0
  %2 = load ptr, ptr %index_access, align 8
  ret ptr %2
}

define ptr @array_output_u32() {
entry:
  %index_alloca14 = alloca i64, align 8
  %index_alloca5 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call ptr @vector_new(i64 2)
  %vector_data = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %1 = call ptr @vector_new(i64 2)
  %vector_data1 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_alloca5, align 4
  br label %cond2

cond2:                                            ; preds = %body3, %done
  %index_value6 = load i64, ptr %index_alloca5, align 4
  %loop_cond7 = icmp ult i64 %index_value6, 2
  br i1 %loop_cond7, label %body3, label %done4

body3:                                            ; preds = %cond2
  %index_access8 = getelementptr ptr, ptr %vector_data1, i64 %index_value6
  store i64 0, ptr %index_access8, align 4
  %next_index9 = add i64 %index_value6, 1
  store i64 %next_index9, ptr %index_alloca5, align 4
  br label %cond2

done4:                                            ; preds = %cond2
  %2 = call ptr @vector_new(i64 2)
  %vector_data10 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_alloca14, align 4
  br label %cond11

cond11:                                           ; preds = %body12, %done4
  %index_value15 = load i64, ptr %index_alloca14, align 4
  %loop_cond16 = icmp ult i64 %index_value15, 2
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %index_access17 = getelementptr ptr, ptr %vector_data10, i64 %index_value15
  store i64 0, ptr %index_access17, align 4
  %next_index18 = add i64 %index_value15, 1
  store i64 %next_index18, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  %3 = call ptr @heap_malloc(i64 3)
  %index_access19 = getelementptr [3 x ptr], ptr %3, i64 0, i64 0
  store ptr %0, ptr %index_access19, align 8
  %index_access20 = getelementptr [3 x ptr], ptr %3, i64 0, i64 1
  store ptr %1, ptr %index_access20, align 8
  %index_access21 = getelementptr [3 x ptr], ptr %3, i64 0, i64 2
  store ptr %2, ptr %index_access21, align 8
  ret ptr %3
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
  %index_access = getelementptr [3 x ptr], ptr %2, i64 0, i64 %3
  %5 = load ptr, ptr %index_access, align 8
  ret ptr %5
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
  %1 = call ptr @heap_malloc(i64 3)
  ret ptr %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr205 = alloca i64, align 8
  %index_ptr196 = alloca i64, align 8
  %buffer_offset195 = alloca i64, align 8
  %index_ptr175 = alloca i64, align 8
  %index_ptr170 = alloca i64, align 8
  %array_size169 = alloca i64, align 8
  %index_ptr157 = alloca i64, align 8
  %buffer_offset155 = alloca i64, align 8
  %index_ptr142 = alloca i64, align 8
  %array_size141 = alloca i64, align 8
  %index_ptr122 = alloca i64, align 8
  %index_ptr112 = alloca i64, align 8
  %array_ptr111 = alloca ptr, align 8
  %offset_var110 = alloca i64, align 8
  %index_ptr87 = alloca i64, align 8
  %index_ptr78 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr58 = alloca i64, align 8
  %index_ptr53 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr31 = alloca i64, align 8
  %index_ptr21 = alloca i64, align 8
  %array_ptr20 = alloca ptr, align 8
  %offset_var19 = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 518061708, label %func_0_dispatch
    i64 271119659, label %func_1_dispatch
    i64 2873489331, label %func_2_dispatch
    i64 3210415193, label %func_3_dispatch
    i64 208757611, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var, align 4
  %4 = load i64, ptr %offset_var, align 4
  %5 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %6 = load i64, ptr %index_ptr, align 4
  %7 = icmp ult i64 %6, 3
  br i1 %7, label %body, label %end_for

body:                                             ; preds = %cond
  %8 = load i64, ptr %offset_var, align 4
  %9 = getelementptr ptr, ptr %3, i64 %8
  %10 = load i64, ptr %offset_var, align 4
  %array_length = getelementptr ptr, ptr %9, i64 %10
  %11 = load i64, ptr %array_length, align 4
  %12 = add i64 %10, 1
  store i64 %12, ptr %offset_var, align 4
  %13 = call ptr @vector_new(i64 %11)
  %load_array = load ptr, ptr %array_ptr, align 8
  %array_index = load i64, ptr %index_ptr, align 4
  %14 = sub i64 2, %array_index
  call void @builtin_range_check(i64 %14)
  %index_access = getelementptr [3 x ptr], ptr %load_array, i64 0, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  store ptr %13, ptr %index_access, align 8
  %15 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

next:                                             ; preds = %end_for5
  %index16 = load i64, ptr %index_ptr, align 4
  %16 = add i64 %index16, 1
  store i64 %16, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %17 = load ptr, ptr %array_ptr, align 8
  %18 = load i64, ptr %offset_var, align 4
  %19 = getelementptr ptr, ptr %3, i64 %18
  %20 = load i64, ptr %19, align 4
  %21 = call ptr @array_input_u32(ptr %17, i64 %20)
  %vector_length17 = load i64, ptr %21, align 4
  %22 = mul i64 %vector_length17, 1
  %23 = add i64 %22, 1
  %heap_size = add i64 %23, 1
  %24 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length18 = load i64, ptr %21, align 4
  %25 = mul i64 %vector_length18, 1
  %26 = add i64 %25, 1
  call void @memcpy(ptr %21, ptr %24, i64 %26)
  %27 = getelementptr ptr, ptr %24, i64 %26
  store i64 %23, ptr %27, align 4
  call void @set_tape_data(ptr %24, i64 %heap_size)
  ret void

cond2:                                            ; preds = %next4, %body
  %array_index6 = load i64, ptr %index_ptr, align 4
  %28 = sub i64 2, %array_index6
  call void @builtin_range_check(i64 %28)
  %index_access7 = getelementptr [3 x ptr], ptr %15, i64 0, i64 %array_index6
  %array_element8 = load ptr, ptr %index_access7, align 8
  %vector_length = load i64, ptr %array_element8, align 4
  %29 = load i64, ptr %index_ptr1, align 4
  %30 = icmp ult i64 %29, %vector_length
  br i1 %30, label %body3, label %end_for5

body3:                                            ; preds = %cond2
  %31 = load i64, ptr %offset_var, align 4
  %32 = getelementptr ptr, ptr %9, i64 %31
  %33 = load i64, ptr %32, align 4
  %34 = load ptr, ptr %array_ptr, align 8
  %array_index9 = load i64, ptr %index_ptr, align 4
  %35 = sub i64 2, %array_index9
  call void @builtin_range_check(i64 %35)
  %index_access10 = getelementptr [3 x ptr], ptr %34, i64 0, i64 %array_index9
  %array_element11 = load ptr, ptr %index_access10, align 8
  %array_index12 = load i64, ptr %index_ptr1, align 4
  %vector_length13 = load i64, ptr %array_element11, align 4
  %36 = sub i64 %vector_length13, 1
  %37 = sub i64 %36, %array_index12
  call void @builtin_range_check(i64 %37)
  %vector_data = getelementptr i64, ptr %array_element11, i64 1
  %index_access14 = getelementptr i64, ptr %vector_data, i64 %array_index12
  %array_element15 = load i64, ptr %index_access14, align 4
  store i64 %33, ptr %index_access14, align 4
  %38 = add i64 1, %31
  store i64 %38, ptr %offset_var, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index = load i64, ptr %index_ptr1, align 4
  %39 = add i64 %index, 1
  store i64 %39, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  br label %next

func_1_dispatch:                                  ; preds = %entry
  %40 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var19, align 4
  %41 = load i64, ptr %offset_var19, align 4
  %42 = load ptr, ptr %array_ptr20, align 8
  store i64 0, ptr %index_ptr21, align 4
  br label %cond22

cond22:                                           ; preds = %next24, %func_1_dispatch
  %43 = load i64, ptr %index_ptr21, align 4
  %44 = icmp ult i64 %43, 3
  br i1 %44, label %body23, label %end_for25

body23:                                           ; preds = %cond22
  %45 = load i64, ptr %offset_var19, align 4
  %46 = getelementptr ptr, ptr %40, i64 %45
  %47 = load i64, ptr %offset_var19, align 4
  %array_length26 = getelementptr ptr, ptr %46, i64 %47
  %48 = load i64, ptr %array_length26, align 4
  %49 = add i64 %47, 1
  store i64 %49, ptr %offset_var19, align 4
  %50 = call ptr @vector_new(i64 %48)
  %load_array27 = load ptr, ptr %array_ptr20, align 8
  %array_index28 = load i64, ptr %index_ptr21, align 4
  %51 = sub i64 2, %array_index28
  call void @builtin_range_check(i64 %51)
  %index_access29 = getelementptr [3 x ptr], ptr %load_array27, i64 0, i64 %array_index28
  %array_element30 = load ptr, ptr %index_access29, align 8
  store ptr %50, ptr %index_access29, align 8
  %52 = load ptr, ptr %array_ptr20, align 8
  store i64 0, ptr %index_ptr31, align 4
  br label %cond32

next24:                                           ; preds = %end_for35
  %index49 = load i64, ptr %index_ptr21, align 4
  %53 = add i64 %index49, 1
  store i64 %53, ptr %index_ptr21, align 4
  br label %cond22

end_for25:                                        ; preds = %cond22
  %54 = load ptr, ptr %array_ptr20, align 8
  %55 = load i64, ptr %offset_var19, align 4
  %56 = call ptr @array_input(ptr %54)
  %vector_length50 = load i64, ptr %56, align 4
  %57 = mul i64 %vector_length50, 1
  %58 = add i64 %57, 1
  %heap_size51 = add i64 %58, 1
  %59 = call ptr @heap_malloc(i64 %heap_size51)
  %vector_length52 = load i64, ptr %56, align 4
  %60 = mul i64 %vector_length52, 1
  %61 = add i64 %60, 1
  call void @memcpy(ptr %56, ptr %59, i64 %61)
  %62 = getelementptr ptr, ptr %59, i64 %61
  store i64 %58, ptr %62, align 4
  call void @set_tape_data(ptr %59, i64 %heap_size51)
  ret void

cond32:                                           ; preds = %next34, %body23
  %array_index36 = load i64, ptr %index_ptr21, align 4
  %63 = sub i64 2, %array_index36
  call void @builtin_range_check(i64 %63)
  %index_access37 = getelementptr [3 x ptr], ptr %52, i64 0, i64 %array_index36
  %array_element38 = load ptr, ptr %index_access37, align 8
  %vector_length39 = load i64, ptr %array_element38, align 4
  %64 = load i64, ptr %index_ptr31, align 4
  %65 = icmp ult i64 %64, %vector_length39
  br i1 %65, label %body33, label %end_for35

body33:                                           ; preds = %cond32
  %66 = load i64, ptr %offset_var19, align 4
  %67 = getelementptr ptr, ptr %46, i64 %66
  %68 = load i64, ptr %67, align 4
  %69 = load ptr, ptr %array_ptr20, align 8
  %array_index40 = load i64, ptr %index_ptr21, align 4
  %70 = sub i64 2, %array_index40
  call void @builtin_range_check(i64 %70)
  %index_access41 = getelementptr [3 x ptr], ptr %69, i64 0, i64 %array_index40
  %array_element42 = load ptr, ptr %index_access41, align 8
  %array_index43 = load i64, ptr %index_ptr31, align 4
  %vector_length44 = load i64, ptr %array_element42, align 4
  %71 = sub i64 %vector_length44, 1
  %72 = sub i64 %71, %array_index43
  call void @builtin_range_check(i64 %72)
  %vector_data45 = getelementptr i64, ptr %array_element42, i64 1
  %index_access46 = getelementptr i64, ptr %vector_data45, i64 %array_index43
  %array_element47 = load i64, ptr %index_access46, align 4
  store i64 %68, ptr %index_access46, align 4
  %73 = add i64 1, %66
  store i64 %73, ptr %offset_var19, align 4
  br label %next34

next34:                                           ; preds = %body33
  %index48 = load i64, ptr %index_ptr31, align 4
  %74 = add i64 %index48, 1
  store i64 %74, ptr %index_ptr31, align 4
  br label %cond32

end_for35:                                        ; preds = %cond32
  br label %next24

func_2_dispatch:                                  ; preds = %entry
  %75 = call ptr @array_output_u32()
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr53, align 4
  br label %cond54

cond54:                                           ; preds = %next56, %func_2_dispatch
  %76 = load i64, ptr %index_ptr53, align 4
  %77 = icmp ult i64 %76, 3
  br i1 %77, label %body55, label %end_for57

body55:                                           ; preds = %cond54
  %78 = load i64, ptr %array_size, align 4
  %79 = add i64 %78, 1
  store i64 %79, ptr %array_size, align 4
  store i64 0, ptr %index_ptr58, align 4
  br label %cond59

next56:                                           ; preds = %end_for62
  %index76 = load i64, ptr %index_ptr53, align 4
  %80 = add i64 %index76, 1
  store i64 %80, ptr %index_ptr53, align 4
  br label %cond54

end_for57:                                        ; preds = %cond54
  %81 = load i64, ptr %array_size, align 4
  %heap_size77 = add i64 %81, 1
  %82 = call ptr @heap_malloc(i64 %heap_size77)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr78, align 4
  br label %cond79

cond59:                                           ; preds = %next61, %body55
  %array_index63 = load i64, ptr %index_ptr53, align 4
  %83 = sub i64 2, %array_index63
  call void @builtin_range_check(i64 %83)
  %index_access64 = getelementptr [3 x ptr], ptr %75, i64 0, i64 %array_index63
  %array_element65 = load ptr, ptr %index_access64, align 8
  %vector_length66 = load i64, ptr %array_element65, align 4
  %84 = load i64, ptr %index_ptr58, align 4
  %85 = icmp ult i64 %84, %vector_length66
  br i1 %85, label %body60, label %end_for62

body60:                                           ; preds = %cond59
  %array_index67 = load i64, ptr %index_ptr53, align 4
  %86 = sub i64 2, %array_index67
  call void @builtin_range_check(i64 %86)
  %index_access68 = getelementptr [3 x ptr], ptr %75, i64 0, i64 %array_index67
  %array_element69 = load ptr, ptr %index_access68, align 8
  %array_index70 = load i64, ptr %index_ptr58, align 4
  %vector_length71 = load i64, ptr %array_element69, align 4
  %87 = sub i64 %vector_length71, 1
  %88 = sub i64 %87, %array_index70
  call void @builtin_range_check(i64 %88)
  %vector_data72 = getelementptr i64, ptr %array_element69, i64 1
  %index_access73 = getelementptr i64, ptr %vector_data72, i64 %array_index70
  %array_element74 = load i64, ptr %index_access73, align 4
  %89 = load i64, ptr %array_size, align 4
  %90 = add i64 %89, 1
  store i64 %90, ptr %array_size, align 4
  br label %next61

next61:                                           ; preds = %body60
  %index75 = load i64, ptr %index_ptr58, align 4
  %91 = add i64 %index75, 1
  store i64 %91, ptr %index_ptr58, align 4
  br label %cond59

end_for62:                                        ; preds = %cond59
  br label %next56

cond79:                                           ; preds = %next81, %end_for57
  %92 = load i64, ptr %index_ptr78, align 4
  %93 = icmp ult i64 %92, 3
  br i1 %93, label %body80, label %end_for82

body80:                                           ; preds = %cond79
  %array_index83 = load i64, ptr %index_ptr78, align 4
  %94 = sub i64 2, %array_index83
  call void @builtin_range_check(i64 %94)
  %index_access84 = getelementptr [3 x ptr], ptr %75, i64 0, i64 %array_index83
  %array_element85 = load ptr, ptr %index_access84, align 8
  %95 = load i64, ptr %buffer_offset, align 4
  %96 = add i64 %95, 1
  store i64 %96, ptr %buffer_offset, align 4
  %97 = getelementptr ptr, ptr %82, i64 %95
  %vector_length86 = load i64, ptr %array_element85, align 4
  store i64 %vector_length86, ptr %97, align 4
  store i64 0, ptr %index_ptr87, align 4
  br label %cond88

next81:                                           ; preds = %end_for91
  %index109 = load i64, ptr %index_ptr78, align 4
  %98 = add i64 %index109, 1
  store i64 %98, ptr %index_ptr78, align 4
  br label %cond79

end_for82:                                        ; preds = %cond79
  %99 = load i64, ptr %buffer_offset, align 4
  %100 = getelementptr ptr, ptr %82, i64 %99
  store i64 %81, ptr %100, align 4
  call void @set_tape_data(ptr %82, i64 %heap_size77)
  ret void

cond88:                                           ; preds = %next90, %body80
  %array_index92 = load i64, ptr %index_ptr78, align 4
  %vector_length93 = load i64, ptr %75, align 4
  %101 = sub i64 %vector_length93, 1
  %102 = sub i64 %101, %array_index92
  call void @builtin_range_check(i64 %102)
  %vector_data94 = getelementptr i64, ptr %75, i64 1
  %index_access95 = getelementptr i64, ptr %vector_data94, i64 %array_index92
  %array_element96 = load ptr, ptr %index_access95, align 8
  %vector_length97 = load i64, ptr %array_element96, align 4
  %103 = load i64, ptr %index_ptr87, align 4
  %104 = icmp ult i64 %103, %vector_length97
  br i1 %104, label %body89, label %end_for91

body89:                                           ; preds = %cond88
  %array_index98 = load i64, ptr %index_ptr78, align 4
  %vector_length99 = load i64, ptr %75, align 4
  %105 = sub i64 %vector_length99, 1
  %106 = sub i64 %105, %array_index98
  call void @builtin_range_check(i64 %106)
  %vector_data100 = getelementptr i64, ptr %75, i64 1
  %index_access101 = getelementptr i64, ptr %vector_data100, i64 %array_index98
  %array_element102 = load ptr, ptr %index_access101, align 8
  %array_index103 = load i64, ptr %index_ptr87, align 4
  %vector_length104 = load i64, ptr %array_element102, align 4
  %107 = sub i64 %vector_length104, 1
  %108 = sub i64 %107, %array_index103
  call void @builtin_range_check(i64 %108)
  %vector_data105 = getelementptr i64, ptr %array_element102, i64 1
  %index_access106 = getelementptr i64, ptr %vector_data105, i64 %array_index103
  %array_element107 = load i64, ptr %index_access106, align 4
  %109 = load i64, ptr %buffer_offset, align 4
  %110 = getelementptr ptr, ptr %82, i64 %109
  store i64 %array_element107, ptr %110, align 4
  %111 = load i64, ptr %buffer_offset, align 4
  %112 = add i64 %111, 1
  store i64 %112, ptr %buffer_offset, align 4
  br label %next90

next90:                                           ; preds = %body89
  %index108 = load i64, ptr %index_ptr87, align 4
  %113 = add i64 %index108, 1
  store i64 %113, ptr %index_ptr87, align 4
  br label %cond88

end_for91:                                        ; preds = %cond88
  br label %next81

func_3_dispatch:                                  ; preds = %entry
  %114 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var110, align 4
  %115 = load i64, ptr %offset_var110, align 4
  %116 = load ptr, ptr %array_ptr111, align 8
  store i64 0, ptr %index_ptr112, align 4
  br label %cond113

cond113:                                          ; preds = %next115, %func_3_dispatch
  %117 = load i64, ptr %index_ptr112, align 4
  %118 = icmp ult i64 %117, 3
  br i1 %118, label %body114, label %end_for116

body114:                                          ; preds = %cond113
  %119 = load i64, ptr %offset_var110, align 4
  %120 = getelementptr ptr, ptr %114, i64 %119
  %121 = load i64, ptr %offset_var110, align 4
  %array_length117 = getelementptr ptr, ptr %120, i64 %121
  %122 = load i64, ptr %array_length117, align 4
  %123 = add i64 %121, 1
  store i64 %123, ptr %offset_var110, align 4
  %124 = call ptr @vector_new(i64 %122)
  %load_array118 = load ptr, ptr %array_ptr111, align 8
  %array_index119 = load i64, ptr %index_ptr112, align 4
  %125 = sub i64 2, %array_index119
  call void @builtin_range_check(i64 %125)
  %index_access120 = getelementptr [3 x ptr], ptr %load_array118, i64 0, i64 %array_index119
  %array_element121 = load ptr, ptr %index_access120, align 8
  store ptr %124, ptr %index_access120, align 8
  %126 = load ptr, ptr %array_ptr111, align 8
  store i64 0, ptr %index_ptr122, align 4
  br label %cond123

next115:                                          ; preds = %end_for126
  %index140 = load i64, ptr %index_ptr112, align 4
  %127 = add i64 %index140, 1
  store i64 %127, ptr %index_ptr112, align 4
  br label %cond113

end_for116:                                       ; preds = %cond113
  %128 = load ptr, ptr %array_ptr111, align 8
  %129 = load i64, ptr %offset_var110, align 4
  %130 = getelementptr ptr, ptr %114, i64 %129
  %131 = load i64, ptr %130, align 4
  %132 = call ptr @array_input_address(ptr %128, i64 %131)
  store i64 0, ptr %array_size141, align 4
  %133 = load i64, ptr %array_size141, align 4
  %134 = add i64 %133, 1
  store i64 %134, ptr %array_size141, align 4
  store i64 0, ptr %index_ptr142, align 4
  br label %cond143

cond123:                                          ; preds = %next125, %body114
  %array_index127 = load i64, ptr %index_ptr112, align 4
  %135 = sub i64 2, %array_index127
  call void @builtin_range_check(i64 %135)
  %index_access128 = getelementptr [3 x ptr], ptr %126, i64 0, i64 %array_index127
  %array_element129 = load ptr, ptr %index_access128, align 8
  %vector_length130 = load i64, ptr %array_element129, align 4
  %136 = load i64, ptr %index_ptr122, align 4
  %137 = icmp ult i64 %136, %vector_length130
  br i1 %137, label %body124, label %end_for126

body124:                                          ; preds = %cond123
  %138 = load i64, ptr %offset_var110, align 4
  %139 = getelementptr ptr, ptr %120, i64 %138
  %140 = load ptr, ptr %array_ptr111, align 8
  %array_index131 = load i64, ptr %index_ptr112, align 4
  %141 = sub i64 2, %array_index131
  call void @builtin_range_check(i64 %141)
  %index_access132 = getelementptr [3 x ptr], ptr %140, i64 0, i64 %array_index131
  %array_element133 = load ptr, ptr %index_access132, align 8
  %array_index134 = load i64, ptr %index_ptr122, align 4
  %vector_length135 = load i64, ptr %array_element133, align 4
  %142 = sub i64 %vector_length135, 1
  %143 = sub i64 %142, %array_index134
  call void @builtin_range_check(i64 %143)
  %vector_data136 = getelementptr i64, ptr %array_element133, i64 1
  %index_access137 = getelementptr ptr, ptr %vector_data136, i64 %array_index134
  %array_element138 = load ptr, ptr %index_access137, align 8
  store ptr %139, ptr %index_access137, align 8
  %144 = add i64 4, %138
  store i64 %144, ptr %offset_var110, align 4
  br label %next125

next125:                                          ; preds = %body124
  %index139 = load i64, ptr %index_ptr122, align 4
  %145 = add i64 %index139, 1
  store i64 %145, ptr %index_ptr122, align 4
  br label %cond123

end_for126:                                       ; preds = %cond123
  br label %next115

cond143:                                          ; preds = %next145, %end_for116
  %vector_length147 = load i64, ptr %132, align 4
  %146 = load i64, ptr %index_ptr142, align 4
  %147 = icmp ult i64 %146, %vector_length147
  br i1 %147, label %body144, label %end_for146

body144:                                          ; preds = %cond143
  %array_index148 = load i64, ptr %index_ptr142, align 4
  %vector_length149 = load i64, ptr %132, align 4
  %148 = sub i64 %vector_length149, 1
  %149 = sub i64 %148, %array_index148
  call void @builtin_range_check(i64 %149)
  %vector_data150 = getelementptr i64, ptr %132, i64 1
  %index_access151 = getelementptr ptr, ptr %vector_data150, i64 %array_index148
  %array_element152 = load ptr, ptr %index_access151, align 8
  %150 = load i64, ptr %array_size141, align 4
  %151 = add i64 %150, 4
  store i64 %151, ptr %array_size141, align 4
  br label %next145

next145:                                          ; preds = %body144
  %index153 = load i64, ptr %index_ptr142, align 4
  %152 = add i64 %index153, 1
  store i64 %152, ptr %index_ptr142, align 4
  br label %cond143

end_for146:                                       ; preds = %cond143
  %153 = load i64, ptr %array_size141, align 4
  %heap_size154 = add i64 %153, 1
  %154 = call ptr @heap_malloc(i64 %heap_size154)
  store i64 0, ptr %buffer_offset155, align 4
  %155 = load i64, ptr %buffer_offset155, align 4
  %156 = add i64 %155, 1
  store i64 %156, ptr %buffer_offset155, align 4
  %157 = getelementptr ptr, ptr %154, i64 %155
  %vector_length156 = load i64, ptr %132, align 4
  store i64 %vector_length156, ptr %157, align 4
  store i64 0, ptr %index_ptr157, align 4
  br label %cond158

cond158:                                          ; preds = %next160, %end_for146
  %vector_length162 = load i64, ptr %132, align 4
  %158 = load i64, ptr %index_ptr157, align 4
  %159 = icmp ult i64 %158, %vector_length162
  br i1 %159, label %body159, label %end_for161

body159:                                          ; preds = %cond158
  %array_index163 = load i64, ptr %index_ptr157, align 4
  %vector_length164 = load i64, ptr %132, align 4
  %160 = sub i64 %vector_length164, 1
  %161 = sub i64 %160, %array_index163
  call void @builtin_range_check(i64 %161)
  %vector_data165 = getelementptr i64, ptr %132, i64 1
  %index_access166 = getelementptr ptr, ptr %vector_data165, i64 %array_index163
  %array_element167 = load ptr, ptr %index_access166, align 8
  %162 = load i64, ptr %buffer_offset155, align 4
  %163 = getelementptr ptr, ptr %154, i64 %162
  %164 = getelementptr i64, ptr %array_element167, i64 0
  %165 = load i64, ptr %164, align 4
  %166 = getelementptr i64, ptr %163, i64 0
  store i64 %165, ptr %166, align 4
  %167 = getelementptr i64, ptr %array_element167, i64 1
  %168 = load i64, ptr %167, align 4
  %169 = getelementptr i64, ptr %163, i64 1
  store i64 %168, ptr %169, align 4
  %170 = getelementptr i64, ptr %array_element167, i64 2
  %171 = load i64, ptr %170, align 4
  %172 = getelementptr i64, ptr %163, i64 2
  store i64 %171, ptr %172, align 4
  %173 = getelementptr i64, ptr %array_element167, i64 3
  %174 = load i64, ptr %173, align 4
  %175 = getelementptr i64, ptr %163, i64 3
  store i64 %174, ptr %175, align 4
  %176 = load i64, ptr %buffer_offset155, align 4
  %177 = add i64 %176, 4
  store i64 %177, ptr %buffer_offset155, align 4
  br label %next160

next160:                                          ; preds = %body159
  %index168 = load i64, ptr %index_ptr157, align 4
  %178 = add i64 %index168, 1
  store i64 %178, ptr %index_ptr157, align 4
  br label %cond158

end_for161:                                       ; preds = %cond158
  %179 = load i64, ptr %buffer_offset155, align 4
  %180 = getelementptr ptr, ptr %154, i64 %179
  store i64 %153, ptr %180, align 4
  call void @set_tape_data(ptr %154, i64 %heap_size154)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %181 = call ptr @array_output_address()
  store i64 0, ptr %array_size169, align 4
  store i64 0, ptr %index_ptr170, align 4
  br label %cond171

cond171:                                          ; preds = %next173, %func_4_dispatch
  %182 = load i64, ptr %index_ptr170, align 4
  %183 = icmp ult i64 %182, 3
  br i1 %183, label %body172, label %end_for174

body172:                                          ; preds = %cond171
  %184 = load i64, ptr %array_size169, align 4
  %185 = add i64 %184, 1
  store i64 %185, ptr %array_size169, align 4
  store i64 0, ptr %index_ptr175, align 4
  br label %cond176

next173:                                          ; preds = %end_for179
  %index193 = load i64, ptr %index_ptr170, align 4
  %186 = add i64 %index193, 1
  store i64 %186, ptr %index_ptr170, align 4
  br label %cond171

end_for174:                                       ; preds = %cond171
  %187 = load i64, ptr %array_size169, align 4
  %heap_size194 = add i64 %187, 1
  %188 = call ptr @heap_malloc(i64 %heap_size194)
  store i64 0, ptr %buffer_offset195, align 4
  store i64 0, ptr %index_ptr196, align 4
  br label %cond197

cond176:                                          ; preds = %next178, %body172
  %array_index180 = load i64, ptr %index_ptr170, align 4
  %189 = sub i64 2, %array_index180
  call void @builtin_range_check(i64 %189)
  %index_access181 = getelementptr [3 x ptr], ptr %181, i64 0, i64 %array_index180
  %array_element182 = load ptr, ptr %index_access181, align 8
  %vector_length183 = load i64, ptr %array_element182, align 4
  %190 = load i64, ptr %index_ptr175, align 4
  %191 = icmp ult i64 %190, %vector_length183
  br i1 %191, label %body177, label %end_for179

body177:                                          ; preds = %cond176
  %array_index184 = load i64, ptr %index_ptr170, align 4
  %192 = sub i64 2, %array_index184
  call void @builtin_range_check(i64 %192)
  %index_access185 = getelementptr [3 x ptr], ptr %181, i64 0, i64 %array_index184
  %array_element186 = load ptr, ptr %index_access185, align 8
  %array_index187 = load i64, ptr %index_ptr175, align 4
  %vector_length188 = load i64, ptr %array_element186, align 4
  %193 = sub i64 %vector_length188, 1
  %194 = sub i64 %193, %array_index187
  call void @builtin_range_check(i64 %194)
  %vector_data189 = getelementptr i64, ptr %array_element186, i64 1
  %index_access190 = getelementptr ptr, ptr %vector_data189, i64 %array_index187
  %array_element191 = load ptr, ptr %index_access190, align 8
  %195 = load i64, ptr %array_size169, align 4
  %196 = add i64 %195, 4
  store i64 %196, ptr %array_size169, align 4
  br label %next178

next178:                                          ; preds = %body177
  %index192 = load i64, ptr %index_ptr175, align 4
  %197 = add i64 %index192, 1
  store i64 %197, ptr %index_ptr175, align 4
  br label %cond176

end_for179:                                       ; preds = %cond176
  br label %next173

cond197:                                          ; preds = %next199, %end_for174
  %198 = load i64, ptr %index_ptr196, align 4
  %199 = icmp ult i64 %198, 3
  br i1 %199, label %body198, label %end_for200

body198:                                          ; preds = %cond197
  %array_index201 = load i64, ptr %index_ptr196, align 4
  %200 = sub i64 2, %array_index201
  call void @builtin_range_check(i64 %200)
  %index_access202 = getelementptr [3 x ptr], ptr %181, i64 0, i64 %array_index201
  %array_element203 = load ptr, ptr %index_access202, align 8
  %201 = load i64, ptr %buffer_offset195, align 4
  %202 = add i64 %201, 1
  store i64 %202, ptr %buffer_offset195, align 4
  %203 = getelementptr ptr, ptr %188, i64 %201
  %vector_length204 = load i64, ptr %array_element203, align 4
  store i64 %vector_length204, ptr %203, align 4
  store i64 0, ptr %index_ptr205, align 4
  br label %cond206

next199:                                          ; preds = %end_for209
  %index227 = load i64, ptr %index_ptr196, align 4
  %204 = add i64 %index227, 1
  store i64 %204, ptr %index_ptr196, align 4
  br label %cond197

end_for200:                                       ; preds = %cond197
  %205 = load i64, ptr %buffer_offset195, align 4
  %206 = getelementptr ptr, ptr %188, i64 %205
  store i64 %187, ptr %206, align 4
  call void @set_tape_data(ptr %188, i64 %heap_size194)
  ret void

cond206:                                          ; preds = %next208, %body198
  %array_index210 = load i64, ptr %index_ptr196, align 4
  %vector_length211 = load i64, ptr %181, align 4
  %207 = sub i64 %vector_length211, 1
  %208 = sub i64 %207, %array_index210
  call void @builtin_range_check(i64 %208)
  %vector_data212 = getelementptr i64, ptr %181, i64 1
  %index_access213 = getelementptr ptr, ptr %vector_data212, i64 %array_index210
  %array_element214 = load ptr, ptr %index_access213, align 8
  %vector_length215 = load i64, ptr %array_element214, align 4
  %209 = load i64, ptr %index_ptr205, align 4
  %210 = icmp ult i64 %209, %vector_length215
  br i1 %210, label %body207, label %end_for209

body207:                                          ; preds = %cond206
  %array_index216 = load i64, ptr %index_ptr196, align 4
  %vector_length217 = load i64, ptr %181, align 4
  %211 = sub i64 %vector_length217, 1
  %212 = sub i64 %211, %array_index216
  call void @builtin_range_check(i64 %212)
  %vector_data218 = getelementptr i64, ptr %181, i64 1
  %index_access219 = getelementptr ptr, ptr %vector_data218, i64 %array_index216
  %array_element220 = load ptr, ptr %index_access219, align 8
  %array_index221 = load i64, ptr %index_ptr205, align 4
  %vector_length222 = load i64, ptr %array_element220, align 4
  %213 = sub i64 %vector_length222, 1
  %214 = sub i64 %213, %array_index221
  call void @builtin_range_check(i64 %214)
  %vector_data223 = getelementptr i64, ptr %array_element220, i64 1
  %index_access224 = getelementptr ptr, ptr %vector_data223, i64 %array_index221
  %array_element225 = load ptr, ptr %index_access224, align 8
  %215 = load i64, ptr %buffer_offset195, align 4
  %216 = getelementptr ptr, ptr %188, i64 %215
  %217 = getelementptr i64, ptr %array_element225, i64 0
  %218 = load i64, ptr %217, align 4
  %219 = getelementptr i64, ptr %216, i64 0
  store i64 %218, ptr %219, align 4
  %220 = getelementptr i64, ptr %array_element225, i64 1
  %221 = load i64, ptr %220, align 4
  %222 = getelementptr i64, ptr %216, i64 1
  store i64 %221, ptr %222, align 4
  %223 = getelementptr i64, ptr %array_element225, i64 2
  %224 = load i64, ptr %223, align 4
  %225 = getelementptr i64, ptr %216, i64 2
  store i64 %224, ptr %225, align 4
  %226 = getelementptr i64, ptr %array_element225, i64 3
  %227 = load i64, ptr %226, align 4
  %228 = getelementptr i64, ptr %216, i64 3
  store i64 %227, ptr %228, align 4
  %229 = load i64, ptr %buffer_offset195, align 4
  %230 = add i64 %229, 4
  store i64 %230, ptr %buffer_offset195, align 4
  br label %next208

next208:                                          ; preds = %body207
  %index226 = load i64, ptr %index_ptr205, align 4
  %231 = add i64 %index226, 1
  store i64 %231, ptr %index_ptr205, align 4
  br label %cond206

end_for209:                                       ; preds = %cond206
  br label %next199
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
