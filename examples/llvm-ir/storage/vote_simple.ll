; ModuleID = 'Voting'
source_filename = "vote_simple"

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
  %compare = icmp uge i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
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
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %compare_high = icmp ugt i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp ugt i64 %4, %6
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
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
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %compare_high = icmp uge i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %4, %6
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
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
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = phi i64 [ 0, %entry ], [ %inc, %loop ]
  %3 = phi i64 [ 1, %entry ], [ %multmp, %loop ]
  %inc = add i64 %2, 1
  %multmp = mul i64 %3, %0
  %loopcond = icmp ule i64 %inc, %1
  br i1 %loopcond, label %loop, label %exit

exit:                                             ; preds = %loop
  call void @builtin_range_check(i64 %3)
  ret i64 %3
}

define void @contract_init(ptr %0) {
entry:
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %1 = load ptr, ptr %proposalNames_, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %2 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %1, align 4
  %3 = icmp ult i64 %2, %vector_length
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = call ptr @heap_malloc(i64 4)
  %5 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %5, align 4
  %6 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 3
  store i64 0, ptr %8, align 4
  call void @get_storage(ptr %5, ptr %4)
  %storage_value = load i64, ptr %4, align 4
  %9 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %9, align 4
  %10 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %9, i64 3
  store i64 0, ptr %12, align 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %9, ptr %13, i64 4)
  %hash_value_low = load i64, ptr %13, align 4
  %14 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %14
  store i64 %storage_array_offset, ptr %13, align 4
  %15 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 0
  %16 = load i64, ptr %i, align 4
  %vector_length1 = load i64, ptr %1, align 4
  %17 = sub i64 %vector_length1, 1
  %18 = sub i64 %17, %16
  call void @builtin_range_check(i64 %18)
  %vector_data = getelementptr i64, ptr %1, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 %16
  %19 = load i64, ptr %index_access, align 4
  store i64 %19, ptr %struct_member, align 4
  %struct_member2 = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 1
  store i64 0, ptr %struct_member2, align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 0
  %20 = load i64, ptr %name, align 4
  %21 = call ptr @heap_malloc(i64 4)
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %21, i64 1
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %21, i64 2
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %21, i64 3
  store i64 0, ptr %24, align 4
  call void @set_storage(ptr %13, ptr %21)
  %slot_value = load i64, ptr %13, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %13, align 4
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %15, i32 0, i32 1
  %25 = load i64, ptr %voteCount, align 4
  %26 = call ptr @heap_malloc(i64 4)
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %26, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %26, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %26, i64 3
  store i64 0, ptr %29, align 4
  call void @set_storage(ptr %13, ptr %26)
  %new_length = add i64 %storage_value, 1
  %30 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %30, align 4
  %31 = getelementptr i64, ptr %30, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %30, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %30, i64 3
  store i64 0, ptr %33, align 4
  %34 = call ptr @heap_malloc(i64 4)
  store i64 %new_length, ptr %34, align 4
  %35 = getelementptr i64, ptr %34, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %34, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %34, i64 3
  store i64 0, ptr %37, align 4
  call void @set_storage(ptr %30, ptr %34)
  %38 = load i64, ptr %i, align 4
  %39 = call ptr @heap_malloc(i64 4)
  %40 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %40, align 4
  %41 = getelementptr i64, ptr %40, i64 1
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %40, i64 2
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %40, i64 3
  store i64 0, ptr %43, align 4
  call void @get_storage(ptr %40, ptr %39)
  %storage_value3 = load i64, ptr %39, align 4
  %44 = sub i64 %storage_value3, 1
  %45 = sub i64 %44, %38
  call void @builtin_range_check(i64 %45)
  %46 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %46, align 4
  %47 = getelementptr i64, ptr %46, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %46, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %46, i64 3
  store i64 0, ptr %49, align 4
  %50 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %46, ptr %50, i64 4)
  %hash_value_low4 = load i64, ptr %50, align 4
  %51 = mul i64 %38, 2
  %storage_array_offset5 = add i64 %hash_value_low4, %51
  store i64 %storage_array_offset5, ptr %50, align 4
  %slot_value6 = load i64, ptr %50, align 4
  %slot_offset7 = add i64 %slot_value6, 0
  store i64 %slot_offset7, ptr %50, align 4
  %52 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %50, ptr %52)
  %storage_value8 = load i64, ptr %52, align 4
  %slot_value9 = load i64, ptr %50, align 4
  %slot_offset10 = add i64 %slot_value9, 1
  store i64 %slot_offset10, ptr %50, align 4
  call void @prophet_printf(i64 %storage_value8, i64 3)
  br label %next

next:                                             ; preds = %body
  %53 = load i64, ptr %i, align 4
  %54 = add i64 %53, 1
  store i64 %54, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
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
  store i64 0, ptr %3, align 4
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
  %13 = call ptr @heap_malloc(i64 4)
  store i64 %slot_offset, ptr %13, align 4
  %14 = getelementptr i64, ptr %13, i64 1
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %13, i64 2
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %13, i64 3
  store i64 0, ptr %16, align 4
  call void @get_storage(ptr %13, ptr %12)
  %storage_value = load i64, ptr %12, align 4
  %slot_offset1 = add i64 %slot_offset, 1
  %17 = icmp eq i64 %storage_value, 0
  %18 = zext i1 %17 to i64
  call void @builtin_assert(i64 %18)
  %19 = load i64, ptr %sender, align 4
  %slot_offset2 = add i64 %19, 0
  %20 = call ptr @heap_malloc(i64 4)
  store i64 %slot_offset2, ptr %20, align 4
  %21 = getelementptr i64, ptr %20, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %20, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %20, i64 3
  store i64 0, ptr %23, align 4
  %24 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %24, align 4
  %25 = getelementptr i64, ptr %24, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %24, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %24, i64 3
  store i64 0, ptr %27, align 4
  call void @set_storage(ptr %20, ptr %24)
  %28 = load i64, ptr %sender, align 4
  %slot_offset3 = add i64 %28, 1
  %29 = load i64, ptr %proposal_, align 4
  %30 = call ptr @heap_malloc(i64 4)
  store i64 %slot_offset3, ptr %30, align 4
  %31 = getelementptr i64, ptr %30, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %30, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %30, i64 3
  store i64 0, ptr %33, align 4
  %34 = call ptr @heap_malloc(i64 4)
  store i64 %29, ptr %34, align 4
  %35 = getelementptr i64, ptr %34, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %34, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %34, i64 3
  store i64 0, ptr %37, align 4
  call void @set_storage(ptr %30, ptr %34)
  %38 = load i64, ptr %proposal_, align 4
  %39 = call ptr @heap_malloc(i64 4)
  %40 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %40, align 4
  %41 = getelementptr i64, ptr %40, i64 1
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %40, i64 2
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %40, i64 3
  store i64 0, ptr %43, align 4
  call void @get_storage(ptr %40, ptr %39)
  %storage_value4 = load i64, ptr %39, align 4
  %44 = sub i64 %storage_value4, 1
  %45 = sub i64 %44, %38
  call void @builtin_range_check(i64 %45)
  %46 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %46, align 4
  %47 = getelementptr i64, ptr %46, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %46, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %46, i64 3
  store i64 0, ptr %49, align 4
  %50 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %46, ptr %50, i64 4)
  %hash_value_low = load i64, ptr %50, align 4
  %51 = mul i64 %38, 2
  %storage_array_offset = add i64 %hash_value_low, %51
  store i64 %storage_array_offset, ptr %50, align 4
  %slot_value = load i64, ptr %50, align 4
  %slot_offset5 = add i64 %slot_value, 0
  store i64 %slot_offset5, ptr %50, align 4
  %52 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %50, ptr %52)
  %storage_value6 = load i64, ptr %52, align 4
  %slot_value7 = load i64, ptr %50, align 4
  %slot_offset8 = add i64 %slot_value7, 1
  store i64 %slot_offset8, ptr %50, align 4
  call void @prophet_printf(i64 %storage_value6, i64 3)
  %53 = load i64, ptr %proposal_, align 4
  %54 = call ptr @heap_malloc(i64 4)
  %55 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %55, align 4
  %56 = getelementptr i64, ptr %55, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %55, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %55, i64 3
  store i64 0, ptr %58, align 4
  call void @get_storage(ptr %55, ptr %54)
  %storage_value9 = load i64, ptr %54, align 4
  %59 = sub i64 %storage_value9, 1
  %60 = sub i64 %59, %53
  call void @builtin_range_check(i64 %60)
  %61 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %61, align 4
  %62 = getelementptr i64, ptr %61, i64 1
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %61, i64 2
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %61, i64 3
  store i64 0, ptr %64, align 4
  %65 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %61, ptr %65, i64 4)
  %hash_value_low10 = load i64, ptr %65, align 4
  %66 = mul i64 %53, 2
  %storage_array_offset11 = add i64 %hash_value_low10, %66
  store i64 %storage_array_offset11, ptr %65, align 4
  %slot_value12 = load i64, ptr %65, align 4
  %slot_offset13 = add i64 %slot_value12, 0
  store i64 %slot_offset13, ptr %65, align 4
  %67 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %65, ptr %67)
  %storage_value14 = load i64, ptr %67, align 4
  %slot_value15 = load i64, ptr %65, align 4
  %slot_offset16 = add i64 %slot_value15, 1
  store i64 %slot_offset16, ptr %65, align 4
  %68 = icmp ne i64 %storage_value14, 0
  %69 = zext i1 %68 to i64
  call void @builtin_assert(i64 %69)
  %70 = load i64, ptr %proposal_, align 4
  %71 = call ptr @heap_malloc(i64 4)
  %72 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %72, align 4
  %73 = getelementptr i64, ptr %72, i64 1
  store i64 0, ptr %73, align 4
  %74 = getelementptr i64, ptr %72, i64 2
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %72, i64 3
  store i64 0, ptr %75, align 4
  call void @get_storage(ptr %72, ptr %71)
  %storage_value17 = load i64, ptr %71, align 4
  %76 = sub i64 %storage_value17, 1
  %77 = sub i64 %76, %70
  call void @builtin_range_check(i64 %77)
  %78 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %78, align 4
  %79 = getelementptr i64, ptr %78, i64 1
  store i64 0, ptr %79, align 4
  %80 = getelementptr i64, ptr %78, i64 2
  store i64 0, ptr %80, align 4
  %81 = getelementptr i64, ptr %78, i64 3
  store i64 0, ptr %81, align 4
  %82 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %78, ptr %82, i64 4)
  %hash_value_low18 = load i64, ptr %82, align 4
  %83 = mul i64 %70, 2
  %storage_array_offset19 = add i64 %hash_value_low18, %83
  store i64 %storage_array_offset19, ptr %82, align 4
  %slot_value20 = load i64, ptr %82, align 4
  %slot_offset21 = add i64 %slot_value20, 1
  store i64 %slot_offset21, ptr %82, align 4
  %84 = load i64, ptr %proposal_, align 4
  %85 = call ptr @heap_malloc(i64 4)
  %86 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %86, align 4
  %87 = getelementptr i64, ptr %86, i64 1
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %86, i64 2
  store i64 0, ptr %88, align 4
  %89 = getelementptr i64, ptr %86, i64 3
  store i64 0, ptr %89, align 4
  call void @get_storage(ptr %86, ptr %85)
  %storage_value22 = load i64, ptr %85, align 4
  %90 = sub i64 %storage_value22, 1
  %91 = sub i64 %90, %84
  call void @builtin_range_check(i64 %91)
  %92 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %92, align 4
  %93 = getelementptr i64, ptr %92, i64 1
  store i64 0, ptr %93, align 4
  %94 = getelementptr i64, ptr %92, i64 2
  store i64 0, ptr %94, align 4
  %95 = getelementptr i64, ptr %92, i64 3
  store i64 0, ptr %95, align 4
  %96 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %92, ptr %96, i64 4)
  %hash_value_low23 = load i64, ptr %96, align 4
  %97 = mul i64 %84, 2
  %storage_array_offset24 = add i64 %hash_value_low23, %97
  store i64 %storage_array_offset24, ptr %96, align 4
  %slot_value25 = load i64, ptr %96, align 4
  %slot_offset26 = add i64 %slot_value25, 1
  store i64 %slot_offset26, ptr %96, align 4
  %98 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %96, ptr %98)
  %storage_value27 = load i64, ptr %98, align 4
  %slot_value28 = load i64, ptr %96, align 4
  %slot_offset29 = add i64 %slot_value28, 1
  store i64 %slot_offset29, ptr %96, align 4
  %99 = add i64 %storage_value27, 1
  call void @builtin_range_check(i64 %99)
  %100 = call ptr @heap_malloc(i64 4)
  store i64 %99, ptr %100, align 4
  %101 = getelementptr i64, ptr %100, i64 1
  store i64 0, ptr %101, align 4
  %102 = getelementptr i64, ptr %100, i64 2
  store i64 0, ptr %102, align 4
  %103 = getelementptr i64, ptr %100, i64 3
  store i64 0, ptr %103, align 4
  call void @set_storage(ptr %82, ptr %100)
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
  store i64 1, ptr %2, align 4
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
  store i64 1, ptr %9, align 4
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
  store i64 1, ptr %15, align 4
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
  call void @prophet_printf(i64 %26, i64 3)
  %27 = load i64, ptr %winningProposal_, align 4
  ret i64 %27

then:                                             ; preds = %body
  %28 = load i64, ptr %p, align 4
  %29 = call ptr @heap_malloc(i64 4)
  %30 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %30, align 4
  %31 = getelementptr i64, ptr %30, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %30, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %30, i64 3
  store i64 0, ptr %33, align 4
  call void @get_storage(ptr %30, ptr %29)
  %storage_value5 = load i64, ptr %29, align 4
  %34 = sub i64 %storage_value5, 1
  %35 = sub i64 %34, %28
  call void @builtin_range_check(i64 %35)
  %36 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %36, align 4
  %37 = getelementptr i64, ptr %36, i64 1
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %36, i64 2
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %36, i64 3
  store i64 0, ptr %39, align 4
  %40 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %36, ptr %40, i64 4)
  %hash_value_low6 = load i64, ptr %40, align 4
  %41 = mul i64 %28, 2
  %storage_array_offset7 = add i64 %hash_value_low6, %41
  store i64 %storage_array_offset7, ptr %40, align 4
  %slot_value8 = load i64, ptr %40, align 4
  %slot_offset9 = add i64 %slot_value8, 1
  store i64 %slot_offset9, ptr %40, align 4
  %42 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %40, ptr %42)
  %storage_value10 = load i64, ptr %42, align 4
  %slot_value11 = load i64, ptr %40, align 4
  %slot_offset12 = add i64 %slot_value11, 1
  store i64 %slot_offset12, ptr %40, align 4
  store i64 %storage_value10, ptr %winningVoteCount, align 4
  %43 = load i64, ptr %p, align 4
  store i64 %43, ptr %winningProposal_, align 4
  br label %endif

endif:                                            ; preds = %then, %body
  br label %next
}

define i64 @getWinnerName() {
entry:
  %winnerName = alloca i64, align 8
  %winnerP = alloca i64, align 8
  %0 = call i64 @winningProposal()
  store i64 %0, ptr %winnerP, align 4
  %1 = load i64, ptr %winnerP, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %3 = call ptr @heap_malloc(i64 4)
  store i64 1, ptr %3, align 4
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
  store i64 1, ptr %9, align 4
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
  store i64 %storage_value1, ptr %winnerName, align 4
  %16 = load i64, ptr %winnerName, align 4
  call void @prophet_printf(i64 %16, i64 3)
  %17 = load i64, ptr %winnerName, align 4
  ret i64 %17
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3826510503, label %func_0_dispatch
    i64 597976998, label %func_1_dispatch
    i64 1621094845, label %func_2_dispatch
    i64 738043157, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %vector_length = load i64, ptr %3, align 4
  %4 = mul i64 %vector_length, 1
  %5 = add i64 %4, 1
  call void @contract_init(ptr %3)
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = getelementptr ptr, ptr %2, i64 0
  %8 = load i64, ptr %7, align 4
  call void @vote_proposal(i64 %8)
  %9 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %9, align 4
  call void @set_tape_data(ptr %9, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %10 = call i64 @winningProposal()
  %11 = call ptr @heap_malloc(i64 2)
  store i64 %10, ptr %11, align 4
  %12 = getelementptr ptr, ptr %11, i64 1
  store i64 1, ptr %12, align 4
  call void @set_tape_data(ptr %11, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %13 = call i64 @getWinnerName()
  %14 = call ptr @heap_malloc(i64 2)
  store i64 %13, ptr %14, align 4
  %15 = getelementptr ptr, ptr %14, i64 1
  store i64 1, ptr %15, align 4
  call void @set_tape_data(ptr %14, i64 2)
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
