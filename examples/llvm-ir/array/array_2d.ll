; ModuleID = 'TwoDArrayExample'
source_filename = "examples/source/array/array_2d.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

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
  %_array2D = alloca ptr, align 8
  store ptr %0, ptr %_array2D, align 8
  store i64 %1, ptr %_i, align 4
  store i64 %2, ptr %_j, align 4
  %3 = load i64, ptr %_i, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x i64]], ptr %_array2D, i64 0, i64 %3
  %5 = load i64, ptr %_j, align 4
  %6 = sub i64 1, %5
  call void @builtin_range_check(i64 %6)
  %index_access1 = getelementptr [2 x i64], ptr %index_access, i64 0, i64 %5
  %7 = load i64, ptr %index_access1, align 4
  ret i64 %7
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
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
  %elemptr0 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 0, i64 0
  %4 = load i64, ptr %elemptr0, align 4
  call void @tape_store(i64 0, i64 %4)
  %elemptr1 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 0, i64 1
  %5 = load i64, ptr %elemptr1, align 4
  call void @tape_store(i64 1, i64 %5)
  %elemptr2 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 1, i64 0
  %6 = load i64, ptr %elemptr2, align 4
  call void @tape_store(i64 2, i64 %6)
  %elemptr3 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 1, i64 1
  %7 = load i64, ptr %elemptr3, align 4
  call void @tape_store(i64 3, i64 %7)
  %elemptr4 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 2, i64 0
  %8 = load i64, ptr %elemptr4, align 4
  call void @tape_store(i64 4, i64 %8)
  %elemptr5 = getelementptr [3 x [2 x i64]], ptr %3, i64 0, i64 2, i64 1
  %9 = load i64, ptr %elemptr5, align 4
  call void @tape_store(i64 5, i64 %9)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %10 = icmp ule i64 8, %1
  br i1 %10, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %elemptr01 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 0
  %11 = call i64 @tape_load(i64 %2, i64 0)
  store i64 %11, ptr %elemptr01, align 4
  %elemptr12 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 1
  %12 = call i64 @tape_load(i64 %2, i64 1)
  store i64 %12, ptr %elemptr12, align 4
  %elemptr23 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 0
  %13 = call i64 @tape_load(i64 %2, i64 2)
  store i64 %13, ptr %elemptr23, align 4
  %elemptr34 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 1
  %14 = call i64 @tape_load(i64 %2, i64 3)
  store i64 %14, ptr %elemptr34, align 4
  %elemptr45 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 0
  %15 = call i64 @tape_load(i64 %2, i64 4)
  store i64 %15, ptr %elemptr45, align 4
  %elemptr56 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 1
  %16 = call i64 @tape_load(i64 %2, i64 5)
  store i64 %16, ptr %elemptr56, align 4
  %17 = call i64 @tape_load(i64 %2, i64 6)
  %18 = call i64 @tape_load(i64 %2, i64 7)
  %19 = icmp ult i64 8, %1
  br i1 %19, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %20 = call i64 @getElement(ptr %array_literal, i64 %17, i64 %18)
  call void @tape_store(i64 0, i64 %20)
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
