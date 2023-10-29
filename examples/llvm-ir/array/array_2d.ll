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

declare void @prophet_printf(i64, i64)

define ptr @create2DArray() {
entry:
  %0 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %0, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %elemptr0 = getelementptr [3 x [2 x i64]], ptr %heap_to_ptr, i64 0, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x [2 x i64]], ptr %heap_to_ptr, i64 0, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x [2 x i64]], ptr %heap_to_ptr, i64 0, i64 1, i64 0
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [3 x [2 x i64]], ptr %heap_to_ptr, i64 0, i64 1, i64 1
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [3 x [2 x i64]], ptr %heap_to_ptr, i64 0, i64 2, i64 0
  store i64 5, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [3 x [2 x i64]], ptr %heap_to_ptr, i64 0, i64 2, i64 1
  store i64 6, ptr %elemptr5, align 4
  ret ptr %heap_to_ptr
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %_j = alloca i64, align 8
  %_i = alloca i64, align 8
  %_array2D = alloca ptr, align 8
  store ptr %0, ptr %_array2D, align 8
  %3 = load ptr, ptr %_array2D, align 8
  store i64 %1, ptr %_i, align 4
  store i64 %2, ptr %_j, align 4
  %4 = load i64, ptr %_i, align 4
  %5 = sub i64 2, %4
  call void @builtin_range_check(i64 %5)
  %index_access = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 %4
  %6 = load i64, ptr %_j, align 4
  %7 = sub i64 1, %6
  call void @builtin_range_check(i64 %7)
  %index_access1 = getelementptr [2 x i64], ptr %index_access, i64 0, i64 %6
  %8 = load i64, ptr %index_access1, align 4
  ret i64 %8
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
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
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %encode_value_ptr, align 4
  %elemptr1 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 0, i64 1
  %6 = load i64, ptr %elemptr1, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %6, ptr %encode_value_ptr1, align 4
  %elemptr2 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 1, i64 0
  %7 = load i64, ptr %elemptr2, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %7, ptr %encode_value_ptr2, align 4
  %elemptr3 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 1, i64 1
  %8 = load i64, ptr %elemptr3, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %8, ptr %encode_value_ptr3, align 4
  %elemptr4 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 2, i64 0
  %9 = load i64, ptr %elemptr4, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 %9, ptr %encode_value_ptr4, align 4
  %elemptr5 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 2, i64 1
  %10 = load i64, ptr %elemptr5, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr, i64 5
  store i64 %10, ptr %encode_value_ptr5, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr, i64 6
  store i64 6, ptr %encode_value_ptr6, align 4
  call void @set_tape_data(i64 %heap_start, i64 7)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %11 = inttoptr i64 %input_start to ptr
  %12 = add i64 %input_start, 6
  %13 = inttoptr i64 %12 to ptr
  %decode_value = load i64, ptr %13, align 4
  %14 = add i64 %12, 1
  %15 = inttoptr i64 %14 to ptr
  %decode_value7 = load i64, ptr %15, align 4
  %16 = call i64 @getElement(ptr %11, i64 %decode_value, i64 %decode_value7)
  %17 = call i64 @vector_new(i64 2)
  %heap_start8 = sub i64 %17, 2
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  %encode_value_ptr10 = getelementptr i64, ptr %heap_to_ptr9, i64 0
  store i64 %16, ptr %encode_value_ptr10, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %heap_to_ptr9, i64 1
  store i64 1, ptr %encode_value_ptr11, align 4
  call void @set_tape_data(i64 %heap_start8, i64 2)
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
