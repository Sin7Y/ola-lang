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

define ptr @caller_address_test() {
entry:
  %0 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %0, i64 12)
  ret ptr %0
}

define ptr @origin_address_test() {
entry:
  %0 = call ptr @heap_malloc(i64 4)
  %origin_address = getelementptr i64, ptr %0, i64 0
  call void @get_context_data(ptr %origin_address, i64 8)
  %origin_address1 = getelementptr i64, ptr %0, i64 1
  call void @get_context_data(ptr %origin_address1, i64 9)
  %origin_address2 = getelementptr i64, ptr %0, i64 2
  call void @get_context_data(ptr %origin_address2, i64 10)
  %origin_address3 = getelementptr i64, ptr %0, i64 3
  call void @get_context_data(ptr %origin_address3, i64 11)
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

define void @all_test() {
entry:
  %chain = alloca i64, align 8
  %current = alloca ptr, align 8
  %code = alloca ptr, align 8
  %origin = alloca ptr, align 8
  %caller = alloca ptr, align 8
  %0 = call ptr @caller_address_test()
  store ptr %0, ptr %caller, align 8
  %1 = load ptr, ptr %caller, align 8
  %2 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %2, i64 0
  store i64 17, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %2, i64 1
  store i64 18, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %2, i64 2
  store i64 19, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %2, i64 3
  store i64 20, ptr %index_access3, align 4
  %3 = call i64 @memcmp_eq(ptr %1, ptr %2, i64 4)
  call void @builtin_assert(i64 %3)
  %4 = call ptr @origin_address_test()
  store ptr %4, ptr %origin, align 8
  %5 = load ptr, ptr %origin, align 8
  %6 = call ptr @heap_malloc(i64 4)
  %index_access4 = getelementptr i64, ptr %6, i64 0
  store i64 5, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %6, i64 1
  store i64 6, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %6, i64 2
  store i64 7, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %6, i64 3
  store i64 8, ptr %index_access7, align 4
  %7 = call i64 @memcmp_eq(ptr %5, ptr %6, i64 4)
  call void @builtin_assert(i64 %7)
  %8 = call ptr @code_address_test()
  store ptr %8, ptr %code, align 8
  %9 = load ptr, ptr %code, align 8
  %10 = call ptr @heap_malloc(i64 4)
  %index_access8 = getelementptr i64, ptr %10, i64 0
  store i64 9, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %10, i64 1
  store i64 10, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %10, i64 2
  store i64 11, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %10, i64 3
  store i64 12, ptr %index_access11, align 4
  %11 = call i64 @memcmp_eq(ptr %9, ptr %10, i64 4)
  call void @builtin_assert(i64 %11)
  %12 = call ptr @current_address_test()
  store ptr %12, ptr %current, align 8
  %13 = load ptr, ptr %current, align 8
  %14 = call ptr @heap_malloc(i64 4)
  %index_access12 = getelementptr i64, ptr %14, i64 0
  store i64 13, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %14, i64 1
  store i64 14, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %14, i64 2
  store i64 15, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %14, i64 3
  store i64 16, ptr %index_access15, align 4
  %15 = call i64 @memcmp_eq(ptr %13, ptr %14, i64 4)
  call void @builtin_assert(i64 %15)
  %16 = call i64 @chain_id_test()
  store i64 %16, ptr %chain, align 4
  %17 = load i64, ptr %chain, align 4
  %18 = icmp eq i64 %17, 1
  %19 = zext i1 %18 to i64
  call void @builtin_assert(i64 %19)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1522957762, label %func_0_dispatch
    i64 3586122346, label %func_1_dispatch
    i64 1485773374, label %func_2_dispatch
    i64 2733308081, label %func_3_dispatch
    i64 869244242, label %func_4_dispatch
    i64 2702975438, label %func_5_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @caller_address_test()
  %4 = call ptr @heap_malloc(i64 5)
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %encode_value_ptr = getelementptr i64, ptr %4, i64 0
  store i64 %6, ptr %encode_value_ptr, align 4
  %7 = getelementptr i64, ptr %3, i64 1
  %8 = load i64, ptr %7, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %4, i64 1
  store i64 %8, ptr %encode_value_ptr1, align 4
  %9 = getelementptr i64, ptr %3, i64 2
  %10 = load i64, ptr %9, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %4, i64 2
  store i64 %10, ptr %encode_value_ptr2, align 4
  %11 = getelementptr i64, ptr %3, i64 3
  %12 = load i64, ptr %11, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %4, i64 3
  store i64 %12, ptr %encode_value_ptr3, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %4, i64 4
  store i64 4, ptr %encode_value_ptr4, align 4
  call void @set_tape_data(ptr %4, i64 5)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %13 = call ptr @origin_address_test()
  %14 = call ptr @heap_malloc(i64 5)
  %15 = getelementptr i64, ptr %13, i64 0
  %16 = load i64, ptr %15, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %14, i64 0
  store i64 %16, ptr %encode_value_ptr5, align 4
  %17 = getelementptr i64, ptr %13, i64 1
  %18 = load i64, ptr %17, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %14, i64 1
  store i64 %18, ptr %encode_value_ptr6, align 4
  %19 = getelementptr i64, ptr %13, i64 2
  %20 = load i64, ptr %19, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %14, i64 2
  store i64 %20, ptr %encode_value_ptr7, align 4
  %21 = getelementptr i64, ptr %13, i64 3
  %22 = load i64, ptr %21, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %14, i64 3
  store i64 %22, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %14, i64 4
  store i64 4, ptr %encode_value_ptr9, align 4
  call void @set_tape_data(ptr %14, i64 5)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %23 = call ptr @code_address_test()
  %24 = call ptr @heap_malloc(i64 5)
  %25 = getelementptr i64, ptr %23, i64 0
  %26 = load i64, ptr %25, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %24, i64 0
  store i64 %26, ptr %encode_value_ptr10, align 4
  %27 = getelementptr i64, ptr %23, i64 1
  %28 = load i64, ptr %27, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %24, i64 1
  store i64 %28, ptr %encode_value_ptr11, align 4
  %29 = getelementptr i64, ptr %23, i64 2
  %30 = load i64, ptr %29, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %24, i64 2
  store i64 %30, ptr %encode_value_ptr12, align 4
  %31 = getelementptr i64, ptr %23, i64 3
  %32 = load i64, ptr %31, align 4
  %encode_value_ptr13 = getelementptr i64, ptr %24, i64 3
  store i64 %32, ptr %encode_value_ptr13, align 4
  %encode_value_ptr14 = getelementptr i64, ptr %24, i64 4
  store i64 4, ptr %encode_value_ptr14, align 4
  call void @set_tape_data(ptr %24, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %33 = call ptr @current_address_test()
  %34 = call ptr @heap_malloc(i64 5)
  %35 = getelementptr i64, ptr %33, i64 0
  %36 = load i64, ptr %35, align 4
  %encode_value_ptr15 = getelementptr i64, ptr %34, i64 0
  store i64 %36, ptr %encode_value_ptr15, align 4
  %37 = getelementptr i64, ptr %33, i64 1
  %38 = load i64, ptr %37, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %34, i64 1
  store i64 %38, ptr %encode_value_ptr16, align 4
  %39 = getelementptr i64, ptr %33, i64 2
  %40 = load i64, ptr %39, align 4
  %encode_value_ptr17 = getelementptr i64, ptr %34, i64 2
  store i64 %40, ptr %encode_value_ptr17, align 4
  %41 = getelementptr i64, ptr %33, i64 3
  %42 = load i64, ptr %41, align 4
  %encode_value_ptr18 = getelementptr i64, ptr %34, i64 3
  store i64 %42, ptr %encode_value_ptr18, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %34, i64 4
  store i64 4, ptr %encode_value_ptr19, align 4
  call void @set_tape_data(ptr %34, i64 5)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %43 = call i64 @chain_id_test()
  %44 = call ptr @heap_malloc(i64 2)
  %encode_value_ptr20 = getelementptr i64, ptr %44, i64 0
  store i64 %43, ptr %encode_value_ptr20, align 4
  %encode_value_ptr21 = getelementptr i64, ptr %44, i64 1
  store i64 1, ptr %encode_value_ptr21, align 4
  call void @set_tape_data(ptr %44, i64 2)
  ret void

func_5_dispatch:                                  ; preds = %entry
  call void @all_test()
  %45 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %45, align 4
  call void @set_tape_data(ptr %45, i64 1)
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
