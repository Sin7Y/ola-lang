; ModuleID = 'DynamicTwoDimensionalArrayInMemory'
source_filename = "array_dynamic_address"

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

define ptr @address_outer_dynamic(ptr %0) {
entry:
  %a = alloca ptr, align 8
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  ret ptr %1
}

define ptr @address_inner_dynamic(ptr %0) {
entry:
  %a = alloca ptr, align 8
  store ptr %0, ptr %a, align 8
  %1 = load ptr, ptr %a, align 8
  ret ptr %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr110 = alloca i64, align 8
  %index_ptr101 = alloca i64, align 8
  %buffer_offset100 = alloca i64, align 8
  %index_ptr83 = alloca i64, align 8
  %index_ptr77 = alloca i64, align 8
  %array_size76 = alloca i64, align 8
  %index_ptr60 = alloca i64, align 8
  %index_ptr52 = alloca i64, align 8
  %array_ptr51 = alloca ptr, align 8
  %array_offset50 = alloca i64, align 8
  %index_ptr38 = alloca i64, align 8
  %index_ptr31 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr18 = alloca i64, align 8
  %index_ptr11 = alloca i64, align 8
  %array_size = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 4205487845, label %func_0_dispatch
    i64 781825070, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %array_offset, align 4
  %4 = load i64, ptr %array_offset, align 4
  %array_length = load i64, ptr %3, align 4
  %5 = add i64 %4, 1
  store i64 %5, ptr %array_offset, align 4
  %6 = call ptr @vector_new(i64 %array_length)
  store ptr %6, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %vector_length = load i64, ptr %array_ptr, align 4
  %7 = icmp ult i64 %index, %vector_length
  br i1 %7, label %body, label %end_for

next:                                             ; preds = %end_for6
  %index10 = load i64, ptr %index_ptr, align 4
  %8 = add i64 %index10, 1
  store i64 %8, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %9 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr1, align 4
  %index2 = load i64, ptr %index_ptr1, align 4
  br label %cond3

end_for:                                          ; preds = %cond
  %10 = load ptr, ptr %array_ptr, align 8
  %11 = load i64, ptr %array_offset, align 4
  %12 = call ptr @address_outer_dynamic(ptr %10)
  store i64 0, ptr %array_size, align 4
  %13 = load i64, ptr %array_size, align 4
  %14 = add i64 %13, 1
  store i64 %14, ptr %array_size, align 4
  store i64 0, ptr %index_ptr11, align 4
  %index12 = load i64, ptr %index_ptr11, align 4
  br label %cond13

cond3:                                            ; preds = %next4, %body
  %15 = icmp ult i64 %index2, 2
  br i1 %15, label %body5, label %end_for6

next4:                                            ; preds = %body5
  %index9 = load i64, ptr %index_ptr1, align 4
  %16 = add i64 %index9, 1
  store i64 %16, ptr %index_ptr1, align 4
  br label %cond3

body5:                                            ; preds = %cond3
  %17 = load ptr, ptr %array_ptr, align 8
  %vector_length7 = load i64, ptr %17, align 4
  %18 = sub i64 %vector_length7, 1
  %19 = sub i64 %18, %index
  call void @builtin_range_check(i64 %19)
  %vector_data = getelementptr i64, ptr %17, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %20 = sub i64 1, %index2
  call void @builtin_range_check(i64 %20)
  %index_access8 = getelementptr [2 x ptr], ptr %index_access, i64 %index2
  store ptr %3, ptr %index_access8, align 8
  %21 = add i64 4, %9
  store i64 %21, ptr %array_offset, align 4
  br label %next4

end_for6:                                         ; preds = %cond3
  br label %next

cond13:                                           ; preds = %next14, %end_for
  %vector_length17 = load i64, ptr %12, align 4
  %22 = icmp ult i64 %index12, %vector_length17
  br i1 %22, label %body15, label %end_for16

next14:                                           ; preds = %end_for23
  %index29 = load i64, ptr %index_ptr11, align 4
  %23 = add i64 %index29, 1
  store i64 %23, ptr %index_ptr11, align 4
  br label %cond13

body15:                                           ; preds = %cond13
  store i64 0, ptr %index_ptr18, align 4
  %index19 = load i64, ptr %index_ptr18, align 4
  br label %cond20

end_for16:                                        ; preds = %cond13
  %24 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %24, 1
  %25 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %26 = load i64, ptr %buffer_offset, align 4
  %27 = add i64 %26, 1
  store i64 %27, ptr %buffer_offset, align 4
  %28 = getelementptr ptr, ptr %25, i64 %26
  %vector_length30 = load i64, ptr %12, align 4
  store i64 %vector_length30, ptr %28, align 4
  store i64 0, ptr %index_ptr31, align 4
  %index32 = load i64, ptr %index_ptr31, align 4
  br label %cond33

cond20:                                           ; preds = %next21, %body15
  %29 = icmp ult i64 %index19, 2
  br i1 %29, label %body22, label %end_for23

next21:                                           ; preds = %body22
  %index28 = load i64, ptr %index_ptr18, align 4
  %30 = add i64 %index28, 1
  store i64 %30, ptr %index_ptr18, align 4
  br label %cond20

body22:                                           ; preds = %cond20
  %vector_length24 = load i64, ptr %12, align 4
  %31 = sub i64 %vector_length24, 1
  %32 = sub i64 %31, %index12
  call void @builtin_range_check(i64 %32)
  %vector_data25 = getelementptr i64, ptr %12, i64 1
  %index_access26 = getelementptr ptr, ptr %vector_data25, i64 %index12
  %33 = sub i64 1, %index19
  call void @builtin_range_check(i64 %33)
  %index_access27 = getelementptr [2 x ptr], ptr %index_access26, i64 %index19
  %34 = load i64, ptr %array_size, align 4
  %35 = add i64 %34, 4
  store i64 %35, ptr %array_size, align 4
  br label %next21

end_for23:                                        ; preds = %cond20
  br label %next14

cond33:                                           ; preds = %next34, %end_for16
  %vector_length37 = load i64, ptr %12, align 4
  %36 = icmp ult i64 %index32, %vector_length37
  br i1 %36, label %body35, label %end_for36

next34:                                           ; preds = %end_for43
  %index49 = load i64, ptr %index_ptr31, align 4
  %37 = add i64 %index49, 1
  store i64 %37, ptr %index_ptr31, align 4
  br label %cond33

body35:                                           ; preds = %cond33
  store i64 0, ptr %index_ptr38, align 4
  %index39 = load i64, ptr %index_ptr38, align 4
  br label %cond40

end_for36:                                        ; preds = %cond33
  %38 = load i64, ptr %buffer_offset, align 4
  %39 = getelementptr ptr, ptr %25, i64 %38
  store i64 %24, ptr %39, align 4
  call void @set_tape_data(ptr %25, i64 %heap_size)
  ret void

cond40:                                           ; preds = %next41, %body35
  %40 = icmp ult i64 %index39, 2
  br i1 %40, label %body42, label %end_for43

next41:                                           ; preds = %body42
  %index48 = load i64, ptr %index_ptr38, align 4
  %41 = add i64 %index48, 1
  store i64 %41, ptr %index_ptr38, align 4
  br label %cond40

body42:                                           ; preds = %cond40
  %vector_length44 = load i64, ptr %12, align 4
  %42 = sub i64 %vector_length44, 1
  %43 = sub i64 %42, %index32
  call void @builtin_range_check(i64 %43)
  %vector_data45 = getelementptr i64, ptr %12, i64 1
  %index_access46 = getelementptr ptr, ptr %vector_data45, i64 %index32
  %44 = sub i64 1, %index39
  call void @builtin_range_check(i64 %44)
  %index_access47 = getelementptr [2 x ptr], ptr %index_access46, i64 %index39
  %45 = load i64, ptr %buffer_offset, align 4
  %46 = getelementptr ptr, ptr %25, i64 %45
  %47 = getelementptr i64, ptr %index_access47, i64 0
  %48 = load i64, ptr %47, align 4
  %49 = getelementptr i64, ptr %46, i64 0
  store i64 %48, ptr %49, align 4
  %50 = getelementptr i64, ptr %index_access47, i64 1
  %51 = load i64, ptr %50, align 4
  %52 = getelementptr i64, ptr %46, i64 1
  store i64 %51, ptr %52, align 4
  %53 = getelementptr i64, ptr %index_access47, i64 2
  %54 = load i64, ptr %53, align 4
  %55 = getelementptr i64, ptr %46, i64 2
  store i64 %54, ptr %55, align 4
  %56 = getelementptr i64, ptr %index_access47, i64 3
  %57 = load i64, ptr %56, align 4
  %58 = getelementptr i64, ptr %46, i64 3
  store i64 %57, ptr %58, align 4
  %59 = load i64, ptr %buffer_offset, align 4
  %60 = add i64 %59, 4
  store i64 %60, ptr %buffer_offset, align 4
  br label %next41

end_for43:                                        ; preds = %cond40
  br label %next34

func_1_dispatch:                                  ; preds = %entry
  %61 = getelementptr ptr, ptr %input, i64 0
  store i64 0, ptr %array_offset50, align 4
  store ptr null, ptr %array_ptr51, align 8
  %62 = load i64, ptr %array_offset50, align 4
  store i64 0, ptr %index_ptr52, align 4
  %index53 = load i64, ptr %index_ptr52, align 4
  br label %cond54

cond54:                                           ; preds = %next55, %func_1_dispatch
  %63 = icmp ult i64 %index53, 2
  br i1 %63, label %body56, label %end_for57

next55:                                           ; preds = %end_for65
  %index75 = load i64, ptr %index_ptr52, align 4
  %64 = add i64 %index75, 1
  store i64 %64, ptr %index_ptr52, align 4
  br label %cond54

body56:                                           ; preds = %cond54
  %65 = load i64, ptr %array_offset50, align 4
  %array_length58 = load i64, ptr %61, align 4
  %66 = add i64 %65, 1
  store i64 %66, ptr %array_offset50, align 4
  %67 = call ptr @vector_new(i64 %array_length58)
  %68 = load ptr, ptr %array_ptr51, align 8
  %69 = sub i64 1, %index53
  call void @builtin_range_check(i64 %69)
  %index_access59 = getelementptr ptr, ptr %68, i64 %index53
  %arr = load ptr, ptr %index_access59, align 8
  store ptr %arr, ptr %array_ptr51, align 8
  store i64 0, ptr %index_ptr60, align 4
  %index61 = load i64, ptr %index_ptr60, align 4
  br label %cond62

end_for57:                                        ; preds = %cond54
  %70 = load ptr, ptr %array_ptr51, align 8
  %71 = load i64, ptr %array_offset50, align 4
  %72 = call ptr @address_inner_dynamic(ptr %70)
  store i64 0, ptr %array_size76, align 4
  store i64 0, ptr %index_ptr77, align 4
  %index78 = load i64, ptr %index_ptr77, align 4
  br label %cond79

cond62:                                           ; preds = %next63, %body56
  %73 = sub i64 1, %index53
  call void @builtin_range_check(i64 %73)
  %index_access66 = getelementptr ptr, ptr %array_ptr51, i64 %index53
  %arr67 = load ptr, ptr %index_access66, align 8
  %vector_length68 = load i64, ptr %arr67, align 4
  %74 = icmp ult i64 %index61, %vector_length68
  br i1 %74, label %body64, label %end_for65

next63:                                           ; preds = %body64
  %index74 = load i64, ptr %index_ptr60, align 4
  %75 = add i64 %index74, 1
  store i64 %75, ptr %index_ptr60, align 4
  br label %cond62

body64:                                           ; preds = %cond62
  %76 = load ptr, ptr %array_ptr51, align 8
  %77 = sub i64 1, %index53
  call void @builtin_range_check(i64 %77)
  %index_access69 = getelementptr ptr, ptr %76, i64 %index53
  %arr70 = load ptr, ptr %index_access69, align 8
  %vector_length71 = load i64, ptr %arr70, align 4
  %78 = sub i64 %vector_length71, 1
  %79 = sub i64 %78, %index61
  call void @builtin_range_check(i64 %79)
  %vector_data72 = getelementptr i64, ptr %arr70, i64 1
  %index_access73 = getelementptr ptr, ptr %vector_data72, i64 %index61
  store ptr %61, ptr %index_access73, align 8
  %80 = add i64 4, %65
  store i64 %80, ptr %array_offset50, align 4
  br label %next63

end_for65:                                        ; preds = %cond62
  br label %next55

cond79:                                           ; preds = %next80, %end_for57
  %81 = icmp ult i64 %index78, 2
  br i1 %81, label %body81, label %end_for82

next80:                                           ; preds = %end_for88
  %index98 = load i64, ptr %index_ptr77, align 4
  %82 = add i64 %index98, 1
  store i64 %82, ptr %index_ptr77, align 4
  br label %cond79

body81:                                           ; preds = %cond79
  %83 = load i64, ptr %array_size76, align 4
  %84 = add i64 %83, 1
  store i64 %84, ptr %array_size76, align 4
  store i64 0, ptr %index_ptr83, align 4
  %index84 = load i64, ptr %index_ptr83, align 4
  br label %cond85

end_for82:                                        ; preds = %cond79
  %85 = load i64, ptr %array_size76, align 4
  %heap_size99 = add i64 %85, 1
  %86 = call ptr @heap_malloc(i64 %heap_size99)
  store i64 0, ptr %buffer_offset100, align 4
  store i64 0, ptr %index_ptr101, align 4
  %index102 = load i64, ptr %index_ptr101, align 4
  br label %cond103

cond85:                                           ; preds = %next86, %body81
  %87 = sub i64 1, %index78
  call void @builtin_range_check(i64 %87)
  %index_access89 = getelementptr ptr, ptr %72, i64 %index78
  %arr90 = load ptr, ptr %index_access89, align 8
  %vector_length91 = load i64, ptr %arr90, align 4
  %88 = icmp ult i64 %index84, %vector_length91
  br i1 %88, label %body87, label %end_for88

next86:                                           ; preds = %body87
  %index97 = load i64, ptr %index_ptr83, align 4
  %89 = add i64 %index97, 1
  store i64 %89, ptr %index_ptr83, align 4
  br label %cond85

body87:                                           ; preds = %cond85
  %90 = sub i64 1, %index78
  call void @builtin_range_check(i64 %90)
  %index_access92 = getelementptr ptr, ptr %72, i64 %index78
  %arr93 = load ptr, ptr %index_access92, align 8
  %vector_length94 = load i64, ptr %arr93, align 4
  %91 = sub i64 %vector_length94, 1
  %92 = sub i64 %91, %index84
  call void @builtin_range_check(i64 %92)
  %vector_data95 = getelementptr i64, ptr %arr93, i64 1
  %index_access96 = getelementptr ptr, ptr %vector_data95, i64 %index84
  %93 = load i64, ptr %array_size76, align 4
  %94 = add i64 %93, 4
  store i64 %94, ptr %array_size76, align 4
  br label %next86

end_for88:                                        ; preds = %cond85
  br label %next80

cond103:                                          ; preds = %next104, %end_for82
  %95 = icmp ult i64 %index102, 2
  br i1 %95, label %body105, label %end_for106

next104:                                          ; preds = %end_for115
  %index129 = load i64, ptr %index_ptr101, align 4
  %96 = add i64 %index129, 1
  store i64 %96, ptr %index_ptr101, align 4
  br label %cond103

body105:                                          ; preds = %cond103
  %97 = sub i64 1, %index102
  call void @builtin_range_check(i64 %97)
  %index_access107 = getelementptr ptr, ptr %72, i64 %index102
  %arr108 = load ptr, ptr %index_access107, align 8
  %98 = load i64, ptr %buffer_offset100, align 4
  %99 = add i64 %98, 1
  store i64 %99, ptr %buffer_offset100, align 4
  %100 = getelementptr ptr, ptr %86, i64 %98
  %vector_length109 = load i64, ptr %arr108, align 4
  store i64 %vector_length109, ptr %100, align 4
  store i64 0, ptr %index_ptr110, align 4
  %index111 = load i64, ptr %index_ptr110, align 4
  br label %cond112

end_for106:                                       ; preds = %cond103
  %101 = load i64, ptr %buffer_offset100, align 4
  %102 = getelementptr ptr, ptr %86, i64 %101
  store i64 %85, ptr %102, align 4
  call void @set_tape_data(ptr %86, i64 %heap_size99)
  ret void

cond112:                                          ; preds = %next113, %body105
  %vector_length116 = load i64, ptr %arr108, align 4
  %103 = sub i64 %vector_length116, 1
  %104 = sub i64 %103, %index102
  call void @builtin_range_check(i64 %104)
  %vector_data117 = getelementptr i64, ptr %arr108, i64 1
  %index_access118 = getelementptr ptr, ptr %vector_data117, i64 %index102
  %arr119 = load ptr, ptr %index_access118, align 8
  %vector_length120 = load i64, ptr %arr119, align 4
  %105 = icmp ult i64 %index111, %vector_length120
  br i1 %105, label %body114, label %end_for115

next113:                                          ; preds = %body114
  %index128 = load i64, ptr %index_ptr110, align 4
  %106 = add i64 %index128, 1
  store i64 %106, ptr %index_ptr110, align 4
  br label %cond112

body114:                                          ; preds = %cond112
  %vector_length121 = load i64, ptr %arr108, align 4
  %107 = sub i64 %vector_length121, 1
  %108 = sub i64 %107, %index102
  call void @builtin_range_check(i64 %108)
  %vector_data122 = getelementptr i64, ptr %arr108, i64 1
  %index_access123 = getelementptr ptr, ptr %vector_data122, i64 %index102
  %arr124 = load ptr, ptr %index_access123, align 8
  %vector_length125 = load i64, ptr %arr124, align 4
  %109 = sub i64 %vector_length125, 1
  %110 = sub i64 %109, %index111
  call void @builtin_range_check(i64 %110)
  %vector_data126 = getelementptr i64, ptr %arr124, i64 1
  %index_access127 = getelementptr ptr, ptr %vector_data126, i64 %index111
  %111 = load i64, ptr %buffer_offset100, align 4
  %112 = getelementptr ptr, ptr %86, i64 %111
  %113 = getelementptr i64, ptr %index_access127, i64 0
  %114 = load i64, ptr %113, align 4
  %115 = getelementptr i64, ptr %112, i64 0
  store i64 %114, ptr %115, align 4
  %116 = getelementptr i64, ptr %index_access127, i64 1
  %117 = load i64, ptr %116, align 4
  %118 = getelementptr i64, ptr %112, i64 1
  store i64 %117, ptr %118, align 4
  %119 = getelementptr i64, ptr %index_access127, i64 2
  %120 = load i64, ptr %119, align 4
  %121 = getelementptr i64, ptr %112, i64 2
  store i64 %120, ptr %121, align 4
  %122 = getelementptr i64, ptr %index_access127, i64 3
  %123 = load i64, ptr %122, align 4
  %124 = getelementptr i64, ptr %112, i64 3
  store i64 %123, ptr %124, align 4
  %125 = load i64, ptr %buffer_offset100, align 4
  %126 = add i64 %125, 4
  store i64 %126, ptr %buffer_offset100, align 4
  br label %next113

end_for115:                                       ; preds = %cond112
  br label %next104
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
