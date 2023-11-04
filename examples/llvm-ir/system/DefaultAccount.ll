; ModuleID = 'DefaultAccount'
source_filename = "examples/source/system/DefaultAccount.ola"

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

define void @ignoreDelegateCall() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 4)
  %1 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %1, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 8)
  %2 = call i64 @memcmp_eq(ptr %heap_to_ptr, ptr %heap_to_ptr2, i64 4)
  call void @builtin_assert(i64 %2)
  ret void
}

define i64 @validateTransaction(ptr %0, ptr %1, ptr %2) {
entry:
  %magic = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  %_txHash = alloca ptr, align 8
  store ptr %0, ptr %_txHash, align 8
  store ptr %1, ptr %_signedHash, align 8
  store ptr %2, ptr %_tx, align 8
  %3 = load ptr, ptr %_tx, align 8
  call void @onlyEntrypointCall()
  call void @ignoreDelegateCall()
  %4 = call i64 @vector_new(i64 43)
  %heap_start = sub i64 %4, 43
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 42, ptr %heap_to_ptr, align 4
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data = inttoptr i64 %6 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 118, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 97, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 105, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 100, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 5
  store i64 97, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 6
  store i64 116, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 7
  store i64 101, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 8
  store i64 84, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data, i64 9
  store i64 114, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data, i64 10
  store i64 97, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data, i64 11
  store i64 110, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data, i64 12
  store i64 115, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data, i64 13
  store i64 97, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %vector_data, i64 14
  store i64 99, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data, i64 15
  store i64 116, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %vector_data, i64 16
  store i64 105, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %vector_data, i64 17
  store i64 111, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %vector_data, i64 18
  store i64 110, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %vector_data, i64 19
  store i64 40, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %vector_data, i64 20
  store i64 104, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %vector_data, i64 21
  store i64 97, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %vector_data, i64 22
  store i64 115, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data, i64 23
  store i64 104, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %vector_data, i64 24
  store i64 44, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %vector_data, i64 25
  store i64 104, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %vector_data, i64 26
  store i64 97, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %vector_data, i64 27
  store i64 115, ptr %index_access27, align 4
  %index_access28 = getelementptr i64, ptr %vector_data, i64 28
  store i64 104, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %vector_data, i64 29
  store i64 44, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %vector_data, i64 30
  store i64 84, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %vector_data, i64 31
  store i64 114, ptr %index_access31, align 4
  %index_access32 = getelementptr i64, ptr %vector_data, i64 32
  store i64 97, ptr %index_access32, align 4
  %index_access33 = getelementptr i64, ptr %vector_data, i64 33
  store i64 110, ptr %index_access33, align 4
  %index_access34 = getelementptr i64, ptr %vector_data, i64 34
  store i64 115, ptr %index_access34, align 4
  %index_access35 = getelementptr i64, ptr %vector_data, i64 35
  store i64 97, ptr %index_access35, align 4
  %index_access36 = getelementptr i64, ptr %vector_data, i64 36
  store i64 99, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %vector_data, i64 37
  store i64 116, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %vector_data, i64 38
  store i64 105, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %vector_data, i64 39
  store i64 111, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %vector_data, i64 40
  store i64 110, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %vector_data, i64 41
  store i64 41, ptr %index_access41, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %7 = ptrtoint ptr %heap_to_ptr to i64
  %8 = add i64 %7, 1
  %vector_data42 = inttoptr i64 %8 to ptr
  %9 = call i64 @vector_new(i64 4)
  %heap_start43 = sub i64 %9, 4
  %heap_to_ptr44 = inttoptr i64 %heap_start43 to ptr
  call void @poseidon_hash(ptr %vector_data42, ptr %heap_to_ptr44, i64 %length)
  store ptr %heap_to_ptr44, ptr %magic, align 8
  %10 = load ptr, ptr %magic, align 8
  %11 = call i64 @vector_new(i64 5)
  %heap_start45 = sub i64 %11, 5
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  store i64 4, ptr %heap_to_ptr46, align 4
  %12 = getelementptr i64, ptr %10, i64 0
  %13 = load i64, ptr %12, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr46, i64 0
  store i64 %13, ptr %14, align 4
  %15 = getelementptr i64, ptr %10, i64 1
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr46, i64 1
  store i64 %16, ptr %17, align 4
  %18 = getelementptr i64, ptr %10, i64 2
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr46, i64 2
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %10, i64 3
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr46, i64 3
  store i64 %22, ptr %23, align 4
  %length47 = load i64, ptr %heap_to_ptr46, align 4
  %24 = sub i64 %length47, 1
  %25 = sub i64 %24, 0
  call void @builtin_range_check(i64 %25)
  %26 = ptrtoint ptr %heap_to_ptr46 to i64
  %27 = add i64 %26, 1
  %vector_data48 = inttoptr i64 %27 to ptr
  %index_access49 = getelementptr i64, ptr %vector_data48, i64 0
  %28 = load i64, ptr %index_access49, align 4
  ret i64 %28
}

define ptr @executeTransaction(ptr %0, ptr %1, ptr %2) {
entry:
  %to = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  %_txHash = alloca ptr, align 8
  store ptr %0, ptr %_txHash, align 8
  store ptr %1, ptr %_signedHash, align 8
  store ptr %2, ptr %_tx, align 8
  %3 = load ptr, ptr %_tx, align 8
  call void @onlyEntrypointCall()
  call void @ignoreDelegateCall()
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 4
  %4 = load ptr, ptr %struct_member, align 8
  %length = load i64, ptr %4, align 4
  %array_len_sub_one = sub i64 %length, 1
  %5 = sub i64 %array_len_sub_one, 0
  call void @builtin_range_check(i64 %5)
  %6 = sub i64 %length, 4
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %7, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 4, ptr %heap_to_ptr, align 4
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %9 = add i64 %8, 1
  %vector_data = inttoptr i64 %9 to ptr
  %10 = ptrtoint ptr %4 to i64
  %11 = add i64 %10, 1
  %vector_data1 = inttoptr i64 %11 to ptr
  call void @memcpy(ptr %vector_data1, ptr %vector_data, i64 4)
  %length2 = load i64, ptr %heap_to_ptr, align 4
  %12 = ptrtoint ptr %heap_to_ptr to i64
  %13 = add i64 %12, 1
  %vector_data3 = inttoptr i64 %13 to ptr
  %input_start = ptrtoint ptr %vector_data3 to i64
  %14 = inttoptr i64 %input_start to ptr
  store ptr %14, ptr %to, align 8
  %struct_member4 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 4
  %15 = load ptr, ptr %struct_member4, align 8
  %length5 = load i64, ptr %15, align 4
  %array_len_sub_one6 = sub i64 %length5, 1
  %16 = sub i64 %array_len_sub_one6, 4
  call void @builtin_range_check(i64 %16)
  %17 = sub i64 %length5, %length5
  call void @builtin_range_check(i64 %17)
  %slice_len = sub i64 %length5, 4
  call void @builtin_range_check(i64 %slice_len)
  %length_and_data = add i64 %slice_len, 1
  %18 = call i64 @vector_new(i64 %length_and_data)
  %heap_start7 = sub i64 %18, %length_and_data
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %slice_len, ptr %heap_to_ptr8, align 4
  %19 = ptrtoint ptr %heap_to_ptr8 to i64
  %20 = add i64 %19, 1
  %vector_data9 = inttoptr i64 %20 to ptr
  %21 = ptrtoint ptr %15 to i64
  %22 = add i64 %21, 1
  %vector_data10 = inttoptr i64 %22 to ptr
  call void @memcpy(ptr %vector_data10, ptr %vector_data9, i64 %slice_len)
  %23 = load ptr, ptr %to, align 8
  %payload_len = load i64, ptr %heap_to_ptr8, align 4
  %tape_size = add i64 %payload_len, 2
  %24 = ptrtoint ptr %heap_to_ptr8 to i64
  %payload_start = add i64 %24, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %23, i64 0)
  %25 = call i64 @vector_new(i64 1)
  %heap_start11 = sub i64 %25, 1
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @get_tape_data(i64 %heap_start11, i64 1)
  %return_length = load i64, ptr %heap_to_ptr12, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size13 = add i64 %return_length, 1
  %26 = call i64 @vector_new(i64 %heap_size)
  %heap_start14 = sub i64 %26, %heap_size
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %return_length, ptr %heap_to_ptr15, align 4
  %27 = add i64 %heap_start14, 1
  call void @get_tape_data(i64 %27, i64 %tape_size13)
  ret ptr %heap_to_ptr15
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 698884830, label %func_0_dispatch
    i64 4067211222, label %func_1_dispatch
    i64 720659959, label %func_2_dispatch
    i64 2740749627, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @onlyEntrypointCall()
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @ignoreDelegateCall()
  ret void

func_2_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = add i64 %input_start, 4
  %5 = inttoptr i64 %4 to ptr
  %6 = add i64 %4, 4
  %7 = inttoptr i64 %6 to ptr
  %struct_offset = add i64 %6, 4
  %8 = inttoptr i64 %struct_offset to ptr
  %decode_value = load i64, ptr %8, align 4
  %struct_offset1 = add i64 %struct_offset, 1
  %9 = inttoptr i64 %struct_offset1 to ptr
  %decode_value2 = load i64, ptr %9, align 4
  %struct_offset3 = add i64 %struct_offset1, 1
  %10 = inttoptr i64 %struct_offset3 to ptr
  %decode_value4 = load i64, ptr %10, align 4
  %struct_offset5 = add i64 %struct_offset3, 1
  %11 = inttoptr i64 %struct_offset5 to ptr
  %length = load i64, ptr %11, align 4
  %12 = add i64 %length, 1
  %struct_offset6 = add i64 %struct_offset5, %12
  %13 = inttoptr i64 %struct_offset6 to ptr
  %length7 = load i64, ptr %13, align 4
  %14 = add i64 %length7, 1
  %struct_offset8 = add i64 %struct_offset6, %14
  %15 = inttoptr i64 %struct_offset8 to ptr
  %length9 = load i64, ptr %15, align 4
  %16 = add i64 %length9, 1
  %struct_offset10 = add i64 %struct_offset8, %16
  %17 = inttoptr i64 %struct_offset10 to ptr
  %struct_offset11 = add i64 %struct_offset10, 4
  %struct_decode_size = sub i64 %struct_offset11, %6
  %18 = call i64 @vector_new(i64 14)
  %heap_start = sub i64 %18, 14
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 0
  store ptr %7, ptr %struct_member, align 8
  %struct_member12 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 1
  store i64 %decode_value, ptr %struct_member12, align 4
  %struct_member13 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 2
  store i64 %decode_value2, ptr %struct_member13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 3
  store i64 %decode_value4, ptr %struct_member14, align 4
  %struct_member15 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 4
  store ptr %11, ptr %struct_member15, align 8
  %struct_member16 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 5
  store ptr %13, ptr %struct_member16, align 8
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 6
  store ptr %15, ptr %struct_member17, align 8
  %struct_member18 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 7
  store ptr %17, ptr %struct_member18, align 8
  %19 = call i64 @validateTransaction(ptr %3, ptr %5, ptr %heap_to_ptr)
  %20 = call i64 @vector_new(i64 2)
  %heap_start19 = sub i64 %20, 2
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr20, i64 0
  store i64 %19, ptr %encode_value_ptr, align 4
  %encode_value_ptr21 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 1, ptr %encode_value_ptr21, align 4
  call void @set_tape_data(i64 %heap_start19, i64 2)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %input_start22 = ptrtoint ptr %input to i64
  %21 = inttoptr i64 %input_start22 to ptr
  %22 = add i64 %input_start22, 4
  %23 = inttoptr i64 %22 to ptr
  %24 = add i64 %22, 4
  %25 = inttoptr i64 %24 to ptr
  %struct_offset23 = add i64 %24, 4
  %26 = inttoptr i64 %struct_offset23 to ptr
  %decode_value24 = load i64, ptr %26, align 4
  %struct_offset25 = add i64 %struct_offset23, 1
  %27 = inttoptr i64 %struct_offset25 to ptr
  %decode_value26 = load i64, ptr %27, align 4
  %struct_offset27 = add i64 %struct_offset25, 1
  %28 = inttoptr i64 %struct_offset27 to ptr
  %decode_value28 = load i64, ptr %28, align 4
  %struct_offset29 = add i64 %struct_offset27, 1
  %29 = inttoptr i64 %struct_offset29 to ptr
  %length30 = load i64, ptr %29, align 4
  %30 = add i64 %length30, 1
  %struct_offset31 = add i64 %struct_offset29, %30
  %31 = inttoptr i64 %struct_offset31 to ptr
  %length32 = load i64, ptr %31, align 4
  %32 = add i64 %length32, 1
  %struct_offset33 = add i64 %struct_offset31, %32
  %33 = inttoptr i64 %struct_offset33 to ptr
  %length34 = load i64, ptr %33, align 4
  %34 = add i64 %length34, 1
  %struct_offset35 = add i64 %struct_offset33, %34
  %35 = inttoptr i64 %struct_offset35 to ptr
  %struct_offset36 = add i64 %struct_offset35, 4
  %struct_decode_size37 = sub i64 %struct_offset36, %24
  %36 = call i64 @vector_new(i64 14)
  %heap_start38 = sub i64 %36, 14
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  %struct_member40 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 0
  store ptr %25, ptr %struct_member40, align 8
  %struct_member41 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 1
  store i64 %decode_value24, ptr %struct_member41, align 4
  %struct_member42 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 2
  store i64 %decode_value26, ptr %struct_member42, align 4
  %struct_member43 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 3
  store i64 %decode_value28, ptr %struct_member43, align 4
  %struct_member44 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 4
  store ptr %29, ptr %struct_member44, align 8
  %struct_member45 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 5
  store ptr %31, ptr %struct_member45, align 8
  %struct_member46 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 6
  store ptr %33, ptr %struct_member46, align 8
  %struct_member47 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr39, i32 0, i32 7
  store ptr %35, ptr %struct_member47, align 8
  %37 = call ptr @executeTransaction(ptr %21, ptr %23, ptr %heap_to_ptr39)
  %length48 = load i64, ptr %37, align 4
  %38 = add i64 %length48, 1
  %heap_size = add i64 %38, 1
  %39 = call i64 @vector_new(i64 %heap_size)
  %heap_start49 = sub i64 %39, %heap_size
  %heap_to_ptr50 = inttoptr i64 %heap_start49 to ptr
  %length51 = load i64, ptr %37, align 4
  %40 = ptrtoint ptr %heap_to_ptr50 to i64
  %buffer_start = add i64 %40, 1
  %41 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr52 = getelementptr i64, ptr %41, i64 1
  store i64 %length51, ptr %encode_value_ptr52, align 4
  %42 = ptrtoint ptr %37 to i64
  %43 = add i64 %42, 1
  %vector_data = inttoptr i64 %43 to ptr
  call void @memcpy(ptr %vector_data, ptr %41, i64 %length51)
  %44 = add i64 %length51, 1
  %45 = add i64 %44, 0
  %encode_value_ptr53 = getelementptr i64, ptr %heap_to_ptr50, i64 %45
  store i64 %38, ptr %encode_value_ptr53, align 4
  call void @set_tape_data(i64 %heap_start49, i64 %heap_size)
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
