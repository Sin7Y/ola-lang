; ModuleID = 'Voting'
source_filename = "examples/source/storage/vote_simple.ola"

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
  %4 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %4, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 0
  %5 = load i64, ptr %i, align 4
  %length1 = load i64, ptr %1, align 4
  %6 = sub i64 %length1, 1
  %7 = sub i64 %6, %5
  call void @builtin_range_check(i64 %7)
  %8 = ptrtoint ptr %1 to i64
  %9 = add i64 %8, 1
  %vector_data = inttoptr i64 %9 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %5
  %10 = load i64, ptr %index_access, align 4
  store i64 %10, ptr %struct_member, align 4
  %struct_member2 = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 1
  store i64 99, ptr %struct_member2, align 4
  %11 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %11, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 1, ptr %heap_to_ptr6, align 4
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
  store i64 1, ptr %heap_to_ptr8, align 4
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
  %21 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  %hash_value_low = load i64, ptr %21, align 4
  %22 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %22
  store i64 %storage_array_offset, ptr %21, align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 0
  %23 = load i64, ptr %name, align 4
  %24 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %24, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %23, ptr %heap_to_ptr12, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %27, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr12)
  %28 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  %slot_value = load i64, ptr %28, align 4
  %slot_offset = add i64 %slot_value, 1
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 1
  %29 = load i64, ptr %voteCount, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %30, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 %slot_offset, ptr %heap_to_ptr14, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %32, align 4
  %33 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %33, align 4
  %34 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %34, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %29, ptr %heap_to_ptr16, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %36, align 4
  %37 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %37, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  %new_length = add i64 %storage_value, 1
  %38 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %38, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 1, ptr %heap_to_ptr18, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %41, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %42, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %new_length, ptr %heap_to_ptr20, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %45, align 4
  call void @set_storage(ptr %heap_to_ptr18, ptr %heap_to_ptr20)
  br label %next

next:                                             ; preds = %body
  %46 = load i64, ptr %i, align 4
  %47 = add i64 %46, 1
  store i64 %47, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %48 = call i64 @vector_new(i64 4)
  %heap_start21 = sub i64 %48, 4
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  %49 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %49, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  store i64 1, ptr %heap_to_ptr24, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr24, i64 1
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr24, i64 2
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr24, i64 3
  store i64 0, ptr %52, align 4
  call void @get_storage(ptr %heap_to_ptr24, ptr %heap_to_ptr22)
  %storage_value25 = load i64, ptr %heap_to_ptr22, align 4
  %53 = sub i64 %storage_value25, 1
  %54 = sub i64 %53, 0
  call void @builtin_range_check(i64 %54)
  %55 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %55, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  store i64 1, ptr %heap_to_ptr27, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr27, i64 2
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  store i64 0, ptr %58, align 4
  %59 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %59, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr27, ptr %heap_to_ptr29, i64 4)
  %60 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  %hash_value_low30 = load i64, ptr %60, align 4
  %storage_array_offset31 = add i64 %hash_value_low30, 0
  store i64 %storage_array_offset31, ptr %60, align 4
  %61 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  %slot_value32 = load i64, ptr %61, align 4
  %slot_offset33 = add i64 %slot_value32, 0
  %62 = call i64 @vector_new(i64 4)
  %heap_start34 = sub i64 %62, 4
  %heap_to_ptr35 = inttoptr i64 %heap_start34 to ptr
  %63 = call i64 @vector_new(i64 4)
  %heap_start36 = sub i64 %63, 4
  %heap_to_ptr37 = inttoptr i64 %heap_start36 to ptr
  store i64 %slot_offset33, ptr %heap_to_ptr37, align 4
  %64 = getelementptr i64, ptr %heap_to_ptr37, i64 1
  store i64 0, ptr %64, align 4
  %65 = getelementptr i64, ptr %heap_to_ptr37, i64 2
  store i64 0, ptr %65, align 4
  %66 = getelementptr i64, ptr %heap_to_ptr37, i64 3
  store i64 0, ptr %66, align 4
  call void @get_storage(ptr %heap_to_ptr37, ptr %heap_to_ptr35)
  %storage_value38 = load i64, ptr %heap_to_ptr35, align 4
  %slot_offset39 = add i64 %slot_offset33, 1
  call void @prophet_printf(i64 %storage_value38, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2817135588, label %func_0_dispatch
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
