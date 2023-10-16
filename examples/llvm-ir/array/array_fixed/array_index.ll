; ModuleID = 'ArrayIndexExample'
source_filename = "examples/source/array/array_fixed/array_index.ola"

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

define void @main() {
entry:
  %value = alloca i64, align 8
  %index = alloca i64, align 8
  store i64 2, ptr %index, align 4
  %0 = load i64, ptr %index, align 4
  %1 = call i64 @array_index(i64 %0)
  store i64 %1, ptr %value, align 4
  ret void
}

define i64 @array_index(i64 %0) {
entry:
  %array_literal = alloca [3 x i64], align 8
  %index = alloca i64, align 8
  store i64 %0, ptr %index, align 4
  %elemptr0 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %1 = load i64, ptr %index, align 4
  %2 = sub i64 2, %1
  call void @builtin_range_check(i64 %2)
  %index_access = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 %1
  %3 = load i64, ptr %index_access, align 4
  ret i64 %3
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3501063903, label %func_0_dispatch
    i64 256530221, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @main()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 1, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = icmp ult i64 1, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %5 = call i64 @array_index(i64 %value)
  %6 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %6, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start2, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void
}

define void @main.1() {
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
