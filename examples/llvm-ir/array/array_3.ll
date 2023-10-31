; ModuleID = 'ArrayLengthExample'
source_filename = "examples/source/array/array_3.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

define void @mempcy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

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

define i64 @array_length_test() {
entry:
  %0 = call i64 @vector_new(i64 10)
  %heap_start = sub i64 %0, 10
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %elemptr0 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 0
  store i64 0, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 1
  store i64 1, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 2
  store i64 2, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 3
  store i64 3, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 4
  store i64 4, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 5
  store i64 5, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 6
  store i64 6, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 7
  store i64 7, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %heap_to_ptr, i64 9
  store i64 9, ptr %elemptr9, align 4
  ret i64 10
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 3568958617, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call i64 @array_length_test()
  %4 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %4, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %3, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr1, align 4
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
