; ModuleID = 'InputExample'
source_filename = "examples/source/contract_input/input_1.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_call_data(i64, i64)

declare void @set_tape_data(i64, i64)

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
  %4 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %4, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %3, ptr %start, align 4
  call void @set_tape_data(i64 %heap_start, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @main()
  ret void

func_2_dispatch:                                  ; preds = %entry
  %5 = call i64 @bar()
  %6 = call i64 @vector_new(i64 1)
  %heap_start1 = sub i64 %6, 1
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %start3 = getelementptr i64, ptr %heap_to_ptr2, i64 0
  store i64 %5, ptr %start3, align 4
  call void @set_tape_data(i64 %heap_start1, i64 1)
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_call_data(i64 %heap_start, i64 0)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 1)
  %heap_start1 = sub i64 %1, 1
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_call_data(i64 %heap_start1, i64 1)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = call i64 @vector_new(i64 %input_length)
  %heap_start3 = sub i64 %2, %input_length
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_call_data(i64 %heap_start3, i64 2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  unreachable
}
