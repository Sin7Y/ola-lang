; ModuleID = 'BookExample'
source_filename = "books"

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

define ptr @createBook(i64 %0, ptr %1) {
entry:
  %name = alloca ptr, align 8
  %id = alloca i64, align 8
  store i64 %0, ptr %id, align 4
  store ptr %1, ptr %name, align 8
  %2 = load ptr, ptr %name, align 8
  %3 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %id, align 4
  store i64 %4, ptr %struct_member, align 4
  %struct_member1 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  store ptr %2, ptr %struct_member1, align 8
  ret ptr %3
}

define ptr @getBookName(ptr %0) {
entry:
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %struct_member = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %2 = load ptr, ptr %struct_member, align 8
  ret ptr %2
}

define i64 @getBookId(ptr %0) {
entry:
  %b = alloca i64, align 8
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %struct_member = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %2 = load i64, ptr %struct_member, align 4
  %3 = add i64 %2, 1
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %b, align 4
  %4 = load i64, ptr %b, align 4
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 120553111, label %func_0_dispatch
    i64 1109322942, label %func_1_dispatch
    i64 2390167610, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %input, i64 0
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr ptr, ptr %3, i64 1
  %vector_length = load i64, ptr %5, align 4
  %6 = add i64 %vector_length, 1
  %7 = call ptr @createBook(i64 %4, ptr %5)
  %struct_member = getelementptr inbounds { i64, ptr }, ptr %7, i32 0, i32 1
  %vector_length1 = load i64, ptr %struct_member, align 4
  %8 = add i64 %vector_length1, 1
  %9 = add i64 1, %8
  %heap_size = add i64 %9, 1
  %10 = call ptr @heap_malloc(i64 %heap_size)
  %struct_member2 = getelementptr inbounds { i64, ptr }, ptr %7, i32 0, i32 0
  %elem = load i64, ptr %struct_member2, align 4
  %encode_value_ptr = getelementptr i64, ptr %10, i64 0
  store i64 %elem, ptr %encode_value_ptr, align 4
  %struct_member3 = getelementptr inbounds { i64, ptr }, ptr %7, i32 0, i32 1
  %elem4 = load ptr, ptr %struct_member3, align 8
  %vector_length5 = load i64, ptr %elem4, align 4
  %vector_data = getelementptr i64, ptr %elem4, i64 1
  %11 = add i64 %vector_length5, 1
  call void @memcpy(ptr %vector_data, ptr %10, i64 %11)
  %12 = add i64 %11, 1
  %13 = add i64 %12, 0
  %encode_value_ptr6 = getelementptr i64, ptr %10, i64 %13
  store i64 %9, ptr %encode_value_ptr6, align 4
  call void @set_tape_data(ptr %10, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %14 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field = getelementptr { i64, ptr }, ptr %14, i64 0
  %15 = load i64, ptr %decode_struct_field, align 4
  %decode_struct_field7 = getelementptr { i64, ptr }, ptr %14, i64 1
  %vector_length8 = load i64, ptr %decode_struct_field7, align 4
  %16 = add i64 %vector_length8, 1
  %decode_struct_offset = add i64 1, %16
  %17 = call ptr @heap_malloc(i64 2)
  %struct_member9 = getelementptr inbounds { i64, ptr }, ptr %17, i32 0, i32 0
  store i64 %15, ptr %struct_member9, align 4
  %struct_member10 = getelementptr inbounds { i64, ptr }, ptr %17, i32 0, i32 1
  store ptr %decode_struct_field7, ptr %struct_member10, align 8
  %18 = call ptr @getBookName(ptr %17)
  %vector_length11 = load i64, ptr %18, align 4
  %19 = add i64 %vector_length11, 1
  %heap_size12 = add i64 %19, 1
  %20 = call ptr @heap_malloc(i64 %heap_size12)
  %vector_length13 = load i64, ptr %18, align 4
  %vector_data14 = getelementptr i64, ptr %18, i64 1
  %21 = add i64 %vector_length13, 1
  call void @memcpy(ptr %vector_data14, ptr %20, i64 %21)
  %22 = add i64 %21, 0
  %encode_value_ptr15 = getelementptr i64, ptr %20, i64 %22
  store i64 %19, ptr %encode_value_ptr15, align 4
  call void @set_tape_data(ptr %20, i64 %heap_size12)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %23 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field16 = getelementptr { i64, ptr }, ptr %23, i64 0
  %24 = load i64, ptr %decode_struct_field16, align 4
  %decode_struct_field17 = getelementptr { i64, ptr }, ptr %23, i64 1
  %vector_length18 = load i64, ptr %decode_struct_field17, align 4
  %25 = add i64 %vector_length18, 1
  %decode_struct_offset19 = add i64 1, %25
  %26 = call ptr @heap_malloc(i64 2)
  %struct_member20 = getelementptr inbounds { i64, ptr }, ptr %26, i32 0, i32 0
  store i64 %24, ptr %struct_member20, align 4
  %struct_member21 = getelementptr inbounds { i64, ptr }, ptr %26, i32 0, i32 1
  store ptr %decode_struct_field17, ptr %struct_member21, align 8
  %27 = call i64 @getBookId(ptr %26)
  %28 = call ptr @heap_malloc(i64 2)
  %encode_value_ptr22 = getelementptr i64, ptr %28, i64 0
  store i64 %27, ptr %encode_value_ptr22, align 4
  %encode_value_ptr23 = getelementptr i64, ptr %28, i64 1
  store i64 1, ptr %encode_value_ptr23, align 4
  call void @set_tape_data(ptr %28, i64 2)
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
