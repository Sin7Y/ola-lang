; ModuleID = 'StringExample'
source_filename = "storage_string"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define void @memcpy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
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
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp ugt i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define void @u32_div_mod(i64 %0, i64 %1, ptr %2, ptr %3) {
entry:
  %remainder_alloca = alloca ptr, align 8
  %quotient_alloca = alloca ptr, align 8
  %divisor_alloca = alloca i64, align 8
  %dividend_alloca = alloca i64, align 8
  store i64 %0, ptr %dividend_alloca, align 4
  %dividend = load i64, ptr %dividend_alloca, align 4
  store i64 %1, ptr %divisor_alloca, align 4
  %divisor = load i64, ptr %divisor_alloca, align 4
  store ptr %2, ptr %quotient_alloca, align 8
  %quotient = load ptr, ptr %quotient_alloca, align 8
  store ptr %3, ptr %remainder_alloca, align 8
  %remainder = load ptr, ptr %remainder_alloca, align 8
  %4 = call i64 @prophet_u32_mod(i64 %dividend, i64 %divisor)
  call void @builtin_range_check(i64 %4)
  %5 = add i64 %4, 1
  %6 = sub i64 %divisor, %5
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @prophet_u32_div(i64 %dividend, i64 %divisor)
  call void @builtin_range_check(ptr %quotient)
  %8 = mul i64 %7, %divisor
  %9 = add i64 %8, %4
  %10 = icmp eq i64 %9, %dividend
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  store i64 %7, ptr %quotient, align 4
  store i64 %4, ptr %remainder, align 4
  ret void
}

define i64 @u32_power(i64 %0, i64 %1) {
entry:
  %exponent_alloca = alloca i64, align 8
  %base_alloca = alloca i64, align 8
  store i64 %0, ptr %base_alloca, align 4
  %base = load i64, ptr %base_alloca, align 4
  store i64 %1, ptr %exponent_alloca, align 4
  %exponent = load i64, ptr %exponent_alloca, align 4
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = phi i64 [ 0, %entry ], [ %inc, %loop ]
  %3 = phi i64 [ 1, %entry ], [ %multmp, %loop ]
  %inc = add i64 %2, 1
  %multmp = mul i64 %3, %base
  %loopcond = icmp ule i64 %inc, %exponent
  br i1 %loopcond, label %loop, label %exit

exit:                                             ; preds = %loop
  call void @builtin_range_check(i64 %3)
  ret i64 %3
}

define void @set(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca16 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %s = alloca ptr, align 8
  store ptr %0, ptr %s, align 8
  %3 = load ptr, ptr %s, align 8
  %length = load i64, ptr %3, align 4
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %5 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %5, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %8, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %9 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %9, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 0, ptr %heap_to_ptr4, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %12, align 4
  %13 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %13, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %length, ptr %heap_to_ptr6, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %16, align 4
  call void @set_storage(ptr %heap_to_ptr4, ptr %heap_to_ptr6)
  %17 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %17, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 0, ptr %heap_to_ptr8, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %20, align 4
  %21 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %21, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr10, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr10, ptr %2, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %22 = load ptr, ptr %2, align 8
  %23 = ptrtoint ptr %3 to i64
  %24 = add i64 %23, 1
  %vector_data = inttoptr i64 %24 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %25 = load i64, ptr %index_access, align 4
  %26 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %26, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %25, ptr %heap_to_ptr12, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %29, align 4
  call void @set_storage(ptr %22, ptr %heap_to_ptr12)
  %slot_value = load i64, ptr %22, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %22, align 4
  store ptr %22, ptr %2, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca16, align 4
  store ptr %heap_to_ptr10, ptr %1, align 8
  br label %cond13

cond13:                                           ; preds = %body14, %done
  %index_value17 = load i64, ptr %index_alloca16, align 4
  %loop_cond18 = icmp ult i64 %index_value17, %storage_value
  br i1 %loop_cond18, label %body14, label %done15

body14:                                           ; preds = %cond13
  %30 = load ptr, ptr %1, align 8
  %31 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %31, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr20, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr21 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %storage_key_ptr21, align 4
  %storage_key_ptr22 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %storage_key_ptr22, align 4
  %storage_key_ptr23 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %storage_key_ptr23, align 4
  call void @set_storage(ptr %30, ptr %heap_to_ptr20)
  %slot_value24 = load i64, ptr %30, align 4
  %slot_offset25 = add i64 %slot_value24, 1
  store i64 %slot_offset25, ptr %30, align 4
  store ptr %30, ptr %1, align 8
  %next_index26 = add i64 %index_value17, 1
  store i64 %next_index26, ptr %index_alloca16, align 4
  br label %cond13

done15:                                           ; preds = %cond13
  ret void
}

define void @setStringLiteral() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca24 = alloca i64, align 8
  %1 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %2 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %2, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 5, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data = inttoptr i64 %4 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access4, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %5 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %5, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %6 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %6, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 0, ptr %heap_to_ptr8, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %9, align 4
  call void @get_storage(ptr %heap_to_ptr8, ptr %heap_to_ptr6)
  %storage_value = load i64, ptr %heap_to_ptr6, align 4
  %10 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %10, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 0, ptr %heap_to_ptr10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %13, align 4
  %14 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %14, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %length, ptr %heap_to_ptr12, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %17, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr12)
  %18 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %18, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 0, ptr %heap_to_ptr14, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %21, align 4
  %22 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %22, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr14, ptr %heap_to_ptr16, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr16, ptr %1, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %23 = load ptr, ptr %1, align 8
  %24 = ptrtoint ptr %heap_to_ptr to i64
  %25 = add i64 %24, 1
  %vector_data17 = inttoptr i64 %25 to ptr
  %index_access18 = getelementptr i64, ptr %vector_data17, i64 %index_value
  %26 = load i64, ptr %index_access18, align 4
  %27 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %27, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %26, ptr %heap_to_ptr20, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %30, align 4
  call void @set_storage(ptr %23, ptr %heap_to_ptr20)
  %slot_value = load i64, ptr %23, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %23, align 4
  store ptr %23, ptr %1, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca24, align 4
  store ptr %heap_to_ptr16, ptr %0, align 8
  br label %cond21

cond21:                                           ; preds = %body22, %done
  %index_value25 = load i64, ptr %index_alloca24, align 4
  %loop_cond26 = icmp ult i64 %index_value25, %storage_value
  br i1 %loop_cond26, label %body22, label %done23

body22:                                           ; preds = %cond21
  %31 = load ptr, ptr %0, align 8
  %32 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %32, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr28, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr29 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 0, ptr %storage_key_ptr29, align 4
  %storage_key_ptr30 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 0, ptr %storage_key_ptr30, align 4
  %storage_key_ptr31 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 0, ptr %storage_key_ptr31, align 4
  call void @set_storage(ptr %31, ptr %heap_to_ptr28)
  %slot_value32 = load i64, ptr %31, align 4
  %slot_offset33 = add i64 %slot_value32, 1
  store i64 %slot_offset33, ptr %31, align 4
  store ptr %31, ptr %0, align 8
  %next_index34 = add i64 %index_value25, 1
  store i64 %next_index34, ptr %index_alloca24, align 4
  br label %cond21

done23:                                           ; preds = %cond21
  ret void
}

define ptr @get() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %1, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %2 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %2, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %5, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %length_and_data = add i64 %storage_value, 1
  %6 = call i64 @vector_new(i64 %length_and_data)
  %heap_start3 = sub i64 %6, %length_and_data
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 %storage_value, ptr %heap_to_ptr4, align 4
  %7 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %7, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 0, ptr %heap_to_ptr6, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %10, align 4
  %11 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %11, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr6, ptr %heap_to_ptr8, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr8, ptr %0, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %storage_value
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %12 = load ptr, ptr %0, align 8
  %13 = ptrtoint ptr %heap_to_ptr4 to i64
  %14 = add i64 %13, 1
  %vector_data = inttoptr i64 %14 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %15 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %15, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @get_storage(ptr %12, ptr %heap_to_ptr10)
  %storage_value11 = load i64, ptr %heap_to_ptr10, align 4
  %slot_value = load i64, ptr %12, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %12, align 4
  store i64 %storage_value11, ptr %index_access, align 4
  store ptr %12, ptr %0, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %heap_to_ptr4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1586025294, label %func_0_dispatch
    i64 515430227, label %func_1_dispatch
    i64 1021725805, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %length = load i64, ptr %3, align 4
  %4 = add i64 %length, 1
  call void @set(ptr %3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @setStringLiteral()
  ret void

func_2_dispatch:                                  ; preds = %entry
  %5 = call ptr @get()
  %length1 = load i64, ptr %5, align 4
  %6 = add i64 %length1, 1
  %heap_size = add i64 %6, 1
  %7 = call i64 @vector_new(i64 %heap_size)
  %heap_start = sub i64 %7, %heap_size
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %length2 = load i64, ptr %5, align 4
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %buffer_start = add i64 %8, 1
  %9 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %9, i64 1
  store i64 %length2, ptr %encode_value_ptr, align 4
  %10 = ptrtoint ptr %5 to i64
  %11 = add i64 %10, 1
  %vector_data = inttoptr i64 %11 to ptr
  call void @memcpy(ptr %vector_data, ptr %9, i64 %length2)
  %12 = add i64 %length2, 1
  %13 = add i64 %12, 0
  %encode_value_ptr3 = getelementptr i64, ptr %heap_to_ptr, i64 %13
  store i64 %6, ptr %encode_value_ptr3, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
  ret void
}

define void @main() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
