; ModuleID = 'Voting'
source_filename = "vote_simple"

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
  %length = load i64, ptr %1, align 4
  %3 = icmp ult i64 %2, %length
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %5 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %5, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
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
  store i64 1, ptr %heap_to_ptr4, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %12, align 4
  %13 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %13, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr6, align 4
  %14 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %14
  store i64 %storage_array_offset, ptr %heap_to_ptr6, align 4
  %15 = call i64 @vector_new(i64 2)
  %heap_start7 = sub i64 %15, 2
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 0
  %16 = load i64, ptr %i, align 4
  %length9 = load i64, ptr %1, align 4
  %17 = sub i64 %length9, 1
  %18 = sub i64 %17, %16
  call void @builtin_range_check(i64 %18)
  %19 = ptrtoint ptr %1 to i64
  %20 = add i64 %19, 1
  %vector_data = inttoptr i64 %20 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %16
  %21 = load i64, ptr %index_access, align 4
  store i64 %21, ptr %struct_member, align 4
  %struct_member10 = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 1
  store i64 0, ptr %struct_member10, align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 0
  %22 = load i64, ptr %name, align 4
  %23 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %23, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %22, ptr %heap_to_ptr12, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %26, align 4
  call void @set_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr12)
  %slot_value = load i64, ptr %heap_to_ptr6, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr6, align 4
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr8, i32 0, i32 1
  %27 = load i64, ptr %voteCount, align 4
  %28 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %28, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %27, ptr %heap_to_ptr14, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %31, align 4
  call void @set_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr14)
  %new_length = add i64 %storage_value, 1
  %32 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %32, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 1, ptr %heap_to_ptr16, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %35, align 4
  %36 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %36, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 %new_length, ptr %heap_to_ptr18, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %39, align 4
  call void @set_storage(ptr %heap_to_ptr16, ptr %heap_to_ptr18)
  %40 = load i64, ptr %i, align 4
  %41 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %41, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  %42 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %42, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 1, ptr %heap_to_ptr22, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 0, ptr %45, align 4
  call void @get_storage(ptr %heap_to_ptr22, ptr %heap_to_ptr20)
  %storage_value23 = load i64, ptr %heap_to_ptr20, align 4
  %46 = sub i64 %storage_value23, 1
  %47 = sub i64 %46, %40
  call void @builtin_range_check(i64 %47)
  %48 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %48, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  store i64 1, ptr %heap_to_ptr25, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr25, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr25, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  store i64 0, ptr %51, align 4
  %52 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %52, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr25, ptr %heap_to_ptr27, i64 4)
  %hash_value_low28 = load i64, ptr %heap_to_ptr27, align 4
  %53 = mul i64 %40, 2
  %storage_array_offset29 = add i64 %hash_value_low28, %53
  store i64 %storage_array_offset29, ptr %heap_to_ptr27, align 4
  %slot_value30 = load i64, ptr %heap_to_ptr27, align 4
  %slot_offset31 = add i64 %slot_value30, 0
  store i64 %slot_offset31, ptr %heap_to_ptr27, align 4
  %54 = call i64 @vector_new(i64 4)
  %heap_start32 = sub i64 %54, 4
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  call void @get_storage(ptr %heap_to_ptr27, ptr %heap_to_ptr33)
  %storage_value34 = load i64, ptr %heap_to_ptr33, align 4
  %slot_value35 = load i64, ptr %heap_to_ptr27, align 4
  %slot_offset36 = add i64 %slot_value35, 1
  store i64 %slot_offset36, ptr %heap_to_ptr27, align 4
  call void @prophet_printf(i64 %storage_value34, i64 3)
  br label %next

next:                                             ; preds = %body
  %55 = load i64, ptr %i, align 4
  %56 = add i64 %55, 1
  store i64 %56, ptr %i, align 4
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
  %1 = call i64 @vector_new(i64 12)
  %heap_start = sub i64 %1, 12
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 12)
  store ptr %heap_to_ptr, ptr %msgSender, align 8
  %2 = load ptr, ptr %msgSender, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %3, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start3 = sub i64 %7, 8
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %8 = inttoptr i64 %heap_start3 to ptr
  call void @memcpy(ptr %heap_to_ptr2, ptr %8, i64 4)
  %next_dest_offset = add i64 %heap_start3, 4
  %9 = inttoptr i64 %next_dest_offset to ptr
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %10, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 8)
  store ptr %heap_to_ptr6, ptr %sender, align 8
  %11 = load i64, ptr %sender, align 4
  %slot_offset = add i64 %11, 0
  %12 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %12, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %13 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %13, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %slot_offset, ptr %heap_to_ptr10, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %16, align 4
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr8)
  %storage_value = load i64, ptr %heap_to_ptr8, align 4
  %slot_offset11 = add i64 %slot_offset, 1
  %17 = icmp eq i64 %storage_value, 0
  %18 = zext i1 %17 to i64
  call void @builtin_assert(i64 %18)
  %19 = load i64, ptr %sender, align 4
  %slot_offset12 = add i64 %19, 0
  %20 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %20, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %slot_offset12, ptr %heap_to_ptr14, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %23, align 4
  %24 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %24, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 1, ptr %heap_to_ptr16, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %27, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  %28 = load i64, ptr %sender, align 4
  %slot_offset17 = add i64 %28, 1
  %29 = load i64, ptr %proposal_, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %30, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  store i64 %slot_offset17, ptr %heap_to_ptr19, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr19, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr19, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr19, i64 3
  store i64 0, ptr %33, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start20 = sub i64 %34, 4
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  store i64 %29, ptr %heap_to_ptr21, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr21, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr21, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr21, i64 3
  store i64 0, ptr %37, align 4
  call void @set_storage(ptr %heap_to_ptr19, ptr %heap_to_ptr21)
  %38 = load i64, ptr %proposal_, align 4
  %39 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %39, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  %40 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %40, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  store i64 1, ptr %heap_to_ptr25, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr25, i64 1
  store i64 0, ptr %41, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr25, i64 2
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  store i64 0, ptr %43, align 4
  call void @get_storage(ptr %heap_to_ptr25, ptr %heap_to_ptr23)
  %storage_value26 = load i64, ptr %heap_to_ptr23, align 4
  %44 = sub i64 %storage_value26, 1
  %45 = sub i64 %44, %38
  call void @builtin_range_check(i64 %45)
  %46 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %46, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  store i64 1, ptr %heap_to_ptr28, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 0, ptr %49, align 4
  %50 = call i64 @vector_new(i64 4)
  %heap_start29 = sub i64 %50, 4
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr28, ptr %heap_to_ptr30, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr30, align 4
  %51 = mul i64 %38, 2
  %storage_array_offset = add i64 %hash_value_low, %51
  store i64 %storage_array_offset, ptr %heap_to_ptr30, align 4
  %slot_value = load i64, ptr %heap_to_ptr30, align 4
  %slot_offset31 = add i64 %slot_value, 0
  store i64 %slot_offset31, ptr %heap_to_ptr30, align 4
  %52 = call i64 @vector_new(i64 4)
  %heap_start32 = sub i64 %52, 4
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  call void @get_storage(ptr %heap_to_ptr30, ptr %heap_to_ptr33)
  %storage_value34 = load i64, ptr %heap_to_ptr33, align 4
  %slot_value35 = load i64, ptr %heap_to_ptr30, align 4
  %slot_offset36 = add i64 %slot_value35, 1
  store i64 %slot_offset36, ptr %heap_to_ptr30, align 4
  call void @prophet_printf(i64 %storage_value34, i64 3)
  %53 = load i64, ptr %proposal_, align 4
  %54 = call i64 @vector_new(i64 4)
  %heap_start37 = sub i64 %54, 4
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  %55 = call i64 @vector_new(i64 4)
  %heap_start39 = sub i64 %55, 4
  %heap_to_ptr40 = inttoptr i64 %heap_start39 to ptr
  store i64 1, ptr %heap_to_ptr40, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr40, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr40, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr40, i64 3
  store i64 0, ptr %58, align 4
  call void @get_storage(ptr %heap_to_ptr40, ptr %heap_to_ptr38)
  %storage_value41 = load i64, ptr %heap_to_ptr38, align 4
  %59 = sub i64 %storage_value41, 1
  %60 = sub i64 %59, %53
  call void @builtin_range_check(i64 %60)
  %61 = call i64 @vector_new(i64 4)
  %heap_start42 = sub i64 %61, 4
  %heap_to_ptr43 = inttoptr i64 %heap_start42 to ptr
  store i64 1, ptr %heap_to_ptr43, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr43, i64 1
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr43, i64 2
  store i64 0, ptr %63, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr43, i64 3
  store i64 0, ptr %64, align 4
  %65 = call i64 @vector_new(i64 4)
  %heap_start44 = sub i64 %65, 4
  %heap_to_ptr45 = inttoptr i64 %heap_start44 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr43, ptr %heap_to_ptr45, i64 4)
  %hash_value_low46 = load i64, ptr %heap_to_ptr45, align 4
  %66 = mul i64 %53, 2
  %storage_array_offset47 = add i64 %hash_value_low46, %66
  store i64 %storage_array_offset47, ptr %heap_to_ptr45, align 4
  %slot_value48 = load i64, ptr %heap_to_ptr45, align 4
  %slot_offset49 = add i64 %slot_value48, 0
  store i64 %slot_offset49, ptr %heap_to_ptr45, align 4
  %67 = call i64 @vector_new(i64 4)
  %heap_start50 = sub i64 %67, 4
  %heap_to_ptr51 = inttoptr i64 %heap_start50 to ptr
  call void @get_storage(ptr %heap_to_ptr45, ptr %heap_to_ptr51)
  %storage_value52 = load i64, ptr %heap_to_ptr51, align 4
  %slot_value53 = load i64, ptr %heap_to_ptr45, align 4
  %slot_offset54 = add i64 %slot_value53, 1
  store i64 %slot_offset54, ptr %heap_to_ptr45, align 4
  %68 = icmp ne i64 %storage_value52, 0
  %69 = zext i1 %68 to i64
  call void @builtin_assert(i64 %69)
  %70 = load i64, ptr %proposal_, align 4
  %71 = call i64 @vector_new(i64 4)
  %heap_start55 = sub i64 %71, 4
  %heap_to_ptr56 = inttoptr i64 %heap_start55 to ptr
  %72 = call i64 @vector_new(i64 4)
  %heap_start57 = sub i64 %72, 4
  %heap_to_ptr58 = inttoptr i64 %heap_start57 to ptr
  store i64 1, ptr %heap_to_ptr58, align 4
  %73 = getelementptr i64, ptr %heap_to_ptr58, i64 1
  store i64 0, ptr %73, align 4
  %74 = getelementptr i64, ptr %heap_to_ptr58, i64 2
  store i64 0, ptr %74, align 4
  %75 = getelementptr i64, ptr %heap_to_ptr58, i64 3
  store i64 0, ptr %75, align 4
  call void @get_storage(ptr %heap_to_ptr58, ptr %heap_to_ptr56)
  %storage_value59 = load i64, ptr %heap_to_ptr56, align 4
  %76 = sub i64 %storage_value59, 1
  %77 = sub i64 %76, %70
  call void @builtin_range_check(i64 %77)
  %78 = call i64 @vector_new(i64 4)
  %heap_start60 = sub i64 %78, 4
  %heap_to_ptr61 = inttoptr i64 %heap_start60 to ptr
  store i64 1, ptr %heap_to_ptr61, align 4
  %79 = getelementptr i64, ptr %heap_to_ptr61, i64 1
  store i64 0, ptr %79, align 4
  %80 = getelementptr i64, ptr %heap_to_ptr61, i64 2
  store i64 0, ptr %80, align 4
  %81 = getelementptr i64, ptr %heap_to_ptr61, i64 3
  store i64 0, ptr %81, align 4
  %82 = call i64 @vector_new(i64 4)
  %heap_start62 = sub i64 %82, 4
  %heap_to_ptr63 = inttoptr i64 %heap_start62 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr61, ptr %heap_to_ptr63, i64 4)
  %hash_value_low64 = load i64, ptr %heap_to_ptr63, align 4
  %83 = mul i64 %70, 2
  %storage_array_offset65 = add i64 %hash_value_low64, %83
  store i64 %storage_array_offset65, ptr %heap_to_ptr63, align 4
  %slot_value66 = load i64, ptr %heap_to_ptr63, align 4
  %slot_offset67 = add i64 %slot_value66, 1
  store i64 %slot_offset67, ptr %heap_to_ptr63, align 4
  %84 = load i64, ptr %proposal_, align 4
  %85 = call i64 @vector_new(i64 4)
  %heap_start68 = sub i64 %85, 4
  %heap_to_ptr69 = inttoptr i64 %heap_start68 to ptr
  %86 = call i64 @vector_new(i64 4)
  %heap_start70 = sub i64 %86, 4
  %heap_to_ptr71 = inttoptr i64 %heap_start70 to ptr
  store i64 1, ptr %heap_to_ptr71, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr71, i64 1
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr71, i64 2
  store i64 0, ptr %88, align 4
  %89 = getelementptr i64, ptr %heap_to_ptr71, i64 3
  store i64 0, ptr %89, align 4
  call void @get_storage(ptr %heap_to_ptr71, ptr %heap_to_ptr69)
  %storage_value72 = load i64, ptr %heap_to_ptr69, align 4
  %90 = sub i64 %storage_value72, 1
  %91 = sub i64 %90, %84
  call void @builtin_range_check(i64 %91)
  %92 = call i64 @vector_new(i64 4)
  %heap_start73 = sub i64 %92, 4
  %heap_to_ptr74 = inttoptr i64 %heap_start73 to ptr
  store i64 1, ptr %heap_to_ptr74, align 4
  %93 = getelementptr i64, ptr %heap_to_ptr74, i64 1
  store i64 0, ptr %93, align 4
  %94 = getelementptr i64, ptr %heap_to_ptr74, i64 2
  store i64 0, ptr %94, align 4
  %95 = getelementptr i64, ptr %heap_to_ptr74, i64 3
  store i64 0, ptr %95, align 4
  %96 = call i64 @vector_new(i64 4)
  %heap_start75 = sub i64 %96, 4
  %heap_to_ptr76 = inttoptr i64 %heap_start75 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr74, ptr %heap_to_ptr76, i64 4)
  %hash_value_low77 = load i64, ptr %heap_to_ptr76, align 4
  %97 = mul i64 %84, 2
  %storage_array_offset78 = add i64 %hash_value_low77, %97
  store i64 %storage_array_offset78, ptr %heap_to_ptr76, align 4
  %slot_value79 = load i64, ptr %heap_to_ptr76, align 4
  %slot_offset80 = add i64 %slot_value79, 1
  store i64 %slot_offset80, ptr %heap_to_ptr76, align 4
  %98 = call i64 @vector_new(i64 4)
  %heap_start81 = sub i64 %98, 4
  %heap_to_ptr82 = inttoptr i64 %heap_start81 to ptr
  call void @get_storage(ptr %heap_to_ptr76, ptr %heap_to_ptr82)
  %storage_value83 = load i64, ptr %heap_to_ptr82, align 4
  %slot_value84 = load i64, ptr %heap_to_ptr76, align 4
  %slot_offset85 = add i64 %slot_value84, 1
  store i64 %slot_offset85, ptr %heap_to_ptr76, align 4
  %99 = add i64 %storage_value83, 1
  call void @builtin_range_check(i64 %99)
  %100 = call i64 @vector_new(i64 4)
  %heap_start86 = sub i64 %100, 4
  %heap_to_ptr87 = inttoptr i64 %heap_start86 to ptr
  store i64 %99, ptr %heap_to_ptr87, align 4
  %101 = getelementptr i64, ptr %heap_to_ptr87, i64 1
  store i64 0, ptr %101, align 4
  %102 = getelementptr i64, ptr %heap_to_ptr87, i64 2
  store i64 0, ptr %102, align 4
  %103 = getelementptr i64, ptr %heap_to_ptr87, i64 3
  store i64 0, ptr %103, align 4
  call void @set_storage(ptr %heap_to_ptr63, ptr %heap_to_ptr87)
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
  %1 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %1, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %2 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %2, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %5, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %6 = icmp ult i64 %0, %storage_value
  br i1 %6, label %body, label %endfor

body:                                             ; preds = %cond
  %7 = load i64, ptr %p, align 4
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %9 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %9, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 1, ptr %heap_to_ptr6, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %12, align 4
  call void @get_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr4)
  %storage_value7 = load i64, ptr %heap_to_ptr4, align 4
  %13 = sub i64 %storage_value7, 1
  %14 = sub i64 %13, %7
  call void @builtin_range_check(i64 %14)
  %15 = call i64 @vector_new(i64 4)
  %heap_start8 = sub i64 %15, 4
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  store i64 1, ptr %heap_to_ptr9, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr9, i64 1
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr9, i64 2
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr9, i64 3
  store i64 0, ptr %18, align 4
  %19 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %19, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr9, ptr %heap_to_ptr11, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr11, align 4
  %20 = mul i64 %7, 2
  %storage_array_offset = add i64 %hash_value_low, %20
  store i64 %storage_array_offset, ptr %heap_to_ptr11, align 4
  %slot_value = load i64, ptr %heap_to_ptr11, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr11, align 4
  %21 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %21, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @get_storage(ptr %heap_to_ptr11, ptr %heap_to_ptr13)
  %storage_value14 = load i64, ptr %heap_to_ptr13, align 4
  %slot_value15 = load i64, ptr %heap_to_ptr11, align 4
  %slot_offset16 = add i64 %slot_value15, 1
  store i64 %slot_offset16, ptr %heap_to_ptr11, align 4
  %22 = load i64, ptr %winningVoteCount, align 4
  %23 = icmp ugt i64 %storage_value14, %22
  br i1 %23, label %then, label %enif

next:                                             ; preds = %enif
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
  %29 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %29, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %30 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %30, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 1, ptr %heap_to_ptr20, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %33, align 4
  call void @get_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr18)
  %storage_value21 = load i64, ptr %heap_to_ptr18, align 4
  %34 = sub i64 %storage_value21, 1
  %35 = sub i64 %34, %28
  call void @builtin_range_check(i64 %35)
  %36 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %36, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 1, ptr %heap_to_ptr23, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr23, i64 1
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr23, i64 2
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr23, i64 3
  store i64 0, ptr %39, align 4
  %40 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %40, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr23, ptr %heap_to_ptr25, i64 4)
  %hash_value_low26 = load i64, ptr %heap_to_ptr25, align 4
  %41 = mul i64 %28, 2
  %storage_array_offset27 = add i64 %hash_value_low26, %41
  store i64 %storage_array_offset27, ptr %heap_to_ptr25, align 4
  %slot_value28 = load i64, ptr %heap_to_ptr25, align 4
  %slot_offset29 = add i64 %slot_value28, 1
  store i64 %slot_offset29, ptr %heap_to_ptr25, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %42, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  call void @get_storage(ptr %heap_to_ptr25, ptr %heap_to_ptr31)
  %storage_value32 = load i64, ptr %heap_to_ptr31, align 4
  %slot_value33 = load i64, ptr %heap_to_ptr25, align 4
  %slot_offset34 = add i64 %slot_value33, 1
  store i64 %slot_offset34, ptr %heap_to_ptr25, align 4
  store i64 %storage_value32, ptr %winningVoteCount, align 4
  %43 = load i64, ptr %p, align 4
  store i64 %43, ptr %winningProposal_, align 4
  br label %enif

enif:                                             ; preds = %then, %body
  br label %next
}

define i64 @getWinnerName() {
entry:
  %winnerName = alloca i64, align 8
  %winnerP = alloca i64, align 8
  %0 = call i64 @winningProposal()
  store i64 %0, ptr %winnerP, align 4
  %1 = load i64, ptr %winnerP, align 4
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %3 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %3, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %6, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %7 = sub i64 %storage_value, 1
  %8 = sub i64 %7, %1
  call void @builtin_range_check(i64 %8)
  %9 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %9, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 1, ptr %heap_to_ptr4, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %12, align 4
  %13 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %13, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr6, align 4
  %14 = mul i64 %1, 2
  %storage_array_offset = add i64 %hash_value_low, %14
  store i64 %storage_array_offset, ptr %heap_to_ptr6, align 4
  %slot_value = load i64, ptr %heap_to_ptr6, align 4
  %slot_offset = add i64 %slot_value, 0
  store i64 %slot_offset, ptr %heap_to_ptr6, align 4
  %15 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %15, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @get_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr8)
  %storage_value9 = load i64, ptr %heap_to_ptr8, align 4
  %slot_value10 = load i64, ptr %heap_to_ptr6, align 4
  %slot_offset11 = add i64 %slot_value10, 1
  store i64 %slot_offset11, ptr %heap_to_ptr6, align 4
  store i64 %storage_value9, ptr %winnerName, align 4
  %16 = load i64, ptr %winnerName, align 4
  call void @prophet_printf(i64 %16, i64 3)
  %17 = load i64, ptr %winnerName, align 4
  ret i64 %17
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2817135588, label %func_0_dispatch
    i64 2791810083, label %func_1_dispatch
    i64 3186728800, label %func_2_dispatch
    i64 363199787, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %length = load i64, ptr %3, align 4
  %4 = mul i64 %length, 1
  %5 = add i64 %4, 1
  call void @contract_init(ptr %3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start1 = ptrtoint ptr %input to i64
  %6 = inttoptr i64 %input_start1 to ptr
  %decode_value = load i64, ptr %6, align 4
  call void @vote_proposal(i64 %decode_value)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %7 = call i64 @winningProposal()
  %8 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %8, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %7, ptr %encode_value_ptr, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr2, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %9 = call i64 @getWinnerName()
  %10 = call i64 @vector_new(i64 2)
  %heap_start3 = sub i64 %10, 2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr4, i64 0
  store i64 %9, ptr %encode_value_ptr5, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 1, ptr %encode_value_ptr6, align 4
  call void @set_tape_data(i64 %heap_start3, i64 2)
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
