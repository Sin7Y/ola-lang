; ModuleID = 'Caller'
source_filename = "examples/source/cross_call/caller.ola"

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

define void @delegatecall_test(ptr %0) {
entry:
  %set_data = alloca i64, align 8
  %_contract = alloca ptr, align 8
  store ptr %0, ptr %_contract, align 8
  store i64 66, ptr %set_data, align 4
  %1 = load i64, ptr %set_data, align 4
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_to_ptr, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %1, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 1, ptr %encode_value_ptr1, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 2653574029, ptr %encode_value_ptr2, align 4
  %3 = load ptr, ptr %_contract, align 8
  %payload_len = load i64, ptr %heap_to_ptr, align 4
  %tape_size = add i64 %payload_len, 2
  %4 = ptrtoint ptr %heap_to_ptr to i64
  %payload_start = add i64 %4, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %3, i64 1)
  %5 = call i64 @vector_new(i64 1)
  %heap_start3 = sub i64 %5, 1
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 1)
  %return_length = load i64, ptr %heap_to_ptr4, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size5 = add i64 %return_length, 1
  %6 = call i64 @vector_new(i64 %heap_size)
  %heap_start6 = sub i64 %6, %heap_size
  %heap_to_ptr7 = inttoptr i64 %heap_start6 to ptr
  store i64 %return_length, ptr %heap_to_ptr7, align 4
  %7 = add i64 %heap_start6, 1
  call void @get_tape_data(i64 %7, i64 %tape_size5)
  %8 = call i64 @vector_new(i64 4)
  %heap_start8 = sub i64 %8, 4
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  %9 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %9, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  store i64 0, ptr %heap_to_ptr11, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr11, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr11, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  store i64 0, ptr %12, align 4
  call void @get_storage(ptr %heap_to_ptr11, ptr %heap_to_ptr9)
  %storage_value = load i64, ptr %heap_to_ptr9, align 4
  %13 = icmp eq i64 %storage_value, 66
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @call_test(ptr %0) {
entry:
  %result = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %_contract = alloca ptr, align 8
  store ptr %0, ptr %_contract, align 8
  store i64 100, ptr %a, align 4
  store i64 200, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %3, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 4, ptr %heap_to_ptr, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %1, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %2, ptr %encode_value_ptr1, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 2, ptr %encode_value_ptr2, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 1715662714, ptr %encode_value_ptr3, align 4
  %4 = load ptr, ptr %_contract, align 8
  %payload_len = load i64, ptr %heap_to_ptr, align 4
  %tape_size = add i64 %payload_len, 2
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %payload_start = add i64 %5, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %4, i64 0)
  %6 = call i64 @vector_new(i64 1)
  %heap_start4 = sub i64 %6, 1
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  call void @get_tape_data(i64 %heap_start4, i64 1)
  %return_length = load i64, ptr %heap_to_ptr5, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size6 = add i64 %return_length, 1
  %7 = call i64 @vector_new(i64 %heap_size)
  %heap_start7 = sub i64 %7, %heap_size
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %return_length, ptr %heap_to_ptr8, align 4
  %8 = add i64 %heap_start7, 1
  call void @get_tape_data(i64 %8, i64 %tape_size6)
  %length = load i64, ptr %heap_to_ptr8, align 4
  %9 = ptrtoint ptr %heap_to_ptr8 to i64
  %10 = add i64 %9, 1
  %vector_data = inttoptr i64 %10 to ptr
  %input_start = ptrtoint ptr %vector_data to i64
  %11 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %11, align 4
  store i64 %decode_value, ptr %result, align 4
  %12 = load i64, ptr %result, align 4
  %13 = icmp eq i64 %12, 300
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3965482278, label %func_0_dispatch
    i64 1607480800, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  call void @delegatecall_test(ptr %3)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start1 = ptrtoint ptr %input to i64
  %4 = inttoptr i64 %input_start1 to ptr
  call void @call_test(ptr %4)
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
