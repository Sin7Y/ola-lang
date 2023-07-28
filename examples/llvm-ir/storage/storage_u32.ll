; ModuleID = 'SimpleVar'
source_filename = "examples/source/storage/storage_u32.ola"

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

define void @inc_simple() {
entry:
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] [i64 0, i64 0, i64 0, i64 100])
  ret void
}

define i64 @get() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %1 = extractvalue [4 x i64] %0, 3
  ret i64 %1
}

define void @main() {
entry:
  %x = alloca i64, align 8
  call void @inc_simple()
  %0 = call i64 @get()
  store i64 %0, ptr %x, align 4
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2364819430, label %func_0_dispatch
    i64 1021725805, label %func_1_dispatch
    i64 3501063903, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @inc_simple()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %3 = call i64 @get()
  call void @tape_store(i64 0, i64 %3)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @main()
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
