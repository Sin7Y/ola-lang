; ModuleID = 'NonceHolder'
source_filename = "NonceHolder"

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

define void @onlyEntrypointCall() {
entry:
  %ENTRY_POINT_ADDRESS = alloca ptr, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 32769, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %ENTRY_POINT_ADDRESS, align 8
  %1 = call i64 @vector_new(i64 12)
  %heap_start4 = sub i64 %1, 12
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  call void @get_tape_data(i64 %heap_start4, i64 12)
  %2 = load ptr, ptr %ENTRY_POINT_ADDRESS, align 8
  %3 = call i64 @memcmp_eq(ptr %heap_to_ptr5, ptr %2, i64 4)
  call void @builtin_assert(i64 %3)
  ret void
}

define i64 @isNonceUsed(ptr %0, i64 %1) {
entry:
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %8 = inttoptr i64 %heap_start1 to ptr
  call void @memcpy(ptr %heap_to_ptr, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %10, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %11 = load i64, ptr %_nonce, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %11, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  %16 = call i64 @vector_new(i64 8)
  %heap_start7 = sub i64 %16, 8
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %17 = inttoptr i64 %heap_start7 to ptr
  call void @memcpy(ptr %heap_to_ptr4, ptr %17, i64 4)
  %next_dest_offset9 = add i64 %heap_start7, 4
  %18 = inttoptr i64 %next_dest_offset9 to ptr
  call void @memcpy(ptr %heap_to_ptr6, ptr %18, i64 4)
  %19 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %19, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr11, i64 8)
  %20 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %20, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @get_storage(ptr %heap_to_ptr11, ptr %heap_to_ptr13)
  %storage_value = load i64, ptr %heap_to_ptr13, align 4
  %slot_value = load i64, ptr %heap_to_ptr11, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr11, align 4
  ret i64 %storage_value
}

define void @setNonce(ptr %0, i64 %1) {
entry:
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  call void @onlyEntrypointCall()
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %8 = inttoptr i64 %heap_start1 to ptr
  call void @memcpy(ptr %heap_to_ptr, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %10, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %11 = load i64, ptr %_nonce, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %11, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  %16 = call i64 @vector_new(i64 8)
  %heap_start7 = sub i64 %16, 8
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %17 = inttoptr i64 %heap_start7 to ptr
  call void @memcpy(ptr %heap_to_ptr4, ptr %17, i64 4)
  %next_dest_offset9 = add i64 %heap_start7, 4
  %18 = inttoptr i64 %next_dest_offset9 to ptr
  call void @memcpy(ptr %heap_to_ptr6, ptr %18, i64 4)
  %19 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %19, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr11, i64 8)
  %20 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %20, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @get_storage(ptr %heap_to_ptr11, ptr %heap_to_ptr13)
  %storage_value = load i64, ptr %heap_to_ptr13, align 4
  %slot_value = load i64, ptr %heap_to_ptr11, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr11, align 4
  %21 = icmp eq i64 %storage_value, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
  %23 = load ptr, ptr %_address, align 8
  %24 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %24, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 0, ptr %heap_to_ptr15, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %27, align 4
  %28 = call i64 @vector_new(i64 8)
  %heap_start16 = sub i64 %28, 8
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  %29 = inttoptr i64 %heap_start16 to ptr
  call void @memcpy(ptr %heap_to_ptr15, ptr %29, i64 4)
  %next_dest_offset18 = add i64 %heap_start16, 4
  %30 = inttoptr i64 %next_dest_offset18 to ptr
  call void @memcpy(ptr %23, ptr %30, i64 4)
  %31 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %31, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr17, ptr %heap_to_ptr20, i64 8)
  %32 = load i64, ptr %_nonce, align 4
  %33 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %33, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 %32, ptr %heap_to_ptr22, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %36, align 4
  %37 = call i64 @vector_new(i64 8)
  %heap_start23 = sub i64 %37, 8
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  %38 = inttoptr i64 %heap_start23 to ptr
  call void @memcpy(ptr %heap_to_ptr20, ptr %38, i64 4)
  %next_dest_offset25 = add i64 %heap_start23, 4
  %39 = inttoptr i64 %next_dest_offset25 to ptr
  call void @memcpy(ptr %heap_to_ptr22, ptr %39, i64 4)
  %40 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %40, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr24, ptr %heap_to_ptr27, i64 8)
  %41 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %41, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 1, ptr %heap_to_ptr29, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %44, align 4
  call void @set_storage(ptr %heap_to_ptr27, ptr %heap_to_ptr29)
  %45 = load ptr, ptr %_address, align 8
  %46 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %46, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  store i64 1, ptr %heap_to_ptr31, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr31, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr31, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  store i64 0, ptr %49, align 4
  %50 = call i64 @vector_new(i64 8)
  %heap_start32 = sub i64 %50, 8
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  %51 = inttoptr i64 %heap_start32 to ptr
  call void @memcpy(ptr %heap_to_ptr31, ptr %51, i64 4)
  %next_dest_offset34 = add i64 %heap_start32, 4
  %52 = inttoptr i64 %next_dest_offset34 to ptr
  call void @memcpy(ptr %45, ptr %52, i64 4)
  %53 = call i64 @vector_new(i64 4)
  %heap_start35 = sub i64 %53, 4
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr33, ptr %heap_to_ptr36, i64 8)
  %54 = load ptr, ptr %_address, align 8
  %55 = call i64 @vector_new(i64 4)
  %heap_start37 = sub i64 %55, 4
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  store i64 1, ptr %heap_to_ptr38, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr38, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr38, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr38, i64 3
  store i64 0, ptr %58, align 4
  %59 = call i64 @vector_new(i64 8)
  %heap_start39 = sub i64 %59, 8
  %heap_to_ptr40 = inttoptr i64 %heap_start39 to ptr
  %60 = inttoptr i64 %heap_start39 to ptr
  call void @memcpy(ptr %heap_to_ptr38, ptr %60, i64 4)
  %next_dest_offset41 = add i64 %heap_start39, 4
  %61 = inttoptr i64 %next_dest_offset41 to ptr
  call void @memcpy(ptr %54, ptr %61, i64 4)
  %62 = call i64 @vector_new(i64 4)
  %heap_start42 = sub i64 %62, 4
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr40, ptr %heap_to_ptr43, i64 8)
  %63 = call i64 @vector_new(i64 4)
  %heap_start44 = sub i64 %63, 4
  %heap_to_ptr45 = inttoptr i64 %heap_start44 to ptr
  call void @get_storage(ptr %heap_to_ptr43, ptr %heap_to_ptr45)
  %storage_value46 = load i64, ptr %heap_to_ptr45, align 4
  %slot_value47 = load i64, ptr %heap_to_ptr43, align 4
  %slot_offset48 = add i64 %slot_value47, 1
  store i64 %slot_offset48, ptr %heap_to_ptr43, align 4
  %64 = add i64 %storage_value46, 1
  call void @builtin_range_check(i64 %64)
  %65 = call i64 @vector_new(i64 4)
  %heap_start49 = sub i64 %65, 4
  %heap_to_ptr50 = inttoptr i64 %heap_start49 to ptr
  store i64 %64, ptr %heap_to_ptr50, align 4
  %66 = getelementptr i64, ptr %heap_to_ptr50, i64 1
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %heap_to_ptr50, i64 2
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %heap_to_ptr50, i64 3
  store i64 0, ptr %68, align 4
  call void @set_storage(ptr %heap_to_ptr36, ptr %heap_to_ptr50)
  ret void
}

define i64 @usedNonces(ptr %0) {
entry:
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = load ptr, ptr %_address, align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_to_ptr, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %5, align 4
  %6 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %6, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %7 = inttoptr i64 %heap_start1 to ptr
  call void @memcpy(ptr %heap_to_ptr, ptr %7, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %8 = inttoptr i64 %next_dest_offset to ptr
  call void @memcpy(ptr %1, ptr %8, i64 4)
  %9 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %9, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %10 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %10, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @get_storage(ptr %heap_to_ptr4, ptr %heap_to_ptr6)
  %storage_value = load i64, ptr %heap_to_ptr6, align 4
  %slot_value = load i64, ptr %heap_to_ptr4, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr4, align 4
  ret i64 %storage_value
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 698884830, label %func_0_dispatch
    i64 1390938593, label %func_1_dispatch
    i64 3694669121, label %func_2_dispatch
    i64 3422263526, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @onlyEntrypointCall()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = add i64 %input_start, 4
  %5 = inttoptr i64 %4 to ptr
  %decode_value = load i64, ptr %5, align 4
  %6 = call i64 @isNonceUsed(ptr %3, i64 %decode_value)
  %7 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %7, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %6, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr1, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %input_start2 = ptrtoint ptr %input to i64
  %8 = inttoptr i64 %input_start2 to ptr
  %9 = add i64 %input_start2, 4
  %10 = inttoptr i64 %9 to ptr
  %decode_value3 = load i64, ptr %10, align 4
  call void @setNonce(ptr %8, i64 %decode_value3)
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %input_start4 = ptrtoint ptr %input to i64
  %11 = inttoptr i64 %input_start4 to ptr
  %12 = call i64 @usedNonces(ptr %11)
  %13 = call i64 @vector_new(i64 2)
  %heap_start5 = sub i64 %13, 2
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr6, i64 0
  store i64 %12, ptr %encode_value_ptr7, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 1, ptr %encode_value_ptr8, align 4
  call void @set_tape_data(i64 %heap_start5, i64 2)
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
