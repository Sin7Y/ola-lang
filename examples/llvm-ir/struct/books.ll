; ModuleID = 'BookExample'
source_filename = "books"

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

define ptr @createBook(i64 %0, ptr %1) {
entry:
  %name = alloca ptr, align 8
  %id = alloca i64, align 8
  store i64 %0, ptr %id, align 4
  store ptr %1, ptr %name, align 8
  %2 = load ptr, ptr %name, align 8
  %3 = call ptr @heap_malloc(i64 3)
  %struct_member = getelementptr inbounds { i64, ptr, ptr }, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %id, align 4
  store i64 %4, ptr %struct_member, align 4
  %struct_member1 = getelementptr inbounds { i64, ptr, ptr }, ptr %3, i32 0, i32 1
  store ptr %2, ptr %struct_member1, align 8
  %struct_member2 = getelementptr inbounds { i64, ptr, ptr }, ptr %3, i32 0, i32 2
  %5 = call ptr @vector_new(i64 5)
  %vector_data = getelementptr i64, ptr %5, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 112, ptr %index_access, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 2
  store i64 116, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 3
  store i64 101, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 4
  store i64 114, ptr %index_access6, align 4
  store ptr %5, ptr %struct_member2, align 8
  %6 = call ptr @heap_malloc(i64 4)
  %index_access7 = getelementptr i64, ptr %6, i64 3
  store i64 -1670511077848758898, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %6, i64 2
  store i64 68930750687700470, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %6, i64 1
  store i64 -9023208100383950340, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %6, i64 0
  store i64 876009939773297099, ptr %index_access10, align 4
  %7 = load i64, ptr %id, align 4
  %8 = call ptr @heap_malloc(i64 4)
  %9 = getelementptr i64, ptr %8, i64 0
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %8, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %8, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %8, i64 3
  store i64 %7, ptr %12, align 4
  %vector_length = load i64, ptr %2, align 4
  %13 = add i64 %vector_length, 1
  %14 = call ptr @vector_new(i64 %13)
  %15 = getelementptr ptr, ptr %14, i64 1
  %vector_length11 = load i64, ptr %2, align 4
  %16 = add i64 %vector_length11, 1
  call void @memcpy(ptr %2, ptr %15, i64 %16)
  %vector_length12 = load i64, ptr %14, align 4
  %vector_data13 = getelementptr i64, ptr %14, i64 1
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data13, ptr %17, i64 %vector_length12)
  %18 = call ptr @vector_new(i64 5)
  %vector_data14 = getelementptr i64, ptr %18, i64 1
  %index_access15 = getelementptr i64, ptr %vector_data14, i64 0
  store i64 112, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %vector_data14, i64 1
  store i64 101, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %vector_data14, i64 2
  store i64 116, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %vector_data14, i64 3
  store i64 101, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %vector_data14, i64 4
  store i64 114, ptr %index_access19, align 4
  %19 = call ptr @vector_new(i64 3)
  %vector_data20 = getelementptr i64, ptr %19, i64 1
  %topic_ptr = getelementptr ptr, ptr %vector_data20, i64 0
  store ptr %6, ptr %topic_ptr, align 8
  %topic_ptr21 = getelementptr ptr, ptr %vector_data20, i64 1
  store ptr %8, ptr %topic_ptr21, align 8
  %topic_ptr22 = getelementptr ptr, ptr %vector_data20, i64 2
  store ptr %17, ptr %topic_ptr22, align 8
  %vector_length23 = load i64, ptr %18, align 4
  %20 = add i64 %vector_length23, 1
  %21 = call ptr @vector_new(i64 %20)
  %22 = getelementptr ptr, ptr %21, i64 1
  %vector_length24 = load i64, ptr %18, align 4
  %23 = add i64 %vector_length24, 1
  call void @memcpy(ptr %18, ptr %22, i64 %23)
  call void @emit_event(ptr %19, ptr %21)
  ret ptr %3
}

define ptr @getBookName(ptr %0) {
entry:
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %struct_member = getelementptr inbounds { i64, ptr, ptr }, ptr %1, i32 0, i32 1
  %2 = load ptr, ptr %struct_member, align 8
  ret ptr %2
}

define i64 @getBookId(ptr %0) {
entry:
  %b = alloca i64, align 8
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %struct_member = getelementptr inbounds { i64, ptr, ptr }, ptr %1, i32 0, i32 0
  %2 = load i64, ptr %struct_member, align 4
  %3 = add i64 %2, 1
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %b, align 4
  %4 = load i64, ptr %b, align 4
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 120553111, label %func_0_dispatch
    i64 621839196, label %func_1_dispatch
    i64 1272517693, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr ptr, ptr %3, i64 1
  %vector_length = load i64, ptr %5, align 4
  %6 = add i64 %vector_length, 1
  %7 = call ptr @createBook(i64 %4, ptr %5)
  %struct_member = getelementptr inbounds { i64, ptr, ptr }, ptr %7, i32 0, i32 1
  %8 = load ptr, ptr %struct_member, align 8
  %vector_length1 = load i64, ptr %8, align 4
  %9 = add i64 %vector_length1, 1
  %10 = add i64 1, %9
  %struct_member2 = getelementptr inbounds { i64, ptr, ptr }, ptr %7, i32 0, i32 2
  %11 = load ptr, ptr %struct_member2, align 8
  %vector_length3 = load i64, ptr %11, align 4
  %12 = add i64 %vector_length3, 1
  %13 = add i64 %10, %12
  %heap_size = add i64 %13, 1
  %14 = call ptr @heap_malloc(i64 %heap_size)
  %struct_member4 = getelementptr inbounds { i64, ptr, ptr }, ptr %7, i32 0, i32 0
  %strcut_member = load i64, ptr %struct_member4, align 4
  %struct_offset = getelementptr ptr, ptr %14, i64 0
  store i64 %strcut_member, ptr %struct_offset, align 4
  %struct_member5 = getelementptr inbounds { i64, ptr, ptr }, ptr %7, i32 0, i32 1
  %strcut_member6 = load ptr, ptr %struct_member5, align 8
  %struct_offset7 = getelementptr ptr, ptr %struct_offset, i64 1
  %vector_length8 = load i64, ptr %strcut_member6, align 4
  %15 = add i64 %vector_length8, 1
  call void @memcpy(ptr %strcut_member6, ptr %struct_offset7, i64 %15)
  %struct_size = add i64 %15, 1
  %struct_member9 = getelementptr inbounds { i64, ptr, ptr }, ptr %7, i32 0, i32 2
  %strcut_member10 = load ptr, ptr %struct_member9, align 8
  %struct_offset11 = getelementptr ptr, ptr %struct_offset7, i64 %15
  %vector_length12 = load i64, ptr %strcut_member10, align 4
  %16 = add i64 %vector_length12, 1
  call void @memcpy(ptr %strcut_member10, ptr %struct_offset11, i64 %16)
  %struct_size13 = add i64 %16, %struct_size
  %17 = getelementptr ptr, ptr %14, i64 %struct_size13
  store i64 %13, ptr %17, align 4
  call void @set_tape_data(ptr %14, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %18 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field = getelementptr ptr, ptr %18, i64 0
  %19 = load i64, ptr %decode_struct_field, align 4
  %decode_struct_field14 = getelementptr ptr, ptr %18, i64 1
  %vector_length15 = load i64, ptr %decode_struct_field14, align 4
  %20 = add i64 %vector_length15, 1
  %decode_struct_offset = add i64 1, %20
  %decode_struct_field16 = getelementptr ptr, ptr %18, i64 %decode_struct_offset
  %vector_length17 = load i64, ptr %decode_struct_field16, align 4
  %21 = add i64 %vector_length17, 1
  %decode_struct_offset18 = add i64 %decode_struct_offset, %21
  %22 = call ptr @heap_malloc(i64 3)
  %struct_member19 = getelementptr inbounds { i64, ptr, ptr }, ptr %22, i32 0, i32 0
  store i64 %19, ptr %struct_member19, align 4
  %struct_member20 = getelementptr inbounds { i64, ptr, ptr }, ptr %22, i32 0, i32 1
  store ptr %decode_struct_field14, ptr %struct_member20, align 8
  %struct_member21 = getelementptr inbounds { i64, ptr, ptr }, ptr %22, i32 0, i32 2
  store ptr %decode_struct_field16, ptr %struct_member21, align 8
  %23 = call ptr @getBookName(ptr %22)
  %vector_length22 = load i64, ptr %23, align 4
  %24 = add i64 %vector_length22, 1
  %heap_size23 = add i64 %24, 1
  %25 = call ptr @heap_malloc(i64 %heap_size23)
  %vector_length24 = load i64, ptr %23, align 4
  %26 = add i64 %vector_length24, 1
  call void @memcpy(ptr %23, ptr %25, i64 %26)
  %27 = getelementptr ptr, ptr %25, i64 %26
  store i64 %24, ptr %27, align 4
  call void @set_tape_data(ptr %25, i64 %heap_size23)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %28 = getelementptr ptr, ptr %2, i64 0
  %decode_struct_field25 = getelementptr ptr, ptr %28, i64 0
  %29 = load i64, ptr %decode_struct_field25, align 4
  %decode_struct_field26 = getelementptr ptr, ptr %28, i64 1
  %vector_length27 = load i64, ptr %decode_struct_field26, align 4
  %30 = add i64 %vector_length27, 1
  %decode_struct_offset28 = add i64 1, %30
  %decode_struct_field29 = getelementptr ptr, ptr %28, i64 %decode_struct_offset28
  %vector_length30 = load i64, ptr %decode_struct_field29, align 4
  %31 = add i64 %vector_length30, 1
  %decode_struct_offset31 = add i64 %decode_struct_offset28, %31
  %32 = call ptr @heap_malloc(i64 3)
  %struct_member32 = getelementptr inbounds { i64, ptr, ptr }, ptr %32, i32 0, i32 0
  store i64 %29, ptr %struct_member32, align 4
  %struct_member33 = getelementptr inbounds { i64, ptr, ptr }, ptr %32, i32 0, i32 1
  store ptr %decode_struct_field26, ptr %struct_member33, align 8
  %struct_member34 = getelementptr inbounds { i64, ptr, ptr }, ptr %32, i32 0, i32 2
  store ptr %decode_struct_field29, ptr %struct_member34, align 8
  %33 = call i64 @getBookId(ptr %32)
  %34 = call ptr @heap_malloc(i64 2)
  store i64 %33, ptr %34, align 4
  %35 = getelementptr ptr, ptr %34, i64 1
  store i64 1, ptr %35, align 4
  call void @set_tape_data(ptr %34, i64 2)
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
