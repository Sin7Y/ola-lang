; ModuleID = 'ERC20'
source_filename = "ERC20"

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

define void @_mint(ptr %0, i64 %1) {
entry:
  %value = alloca i64, align 8
  %to = alloca ptr, align 8
  store ptr %0, ptr %to, align 8
  store i64 %1, ptr %value, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 3, ptr %7, align 4
  call void @get_storage(ptr %3, ptr %2)
  %8 = getelementptr i64, ptr %2, i64 3
  %storage_value = load i64, ptr %8, align 4
  %9 = load i64, ptr %value, align 4
  %10 = add i64 %storage_value, %9
  call void @builtin_range_check(i64 %10)
  %11 = call ptr @heap_malloc(i64 4)
  %12 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %11, i64 3
  store i64 3, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 4)
  %17 = getelementptr i64, ptr %16, i64 0
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %16, i64 1
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %16, i64 2
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %16, i64 3
  store i64 %10, ptr %20, align 4
  call void @set_storage(ptr %11, ptr %16)
  %21 = load ptr, ptr %to, align 8
  %22 = call ptr @heap_malloc(i64 4)
  %23 = getelementptr i64, ptr %22, i64 0
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %22, i64 1
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %22, i64 2
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %22, i64 3
  store i64 4, ptr %26, align 4
  %27 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %22, ptr %27, i64 4)
  %28 = getelementptr i64, ptr %27, i64 4
  call void @memcpy(ptr %21, ptr %28, i64 4)
  %29 = getelementptr i64, ptr %28, i64 4
  %30 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %27, ptr %30, i64 8)
  %31 = load ptr, ptr %to, align 8
  %32 = call ptr @heap_malloc(i64 4)
  %33 = getelementptr i64, ptr %32, i64 0
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %32, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %32, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %32, i64 3
  store i64 4, ptr %36, align 4
  %37 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %32, ptr %37, i64 4)
  %38 = getelementptr i64, ptr %37, i64 4
  call void @memcpy(ptr %31, ptr %38, i64 4)
  %39 = getelementptr i64, ptr %38, i64 4
  %40 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %37, ptr %40, i64 8)
  %41 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %40, ptr %41)
  %42 = getelementptr i64, ptr %41, i64 3
  %storage_value1 = load i64, ptr %42, align 4
  %43 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %40, ptr %43, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %43, i64 3
  %44 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %44, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %45 = load i64, ptr %value, align 4
  %46 = add i64 %storage_value1, %45
  call void @builtin_range_check(i64 %46)
  %47 = call ptr @heap_malloc(i64 4)
  %48 = getelementptr i64, ptr %47, i64 0
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %47, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %47, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %47, i64 3
  store i64 %46, ptr %51, align 4
  call void @set_storage(ptr %30, ptr %47)
  %52 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %52, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access2 = getelementptr i64, ptr %52, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %52, i64 1
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %52, i64 0
  store i64 0, ptr %index_access4, align 4
  %53 = call ptr @heap_malloc(i64 4)
  %index_access5 = getelementptr i64, ptr %53, i64 3
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %53, i64 2
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %53, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %53, i64 0
  store i64 0, ptr %index_access8, align 4
  %54 = load ptr, ptr %to, align 8
  %55 = load i64, ptr %value, align 4
  %56 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %56, i64 1
  %topic_ptr = getelementptr ptr, ptr %vector_data, i64 0
  store ptr %52, ptr %topic_ptr, align 8
  %topic_ptr9 = getelementptr ptr, ptr %vector_data, i64 1
  store ptr %53, ptr %topic_ptr9, align 8
  %topic_ptr10 = getelementptr ptr, ptr %vector_data, i64 2
  store ptr %54, ptr %topic_ptr10, align 8
  %57 = call ptr @vector_new(i64 1)
  %58 = getelementptr ptr, ptr %57, i64 1
  store i64 %55, ptr %58, align 4
  call void @emit_event(ptr %56, ptr %57)
  ret void
}

define void @_burn(ptr %0, i64 %1) {
entry:
  %value = alloca i64, align 8
  %from = alloca ptr, align 8
  store ptr %0, ptr %from, align 8
  store i64 %1, ptr %value, align 4
  %2 = load ptr, ptr %from, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 4, ptr %7, align 4
  %8 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %3, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = getelementptr i64, ptr %9, i64 4
  %11 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %8, ptr %11, i64 8)
  %12 = load ptr, ptr %from, align 8
  %13 = call ptr @heap_malloc(i64 4)
  %14 = getelementptr i64, ptr %13, i64 0
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %13, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %13, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %13, i64 3
  store i64 4, ptr %17, align 4
  %18 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %13, ptr %18, i64 4)
  %19 = getelementptr i64, ptr %18, i64 4
  call void @memcpy(ptr %12, ptr %19, i64 4)
  %20 = getelementptr i64, ptr %19, i64 4
  %21 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %18, ptr %21, i64 8)
  %22 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %21, ptr %22)
  %23 = getelementptr i64, ptr %22, i64 3
  %storage_value = load i64, ptr %23, align 4
  %24 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %21, ptr %24, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %24, i64 3
  %25 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %25, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %26 = load i64, ptr %value, align 4
  %27 = sub i64 %storage_value, %26
  call void @builtin_range_check(i64 %27)
  %28 = call ptr @heap_malloc(i64 4)
  %29 = getelementptr i64, ptr %28, i64 0
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %28, i64 1
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %28, i64 2
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %28, i64 3
  store i64 %27, ptr %32, align 4
  call void @set_storage(ptr %11, ptr %28)
  %33 = call ptr @heap_malloc(i64 4)
  %34 = call ptr @heap_malloc(i64 4)
  %35 = getelementptr i64, ptr %34, i64 0
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %34, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %34, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %34, i64 3
  store i64 3, ptr %38, align 4
  call void @get_storage(ptr %34, ptr %33)
  %39 = getelementptr i64, ptr %33, i64 3
  %storage_value1 = load i64, ptr %39, align 4
  %40 = load i64, ptr %value, align 4
  %41 = sub i64 %storage_value1, %40
  call void @builtin_range_check(i64 %41)
  %42 = call ptr @heap_malloc(i64 4)
  %43 = getelementptr i64, ptr %42, i64 0
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %42, i64 1
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %42, i64 2
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %42, i64 3
  store i64 3, ptr %46, align 4
  %47 = call ptr @heap_malloc(i64 4)
  %48 = getelementptr i64, ptr %47, i64 0
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %47, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %47, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %47, i64 3
  store i64 %41, ptr %51, align 4
  call void @set_storage(ptr %42, ptr %47)
  %52 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %52, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access2 = getelementptr i64, ptr %52, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %52, i64 1
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %52, i64 0
  store i64 0, ptr %index_access4, align 4
  %53 = load ptr, ptr %from, align 8
  %54 = call ptr @heap_malloc(i64 4)
  %index_access5 = getelementptr i64, ptr %54, i64 3
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %54, i64 2
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %54, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %54, i64 0
  store i64 0, ptr %index_access8, align 4
  %55 = load i64, ptr %value, align 4
  %56 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %56, i64 1
  %topic_ptr = getelementptr ptr, ptr %vector_data, i64 0
  store ptr %52, ptr %topic_ptr, align 8
  %topic_ptr9 = getelementptr ptr, ptr %vector_data, i64 1
  store ptr %53, ptr %topic_ptr9, align 8
  %topic_ptr10 = getelementptr ptr, ptr %vector_data, i64 2
  store ptr %54, ptr %topic_ptr10, align 8
  %57 = call ptr @vector_new(i64 1)
  %58 = getelementptr ptr, ptr %57, i64 1
  store i64 %55, ptr %58, align 4
  call void @emit_event(ptr %56, ptr %57)
  ret void
}

define void @_approve(ptr %0, ptr %1, i64 %2) {
entry:
  %value = alloca i64, align 8
  %spender = alloca ptr, align 8
  %owner = alloca ptr, align 8
  store ptr %0, ptr %owner, align 8
  store ptr %1, ptr %spender, align 8
  store i64 %2, ptr %value, align 4
  %3 = load ptr, ptr %owner, align 8
  %4 = call ptr @heap_malloc(i64 4)
  %5 = getelementptr i64, ptr %4, i64 0
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %4, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %4, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %4, i64 3
  store i64 5, ptr %8, align 4
  %9 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %4, ptr %9, i64 4)
  %10 = getelementptr i64, ptr %9, i64 4
  call void @memcpy(ptr %3, ptr %10, i64 4)
  %11 = getelementptr i64, ptr %10, i64 4
  %12 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %9, ptr %12, i64 8)
  %13 = load ptr, ptr %spender, align 8
  %14 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %12, ptr %14, i64 4)
  %15 = getelementptr i64, ptr %14, i64 4
  call void @memcpy(ptr %13, ptr %15, i64 4)
  %16 = getelementptr i64, ptr %15, i64 4
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %14, ptr %17, i64 8)
  %18 = load i64, ptr %value, align 4
  %19 = call ptr @heap_malloc(i64 4)
  %20 = getelementptr i64, ptr %19, i64 0
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %19, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %19, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %19, i64 3
  store i64 %18, ptr %23, align 4
  call void @set_storage(ptr %17, ptr %19)
  %24 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %24, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %24, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %24, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %24, i64 0
  store i64 0, ptr %index_access3, align 4
  %25 = load ptr, ptr %owner, align 8
  %26 = load ptr, ptr %spender, align 8
  %27 = load i64, ptr %value, align 4
  %28 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %28, i64 1
  %topic_ptr = getelementptr ptr, ptr %vector_data, i64 0
  store ptr %24, ptr %topic_ptr, align 8
  %topic_ptr4 = getelementptr ptr, ptr %vector_data, i64 1
  store ptr %25, ptr %topic_ptr4, align 8
  %topic_ptr5 = getelementptr ptr, ptr %vector_data, i64 2
  store ptr %26, ptr %topic_ptr5, align 8
  %29 = call ptr @vector_new(i64 1)
  %30 = getelementptr ptr, ptr %29, i64 1
  store i64 %27, ptr %30, align 4
  call void @emit_event(ptr %28, ptr %29)
  ret void
}

define void @_transfer(ptr %0, ptr %1, i64 %2) {
entry:
  %value = alloca i64, align 8
  %to = alloca ptr, align 8
  %from = alloca ptr, align 8
  store ptr %0, ptr %from, align 8
  store ptr %1, ptr %to, align 8
  store i64 %2, ptr %value, align 4
  %3 = load ptr, ptr %from, align 8
  %4 = call ptr @heap_malloc(i64 4)
  %5 = getelementptr i64, ptr %4, i64 0
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %4, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %4, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %4, i64 3
  store i64 4, ptr %8, align 4
  %9 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %4, ptr %9, i64 4)
  %10 = getelementptr i64, ptr %9, i64 4
  call void @memcpy(ptr %3, ptr %10, i64 4)
  %11 = getelementptr i64, ptr %10, i64 4
  %12 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %9, ptr %12, i64 8)
  %13 = load ptr, ptr %from, align 8
  %14 = call ptr @heap_malloc(i64 4)
  %15 = getelementptr i64, ptr %14, i64 0
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %14, i64 1
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %14, i64 2
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %14, i64 3
  store i64 4, ptr %18, align 4
  %19 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %14, ptr %19, i64 4)
  %20 = getelementptr i64, ptr %19, i64 4
  call void @memcpy(ptr %13, ptr %20, i64 4)
  %21 = getelementptr i64, ptr %20, i64 4
  %22 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %19, ptr %22, i64 8)
  %23 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %22, ptr %23)
  %24 = getelementptr i64, ptr %23, i64 3
  %storage_value = load i64, ptr %24, align 4
  %25 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %22, ptr %25, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %25, i64 3
  %26 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %26, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %27 = load i64, ptr %value, align 4
  %28 = sub i64 %storage_value, %27
  call void @builtin_range_check(i64 %28)
  %29 = call ptr @heap_malloc(i64 4)
  %30 = getelementptr i64, ptr %29, i64 0
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %29, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %29, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %29, i64 3
  store i64 %28, ptr %33, align 4
  call void @set_storage(ptr %12, ptr %29)
  %34 = load ptr, ptr %to, align 8
  %35 = call ptr @heap_malloc(i64 4)
  %36 = getelementptr i64, ptr %35, i64 0
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %35, i64 1
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %35, i64 2
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %35, i64 3
  store i64 4, ptr %39, align 4
  %40 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %35, ptr %40, i64 4)
  %41 = getelementptr i64, ptr %40, i64 4
  call void @memcpy(ptr %34, ptr %41, i64 4)
  %42 = getelementptr i64, ptr %41, i64 4
  %43 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %40, ptr %43, i64 8)
  %44 = load ptr, ptr %to, align 8
  %45 = call ptr @heap_malloc(i64 4)
  %46 = getelementptr i64, ptr %45, i64 0
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %45, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %45, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %45, i64 3
  store i64 4, ptr %49, align 4
  %50 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %45, ptr %50, i64 4)
  %51 = getelementptr i64, ptr %50, i64 4
  call void @memcpy(ptr %44, ptr %51, i64 4)
  %52 = getelementptr i64, ptr %51, i64 4
  %53 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %50, ptr %53, i64 8)
  %54 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %53, ptr %54)
  %55 = getelementptr i64, ptr %54, i64 3
  %storage_value1 = load i64, ptr %55, align 4
  %56 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %53, ptr %56, i64 4)
  %last_elem_ptr2 = getelementptr i64, ptr %56, i64 3
  %57 = load i64, ptr %last_elem_ptr2, align 4
  %last_elem3 = add i64 %57, 1
  store i64 %last_elem3, ptr %last_elem_ptr2, align 4
  %58 = load i64, ptr %value, align 4
  %59 = add i64 %storage_value1, %58
  call void @builtin_range_check(i64 %59)
  %60 = call ptr @heap_malloc(i64 4)
  %61 = getelementptr i64, ptr %60, i64 0
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %60, i64 1
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %60, i64 2
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %60, i64 3
  store i64 %59, ptr %64, align 4
  call void @set_storage(ptr %43, ptr %60)
  %65 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %65, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access4 = getelementptr i64, ptr %65, i64 2
  store i64 0, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %65, i64 1
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %65, i64 0
  store i64 0, ptr %index_access6, align 4
  %66 = load ptr, ptr %from, align 8
  %67 = load ptr, ptr %to, align 8
  %68 = load i64, ptr %value, align 4
  %69 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %69, i64 1
  %topic_ptr = getelementptr ptr, ptr %vector_data, i64 0
  store ptr %65, ptr %topic_ptr, align 8
  %topic_ptr7 = getelementptr ptr, ptr %vector_data, i64 1
  store ptr %66, ptr %topic_ptr7, align 8
  %topic_ptr8 = getelementptr ptr, ptr %vector_data, i64 2
  store ptr %67, ptr %topic_ptr8, align 8
  %70 = call ptr @vector_new(i64 1)
  %71 = getelementptr ptr, ptr %70, i64 1
  store i64 %68, ptr %71, align 4
  call void @emit_event(ptr %69, ptr %70)
  ret void
}

define i64 @approve(ptr %0, i64 %1) {
entry:
  %value = alloca i64, align 8
  %spender = alloca ptr, align 8
  store ptr %0, ptr %spender, align 8
  store i64 %1, ptr %value, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  call void @get_context_data(ptr %3, i64 8)
  %4 = getelementptr i64, ptr %2, i64 1
  call void @get_context_data(ptr %4, i64 9)
  %5 = getelementptr i64, ptr %2, i64 2
  call void @get_context_data(ptr %5, i64 10)
  %6 = getelementptr i64, ptr %2, i64 3
  call void @get_context_data(ptr %6, i64 11)
  %7 = load ptr, ptr %spender, align 8
  %8 = load i64, ptr %value, align 4
  call void @_approve(ptr %2, ptr %7, i64 %8)
  ret i64 1
}

define i64 @transfer(ptr %0, i64 %1) {
entry:
  %value = alloca i64, align 8
  %to = alloca ptr, align 8
  store ptr %0, ptr %to, align 8
  store i64 %1, ptr %value, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  call void @get_context_data(ptr %3, i64 8)
  %4 = getelementptr i64, ptr %2, i64 1
  call void @get_context_data(ptr %4, i64 9)
  %5 = getelementptr i64, ptr %2, i64 2
  call void @get_context_data(ptr %5, i64 10)
  %6 = getelementptr i64, ptr %2, i64 3
  call void @get_context_data(ptr %6, i64 11)
  %7 = load ptr, ptr %to, align 8
  %8 = load i64, ptr %value, align 4
  call void @_transfer(ptr %2, ptr %7, i64 %8)
  ret i64 1
}

define i64 @transferFrom(ptr %0, ptr %1, i64 %2) {
entry:
  %value = alloca i64, align 8
  %to = alloca ptr, align 8
  %from = alloca ptr, align 8
  store ptr %0, ptr %from, align 8
  store ptr %1, ptr %to, align 8
  store i64 %2, ptr %value, align 4
  %3 = load ptr, ptr %from, align 8
  %4 = call ptr @heap_malloc(i64 4)
  %5 = getelementptr i64, ptr %4, i64 0
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %4, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %4, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %4, i64 3
  store i64 4, ptr %8, align 4
  %9 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %4, ptr %9, i64 4)
  %10 = getelementptr i64, ptr %9, i64 4
  call void @memcpy(ptr %3, ptr %10, i64 4)
  %11 = getelementptr i64, ptr %10, i64 4
  %12 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %9, ptr %12, i64 8)
  %13 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %12, ptr %13)
  %14 = getelementptr i64, ptr %13, i64 3
  %storage_value = load i64, ptr %14, align 4
  %15 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %12, ptr %15, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %15, i64 3
  %16 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %16, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %17 = load i64, ptr %value, align 4
  %18 = icmp uge i64 %storage_value, %17
  %19 = zext i1 %18 to i64
  call void @builtin_assert(i64 %19)
  %20 = load ptr, ptr %from, align 8
  %21 = call ptr @heap_malloc(i64 4)
  %22 = getelementptr i64, ptr %21, i64 0
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %21, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %21, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %21, i64 3
  store i64 5, ptr %25, align 4
  %26 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %21, ptr %26, i64 4)
  %27 = getelementptr i64, ptr %26, i64 4
  call void @memcpy(ptr %20, ptr %27, i64 4)
  %28 = getelementptr i64, ptr %27, i64 4
  %29 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %26, ptr %29, i64 8)
  %30 = call ptr @heap_malloc(i64 4)
  %31 = getelementptr i64, ptr %30, i64 0
  call void @get_context_data(ptr %31, i64 8)
  %32 = getelementptr i64, ptr %30, i64 1
  call void @get_context_data(ptr %32, i64 9)
  %33 = getelementptr i64, ptr %30, i64 2
  call void @get_context_data(ptr %33, i64 10)
  %34 = getelementptr i64, ptr %30, i64 3
  call void @get_context_data(ptr %34, i64 11)
  %35 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %29, ptr %35, i64 4)
  %36 = getelementptr i64, ptr %35, i64 4
  call void @memcpy(ptr %30, ptr %36, i64 4)
  %37 = getelementptr i64, ptr %36, i64 4
  %38 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %35, ptr %38, i64 8)
  %39 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %38, ptr %39)
  %40 = getelementptr i64, ptr %39, i64 3
  %storage_value1 = load i64, ptr %40, align 4
  %41 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %38, ptr %41, i64 4)
  %last_elem_ptr2 = getelementptr i64, ptr %41, i64 3
  %42 = load i64, ptr %last_elem_ptr2, align 4
  %last_elem3 = add i64 %42, 1
  store i64 %last_elem3, ptr %last_elem_ptr2, align 4
  %43 = load i64, ptr %value, align 4
  %44 = icmp uge i64 %storage_value1, %43
  %45 = zext i1 %44 to i64
  call void @builtin_assert(i64 %45)
  %46 = load ptr, ptr %from, align 8
  %47 = load ptr, ptr %to, align 8
  %48 = load i64, ptr %value, align 4
  call void @_transfer(ptr %46, ptr %47, i64 %48)
  %49 = load ptr, ptr %from, align 8
  %50 = call ptr @heap_malloc(i64 4)
  %51 = getelementptr i64, ptr %50, i64 0
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %50, i64 1
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %50, i64 2
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %50, i64 3
  store i64 5, ptr %54, align 4
  %55 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %50, ptr %55, i64 4)
  %56 = getelementptr i64, ptr %55, i64 4
  call void @memcpy(ptr %49, ptr %56, i64 4)
  %57 = getelementptr i64, ptr %56, i64 4
  %58 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %55, ptr %58, i64 8)
  %59 = call ptr @heap_malloc(i64 4)
  %60 = getelementptr i64, ptr %59, i64 0
  call void @get_context_data(ptr %60, i64 8)
  %61 = getelementptr i64, ptr %59, i64 1
  call void @get_context_data(ptr %61, i64 9)
  %62 = getelementptr i64, ptr %59, i64 2
  call void @get_context_data(ptr %62, i64 10)
  %63 = getelementptr i64, ptr %59, i64 3
  call void @get_context_data(ptr %63, i64 11)
  %64 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %58, ptr %64, i64 4)
  %65 = getelementptr i64, ptr %64, i64 4
  call void @memcpy(ptr %59, ptr %65, i64 4)
  %66 = getelementptr i64, ptr %65, i64 4
  %67 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %64, ptr %67, i64 8)
  %68 = load ptr, ptr %from, align 8
  %69 = call ptr @heap_malloc(i64 4)
  %70 = getelementptr i64, ptr %69, i64 0
  store i64 0, ptr %70, align 4
  %71 = getelementptr i64, ptr %69, i64 1
  store i64 0, ptr %71, align 4
  %72 = getelementptr i64, ptr %69, i64 2
  store i64 0, ptr %72, align 4
  %73 = getelementptr i64, ptr %69, i64 3
  store i64 5, ptr %73, align 4
  %74 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %69, ptr %74, i64 4)
  %75 = getelementptr i64, ptr %74, i64 4
  call void @memcpy(ptr %68, ptr %75, i64 4)
  %76 = getelementptr i64, ptr %75, i64 4
  %77 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %74, ptr %77, i64 8)
  %78 = call ptr @heap_malloc(i64 4)
  %79 = getelementptr i64, ptr %78, i64 0
  call void @get_context_data(ptr %79, i64 8)
  %80 = getelementptr i64, ptr %78, i64 1
  call void @get_context_data(ptr %80, i64 9)
  %81 = getelementptr i64, ptr %78, i64 2
  call void @get_context_data(ptr %81, i64 10)
  %82 = getelementptr i64, ptr %78, i64 3
  call void @get_context_data(ptr %82, i64 11)
  %83 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %77, ptr %83, i64 4)
  %84 = getelementptr i64, ptr %83, i64 4
  call void @memcpy(ptr %78, ptr %84, i64 4)
  %85 = getelementptr i64, ptr %84, i64 4
  %86 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %83, ptr %86, i64 8)
  %87 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %86, ptr %87)
  %88 = getelementptr i64, ptr %87, i64 3
  %storage_value4 = load i64, ptr %88, align 4
  %89 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %86, ptr %89, i64 4)
  %last_elem_ptr5 = getelementptr i64, ptr %89, i64 3
  %90 = load i64, ptr %last_elem_ptr5, align 4
  %last_elem6 = add i64 %90, 1
  store i64 %last_elem6, ptr %last_elem_ptr5, align 4
  %91 = load i64, ptr %value, align 4
  %92 = sub i64 %storage_value4, %91
  call void @builtin_range_check(i64 %92)
  %93 = call ptr @heap_malloc(i64 4)
  %94 = getelementptr i64, ptr %93, i64 0
  store i64 0, ptr %94, align 4
  %95 = getelementptr i64, ptr %93, i64 1
  store i64 0, ptr %95, align 4
  %96 = getelementptr i64, ptr %93, i64 2
  store i64 0, ptr %96, align 4
  %97 = getelementptr i64, ptr %93, i64 3
  store i64 %92, ptr %97, align 4
  call void @set_storage(ptr %67, ptr %93)
  %98 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %98, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access7 = getelementptr i64, ptr %98, i64 2
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %98, i64 1
  store i64 0, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %98, i64 0
  store i64 0, ptr %index_access9, align 4
  %99 = load ptr, ptr %from, align 8
  %100 = load ptr, ptr %to, align 8
  %101 = load i64, ptr %value, align 4
  %102 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %102, i64 1
  %topic_ptr = getelementptr ptr, ptr %vector_data, i64 0
  store ptr %98, ptr %topic_ptr, align 8
  %topic_ptr10 = getelementptr ptr, ptr %vector_data, i64 1
  store ptr %99, ptr %topic_ptr10, align 8
  %topic_ptr11 = getelementptr ptr, ptr %vector_data, i64 2
  store ptr %100, ptr %topic_ptr11, align 8
  %103 = call ptr @vector_new(i64 1)
  %104 = getelementptr ptr, ptr %103, i64 1
  store i64 %101, ptr %104, align 4
  call void @emit_event(ptr %102, ptr %103)
  ret i64 1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 890988575, label %func_0_dispatch
    i64 3438416296, label %func_1_dispatch
    i64 3345580353, label %func_2_dispatch
    i64 2074087421, label %func_3_dispatch
    i64 2651249236, label %func_4_dispatch
    i64 279653635, label %func_5_dispatch
    i64 3208634742, label %func_6_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = getelementptr ptr, ptr %3, i64 4
  %5 = load i64, ptr %4, align 4
  call void @_mint(ptr %3, i64 %5)
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = getelementptr ptr, ptr %2, i64 0
  %8 = getelementptr ptr, ptr %7, i64 4
  %9 = load i64, ptr %8, align 4
  call void @_burn(ptr %7, i64 %9)
  %10 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %10, align 4
  call void @set_tape_data(ptr %10, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %11 = getelementptr ptr, ptr %2, i64 0
  %12 = getelementptr ptr, ptr %11, i64 4
  %13 = getelementptr ptr, ptr %12, i64 4
  %14 = load i64, ptr %13, align 4
  call void @_approve(ptr %11, ptr %12, i64 %14)
  %15 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %15, align 4
  call void @set_tape_data(ptr %15, i64 1)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %16 = getelementptr ptr, ptr %2, i64 0
  %17 = getelementptr ptr, ptr %16, i64 4
  %18 = getelementptr ptr, ptr %17, i64 4
  %19 = load i64, ptr %18, align 4
  call void @_transfer(ptr %16, ptr %17, i64 %19)
  %20 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %20, align 4
  call void @set_tape_data(ptr %20, i64 1)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %21 = getelementptr ptr, ptr %2, i64 0
  %22 = getelementptr ptr, ptr %21, i64 4
  %23 = load i64, ptr %22, align 4
  %24 = call i64 @approve(ptr %21, i64 %23)
  %25 = call ptr @heap_malloc(i64 2)
  store i64 %24, ptr %25, align 4
  %26 = getelementptr ptr, ptr %25, i64 1
  store i64 1, ptr %26, align 4
  call void @set_tape_data(ptr %25, i64 2)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %27 = getelementptr ptr, ptr %2, i64 0
  %28 = getelementptr ptr, ptr %27, i64 4
  %29 = load i64, ptr %28, align 4
  %30 = call i64 @transfer(ptr %27, i64 %29)
  %31 = call ptr @heap_malloc(i64 2)
  store i64 %30, ptr %31, align 4
  %32 = getelementptr ptr, ptr %31, i64 1
  store i64 1, ptr %32, align 4
  call void @set_tape_data(ptr %31, i64 2)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %33 = getelementptr ptr, ptr %2, i64 0
  %34 = getelementptr ptr, ptr %33, i64 4
  %35 = getelementptr ptr, ptr %34, i64 4
  %36 = load i64, ptr %35, align 4
  %37 = call i64 @transferFrom(ptr %33, ptr %34, i64 %36)
  %38 = call ptr @heap_malloc(i64 2)
  store i64 %37, ptr %38, align 4
  %39 = getelementptr ptr, ptr %38, i64 1
  store i64 1, ptr %39, align 4
  call void @set_tape_data(ptr %38, i64 2)
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
