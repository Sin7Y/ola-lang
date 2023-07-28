; ModuleID = 'Fibonacci'
source_filename = "examples/source/variable/var.ola"

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

define i64 @var_test(i64 %0) {
entry:
  %second = alloca i64, align 8
  %first = alloca i64, align 8
  %third = alloca i64, align 8
  %n = alloca i64, align 8
  store i64 %0, ptr %n, align 4
  %1 = load i64, ptr %n, align 4
  %2 = add i64 1, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %third, align 4
  %3 = load i64, ptr %n, align 4
  %4 = add i64 2, %3
  call void @builtin_range_check(i64 %4)
  store i64 %4, ptr %first, align 4
  %5 = load i64, ptr %n, align 4
  %6 = add i64 3, %5
  call void @builtin_range_check(i64 %6)
  store i64 %6, ptr %second, align 4
  %7 = load i64, ptr %third, align 4
  %8 = load i64, ptr %first, align 4
  %9 = add i64 %7, %8
  call void @builtin_range_check(i64 %9)
  %10 = load i64, ptr %second, align 4
  %11 = add i64 %9, %10
  call void @builtin_range_check(i64 %11)
  ret i64 %11
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3897801033, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 1, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %4 = call i64 @tape_load(i64 %2, i64 0)
  %5 = icmp ult i64 1, %1
  br i1 %5, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %6 = call i64 @var_test(i64 %4)
  call void @tape_store(i64 0, i64 %6)
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
