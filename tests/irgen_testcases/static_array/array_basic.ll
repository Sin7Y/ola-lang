; ModuleID = 'StaticArrayBasicTest'
source_filename = "array_basic"

@heap_address = internal global i64 -4294967353

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

define void @testArrayDeclareUninitialized() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 0, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 0, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 0, ptr %elemptr2, align 4
  %array_start = ptrtoint ptr %0 to i64
  call void @prophet_printf(i64 %array_start, i64 0)
  ret void
}

define void @testArrayDeclareInitialized() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %array_start = ptrtoint ptr %0 to i64
  call void @prophet_printf(i64 %array_start, i64 0)
  ret void
}

define void @testArrayDeclareThenInitialized() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 0, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 0, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 0, ptr %elemptr2, align 4
  %1 = call ptr @heap_malloc(i64 3)
  %elemptr01 = getelementptr [3 x i64], ptr %1, i64 0
  store i64 1, ptr %elemptr01, align 4
  %elemptr12 = getelementptr [3 x i64], ptr %1, i64 1
  store i64 2, ptr %elemptr12, align 4
  %elemptr23 = getelementptr [3 x i64], ptr %1, i64 2
  store i64 3, ptr %elemptr23, align 4
  %array_start = ptrtoint ptr %1 to i64
  call void @prophet_printf(i64 %array_start, i64 0)
  ret void
}

define void @testArrayInitializedByOther() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %array_start = ptrtoint ptr %0 to i64
  call void @prophet_printf(i64 %array_start, i64 0)
  ret void
}

define void @testArraySizeWithExpression() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %array_start = ptrtoint ptr %0 to i64
  call void @prophet_printf(i64 %array_start, i64 0)
  ret void
}

define void @testArrayAsParameter(ptr %0) {
entry:
  %x = alloca ptr, align 8
  store ptr %0, ptr %x, align 8
  %1 = load ptr, ptr %x, align 8
  %array_start = ptrtoint ptr %1 to i64
  call void @prophet_printf(i64 %array_start, i64 0)
  ret void
}

define void @testArrayCallByValue() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  call void @testArrayAsParameter(ptr %0)
  ret void
}

define ptr @testArrayAsReturnValue() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  ret ptr %0
}

define ptr @testArrayAsReturnConstValue() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  ret ptr %0
}

define i64 @testArrayLength() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  ret i64 3
}

define void @testArrayGetEelement() {
entry:
  %b = alloca i64, align 8
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %0, i64 2
  %1 = load i64, ptr %index_access, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %b, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @testArraySetEelement() {
entry:
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %0, i64 2
  store i64 4, ptr %index_access, align 4
  %array_start = ptrtoint ptr %0 to i64
  call void @prophet_printf(i64 %array_start, i64 0)
  ret void
}

define void @testArrayIndexOutOfBound() {
entry:
  %b = alloca i64, align 8
  %0 = call ptr @heap_malloc(i64 3)
  %elemptr0 = getelementptr [3 x i64], ptr %0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %0, i64 2
  store i64 3, ptr %elemptr2, align 4
  call void @builtin_range_check(i64 -1)
  %index_access = getelementptr [3 x i64], ptr %0, i64 3
  %1 = load i64, ptr %index_access, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %b, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 432367226, label %func_0_dispatch
    i64 3136118530, label %func_1_dispatch
    i64 1307800998, label %func_2_dispatch
    i64 447890007, label %func_3_dispatch
    i64 2401934093, label %func_4_dispatch
    i64 3877688483, label %func_5_dispatch
    i64 1288701359, label %func_6_dispatch
    i64 29085570, label %func_7_dispatch
    i64 2388818016, label %func_8_dispatch
    i64 409498593, label %func_9_dispatch
    i64 3741232141, label %func_10_dispatch
    i64 829436596, label %func_11_dispatch
    i64 469877648, label %func_12_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @testArrayDeclareUninitialized()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @testArrayDeclareInitialized()
  %4 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %4, align 4
  call void @set_tape_data(ptr %4, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @testArrayDeclareThenInitialized()
  %5 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %5, align 4
  call void @set_tape_data(ptr %5, i64 1)
  ret void

func_3_dispatch:                                  ; preds = %entry
  call void @testArrayInitializedByOther()
  %6 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %6, align 4
  call void @set_tape_data(ptr %6, i64 1)
  ret void

func_4_dispatch:                                  ; preds = %entry
  call void @testArraySizeWithExpression()
  %7 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %7, align 4
  call void @set_tape_data(ptr %7, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %8 = getelementptr ptr, ptr %input, i64 3
  call void @testArrayAsParameter(ptr %input)
  %9 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %9, align 4
  call void @set_tape_data(ptr %9, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  call void @testArrayCallByValue()
  %10 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %10, align 4
  call void @set_tape_data(ptr %10, i64 1)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %11 = call ptr @testArrayAsReturnValue()
  %12 = call ptr @heap_malloc(i64 4)
  %elemptr0 = getelementptr [3 x i64], ptr %11, i64 0, i64 0
  %13 = load i64, ptr %elemptr0, align 4
  %encode_value_ptr = getelementptr i64, ptr %12, i64 0
  store i64 %13, ptr %encode_value_ptr, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %11, i64 0, i64 1
  %14 = load i64, ptr %elemptr1, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %12, i64 1
  store i64 %14, ptr %encode_value_ptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %11, i64 0, i64 2
  %15 = load i64, ptr %elemptr2, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %12, i64 2
  store i64 %15, ptr %encode_value_ptr2, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %12, i64 3
  store i64 3, ptr %encode_value_ptr3, align 4
  call void @set_tape_data(ptr %12, i64 4)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %16 = call ptr @testArrayAsReturnConstValue()
  %17 = call ptr @heap_malloc(i64 4)
  %elemptr04 = getelementptr [3 x i64], ptr %16, i64 0, i64 0
  %18 = load i64, ptr %elemptr04, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %17, i64 0
  store i64 %18, ptr %encode_value_ptr5, align 4
  %elemptr16 = getelementptr [3 x i64], ptr %16, i64 0, i64 1
  %19 = load i64, ptr %elemptr16, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %17, i64 1
  store i64 %19, ptr %encode_value_ptr7, align 4
  %elemptr28 = getelementptr [3 x i64], ptr %16, i64 0, i64 2
  %20 = load i64, ptr %elemptr28, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %17, i64 2
  store i64 %20, ptr %encode_value_ptr9, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %17, i64 3
  store i64 3, ptr %encode_value_ptr10, align 4
  call void @set_tape_data(ptr %17, i64 4)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %21 = call i64 @testArrayLength()
  %22 = call ptr @heap_malloc(i64 2)
  %encode_value_ptr11 = getelementptr i64, ptr %22, i64 0
  store i64 %21, ptr %encode_value_ptr11, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %22, i64 1
  store i64 1, ptr %encode_value_ptr12, align 4
  call void @set_tape_data(ptr %22, i64 2)
  ret void

func_10_dispatch:                                 ; preds = %entry
  call void @testArrayGetEelement()
  %23 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %23, align 4
  call void @set_tape_data(ptr %23, i64 1)
  ret void

func_11_dispatch:                                 ; preds = %entry
  call void @testArraySetEelement()
  %24 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %24, align 4
  call void @set_tape_data(ptr %24, i64 1)
  ret void

func_12_dispatch:                                 ; preds = %entry
  call void @testArrayIndexOutOfBound()
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
