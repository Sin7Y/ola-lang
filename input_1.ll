; ModuleID = 'InputExample'
source_filename = "examples/source/contract_input/input_1.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define i64 @foo() {
entry:
  ret i64 5
}

define void @main() {
entry:
  %y = alloca i64, align 8
  %x = alloca i64, align 8
  store i64 5, ptr %x, align 4
  %0 = call i64 @foo()
  store i64 %0, ptr %y, align 4
  ret void
}

define i64 @bar() {
entry:
  call void @builtin_range_check(i64 9)
  ret i64 9
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2018875586, label %func_0_dispatch
    i64 3501063903, label %func_1_dispatch
    i64 2114960382, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call i64 @foo()

func_1_dispatch:                                  ; preds = %entry
  call void @main()

func_2_dispatch:                                  ; preds = %entry
  %4 = call i64 @bar()
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 2
  %data = load ptr, ptr %input_data, align 8
  call void @function_dispatch(i64 %selector, i64 %len, ptr %data)
  unreachable
}
