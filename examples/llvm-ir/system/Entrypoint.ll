; ModuleID = 'Entrypoint'
source_filename = "Entrypoint"

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

define ptr @fields_concat(ptr %0, ptr %1) {
entry:
  %vector_length = load i64, ptr %0, align 4
  %vector_data = getelementptr i64, ptr %1, i64 1
  %vector_length1 = load i64, ptr %0, align 4
  %vector_data2 = getelementptr i64, ptr %1, i64 1
  %new_len = add i64 %vector_length, %vector_length1
  %2 = call ptr @vector_new(i64 %new_len)
  %vector_data3 = getelementptr i64, ptr %2, i64 1
  call void @memcpy(ptr %vector_data, ptr %vector_data3, i64 %vector_length)
  %new_fields_data = getelementptr ptr, ptr %vector_data3, i64 %vector_length
  call void @memcpy(ptr %vector_data2, ptr %new_fields_data, i64 %vector_length1)
  ret ptr %2
}

define void @system_entrance(ptr %0, i64 %1) {
entry:
  %_isETHCall = alloca i64, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %2 = load ptr, ptr %_tx, align 8
  store i64 %1, ptr %_isETHCall, align 4
  call void @validateTxStructure(ptr %2)
  %3 = load i64, ptr %_isETHCall, align 4
  %4 = trunc i64 %3 to i1
  br i1 %4, label %then, label %else

then:                                             ; preds = %entry
  %5 = call ptr @callTx(ptr %2)
  br label %endif

else:                                             ; preds = %entry
  call void @sendTx(ptr %2)
  br label %endif

endif:                                            ; preds = %else, %then
  ret void
}

define void @validateTxStructure(ptr %0) {
entry:
  %MAX_SYSTEM_CONTRACT_ADDRESS = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %2 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %2, i64 3
  store i64 65535, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access3, align 4
  store ptr %2, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %3 = load ptr, ptr %struct_member, align 8
  %4 = load ptr, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %5 = call i64 @field_memcmp_ugt(ptr %3, ptr %4, i64 4)
  call void @builtin_assert(i64 %5)
  %struct_member4 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %6 = load ptr, ptr %struct_member4, align 8
  %7 = call ptr @heap_malloc(i64 4)
  %index_access5 = getelementptr i64, ptr %7, i64 3
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %7, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %7, i64 0
  store i64 0, ptr %index_access8, align 4
  %8 = call i64 @memcmp_ne(ptr %6, ptr %7, i64 4)
  call void @builtin_assert(i64 %8)
  %struct_member9 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %9 = load ptr, ptr %struct_member9, align 8
  %vector_length = load i64, ptr %9, align 4
  %10 = icmp ne i64 %vector_length, 0
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  %12 = call ptr @vector_new(i64 8)
  %vector_data = getelementptr i64, ptr %12, i64 1
  %13 = getelementptr i64, ptr %vector_data, i64 0
  call void @get_context_data(ptr %13, i64 13)
  %14 = getelementptr i64, ptr %vector_data, i64 1
  call void @get_context_data(ptr %14, i64 14)
  %15 = getelementptr i64, ptr %vector_data, i64 2
  call void @get_context_data(ptr %15, i64 15)
  %16 = getelementptr i64, ptr %vector_data, i64 3
  call void @get_context_data(ptr %16, i64 16)
  %17 = getelementptr i64, ptr %vector_data, i64 4
  call void @get_context_data(ptr %17, i64 17)
  %18 = getelementptr i64, ptr %vector_data, i64 5
  call void @get_context_data(ptr %18, i64 18)
  %19 = getelementptr i64, ptr %vector_data, i64 6
  call void @get_context_data(ptr %19, i64 19)
  %20 = getelementptr i64, ptr %vector_data, i64 7
  call void @get_context_data(ptr %20, i64 20)
  %vector_length10 = load i64, ptr %12, align 4
  %21 = icmp ne i64 %vector_length10, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  ret void
}

define ptr @callTx(ptr %0) {
entry:
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %2 = load ptr, ptr %struct_member, align 8
  %address_start = ptrtoint ptr %2 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %struct_member1 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %3 = load ptr, ptr %struct_member1, align 8
  %address_start2 = ptrtoint ptr %3 to i64
  call void @prophet_printf(i64 %address_start2, i64 2)
  %struct_member3 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %4 = load ptr, ptr %struct_member3, align 8
  %fields_start = ptrtoint ptr %4 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  %struct_member4 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %5 = load ptr, ptr %struct_member4, align 8
  %fields_start5 = ptrtoint ptr %5 to i64
  call void @prophet_printf(i64 %fields_start5, i64 0)
  %struct_member6 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %6 = load ptr, ptr %struct_member6, align 8
  %struct_member7 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %7 = load ptr, ptr %struct_member7, align 8
  %vector_length = load i64, ptr %6, align 4
  %vector_data = getelementptr i64, ptr %6, i64 1
  call void @set_tape_data(ptr %vector_data, i64 %vector_length)
  call void @contract_call(ptr %7, i64 0)
  %8 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %8, i64 1)
  %return_length = load i64, ptr %8, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %9 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %9, align 4
  %return_data_start = getelementptr i64, ptr %9, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  ret ptr %9
}

define void @sendTx(ptr %0) {
entry:
  %NONCE_HOLDER_ADDRESS = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %2 = load ptr, ptr %struct_member, align 8
  %address_start = ptrtoint ptr %2 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %struct_member1 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %3 = load ptr, ptr %struct_member1, align 8
  %address_start2 = ptrtoint ptr %3 to i64
  call void @prophet_printf(i64 %address_start2, i64 2)
  %struct_member3 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %4 = load ptr, ptr %struct_member3, align 8
  %fields_start = ptrtoint ptr %4 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  %struct_member4 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %5 = load ptr, ptr %struct_member4, align 8
  %fields_start5 = ptrtoint ptr %5 to i64
  call void @prophet_printf(i64 %fields_start5, i64 0)
  call void @validateTx(ptr %1)
  call void @validateDeployment(ptr %1)
  %struct_member6 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %6 = load ptr, ptr %struct_member6, align 8
  %struct_member7 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %7 = load ptr, ptr %struct_member7, align 8
  %vector_length = load i64, ptr %6, align 4
  %vector_data = getelementptr i64, ptr %6, i64 1
  call void @set_tape_data(ptr %vector_data, i64 %vector_length)
  call void @contract_call(ptr %7, i64 0)
  %8 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %8, i64 1)
  %return_length = load i64, ptr %8, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %9 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %9, align 4
  %return_data_start = getelementptr i64, ptr %9, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %10 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %10, i64 3
  store i64 32771, ptr %index_access, align 4
  %index_access8 = getelementptr i64, ptr %10, i64 2
  store i64 0, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %10, i64 1
  store i64 0, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %10, i64 0
  store i64 0, ptr %index_access10, align 4
  store ptr %10, ptr %NONCE_HOLDER_ADDRESS, align 8
  %struct_member11 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %11 = load ptr, ptr %struct_member11, align 8
  %12 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %12, i64 12)
  %13 = load i64, ptr %12, align 4
  %14 = call ptr @vector_new(i64 7)
  %vector_data12 = getelementptr i64, ptr %14, i64 1
  %15 = getelementptr i64, ptr %11, i64 0
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %vector_data12, i64 0
  store i64 %16, ptr %17, align 4
  %18 = getelementptr i64, ptr %11, i64 1
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %vector_data12, i64 1
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %11, i64 2
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %vector_data12, i64 2
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %11, i64 3
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %vector_data12, i64 3
  store i64 %25, ptr %26, align 4
  %27 = getelementptr ptr, ptr %vector_data12, i64 4
  store i64 %13, ptr %27, align 4
  %28 = getelementptr ptr, ptr %27, i64 1
  store i64 5, ptr %28, align 4
  %29 = getelementptr ptr, ptr %28, i64 1
  store i64 1093482716, ptr %29, align 4
  %30 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %vector_length13 = load i64, ptr %14, align 4
  %vector_data14 = getelementptr i64, ptr %14, i64 1
  call void @set_tape_data(ptr %vector_data14, i64 %vector_length13)
  call void @contract_call(ptr %30, i64 0)
  %31 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %31, i64 1)
  %return_length15 = load i64, ptr %31, align 4
  %tape_size16 = add i64 %return_length15, 1
  %heap_size17 = add i64 %return_length15, 2
  %32 = call ptr @heap_malloc(i64 %heap_size17)
  store i64 %return_length15, ptr %32, align 4
  %return_data_start18 = getelementptr i64, ptr %32, i64 1
  call void @get_tape_data(ptr %return_data_start18, i64 %tape_size16)
  ret void
}

define void @validateTx(ptr %0) {
entry:
  %txHash = alloca ptr, align 8
  %signedHash = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %2 = call ptr @getSignedHash(ptr %1)
  store ptr %2, ptr %signedHash, align 8
  %3 = load ptr, ptr %signedHash, align 8
  %4 = call ptr @vector_new(i64 8)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %5 = getelementptr i64, ptr %vector_data, i64 0
  call void @get_context_data(ptr %5, i64 13)
  %6 = getelementptr i64, ptr %vector_data, i64 1
  call void @get_context_data(ptr %6, i64 14)
  %7 = getelementptr i64, ptr %vector_data, i64 2
  call void @get_context_data(ptr %7, i64 15)
  %8 = getelementptr i64, ptr %vector_data, i64 3
  call void @get_context_data(ptr %8, i64 16)
  %9 = getelementptr i64, ptr %vector_data, i64 4
  call void @get_context_data(ptr %9, i64 17)
  %10 = getelementptr i64, ptr %vector_data, i64 5
  call void @get_context_data(ptr %10, i64 18)
  %11 = getelementptr i64, ptr %vector_data, i64 6
  call void @get_context_data(ptr %11, i64 19)
  %12 = getelementptr i64, ptr %vector_data, i64 7
  call void @get_context_data(ptr %12, i64 20)
  %13 = call ptr @getTransactionHash(ptr %3, ptr %4)
  store ptr %13, ptr %txHash, align 8
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %14 = load ptr, ptr %struct_member, align 8
  call void @validate_from(ptr %14)
  %struct_member1 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %15 = load ptr, ptr %struct_member1, align 8
  %16 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %16, i64 12)
  %17 = load i64, ptr %16, align 4
  call void @validate_nonce(ptr %15, i64 %17)
  %18 = load ptr, ptr %txHash, align 8
  %19 = load ptr, ptr %signedHash, align 8
  call void @validate_tx(ptr %18, ptr %19, ptr %1)
  ret void
}

define void @validateDeployment(ptr %0) {
entry:
  %DEPLOYER_SYSTEM_CONTRACT = alloca ptr, align 8
  %is_codehash_known = alloca i64, align 8
  %KNOWN_CODES_STORAGE = alloca ptr, align 8
  %codeHash = alloca ptr, align 8
  %bytecodeHash = alloca ptr, align 8
  %code_len = alloca i64, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %2 = load ptr, ptr %struct_member, align 8
  %vector_length = load i64, ptr %2, align 4
  store i64 %vector_length, ptr %code_len, align 4
  %3 = load i64, ptr %code_len, align 4
  %4 = icmp ne i64 %3, 0
  br i1 %4, label %then, label %endif

then:                                             ; preds = %entry
  %struct_member1 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %5 = load ptr, ptr %struct_member1, align 8
  %6 = call ptr @hashL2Bytecode(ptr %5)
  store ptr %6, ptr %bytecodeHash, align 8
  %struct_member2 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %7 = load ptr, ptr %struct_member2, align 8
  %vector_length3 = load i64, ptr %7, align 4
  %array_len_sub_one = sub i64 %vector_length3, 1
  %8 = sub i64 %array_len_sub_one, 8
  call void @builtin_range_check(i64 %8)
  %9 = sub i64 %vector_length3, 12
  call void @builtin_range_check(i64 %9)
  %10 = call ptr @vector_new(i64 4)
  %vector_data = getelementptr i64, ptr %10, i64 1
  %vector_data4 = getelementptr i64, ptr %7, i64 1
  %src_data_start = getelementptr i64, ptr %vector_data4, i64 8
  call void @memcpy(ptr %src_data_start, ptr %vector_data, i64 4)
  %vector_data5 = getelementptr i64, ptr %10, i64 1
  %11 = getelementptr ptr, ptr %vector_data5, i64 0
  store ptr %11, ptr %codeHash, align 8
  %12 = load ptr, ptr %bytecodeHash, align 8
  %13 = load ptr, ptr %codeHash, align 8
  %14 = call i64 @memcmp_eq(ptr %12, ptr %13, i64 4)
  call void @builtin_assert(i64 %14)
  %15 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %15, i64 3
  store i64 32772, ptr %index_access, align 4
  %index_access6 = getelementptr i64, ptr %15, i64 2
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %15, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %15, i64 0
  store i64 0, ptr %index_access8, align 4
  store ptr %15, ptr %KNOWN_CODES_STORAGE, align 8
  %16 = load ptr, ptr %bytecodeHash, align 8
  %17 = call ptr @vector_new(i64 6)
  %vector_data9 = getelementptr i64, ptr %17, i64 1
  %18 = getelementptr i64, ptr %16, i64 0
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %vector_data9, i64 0
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %16, i64 1
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %vector_data9, i64 1
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %16, i64 2
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %vector_data9, i64 2
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %16, i64 3
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %vector_data9, i64 3
  store i64 %28, ptr %29, align 4
  %30 = getelementptr ptr, ptr %vector_data9, i64 4
  store i64 4, ptr %30, align 4
  %31 = getelementptr ptr, ptr %30, i64 1
  store i64 4199620571, ptr %31, align 4
  %32 = load ptr, ptr %KNOWN_CODES_STORAGE, align 8
  %vector_length10 = load i64, ptr %17, align 4
  %vector_data11 = getelementptr i64, ptr %17, i64 1
  call void @set_tape_data(ptr %vector_data11, i64 %vector_length10)
  call void @contract_call(ptr %32, i64 0)
  %33 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %33, i64 1)
  %return_length = load i64, ptr %33, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %34 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %34, align 4
  %return_data_start = getelementptr i64, ptr %34, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_data12 = getelementptr i64, ptr %34, i64 1
  %35 = getelementptr ptr, ptr %vector_data12, i64 0
  %36 = load i64, ptr %35, align 4
  store i64 %36, ptr %is_codehash_known, align 4
  %37 = load i64, ptr %is_codehash_known, align 4
  %38 = icmp eq i64 %37, 0
  br i1 %38, label %then13, label %endif14

endif:                                            ; preds = %endif14, %entry
  ret void

then13:                                           ; preds = %then
  %39 = load ptr, ptr %bytecodeHash, align 8
  %40 = call ptr @vector_new(i64 6)
  %vector_data15 = getelementptr i64, ptr %40, i64 1
  %41 = getelementptr i64, ptr %39, i64 0
  %42 = load i64, ptr %41, align 4
  %43 = getelementptr i64, ptr %vector_data15, i64 0
  store i64 %42, ptr %43, align 4
  %44 = getelementptr i64, ptr %39, i64 1
  %45 = load i64, ptr %44, align 4
  %46 = getelementptr i64, ptr %vector_data15, i64 1
  store i64 %45, ptr %46, align 4
  %47 = getelementptr i64, ptr %39, i64 2
  %48 = load i64, ptr %47, align 4
  %49 = getelementptr i64, ptr %vector_data15, i64 2
  store i64 %48, ptr %49, align 4
  %50 = getelementptr i64, ptr %39, i64 3
  %51 = load i64, ptr %50, align 4
  %52 = getelementptr i64, ptr %vector_data15, i64 3
  store i64 %51, ptr %52, align 4
  %53 = getelementptr ptr, ptr %vector_data15, i64 4
  store i64 4, ptr %53, align 4
  %54 = getelementptr ptr, ptr %53, i64 1
  store i64 1119715209, ptr %54, align 4
  %55 = load ptr, ptr %KNOWN_CODES_STORAGE, align 8
  %vector_length16 = load i64, ptr %40, align 4
  %vector_data17 = getelementptr i64, ptr %40, i64 1
  call void @set_tape_data(ptr %vector_data17, i64 %vector_length16)
  call void @contract_call(ptr %55, i64 0)
  %56 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %56, i64 1)
  %return_length18 = load i64, ptr %56, align 4
  %tape_size19 = add i64 %return_length18, 1
  %heap_size20 = add i64 %return_length18, 2
  %57 = call ptr @heap_malloc(i64 %heap_size20)
  store i64 %return_length18, ptr %57, align 4
  %return_data_start21 = getelementptr i64, ptr %57, i64 1
  call void @get_tape_data(ptr %return_data_start21, i64 %tape_size19)
  br label %endif14

endif14:                                          ; preds = %then13, %then
  %58 = call ptr @heap_malloc(i64 4)
  %index_access22 = getelementptr i64, ptr %58, i64 3
  store i64 32773, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %58, i64 2
  store i64 0, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %58, i64 1
  store i64 0, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %58, i64 0
  store i64 0, ptr %index_access25, align 4
  store ptr %58, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %struct_member26 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %59 = load ptr, ptr %struct_member26, align 8
  %60 = load ptr, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %61 = call i64 @memcmp_eq(ptr %59, ptr %60, i64 4)
  call void @builtin_assert(i64 %61)
  br label %endif
}

define ptr @getSignedHash(ptr %0) {
entry:
  %signedHash = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %2 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %2, i64 7)
  %3 = load i64, ptr %2, align 4
  %4 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %4, i64 6)
  %5 = load i64, ptr %4, align 4
  %6 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %6, i64 12)
  %7 = load i64, ptr %6, align 4
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %8 = load ptr, ptr %struct_member, align 8
  %struct_member1 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %9 = load ptr, ptr %struct_member1, align 8
  %struct_member2 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %10 = load ptr, ptr %struct_member2, align 8
  %vector_length = load i64, ptr %10, align 4
  %11 = add i64 %vector_length, 1
  %12 = add i64 11, %11
  %13 = call ptr @vector_new(i64 %12)
  %14 = getelementptr ptr, ptr %13, i64 1
  store i64 %3, ptr %14, align 4
  %15 = getelementptr ptr, ptr %14, i64 1
  store i64 %5, ptr %15, align 4
  %16 = getelementptr ptr, ptr %15, i64 1
  store i64 %7, ptr %16, align 4
  %17 = getelementptr ptr, ptr %16, i64 1
  %18 = getelementptr i64, ptr %8, i64 0
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %17, i64 0
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %8, i64 1
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %17, i64 1
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %8, i64 2
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %17, i64 2
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %8, i64 3
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %17, i64 3
  store i64 %28, ptr %29, align 4
  %30 = getelementptr ptr, ptr %17, i64 4
  %31 = getelementptr i64, ptr %9, i64 0
  %32 = load i64, ptr %31, align 4
  %33 = getelementptr i64, ptr %30, i64 0
  store i64 %32, ptr %33, align 4
  %34 = getelementptr i64, ptr %9, i64 1
  %35 = load i64, ptr %34, align 4
  %36 = getelementptr i64, ptr %30, i64 1
  store i64 %35, ptr %36, align 4
  %37 = getelementptr i64, ptr %9, i64 2
  %38 = load i64, ptr %37, align 4
  %39 = getelementptr i64, ptr %30, i64 2
  store i64 %38, ptr %39, align 4
  %40 = getelementptr i64, ptr %9, i64 3
  %41 = load i64, ptr %40, align 4
  %42 = getelementptr i64, ptr %30, i64 3
  store i64 %41, ptr %42, align 4
  %43 = getelementptr ptr, ptr %30, i64 4
  %vector_length3 = load i64, ptr %10, align 4
  %44 = add i64 %vector_length3, 1
  call void @memcpy(ptr %10, ptr %43, i64 %44)
  %vector_length4 = load i64, ptr %13, align 4
  %vector_data = getelementptr i64, ptr %13, i64 1
  %45 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data, ptr %45, i64 %vector_length4)
  store ptr %45, ptr %signedHash, align 8
  %46 = load ptr, ptr %signedHash, align 8
  ret ptr %46
}

define ptr @getTransactionHash(ptr %0, ptr %1) {
entry:
  %txHash = alloca ptr, align 8
  %signature = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  store ptr %0, ptr %_signedHash, align 8
  store ptr %1, ptr %signature, align 8
  %2 = load ptr, ptr %signature, align 8
  %3 = load ptr, ptr %_signedHash, align 8
  %4 = call ptr @vector_new(i64 4)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %7 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %6, ptr %7, align 4
  %8 = getelementptr i64, ptr %3, i64 1
  %9 = load i64, ptr %8, align 4
  %10 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %9, ptr %10, align 4
  %11 = getelementptr i64, ptr %3, i64 2
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %3, i64 3
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %15, ptr %16, align 4
  %vector_length = load i64, ptr %2, align 4
  %vector_data1 = getelementptr i64, ptr %2, i64 1
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data1, ptr %17, i64 %vector_length)
  %18 = call ptr @vector_new(i64 4)
  %vector_data2 = getelementptr i64, ptr %18, i64 1
  %19 = getelementptr i64, ptr %17, i64 0
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %vector_data2, i64 0
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %17, i64 1
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %vector_data2, i64 1
  store i64 %23, ptr %24, align 4
  %25 = getelementptr i64, ptr %17, i64 2
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %vector_data2, i64 2
  store i64 %26, ptr %27, align 4
  %28 = getelementptr i64, ptr %17, i64 3
  %29 = load i64, ptr %28, align 4
  %30 = getelementptr i64, ptr %vector_data2, i64 3
  store i64 %29, ptr %30, align 4
  %31 = call ptr @fields_concat(ptr %4, ptr %18)
  %vector_length3 = load i64, ptr %31, align 4
  %vector_data4 = getelementptr i64, ptr %31, i64 1
  %32 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data4, ptr %32, i64 %vector_length3)
  store ptr %32, ptr %txHash, align 8
  %33 = load ptr, ptr %txHash, align 8
  ret ptr %33
}

define void @validate_from(ptr %0) {
entry:
  %account_version = alloca i64, align 8
  %DEPLOYER_SYSTEM_CONTRACT = alloca ptr, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 3
  store i64 32773, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %index_access3, align 4
  store ptr %1, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %2 = load ptr, ptr %_address, align 8
  %3 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %4 = getelementptr i64, ptr %2, i64 0
  %5 = load i64, ptr %4, align 4
  %6 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %5, ptr %6, align 4
  %7 = getelementptr i64, ptr %2, i64 1
  %8 = load i64, ptr %7, align 4
  %9 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %8, ptr %9, align 4
  %10 = getelementptr i64, ptr %2, i64 2
  %11 = load i64, ptr %10, align 4
  %12 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %11, ptr %12, align 4
  %13 = getelementptr i64, ptr %2, i64 3
  %14 = load i64, ptr %13, align 4
  %15 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %14, ptr %15, align 4
  %16 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %16, align 4
  %17 = getelementptr ptr, ptr %16, i64 1
  store i64 3138377232, ptr %17, align 4
  %18 = load ptr, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %vector_length = load i64, ptr %3, align 4
  %vector_data4 = getelementptr i64, ptr %3, i64 1
  call void @set_tape_data(ptr %vector_data4, i64 %vector_length)
  call void @contract_call(ptr %18, i64 0)
  %19 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %19, i64 1)
  %return_length = load i64, ptr %19, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %20 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %20, align 4
  %return_data_start = getelementptr i64, ptr %20, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_data5 = getelementptr i64, ptr %20, i64 1
  %21 = getelementptr ptr, ptr %vector_data5, i64 0
  %22 = load i64, ptr %21, align 4
  store i64 %22, ptr %account_version, align 4
  %23 = load i64, ptr %account_version, align 4
  %24 = icmp ne i64 %23, 0
  %25 = zext i1 %24 to i64
  call void @builtin_assert(i64 %25)
  ret void
}

define void @validate_nonce(ptr %0, i64 %1) {
entry:
  %nonce = alloca i64, align 8
  %NONCE_HOLDER_ADDRESS = alloca ptr, align 8
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %2, i64 3
  store i64 32771, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access3, align 4
  store ptr %2, ptr %NONCE_HOLDER_ADDRESS, align 8
  %3 = load ptr, ptr %_address, align 8
  %4 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %7 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %6, ptr %7, align 4
  %8 = getelementptr i64, ptr %3, i64 1
  %9 = load i64, ptr %8, align 4
  %10 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %9, ptr %10, align 4
  %11 = getelementptr i64, ptr %3, i64 2
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %3, i64 3
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %15, ptr %16, align 4
  %17 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %17, align 4
  %18 = getelementptr ptr, ptr %17, i64 1
  store i64 755185067, ptr %18, align 4
  %19 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %vector_length = load i64, ptr %4, align 4
  %vector_data4 = getelementptr i64, ptr %4, i64 1
  call void @set_tape_data(ptr %vector_data4, i64 %vector_length)
  call void @contract_call(ptr %19, i64 0)
  %20 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %20, i64 1)
  %return_length = load i64, ptr %20, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %21 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %21, align 4
  %return_data_start = getelementptr i64, ptr %21, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_data5 = getelementptr i64, ptr %21, i64 1
  %22 = getelementptr ptr, ptr %vector_data5, i64 0
  %23 = load i64, ptr %22, align 4
  store i64 %23, ptr %nonce, align 4
  %24 = load i64, ptr %_nonce, align 4
  %25 = load i64, ptr %nonce, align 4
  %26 = add i64 %25, 1
  call void @builtin_range_check(i64 %26)
  %27 = icmp eq i64 %24, %26
  %28 = zext i1 %27 to i64
  call void @builtin_assert(i64 %28)
  ret void
}

define void @validate_tx(ptr %0, ptr %1, ptr %2) {
entry:
  %expected_magic = alloca i64, align 8
  %magic = alloca i64, align 8
  %_tx = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  %_txHash = alloca ptr, align 8
  store ptr %0, ptr %_txHash, align 8
  store ptr %1, ptr %_signedHash, align 8
  store ptr %2, ptr %_tx, align 8
  %3 = load ptr, ptr %_tx, align 8
  %4 = load ptr, ptr %_txHash, align 8
  %5 = load ptr, ptr %_signedHash, align 8
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 2
  %6 = load ptr, ptr %struct_member, align 8
  %vector_length = load i64, ptr %6, align 4
  %7 = add i64 %vector_length, 1
  %8 = add i64 8, %7
  %struct_member1 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 3
  %9 = load ptr, ptr %struct_member1, align 8
  %vector_length2 = load i64, ptr %9, align 4
  %10 = add i64 %vector_length2, 1
  %11 = add i64 %8, %10
  %12 = add i64 8, %11
  %heap_size = add i64 %12, 2
  %13 = call ptr @vector_new(i64 %heap_size)
  %vector_data = getelementptr i64, ptr %13, i64 1
  %14 = getelementptr i64, ptr %4, i64 0
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %15, ptr %16, align 4
  %17 = getelementptr i64, ptr %4, i64 1
  %18 = load i64, ptr %17, align 4
  %19 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %18, ptr %19, align 4
  %20 = getelementptr i64, ptr %4, i64 2
  %21 = load i64, ptr %20, align 4
  %22 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %21, ptr %22, align 4
  %23 = getelementptr i64, ptr %4, i64 3
  %24 = load i64, ptr %23, align 4
  %25 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %24, ptr %25, align 4
  %26 = getelementptr ptr, ptr %vector_data, i64 4
  %27 = getelementptr i64, ptr %5, i64 0
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %26, i64 0
  store i64 %28, ptr %29, align 4
  %30 = getelementptr i64, ptr %5, i64 1
  %31 = load i64, ptr %30, align 4
  %32 = getelementptr i64, ptr %26, i64 1
  store i64 %31, ptr %32, align 4
  %33 = getelementptr i64, ptr %5, i64 2
  %34 = load i64, ptr %33, align 4
  %35 = getelementptr i64, ptr %26, i64 2
  store i64 %34, ptr %35, align 4
  %36 = getelementptr i64, ptr %5, i64 3
  %37 = load i64, ptr %36, align 4
  %38 = getelementptr i64, ptr %26, i64 3
  store i64 %37, ptr %38, align 4
  %39 = getelementptr ptr, ptr %26, i64 4
  %struct_member3 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %strcut_member = load ptr, ptr %struct_member3, align 8
  %struct_offset = getelementptr ptr, ptr %39, i64 0
  %40 = getelementptr i64, ptr %strcut_member, i64 0
  %41 = load i64, ptr %40, align 4
  %42 = getelementptr i64, ptr %struct_offset, i64 0
  store i64 %41, ptr %42, align 4
  %43 = getelementptr i64, ptr %strcut_member, i64 1
  %44 = load i64, ptr %43, align 4
  %45 = getelementptr i64, ptr %struct_offset, i64 1
  store i64 %44, ptr %45, align 4
  %46 = getelementptr i64, ptr %strcut_member, i64 2
  %47 = load i64, ptr %46, align 4
  %48 = getelementptr i64, ptr %struct_offset, i64 2
  store i64 %47, ptr %48, align 4
  %49 = getelementptr i64, ptr %strcut_member, i64 3
  %50 = load i64, ptr %49, align 4
  %51 = getelementptr i64, ptr %struct_offset, i64 3
  store i64 %50, ptr %51, align 4
  %struct_member4 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 1
  %strcut_member5 = load ptr, ptr %struct_member4, align 8
  %struct_offset6 = getelementptr ptr, ptr %struct_offset, i64 4
  %52 = getelementptr i64, ptr %strcut_member5, i64 0
  %53 = load i64, ptr %52, align 4
  %54 = getelementptr i64, ptr %struct_offset6, i64 0
  store i64 %53, ptr %54, align 4
  %55 = getelementptr i64, ptr %strcut_member5, i64 1
  %56 = load i64, ptr %55, align 4
  %57 = getelementptr i64, ptr %struct_offset6, i64 1
  store i64 %56, ptr %57, align 4
  %58 = getelementptr i64, ptr %strcut_member5, i64 2
  %59 = load i64, ptr %58, align 4
  %60 = getelementptr i64, ptr %struct_offset6, i64 2
  store i64 %59, ptr %60, align 4
  %61 = getelementptr i64, ptr %strcut_member5, i64 3
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr i64, ptr %struct_offset6, i64 3
  store i64 %62, ptr %63, align 4
  %struct_member7 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 2
  %strcut_member8 = load ptr, ptr %struct_member7, align 8
  %struct_offset9 = getelementptr ptr, ptr %struct_offset6, i64 4
  %vector_length10 = load i64, ptr %strcut_member8, align 4
  %64 = add i64 %vector_length10, 1
  call void @memcpy(ptr %strcut_member8, ptr %struct_offset9, i64 %64)
  %struct_size = add i64 %64, 8
  %struct_member11 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 3
  %strcut_member12 = load ptr, ptr %struct_member11, align 8
  %struct_offset13 = getelementptr ptr, ptr %struct_offset9, i64 %64
  %vector_length14 = load i64, ptr %strcut_member12, align 4
  %65 = add i64 %vector_length14, 1
  call void @memcpy(ptr %strcut_member12, ptr %struct_offset13, i64 %65)
  %struct_size15 = add i64 %65, %struct_size
  %66 = getelementptr ptr, ptr %39, i64 %struct_size15
  store i64 %12, ptr %66, align 4
  %67 = getelementptr ptr, ptr %66, i64 1
  store i64 3738116221, ptr %67, align 4
  %struct_member16 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %68 = load ptr, ptr %struct_member16, align 8
  %vector_length17 = load i64, ptr %13, align 4
  %vector_data18 = getelementptr i64, ptr %13, i64 1
  call void @set_tape_data(ptr %vector_data18, i64 %vector_length17)
  call void @contract_call(ptr %68, i64 0)
  %69 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %69, i64 1)
  %return_length = load i64, ptr %69, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size19 = add i64 %return_length, 2
  %70 = call ptr @heap_malloc(i64 %heap_size19)
  store i64 %return_length, ptr %70, align 4
  %return_data_start = getelementptr i64, ptr %70, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_data20 = getelementptr i64, ptr %70, i64 1
  %71 = getelementptr ptr, ptr %vector_data20, i64 0
  %72 = load i64, ptr %71, align 4
  store i64 %72, ptr %magic, align 4
  store i64 3738116221, ptr %expected_magic, align 4
  %73 = load i64, ptr %magic, align 4
  %74 = load i64, ptr %expected_magic, align 4
  %75 = icmp eq i64 %73, %74
  %76 = zext i1 %75 to i64
  call void @builtin_assert(i64 %76)
  ret void
}

define ptr @hashL2Bytecode(ptr %0) {
entry:
  %hash_bytecode = alloca ptr, align 8
  %_bytecode = alloca ptr, align 8
  store ptr %0, ptr %_bytecode, align 8
  %1 = load ptr, ptr %_bytecode, align 8
  %vector_length = load i64, ptr %1, align 4
  %vector_data = getelementptr i64, ptr %1, i64 1
  %2 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data, ptr %2, i64 %vector_length)
  store ptr %2, ptr %hash_bytecode, align 8
  %3 = load ptr, ptr %hash_bytecode, align 8
  ret ptr %3
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3234502684, label %func_0_dispatch
    i64 1842341210, label %func_1_dispatch
    i64 1130404146, label %func_2_dispatch
    i64 962576880, label %func_3_dispatch
    i64 1345188922, label %func_4_dispatch
    i64 4026982134, label %func_5_dispatch
    i64 852492234, label %func_6_dispatch
    i64 1928909022, label %func_7_dispatch
    i64 3520822549, label %func_8_dispatch
    i64 2845631446, label %func_9_dispatch
    i64 3030619545, label %func_10_dispatch
    i64 2132927061, label %func_11_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field = getelementptr ptr, ptr %3, i64 0
  %decode_struct_field1 = getelementptr ptr, ptr %3, i64 4
  %decode_struct_field2 = getelementptr ptr, ptr %3, i64 8
  %vector_length = load i64, ptr %decode_struct_field2, align 4
  %4 = add i64 %vector_length, 1
  %decode_struct_offset = add i64 8, %4
  %decode_struct_field3 = getelementptr ptr, ptr %3, i64 %decode_struct_offset
  %vector_length4 = load i64, ptr %decode_struct_field3, align 4
  %5 = add i64 %vector_length4, 1
  %decode_struct_offset5 = add i64 %decode_struct_offset, %5
  %6 = call ptr @heap_malloc(i64 4)
  %struct_member = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %6, i32 0, i32 0
  store ptr %decode_struct_field, ptr %struct_member, align 8
  %struct_member6 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %6, i32 0, i32 1
  store ptr %decode_struct_field1, ptr %struct_member6, align 8
  %struct_member7 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %6, i32 0, i32 2
  store ptr %decode_struct_field2, ptr %struct_member7, align 8
  %struct_member8 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %6, i32 0, i32 3
  store ptr %decode_struct_field3, ptr %struct_member8, align 8
  %7 = getelementptr ptr, ptr %3, i64 %decode_struct_offset5
  %8 = load i64, ptr %7, align 4
  call void @system_entrance(ptr %6, i64 %8)
  %9 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %9, align 4
  call void @set_tape_data(ptr %9, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %10 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field9 = getelementptr ptr, ptr %10, i64 0
  %decode_struct_field10 = getelementptr ptr, ptr %10, i64 4
  %decode_struct_field11 = getelementptr ptr, ptr %10, i64 8
  %vector_length12 = load i64, ptr %decode_struct_field11, align 4
  %11 = add i64 %vector_length12, 1
  %decode_struct_offset13 = add i64 8, %11
  %decode_struct_field14 = getelementptr ptr, ptr %10, i64 %decode_struct_offset13
  %vector_length15 = load i64, ptr %decode_struct_field14, align 4
  %12 = add i64 %vector_length15, 1
  %decode_struct_offset16 = add i64 %decode_struct_offset13, %12
  %13 = call ptr @heap_malloc(i64 4)
  %struct_member17 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 0
  store ptr %decode_struct_field9, ptr %struct_member17, align 8
  %struct_member18 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 1
  store ptr %decode_struct_field10, ptr %struct_member18, align 8
  %struct_member19 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 2
  store ptr %decode_struct_field11, ptr %struct_member19, align 8
  %struct_member20 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %13, i32 0, i32 3
  store ptr %decode_struct_field14, ptr %struct_member20, align 8
  call void @validateTxStructure(ptr %13)
  %14 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %14, align 4
  call void @set_tape_data(ptr %14, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %15 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field21 = getelementptr ptr, ptr %15, i64 0
  %decode_struct_field22 = getelementptr ptr, ptr %15, i64 4
  %decode_struct_field23 = getelementptr ptr, ptr %15, i64 8
  %vector_length24 = load i64, ptr %decode_struct_field23, align 4
  %16 = add i64 %vector_length24, 1
  %decode_struct_offset25 = add i64 8, %16
  %decode_struct_field26 = getelementptr ptr, ptr %15, i64 %decode_struct_offset25
  %vector_length27 = load i64, ptr %decode_struct_field26, align 4
  %17 = add i64 %vector_length27, 1
  %decode_struct_offset28 = add i64 %decode_struct_offset25, %17
  %18 = call ptr @heap_malloc(i64 4)
  %struct_member29 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %18, i32 0, i32 0
  store ptr %decode_struct_field21, ptr %struct_member29, align 8
  %struct_member30 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %18, i32 0, i32 1
  store ptr %decode_struct_field22, ptr %struct_member30, align 8
  %struct_member31 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %18, i32 0, i32 2
  store ptr %decode_struct_field23, ptr %struct_member31, align 8
  %struct_member32 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %18, i32 0, i32 3
  store ptr %decode_struct_field26, ptr %struct_member32, align 8
  %19 = call ptr @callTx(ptr %18)
  %vector_length33 = load i64, ptr %19, align 4
  %20 = add i64 %vector_length33, 1
  %heap_size = add i64 %20, 1
  %21 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length34 = load i64, ptr %19, align 4
  %22 = add i64 %vector_length34, 1
  call void @memcpy(ptr %19, ptr %21, i64 %22)
  %23 = getelementptr ptr, ptr %21, i64 %22
  store i64 %20, ptr %23, align 4
  call void @set_tape_data(ptr %21, i64 %heap_size)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %24 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field35 = getelementptr ptr, ptr %24, i64 0
  %decode_struct_field36 = getelementptr ptr, ptr %24, i64 4
  %decode_struct_field37 = getelementptr ptr, ptr %24, i64 8
  %vector_length38 = load i64, ptr %decode_struct_field37, align 4
  %25 = add i64 %vector_length38, 1
  %decode_struct_offset39 = add i64 8, %25
  %decode_struct_field40 = getelementptr ptr, ptr %24, i64 %decode_struct_offset39
  %vector_length41 = load i64, ptr %decode_struct_field40, align 4
  %26 = add i64 %vector_length41, 1
  %decode_struct_offset42 = add i64 %decode_struct_offset39, %26
  %27 = call ptr @heap_malloc(i64 4)
  %struct_member43 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %27, i32 0, i32 0
  store ptr %decode_struct_field35, ptr %struct_member43, align 8
  %struct_member44 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %27, i32 0, i32 1
  store ptr %decode_struct_field36, ptr %struct_member44, align 8
  %struct_member45 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %27, i32 0, i32 2
  store ptr %decode_struct_field37, ptr %struct_member45, align 8
  %struct_member46 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %27, i32 0, i32 3
  store ptr %decode_struct_field40, ptr %struct_member46, align 8
  call void @sendTx(ptr %27)
  %28 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %28, align 4
  call void @set_tape_data(ptr %28, i64 1)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %29 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field47 = getelementptr ptr, ptr %29, i64 0
  %decode_struct_field48 = getelementptr ptr, ptr %29, i64 4
  %decode_struct_field49 = getelementptr ptr, ptr %29, i64 8
  %vector_length50 = load i64, ptr %decode_struct_field49, align 4
  %30 = add i64 %vector_length50, 1
  %decode_struct_offset51 = add i64 8, %30
  %decode_struct_field52 = getelementptr ptr, ptr %29, i64 %decode_struct_offset51
  %vector_length53 = load i64, ptr %decode_struct_field52, align 4
  %31 = add i64 %vector_length53, 1
  %decode_struct_offset54 = add i64 %decode_struct_offset51, %31
  %32 = call ptr @heap_malloc(i64 4)
  %struct_member55 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %32, i32 0, i32 0
  store ptr %decode_struct_field47, ptr %struct_member55, align 8
  %struct_member56 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %32, i32 0, i32 1
  store ptr %decode_struct_field48, ptr %struct_member56, align 8
  %struct_member57 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %32, i32 0, i32 2
  store ptr %decode_struct_field49, ptr %struct_member57, align 8
  %struct_member58 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %32, i32 0, i32 3
  store ptr %decode_struct_field52, ptr %struct_member58, align 8
  call void @validateTx(ptr %32)
  %33 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %33, align 4
  call void @set_tape_data(ptr %33, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %34 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field59 = getelementptr ptr, ptr %34, i64 0
  %decode_struct_field60 = getelementptr ptr, ptr %34, i64 4
  %decode_struct_field61 = getelementptr ptr, ptr %34, i64 8
  %vector_length62 = load i64, ptr %decode_struct_field61, align 4
  %35 = add i64 %vector_length62, 1
  %decode_struct_offset63 = add i64 8, %35
  %decode_struct_field64 = getelementptr ptr, ptr %34, i64 %decode_struct_offset63
  %vector_length65 = load i64, ptr %decode_struct_field64, align 4
  %36 = add i64 %vector_length65, 1
  %decode_struct_offset66 = add i64 %decode_struct_offset63, %36
  %37 = call ptr @heap_malloc(i64 4)
  %struct_member67 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 0
  store ptr %decode_struct_field59, ptr %struct_member67, align 8
  %struct_member68 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 1
  store ptr %decode_struct_field60, ptr %struct_member68, align 8
  %struct_member69 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 2
  store ptr %decode_struct_field61, ptr %struct_member69, align 8
  %struct_member70 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %37, i32 0, i32 3
  store ptr %decode_struct_field64, ptr %struct_member70, align 8
  call void @validateDeployment(ptr %37)
  %38 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %38, align 4
  call void @set_tape_data(ptr %38, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %39 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field71 = getelementptr ptr, ptr %39, i64 0
  %decode_struct_field72 = getelementptr ptr, ptr %39, i64 4
  %decode_struct_field73 = getelementptr ptr, ptr %39, i64 8
  %vector_length74 = load i64, ptr %decode_struct_field73, align 4
  %40 = add i64 %vector_length74, 1
  %decode_struct_offset75 = add i64 8, %40
  %decode_struct_field76 = getelementptr ptr, ptr %39, i64 %decode_struct_offset75
  %vector_length77 = load i64, ptr %decode_struct_field76, align 4
  %41 = add i64 %vector_length77, 1
  %decode_struct_offset78 = add i64 %decode_struct_offset75, %41
  %42 = call ptr @heap_malloc(i64 4)
  %struct_member79 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 0
  store ptr %decode_struct_field71, ptr %struct_member79, align 8
  %struct_member80 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 1
  store ptr %decode_struct_field72, ptr %struct_member80, align 8
  %struct_member81 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 2
  store ptr %decode_struct_field73, ptr %struct_member81, align 8
  %struct_member82 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 3
  store ptr %decode_struct_field76, ptr %struct_member82, align 8
  %43 = call ptr @getSignedHash(ptr %42)
  %44 = call ptr @heap_malloc(i64 5)
  %45 = getelementptr i64, ptr %43, i64 0
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %44, i64 0
  store i64 %46, ptr %47, align 4
  %48 = getelementptr i64, ptr %43, i64 1
  %49 = load i64, ptr %48, align 4
  %50 = getelementptr i64, ptr %44, i64 1
  store i64 %49, ptr %50, align 4
  %51 = getelementptr i64, ptr %43, i64 2
  %52 = load i64, ptr %51, align 4
  %53 = getelementptr i64, ptr %44, i64 2
  store i64 %52, ptr %53, align 4
  %54 = getelementptr i64, ptr %43, i64 3
  %55 = load i64, ptr %54, align 4
  %56 = getelementptr i64, ptr %44, i64 3
  store i64 %55, ptr %56, align 4
  %57 = getelementptr ptr, ptr %44, i64 4
  store i64 4, ptr %57, align 4
  call void @set_tape_data(ptr %44, i64 5)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %58 = getelementptr ptr, ptr %2, i64 0
  %59 = getelementptr ptr, ptr %58, i64 4
  %vector_length83 = load i64, ptr %59, align 4
  %60 = add i64 %vector_length83, 1
  %61 = call ptr @getTransactionHash(ptr %58, ptr %59)
  %62 = call ptr @heap_malloc(i64 5)
  %63 = getelementptr i64, ptr %61, i64 0
  %64 = load i64, ptr %63, align 4
  %65 = getelementptr i64, ptr %62, i64 0
  store i64 %64, ptr %65, align 4
  %66 = getelementptr i64, ptr %61, i64 1
  %67 = load i64, ptr %66, align 4
  %68 = getelementptr i64, ptr %62, i64 1
  store i64 %67, ptr %68, align 4
  %69 = getelementptr i64, ptr %61, i64 2
  %70 = load i64, ptr %69, align 4
  %71 = getelementptr i64, ptr %62, i64 2
  store i64 %70, ptr %71, align 4
  %72 = getelementptr i64, ptr %61, i64 3
  %73 = load i64, ptr %72, align 4
  %74 = getelementptr i64, ptr %62, i64 3
  store i64 %73, ptr %74, align 4
  %75 = getelementptr ptr, ptr %62, i64 4
  store i64 4, ptr %75, align 4
  call void @set_tape_data(ptr %62, i64 5)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %76 = getelementptr ptr, ptr %2, i64 0
  call void @validate_from(ptr %76)
  %77 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %77, align 4
  call void @set_tape_data(ptr %77, i64 1)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %78 = getelementptr ptr, ptr %2, i64 0
  %79 = getelementptr ptr, ptr %78, i64 4
  %80 = load i64, ptr %79, align 4
  call void @validate_nonce(ptr %78, i64 %80)
  %81 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %81, align 4
  call void @set_tape_data(ptr %81, i64 1)
  ret void

func_10_dispatch:                                 ; preds = %entry
  %82 = getelementptr ptr, ptr %2, i64 0
  %83 = getelementptr ptr, ptr %82, i64 4
  %84 = getelementptr ptr, ptr %83, i64 4
  %decode_struct_field84 = getelementptr ptr, ptr %84, i64 0
  %decode_struct_field85 = getelementptr ptr, ptr %84, i64 4
  %decode_struct_field86 = getelementptr ptr, ptr %84, i64 8
  %vector_length87 = load i64, ptr %decode_struct_field86, align 4
  %85 = add i64 %vector_length87, 1
  %decode_struct_offset88 = add i64 8, %85
  %decode_struct_field89 = getelementptr ptr, ptr %84, i64 %decode_struct_offset88
  %vector_length90 = load i64, ptr %decode_struct_field89, align 4
  %86 = add i64 %vector_length90, 1
  %decode_struct_offset91 = add i64 %decode_struct_offset88, %86
  %87 = call ptr @heap_malloc(i64 4)
  %struct_member92 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %87, i32 0, i32 0
  store ptr %decode_struct_field84, ptr %struct_member92, align 8
  %struct_member93 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %87, i32 0, i32 1
  store ptr %decode_struct_field85, ptr %struct_member93, align 8
  %struct_member94 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %87, i32 0, i32 2
  store ptr %decode_struct_field86, ptr %struct_member94, align 8
  %struct_member95 = getelementptr inbounds { ptr, ptr, ptr, ptr }, ptr %87, i32 0, i32 3
  store ptr %decode_struct_field89, ptr %struct_member95, align 8
  call void @validate_tx(ptr %82, ptr %83, ptr %87)
  %88 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %88, align 4
  call void @set_tape_data(ptr %88, i64 1)
  ret void

func_11_dispatch:                                 ; preds = %entry
  %89 = getelementptr ptr, ptr %2, i64 0
  %vector_length96 = load i64, ptr %89, align 4
  %90 = add i64 %vector_length96, 1
  %91 = call ptr @hashL2Bytecode(ptr %89)
  %92 = call ptr @heap_malloc(i64 5)
  %93 = getelementptr i64, ptr %91, i64 0
  %94 = load i64, ptr %93, align 4
  %95 = getelementptr i64, ptr %92, i64 0
  store i64 %94, ptr %95, align 4
  %96 = getelementptr i64, ptr %91, i64 1
  %97 = load i64, ptr %96, align 4
  %98 = getelementptr i64, ptr %92, i64 1
  store i64 %97, ptr %98, align 4
  %99 = getelementptr i64, ptr %91, i64 2
  %100 = load i64, ptr %99, align 4
  %101 = getelementptr i64, ptr %92, i64 2
  store i64 %100, ptr %101, align 4
  %102 = getelementptr i64, ptr %91, i64 3
  %103 = load i64, ptr %102, align 4
  %104 = getelementptr i64, ptr %92, i64 3
  store i64 %103, ptr %104, align 4
  %105 = getelementptr ptr, ptr %92, i64 4
  store i64 4, ptr %105, align 4
  call void @set_tape_data(ptr %92, i64 5)
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
