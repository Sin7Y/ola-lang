; ModuleID = 'StructArrayExample'
source_filename = "examples/source/array/array_struct.ola"

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

define ptr @createBooks() {
entry:
  %struct_alloca3 = alloca { i64, i64 }, align 8
  %struct_alloca = alloca { i64, i64 }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %heap_start = sub i64 %0, 3
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 1
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr { i64, i64 }, ptr %vector_data, i64 %index_value
  store ptr %struct_alloca, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_to_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca3, i32 0, i32 0
  store i64 99, ptr %"struct member", align 4
  %"struct member4" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca3, i32 0, i32 1
  store i64 100, ptr %"struct member4", align 4
  %7 = load { i64, i64 }, ptr %struct_alloca3, align 4
  store { i64, i64 } %7, ptr %index_access2, align 4
  ret ptr %heap_to_ptr
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2736305406, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBooks()
  %length = load i64, ptr %3, align 4
  %4 = mul i64 %length, 2
  %5 = add i64 %4, 1
  %6 = call i64 @vector_new(i64 %5)
  %heap_start = sub i64 %6, %5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %length1 = load i64, ptr %3, align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %length1, ptr %start, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %func_0_dispatch
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr ptr, ptr %3, i64 %index
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %element, i32 0, i32 0
  %elem = load i64, ptr %"struct member", align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %elem, ptr %start2, align 4
  %"struct member3" = getelementptr inbounds { i64, i64 }, ptr %element, i32 0, i32 1
  %elem4 = load i64, ptr %"struct member3", align 4
  %start5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %elem4, ptr %start5, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %length1
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
  %7 = add i64 %length1, 1
  %8 = add i64 0, %7
  call void @set_tape_data(i64 %heap_start, i64 %5)
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
