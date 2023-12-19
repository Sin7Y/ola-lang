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
  %size_var91 = alloca i64, align 8
  %size_var57 = alloca i64, align 8
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
  %vector_length24 = load i64, ptr %7, align 4
  store i64 %vector_length24, ptr %17, align 4
  %18 = getelementptr ptr, ptr %17, i64 1
  %index_ptr25 = alloca i64, align 8
  store i64 0, ptr %index_ptr25, align 4
  %index26 = load i64, ptr %index_ptr25, align 4
  br label %cond27

cond6:                                            ; preds = %next7, %body
  %vector_length10 = load i64, ptr %7, align 4
  %19 = sub i64 %vector_length10, 1
  %20 = sub i64 %19, %index
  call void @builtin_range_check(i64 %20)
  %vector_data11 = getelementptr i64, ptr %7, i64 1
  %index_access12 = getelementptr ptr, ptr %vector_data11, i64 %index
  %arr13 = load ptr, ptr %index_access12, align 8
  %vector_length14 = load i64, ptr %arr13, align 4
  %21 = icmp ult i64 %index5, %vector_length14
  br i1 %21, label %body8, label %end_for9

next7:                                            ; preds = %body8
  %index22 = load i64, ptr %index_ptr4, align 4
  %22 = add i64 %index22, 1
  store i64 %22, ptr %index_ptr4, align 4
  br label %cond6

body8:                                            ; preds = %cond6
  %vector_length15 = load i64, ptr %7, align 4
  %23 = sub i64 %vector_length15, 1
  %24 = sub i64 %23, %index
  call void @builtin_range_check(i64 %24)
  %vector_data16 = getelementptr i64, ptr %7, i64 1
  %index_access17 = getelementptr ptr, ptr %vector_data16, i64 %index
  %arr18 = load ptr, ptr %index_access17, align 8
  %vector_length19 = load i64, ptr %arr18, align 4
  %25 = sub i64 %vector_length19, 1
  %26 = sub i64 %25, %index5
  call void @builtin_range_check(i64 %26)
  %vector_data20 = getelementptr i64, ptr %arr18, i64 1
  %index_access21 = getelementptr i64, ptr %vector_data20, i64 %index5
  %27 = load i64, ptr %size_var, align 4
  %28 = add i64 %27, 1
  store i64 %28, ptr %size_var, align 4
  br label %next7

end_for9:                                         ; preds = %cond6
  br label %next

cond27:                                           ; preds = %next28, %end_for
  %vector_length31 = load i64, ptr %7, align 4
  %29 = icmp ult i64 %index26, %vector_length31
  br i1 %29, label %body29, label %end_for30

next28:                                           ; preds = %end_for42
  %index56 = load i64, ptr %index_ptr25, align 4
  %30 = add i64 %index56, 1
  store i64 %30, ptr %index_ptr25, align 4
  br label %cond27

body29:                                           ; preds = %cond27
  %vector_length32 = load i64, ptr %7, align 4
  %31 = sub i64 %vector_length32, 1
  %32 = sub i64 %31, %index26
  call void @builtin_range_check(i64 %32)
  %vector_data33 = getelementptr i64, ptr %7, i64 1
  %index_access34 = getelementptr ptr, ptr %vector_data33, i64 %index26
  %arr35 = load ptr, ptr %index_access34, align 8
  %vector_length36 = load i64, ptr %arr35, align 4
  store i64 %vector_length36, ptr %18, align 4
  %33 = getelementptr ptr, ptr %18, i64 1
  %index_ptr37 = alloca i64, align 8
  store i64 0, ptr %index_ptr37, align 4
  %index38 = load i64, ptr %index_ptr37, align 4
  br label %cond39

end_for30:                                        ; preds = %cond27
  %34 = getelementptr ptr, ptr %17, i64 1
  store i64 %16, ptr %34, align 4
  call void @set_tape_data(ptr %17, i64 %heap_size)
  ret void

cond39:                                           ; preds = %next40, %body29
  %vector_length43 = load i64, ptr %arr35, align 4
  %35 = sub i64 %vector_length43, 1
  %36 = sub i64 %35, %index26
  call void @builtin_range_check(i64 %36)
  %vector_data44 = getelementptr i64, ptr %arr35, i64 1
  %index_access45 = getelementptr i64, ptr %vector_data44, i64 %index26
  %arr46 = load ptr, ptr %index_access45, align 8
  %vector_length47 = load i64, ptr %arr46, align 4
  %37 = icmp ult i64 %index38, %vector_length47
  br i1 %37, label %body41, label %end_for42

next40:                                           ; preds = %body41
  %index55 = load i64, ptr %index_ptr37, align 4
  %38 = add i64 %index55, 1
  store i64 %38, ptr %index_ptr37, align 4
  br label %cond39

body41:                                           ; preds = %cond39
  %vector_length48 = load i64, ptr %arr35, align 4
  %39 = sub i64 %vector_length48, 1
  %40 = sub i64 %39, %index26
  call void @builtin_range_check(i64 %40)
  %vector_data49 = getelementptr i64, ptr %arr35, i64 1
  %index_access50 = getelementptr i64, ptr %vector_data49, i64 %index26
  %arr51 = load ptr, ptr %index_access50, align 8
  %vector_length52 = load i64, ptr %arr51, align 4
  %41 = sub i64 %vector_length52, 1
  %42 = sub i64 %41, %index38
  call void @builtin_range_check(i64 %42)
  %vector_data53 = getelementptr i64, ptr %arr51, i64 1
  %index_access54 = getelementptr i64, ptr %vector_data53, i64 %index38
  store ptr %index_access54, ptr %33, align 8
  %43 = getelementptr ptr, ptr %33, i64 1
  br label %next40

end_for42:                                        ; preds = %cond39
  br label %next28

func_1_dispatch:                                  ; preds = %entry
  %44 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %size_var57, align 4
  %vector_length58 = load i64, ptr %44, align 4
  %45 = load i64, ptr %size_var57, align 4
  %46 = add i64 %45, %vector_length58
  store i64 %46, ptr %size_var57, align 4
  %index_ptr59 = alloca i64, align 8
  store i64 0, ptr %index_ptr59, align 4
  %index60 = load i64, ptr %index_ptr59, align 4
  br label %cond61

cond61:                                           ; preds = %next62, %func_1_dispatch
  %vector_length65 = load i64, ptr %44, align 4
  %47 = icmp ult i64 %index60, %vector_length65
  br i1 %47, label %body63, label %end_for64

next62:                                           ; preds = %end_for76
  %index90 = load i64, ptr %index_ptr59, align 4
  %48 = add i64 %index90, 1
  store i64 %48, ptr %index_ptr59, align 4
  br label %cond61

body63:                                           ; preds = %cond61
  %vector_length66 = load i64, ptr %44, align 4
  %49 = sub i64 %vector_length66, 1
  %50 = sub i64 %49, %index60
  call void @builtin_range_check(i64 %50)
  %vector_data67 = getelementptr i64, ptr %44, i64 1
  %index_access68 = getelementptr ptr, ptr %vector_data67, i64 %index60
  %arr69 = load ptr, ptr %index_access68, align 8
  %vector_length70 = load i64, ptr %arr69, align 4
  %51 = load i64, ptr %size_var57, align 4
  %52 = add i64 %51, %vector_length70
  store i64 %52, ptr %size_var57, align 4
  %index_ptr71 = alloca i64, align 8
  store i64 0, ptr %index_ptr71, align 4
  %index72 = load i64, ptr %index_ptr71, align 4
  br label %cond73

end_for64:                                        ; preds = %cond61
  %53 = load i64, ptr %size_var57, align 4
  %54 = getelementptr ptr, ptr %44, i64 %53
  %55 = load i64, ptr %54, align 4
  %56 = getelementptr ptr, ptr %54, i64 1
  %57 = load i64, ptr %56, align 4
  %58 = getelementptr ptr, ptr %56, i64 1
  %59 = load i64, ptr %58, align 4
  call void @setElement(ptr %44, i64 %55, i64 %57, i64 %59)
  %60 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %60, align 4
  call void @set_tape_data(ptr %60, i64 1)
  ret void

cond73:                                           ; preds = %next74, %body63
  %vector_length77 = load i64, ptr %44, align 4
  %61 = sub i64 %vector_length77, 1
  %62 = sub i64 %61, %index60
  call void @builtin_range_check(i64 %62)
  %vector_data78 = getelementptr i64, ptr %44, i64 1
  %index_access79 = getelementptr ptr, ptr %vector_data78, i64 %index60
  %arr80 = load ptr, ptr %index_access79, align 8
  %vector_length81 = load i64, ptr %arr80, align 4
  %63 = icmp ult i64 %index72, %vector_length81
  br i1 %63, label %body75, label %end_for76

next74:                                           ; preds = %body75
  %index89 = load i64, ptr %index_ptr71, align 4
  %64 = add i64 %index89, 1
  store i64 %64, ptr %index_ptr71, align 4
  br label %cond73

body75:                                           ; preds = %cond73
  %vector_length82 = load i64, ptr %44, align 4
  %65 = sub i64 %vector_length82, 1
  %66 = sub i64 %65, %index60
  call void @builtin_range_check(i64 %66)
  %vector_data83 = getelementptr i64, ptr %44, i64 1
  %index_access84 = getelementptr ptr, ptr %vector_data83, i64 %index60
  %arr85 = load ptr, ptr %index_access84, align 8
  %vector_length86 = load i64, ptr %arr85, align 4
  %67 = sub i64 %vector_length86, 1
  %68 = sub i64 %67, %index72
  call void @builtin_range_check(i64 %68)
  %vector_data87 = getelementptr i64, ptr %arr85, i64 1
  %index_access88 = getelementptr i64, ptr %vector_data87, i64 %index72
  %69 = load i64, ptr %size_var57, align 4
  %70 = add i64 %69, 1
  store i64 %70, ptr %size_var57, align 4
  br label %next74

end_for76:                                        ; preds = %cond73
  br label %next62

func_2_dispatch:                                  ; preds = %entry
  %71 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %size_var91, align 4
  %vector_length92 = load i64, ptr %71, align 4
  %72 = load i64, ptr %size_var91, align 4
  %73 = add i64 %72, %vector_length92
  store i64 %73, ptr %size_var91, align 4
  %index_ptr93 = alloca i64, align 8
  store i64 0, ptr %index_ptr93, align 4
  %index94 = load i64, ptr %index_ptr93, align 4
  br label %cond95

cond95:                                           ; preds = %next96, %func_2_dispatch
  %vector_length99 = load i64, ptr %71, align 4
  %74 = icmp ult i64 %index94, %vector_length99
  br i1 %74, label %body97, label %end_for98

next96:                                           ; preds = %end_for110
  %index124 = load i64, ptr %index_ptr93, align 4
  %75 = add i64 %index124, 1
  store i64 %75, ptr %index_ptr93, align 4
  br label %cond95

body97:                                           ; preds = %cond95
  %vector_length100 = load i64, ptr %71, align 4
  %76 = sub i64 %vector_length100, 1
  %77 = sub i64 %76, %index94
  call void @builtin_range_check(i64 %77)
  %vector_data101 = getelementptr i64, ptr %71, i64 1
  %index_access102 = getelementptr ptr, ptr %vector_data101, i64 %index94
  %arr103 = load ptr, ptr %index_access102, align 8
  %vector_length104 = load i64, ptr %arr103, align 4
  %78 = load i64, ptr %size_var91, align 4
  %79 = add i64 %78, %vector_length104
  store i64 %79, ptr %size_var91, align 4
  %index_ptr105 = alloca i64, align 8
  store i64 0, ptr %index_ptr105, align 4
  %index106 = load i64, ptr %index_ptr105, align 4
  br label %cond107

end_for98:                                        ; preds = %cond95
  %80 = load i64, ptr %size_var91, align 4
  %81 = getelementptr ptr, ptr %71, i64 %80
  %82 = load i64, ptr %81, align 4
  %83 = getelementptr ptr, ptr %81, i64 1
  %84 = load i64, ptr %83, align 4
  %85 = call i64 @getElement(ptr %71, i64 %82, i64 %84)
  %86 = call ptr @heap_malloc(i64 2)
  store i64 %85, ptr %86, align 4
  %87 = getelementptr ptr, ptr %86, i64 1
  store i64 1, ptr %87, align 4
  call void @set_tape_data(ptr %86, i64 2)
  ret void

cond107:                                          ; preds = %next108, %body97
  %vector_length111 = load i64, ptr %71, align 4
  %88 = sub i64 %vector_length111, 1
  %89 = sub i64 %88, %index94
  call void @builtin_range_check(i64 %89)
  %vector_data112 = getelementptr i64, ptr %71, i64 1
  %index_access113 = getelementptr ptr, ptr %vector_data112, i64 %index94
  %arr114 = load ptr, ptr %index_access113, align 8
  %vector_length115 = load i64, ptr %arr114, align 4
  %90 = icmp ult i64 %index106, %vector_length115
  br i1 %90, label %body109, label %end_for110

next108:                                          ; preds = %body109
  %index123 = load i64, ptr %index_ptr105, align 4
  %91 = add i64 %index123, 1
  store i64 %91, ptr %index_ptr105, align 4
  br label %cond107

body109:                                          ; preds = %cond107
  %vector_length116 = load i64, ptr %71, align 4
  %92 = sub i64 %vector_length116, 1
  %93 = sub i64 %92, %index94
  call void @builtin_range_check(i64 %93)
  %vector_data117 = getelementptr i64, ptr %71, i64 1
  %index_access118 = getelementptr ptr, ptr %vector_data117, i64 %index94
  %arr119 = load ptr, ptr %index_access118, align 8
  %vector_length120 = load i64, ptr %arr119, align 4
  %94 = sub i64 %vector_length120, 1
  %95 = sub i64 %94, %index106
  call void @builtin_range_check(i64 %95)
  %vector_data121 = getelementptr i64, ptr %arr119, i64 1
  %index_access122 = getelementptr i64, ptr %vector_data121, i64 %index106
  %96 = load i64, ptr %size_var91, align 4
  %97 = add i64 %96, 1
  store i64 %97, ptr %size_var91, align 4
  br label %next108

end_for110:                                       ; preds = %cond107
  br label %next96
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
