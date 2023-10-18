; ModuleID = 'ArraySortExample'
source_filename = "examples/source/array/array_4.ola"

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

define i64 @array_sort_test() {
entry:
  %array_literal1 = alloca [10 x i64], align 8
  %array_literal = alloca [10 x i64], align 8
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
  %0 = load i64, ptr %index_access, align 4
  ret i64 %0
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1065523696, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call i64 @array_sort_test()
  %4 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %4, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %3, ptr %start, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start1, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
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
