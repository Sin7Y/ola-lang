; ModuleID = 'Voting'
source_filename = "vote"

@heap_address = internal global i64 -12884901885

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare void @get_context_data(ptr, i64)

declare void @get_tape_data(ptr, i64)

declare void @set_tape_data(ptr, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define ptr @heap_malloc(i64 %0) {
entry:
  %size_alloca = alloca i64, align 8
  store i64 %0, ptr %size_alloca, align 4
  %size = load i64, ptr %size_alloca, align 4
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %size
  store i64 %updated_address, ptr @heap_address, align 4
  %1 = inttoptr i64 %current_address to ptr
  ret ptr %1
}

define ptr @vector_new(i64 %0) {
entry:
  %size_alloca = alloca i64, align 8
  store i64 %0, ptr %size_alloca, align 4
  %size = load i64, ptr %size_alloca, align 4
  %1 = add i64 %size, 1
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %1
  store i64 %updated_address, ptr @heap_address, align 4
  %2 = inttoptr i64 %current_address to ptr
  store i64 %size, ptr %2, align 4
  ret ptr %2
}

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

define void @contract_init(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca14 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %3 = load ptr, ptr %proposalNames_, align 8
  %4 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %4, i64 12)
  %5 = call ptr @heap_malloc(i64 4)
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 3
  store i64 0, ptr %8, align 4
  call void @set_storage(ptr %5, ptr %4)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %9 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %3, align 4
  %10 = icmp ult i64 %9, %vector_length
  br i1 %10, label %body, label %endfor

body:                                             ; preds = %cond
  %11 = call ptr @heap_malloc(i64 4)
  %12 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %12, align 4
  %13 = getelementptr i64, ptr %12, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %12, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %12, i64 3
  store i64 0, ptr %15, align 4
  call void @get_storage(ptr %12, ptr %11)
  %storage_value = load i64, ptr %11, align 4
  %16 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %16, align 4
  %17 = getelementptr i64, ptr %16, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %16, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %16, i64 3
  store i64 0, ptr %19, align 4
  %20 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %16, ptr %20, i64 4)
  %hash_value_low = load i64, ptr %20, align 4
  %21 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %21
  store i64 %storage_array_offset, ptr %20, align 4
  %22 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { ptr, i64 }, ptr %22, i32 0, i32 0
  %23 = load i64, ptr %i, align 4
  %vector_length1 = load i64, ptr %3, align 4
  %24 = sub i64 %vector_length1, 1
  %25 = sub i64 %24, %23
  call void @builtin_range_check(i64 %25)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %23
  %26 = load ptr, ptr %index_access, align 8
  store ptr %26, ptr %struct_member, align 8
  %struct_member2 = getelementptr inbounds { ptr, i64 }, ptr %22, i32 0, i32 1
  store i64 0, ptr %struct_member2, align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %22, i32 0, i32 0
  %vector_length3 = load i64, ptr %name, align 4
  %27 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %20, ptr %27)
  %storage_value4 = load i64, ptr %27, align 4
  %slot_value = load i64, ptr %20, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %20, align 4
  %28 = call ptr @heap_malloc(i64 4)
  store i64 %vector_length3, ptr %28, align 4
  %29 = getelementptr i64, ptr %28, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %28, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %28, i64 3
  store i64 0, ptr %31, align 4
  call void @set_storage(ptr %20, ptr %28)
  %32 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %20, ptr %32, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %32, ptr %2, align 8
  br label %cond5

next:                                             ; preds = %done13
  %33 = load i64, ptr %i, align 4
  %34 = add i64 %33, 1
  store i64 %34, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond5:                                            ; preds = %body6, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length3
  br i1 %loop_cond, label %body6, label %done

body6:                                            ; preds = %cond5
  %35 = load ptr, ptr %2, align 8
  %vector_data7 = getelementptr i64, ptr %name, i64 1
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 %index_value
  %36 = load i64, ptr %index_access8, align 4
  %37 = call ptr @heap_malloc(i64 4)
  store i64 %36, ptr %37, align 4
  %38 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %40, align 4
  call void @set_storage(ptr %35, ptr %37)
  %slot_value9 = load i64, ptr %35, align 4
  %slot_offset10 = add i64 %slot_value9, 1
  store i64 %slot_offset10, ptr %35, align 4
  store ptr %35, ptr %2, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond5

done:                                             ; preds = %cond5
  store i64 %vector_length3, ptr %index_alloca14, align 4
  store ptr %32, ptr %1, align 8
  br label %cond11

cond11:                                           ; preds = %body12, %done
  %index_value15 = load i64, ptr %index_alloca14, align 4
  %loop_cond16 = icmp ult i64 %index_value15, %storage_value4
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %41 = load ptr, ptr %1, align 8
  %42 = call ptr @heap_malloc(i64 4)
  %storage_key_ptr = getelementptr i64, ptr %42, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr17 = getelementptr i64, ptr %42, i64 1
  store i64 0, ptr %storage_key_ptr17, align 4
  %storage_key_ptr18 = getelementptr i64, ptr %42, i64 2
  store i64 0, ptr %storage_key_ptr18, align 4
  %storage_key_ptr19 = getelementptr i64, ptr %42, i64 3
  store i64 0, ptr %storage_key_ptr19, align 4
  call void @set_storage(ptr %41, ptr %42)
  %slot_value20 = load i64, ptr %41, align 4
  %slot_offset21 = add i64 %slot_value20, 1
  store i64 %slot_offset21, ptr %41, align 4
  store ptr %41, ptr %1, align 8
  %next_index22 = add i64 %index_value15, 1
  store i64 %next_index22, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  %slot_value23 = load i64, ptr %20, align 4
  %slot_offset24 = add i64 %slot_value23, 1
  store i64 %slot_offset24, ptr %20, align 4
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %22, i32 0, i32 1
  %43 = load i64, ptr %voteCount, align 4
  %44 = call ptr @heap_malloc(i64 4)
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %44, i64 1
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %44, i64 2
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %44, i64 3
  store i64 0, ptr %47, align 4
  call void @set_storage(ptr %20, ptr %44)
  %new_length = add i64 %storage_value, 1
  %48 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %48, align 4
  %49 = getelementptr i64, ptr %48, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %48, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %48, i64 3
  store i64 0, ptr %51, align 4
  %52 = call ptr @heap_malloc(i64 4)
  store i64 %new_length, ptr %52, align 4
  %53 = getelementptr i64, ptr %52, i64 1
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %52, i64 2
  store i64 0, ptr %54, align 4
  %55 = getelementptr i64, ptr %52, i64 3
  store i64 0, ptr %55, align 4
  call void @set_storage(ptr %48, ptr %52)
  br label %next
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
  store i64 1, ptr %3, align 4
  %4 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 3
  store i64 0, ptr %6, align 4
  %7 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %3, ptr %7, i64 4)
  %8 = getelementptr i64, ptr %7, i64 4
  call void @memcpy(ptr %2, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  %10 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %7, ptr %10, i64 8)
  store ptr %10, ptr %sender, align 8
  %11 = load i64, ptr %sender, align 4
  %slot_offset = add i64 %11, 0
  %12 = call ptr @heap_malloc(i64 4)
  store i64 %slot_offset, ptr %12, align 4
  %13 = getelementptr i64, ptr %12, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %12, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %12, i64 3
  store i64 0, ptr %15, align 4
  %16 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %16, align 4
  %17 = getelementptr i64, ptr %16, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %16, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %16, i64 3
  store i64 0, ptr %19, align 4
  call void @set_storage(ptr %12, ptr %16)
  %20 = load i64, ptr %sender, align 4
  %slot_offset1 = add i64 %20, 1
  %21 = load i64, ptr %proposal_, align 4
  %22 = call ptr @heap_malloc(i64 4)
  store i64 %slot_offset1, ptr %22, align 4
  %23 = getelementptr i64, ptr %22, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %22, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %22, i64 3
  store i64 0, ptr %25, align 4
  %26 = call ptr @heap_malloc(i64 4)
  store i64 %21, ptr %26, align 4
  %27 = getelementptr i64, ptr %26, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %26, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %26, i64 3
  store i64 0, ptr %29, align 4
  call void @set_storage(ptr %22, ptr %26)
  %30 = load i64, ptr %proposal_, align 4
  %31 = call ptr @heap_malloc(i64 4)
  %32 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %32, align 4
  %33 = getelementptr i64, ptr %32, i64 1
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %32, i64 2
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %32, i64 3
  store i64 0, ptr %35, align 4
  call void @get_storage(ptr %32, ptr %31)
  %storage_value = load i64, ptr %31, align 4
  %36 = sub i64 %storage_value, 1
  %37 = sub i64 %36, %30
  call void @builtin_range_check(i64 %37)
  %38 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %38, align 4
  %39 = getelementptr i64, ptr %38, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %38, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %38, i64 3
  store i64 0, ptr %41, align 4
  %42 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %38, ptr %42, i64 4)
  %hash_value_low = load i64, ptr %42, align 4
  %43 = mul i64 %30, 2
  %storage_array_offset = add i64 %hash_value_low, %43
  store i64 %storage_array_offset, ptr %42, align 4
  %slot_value = load i64, ptr %42, align 4
  %slot_offset2 = add i64 %slot_value, 1
  store i64 %slot_offset2, ptr %42, align 4
  %44 = load i64, ptr %proposal_, align 4
  %45 = call ptr @heap_malloc(i64 4)
  %46 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %46, align 4
  %47 = getelementptr i64, ptr %46, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %46, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %46, i64 3
  store i64 0, ptr %49, align 4
  call void @get_storage(ptr %46, ptr %45)
  %storage_value3 = load i64, ptr %45, align 4
  %50 = sub i64 %storage_value3, 1
  %51 = sub i64 %50, %44
  call void @builtin_range_check(i64 %51)
  %52 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %52, align 4
  %53 = getelementptr i64, ptr %52, i64 1
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %52, i64 2
  store i64 0, ptr %54, align 4
  %55 = getelementptr i64, ptr %52, i64 3
  store i64 0, ptr %55, align 4
  %56 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %52, ptr %56, i64 4)
  %hash_value_low4 = load i64, ptr %56, align 4
  %57 = mul i64 %44, 2
  %storage_array_offset5 = add i64 %hash_value_low4, %57
  store i64 %storage_array_offset5, ptr %56, align 4
  %slot_value6 = load i64, ptr %56, align 4
  %slot_offset7 = add i64 %slot_value6, 1
  store i64 %slot_offset7, ptr %56, align 4
  %58 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %56, ptr %58)
  %storage_value8 = load i64, ptr %58, align 4
  %slot_value9 = load i64, ptr %56, align 4
  %slot_offset10 = add i64 %slot_value9, 1
  store i64 %slot_offset10, ptr %56, align 4
  %59 = add i64 %storage_value8, 1
  call void @builtin_range_check(i64 %59)
  %60 = call ptr @heap_malloc(i64 4)
  store i64 %59, ptr %60, align 4
  %61 = getelementptr i64, ptr %60, i64 1
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %60, i64 2
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %60, i64 3
  store i64 0, ptr %63, align 4
  call void @set_storage(ptr %42, ptr %60)
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
  store i64 2, ptr %2, align 4
  %3 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 3
  store i64 0, ptr %5, align 4
  call void @get_storage(ptr %2, ptr %1)
  %storage_value = load i64, ptr %1, align 4
  %6 = icmp ult i64 %0, %storage_value
  br i1 %6, label %body, label %endfor

body:                                             ; preds = %cond
  %7 = load i64, ptr %p, align 4
  %8 = call ptr @heap_malloc(i64 4)
  %9 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %9, align 4
  %10 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %9, i64 3
  store i64 0, ptr %12, align 4
  call void @get_storage(ptr %9, ptr %8)
  %storage_value1 = load i64, ptr %8, align 4
  %13 = sub i64 %storage_value1, 1
  %14 = sub i64 %13, %7
  call void @builtin_range_check(i64 %14)
  %15 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %15, align 4
  %16 = getelementptr i64, ptr %15, i64 1
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %15, i64 2
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %15, i64 3
  store i64 0, ptr %18, align 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %15, ptr %19, i64 4)
  %hash_value_low = load i64, ptr %19, align 4
  %20 = mul i64 %7, 2
  %storage_array_offset = add i64 %hash_value_low, %20
  store i64 %storage_array_offset, ptr %19, align 4
  %slot_value = load i64, ptr %19, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %19, align 4
  %21 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %19, ptr %21)
  %storage_value2 = load i64, ptr %21, align 4
  %slot_value3 = load i64, ptr %19, align 4
  %slot_offset4 = add i64 %slot_value3, 1
  store i64 %slot_offset4, ptr %19, align 4
  %22 = load i64, ptr %winningVoteCount, align 4
  %23 = icmp ugt i64 %storage_value2, %22
  br i1 %23, label %then, label %endif

next:                                             ; preds = %endif
  %24 = load i64, ptr %p, align 4
  %25 = add i64 %24, 1
  store i64 %25, ptr %p, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %26 = load i64, ptr %winningProposal_, align 4
  ret i64 %26

then:                                             ; preds = %body
  %27 = load i64, ptr %p, align 4
  %28 = call ptr @heap_malloc(i64 4)
  %29 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %29, align 4
  %30 = getelementptr i64, ptr %29, i64 1
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %29, i64 2
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %29, i64 3
  store i64 0, ptr %32, align 4
  call void @get_storage(ptr %29, ptr %28)
  %storage_value5 = load i64, ptr %28, align 4
  %33 = sub i64 %storage_value5, 1
  %34 = sub i64 %33, %27
  call void @builtin_range_check(i64 %34)
  %35 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %35, align 4
  %36 = getelementptr i64, ptr %35, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %35, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %35, i64 3
  store i64 0, ptr %38, align 4
  %39 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %35, ptr %39, i64 4)
  %hash_value_low6 = load i64, ptr %39, align 4
  %40 = mul i64 %27, 2
  %storage_array_offset7 = add i64 %hash_value_low6, %40
  store i64 %storage_array_offset7, ptr %39, align 4
  %slot_value8 = load i64, ptr %39, align 4
  %slot_offset9 = add i64 %slot_value8, 1
  store i64 %slot_offset9, ptr %39, align 4
  %41 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %39, ptr %41)
  %storage_value10 = load i64, ptr %41, align 4
  %slot_value11 = load i64, ptr %39, align 4
  %slot_offset12 = add i64 %slot_value11, 1
  store i64 %slot_offset12, ptr %39, align 4
  store i64 %storage_value10, ptr %winningVoteCount, align 4
  %42 = load i64, ptr %p, align 4
  store i64 %42, ptr %winningProposal_, align 4
  br label %endif

endif:                                            ; preds = %then, %body
  br label %next
}

define ptr @getWinnerName() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @winningProposal()
  %2 = call ptr @heap_malloc(i64 4)
  %3 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %3, align 4
  %4 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 3
  store i64 0, ptr %6, align 4
  call void @get_storage(ptr %3, ptr %2)
  %storage_value = load i64, ptr %2, align 4
  %7 = sub i64 %storage_value, 1
  %8 = sub i64 %7, %1
  call void @builtin_range_check(i64 %8)
  %9 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %9, align 4
  %10 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %9, i64 3
  store i64 0, ptr %12, align 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %9, ptr %13, i64 4)
  %hash_value_low = load i64, ptr %13, align 4
  %14 = mul i64 %1, 2
  %storage_array_offset = add i64 %hash_value_low, %14
  store i64 %storage_array_offset, ptr %13, align 4
  %slot_value = load i64, ptr %13, align 4
  %slot_offset = add i64 %slot_value, 0
  store i64 %slot_offset, ptr %13, align 4
  %15 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %15)
  %storage_value1 = load i64, ptr %15, align 4
  %slot_value2 = load i64, ptr %13, align 4
  %slot_offset3 = add i64 %slot_value2, 1
  store i64 %slot_offset3, ptr %13, align 4
  %16 = call ptr @vector_new(i64 %storage_value1)
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %13, ptr %17, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %17, ptr %0, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %storage_value1
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %18 = load ptr, ptr %0, align 8
  %vector_data = getelementptr i64, ptr %16, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %19 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %19)
  %storage_value4 = load i64, ptr %19, align 4
  %slot_value5 = load i64, ptr %18, align 4
  %slot_offset6 = add i64 %slot_value5, 1
  store i64 %slot_offset6, ptr %18, align 4
  store i64 %storage_value4, ptr %index_access, align 4
  store ptr %18, ptr %0, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %slot_value7 = load i64, ptr %13, align 4
  %slot_offset8 = add i64 %slot_value7, 1
  store i64 %slot_offset8, ptr %13, align 4
  ret ptr %16
}

define void @vote_test() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca87 = alloca i64, align 8
  %1 = alloca ptr, align 8
  %index_alloca65 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca54 = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %3 = call ptr @vector_new(i64 3)
  %vector_data = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %4 = call ptr @vector_new(i64 0)
  store ptr %4, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %vector_length = load i64, ptr %3, align 4
  %5 = sub i64 %vector_length, 1
  %6 = sub i64 %5, 0
  call void @builtin_range_check(i64 %6)
  %vector_data1 = getelementptr i64, ptr %3, i64 1
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %7 = call ptr @vector_new(i64 10)
  %vector_data3 = getelementptr i64, ptr %7, i64 1
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 0
  store i64 80, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data3, i64 1
  store i64 114, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data3, i64 2
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data3, i64 3
  store i64 112, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data3, i64 4
  store i64 111, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data3, i64 5
  store i64 115, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data3, i64 6
  store i64 97, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data3, i64 7
  store i64 108, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data3, i64 8
  store i64 95, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data3, i64 9
  store i64 49, ptr %index_access13, align 4
  store ptr %7, ptr %index_access2, align 8
  %vector_length14 = load i64, ptr %3, align 4
  %8 = sub i64 %vector_length14, 1
  %9 = sub i64 %8, 1
  call void @builtin_range_check(i64 %9)
  %vector_data15 = getelementptr i64, ptr %3, i64 1
  %index_access16 = getelementptr ptr, ptr %vector_data15, i64 1
  %10 = call ptr @vector_new(i64 10)
  %vector_data17 = getelementptr i64, ptr %10, i64 1
  %index_access18 = getelementptr i64, ptr %vector_data17, i64 0
  store i64 80, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %vector_data17, i64 1
  store i64 114, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %vector_data17, i64 2
  store i64 111, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %vector_data17, i64 3
  store i64 112, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %vector_data17, i64 4
  store i64 111, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data17, i64 5
  store i64 115, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %vector_data17, i64 6
  store i64 97, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %vector_data17, i64 7
  store i64 108, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %vector_data17, i64 8
  store i64 95, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %vector_data17, i64 9
  store i64 50, ptr %index_access27, align 4
  store ptr %10, ptr %index_access16, align 8
  %vector_length28 = load i64, ptr %3, align 4
  %11 = sub i64 %vector_length28, 1
  %12 = sub i64 %11, 2
  call void @builtin_range_check(i64 %12)
  %vector_data29 = getelementptr i64, ptr %3, i64 1
  %index_access30 = getelementptr ptr, ptr %vector_data29, i64 2
  %13 = call ptr @vector_new(i64 10)
  %vector_data31 = getelementptr i64, ptr %13, i64 1
  %index_access32 = getelementptr i64, ptr %vector_data31, i64 0
  store i64 80, ptr %index_access32, align 4
  %index_access33 = getelementptr i64, ptr %vector_data31, i64 1
  store i64 114, ptr %index_access33, align 4
  %index_access34 = getelementptr i64, ptr %vector_data31, i64 2
  store i64 111, ptr %index_access34, align 4
  %index_access35 = getelementptr i64, ptr %vector_data31, i64 3
  store i64 112, ptr %index_access35, align 4
  %index_access36 = getelementptr i64, ptr %vector_data31, i64 4
  store i64 111, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %vector_data31, i64 5
  store i64 115, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %vector_data31, i64 6
  store i64 97, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %vector_data31, i64 7
  store i64 108, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %vector_data31, i64 8
  store i64 95, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %vector_data31, i64 9
  store i64 51, ptr %index_access41, align 4
  store ptr %13, ptr %index_access30, align 8
  store i64 0, ptr %i, align 4
  br label %cond42

cond42:                                           ; preds = %next, %done
  %14 = load i64, ptr %i, align 4
  %vector_length44 = load i64, ptr %3, align 4
  %15 = icmp ult i64 %14, %vector_length44
  br i1 %15, label %body43, label %endfor

body43:                                           ; preds = %cond42
  %16 = call ptr @heap_malloc(i64 4)
  %17 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %17, align 4
  %18 = getelementptr i64, ptr %17, i64 1
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %17, i64 2
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %17, i64 3
  store i64 0, ptr %20, align 4
  call void @get_storage(ptr %17, ptr %16)
  %storage_value = load i64, ptr %16, align 4
  %21 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %21, align 4
  %22 = getelementptr i64, ptr %21, i64 1
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %21, i64 2
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %21, i64 3
  store i64 0, ptr %24, align 4
  %25 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %21, ptr %25, i64 4)
  %hash_value_low = load i64, ptr %25, align 4
  %26 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %26
  store i64 %storage_array_offset, ptr %25, align 4
  %27 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 0
  %28 = load i64, ptr %i, align 4
  %vector_length45 = load i64, ptr %3, align 4
  %29 = sub i64 %vector_length45, 1
  %30 = sub i64 %29, %28
  call void @builtin_range_check(i64 %30)
  %vector_data46 = getelementptr i64, ptr %3, i64 1
  %index_access47 = getelementptr ptr, ptr %vector_data46, i64 %28
  %31 = load ptr, ptr %index_access47, align 8
  store ptr %31, ptr %struct_member, align 8
  %struct_member48 = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 1
  %32 = load i64, ptr %i, align 4
  store i64 %32, ptr %struct_member48, align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 0
  %vector_length49 = load i64, ptr %name, align 4
  %33 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %25, ptr %33)
  %storage_value50 = load i64, ptr %33, align 4
  %slot_value = load i64, ptr %25, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %25, align 4
  %34 = call ptr @heap_malloc(i64 4)
  store i64 %vector_length49, ptr %34, align 4
  %35 = getelementptr i64, ptr %34, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %34, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %34, i64 3
  store i64 0, ptr %37, align 4
  call void @set_storage(ptr %25, ptr %34)
  %38 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %25, ptr %38, i64 4)
  store i64 0, ptr %index_alloca54, align 4
  store ptr %38, ptr %2, align 8
  br label %cond51

next:                                             ; preds = %done64
  %39 = load i64, ptr %i, align 4
  %40 = add i64 %39, 1
  store i64 %40, ptr %i, align 4
  br label %cond42

endfor:                                           ; preds = %cond42
  %41 = call ptr @heap_malloc(i64 4)
  %42 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %42, align 4
  %43 = getelementptr i64, ptr %42, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %42, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %42, i64 3
  store i64 0, ptr %45, align 4
  call void @get_storage(ptr %42, ptr %41)
  %storage_value76 = load i64, ptr %41, align 4
  %46 = sub i64 %storage_value76, 1
  %47 = sub i64 %46, 0
  call void @builtin_range_check(i64 %47)
  %48 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %48, align 4
  %49 = getelementptr i64, ptr %48, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %48, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %48, i64 3
  store i64 0, ptr %51, align 4
  %52 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %48, ptr %52, i64 4)
  %hash_value_low77 = load i64, ptr %52, align 4
  %storage_array_offset78 = add i64 %hash_value_low77, 0
  store i64 %storage_array_offset78, ptr %52, align 4
  %slot_value79 = load i64, ptr %52, align 4
  %slot_offset80 = add i64 %slot_value79, 0
  store i64 %slot_offset80, ptr %52, align 4
  %53 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %52, ptr %53)
  %storage_value81 = load i64, ptr %53, align 4
  %slot_value82 = load i64, ptr %52, align 4
  %slot_offset83 = add i64 %slot_value82, 1
  store i64 %slot_offset83, ptr %52, align 4
  %54 = call ptr @vector_new(i64 %storage_value81)
  %55 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %52, ptr %55, i64 4)
  store i64 0, ptr %index_alloca87, align 4
  store ptr %55, ptr %0, align 8
  br label %cond84

cond51:                                           ; preds = %body52, %body43
  %index_value55 = load i64, ptr %index_alloca54, align 4
  %loop_cond56 = icmp ult i64 %index_value55, %vector_length49
  br i1 %loop_cond56, label %body52, label %done53

body52:                                           ; preds = %cond51
  %56 = load ptr, ptr %2, align 8
  %vector_data57 = getelementptr i64, ptr %name, i64 1
  %index_access58 = getelementptr i64, ptr %vector_data57, i64 %index_value55
  %57 = load i64, ptr %index_access58, align 4
  %58 = call ptr @heap_malloc(i64 4)
  store i64 %57, ptr %58, align 4
  %59 = getelementptr i64, ptr %58, i64 1
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %58, i64 2
  store i64 0, ptr %60, align 4
  %61 = getelementptr i64, ptr %58, i64 3
  store i64 0, ptr %61, align 4
  call void @set_storage(ptr %56, ptr %58)
  %slot_value59 = load i64, ptr %56, align 4
  %slot_offset60 = add i64 %slot_value59, 1
  store i64 %slot_offset60, ptr %56, align 4
  store ptr %56, ptr %2, align 8
  %next_index61 = add i64 %index_value55, 1
  store i64 %next_index61, ptr %index_alloca54, align 4
  br label %cond51

done53:                                           ; preds = %cond51
  store i64 %vector_length49, ptr %index_alloca65, align 4
  store ptr %38, ptr %1, align 8
  br label %cond62

cond62:                                           ; preds = %body63, %done53
  %index_value66 = load i64, ptr %index_alloca65, align 4
  %loop_cond67 = icmp ult i64 %index_value66, %storage_value50
  br i1 %loop_cond67, label %body63, label %done64

body63:                                           ; preds = %cond62
  %62 = load ptr, ptr %1, align 8
  %63 = call ptr @heap_malloc(i64 4)
  %storage_key_ptr = getelementptr i64, ptr %63, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr68 = getelementptr i64, ptr %63, i64 1
  store i64 0, ptr %storage_key_ptr68, align 4
  %storage_key_ptr69 = getelementptr i64, ptr %63, i64 2
  store i64 0, ptr %storage_key_ptr69, align 4
  %storage_key_ptr70 = getelementptr i64, ptr %63, i64 3
  store i64 0, ptr %storage_key_ptr70, align 4
  call void @set_storage(ptr %62, ptr %63)
  %slot_value71 = load i64, ptr %62, align 4
  %slot_offset72 = add i64 %slot_value71, 1
  store i64 %slot_offset72, ptr %62, align 4
  store ptr %62, ptr %1, align 8
  %next_index73 = add i64 %index_value66, 1
  store i64 %next_index73, ptr %index_alloca65, align 4
  br label %cond62

done64:                                           ; preds = %cond62
  %slot_value74 = load i64, ptr %25, align 4
  %slot_offset75 = add i64 %slot_value74, 1
  store i64 %slot_offset75, ptr %25, align 4
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %27, i32 0, i32 1
  %64 = load i64, ptr %voteCount, align 4
  %65 = call ptr @heap_malloc(i64 4)
  store i64 %64, ptr %65, align 4
  %66 = getelementptr i64, ptr %65, i64 1
  store i64 0, ptr %66, align 4
  %67 = getelementptr i64, ptr %65, i64 2
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %65, i64 3
  store i64 0, ptr %68, align 4
  call void @set_storage(ptr %25, ptr %65)
  %new_length = add i64 %storage_value, 1
  %69 = call ptr @heap_malloc(i64 4)
  store i64 2, ptr %69, align 4
  %70 = getelementptr i64, ptr %69, i64 1
  store i64 0, ptr %70, align 4
  %71 = getelementptr i64, ptr %69, i64 2
  store i64 0, ptr %71, align 4
  %72 = getelementptr i64, ptr %69, i64 3
  store i64 0, ptr %72, align 4
  %73 = call ptr @heap_malloc(i64 4)
  store i64 %new_length, ptr %73, align 4
  %74 = getelementptr i64, ptr %73, i64 1
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %73, i64 2
  store i64 0, ptr %75, align 4
  %76 = getelementptr i64, ptr %73, i64 3
  store i64 0, ptr %76, align 4
  call void @set_storage(ptr %69, ptr %73)
  br label %next

cond84:                                           ; preds = %body85, %endfor
  %index_value88 = load i64, ptr %index_alloca87, align 4
  %loop_cond89 = icmp ult i64 %index_value88, %storage_value81
  br i1 %loop_cond89, label %body85, label %done86

body85:                                           ; preds = %cond84
  %77 = load ptr, ptr %0, align 8
  %vector_data90 = getelementptr i64, ptr %54, i64 1
  %index_access91 = getelementptr i64, ptr %vector_data90, i64 %index_value88
  %78 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %77, ptr %78)
  %storage_value92 = load i64, ptr %78, align 4
  %slot_value93 = load i64, ptr %77, align 4
  %slot_offset94 = add i64 %slot_value93, 1
  store i64 %slot_offset94, ptr %77, align 4
  store i64 %storage_value92, ptr %index_access91, align 4
  store ptr %77, ptr %0, align 8
  %next_index95 = add i64 %index_value88, 1
  store i64 %next_index95, ptr %index_alloca87, align 4
  br label %cond84

done86:                                           ; preds = %cond84
  %slot_value96 = load i64, ptr %52, align 4
  %slot_offset97 = add i64 %slot_value96, 1
  store i64 %slot_offset97, ptr %52, align 4
  %vector_data98 = getelementptr i64, ptr %54, i64 1
  %vector_length99 = load i64, ptr %54, align 4
  %79 = call ptr @vector_new(i64 10)
  %vector_data100 = getelementptr i64, ptr %79, i64 1
  %index_access101 = getelementptr i64, ptr %vector_data100, i64 0
  store i64 80, ptr %index_access101, align 4
  %index_access102 = getelementptr i64, ptr %vector_data100, i64 1
  store i64 114, ptr %index_access102, align 4
  %index_access103 = getelementptr i64, ptr %vector_data100, i64 2
  store i64 111, ptr %index_access103, align 4
  %index_access104 = getelementptr i64, ptr %vector_data100, i64 3
  store i64 112, ptr %index_access104, align 4
  %index_access105 = getelementptr i64, ptr %vector_data100, i64 4
  store i64 111, ptr %index_access105, align 4
  %index_access106 = getelementptr i64, ptr %vector_data100, i64 5
  store i64 115, ptr %index_access106, align 4
  %index_access107 = getelementptr i64, ptr %vector_data100, i64 6
  store i64 97, ptr %index_access107, align 4
  %index_access108 = getelementptr i64, ptr %vector_data100, i64 7
  store i64 108, ptr %index_access108, align 4
  %index_access109 = getelementptr i64, ptr %vector_data100, i64 8
  store i64 95, ptr %index_access109, align 4
  %index_access110 = getelementptr i64, ptr %vector_data100, i64 9
  store i64 49, ptr %index_access110, align 4
  %vector_data111 = getelementptr i64, ptr %79, i64 1
  %vector_length112 = load i64, ptr %79, align 4
  %80 = icmp eq i64 %vector_length99, %vector_length112
  %81 = zext i1 %80 to i64
  call void @builtin_assert(i64 %81)
  %82 = call i64 @memcmp_eq(ptr %vector_data98, ptr %vector_data111, i64 %vector_length99)
  call void @builtin_assert(i64 %82)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %size_var = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3912413929, label %func_0_dispatch
    i64 597976998, label %func_1_dispatch
    i64 1621094845, label %func_2_dispatch
    i64 738043157, label %func_3_dispatch
    i64 665853700, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %size_var, align 4
  %vector_length = load i64, ptr %3, align 4
  %4 = load i64, ptr %size_var, align 4
  %5 = add i64 %4, %vector_length
  store i64 %5, ptr %size_var, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %vector_length1 = load i64, ptr %3, align 4
  %6 = icmp ult i64 %index, %vector_length1
  br i1 %6, label %body, label %end_for

next:                                             ; preds = %body
  %index4 = load i64, ptr %index_ptr, align 4
  %7 = add i64 %index4, 1
  store i64 %7, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %vector_length2 = load i64, ptr %3, align 4
  %8 = sub i64 %vector_length2, 1
  %9 = sub i64 %8, %index
  call void @builtin_range_check(i64 %9)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %vector_length3 = load i64, ptr %index_access, align 4
  %10 = add i64 %vector_length3, 1
  %11 = load i64, ptr %size_var, align 4
  %12 = add i64 %11, %10
  store i64 %12, ptr %size_var, align 4
  br label %next

end_for:                                          ; preds = %cond
  %13 = load i64, ptr %size_var, align 4
  call void @contract_init(ptr %3)
  %14 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %14, align 4
  call void @set_tape_data(ptr %14, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %15 = getelementptr ptr, ptr %input, i64 0
  %16 = load i64, ptr %15, align 4
  call void @vote_proposal(i64 %16)
  %17 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %17, align 4
  call void @set_tape_data(ptr %17, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %18 = call i64 @winningProposal()
  %19 = call ptr @heap_malloc(i64 2)
  %encode_value_ptr = getelementptr i64, ptr %19, i64 0
  store i64 %18, ptr %encode_value_ptr, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %19, i64 1
  store i64 1, ptr %encode_value_ptr5, align 4
  call void @set_tape_data(ptr %19, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %20 = call ptr @getWinnerName()
  %vector_length6 = load i64, ptr %20, align 4
  %21 = add i64 %vector_length6, 1
  %heap_size = add i64 %21, 1
  %22 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length7 = load i64, ptr %20, align 4
  %23 = add i64 %vector_length7, 1
  call void @memcpy(ptr %20, ptr %22, i64 %23)
  %24 = add i64 %23, 0
  %encode_value_ptr8 = getelementptr i64, ptr %22, i64 %24
  store i64 %21, ptr %encode_value_ptr8, align 4
  call void @set_tape_data(ptr %22, i64 %heap_size)
  ret void

func_4_dispatch:                                  ; preds = %entry
  call void @vote_test()
  %25 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %25, align 4
  call void @set_tape_data(ptr %25, i64 1)
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
