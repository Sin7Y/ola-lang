; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote.ola"

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
  %1 = alloca ptr, align 8
  %index_alloca34 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %i = alloca i64, align 8
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %3 = load ptr, ptr %proposalNames_, align 8
  %4 = call i64 @vector_new(i64 12)
  %heap_start = sub i64 %4, 12
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 12)
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
  call void @set_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %9 = load i64, ptr %i, align 4
  %length = load i64, ptr %3, align 4
  %10 = icmp ult i64 %9, %length
  br i1 %10, label %body, label %endfor

body:                                             ; preds = %cond
  %11 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %11, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 2, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  call void @get_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr4)
  %storage_value = load i64, ptr %heap_to_ptr4, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %16, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 2, ptr %heap_to_ptr8, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %19, align 4
  %20 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %20, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr10, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr10, align 4
  %21 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %21
  store i64 %storage_array_offset, ptr %heap_to_ptr10, align 4
  %22 = call i64 @vector_new(i64 2)
  %heap_start11 = sub i64 %22, 2
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  %struct_member = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr12, i32 0, i32 0
  %23 = load i64, ptr %i, align 4
  %length13 = load i64, ptr %3, align 4
  %24 = sub i64 %length13, 1
  %25 = sub i64 %24, %23
  call void @builtin_range_check(i64 %25)
  %26 = ptrtoint ptr %3 to i64
  %27 = add i64 %26, 1
  %vector_data = inttoptr i64 %27 to ptr
  %index_access = getelementptr ptr, ptr %vector_data, i64 %23
  %28 = load ptr, ptr %index_access, align 8
  store ptr %28, ptr %struct_member, align 8
  %struct_member14 = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr12, i32 0, i32 1
  store i64 0, ptr %struct_member14, align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr12, i32 0, i32 0
  %length15 = load i64, ptr %name, align 4
  %29 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %29, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr17)
  %storage_value18 = load i64, ptr %heap_to_ptr17, align 4
  %slot_value = load i64, ptr %heap_to_ptr10, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr10, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %30, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %length15, ptr %heap_to_ptr20, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %33, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr20)
  %34 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %34, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr10, ptr %heap_to_ptr22, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr22, ptr %2, align 8
  br label %cond23

next:                                             ; preds = %done33
  %35 = load i64, ptr %i, align 4
  %36 = add i64 %35, 1
  store i64 %36, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void

cond23:                                           ; preds = %body24, %body
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length15
  br i1 %loop_cond, label %body24, label %done

body24:                                           ; preds = %cond23
  %37 = load ptr, ptr %2, align 8
  %38 = ptrtoint ptr %name to i64
  %39 = add i64 %38, 1
  %vector_data25 = inttoptr i64 %39 to ptr
  %index_access26 = getelementptr i64, ptr %vector_data25, i64 %index_value
  %40 = load i64, ptr %index_access26, align 4
  %41 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %41, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  store i64 %40, ptr %heap_to_ptr28, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 0, ptr %42, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 0, ptr %44, align 4
  call void @set_storage(ptr %37, ptr %heap_to_ptr28)
  %slot_value29 = load i64, ptr %37, align 4
  %slot_offset30 = add i64 %slot_value29, 1
  store i64 %slot_offset30, ptr %37, align 4
  store ptr %37, ptr %2, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond23

done:                                             ; preds = %cond23
  store i64 %length15, ptr %index_alloca34, align 4
  store ptr %heap_to_ptr22, ptr %1, align 8
  br label %cond31

cond31:                                           ; preds = %body32, %done
  %index_value35 = load i64, ptr %index_alloca34, align 4
  %loop_cond36 = icmp ult i64 %index_value35, %storage_value18
  br i1 %loop_cond36, label %body32, label %done33

body32:                                           ; preds = %cond31
  %45 = load ptr, ptr %1, align 8
  %46 = call i64 @vector_new(i64 4)
  %heap_start37 = sub i64 %46, 4
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr38, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr39 = getelementptr i64, ptr %heap_to_ptr38, i64 1
  store i64 0, ptr %storage_key_ptr39, align 4
  %storage_key_ptr40 = getelementptr i64, ptr %heap_to_ptr38, i64 2
  store i64 0, ptr %storage_key_ptr40, align 4
  %storage_key_ptr41 = getelementptr i64, ptr %heap_to_ptr38, i64 3
  store i64 0, ptr %storage_key_ptr41, align 4
  call void @set_storage(ptr %45, ptr %heap_to_ptr38)
  %slot_value42 = load i64, ptr %45, align 4
  %slot_offset43 = add i64 %slot_value42, 1
  store i64 %slot_offset43, ptr %45, align 4
  store ptr %45, ptr %1, align 8
  %next_index44 = add i64 %index_value35, 1
  store i64 %next_index44, ptr %index_alloca34, align 4
  br label %cond31

done33:                                           ; preds = %cond31
  %slot_value45 = load i64, ptr %heap_to_ptr10, align 4
  %slot_offset46 = add i64 %slot_value45, 1
  store i64 %slot_offset46, ptr %heap_to_ptr10, align 4
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr12, i32 0, i32 1
  %47 = load i64, ptr %voteCount, align 4
  %48 = call i64 @vector_new(i64 4)
  %heap_start47 = sub i64 %48, 4
  %heap_to_ptr48 = inttoptr i64 %heap_start47 to ptr
  store i64 %47, ptr %heap_to_ptr48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr48, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr48, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr48, i64 3
  store i64 0, ptr %51, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr48)
  %new_length = add i64 %storage_value, 1
  %52 = call i64 @vector_new(i64 4)
  %heap_start49 = sub i64 %52, 4
  %heap_to_ptr50 = inttoptr i64 %heap_start49 to ptr
  store i64 2, ptr %heap_to_ptr50, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr50, i64 1
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %heap_to_ptr50, i64 2
  store i64 0, ptr %54, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr50, i64 3
  store i64 0, ptr %55, align 4
  %56 = call i64 @vector_new(i64 4)
  %heap_start51 = sub i64 %56, 4
  %heap_to_ptr52 = inttoptr i64 %heap_start51 to ptr
  store i64 %new_length, ptr %heap_to_ptr52, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr52, i64 1
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr52, i64 2
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %heap_to_ptr52, i64 3
  store i64 0, ptr %59, align 4
  call void @set_storage(ptr %heap_to_ptr50, ptr %heap_to_ptr52)
  br label %next
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
  store i64 1, ptr %heap_to_ptr2, align 4
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
  store i64 %slot_offset, ptr %heap_to_ptr8, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %15, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %16, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 1, ptr %heap_to_ptr10, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %19, align 4
  call void @set_storage(ptr %heap_to_ptr8, ptr %heap_to_ptr10)
  %20 = load i64, ptr %sender, align 4
  %slot_offset11 = add i64 %20, 1
  %21 = load i64, ptr %proposal_, align 4
  %22 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %22, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  store i64 %slot_offset11, ptr %heap_to_ptr13, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 0, ptr %25, align 4
  %26 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %26, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %21, ptr %heap_to_ptr15, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %29, align 4
  call void @set_storage(ptr %heap_to_ptr13, ptr %heap_to_ptr15)
  %30 = load i64, ptr %proposal_, align 4
  %31 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %31, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  %32 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %32, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  store i64 2, ptr %heap_to_ptr19, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr19, i64 1
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr19, i64 2
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr19, i64 3
  store i64 0, ptr %35, align 4
  call void @get_storage(ptr %heap_to_ptr19, ptr %heap_to_ptr17)
  %storage_value = load i64, ptr %heap_to_ptr17, align 4
  %36 = sub i64 %storage_value, 1
  %37 = sub i64 %36, %30
  call void @builtin_range_check(i64 %37)
  %38 = call i64 @vector_new(i64 4)
  %heap_start20 = sub i64 %38, 4
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  store i64 2, ptr %heap_to_ptr21, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr21, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr21, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr21, i64 3
  store i64 0, ptr %41, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %42, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr21, ptr %heap_to_ptr23, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr23, align 4
  %43 = mul i64 %30, 2
  %storage_array_offset = add i64 %hash_value_low, %43
  store i64 %storage_array_offset, ptr %heap_to_ptr23, align 4
  %slot_value = load i64, ptr %heap_to_ptr23, align 4
  %slot_offset24 = add i64 %slot_value, 1
  store i64 %slot_offset24, ptr %heap_to_ptr23, align 4
  %44 = load i64, ptr %proposal_, align 4
  %45 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %45, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  %46 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %46, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  store i64 2, ptr %heap_to_ptr28, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 0, ptr %49, align 4
  call void @get_storage(ptr %heap_to_ptr28, ptr %heap_to_ptr26)
  %storage_value29 = load i64, ptr %heap_to_ptr26, align 4
  %50 = sub i64 %storage_value29, 1
  %51 = sub i64 %50, %44
  call void @builtin_range_check(i64 %51)
  %52 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %52, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  store i64 2, ptr %heap_to_ptr31, align 4
  %53 = getelementptr i64, ptr %heap_to_ptr31, i64 1
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %heap_to_ptr31, i64 2
  store i64 0, ptr %54, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  store i64 0, ptr %55, align 4
  %56 = call i64 @vector_new(i64 4)
  %heap_start32 = sub i64 %56, 4
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr31, ptr %heap_to_ptr33, i64 4)
  %hash_value_low34 = load i64, ptr %heap_to_ptr33, align 4
  %57 = mul i64 %44, 2
  %storage_array_offset35 = add i64 %hash_value_low34, %57
  store i64 %storage_array_offset35, ptr %heap_to_ptr33, align 4
  %slot_value36 = load i64, ptr %heap_to_ptr33, align 4
  %slot_offset37 = add i64 %slot_value36, 1
  store i64 %slot_offset37, ptr %heap_to_ptr33, align 4
  %58 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %58, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  call void @get_storage(ptr %heap_to_ptr33, ptr %heap_to_ptr39)
  %storage_value40 = load i64, ptr %heap_to_ptr39, align 4
  %slot_value41 = load i64, ptr %heap_to_ptr33, align 4
  %slot_offset42 = add i64 %slot_value41, 1
  store i64 %slot_offset42, ptr %heap_to_ptr33, align 4
  %59 = add i64 %storage_value40, 1
  call void @builtin_range_check(i64 %59)
  %60 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %60, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  store i64 %59, ptr %heap_to_ptr44, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr44, i64 1
  store i64 0, ptr %61, align 4
  %62 = getelementptr i64, ptr %heap_to_ptr44, i64 2
  store i64 0, ptr %62, align 4
  %63 = getelementptr i64, ptr %heap_to_ptr44, i64 3
  store i64 0, ptr %63, align 4
  call void @set_storage(ptr %heap_to_ptr23, ptr %heap_to_ptr44)
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
  store i64 2, ptr %heap_to_ptr2, align 4
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
  store i64 2, ptr %heap_to_ptr6, align 4
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
  store i64 2, ptr %heap_to_ptr9, align 4
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
  ret i64 %26

then:                                             ; preds = %body
  %27 = load i64, ptr %p, align 4
  %28 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %28, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %29 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %29, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 2, ptr %heap_to_ptr20, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %32, align 4
  call void @get_storage(ptr %heap_to_ptr20, ptr %heap_to_ptr18)
  %storage_value21 = load i64, ptr %heap_to_ptr18, align 4
  %33 = sub i64 %storage_value21, 1
  %34 = sub i64 %33, %27
  call void @builtin_range_check(i64 %34)
  %35 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %35, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 2, ptr %heap_to_ptr23, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr23, i64 1
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr23, i64 2
  store i64 0, ptr %37, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr23, i64 3
  store i64 0, ptr %38, align 4
  %39 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %39, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr23, ptr %heap_to_ptr25, i64 4)
  %hash_value_low26 = load i64, ptr %heap_to_ptr25, align 4
  %40 = mul i64 %27, 2
  %storage_array_offset27 = add i64 %hash_value_low26, %40
  store i64 %storage_array_offset27, ptr %heap_to_ptr25, align 4
  %slot_value28 = load i64, ptr %heap_to_ptr25, align 4
  %slot_offset29 = add i64 %slot_value28, 1
  store i64 %slot_offset29, ptr %heap_to_ptr25, align 4
  %41 = call i64 @vector_new(i64 4)
  %heap_start30 = sub i64 %41, 4
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  call void @get_storage(ptr %heap_to_ptr25, ptr %heap_to_ptr31)
  %storage_value32 = load i64, ptr %heap_to_ptr31, align 4
  %slot_value33 = load i64, ptr %heap_to_ptr25, align 4
  %slot_offset34 = add i64 %slot_value33, 1
  store i64 %slot_offset34, ptr %heap_to_ptr25, align 4
  store i64 %storage_value32, ptr %winningVoteCount, align 4
  %42 = load i64, ptr %p, align 4
  store i64 %42, ptr %winningProposal_, align 4
  br label %enif

enif:                                             ; preds = %then, %body
  br label %next
}

define ptr @getWinnerName() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @winningProposal()
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %3 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %3, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 2, ptr %heap_to_ptr2, align 4
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
  store i64 2, ptr %heap_to_ptr4, align 4
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
  %length_and_data = add i64 %storage_value9, 1
  %16 = call i64 @vector_new(i64 %length_and_data)
  %heap_start12 = sub i64 %16, %length_and_data
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  store i64 %storage_value9, ptr %heap_to_ptr13, align 4
  %17 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %17, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr6, ptr %heap_to_ptr15, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr15, ptr %0, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %storage_value9
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %18 = load ptr, ptr %0, align 8
  %19 = ptrtoint ptr %heap_to_ptr13 to i64
  %20 = add i64 %19, 1
  %vector_data = inttoptr i64 %20 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %21 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %21, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  call void @get_storage(ptr %18, ptr %heap_to_ptr17)
  %storage_value18 = load i64, ptr %heap_to_ptr17, align 4
  %slot_value19 = load i64, ptr %18, align 4
  %slot_offset20 = add i64 %slot_value19, 1
  store i64 %slot_offset20, ptr %18, align 4
  store i64 %storage_value18, ptr %index_access, align 4
  store ptr %18, ptr %0, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %slot_value21 = load i64, ptr %heap_to_ptr6, align 4
  %slot_offset22 = add i64 %slot_value21, 1
  store i64 %slot_offset22, ptr %heap_to_ptr6, align 4
  ret ptr %heap_to_ptr13
}

define void @vote_test() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca133 = alloca i64, align 8
  %1 = alloca ptr, align 8
  %index_alloca89 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca76 = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %3 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %3, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_to_ptr, align 4
  %4 = ptrtoint ptr %heap_to_ptr to i64
  %5 = add i64 %4, 1
  %vector_data = inttoptr i64 %5 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_to_ptr, align 4
  %6 = sub i64 %length, 1
  %7 = sub i64 %6, 0
  call void @builtin_range_check(i64 %7)
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %9 = add i64 %8, 1
  %vector_data1 = inttoptr i64 %9 to ptr
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %10 = call i64 @vector_new(i64 11)
  %heap_start3 = sub i64 %10, 11
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 10, ptr %heap_to_ptr4, align 4
  %11 = ptrtoint ptr %heap_to_ptr4 to i64
  %12 = add i64 %11, 1
  %vector_data5 = inttoptr i64 %12 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 0
  store i64 80, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data5, i64 1
  store i64 114, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data5, i64 2
  store i64 111, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data5, i64 3
  store i64 112, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data5, i64 4
  store i64 111, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data5, i64 5
  store i64 115, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data5, i64 6
  store i64 97, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data5, i64 7
  store i64 108, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %vector_data5, i64 8
  store i64 95, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data5, i64 9
  store i64 49, ptr %index_access15, align 4
  store ptr %heap_to_ptr4, ptr %index_access2, align 8
  %length16 = load i64, ptr %heap_to_ptr, align 4
  %13 = sub i64 %length16, 1
  %14 = sub i64 %13, 1
  call void @builtin_range_check(i64 %14)
  %15 = ptrtoint ptr %heap_to_ptr to i64
  %16 = add i64 %15, 1
  %vector_data17 = inttoptr i64 %16 to ptr
  %index_access18 = getelementptr ptr, ptr %vector_data17, i64 1
  %17 = call i64 @vector_new(i64 11)
  %heap_start19 = sub i64 %17, 11
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 10, ptr %heap_to_ptr20, align 4
  %18 = ptrtoint ptr %heap_to_ptr20 to i64
  %19 = add i64 %18, 1
  %vector_data21 = inttoptr i64 %19 to ptr
  %index_access22 = getelementptr i64, ptr %vector_data21, i64 0
  store i64 80, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data21, i64 1
  store i64 114, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %vector_data21, i64 2
  store i64 111, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %vector_data21, i64 3
  store i64 112, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %vector_data21, i64 4
  store i64 111, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %vector_data21, i64 5
  store i64 115, ptr %index_access27, align 4
  %index_access28 = getelementptr i64, ptr %vector_data21, i64 6
  store i64 97, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %vector_data21, i64 7
  store i64 108, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %vector_data21, i64 8
  store i64 95, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %vector_data21, i64 9
  store i64 50, ptr %index_access31, align 4
  store ptr %heap_to_ptr20, ptr %index_access18, align 8
  %length32 = load i64, ptr %heap_to_ptr, align 4
  %20 = sub i64 %length32, 1
  %21 = sub i64 %20, 2
  call void @builtin_range_check(i64 %21)
  %22 = ptrtoint ptr %heap_to_ptr to i64
  %23 = add i64 %22, 1
  %vector_data33 = inttoptr i64 %23 to ptr
  %index_access34 = getelementptr ptr, ptr %vector_data33, i64 2
  %24 = call i64 @vector_new(i64 11)
  %heap_start35 = sub i64 %24, 11
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  store i64 10, ptr %heap_to_ptr36, align 4
  %25 = ptrtoint ptr %heap_to_ptr36 to i64
  %26 = add i64 %25, 1
  %vector_data37 = inttoptr i64 %26 to ptr
  %index_access38 = getelementptr i64, ptr %vector_data37, i64 0
  store i64 80, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %vector_data37, i64 1
  store i64 114, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %vector_data37, i64 2
  store i64 111, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %vector_data37, i64 3
  store i64 112, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %vector_data37, i64 4
  store i64 111, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %vector_data37, i64 5
  store i64 115, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %vector_data37, i64 6
  store i64 97, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %vector_data37, i64 7
  store i64 108, ptr %index_access45, align 4
  %index_access46 = getelementptr i64, ptr %vector_data37, i64 8
  store i64 95, ptr %index_access46, align 4
  %index_access47 = getelementptr i64, ptr %vector_data37, i64 9
  store i64 51, ptr %index_access47, align 4
  store ptr %heap_to_ptr36, ptr %index_access34, align 8
  store i64 0, ptr %i, align 4
  br label %cond48

cond48:                                           ; preds = %next, %done
  %27 = load i64, ptr %i, align 4
  %length50 = load i64, ptr %heap_to_ptr, align 4
  %28 = icmp ult i64 %27, %length50
  br i1 %28, label %body49, label %endfor

body49:                                           ; preds = %cond48
  %29 = call i64 @vector_new(i64 4)
  %heap_start51 = sub i64 %29, 4
  %heap_to_ptr52 = inttoptr i64 %heap_start51 to ptr
  %30 = call i64 @vector_new(i64 4)
  %heap_start53 = sub i64 %30, 4
  %heap_to_ptr54 = inttoptr i64 %heap_start53 to ptr
  store i64 2, ptr %heap_to_ptr54, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr54, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr54, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr54, i64 3
  store i64 0, ptr %33, align 4
  call void @get_storage(ptr %heap_to_ptr54, ptr %heap_to_ptr52)
  %storage_value = load i64, ptr %heap_to_ptr52, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start55 = sub i64 %34, 4
  %heap_to_ptr56 = inttoptr i64 %heap_start55 to ptr
  store i64 2, ptr %heap_to_ptr56, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr56, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr56, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr56, i64 3
  store i64 0, ptr %37, align 4
  %38 = call i64 @vector_new(i64 4)
  %heap_start57 = sub i64 %38, 4
  %heap_to_ptr58 = inttoptr i64 %heap_start57 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr56, ptr %heap_to_ptr58, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr58, align 4
  %39 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %39
  store i64 %storage_array_offset, ptr %heap_to_ptr58, align 4
  %40 = call i64 @vector_new(i64 2)
  %heap_start59 = sub i64 %40, 2
  %heap_to_ptr60 = inttoptr i64 %heap_start59 to ptr
  %struct_member = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr60, i32 0, i32 0
  %41 = load i64, ptr %i, align 4
  %length61 = load i64, ptr %heap_to_ptr, align 4
  %42 = sub i64 %length61, 1
  %43 = sub i64 %42, %41
  call void @builtin_range_check(i64 %43)
  %44 = ptrtoint ptr %heap_to_ptr to i64
  %45 = add i64 %44, 1
  %vector_data62 = inttoptr i64 %45 to ptr
  %index_access63 = getelementptr ptr, ptr %vector_data62, i64 %41
  %46 = load ptr, ptr %index_access63, align 8
  store ptr %46, ptr %struct_member, align 8
  %struct_member64 = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr60, i32 0, i32 1
  %47 = load i64, ptr %i, align 4
  store i64 %47, ptr %struct_member64, align 4
  %name = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr60, i32 0, i32 0
  %length65 = load i64, ptr %name, align 4
  %48 = call i64 @vector_new(i64 4)
  %heap_start66 = sub i64 %48, 4
  %heap_to_ptr67 = inttoptr i64 %heap_start66 to ptr
  call void @get_storage(ptr %heap_to_ptr58, ptr %heap_to_ptr67)
  %storage_value68 = load i64, ptr %heap_to_ptr67, align 4
  %slot_value = load i64, ptr %heap_to_ptr58, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr58, align 4
  %49 = call i64 @vector_new(i64 4)
  %heap_start69 = sub i64 %49, 4
  %heap_to_ptr70 = inttoptr i64 %heap_start69 to ptr
  store i64 %length65, ptr %heap_to_ptr70, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr70, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr70, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr70, i64 3
  store i64 0, ptr %52, align 4
  call void @set_storage(ptr %heap_to_ptr58, ptr %heap_to_ptr70)
  %53 = call i64 @vector_new(i64 4)
  %heap_start71 = sub i64 %53, 4
  %heap_to_ptr72 = inttoptr i64 %heap_start71 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr58, ptr %heap_to_ptr72, i64 4)
  store i64 0, ptr %index_alloca76, align 4
  store ptr %heap_to_ptr72, ptr %2, align 8
  br label %cond73

next:                                             ; preds = %done88
  %54 = load i64, ptr %i, align 4
  %55 = add i64 %54, 1
  store i64 %55, ptr %i, align 4
  br label %cond48

endfor:                                           ; preds = %cond48
  %56 = call i64 @vector_new(i64 4)
  %heap_start108 = sub i64 %56, 4
  %heap_to_ptr109 = inttoptr i64 %heap_start108 to ptr
  %57 = call i64 @vector_new(i64 4)
  %heap_start110 = sub i64 %57, 4
  %heap_to_ptr111 = inttoptr i64 %heap_start110 to ptr
  store i64 2, ptr %heap_to_ptr111, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr111, i64 1
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %heap_to_ptr111, i64 2
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %heap_to_ptr111, i64 3
  store i64 0, ptr %60, align 4
  call void @get_storage(ptr %heap_to_ptr111, ptr %heap_to_ptr109)
  %storage_value112 = load i64, ptr %heap_to_ptr109, align 4
  %61 = sub i64 %storage_value112, 1
  %62 = sub i64 %61, 0
  call void @builtin_range_check(i64 %62)
  %63 = call i64 @vector_new(i64 4)
  %heap_start113 = sub i64 %63, 4
  %heap_to_ptr114 = inttoptr i64 %heap_start113 to ptr
  store i64 2, ptr %heap_to_ptr114, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr114, i64 1
  store i64 0, ptr %64, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr114, i64 2
  store i64 0, ptr %65, align 4
  %66 = getelementptr i64, ptr %heap_to_ptr114, i64 3
  store i64 0, ptr %66, align 4
  %67 = call i64 @vector_new(i64 4)
  %heap_start115 = sub i64 %67, 4
  %heap_to_ptr116 = inttoptr i64 %heap_start115 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr114, ptr %heap_to_ptr116, i64 4)
  %hash_value_low117 = load i64, ptr %heap_to_ptr116, align 4
  %storage_array_offset118 = add i64 %hash_value_low117, 0
  store i64 %storage_array_offset118, ptr %heap_to_ptr116, align 4
  %slot_value119 = load i64, ptr %heap_to_ptr116, align 4
  %slot_offset120 = add i64 %slot_value119, 0
  store i64 %slot_offset120, ptr %heap_to_ptr116, align 4
  %68 = call i64 @vector_new(i64 4)
  %heap_start121 = sub i64 %68, 4
  %heap_to_ptr122 = inttoptr i64 %heap_start121 to ptr
  call void @get_storage(ptr %heap_to_ptr116, ptr %heap_to_ptr122)
  %storage_value123 = load i64, ptr %heap_to_ptr122, align 4
  %slot_value124 = load i64, ptr %heap_to_ptr116, align 4
  %slot_offset125 = add i64 %slot_value124, 1
  store i64 %slot_offset125, ptr %heap_to_ptr116, align 4
  %length_and_data = add i64 %storage_value123, 1
  %69 = call i64 @vector_new(i64 %length_and_data)
  %heap_start126 = sub i64 %69, %length_and_data
  %heap_to_ptr127 = inttoptr i64 %heap_start126 to ptr
  store i64 %storage_value123, ptr %heap_to_ptr127, align 4
  %70 = call i64 @vector_new(i64 4)
  %heap_start128 = sub i64 %70, 4
  %heap_to_ptr129 = inttoptr i64 %heap_start128 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr116, ptr %heap_to_ptr129, i64 4)
  store i64 0, ptr %index_alloca133, align 4
  store ptr %heap_to_ptr129, ptr %0, align 8
  br label %cond130

cond73:                                           ; preds = %body74, %body49
  %index_value77 = load i64, ptr %index_alloca76, align 4
  %loop_cond78 = icmp ult i64 %index_value77, %length65
  br i1 %loop_cond78, label %body74, label %done75

body74:                                           ; preds = %cond73
  %71 = load ptr, ptr %2, align 8
  %72 = ptrtoint ptr %name to i64
  %73 = add i64 %72, 1
  %vector_data79 = inttoptr i64 %73 to ptr
  %index_access80 = getelementptr i64, ptr %vector_data79, i64 %index_value77
  %74 = load i64, ptr %index_access80, align 4
  %75 = call i64 @vector_new(i64 4)
  %heap_start81 = sub i64 %75, 4
  %heap_to_ptr82 = inttoptr i64 %heap_start81 to ptr
  store i64 %74, ptr %heap_to_ptr82, align 4
  %76 = getelementptr i64, ptr %heap_to_ptr82, i64 1
  store i64 0, ptr %76, align 4
  %77 = getelementptr i64, ptr %heap_to_ptr82, i64 2
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %heap_to_ptr82, i64 3
  store i64 0, ptr %78, align 4
  call void @set_storage(ptr %71, ptr %heap_to_ptr82)
  %slot_value83 = load i64, ptr %71, align 4
  %slot_offset84 = add i64 %slot_value83, 1
  store i64 %slot_offset84, ptr %71, align 4
  store ptr %71, ptr %2, align 8
  %next_index85 = add i64 %index_value77, 1
  store i64 %next_index85, ptr %index_alloca76, align 4
  br label %cond73

done75:                                           ; preds = %cond73
  store i64 %length65, ptr %index_alloca89, align 4
  store ptr %heap_to_ptr72, ptr %1, align 8
  br label %cond86

cond86:                                           ; preds = %body87, %done75
  %index_value90 = load i64, ptr %index_alloca89, align 4
  %loop_cond91 = icmp ult i64 %index_value90, %storage_value68
  br i1 %loop_cond91, label %body87, label %done88

body87:                                           ; preds = %cond86
  %79 = load ptr, ptr %1, align 8
  %80 = call i64 @vector_new(i64 4)
  %heap_start92 = sub i64 %80, 4
  %heap_to_ptr93 = inttoptr i64 %heap_start92 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr93, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr94 = getelementptr i64, ptr %heap_to_ptr93, i64 1
  store i64 0, ptr %storage_key_ptr94, align 4
  %storage_key_ptr95 = getelementptr i64, ptr %heap_to_ptr93, i64 2
  store i64 0, ptr %storage_key_ptr95, align 4
  %storage_key_ptr96 = getelementptr i64, ptr %heap_to_ptr93, i64 3
  store i64 0, ptr %storage_key_ptr96, align 4
  call void @set_storage(ptr %79, ptr %heap_to_ptr93)
  %slot_value97 = load i64, ptr %79, align 4
  %slot_offset98 = add i64 %slot_value97, 1
  store i64 %slot_offset98, ptr %79, align 4
  store ptr %79, ptr %1, align 8
  %next_index99 = add i64 %index_value90, 1
  store i64 %next_index99, ptr %index_alloca89, align 4
  br label %cond86

done88:                                           ; preds = %cond86
  %slot_value100 = load i64, ptr %heap_to_ptr58, align 4
  %slot_offset101 = add i64 %slot_value100, 1
  store i64 %slot_offset101, ptr %heap_to_ptr58, align 4
  %voteCount = getelementptr inbounds { ptr, i64 }, ptr %heap_to_ptr60, i32 0, i32 1
  %81 = load i64, ptr %voteCount, align 4
  %82 = call i64 @vector_new(i64 4)
  %heap_start102 = sub i64 %82, 4
  %heap_to_ptr103 = inttoptr i64 %heap_start102 to ptr
  store i64 %81, ptr %heap_to_ptr103, align 4
  %83 = getelementptr i64, ptr %heap_to_ptr103, i64 1
  store i64 0, ptr %83, align 4
  %84 = getelementptr i64, ptr %heap_to_ptr103, i64 2
  store i64 0, ptr %84, align 4
  %85 = getelementptr i64, ptr %heap_to_ptr103, i64 3
  store i64 0, ptr %85, align 4
  call void @set_storage(ptr %heap_to_ptr58, ptr %heap_to_ptr103)
  %new_length = add i64 %storage_value, 1
  %86 = call i64 @vector_new(i64 4)
  %heap_start104 = sub i64 %86, 4
  %heap_to_ptr105 = inttoptr i64 %heap_start104 to ptr
  store i64 2, ptr %heap_to_ptr105, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr105, i64 1
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %heap_to_ptr105, i64 2
  store i64 0, ptr %88, align 4
  %89 = getelementptr i64, ptr %heap_to_ptr105, i64 3
  store i64 0, ptr %89, align 4
  %90 = call i64 @vector_new(i64 4)
  %heap_start106 = sub i64 %90, 4
  %heap_to_ptr107 = inttoptr i64 %heap_start106 to ptr
  store i64 %new_length, ptr %heap_to_ptr107, align 4
  %91 = getelementptr i64, ptr %heap_to_ptr107, i64 1
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %heap_to_ptr107, i64 2
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %heap_to_ptr107, i64 3
  store i64 0, ptr %93, align 4
  call void @set_storage(ptr %heap_to_ptr105, ptr %heap_to_ptr107)
  br label %next

cond130:                                          ; preds = %body131, %endfor
  %index_value134 = load i64, ptr %index_alloca133, align 4
  %loop_cond135 = icmp ult i64 %index_value134, %storage_value123
  br i1 %loop_cond135, label %body131, label %done132

body131:                                          ; preds = %cond130
  %94 = load ptr, ptr %0, align 8
  %95 = ptrtoint ptr %heap_to_ptr127 to i64
  %96 = add i64 %95, 1
  %vector_data136 = inttoptr i64 %96 to ptr
  %index_access137 = getelementptr i64, ptr %vector_data136, i64 %index_value134
  %97 = call i64 @vector_new(i64 4)
  %heap_start138 = sub i64 %97, 4
  %heap_to_ptr139 = inttoptr i64 %heap_start138 to ptr
  call void @get_storage(ptr %94, ptr %heap_to_ptr139)
  %storage_value140 = load i64, ptr %heap_to_ptr139, align 4
  %slot_value141 = load i64, ptr %94, align 4
  %slot_offset142 = add i64 %slot_value141, 1
  store i64 %slot_offset142, ptr %94, align 4
  store i64 %storage_value140, ptr %index_access137, align 4
  store ptr %94, ptr %0, align 8
  %next_index143 = add i64 %index_value134, 1
  store i64 %next_index143, ptr %index_alloca133, align 4
  br label %cond130

done132:                                          ; preds = %cond130
  %slot_value144 = load i64, ptr %heap_to_ptr116, align 4
  %slot_offset145 = add i64 %slot_value144, 1
  store i64 %slot_offset145, ptr %heap_to_ptr116, align 4
  %98 = ptrtoint ptr %heap_to_ptr127 to i64
  %99 = add i64 %98, 1
  %vector_data146 = inttoptr i64 %99 to ptr
  %length147 = load i64, ptr %heap_to_ptr127, align 4
  %100 = call i64 @vector_new(i64 11)
  %heap_start148 = sub i64 %100, 11
  %heap_to_ptr149 = inttoptr i64 %heap_start148 to ptr
  store i64 10, ptr %heap_to_ptr149, align 4
  %101 = ptrtoint ptr %heap_to_ptr149 to i64
  %102 = add i64 %101, 1
  %vector_data150 = inttoptr i64 %102 to ptr
  %index_access151 = getelementptr i64, ptr %vector_data150, i64 0
  store i64 80, ptr %index_access151, align 4
  %index_access152 = getelementptr i64, ptr %vector_data150, i64 1
  store i64 114, ptr %index_access152, align 4
  %index_access153 = getelementptr i64, ptr %vector_data150, i64 2
  store i64 111, ptr %index_access153, align 4
  %index_access154 = getelementptr i64, ptr %vector_data150, i64 3
  store i64 112, ptr %index_access154, align 4
  %index_access155 = getelementptr i64, ptr %vector_data150, i64 4
  store i64 111, ptr %index_access155, align 4
  %index_access156 = getelementptr i64, ptr %vector_data150, i64 5
  store i64 115, ptr %index_access156, align 4
  %index_access157 = getelementptr i64, ptr %vector_data150, i64 6
  store i64 97, ptr %index_access157, align 4
  %index_access158 = getelementptr i64, ptr %vector_data150, i64 7
  store i64 108, ptr %index_access158, align 4
  %index_access159 = getelementptr i64, ptr %vector_data150, i64 8
  store i64 95, ptr %index_access159, align 4
  %index_access160 = getelementptr i64, ptr %vector_data150, i64 9
  store i64 49, ptr %index_access160, align 4
  %103 = ptrtoint ptr %heap_to_ptr149 to i64
  %104 = add i64 %103, 1
  %vector_data161 = inttoptr i64 %104 to ptr
  %length162 = load i64, ptr %heap_to_ptr149, align 4
  %105 = icmp eq i64 %length147, %length162
  %106 = zext i1 %105 to i64
  call void @builtin_assert(i64 %106)
  %107 = call i64 @memcmp_eq(ptr %vector_data146, ptr %vector_data161, i64 %length147)
  call void @builtin_assert(i64 %107)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %size_var = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3920769769, label %func_0_dispatch
    i64 2791810083, label %func_1_dispatch
    i64 3186728800, label %func_2_dispatch
    i64 363199787, label %func_3_dispatch
    i64 69185575, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  store i64 0, ptr %size_var, align 4
  %length = load i64, ptr %3, align 4
  %4 = load i64, ptr %size_var, align 4
  %5 = add i64 %4, %length
  store i64 %5, ptr %size_var, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %length1 = load i64, ptr %3, align 4
  %6 = icmp ult i64 %index, %length1
  br i1 %6, label %body, label %end_for

next:                                             ; preds = %body
  %index4 = load i64, ptr %index_ptr, align 4
  %7 = add i64 %index4, 1
  store i64 %7, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %length2 = load i64, ptr %3, align 4
  %8 = sub i64 %length2, 1
  %9 = sub i64 %8, %index
  call void @builtin_range_check(i64 %9)
  %10 = ptrtoint ptr %3 to i64
  %11 = add i64 %10, 1
  %vector_data = inttoptr i64 %11 to ptr
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %length3 = load i64, ptr %index_access, align 4
  %12 = add i64 %length3, 1
  %13 = load i64, ptr %size_var, align 4
  %14 = add i64 %13, %12
  store i64 %14, ptr %size_var, align 4
  br label %next

end_for:                                          ; preds = %cond
  %15 = load i64, ptr %size_var, align 4
  call void @contract_init(ptr %3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start5 = ptrtoint ptr %input to i64
  %16 = inttoptr i64 %input_start5 to ptr
  %decode_value = load i64, ptr %16, align 4
  call void @vote_proposal(i64 %decode_value)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %17 = call i64 @winningProposal()
  %18 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %18, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %17, ptr %encode_value_ptr, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr6, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %19 = call ptr @getWinnerName()
  %length7 = load i64, ptr %19, align 4
  %20 = add i64 %length7, 1
  %heap_size = add i64 %20, 1
  %21 = call i64 @vector_new(i64 %heap_size)
  %heap_start8 = sub i64 %21, %heap_size
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  %length10 = load i64, ptr %19, align 4
  %22 = ptrtoint ptr %heap_to_ptr9 to i64
  %buffer_start = add i64 %22, 1
  %23 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr11 = getelementptr i64, ptr %23, i64 1
  store i64 %length10, ptr %encode_value_ptr11, align 4
  %24 = ptrtoint ptr %19 to i64
  %25 = add i64 %24, 1
  %vector_data12 = inttoptr i64 %25 to ptr
  call void @memcpy(ptr %vector_data12, ptr %23, i64 %length10)
  %26 = add i64 %length10, 1
  %27 = add i64 %26, 0
  %encode_value_ptr13 = getelementptr i64, ptr %heap_to_ptr9, i64 %27
  store i64 %20, ptr %encode_value_ptr13, align 4
  call void @set_tape_data(i64 %heap_start8, i64 %heap_size)
  ret void

func_4_dispatch:                                  ; preds = %entry
  call void @vote_test()
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
