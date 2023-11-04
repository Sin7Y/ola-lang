; ModuleID = 'ArraySortExample'
source_filename = "examples/source/array/array_sort.ola"

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

define void @test() {
entry:
  %0 = call i64 @vector_new(i64 10)
  %heap_start = sub i64 %0, 10
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %elemptr0 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 0
  store i64 3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 1
  store i64 4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 2
  store i64 5, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 3
  store i64 1, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 4
  store i64 7, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 5
  store i64 9, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 6
  store i64 0, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 7
  store i64 2, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 9
  store i64 6, ptr %elemptr9, align 4
  %1 = call ptr @array_sort_test(ptr %heap_to_ptr)
  %length = load i64, ptr %1, align 4
  %2 = sub i64 %length, 1
  %3 = sub i64 %2, 0
  call void @builtin_range_check(i64 %3)
  %4 = ptrtoint ptr %1 to i64
  %5 = add i64 %4, 1
  %vector_data = inttoptr i64 %5 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  %length1 = load i64, ptr %1, align 4
  %6 = sub i64 %length1, 1
  %7 = sub i64 %6, 0
  call void @builtin_range_check(i64 %7)
  %8 = ptrtoint ptr %1 to i64
  %9 = add i64 %8, 1
  %vector_data2 = inttoptr i64 %9 to ptr
  %index_access3 = getelementptr i64, ptr %vector_data2, i64 0
  %10 = load i64, ptr %index_access3, align 4
  %11 = add i64 %10, 1
  call void @builtin_range_check(i64 %11)
  store i64 %11, ptr %index_access, align 4
  %length4 = load i64, ptr %1, align 4
  %12 = sub i64 %length4, 1
  %13 = sub i64 %12, 1
  call void @builtin_range_check(i64 %13)
  %14 = ptrtoint ptr %1 to i64
  %15 = add i64 %14, 1
  %vector_data5 = inttoptr i64 %15 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 1
  %length7 = load i64, ptr %1, align 4
  %16 = sub i64 %length7, 1
  %17 = sub i64 %16, 1
  call void @builtin_range_check(i64 %17)
  %18 = ptrtoint ptr %1 to i64
  %19 = add i64 %18, 1
  %vector_data8 = inttoptr i64 %19 to ptr
  %index_access9 = getelementptr i64, ptr %vector_data8, i64 1
  %20 = load i64, ptr %index_access9, align 4
  %21 = sub i64 %20, 1
  call void @builtin_range_check(i64 %21)
  store i64 %21, ptr %index_access6, align 4
  %length10 = load i64, ptr %1, align 4
  %22 = sub i64 %length10, 1
  %23 = sub i64 %22, 0
  call void @builtin_range_check(i64 %23)
  %24 = ptrtoint ptr %1 to i64
  %25 = add i64 %24, 1
  %vector_data11 = inttoptr i64 %25 to ptr
  %index_access12 = getelementptr i64, ptr %vector_data11, i64 0
  %26 = load i64, ptr %index_access12, align 4
  %27 = icmp eq i64 %26, 1
  %28 = zext i1 %27 to i64
  call void @builtin_assert(i64 %28)
  %length13 = load i64, ptr %1, align 4
  %29 = sub i64 %length13, 1
  %30 = sub i64 %29, 1
  call void @builtin_range_check(i64 %30)
  %31 = ptrtoint ptr %1 to i64
  %32 = add i64 %31, 1
  %vector_data14 = inttoptr i64 %32 to ptr
  %index_access15 = getelementptr i64, ptr %vector_data14, i64 1
  %33 = load i64, ptr %index_access15, align 4
  %34 = icmp eq i64 %33, 1
  %35 = zext i1 %34 to i64
  call void @builtin_assert(i64 %35)
  ret void
}

define ptr @array_sort_test(ptr %0) {
entry:
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  %1 = load ptr, ptr %source, align 8
  %2 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %2, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data = inttoptr i64 %4 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 10
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %5 = load i64, ptr %i, align 4
  %6 = icmp ult i64 %5, 10
  br i1 %6, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %7 = load i64, ptr %i, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %8 = sub i64 %length, 1
  %9 = sub i64 %8, %7
  call void @builtin_range_check(i64 %9)
  %10 = ptrtoint ptr %heap_to_ptr to i64
  %11 = add i64 %10, 1
  %vector_data3 = inttoptr i64 %11 to ptr
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 %7
  %12 = load i64, ptr %i, align 4
  %13 = sub i64 9, %12
  call void @builtin_range_check(i64 %13)
  %index_access5 = getelementptr [10 x i64], ptr %1, i64 %12
  %14 = load i64, ptr %index_access5, align 4
  store i64 %14, ptr %index_access4, align 4
  br label %next

next:                                             ; preds = %body2
  %15 = load i64, ptr %i, align 4
  %16 = add i64 %15, 1
  call void @builtin_range_check(i64 %16)
  store i64 %16, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  %length6 = load i64, ptr %heap_to_ptr, align 4
  %17 = call ptr @prophet_u32_array_sort(ptr %heap_to_ptr, i64 %length6)
  ret ptr %17
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %offset_ptr = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1845340408, label %func_0_dispatch
    i64 1940129018, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @test()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = call ptr @array_sort_test(ptr %3)
  %length = load i64, ptr %4, align 4
  %5 = mul i64 %length, 1
  %6 = add i64 %5, 1
  %heap_size = add i64 %6, 1
  %7 = call i64 @vector_new(i64 %heap_size)
  %heap_start = sub i64 %7, %heap_size
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %length1 = load i64, ptr %4, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %length1, ptr %encode_value_ptr, align 4
  store i64 1, ptr %offset_ptr, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %func_1_dispatch
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr ptr, ptr %4, i64 %index
  %elem = load i64, ptr %element, align 4
  %offset = load i64, ptr %offset_ptr, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 %offset
  store i64 %elem, ptr %encode_value_ptr2, align 4
  %next_offset = add i64 1, %offset
  store i64 %next_offset, ptr %offset_ptr, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %length1
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
  %8 = add i64 %length1, 1
  %9 = add i64 %8, 0
  %encode_value_ptr3 = getelementptr i64, ptr %heap_to_ptr, i64 %9
  store i64 %6, ptr %encode_value_ptr3, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
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
