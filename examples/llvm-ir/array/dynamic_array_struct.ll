; ModuleID = 'StructArrayExample'
source_filename = "dynamic_array_struct"

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

define ptr @createBooks() {
entry:
  %0 = call i64 @vector_new(i64 14)
  %heap_start = sub i64 %0, 14
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %elemptr0 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %heap_to_ptr, i64 0
  %1 = call i64 @vector_new(i64 7)
  %heap_start1 = sub i64 %1, 7
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %heap_to_ptr2, i32 0, i32 0
  store i64 0, ptr %struct_member, align 4
  %struct_member3 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %heap_to_ptr2, i32 0, i32 1
  store i64 111, ptr %struct_member3, align 4
  %struct_member4 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %heap_to_ptr2, i32 0, i32 2
  %2 = call i64 @vector_new(i64 5)
  %heap_start5 = sub i64 %2, 5
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %elemptr07 = getelementptr [5 x i64], ptr %heap_to_ptr6, i64 0
  store i64 1, ptr %elemptr07, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %heap_to_ptr6, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %heap_to_ptr6, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %heap_to_ptr6, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %heap_to_ptr6, i64 4
  store i64 5, ptr %elemptr4, align 4
  %elem = load [5 x i64], ptr %heap_to_ptr6, align 4
  store [5 x i64] %elem, ptr %struct_member4, align 4
  %elem8 = load { i64, i64, [5 x i64] }, ptr %heap_to_ptr2, align 4
  store { i64, i64, [5 x i64] } %elem8, ptr %elemptr0, align 4
  %elemptr19 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %heap_to_ptr, i64 1
  %3 = call i64 @vector_new(i64 7)
  %heap_start10 = sub i64 %3, 7
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  %struct_member12 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %heap_to_ptr11, i32 0, i32 0
  store i64 0, ptr %struct_member12, align 4
  %struct_member13 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %heap_to_ptr11, i32 0, i32 1
  store i64 0, ptr %struct_member13, align 4
  %struct_member14 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %heap_to_ptr11, i32 0, i32 2
  %4 = call i64 @vector_new(i64 5)
  %heap_start15 = sub i64 %4, 5
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  %elemptr017 = getelementptr [5 x i64], ptr %heap_to_ptr16, i64 0
  store i64 0, ptr %elemptr017, align 4
  %elemptr118 = getelementptr [5 x i64], ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %elemptr118, align 4
  %elemptr219 = getelementptr [5 x i64], ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %elemptr219, align 4
  %elemptr320 = getelementptr [5 x i64], ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %elemptr320, align 4
  %elemptr421 = getelementptr [5 x i64], ptr %heap_to_ptr16, i64 4
  store i64 0, ptr %elemptr421, align 4
  %elem22 = load [5 x i64], ptr %heap_to_ptr16, align 4
  store [5 x i64] %elem22, ptr %struct_member14, align 4
  %elem23 = load { i64, i64, [5 x i64] }, ptr %heap_to_ptr11, align 4
  store { i64, i64, [5 x i64] } %elem23, ptr %elemptr19, align 4
  ret ptr %heap_to_ptr
}

define i64 @getFirstBookID(ptr %0) {
entry:
  %_books = alloca ptr, align 8
  store ptr %0, ptr %_books, align 8
  %1 = load ptr, ptr %_books, align 8
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %1, i64 0
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  %index_access1 = getelementptr [5 x i64], ptr %struct_member, i64 1
  %2 = load i64, ptr %index_access1, align 4
  ret i64 %2
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %size_var24 = alloca i64, align 8
  %size_var = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2736305406, label %func_0_dispatch
    i64 4212406781, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBooks()
  store i64 0, ptr %size_var, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %4 = icmp ult i64 %index, 2
  br i1 %4, label %body, label %end_for

next:                                             ; preds = %body
  %index1 = load i64, ptr %index_ptr, align 4
  %5 = add i64 %index1, 1
  store i64 %5, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %6 = sub i64 1, %index
  call void @builtin_range_check(i64 %6)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 %index
  %struct_start = ptrtoint ptr %index_access to i64
  %7 = add i64 %struct_start, 1
  %8 = inttoptr i64 %7 to ptr
  %9 = add i64 %7, 1
  %10 = inttoptr i64 %9 to ptr
  %11 = add i64 %9, 5
  %12 = inttoptr i64 %11 to ptr
  %13 = sub i64 %11, %struct_start
  %14 = load i64, ptr %size_var, align 4
  %15 = add i64 %14, %13
  store i64 %15, ptr %size_var, align 4
  br label %next

end_for:                                          ; preds = %cond
  %16 = load i64, ptr %size_var, align 4
  %heap_size = add i64 %16, 1
  %17 = call i64 @vector_new(i64 %heap_size)
  %heap_start = sub i64 %17, %heap_size
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %offset_var_no = alloca i64, align 8
  store i64 0, ptr %offset_var_no, align 4
  %index_ptr2 = alloca i64, align 8
  store i64 0, ptr %index_ptr2, align 4
  %index3 = load i64, ptr %index_ptr2, align 4
  br label %cond4

cond4:                                            ; preds = %next5, %end_for
  %18 = icmp ult i64 %index3, 2
  br i1 %18, label %body6, label %end_for7

next5:                                            ; preds = %body6
  %index22 = load i64, ptr %index_ptr2, align 4
  %19 = add i64 %index22, 1
  store i64 %19, ptr %index_ptr2, align 4
  br label %cond4

body6:                                            ; preds = %cond4
  %20 = sub i64 1, %index3
  call void @builtin_range_check(i64 %20)
  %index_access8 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 %index3
  %21 = load i64, ptr %offset_var_no, align 4
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 0
  %elem = load i64, ptr %struct_member, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 %21
  store i64 %elem, ptr %encode_value_ptr, align 4
  %22 = add i64 1, %21
  %struct_member9 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 1
  %elem10 = load i64, ptr %struct_member9, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %heap_to_ptr, i64 %22
  store i64 %elem10, ptr %encode_value_ptr11, align 4
  %23 = add i64 1, %22
  %struct_member12 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 2
  %elemptr0 = getelementptr [5 x i64], ptr %struct_member12, i64 0, i64 0
  %24 = load i64, ptr %elemptr0, align 4
  %encode_value_ptr13 = getelementptr i64, ptr %heap_to_ptr, i64 %23
  store i64 %24, ptr %encode_value_ptr13, align 4
  %offset = add i64 %23, 1
  %elemptr1 = getelementptr [5 x i64], ptr %struct_member12, i64 0, i64 1
  %25 = load i64, ptr %elemptr1, align 4
  %encode_value_ptr14 = getelementptr i64, ptr %heap_to_ptr, i64 %offset
  store i64 %25, ptr %encode_value_ptr14, align 4
  %offset15 = add i64 %offset, 1
  %elemptr2 = getelementptr [5 x i64], ptr %struct_member12, i64 0, i64 2
  %26 = load i64, ptr %elemptr2, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %heap_to_ptr, i64 %offset15
  store i64 %26, ptr %encode_value_ptr16, align 4
  %offset17 = add i64 %offset15, 1
  %elemptr3 = getelementptr [5 x i64], ptr %struct_member12, i64 0, i64 3
  %27 = load i64, ptr %elemptr3, align 4
  %encode_value_ptr18 = getelementptr i64, ptr %heap_to_ptr, i64 %offset17
  store i64 %27, ptr %encode_value_ptr18, align 4
  %offset19 = add i64 %offset17, 1
  %elemptr4 = getelementptr [5 x i64], ptr %struct_member12, i64 0, i64 4
  %28 = load i64, ptr %elemptr4, align 4
  %encode_value_ptr20 = getelementptr i64, ptr %heap_to_ptr, i64 %offset19
  store i64 %28, ptr %encode_value_ptr20, align 4
  %offset21 = add i64 %offset19, 1
  %29 = add i64 %21, 7
  store i64 %29, ptr %offset_var_no, align 4
  br label %next5

end_for7:                                         ; preds = %cond4
  %30 = load i64, ptr %offset_var_no, align 4
  %31 = sub i64 %30, 0
  %32 = add i64 %31, 0
  %encode_value_ptr23 = getelementptr i64, ptr %heap_to_ptr, i64 %32
  store i64 %16, ptr %encode_value_ptr23, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %33 = inttoptr i64 %input_start to ptr
  store i64 0, ptr %size_var24, align 4
  %index_ptr25 = alloca i64, align 8
  store i64 0, ptr %index_ptr25, align 4
  %index26 = load i64, ptr %index_ptr25, align 4
  br label %cond27

cond27:                                           ; preds = %next28, %func_1_dispatch
  %34 = icmp ult i64 %index26, 2
  br i1 %34, label %body29, label %end_for30

next28:                                           ; preds = %body29
  %index33 = load i64, ptr %index_ptr25, align 4
  %35 = add i64 %index33, 1
  store i64 %35, ptr %index_ptr25, align 4
  br label %cond27

body29:                                           ; preds = %cond27
  %36 = sub i64 1, %index26
  call void @builtin_range_check(i64 %36)
  %index_access31 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %33, i64 %index26
  %struct_start32 = ptrtoint ptr %index_access31 to i64
  %37 = add i64 %struct_start32, 1
  %38 = inttoptr i64 %37 to ptr
  %39 = add i64 %37, 1
  %40 = inttoptr i64 %39 to ptr
  %41 = add i64 %39, 5
  %42 = inttoptr i64 %41 to ptr
  %43 = sub i64 %41, %struct_start32
  %44 = load i64, ptr %size_var24, align 4
  %45 = add i64 %44, %43
  store i64 %45, ptr %size_var24, align 4
  br label %next28

end_for30:                                        ; preds = %cond27
  %46 = load i64, ptr %size_var24, align 4
  %47 = call i64 @getFirstBookID(ptr %33)
  %48 = call i64 @vector_new(i64 2)
  %heap_start34 = sub i64 %48, 2
  %heap_to_ptr35 = inttoptr i64 %heap_start34 to ptr
  %encode_value_ptr36 = getelementptr i64, ptr %heap_to_ptr35, i64 0
  store i64 %47, ptr %encode_value_ptr36, align 4
  %encode_value_ptr37 = getelementptr i64, ptr %heap_to_ptr35, i64 1
  store i64 1, ptr %encode_value_ptr37, align 4
  call void @set_tape_data(i64 %heap_start34, i64 2)
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
