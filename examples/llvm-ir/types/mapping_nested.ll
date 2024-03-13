; ModuleID = 'MappingNested'
source_filename = "mapping_nested"

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
  %2 = call ptr @heap_malloc(i64 8)
  %3 = getelementptr i64, ptr %0, i64 7
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr i64, ptr %1, i64 7
  %6 = load i64, ptr %5, align 4
  %7 = add i64 %4, %6
  %sum_with_carry = add i64 %7, 0
  %result = and i64 %sum_with_carry, 4294967295
  %carry = icmp ugt i64 %sum_with_carry, 4294967295
  %8 = zext i1 %carry to i64
  %9 = getelementptr i64, ptr %2, i64 7
  store i64 %result, ptr %9, align 4
  %10 = getelementptr i64, ptr %0, i64 6
  %11 = load i64, ptr %10, align 4
  %12 = getelementptr i64, ptr %1, i64 6
  %13 = load i64, ptr %12, align 4
  %14 = add i64 %11, %13
  %sum_with_carry1 = add i64 %14, %8
  %result2 = and i64 %sum_with_carry1, 4294967295
  %carry3 = icmp ugt i64 %sum_with_carry1, 4294967295
  %15 = zext i1 %carry3 to i64
  %16 = getelementptr i64, ptr %2, i64 6
  store i64 %result2, ptr %16, align 4
  %17 = getelementptr i64, ptr %0, i64 5
  %18 = load i64, ptr %17, align 4
  %19 = getelementptr i64, ptr %1, i64 5
  %20 = load i64, ptr %19, align 4
  %21 = add i64 %18, %20
  %sum_with_carry4 = add i64 %21, %15
  %result5 = and i64 %sum_with_carry4, 4294967295
  %carry6 = icmp ugt i64 %sum_with_carry4, 4294967295
  %22 = zext i1 %carry6 to i64
  %23 = getelementptr i64, ptr %2, i64 5
  store i64 %result5, ptr %23, align 4
  %24 = getelementptr i64, ptr %0, i64 4
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %1, i64 4
  %27 = load i64, ptr %26, align 4
  %28 = add i64 %25, %27
  %sum_with_carry7 = add i64 %28, %22
  %result8 = and i64 %sum_with_carry7, 4294967295
  %carry9 = icmp ugt i64 %sum_with_carry7, 4294967295
  %29 = zext i1 %carry9 to i64
  %30 = getelementptr i64, ptr %2, i64 4
  store i64 %result8, ptr %30, align 4
  %31 = getelementptr i64, ptr %0, i64 3
  %32 = load i64, ptr %31, align 4
  %33 = getelementptr i64, ptr %1, i64 3
  %34 = load i64, ptr %33, align 4
  %35 = add i64 %32, %34
  %sum_with_carry10 = add i64 %35, %29
  %result11 = and i64 %sum_with_carry10, 4294967295
  %carry12 = icmp ugt i64 %sum_with_carry10, 4294967295
  %36 = zext i1 %carry12 to i64
  %37 = getelementptr i64, ptr %2, i64 3
  store i64 %result11, ptr %37, align 4
  %38 = getelementptr i64, ptr %0, i64 2
  %39 = load i64, ptr %38, align 4
  %40 = getelementptr i64, ptr %1, i64 2
  %41 = load i64, ptr %40, align 4
  %42 = add i64 %39, %41
  %sum_with_carry13 = add i64 %42, %36
  %result14 = and i64 %sum_with_carry13, 4294967295
  %carry15 = icmp ugt i64 %sum_with_carry13, 4294967295
  %43 = zext i1 %carry15 to i64
  %44 = getelementptr i64, ptr %2, i64 2
  store i64 %result14, ptr %44, align 4
  %45 = getelementptr i64, ptr %0, i64 1
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %1, i64 1
  %48 = load i64, ptr %47, align 4
  %49 = add i64 %46, %48
  %sum_with_carry16 = add i64 %49, %43
  %result17 = and i64 %sum_with_carry16, 4294967295
  %carry18 = icmp ugt i64 %sum_with_carry16, 4294967295
  %50 = zext i1 %carry18 to i64
  %51 = getelementptr i64, ptr %2, i64 1
  store i64 %result17, ptr %51, align 4
  %52 = getelementptr i64, ptr %0, i64 0
  %53 = load i64, ptr %52, align 4
  %54 = getelementptr i64, ptr %1, i64 0
  %55 = load i64, ptr %54, align 4
  %56 = add i64 %53, %55
  %sum_with_carry19 = add i64 %56, %50
  call void @builtin_range_check(i64 %sum_with_carry19)
  %result20 = and i64 %sum_with_carry19, 4294967295
  %carry21 = icmp ugt i64 %sum_with_carry19, 4294967295
  %57 = zext i1 %carry21 to i64
  %58 = getelementptr i64, ptr %2, i64 0
  store i64 %result20, ptr %58, align 4
  ret ptr %2
}

declare ptr @u256_sub(ptr, ptr)

define void @setNonce(ptr %0, i64 %1) {
entry:
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
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
  %12 = load i64, ptr %_nonce, align 4
  %13 = call ptr @heap_malloc(i64 4)
  %14 = getelementptr i64, ptr %13, i64 0
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %13, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %13, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %13, i64 3
  store i64 %12, ptr %17, align 4
  %18 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %11, ptr %18, i64 4)
  %19 = getelementptr i64, ptr %18, i64 4
  call void @memcpy(ptr %13, ptr %19, i64 4)
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
  %26 = icmp eq i64 %storage_value, 0
  %27 = zext i1 %26 to i64
  call void @builtin_assert(i64 %27)
  %28 = load ptr, ptr %_address, align 8
  %29 = call ptr @heap_malloc(i64 4)
  %30 = getelementptr i64, ptr %29, i64 0
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %29, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %29, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %29, i64 3
  store i64 0, ptr %33, align 4
  %34 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %29, ptr %34, i64 4)
  %35 = getelementptr i64, ptr %34, i64 4
  call void @memcpy(ptr %28, ptr %35, i64 4)
  %36 = getelementptr i64, ptr %35, i64 4
  %37 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %34, ptr %37, i64 8)
  %38 = load i64, ptr %_nonce, align 4
  %39 = call ptr @heap_malloc(i64 4)
  %40 = getelementptr i64, ptr %39, i64 0
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %39, i64 1
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %39, i64 2
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %39, i64 3
  store i64 %38, ptr %43, align 4
  %44 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %37, ptr %44, i64 4)
  %45 = getelementptr i64, ptr %44, i64 4
  call void @memcpy(ptr %39, ptr %45, i64 4)
  %46 = getelementptr i64, ptr %45, i64 4
  %47 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %44, ptr %47, i64 8)
  %48 = call ptr @heap_malloc(i64 4)
  %49 = getelementptr i64, ptr %48, i64 0
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %48, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %48, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %48, i64 3
  store i64 1, ptr %52, align 4
  call void @set_storage(ptr %47, ptr %48)
  %53 = load ptr, ptr %_address, align 8
  %54 = call ptr @heap_malloc(i64 4)
  %55 = getelementptr i64, ptr %54, i64 0
  store i64 0, ptr %55, align 4
  %56 = getelementptr i64, ptr %54, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %54, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %54, i64 3
  store i64 0, ptr %58, align 4
  %59 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %54, ptr %59, i64 4)
  %60 = getelementptr i64, ptr %59, i64 4
  call void @memcpy(ptr %53, ptr %60, i64 4)
  %61 = getelementptr i64, ptr %60, i64 4
  %62 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %59, ptr %62, i64 8)
  %63 = load i64, ptr %_nonce, align 4
  %64 = call ptr @heap_malloc(i64 4)
  %65 = getelementptr i64, ptr %64, i64 0
  store i64 0, ptr %65, align 4
  %66 = getelementptr i64, ptr %64, i64 1
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %64, i64 2
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %64, i64 3
  store i64 %63, ptr %68, align 4
  %69 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %62, ptr %69, i64 4)
  %70 = getelementptr i64, ptr %69, i64 4
  call void @memcpy(ptr %64, ptr %70, i64 4)
  %71 = getelementptr i64, ptr %70, i64 4
  %72 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %69, ptr %72, i64 8)
  %73 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %72, ptr %73)
  %74 = getelementptr i64, ptr %73, i64 3
  %storage_value1 = load i64, ptr %74, align 4
  %75 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %72, ptr %75, i64 4)
  %last_elem_ptr2 = getelementptr i64, ptr %75, i64 3
  %76 = load i64, ptr %last_elem_ptr2, align 4
  %last_elem3 = add i64 %76, 1
  store i64 %last_elem3, ptr %last_elem_ptr2, align 4
  call void @builtin_assert(i64 %storage_value1)
  ret void
}

define void @vote_for() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = getelementptr i64, ptr %0, i64 0
  store i64 0, ptr %1, align 4
  %2 = getelementptr i64, ptr %0, i64 1
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %0, i64 2
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %0, i64 3
  store i64 1, ptr %4, align 4
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 10, ptr %9, align 4
  %10 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %0, ptr %10, i64 4)
  %11 = getelementptr i64, ptr %10, i64 4
  call void @memcpy(ptr %5, ptr %11, i64 4)
  %12 = getelementptr i64, ptr %11, i64 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %10, ptr %13, i64 8)
  %14 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %14, i64 12)
  %15 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %13, ptr %15, i64 4)
  %16 = getelementptr i64, ptr %15, i64 4
  call void @memcpy(ptr %14, ptr %16, i64 4)
  %17 = getelementptr i64, ptr %16, i64 4
  %18 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %15, ptr %18, i64 8)
  %19 = call ptr @heap_malloc(i64 4)
  %20 = getelementptr i64, ptr %19, i64 0
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %19, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %19, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %19, i64 3
  store i64 99, ptr %23, align 4
  call void @set_storage(ptr %18, ptr %19)
  %24 = call ptr @heap_malloc(i64 4)
  %25 = getelementptr i64, ptr %24, i64 0
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %24, i64 1
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %24, i64 2
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %24, i64 3
  store i64 1, ptr %28, align 4
  %29 = call ptr @heap_malloc(i64 4)
  %30 = getelementptr i64, ptr %29, i64 0
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %29, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %29, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %29, i64 3
  store i64 10, ptr %33, align 4
  %34 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %24, ptr %34, i64 4)
  %35 = getelementptr i64, ptr %34, i64 4
  call void @memcpy(ptr %29, ptr %35, i64 4)
  %36 = getelementptr i64, ptr %35, i64 4
  %37 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %34, ptr %37, i64 8)
  %38 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %38, i64 12)
  %39 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %37, ptr %39, i64 4)
  %40 = getelementptr i64, ptr %39, i64 4
  call void @memcpy(ptr %38, ptr %40, i64 4)
  %41 = getelementptr i64, ptr %40, i64 4
  %42 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %39, ptr %42, i64 8)
  %43 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %42, ptr %43)
  %44 = getelementptr i64, ptr %43, i64 3
  %storage_value = load i64, ptr %44, align 4
  %45 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %42, ptr %45, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %45, i64 3
  %46 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %46, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  call void @prophet_printf(i64 %storage_value, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1093482716, label %func_0_dispatch
    i64 1303130570, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = getelementptr ptr, ptr %3, i64 4
  %5 = load i64, ptr %4, align 4
  call void @setNonce(ptr %3, i64 %5)
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @vote_for()
  %7 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %7, align 4
  call void @set_tape_data(ptr %7, i64 1)
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
