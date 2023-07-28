; ModuleID = 'ArraySortExample'
source_filename = "examples/source/array/array_4.ola"

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

define i64 @array_sort_test(ptr %0) {
entry:
  %array_literal1 = alloca [10 x i64], align 8
  %array_literal = alloca [10 x i64], align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  store i64 0, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  store i64 1, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  store i64 2, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  store i64 3, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  store i64 4, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  store i64 5, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  store i64 6, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  store i64 7, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  store i64 9, ptr %elemptr9, align 4
  %elemptr02 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 0
  store i64 0, ptr %elemptr02, align 4
  %elemptr13 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 1
  store i64 0, ptr %elemptr13, align 4
  %elemptr24 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 2
  store i64 0, ptr %elemptr24, align 4
  %elemptr35 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 3
  store i64 0, ptr %elemptr35, align 4
  %elemptr46 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 4
  store i64 0, ptr %elemptr46, align 4
  %elemptr57 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 5
  store i64 0, ptr %elemptr57, align 4
  %elemptr68 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 6
  store i64 0, ptr %elemptr68, align 4
  %elemptr79 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 7
  store i64 0, ptr %elemptr79, align 4
  %elemptr810 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 8
  store i64 0, ptr %elemptr810, align 4
  %elemptr911 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 9
  store i64 0, ptr %elemptr911, align 4
  call void @builtin_range_check(i64 7)
  %index_access = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  %1 = load i64, ptr %index_access, align 4
  ret i64 %1
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  %array_literal = alloca [10 x i64], align 8
  switch i64 %0, label %missing_function [
    i64 1940129018, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  %3 = call i64 @tape_load(i64 %2, i64 0)
  store i64 %3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  %4 = call i64 @tape_load(i64 %2, i64 1)
  store i64 %4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  %5 = call i64 @tape_load(i64 %2, i64 2)
  store i64 %5, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  %6 = call i64 @tape_load(i64 %2, i64 3)
  store i64 %6, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  %7 = call i64 @tape_load(i64 %2, i64 4)
  store i64 %7, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  %8 = call i64 @tape_load(i64 %2, i64 5)
  store i64 %8, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  %9 = call i64 @tape_load(i64 %2, i64 6)
  store i64 %9, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  %10 = call i64 @tape_load(i64 %2, i64 7)
  store i64 %10, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  %11 = call i64 @tape_load(i64 %2, i64 8)
  store i64 %11, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  %12 = call i64 @tape_load(i64 %2, i64 9)
  store i64 %12, ptr %elemptr9, align 4
  %13 = icmp ule i64 10, %1
  br i1 %13, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %14 = icmp ult i64 10, %1
  br i1 %14, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %15 = call i64 @array_sort_test(ptr %array_literal)
  call void @tape_store(i64 0, i64 %15)
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
