; ModuleID = 'TwoDArrayExample'
source_filename = "examples/source/array/array_2d.ola"

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

define ptr @create2DArray() {
entry:
  %array_literal = alloca [3 x [2 x i64]], align 8
  %elemptr0 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 0
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 1
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 0
  store i64 5, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 1
  store i64 6, ptr %elemptr5, align 4
  ret ptr %array_literal
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %_j = alloca i64, align 8
  %_i = alloca i64, align 8
  store i64 %1, ptr %_i, align 4
  store i64 %2, ptr %_j, align 4
  %3 = load i64, ptr %_i, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x i64]], ptr %0, i64 0, i64 %3
  %5 = load i64, ptr %_j, align 4
  %6 = sub i64 1, %5
  call void @builtin_range_check(i64 %6)
  %index_access1 = getelementptr [2 x i64], ptr %index_access, i64 0, i64 %5
  %7 = load i64, ptr %index_access1, align 4
  ret i64 %7
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %array_literal = alloca [3 x [2 x i64]], align 8
  switch i64 %0, label %missing_function [
    i64 2863161113, label %func_0_dispatch
    i64 4267027548, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @create2DArray()
  %4 = call i64 @vector_new(i64 7)
  %heap_start = sub i64 %4, 7
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %elemptr0 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 0, i64 0
  %5 = load i64, ptr %elemptr0, align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %start, align 4
  %elemptr1 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 0, i64 1
  %6 = load i64, ptr %elemptr1, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %6, ptr %start1, align 4
  %elemptr2 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 1, i64 0
  %7 = load i64, ptr %elemptr2, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %7, ptr %start2, align 4
  %elemptr3 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 1, i64 1
  %8 = load i64, ptr %elemptr3, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %8, ptr %start3, align 4
  %elemptr4 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 2, i64 0
  %9 = load i64, ptr %elemptr4, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 %9, ptr %start4, align 4
  %elemptr5 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 2, i64 1
  %10 = load i64, ptr %elemptr5, align 4
  %start5 = getelementptr i64, ptr %heap_to_ptr, i64 5
  store i64 %10, ptr %start5, align 4
  %start6 = getelementptr i64, ptr %heap_to_ptr, i64 6
  store i64 6, ptr %start6, align 4
  call void @set_tape_data(i64 %heap_start, i64 7)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %11 = icmp ule i64 8, %1
  br i1 %11, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %elemptr07 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 0
  %start8 = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start8, align 4
  store i64 %value, ptr %elemptr07, align 4
  %elemptr19 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 1
  %start10 = getelementptr i64, ptr %2, i64 1
  %value11 = load i64, ptr %start10, align 4
  store i64 %value11, ptr %elemptr19, align 4
  %elemptr212 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 0
  %start13 = getelementptr i64, ptr %2, i64 2
  %value14 = load i64, ptr %start13, align 4
  store i64 %value14, ptr %elemptr212, align 4
  %elemptr315 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 1
  %start16 = getelementptr i64, ptr %2, i64 3
  %value17 = load i64, ptr %start16, align 4
  store i64 %value17, ptr %elemptr315, align 4
  %elemptr418 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 0
  %start19 = getelementptr i64, ptr %2, i64 4
  %value20 = load i64, ptr %start19, align 4
  store i64 %value20, ptr %elemptr418, align 4
  %elemptr521 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 1
  %start22 = getelementptr i64, ptr %2, i64 5
  %value23 = load i64, ptr %start22, align 4
  store i64 %value23, ptr %elemptr521, align 4
  %start24 = getelementptr i64, ptr %2, i64 6
  %value25 = load i64, ptr %start24, align 4
  %start26 = getelementptr i64, ptr %2, i64 7
  %value27 = load i64, ptr %start26, align 4
  %12 = icmp ult i64 8, %1
  br i1 %12, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %13 = call i64 @getElement(ptr %array_literal, i64 %value25, i64 %value27)
  %14 = call i64 @vector_new(i64 2)
  %heap_start28 = sub i64 %14, 2
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  %start30 = getelementptr i64, ptr %heap_to_ptr29, i64 0
  store i64 %13, ptr %start30, align 4
  %start31 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 1, ptr %start31, align 4
  call void @set_tape_data(i64 %heap_start28, i64 2)
  ret void
}

define void @call() {
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
