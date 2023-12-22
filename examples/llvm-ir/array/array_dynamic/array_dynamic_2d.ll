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
  %3 = call ptr @vector_new(i64 %2)
  %vector_data = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %4 = call ptr @vector_new(i64 0)
  store ptr %4, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %5 = load i64, ptr %i, align 4
  %6 = load i64, ptr %rows, align 4
  %7 = icmp ult i64 %5, %6
  br i1 %7, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %8 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %3, align 4
  %9 = sub i64 %vector_length, 1
  %10 = sub i64 %9, %8
  call void @builtin_range_check(i64 %10)
  %vector_data3 = getelementptr i64, ptr %3, i64 1
  %index_access4 = getelementptr ptr, ptr %vector_data3, i64 %8
  %11 = load i64, ptr %columns, align 4
  %12 = call ptr @vector_new(i64 %11)
  %vector_data5 = getelementptr i64, ptr %12, i64 1
  store i64 0, ptr %index_alloca9, align 4
  br label %cond6

next:                                             ; preds = %done8
  %13 = load i64, ptr %i, align 4
  %14 = add i64 %13, 1
  store i64 %14, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  ret ptr %3

cond6:                                            ; preds = %body7, %body2
  %index_value10 = load i64, ptr %index_alloca9, align 4
  %loop_cond11 = icmp ult i64 %index_value10, %11
  br i1 %loop_cond11, label %body7, label %done8

body7:                                            ; preds = %cond6
  %index_access12 = getelementptr i64, ptr %vector_data5, i64 %index_value10
  store i64 0, ptr %index_access12, align 4
  %next_index13 = add i64 %index_value10, 1
  store i64 %next_index13, ptr %index_alloca9, align 4
  br label %cond6

done8:                                            ; preds = %cond6
  store ptr %12, ptr %index_access4, align 8
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
  %index_ptr98 = alloca i64, align 8
  %index_ptr86 = alloca i64, align 8
  %array_ptr84 = alloca ptr, align 8
  %array_offset83 = alloca i64, align 8
  %index_ptr63 = alloca i64, align 8
  %index_ptr51 = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  %index_ptr31 = alloca i64, align 8
  %index_ptr19 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_size = alloca i64, align 8
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
  store i64 0, ptr %array_size, align 4
  %8 = load i64, ptr %array_size, align 4
  %9 = add i64 %8, 1
  store i64 %9, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %vector_length = load i64, ptr %7, align 4
  %10 = icmp ult i64 %index, %vector_length
  br i1 %10, label %body, label %end_for

next:                                             ; preds = %end_for6
  %index17 = load i64, ptr %index_ptr, align 4
  %11 = add i64 %index17, 1
  store i64 %11, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %12 = load i64, ptr %array_size, align 4
  %13 = add i64 %12, 1
  store i64 %13, ptr %array_size, align 4
  store i64 0, ptr %index_ptr1, align 4
  %index2 = load i64, ptr %index_ptr1, align 4
  br label %cond3

end_for:                                          ; preds = %cond
  %14 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %14, 1
  %15 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %16 = load i64, ptr %buffer_offset, align 4
  %17 = add i64 %16, 1
  store i64 %17, ptr %buffer_offset, align 4
  %18 = getelementptr ptr, ptr %15, i64 %16
  %vector_length18 = load i64, ptr %7, align 4
  store i64 %vector_length18, ptr %18, align 4
  store i64 0, ptr %index_ptr19, align 4
  %index20 = load i64, ptr %index_ptr19, align 4
  br label %cond21

cond3:                                            ; preds = %next4, %body
  %vector_length7 = load i64, ptr %7, align 4
  %19 = sub i64 %vector_length7, 1
  %20 = sub i64 %19, %index
  call void @builtin_range_check(i64 %20)
  %vector_data = getelementptr i64, ptr %7, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %arr = load ptr, ptr %index_access, align 8
  %vector_length8 = load i64, ptr %arr, align 4
  %21 = icmp ult i64 %index2, %vector_length8
  br i1 %21, label %body5, label %end_for6

next4:                                            ; preds = %body5
  %index16 = load i64, ptr %index_ptr1, align 4
  %22 = add i64 %index16, 1
  store i64 %22, ptr %index_ptr1, align 4
  br label %cond3

body5:                                            ; preds = %cond3
  %vector_length9 = load i64, ptr %7, align 4
  %23 = sub i64 %vector_length9, 1
  %24 = sub i64 %23, %index
  call void @builtin_range_check(i64 %24)
  %vector_data10 = getelementptr i64, ptr %7, i64 1
  %index_access11 = getelementptr ptr, ptr %vector_data10, i64 %index
  %arr12 = load ptr, ptr %index_access11, align 8
  %vector_length13 = load i64, ptr %arr12, align 4
  %25 = sub i64 %vector_length13, 1
  %26 = sub i64 %25, %index2
  call void @builtin_range_check(i64 %26)
  %vector_data14 = getelementptr i64, ptr %arr12, i64 1
  %index_access15 = getelementptr i64, ptr %vector_data14, i64 %index2
  %27 = load i64, ptr %array_size, align 4
  %28 = add i64 %27, 1
  store i64 %28, ptr %array_size, align 4
  br label %next4

end_for6:                                         ; preds = %cond3
  br label %next

cond21:                                           ; preds = %next22, %end_for
  %vector_length25 = load i64, ptr %7, align 4
  %29 = icmp ult i64 %index20, %vector_length25
  br i1 %29, label %body23, label %end_for24

next22:                                           ; preds = %end_for36
  %index50 = load i64, ptr %index_ptr19, align 4
  %30 = add i64 %index50, 1
  store i64 %30, ptr %index_ptr19, align 4
  br label %cond21

body23:                                           ; preds = %cond21
  %vector_length26 = load i64, ptr %7, align 4
  %31 = sub i64 %vector_length26, 1
  %32 = sub i64 %31, %index20
  call void @builtin_range_check(i64 %32)
  %vector_data27 = getelementptr i64, ptr %7, i64 1
  %index_access28 = getelementptr ptr, ptr %vector_data27, i64 %index20
  %arr29 = load ptr, ptr %index_access28, align 8
  %33 = load i64, ptr %buffer_offset, align 4
  %34 = add i64 %33, 1
  store i64 %34, ptr %buffer_offset, align 4
  %35 = getelementptr ptr, ptr %15, i64 %33
  %vector_length30 = load i64, ptr %arr29, align 4
  store i64 %vector_length30, ptr %35, align 4
  store i64 0, ptr %index_ptr31, align 4
  %index32 = load i64, ptr %index_ptr31, align 4
  br label %cond33

end_for24:                                        ; preds = %cond21
  %36 = load i64, ptr %buffer_offset, align 4
  %37 = getelementptr ptr, ptr %15, i64 %36
  store i64 %14, ptr %37, align 4
  call void @set_tape_data(ptr %15, i64 %heap_size)
  ret void

cond33:                                           ; preds = %next34, %body23
  %vector_length37 = load i64, ptr %arr29, align 4
  %38 = sub i64 %vector_length37, 1
  %39 = sub i64 %38, %index20
  call void @builtin_range_check(i64 %39)
  %vector_data38 = getelementptr i64, ptr %arr29, i64 1
  %index_access39 = getelementptr i64, ptr %vector_data38, i64 %index20
  %arr40 = load ptr, ptr %index_access39, align 8
  %vector_length41 = load i64, ptr %arr40, align 4
  %40 = icmp ult i64 %index32, %vector_length41
  br i1 %40, label %body35, label %end_for36

next34:                                           ; preds = %body35
  %index49 = load i64, ptr %index_ptr31, align 4
  %41 = add i64 %index49, 1
  store i64 %41, ptr %index_ptr31, align 4
  br label %cond33

body35:                                           ; preds = %cond33
  %vector_length42 = load i64, ptr %arr29, align 4
  %42 = sub i64 %vector_length42, 1
  %43 = sub i64 %42, %index20
  call void @builtin_range_check(i64 %43)
  %vector_data43 = getelementptr i64, ptr %arr29, i64 1
  %index_access44 = getelementptr i64, ptr %vector_data43, i64 %index20
  %arr45 = load ptr, ptr %index_access44, align 8
  %vector_length46 = load i64, ptr %arr45, align 4
  %44 = sub i64 %vector_length46, 1
  %45 = sub i64 %44, %index32
  call void @builtin_range_check(i64 %45)
  %vector_data47 = getelementptr i64, ptr %arr45, i64 1
  %index_access48 = getelementptr i64, ptr %vector_data47, i64 %index32
  %46 = load i64, ptr %buffer_offset, align 4
  %47 = getelementptr ptr, ptr %15, i64 %46
  store ptr %index_access48, ptr %47, align 8
  %48 = load i64, ptr %buffer_offset, align 4
  %49 = add i64 %48, 1
  store i64 %49, ptr %buffer_offset, align 4
  br label %next34

end_for36:                                        ; preds = %cond33
  br label %next22

func_1_dispatch:                                  ; preds = %entry
  %50 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %array_offset, align 4
  %51 = load i64, ptr %array_offset, align 4
  %array_length = load i64, ptr %50, align 4
  %52 = add i64 %51, 1
  store i64 %52, ptr %array_offset, align 4
  %53 = call ptr @vector_new(i64 %array_length)
  store ptr %53, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr51, align 4
  %index52 = load i64, ptr %index_ptr51, align 4
  br label %cond53

cond53:                                           ; preds = %next54, %func_1_dispatch
  %vector_length57 = load i64, ptr %array_ptr, align 4
  %54 = icmp ult i64 %index52, %vector_length57
  br i1 %54, label %body55, label %end_for56

next54:                                           ; preds = %end_for68
  %index82 = load i64, ptr %index_ptr51, align 4
  %55 = add i64 %index82, 1
  store i64 %55, ptr %index_ptr51, align 4
  br label %cond53

body55:                                           ; preds = %cond53
  %56 = load i64, ptr %array_offset, align 4
  %array_length58 = load i64, ptr %50, align 4
  %57 = add i64 %56, 1
  store i64 %57, ptr %array_offset, align 4
  %58 = call ptr @vector_new(i64 %array_length58)
  %59 = load ptr, ptr %array_ptr, align 8
  %vector_length59 = load i64, ptr %59, align 4
  %60 = sub i64 %vector_length59, 1
  %61 = sub i64 %60, %index52
  call void @builtin_range_check(i64 %61)
  %vector_data60 = getelementptr i64, ptr %59, i64 1
  %index_access61 = getelementptr ptr, ptr %vector_data60, i64 %index52
  %arr62 = load ptr, ptr %index_access61, align 8
  store ptr %arr62, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr63, align 4
  %index64 = load i64, ptr %index_ptr63, align 4
  br label %cond65

end_for56:                                        ; preds = %cond53
  %62 = load ptr, ptr %array_ptr, align 8
  %63 = load i64, ptr %array_offset, align 4
  %64 = getelementptr ptr, ptr %50, i64 %63
  %65 = load i64, ptr %64, align 4
  %66 = getelementptr ptr, ptr %64, i64 1
  %67 = load i64, ptr %66, align 4
  %68 = getelementptr ptr, ptr %66, i64 1
  %69 = load i64, ptr %68, align 4
  call void @setElement(ptr %62, i64 %65, i64 %67, i64 %69)
  %70 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %70, align 4
  call void @set_tape_data(ptr %70, i64 1)
  ret void

cond65:                                           ; preds = %next66, %body55
  %vector_length69 = load i64, ptr %array_ptr, align 4
  %71 = sub i64 %vector_length69, 1
  %72 = sub i64 %71, %index52
  call void @builtin_range_check(i64 %72)
  %vector_data70 = getelementptr i64, ptr %array_ptr, i64 1
  %index_access71 = getelementptr ptr, ptr %vector_data70, i64 %index52
  %arr72 = load ptr, ptr %index_access71, align 8
  %vector_length73 = load i64, ptr %arr72, align 4
  %73 = icmp ult i64 %index64, %vector_length73
  br i1 %73, label %body67, label %end_for68

next66:                                           ; preds = %body67
  %index81 = load i64, ptr %index_ptr63, align 4
  %74 = add i64 %index81, 1
  store i64 %74, ptr %index_ptr63, align 4
  br label %cond65

body67:                                           ; preds = %cond65
  %75 = load i64, ptr %50, align 4
  %76 = load ptr, ptr %array_ptr, align 8
  %vector_length74 = load i64, ptr %76, align 4
  %77 = sub i64 %vector_length74, 1
  %78 = sub i64 %77, %index52
  call void @builtin_range_check(i64 %78)
  %vector_data75 = getelementptr i64, ptr %76, i64 1
  %index_access76 = getelementptr ptr, ptr %vector_data75, i64 %index52
  %arr77 = load ptr, ptr %index_access76, align 8
  %vector_length78 = load i64, ptr %arr77, align 4
  %79 = sub i64 %vector_length78, 1
  %80 = sub i64 %79, %index64
  call void @builtin_range_check(i64 %80)
  %vector_data79 = getelementptr i64, ptr %arr77, i64 1
  %index_access80 = getelementptr i64, ptr %vector_data79, i64 %index64
  store i64 %75, ptr %index_access80, align 4
  %81 = add i64 1, %56
  store i64 %81, ptr %array_offset, align 4
  br label %next66

end_for68:                                        ; preds = %cond65
  br label %next54

func_2_dispatch:                                  ; preds = %entry
  %82 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %array_offset83, align 4
  %83 = load i64, ptr %array_offset83, align 4
  %array_length85 = load i64, ptr %82, align 4
  %84 = add i64 %83, 1
  store i64 %84, ptr %array_offset83, align 4
  %85 = call ptr @vector_new(i64 %array_length85)
  store ptr %85, ptr %array_ptr84, align 8
  store i64 0, ptr %index_ptr86, align 4
  %index87 = load i64, ptr %index_ptr86, align 4
  br label %cond88

cond88:                                           ; preds = %next89, %func_2_dispatch
  %vector_length92 = load i64, ptr %array_ptr84, align 4
  %86 = icmp ult i64 %index87, %vector_length92
  br i1 %86, label %body90, label %end_for91

next89:                                           ; preds = %end_for103
  %index117 = load i64, ptr %index_ptr86, align 4
  %87 = add i64 %index117, 1
  store i64 %87, ptr %index_ptr86, align 4
  br label %cond88

body90:                                           ; preds = %cond88
  %88 = load i64, ptr %array_offset83, align 4
  %array_length93 = load i64, ptr %82, align 4
  %89 = add i64 %88, 1
  store i64 %89, ptr %array_offset83, align 4
  %90 = call ptr @vector_new(i64 %array_length93)
  %91 = load ptr, ptr %array_ptr84, align 8
  %vector_length94 = load i64, ptr %91, align 4
  %92 = sub i64 %vector_length94, 1
  %93 = sub i64 %92, %index87
  call void @builtin_range_check(i64 %93)
  %vector_data95 = getelementptr i64, ptr %91, i64 1
  %index_access96 = getelementptr ptr, ptr %vector_data95, i64 %index87
  %arr97 = load ptr, ptr %index_access96, align 8
  store ptr %arr97, ptr %array_ptr84, align 8
  store i64 0, ptr %index_ptr98, align 4
  %index99 = load i64, ptr %index_ptr98, align 4
  br label %cond100

end_for91:                                        ; preds = %cond88
  %94 = load ptr, ptr %array_ptr84, align 8
  %95 = load i64, ptr %array_offset83, align 4
  %96 = getelementptr ptr, ptr %82, i64 %95
  %97 = load i64, ptr %96, align 4
  %98 = getelementptr ptr, ptr %96, i64 1
  %99 = load i64, ptr %98, align 4
  %100 = call i64 @getElement(ptr %94, i64 %97, i64 %99)
  %101 = call ptr @heap_malloc(i64 2)
  store i64 %100, ptr %101, align 4
  %102 = getelementptr ptr, ptr %101, i64 1
  store i64 1, ptr %102, align 4
  call void @set_tape_data(ptr %101, i64 2)
  ret void

cond100:                                          ; preds = %next101, %body90
  %vector_length104 = load i64, ptr %array_ptr84, align 4
  %103 = sub i64 %vector_length104, 1
  %104 = sub i64 %103, %index87
  call void @builtin_range_check(i64 %104)
  %vector_data105 = getelementptr i64, ptr %array_ptr84, i64 1
  %index_access106 = getelementptr ptr, ptr %vector_data105, i64 %index87
  %arr107 = load ptr, ptr %index_access106, align 8
  %vector_length108 = load i64, ptr %arr107, align 4
  %105 = icmp ult i64 %index99, %vector_length108
  br i1 %105, label %body102, label %end_for103

next101:                                          ; preds = %body102
  %index116 = load i64, ptr %index_ptr98, align 4
  %106 = add i64 %index116, 1
  store i64 %106, ptr %index_ptr98, align 4
  br label %cond100

body102:                                          ; preds = %cond100
  %107 = load i64, ptr %82, align 4
  %108 = load ptr, ptr %array_ptr84, align 8
  %vector_length109 = load i64, ptr %108, align 4
  %109 = sub i64 %vector_length109, 1
  %110 = sub i64 %109, %index87
  call void @builtin_range_check(i64 %110)
  %vector_data110 = getelementptr i64, ptr %108, i64 1
  %index_access111 = getelementptr ptr, ptr %vector_data110, i64 %index87
  %arr112 = load ptr, ptr %index_access111, align 8
  %vector_length113 = load i64, ptr %arr112, align 4
  %111 = sub i64 %vector_length113, 1
  %112 = sub i64 %111, %index99
  call void @builtin_range_check(i64 %112)
  %vector_data114 = getelementptr i64, ptr %arr112, i64 1
  %index_access115 = getelementptr i64, ptr %vector_data114, i64 %index99
  store i64 %107, ptr %index_access115, align 4
  %113 = add i64 1, %88
  store i64 %113, ptr %array_offset83, align 4
  br label %next101

end_for103:                                       ; preds = %cond100
  br label %next89
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
