; ModuleID = 'StaticArrayExample'
source_filename = "examples/source/storage/storage_array.ola"

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

define void @init() {
entry:
  %0 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %array_literal = alloca [5 x i64], align 8
  %elemptr0 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 4
  store i64 5, ptr %elemptr4, align 4
  store i64 0, ptr %index_alloca, align 4
  store i64 0, ptr %0, align 4
  br label %body

body:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %1 = load i64, ptr %0, align 4
  %index_access = getelementptr [5 x i64], ptr %array_literal, i64 0, i64 %index_value
  %2 = load i64, ptr %index_access, align 4
  %3 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %4 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %2, 3
  call void @set_storage([4 x i64] %3, [4 x i64] %4)
  %5 = add i64 %1, 1
  store i64 %5, ptr %0, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %next_index, 5
  br i1 %loop_cond, label %body, label %done

done:                                             ; preds = %body
  ret void
}

define void @setElement(i64 %0, i64 %1) {
entry:
  %value = alloca i64, align 8
  %index = alloca i64, align 8
  store i64 %0, ptr %index, align 4
  store i64 %1, ptr %value, align 4
  %2 = load i64, ptr %index, align 4
  %3 = sub i64 4, %2
  call void @builtin_range_check(i64 %3)
  %4 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %5 = extractvalue [4 x i64] %4, 3
  %6 = add i64 %5, %2
  %7 = insertvalue [4 x i64] %4, i64 %6, 3
  %8 = load i64, ptr %value, align 4
  %9 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %8, 3
  call void @set_storage([4 x i64] %7, [4 x i64] %9)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 708429793, label %func_0_dispatch
    i64 2209048891, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @init()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 2, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %4 = call i64 @tape_load(i64 %2, i64 0)
  %5 = call i64 @tape_load(i64 %2, i64 1)
  %6 = icmp ult i64 2, %1
  br i1 %6, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setElement(i64 %4, i64 %5)
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
