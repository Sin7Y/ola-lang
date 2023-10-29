; ModuleID = 'InputExample'
source_filename = "examples/source/contract_input/simple_input.ola"

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

define i64 @foo(i64 %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = add i64 %2, %3
  call void @builtin_range_check(i64 %4)
  ret i64 %4
}

define i64 @bar(i64 %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = mul i64 %2, %3
  call void @builtin_range_check(i64 %4)
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 253268590, label %func_0_dispatch
    i64 1503968193, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  %4 = add i64 %input_start, 1
  %5 = inttoptr i64 %4 to ptr
  %decode_value1 = load i64, ptr %5, align 4
  %6 = call i64 @foo(i64 %decode_value, i64 %decode_value1)
  %7 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %7, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %6, ptr %encode_value_ptr, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr2, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start3 = ptrtoint ptr %input to i64
  %8 = inttoptr i64 %input_start3 to ptr
  %decode_value4 = load i64, ptr %8, align 4
  %9 = add i64 %input_start3, 1
  %10 = inttoptr i64 %9 to ptr
  %decode_value5 = load i64, ptr %10, align 4
  %11 = call i64 @bar(i64 %decode_value4, i64 %decode_value5)
  %12 = call i64 @vector_new(i64 2)
  %heap_start6 = sub i64 %12, 2
  %heap_to_ptr7 = inttoptr i64 %heap_start6 to ptr
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr7, i64 0
  store i64 %11, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr7, i64 1
  store i64 1, ptr %encode_value_ptr9, align 4
  call void @set_tape_data(i64 %heap_start6, i64 2)
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
