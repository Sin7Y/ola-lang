; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array_4.ola"

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

define i64 @array_call(ptr %0) {
entry:
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %source, i64 0, i64 2
  store i64 100, ptr %index_access, align 4
  call void @builtin_range_check(i64 0)
  %index_access1 = getelementptr [3 x i64], ptr %source, i64 0, i64 2
  %1 = load i64, ptr %index_access1, align 4
  ret i64 %1
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  %array_literal = alloca [3 x i64], align 8
  switch i64 %0, label %missing_function [
    i64 984717406, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %elemptr0 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 0
  %3 = call i64 @tape_load(i64 %2, i64 0)
  store i64 %3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  %4 = call i64 @tape_load(i64 %2, i64 1)
  store i64 %4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  %5 = call i64 @tape_load(i64 %2, i64 2)
  store i64 %5, ptr %elemptr2, align 4
  %6 = icmp ule i64 3, %1
  br i1 %6, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %7 = icmp ult i64 3, %1
  br i1 %7, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %8 = call i64 @array_call(ptr %array_literal)
  call void @tape_store(i64 0, i64 %8)
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
