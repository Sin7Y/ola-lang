; ModuleID = 'SystemContextExample'
source_filename = "system_context"

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

define void @all_test() {
entry:
  %current = alloca ptr, align 8
  %code = alloca ptr, align 8
  %origin = alloca ptr, align 8
  %caller = alloca ptr, align 8
  %tx_hash = alloca ptr, align 8
  %signature = alloca ptr, align 8
  %nonce = alloca i64, align 8
  %chain_id = alloca i64, align 8
  %tx_version = alloca i64, align 8
  %sequence = alloca ptr, align 8
  %block_timestamp = alloca i64, align 8
  %block_number = alloca i64, align 8
  %0 = call i64 @block_number_test()
  store i64 %0, ptr %block_number, align 4
  %1 = load i64, ptr %block_number, align 4
  call void @prophet_printf(i64 %1, i64 3)
  %2 = call i64 @block_timestamp_test()
  store i64 %2, ptr %block_timestamp, align 4
  %3 = load i64, ptr %block_timestamp, align 4
  call void @prophet_printf(i64 %3, i64 3)
  %4 = call ptr @sequence_address_test()
  store ptr %4, ptr %sequence, align 8
  %5 = load ptr, ptr %sequence, align 8
  %address_start = ptrtoint ptr %5 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %6 = call i64 @transaction_version_test()
  store i64 %6, ptr %tx_version, align 4
  %7 = load i64, ptr %tx_version, align 4
  call void @prophet_printf(i64 %7, i64 3)
  %8 = call i64 @chain_id_test()
  store i64 %8, ptr %chain_id, align 4
  %9 = load i64, ptr %chain_id, align 4
  call void @prophet_printf(i64 %9, i64 3)
  %10 = call i64 @nonce_test()
  store i64 %10, ptr %nonce, align 4
  %11 = load i64, ptr %nonce, align 4
  call void @prophet_printf(i64 %11, i64 3)
  %12 = call ptr @signautre_test()
  store ptr %12, ptr %signature, align 8
  %13 = load ptr, ptr %signature, align 8
  %hash_start = ptrtoint ptr %13 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  %14 = call ptr @transaction_hash_test()
  store ptr %14, ptr %tx_hash, align 8
  %15 = load ptr, ptr %tx_hash, align 8
  %hash_start1 = ptrtoint ptr %15 to i64
  call void @prophet_printf(i64 %hash_start1, i64 2)
  %16 = call ptr @caller_address_test()
  store ptr %16, ptr %caller, align 8
  %17 = load ptr, ptr %caller, align 8
  %address_start2 = ptrtoint ptr %17 to i64
  call void @prophet_printf(i64 %address_start2, i64 2)
  %18 = call ptr @origin_address_test()
  store ptr %18, ptr %origin, align 8
  %19 = load ptr, ptr %origin, align 8
  %address_start3 = ptrtoint ptr %19 to i64
  call void @prophet_printf(i64 %address_start3, i64 2)
  %20 = call ptr @code_address_test()
  store ptr %20, ptr %code, align 8
  %21 = load ptr, ptr %code, align 8
  %address_start4 = ptrtoint ptr %21 to i64
  call void @prophet_printf(i64 %address_start4, i64 2)
  %22 = call ptr @current_address_test()
  store ptr %22, ptr %current, align 8
  %23 = load ptr, ptr %current, align 8
  %address_start5 = ptrtoint ptr %23 to i64
  call void @prophet_printf(i64 %address_start5, i64 2)
  ret void
}

define ptr @caller_address_test() {
entry:
  %0 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %0, i64 12)
  ret ptr %0
}

define ptr @origin_address_test() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = getelementptr i64, ptr %0, i64 0
  call void @get_context_data(ptr %1, i64 8)
  %2 = getelementptr i64, ptr %0, i64 1
  call void @get_context_data(ptr %2, i64 9)
  %3 = getelementptr i64, ptr %0, i64 2
  call void @get_context_data(ptr %3, i64 10)
  %4 = getelementptr i64, ptr %0, i64 3
  call void @get_context_data(ptr %4, i64 11)
  ret ptr %0
}

define ptr @code_address_test() {
entry:
  %0 = call ptr @heap_malloc(i64 8)
  call void @get_tape_data(ptr %0, i64 8)
  ret ptr %0
}

define ptr @current_address_test() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  call void @get_tape_data(ptr %0, i64 4)
  ret ptr %0
}

define i64 @chain_id_test() {
entry:
  %0 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %0, i64 7)
  %1 = load i64, ptr %0, align 4
  ret i64 %1
}

define i64 @block_number_test() {
entry:
  %0 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %0, i64 0)
  %1 = load i64, ptr %0, align 4
  ret i64 %1
}

define i64 @block_timestamp_test() {
entry:
  %0 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %0, i64 1)
  %1 = load i64, ptr %0, align 4
  ret i64 %1
}

define ptr @sequence_address_test() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = getelementptr i64, ptr %0, i64 0
  call void @get_context_data(ptr %1, i64 2)
  %2 = getelementptr i64, ptr %0, i64 1
  call void @get_context_data(ptr %2, i64 3)
  %3 = getelementptr i64, ptr %0, i64 2
  call void @get_context_data(ptr %3, i64 4)
  %4 = getelementptr i64, ptr %0, i64 3
  call void @get_context_data(ptr %4, i64 5)
  ret ptr %0
}

define i64 @nonce_test() {
entry:
  %0 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %0, i64 12)
  %1 = load i64, ptr %0, align 4
  ret i64 %1
}

define ptr @signautre_test() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = getelementptr i64, ptr %0, i64 0
  call void @get_context_data(ptr %1, i64 13)
  %2 = getelementptr i64, ptr %0, i64 1
  call void @get_context_data(ptr %2, i64 14)
  %3 = getelementptr i64, ptr %0, i64 2
  call void @get_context_data(ptr %3, i64 15)
  %4 = getelementptr i64, ptr %0, i64 3
  call void @get_context_data(ptr %4, i64 16)
  ret ptr %0
}

define i64 @transaction_version_test() {
entry:
  %0 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %0, i64 6)
  %1 = load i64, ptr %0, align 4
  ret i64 %1
}

define ptr @transaction_hash_test() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %1 = getelementptr i64, ptr %0, i64 0
  call void @get_context_data(ptr %1, i64 17)
  %2 = getelementptr i64, ptr %0, i64 1
  call void @get_context_data(ptr %2, i64 18)
  %3 = getelementptr i64, ptr %0, i64 2
  call void @get_context_data(ptr %3, i64 19)
  %4 = getelementptr i64, ptr %0, i64 3
  call void @get_context_data(ptr %4, i64 20)
  ret ptr %0
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2702975438, label %func_0_dispatch
    i64 1522957762, label %func_1_dispatch
    i64 3586122346, label %func_2_dispatch
    i64 1485773374, label %func_3_dispatch
    i64 2733308081, label %func_4_dispatch
    i64 869244242, label %func_5_dispatch
    i64 3338821124, label %func_6_dispatch
    i64 437255, label %func_7_dispatch
    i64 583520202, label %func_8_dispatch
    i64 2936506770, label %func_9_dispatch
    i64 1992639626, label %func_10_dispatch
    i64 3365981980, label %func_11_dispatch
    i64 2802357593, label %func_12_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @all_test()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %4 = call ptr @caller_address_test()
  %5 = call ptr @heap_malloc(i64 5)
  %6 = getelementptr i64, ptr %4, i64 0
  %7 = load i64, ptr %6, align 4
  %8 = getelementptr i64, ptr %5, i64 0
  store i64 %7, ptr %8, align 4
  %9 = getelementptr i64, ptr %4, i64 1
  %10 = load i64, ptr %9, align 4
  %11 = getelementptr i64, ptr %5, i64 1
  store i64 %10, ptr %11, align 4
  %12 = getelementptr i64, ptr %4, i64 2
  %13 = load i64, ptr %12, align 4
  %14 = getelementptr i64, ptr %5, i64 2
  store i64 %13, ptr %14, align 4
  %15 = getelementptr i64, ptr %4, i64 3
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %5, i64 3
  store i64 %16, ptr %17, align 4
  %18 = getelementptr ptr, ptr %5, i64 4
  store i64 4, ptr %18, align 4
  call void @set_tape_data(ptr %5, i64 5)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %19 = call ptr @origin_address_test()
  %20 = call ptr @heap_malloc(i64 5)
  %21 = getelementptr i64, ptr %19, i64 0
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %20, i64 0
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %19, i64 1
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %20, i64 1
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %19, i64 2
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %20, i64 2
  store i64 %28, ptr %29, align 4
  %30 = getelementptr i64, ptr %19, i64 3
  %31 = load i64, ptr %30, align 4
  %32 = getelementptr i64, ptr %20, i64 3
  store i64 %31, ptr %32, align 4
  %33 = getelementptr ptr, ptr %20, i64 4
  store i64 4, ptr %33, align 4
  call void @set_tape_data(ptr %20, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %34 = call ptr @code_address_test()
  %35 = call ptr @heap_malloc(i64 5)
  %36 = getelementptr i64, ptr %34, i64 0
  %37 = load i64, ptr %36, align 4
  %38 = getelementptr i64, ptr %35, i64 0
  store i64 %37, ptr %38, align 4
  %39 = getelementptr i64, ptr %34, i64 1
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %35, i64 1
  store i64 %40, ptr %41, align 4
  %42 = getelementptr i64, ptr %34, i64 2
  %43 = load i64, ptr %42, align 4
  %44 = getelementptr i64, ptr %35, i64 2
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %34, i64 3
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %35, i64 3
  store i64 %46, ptr %47, align 4
  %48 = getelementptr ptr, ptr %35, i64 4
  store i64 4, ptr %48, align 4
  call void @set_tape_data(ptr %35, i64 5)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %49 = call ptr @current_address_test()
  %50 = call ptr @heap_malloc(i64 5)
  %51 = getelementptr i64, ptr %49, i64 0
  %52 = load i64, ptr %51, align 4
  %53 = getelementptr i64, ptr %50, i64 0
  store i64 %52, ptr %53, align 4
  %54 = getelementptr i64, ptr %49, i64 1
  %55 = load i64, ptr %54, align 4
  %56 = getelementptr i64, ptr %50, i64 1
  store i64 %55, ptr %56, align 4
  %57 = getelementptr i64, ptr %49, i64 2
  %58 = load i64, ptr %57, align 4
  %59 = getelementptr i64, ptr %50, i64 2
  store i64 %58, ptr %59, align 4
  %60 = getelementptr i64, ptr %49, i64 3
  %61 = load i64, ptr %60, align 4
  %62 = getelementptr i64, ptr %50, i64 3
  store i64 %61, ptr %62, align 4
  %63 = getelementptr ptr, ptr %50, i64 4
  store i64 4, ptr %63, align 4
  call void @set_tape_data(ptr %50, i64 5)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %64 = call i64 @chain_id_test()
  %65 = call ptr @heap_malloc(i64 2)
  store i64 %64, ptr %65, align 4
  %66 = getelementptr ptr, ptr %65, i64 1
  store i64 1, ptr %66, align 4
  call void @set_tape_data(ptr %65, i64 2)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %67 = call i64 @block_number_test()
  %68 = call ptr @heap_malloc(i64 2)
  store i64 %67, ptr %68, align 4
  %69 = getelementptr ptr, ptr %68, i64 1
  store i64 1, ptr %69, align 4
  call void @set_tape_data(ptr %68, i64 2)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %70 = call i64 @block_timestamp_test()
  %71 = call ptr @heap_malloc(i64 2)
  store i64 %70, ptr %71, align 4
  %72 = getelementptr ptr, ptr %71, i64 1
  store i64 1, ptr %72, align 4
  call void @set_tape_data(ptr %71, i64 2)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %73 = call ptr @sequence_address_test()
  %74 = call ptr @heap_malloc(i64 5)
  %75 = getelementptr i64, ptr %73, i64 0
  %76 = load i64, ptr %75, align 4
  %77 = getelementptr i64, ptr %74, i64 0
  store i64 %76, ptr %77, align 4
  %78 = getelementptr i64, ptr %73, i64 1
  %79 = load i64, ptr %78, align 4
  %80 = getelementptr i64, ptr %74, i64 1
  store i64 %79, ptr %80, align 4
  %81 = getelementptr i64, ptr %73, i64 2
  %82 = load i64, ptr %81, align 4
  %83 = getelementptr i64, ptr %74, i64 2
  store i64 %82, ptr %83, align 4
  %84 = getelementptr i64, ptr %73, i64 3
  %85 = load i64, ptr %84, align 4
  %86 = getelementptr i64, ptr %74, i64 3
  store i64 %85, ptr %86, align 4
  %87 = getelementptr ptr, ptr %74, i64 4
  store i64 4, ptr %87, align 4
  call void @set_tape_data(ptr %74, i64 5)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %88 = call i64 @nonce_test()
  %89 = call ptr @heap_malloc(i64 2)
  store i64 %88, ptr %89, align 4
  %90 = getelementptr ptr, ptr %89, i64 1
  store i64 1, ptr %90, align 4
  call void @set_tape_data(ptr %89, i64 2)
  ret void

func_10_dispatch:                                 ; preds = %entry
  %91 = call ptr @signautre_test()
  %92 = call ptr @heap_malloc(i64 5)
  %93 = getelementptr i64, ptr %91, i64 0
  %94 = load i64, ptr %93, align 4
  %95 = getelementptr i64, ptr %92, i64 0
  store i64 %94, ptr %95, align 4
  %96 = getelementptr i64, ptr %91, i64 1
  %97 = load i64, ptr %96, align 4
  %98 = getelementptr i64, ptr %92, i64 1
  store i64 %97, ptr %98, align 4
  %99 = getelementptr i64, ptr %91, i64 2
  %100 = load i64, ptr %99, align 4
  %101 = getelementptr i64, ptr %92, i64 2
  store i64 %100, ptr %101, align 4
  %102 = getelementptr i64, ptr %91, i64 3
  %103 = load i64, ptr %102, align 4
  %104 = getelementptr i64, ptr %92, i64 3
  store i64 %103, ptr %104, align 4
  %105 = getelementptr ptr, ptr %92, i64 4
  store i64 4, ptr %105, align 4
  call void @set_tape_data(ptr %92, i64 5)
  ret void

func_11_dispatch:                                 ; preds = %entry
  %106 = call i64 @transaction_version_test()
  %107 = call ptr @heap_malloc(i64 2)
  store i64 %106, ptr %107, align 4
  %108 = getelementptr ptr, ptr %107, i64 1
  store i64 1, ptr %108, align 4
  call void @set_tape_data(ptr %107, i64 2)
  ret void

func_12_dispatch:                                 ; preds = %entry
  %109 = call ptr @transaction_hash_test()
  %110 = call ptr @heap_malloc(i64 5)
  %111 = getelementptr i64, ptr %109, i64 0
  %112 = load i64, ptr %111, align 4
  %113 = getelementptr i64, ptr %110, i64 0
  store i64 %112, ptr %113, align 4
  %114 = getelementptr i64, ptr %109, i64 1
  %115 = load i64, ptr %114, align 4
  %116 = getelementptr i64, ptr %110, i64 1
  store i64 %115, ptr %116, align 4
  %117 = getelementptr i64, ptr %109, i64 2
  %118 = load i64, ptr %117, align 4
  %119 = getelementptr i64, ptr %110, i64 2
  store i64 %118, ptr %119, align 4
  %120 = getelementptr i64, ptr %109, i64 3
  %121 = load i64, ptr %120, align 4
  %122 = getelementptr i64, ptr %110, i64 3
  store i64 %121, ptr %122, align 4
  %123 = getelementptr ptr, ptr %110, i64 4
  store i64 4, ptr %123, align 4
  call void @set_tape_data(ptr %110, i64 5)
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
