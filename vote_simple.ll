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
  %proposalNames_ = alloca ptr, align 8
  store ptr %0, ptr %proposalNames_, align 8
  %1 = load ptr, ptr %proposalNames_, align 8
  %2 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %2, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 0
  %length = load i64, ptr %1, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %1 to i64
  %6 = add i64 %5, 1
  %vector_data = inttoptr i64 %6 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  %7 = load i64, ptr %index_access, align 4
  store i64 %7, ptr %struct_member, align 4
  %struct_member1 = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 1
  store i64 99, ptr %struct_member1, align 4
  %8 = call i64 @vector_new(i64 4)
  %heap_start2 = sub i64 %8, 4
  %heap_to_ptr3 = inttoptr i64 %heap_start2 to ptr
  %9 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %9, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 1, ptr %heap_to_ptr5, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 0, ptr %12, align 4
  call void @get_storage(ptr %heap_to_ptr5, ptr %heap_to_ptr3)
  %storage_value = load i64, ptr %heap_to_ptr3, align 4
  %13 = call i64 @vector_new(i64 4)
  %heap_start6 = sub i64 %13, 4
  %heap_to_ptr7 = inttoptr i64 %heap_start6 to ptr
  store i64 1, ptr %heap_to_ptr7, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr7, i64 1
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr7, i64 2
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr7, i64 3
  store i64 0, ptr %16, align 4
  %17 = call i64 @vector_new(i64 4)
  %heap_start8 = sub i64 %17, 4
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr7, ptr %heap_to_ptr9, i64 4)
  %hash_value_low = load i64, ptr %heap_to_ptr9, align 4
  %18 = mul i64 %storage_value, 2
  %storage_array_offset = add i64 %hash_value_low, %18
  store i64 %storage_array_offset, ptr %heap_to_ptr9, align 4
  %name = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 0
  %19 = load i64, ptr %name, align 4
  %20 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %20, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  store i64 %19, ptr %heap_to_ptr11, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr11, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr11, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  store i64 0, ptr %23, align 4
  call void @set_storage(ptr %heap_to_ptr9, ptr %heap_to_ptr11)
  %slot_value = load i64, ptr %heap_to_ptr9, align 4
  %slot_offset = add i64 %slot_value, 1
  %voteCount = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 1
  %24 = load i64, ptr %voteCount, align 4
  %25 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %25, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  store i64 %slot_offset, ptr %heap_to_ptr13, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 0, ptr %28, align 4
  %29 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %29, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %24, ptr %heap_to_ptr15, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %31, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %32, align 4
  call void @set_storage(ptr %heap_to_ptr13, ptr %heap_to_ptr15)
  %new_length = add i64 %storage_value, 1
  %33 = call i64 @vector_new(i64 4)
  %heap_start16 = sub i64 %33, 4
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 1, ptr %heap_to_ptr17, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr17, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr17, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr17, i64 3
  store i64 0, ptr %36, align 4
  %37 = call i64 @vector_new(i64 4)
  %heap_start18 = sub i64 %37, 4
  %heap_to_ptr19 = inttoptr i64 %heap_start18 to ptr
  store i64 %new_length, ptr %heap_to_ptr19, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr19, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr19, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr19, i64 3
  store i64 0, ptr %40, align 4
  call void @set_storage(ptr %heap_to_ptr17, ptr %heap_to_ptr19)
  %41 = call i64 @vector_new(i64 4)
  %heap_start20 = sub i64 %41, 4
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  %42 = call i64 @vector_new(i64 4)
  %heap_start22 = sub i64 %42, 4
  %heap_to_ptr23 = inttoptr i64 %heap_start22 to ptr
  store i64 1, ptr %heap_to_ptr23, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr23, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr23, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr23, i64 3
  store i64 0, ptr %45, align 4
  call void @get_storage(ptr %heap_to_ptr23, ptr %heap_to_ptr21)
  %storage_value24 = load i64, ptr %heap_to_ptr21, align 4
  %46 = sub i64 %storage_value24, 1
  %47 = sub i64 %46, 0
  call void @builtin_range_check(i64 %47)
  %48 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %48, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  store i64 1, ptr %heap_to_ptr26, align 4
  %49 = getelementptr i64, ptr %heap_to_ptr26, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr26, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  store i64 0, ptr %51, align 4
  %52 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %52, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr26, ptr %heap_to_ptr28, i64 4)
  %hash_value_low29 = load i64, ptr %heap_to_ptr28, align 4
  %storage_array_offset30 = add i64 %hash_value_low29, 0
  store i64 %storage_array_offset30, ptr %heap_to_ptr28, align 4
  %slot_value31 = load i64, ptr %heap_to_ptr28, align 4
  %slot_offset32 = add i64 %slot_value31, 0
  %53 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %53, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  %54 = call i64 @vector_new(i64 4)
  %heap_start35 = sub i64 %54, 4
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  store i64 %slot_offset32, ptr %heap_to_ptr36, align 4
  %55 = getelementptr i64, ptr %heap_to_ptr36, i64 1
  store i64 0, ptr %55, align 4
  %56 = getelementptr i64, ptr %heap_to_ptr36, i64 2
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %heap_to_ptr36, i64 3
  store i64 0, ptr %57, align 4
  call void @get_storage(ptr %heap_to_ptr36, ptr %heap_to_ptr34)
  %storage_value37 = load i64, ptr %heap_to_ptr34, align 4
  %slot_offset38 = add i64 %slot_offset32, 1
  call void @prophet_printf(i64 %storage_value37, i64 3)
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
