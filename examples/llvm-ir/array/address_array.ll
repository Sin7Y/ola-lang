; ModuleID = 'AddressArrayTest'
source_filename = "address_array"

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

define i64 @address_array_fiexed() {
entry:
  %index_alloca = alloca i64, align 8
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x ptr], ptr %0, i64 0, i64 0
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 3
  store i64 18, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %index_access3, align 4
  store ptr %1, ptr %elemptr0, align 8
  %elemptr1 = getelementptr [3 x ptr], ptr %0, i64 0, i64 1
  %2 = call ptr @heap_malloc(i64 4)
  %index_access4 = getelementptr i64, ptr %2, i64 3
  store i64 52, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access7, align 4
  store ptr %2, ptr %elemptr1, align 8
  %elemptr2 = getelementptr [3 x ptr], ptr %0, i64 0, i64 2
  %3 = call ptr @heap_malloc(i64 4)
  %index_access8 = getelementptr i64, ptr %3, i64 3
  store i64 86, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %index_access11, align 4
  store ptr %3, ptr %elemptr2, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access12 = getelementptr [3 x ptr], ptr %0, i64 0, i64 %index_value
  %address_start = ptrtoint ptr %index_access12 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret i64 3
}

define i64 @address_array_dynamic() {
entry:
  %index_alloca = alloca i64, align 8
  %0 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %0, i64 1
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 3
  store i64 18, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr ptr, ptr %vector_data, i64 0
  store ptr %1, ptr %index_access4, align 8
  %2 = call ptr @heap_malloc(i64 4)
  %index_access5 = getelementptr i64, ptr %2, i64 3
  store i64 52, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access8, align 4
  %index_access9 = getelementptr ptr, ptr %vector_data, i64 1
  store ptr %2, ptr %index_access9, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %index_access10 = getelementptr i64, ptr %3, i64 3
  store i64 86, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %index_access13, align 4
  %index_access14 = getelementptr ptr, ptr %vector_data, i64 2
  store ptr %3, ptr %index_access14, align 8
  %vector_length = load i64, ptr %0, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %vector_data15 = getelementptr i64, ptr %0, i64 1
  %index_access16 = getelementptr ptr, ptr %vector_data15, i64 %index_value
  %address_start = ptrtoint ptr %index_access16 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_length17 = load i64, ptr %0, align 4
  ret i64 %vector_length17
}

define ptr @address_array_fiexed_return() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x ptr], ptr %0, i64 0, i64 0
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 3
  store i64 18, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %index_access3, align 4
  store ptr %1, ptr %elemptr0, align 8
  %elemptr1 = getelementptr [3 x ptr], ptr %0, i64 0, i64 1
  %2 = call ptr @heap_malloc(i64 4)
  %index_access4 = getelementptr i64, ptr %2, i64 3
  store i64 52, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access7, align 4
  store ptr %2, ptr %elemptr1, align 8
  %elemptr2 = getelementptr [3 x ptr], ptr %0, i64 0, i64 2
  %3 = call ptr @heap_malloc(i64 4)
  %index_access8 = getelementptr i64, ptr %3, i64 3
  store i64 86, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %index_access11, align 4
  store ptr %3, ptr %elemptr2, align 8
  ret ptr %0
}

define ptr @address_array_dynamic_return() {
entry:
  %0 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %0, i64 1
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 3
  store i64 18, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr ptr, ptr %vector_data, i64 0
  store ptr %1, ptr %index_access4, align 8
  %2 = call ptr @heap_malloc(i64 4)
  %index_access5 = getelementptr i64, ptr %2, i64 3
  store i64 52, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access8, align 4
  %index_access9 = getelementptr ptr, ptr %vector_data, i64 1
  store ptr %2, ptr %index_access9, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %index_access10 = getelementptr i64, ptr %3, i64 3
  store i64 86, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %index_access13, align 4
  %index_access14 = getelementptr ptr, ptr %vector_data, i64 2
  store ptr %3, ptr %index_access14, align 8
  ret ptr %0
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr24 = alloca i64, align 8
  %buffer_offset22 = alloca i64, align 8
  %index_ptr11 = alloca i64, align 8
  %array_size10 = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_size = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 1427901889, label %func_0_dispatch
    i64 1100147071, label %func_1_dispatch
    i64 430167994, label %func_2_dispatch
    i64 1552199841, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call i64 @address_array_fiexed()
  %4 = call ptr @heap_malloc(i64 2)
  store i64 %3, ptr %4, align 4
  %5 = getelementptr ptr, ptr %4, i64 1
  store i64 1, ptr %5, align 4
  call void @set_tape_data(ptr %4, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %6 = call i64 @address_array_dynamic()
  %7 = call ptr @heap_malloc(i64 2)
  store i64 %6, ptr %7, align 4
  %8 = getelementptr ptr, ptr %7, i64 1
  store i64 1, ptr %8, align 4
  call void @set_tape_data(ptr %7, i64 2)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %9 = call ptr @address_array_fiexed_return()
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_2_dispatch
  %10 = load i64, ptr %index_ptr, align 4
  %11 = icmp ult i64 %10, 3
  br i1 %11, label %body, label %end_for

body:                                             ; preds = %cond
  %array_index = load i64, ptr %index_ptr, align 4
  %12 = sub i64 2, %array_index
  call void @builtin_range_check(i64 %12)
  %index_access = getelementptr [3 x ptr], ptr %9, i64 0, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %13 = load i64, ptr %array_size, align 4
  %14 = add i64 %13, 4
  store i64 %14, ptr %array_size, align 4
  br label %next

next:                                             ; preds = %body
  %index = load i64, ptr %index_ptr, align 4
  %15 = add i64 %index, 1
  store i64 %15, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %16 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %16, 1
  %17 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

cond2:                                            ; preds = %next4, %end_for
  %18 = load i64, ptr %index_ptr1, align 4
  %19 = icmp ult i64 %18, 3
  br i1 %19, label %body3, label %end_for5

body3:                                            ; preds = %cond2
  %array_index6 = load i64, ptr %index_ptr1, align 4
  %20 = sub i64 2, %array_index6
  call void @builtin_range_check(i64 %20)
  %index_access7 = getelementptr [3 x ptr], ptr %9, i64 0, i64 %array_index6
  %array_element8 = load ptr, ptr %index_access7, align 8
  %21 = load i64, ptr %buffer_offset, align 4
  %22 = getelementptr ptr, ptr %17, i64 %21
  %23 = getelementptr i64, ptr %array_element8, i64 0
  %24 = load i64, ptr %23, align 4
  %25 = getelementptr i64, ptr %22, i64 0
  store i64 %24, ptr %25, align 4
  %26 = getelementptr i64, ptr %array_element8, i64 1
  %27 = load i64, ptr %26, align 4
  %28 = getelementptr i64, ptr %22, i64 1
  store i64 %27, ptr %28, align 4
  %29 = getelementptr i64, ptr %array_element8, i64 2
  %30 = load i64, ptr %29, align 4
  %31 = getelementptr i64, ptr %22, i64 2
  store i64 %30, ptr %31, align 4
  %32 = getelementptr i64, ptr %array_element8, i64 3
  %33 = load i64, ptr %32, align 4
  %34 = getelementptr i64, ptr %22, i64 3
  store i64 %33, ptr %34, align 4
  %35 = load i64, ptr %buffer_offset, align 4
  %36 = add i64 %35, 4
  store i64 %36, ptr %buffer_offset, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index9 = load i64, ptr %index_ptr1, align 4
  %37 = add i64 %index9, 1
  store i64 %37, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  %38 = load i64, ptr %buffer_offset, align 4
  %39 = getelementptr ptr, ptr %17, i64 %38
  store i64 %16, ptr %39, align 4
  call void @set_tape_data(ptr %17, i64 %heap_size)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %40 = call ptr @address_array_dynamic_return()
  store i64 0, ptr %array_size10, align 4
  %41 = load i64, ptr %array_size10, align 4
  %42 = add i64 %41, 1
  store i64 %42, ptr %array_size10, align 4
  store i64 0, ptr %index_ptr11, align 4
  br label %cond12

cond12:                                           ; preds = %next14, %func_3_dispatch
  %vector_length = load i64, ptr %40, align 4
  %43 = load i64, ptr %index_ptr11, align 4
  %44 = icmp ult i64 %43, %vector_length
  br i1 %44, label %body13, label %end_for15

body13:                                           ; preds = %cond12
  %array_index16 = load i64, ptr %index_ptr11, align 4
  %vector_length17 = load i64, ptr %40, align 4
  %45 = sub i64 %vector_length17, 1
  %46 = sub i64 %45, %array_index16
  call void @builtin_range_check(i64 %46)
  %vector_data = getelementptr i64, ptr %40, i64 1
  %index_access18 = getelementptr ptr, ptr %vector_data, i64 %array_index16
  %array_element19 = load ptr, ptr %index_access18, align 8
  %47 = load i64, ptr %array_size10, align 4
  %48 = add i64 %47, 4
  store i64 %48, ptr %array_size10, align 4
  br label %next14

next14:                                           ; preds = %body13
  %index20 = load i64, ptr %index_ptr11, align 4
  %49 = add i64 %index20, 1
  store i64 %49, ptr %index_ptr11, align 4
  br label %cond12

end_for15:                                        ; preds = %cond12
  %50 = load i64, ptr %array_size10, align 4
  %heap_size21 = add i64 %50, 1
  %51 = call ptr @heap_malloc(i64 %heap_size21)
  store i64 0, ptr %buffer_offset22, align 4
  %52 = load i64, ptr %buffer_offset22, align 4
  %53 = add i64 %52, 1
  store i64 %53, ptr %buffer_offset22, align 4
  %54 = getelementptr ptr, ptr %51, i64 %52
  %vector_length23 = load i64, ptr %40, align 4
  store i64 %vector_length23, ptr %54, align 4
  store i64 0, ptr %index_ptr24, align 4
  br label %cond25

cond25:                                           ; preds = %next27, %end_for15
  %vector_length29 = load i64, ptr %40, align 4
  %55 = load i64, ptr %index_ptr24, align 4
  %56 = icmp ult i64 %55, %vector_length29
  br i1 %56, label %body26, label %end_for28

body26:                                           ; preds = %cond25
  %array_index30 = load i64, ptr %index_ptr24, align 4
  %vector_length31 = load i64, ptr %40, align 4
  %57 = sub i64 %vector_length31, 1
  %58 = sub i64 %57, %array_index30
  call void @builtin_range_check(i64 %58)
  %vector_data32 = getelementptr i64, ptr %40, i64 1
  %index_access33 = getelementptr ptr, ptr %vector_data32, i64 %array_index30
  %array_element34 = load ptr, ptr %index_access33, align 8
  %59 = load i64, ptr %buffer_offset22, align 4
  %60 = getelementptr ptr, ptr %51, i64 %59
  %61 = getelementptr i64, ptr %array_element34, i64 0
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr i64, ptr %60, i64 0
  store i64 %62, ptr %63, align 4
  %64 = getelementptr i64, ptr %array_element34, i64 1
  %65 = load i64, ptr %64, align 4
  %66 = getelementptr i64, ptr %60, i64 1
  store i64 %65, ptr %66, align 4
  %67 = getelementptr i64, ptr %array_element34, i64 2
  %68 = load i64, ptr %67, align 4
  %69 = getelementptr i64, ptr %60, i64 2
  store i64 %68, ptr %69, align 4
  %70 = getelementptr i64, ptr %array_element34, i64 3
  %71 = load i64, ptr %70, align 4
  %72 = getelementptr i64, ptr %60, i64 3
  store i64 %71, ptr %72, align 4
  %73 = load i64, ptr %buffer_offset22, align 4
  %74 = add i64 %73, 4
  store i64 %74, ptr %buffer_offset22, align 4
  br label %next27

next27:                                           ; preds = %body26
  %index35 = load i64, ptr %index_ptr24, align 4
  %75 = add i64 %index35, 1
  store i64 %75, ptr %index_ptr24, align 4
  br label %cond25

end_for28:                                        ; preds = %cond25
  %76 = load i64, ptr %buffer_offset22, align 4
  %77 = getelementptr ptr, ptr %51, i64 %76
  store i64 %50, ptr %77, align 4
  call void @set_tape_data(ptr %51, i64 %heap_size21)
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
