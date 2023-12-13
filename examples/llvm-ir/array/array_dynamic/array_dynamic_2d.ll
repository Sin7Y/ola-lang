; ModuleID = 'DynamicTwoDimensionalArrayInMemory'
source_filename = "array_dynamic_2d"

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

define ptr @initialize(i64 %0, i64 %1) {
entry:
  %index_alloca9 = alloca i64, align 8
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %columns = alloca i64, align 8
  %rows = alloca i64, align 8
  store i64 %0, ptr %rows, align 4
  store i64 %1, ptr %columns, align 4
  %2 = load i64, ptr %rows, align 4
  %3 = mul i64 %2, 1
  %4 = call ptr @vector_new(i64 %3)
  %vector_data = getelementptr i64, ptr %4, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %5 = call ptr @vector_new(i64 0)
  store ptr %5, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %6 = load i64, ptr %i, align 4
  %7 = load i64, ptr %rows, align 4
  %8 = icmp ult i64 %6, %7
  br i1 %8, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %9 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %4, align 4
  %10 = sub i64 %vector_length, 1
  %11 = sub i64 %10, %9
  call void @builtin_range_check(i64 %11)
  %vector_data3 = getelementptr i64, ptr %4, i64 1
  %index_access4 = getelementptr ptr, ptr %vector_data3, i64 %9
  %12 = load i64, ptr %columns, align 4
  %13 = mul i64 %12, 1
  %14 = call ptr @vector_new(i64 %13)
  %vector_data5 = getelementptr i64, ptr %14, i64 1
  store i64 0, ptr %index_alloca9, align 4
  br label %cond6

next:                                             ; preds = %done8
  %15 = load i64, ptr %i, align 4
  %16 = add i64 %15, 1
  store i64 %16, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  ret ptr %4

cond6:                                            ; preds = %body7, %body2
  %index_value10 = load i64, ptr %index_alloca9, align 4
  %loop_cond11 = icmp ult i64 %index_value10, %12
  br i1 %loop_cond11, label %body7, label %done8

body7:                                            ; preds = %cond6
  %index_access12 = getelementptr i64, ptr %vector_data5, i64 %index_value10
  store i64 0, ptr %index_access12, align 4
  %next_index13 = add i64 %index_value10, 1
  store i64 %next_index13, ptr %index_alloca9, align 4
  br label %cond6

done8:                                            ; preds = %cond6
  store ptr %14, ptr %index_access4, align 8
  br label %next
}

define void @setElement(ptr %0, i64 %1, i64 %2, i64 %3) {
entry:
  %value = alloca i64, align 8
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %4 = load ptr, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  store i64 %3, ptr %value, align 4
  %5 = load i64, ptr %row, align 4
  %vector_length = load i64, ptr %4, align 4
  %6 = sub i64 %vector_length, 1
  %7 = sub i64 %6, %5
  call void @builtin_range_check(i64 %7)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %5
  %8 = load ptr, ptr %index_access, align 8
  %9 = load i64, ptr %column, align 4
  %vector_length1 = load i64, ptr %8, align 4
  %10 = sub i64 %vector_length1, 1
  %11 = sub i64 %10, %9
  call void @builtin_range_check(i64 %11)
  %vector_data2 = getelementptr i64, ptr %8, i64 1
  %index_access3 = getelementptr i64, ptr %vector_data2, i64 %9
  %12 = load i64, ptr %value, align 4
  store i64 %12, ptr %index_access3, align 4
  ret void
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %column = alloca i64, align 8
  %row = alloca i64, align 8
  %array = alloca ptr, align 8
  store ptr %0, ptr %array, align 8
  %3 = load ptr, ptr %array, align 8
  store i64 %1, ptr %row, align 4
  store i64 %2, ptr %column, align 4
  %4 = load i64, ptr %row, align 4
  %vector_length = load i64, ptr %3, align 4
  %5 = sub i64 %vector_length, 1
  %6 = sub i64 %5, %4
  call void @builtin_range_check(i64 %6)
  %vector_data = getelementptr i64, ptr %3, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %4
  %7 = load ptr, ptr %index_access, align 8
  %8 = load i64, ptr %column, align 4
  %vector_length1 = load i64, ptr %7, align 4
  %9 = sub i64 %vector_length1, 1
  %10 = sub i64 %9, %8
  call void @builtin_range_check(i64 %10)
  %vector_data2 = getelementptr i64, ptr %7, i64 1
  %index_access3 = getelementptr i64, ptr %vector_data2, i64 %8
  %11 = load i64, ptr %index_access3, align 4
  ret i64 %11
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %size_var94 = alloca i64, align 8
  %size_var60 = alloca i64, align 8
  %size_var = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1267704063, label %func_0_dispatch
    i64 399575402, label %func_1_dispatch
    i64 1503020561, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %input, i64 0
  %4 = load i64, ptr %3, align 4
  %5 = getelementptr ptr, ptr %3, i64 1
  %6 = load i64, ptr %5, align 4
  %7 = call ptr @initialize(i64 %4, i64 %6)
  store i64 0, ptr %size_var, align 4
  %vector_length = load i64, ptr %7, align 4
  %8 = load i64, ptr %size_var, align 4
  %9 = add i64 %8, %vector_length
  store i64 %9, ptr %size_var, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %vector_length1 = load i64, ptr %7, align 4
  %10 = icmp ult i64 %index, %vector_length1
  br i1 %10, label %body, label %end_for

next:                                             ; preds = %end_for9
  %index23 = load i64, ptr %index_ptr, align 4
  %11 = add i64 %index23, 1
  store i64 %11, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %vector_length2 = load i64, ptr %7, align 4
  %12 = sub i64 %vector_length2, 1
  %13 = sub i64 %12, %index
  call void @builtin_range_check(i64 %13)
  %vector_data = getelementptr i64, ptr %7, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %arr = load ptr, ptr %index_access, align 8
  %vector_length3 = load i64, ptr %arr, align 4
  %14 = load i64, ptr %size_var, align 4
  %15 = add i64 %14, %vector_length3
  store i64 %15, ptr %size_var, align 4
  %index_ptr4 = alloca i64, align 8
  store i64 0, ptr %index_ptr4, align 4
  %index5 = load i64, ptr %index_ptr4, align 4
  br label %cond6

end_for:                                          ; preds = %cond
  %16 = load i64, ptr %size_var, align 4
  %heap_size = add i64 %16, 1
  %17 = call ptr @heap_malloc(i64 %heap_size)
  %offset_var_no = alloca i64, align 8
  store i64 0, ptr %offset_var_no, align 4
  %vector_length24 = load i64, ptr %7, align 4
  %18 = load i64, ptr %offset_var_no, align 4
  %encode_value_ptr = getelementptr i64, ptr %17, i64 %18
  store i64 %vector_length24, ptr %encode_value_ptr, align 4
  %19 = add i64 %18, 1
  store i64 %19, ptr %offset_var_no, align 4
  %index_ptr25 = alloca i64, align 8
  store i64 0, ptr %index_ptr25, align 4
  %index26 = load i64, ptr %index_ptr25, align 4
  br label %cond27

cond6:                                            ; preds = %next7, %body
  %vector_length10 = load i64, ptr %7, align 4
  %20 = sub i64 %vector_length10, 1
  %21 = sub i64 %20, %index
  call void @builtin_range_check(i64 %21)
  %vector_data11 = getelementptr i64, ptr %7, i64 1
  %index_access12 = getelementptr ptr, ptr %vector_data11, i64 %index
  %arr13 = load ptr, ptr %index_access12, align 8
  %vector_length14 = load i64, ptr %arr13, align 4
  %22 = icmp ult i64 %index5, %vector_length14
  br i1 %22, label %body8, label %end_for9

next7:                                            ; preds = %body8
  %index22 = load i64, ptr %index_ptr4, align 4
  %23 = add i64 %index22, 1
  store i64 %23, ptr %index_ptr4, align 4
  br label %cond6

body8:                                            ; preds = %cond6
  %vector_length15 = load i64, ptr %7, align 4
  %24 = sub i64 %vector_length15, 1
  %25 = sub i64 %24, %index
  call void @builtin_range_check(i64 %25)
  %vector_data16 = getelementptr i64, ptr %7, i64 1
  %index_access17 = getelementptr ptr, ptr %vector_data16, i64 %index
  %arr18 = load ptr, ptr %index_access17, align 8
  %vector_length19 = load i64, ptr %arr18, align 4
  %26 = sub i64 %vector_length19, 1
  %27 = sub i64 %26, %index5
  call void @builtin_range_check(i64 %27)
  %vector_data20 = getelementptr i64, ptr %arr18, i64 1
  %index_access21 = getelementptr i64, ptr %vector_data20, i64 %index5
  %28 = load i64, ptr %size_var, align 4
  %29 = add i64 %28, 1
  store i64 %29, ptr %size_var, align 4
  br label %next7

end_for9:                                         ; preds = %cond6
  br label %next

cond27:                                           ; preds = %next28, %end_for
  %vector_length31 = load i64, ptr %7, align 4
  %30 = icmp ult i64 %index26, %vector_length31
  br i1 %30, label %body29, label %end_for30

next28:                                           ; preds = %end_for43
  %index58 = load i64, ptr %index_ptr25, align 4
  %31 = add i64 %index58, 1
  store i64 %31, ptr %index_ptr25, align 4
  br label %cond27

body29:                                           ; preds = %cond27
  %vector_length32 = load i64, ptr %7, align 4
  %32 = sub i64 %vector_length32, 1
  %33 = sub i64 %32, %index26
  call void @builtin_range_check(i64 %33)
  %vector_data33 = getelementptr i64, ptr %7, i64 1
  %index_access34 = getelementptr ptr, ptr %vector_data33, i64 %index26
  %arr35 = load ptr, ptr %index_access34, align 8
  %vector_length36 = load i64, ptr %arr35, align 4
  %34 = load i64, ptr %offset_var_no, align 4
  %encode_value_ptr37 = getelementptr i64, ptr %17, i64 %34
  store i64 %vector_length36, ptr %encode_value_ptr37, align 4
  %35 = add i64 %34, 1
  store i64 %35, ptr %offset_var_no, align 4
  %index_ptr38 = alloca i64, align 8
  store i64 0, ptr %index_ptr38, align 4
  %index39 = load i64, ptr %index_ptr38, align 4
  br label %cond40

end_for30:                                        ; preds = %cond27
  %36 = load i64, ptr %offset_var_no, align 4
  %37 = sub i64 %36, 0
  %38 = add i64 %37, 0
  %encode_value_ptr59 = getelementptr i64, ptr %17, i64 %38
  store i64 %16, ptr %encode_value_ptr59, align 4
  call void @set_tape_data(ptr %17, i64 %heap_size)
  ret void

cond40:                                           ; preds = %next41, %body29
  %vector_length44 = load i64, ptr %arr35, align 4
  %39 = sub i64 %vector_length44, 1
  %40 = sub i64 %39, %index26
  call void @builtin_range_check(i64 %40)
  %vector_data45 = getelementptr i64, ptr %arr35, i64 1
  %index_access46 = getelementptr i64, ptr %vector_data45, i64 %index26
  %arr47 = load ptr, ptr %index_access46, align 8
  %vector_length48 = load i64, ptr %arr47, align 4
  %41 = icmp ult i64 %index39, %vector_length48
  br i1 %41, label %body42, label %end_for43

next41:                                           ; preds = %body42
  %index57 = load i64, ptr %index_ptr38, align 4
  %42 = add i64 %index57, 1
  store i64 %42, ptr %index_ptr38, align 4
  br label %cond40

body42:                                           ; preds = %cond40
  %vector_length49 = load i64, ptr %arr35, align 4
  %43 = sub i64 %vector_length49, 1
  %44 = sub i64 %43, %index26
  call void @builtin_range_check(i64 %44)
  %vector_data50 = getelementptr i64, ptr %arr35, i64 1
  %index_access51 = getelementptr i64, ptr %vector_data50, i64 %index26
  %arr52 = load ptr, ptr %index_access51, align 8
  %vector_length53 = load i64, ptr %arr52, align 4
  %45 = sub i64 %vector_length53, 1
  %46 = sub i64 %45, %index39
  call void @builtin_range_check(i64 %46)
  %vector_data54 = getelementptr i64, ptr %arr52, i64 1
  %index_access55 = getelementptr i64, ptr %vector_data54, i64 %index39
  %47 = load i64, ptr %offset_var_no, align 4
  %encode_value_ptr56 = getelementptr i64, ptr %17, i64 %47
  store ptr %index_access55, ptr %encode_value_ptr56, align 8
  %48 = add i64 %47, 1
  store i64 %48, ptr %offset_var_no, align 4
  br label %next41

end_for43:                                        ; preds = %cond40
  br label %next28

func_1_dispatch:                                  ; preds = %entry
  %49 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %size_var60, align 4
  %vector_length61 = load i64, ptr %49, align 4
  %50 = load i64, ptr %size_var60, align 4
  %51 = add i64 %50, %vector_length61
  store i64 %51, ptr %size_var60, align 4
  %index_ptr62 = alloca i64, align 8
  store i64 0, ptr %index_ptr62, align 4
  %index63 = load i64, ptr %index_ptr62, align 4
  br label %cond64

cond64:                                           ; preds = %next65, %func_1_dispatch
  %vector_length68 = load i64, ptr %49, align 4
  %52 = icmp ult i64 %index63, %vector_length68
  br i1 %52, label %body66, label %end_for67

next65:                                           ; preds = %end_for79
  %index93 = load i64, ptr %index_ptr62, align 4
  %53 = add i64 %index93, 1
  store i64 %53, ptr %index_ptr62, align 4
  br label %cond64

body66:                                           ; preds = %cond64
  %vector_length69 = load i64, ptr %49, align 4
  %54 = sub i64 %vector_length69, 1
  %55 = sub i64 %54, %index63
  call void @builtin_range_check(i64 %55)
  %vector_data70 = getelementptr i64, ptr %49, i64 1
  %index_access71 = getelementptr ptr, ptr %vector_data70, i64 %index63
  %arr72 = load ptr, ptr %index_access71, align 8
  %vector_length73 = load i64, ptr %arr72, align 4
  %56 = load i64, ptr %size_var60, align 4
  %57 = add i64 %56, %vector_length73
  store i64 %57, ptr %size_var60, align 4
  %index_ptr74 = alloca i64, align 8
  store i64 0, ptr %index_ptr74, align 4
  %index75 = load i64, ptr %index_ptr74, align 4
  br label %cond76

end_for67:                                        ; preds = %cond64
  %58 = load i64, ptr %size_var60, align 4
  %59 = getelementptr ptr, ptr %49, i64 %58
  %60 = load i64, ptr %59, align 4
  %61 = getelementptr ptr, ptr %59, i64 1
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr ptr, ptr %61, i64 1
  %64 = load i64, ptr %63, align 4
  call void @setElement(ptr %49, i64 %60, i64 %62, i64 %64)
  %65 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %65, align 4
  call void @set_tape_data(ptr %65, i64 1)
  ret void

cond76:                                           ; preds = %next77, %body66
  %vector_length80 = load i64, ptr %49, align 4
  %66 = sub i64 %vector_length80, 1
  %67 = sub i64 %66, %index63
  call void @builtin_range_check(i64 %67)
  %vector_data81 = getelementptr i64, ptr %49, i64 1
  %index_access82 = getelementptr ptr, ptr %vector_data81, i64 %index63
  %arr83 = load ptr, ptr %index_access82, align 8
  %vector_length84 = load i64, ptr %arr83, align 4
  %68 = icmp ult i64 %index75, %vector_length84
  br i1 %68, label %body78, label %end_for79

next77:                                           ; preds = %body78
  %index92 = load i64, ptr %index_ptr74, align 4
  %69 = add i64 %index92, 1
  store i64 %69, ptr %index_ptr74, align 4
  br label %cond76

body78:                                           ; preds = %cond76
  %vector_length85 = load i64, ptr %49, align 4
  %70 = sub i64 %vector_length85, 1
  %71 = sub i64 %70, %index63
  call void @builtin_range_check(i64 %71)
  %vector_data86 = getelementptr i64, ptr %49, i64 1
  %index_access87 = getelementptr ptr, ptr %vector_data86, i64 %index63
  %arr88 = load ptr, ptr %index_access87, align 8
  %vector_length89 = load i64, ptr %arr88, align 4
  %72 = sub i64 %vector_length89, 1
  %73 = sub i64 %72, %index75
  call void @builtin_range_check(i64 %73)
  %vector_data90 = getelementptr i64, ptr %arr88, i64 1
  %index_access91 = getelementptr i64, ptr %vector_data90, i64 %index75
  %74 = load i64, ptr %size_var60, align 4
  %75 = add i64 %74, 1
  store i64 %75, ptr %size_var60, align 4
  br label %next77

end_for79:                                        ; preds = %cond76
  br label %next65

func_2_dispatch:                                  ; preds = %entry
  %76 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %size_var94, align 4
  %vector_length95 = load i64, ptr %76, align 4
  %77 = load i64, ptr %size_var94, align 4
  %78 = add i64 %77, %vector_length95
  store i64 %78, ptr %size_var94, align 4
  %index_ptr96 = alloca i64, align 8
  store i64 0, ptr %index_ptr96, align 4
  %index97 = load i64, ptr %index_ptr96, align 4
  br label %cond98

cond98:                                           ; preds = %next99, %func_2_dispatch
  %vector_length102 = load i64, ptr %76, align 4
  %79 = icmp ult i64 %index97, %vector_length102
  br i1 %79, label %body100, label %end_for101

next99:                                           ; preds = %end_for113
  %index127 = load i64, ptr %index_ptr96, align 4
  %80 = add i64 %index127, 1
  store i64 %80, ptr %index_ptr96, align 4
  br label %cond98

body100:                                          ; preds = %cond98
  %vector_length103 = load i64, ptr %76, align 4
  %81 = sub i64 %vector_length103, 1
  %82 = sub i64 %81, %index97
  call void @builtin_range_check(i64 %82)
  %vector_data104 = getelementptr i64, ptr %76, i64 1
  %index_access105 = getelementptr ptr, ptr %vector_data104, i64 %index97
  %arr106 = load ptr, ptr %index_access105, align 8
  %vector_length107 = load i64, ptr %arr106, align 4
  %83 = load i64, ptr %size_var94, align 4
  %84 = add i64 %83, %vector_length107
  store i64 %84, ptr %size_var94, align 4
  %index_ptr108 = alloca i64, align 8
  store i64 0, ptr %index_ptr108, align 4
  %index109 = load i64, ptr %index_ptr108, align 4
  br label %cond110

end_for101:                                       ; preds = %cond98
  %85 = load i64, ptr %size_var94, align 4
  %86 = getelementptr ptr, ptr %76, i64 %85
  %87 = load i64, ptr %86, align 4
  %88 = getelementptr ptr, ptr %86, i64 1
  %89 = load i64, ptr %88, align 4
  %90 = call i64 @getElement(ptr %76, i64 %87, i64 %89)
  %91 = call ptr @heap_malloc(i64 2)
  %encode_value_ptr128 = getelementptr i64, ptr %91, i64 0
  store i64 %90, ptr %encode_value_ptr128, align 4
  %encode_value_ptr129 = getelementptr i64, ptr %91, i64 1
  store i64 1, ptr %encode_value_ptr129, align 4
  call void @set_tape_data(ptr %91, i64 2)
  ret void

cond110:                                          ; preds = %next111, %body100
  %vector_length114 = load i64, ptr %76, align 4
  %92 = sub i64 %vector_length114, 1
  %93 = sub i64 %92, %index97
  call void @builtin_range_check(i64 %93)
  %vector_data115 = getelementptr i64, ptr %76, i64 1
  %index_access116 = getelementptr ptr, ptr %vector_data115, i64 %index97
  %arr117 = load ptr, ptr %index_access116, align 8
  %vector_length118 = load i64, ptr %arr117, align 4
  %94 = icmp ult i64 %index109, %vector_length118
  br i1 %94, label %body112, label %end_for113

next111:                                          ; preds = %body112
  %index126 = load i64, ptr %index_ptr108, align 4
  %95 = add i64 %index126, 1
  store i64 %95, ptr %index_ptr108, align 4
  br label %cond110

body112:                                          ; preds = %cond110
  %vector_length119 = load i64, ptr %76, align 4
  %96 = sub i64 %vector_length119, 1
  %97 = sub i64 %96, %index97
  call void @builtin_range_check(i64 %97)
  %vector_data120 = getelementptr i64, ptr %76, i64 1
  %index_access121 = getelementptr ptr, ptr %vector_data120, i64 %index97
  %arr122 = load ptr, ptr %index_access121, align 8
  %vector_length123 = load i64, ptr %arr122, align 4
  %98 = sub i64 %vector_length123, 1
  %99 = sub i64 %98, %index109
  call void @builtin_range_check(i64 %99)
  %vector_data124 = getelementptr i64, ptr %arr122, i64 1
  %index_access125 = getelementptr i64, ptr %vector_data124, i64 %index109
  %100 = load i64, ptr %size_var94, align 4
  %101 = add i64 %100, 1
  store i64 %101, ptr %size_var94, align 4
  br label %next111

end_for113:                                       ; preds = %cond110
  br label %next99
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
