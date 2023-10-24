; ModuleID = 'SimpleVar'
source_filename = "examples/source/storage/storage_u32.ola"

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

define void @inc_simple() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %1, align 4
  %2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %3, align 4
  %4 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %4, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 100, ptr %heap_to_ptr2, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %7, align 4
  call void @set_storage(ptr %heap_to_ptr, ptr %heap_to_ptr2)
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %9 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %9, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 0, ptr %heap_to_ptr6, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %12, align 4
  call void @get_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr4)
  %storage_value = load i64, ptr %heap_to_ptr4, align 4
  %13 = icmp eq i64 %storage_value, 100
  %14 = zext i1 %13 to i64
  call void @builtin_assert(i64 %14)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2364819430, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @inc_simple()
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
