; ModuleID = 'MultInputExample'
source_filename = "examples/source/contract_input/mult_input.ola"

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

define void @foo(ptr %0, ptr %1, ptr %2, ptr %3, i64 %4, i64 %5) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %h = alloca ptr, align 8
  %addr = alloca ptr, align 8
  %s = alloca ptr, align 8
  %f = alloca ptr, align 8
  store ptr %0, ptr %f, align 8
  %6 = load ptr, ptr %f, align 8
  store ptr %1, ptr %s, align 8
  %7 = load ptr, ptr %s, align 8
  store ptr %2, ptr %addr, align 8
  store ptr %3, ptr %h, align 8
  store i64 %4, ptr %a, align 4
  store i64 %5, ptr %b, align 4
  %fields_start = ptrtoint ptr %6 to i64
  call void @prophet_printf(i64 %fields_start, i64 1)
  %string_start = ptrtoint ptr %7 to i64
  call void @prophet_printf(i64 %string_start, i64 1)
  %8 = load ptr, ptr %addr, align 8
  %address_start = ptrtoint ptr %8 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %9 = load ptr, ptr %h, align 8
  %hash_start = ptrtoint ptr %9 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  %10 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %10, i64 3)
  %11 = load i64, ptr %b, align 4
  call void @prophet_printf(i64 %11, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 251262146, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %length = load i64, ptr %3, align 4
  %4 = add i64 %length, 1
  %5 = add i64 %input_start, %4
  %6 = inttoptr i64 %5 to ptr
  %length1 = load i64, ptr %6, align 4
  %7 = add i64 %length1, 1
  %8 = add i64 %5, %7
  %9 = inttoptr i64 %8 to ptr
  %10 = add i64 %8, 4
  %11 = inttoptr i64 %10 to ptr
  %12 = add i64 %10, 4
  %13 = inttoptr i64 %12 to ptr
  %decode_value = load i64, ptr %13, align 4
  %14 = add i64 %12, 1
  %15 = inttoptr i64 %14 to ptr
  %decode_value2 = load i64, ptr %15, align 4
  call void @foo(ptr %3, ptr %6, ptr %9, ptr %11, i64 %decode_value, i64 %decode_value2)
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
