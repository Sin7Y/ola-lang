; ModuleID = 'StructWithArrayExample'
source_filename = "examples/source/struct/struct_array.ola"

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

define ptr @createStudent() {
entry:
  %struct_alloca = alloca { i64, ptr }, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
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
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 0
  store i64 85, ptr %index_access2, align 4
  %length3 = load i64, ptr %heap_to_ptr, align 4
  %7 = sub i64 %length3, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %9 = ptrtoint ptr %heap_to_ptr to i64
  %10 = add i64 %9, 1
  %vector_data4 = inttoptr i64 %10 to ptr
  %index_access5 = getelementptr i64, ptr %vector_data4, i64 1
  store i64 90, ptr %index_access5, align 4
  %length6 = load i64, ptr %heap_to_ptr, align 4
  %11 = sub i64 %length6, 1
  %12 = sub i64 %11, 2
  call void @builtin_range_check(i64 %12)
  %13 = ptrtoint ptr %heap_to_ptr to i64
  %14 = add i64 %13, 1
  %vector_data7 = inttoptr i64 %14 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 2
  store i64 95, ptr %index_access8, align 4
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 0
  store i64 20, ptr %"struct member", align 4
  %"struct member9" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 1
  store ptr %heap_to_ptr, ptr %"struct member9", align 8
  ret ptr %struct_alloca
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 15777857, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createStudent()
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %elem = load i64, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %length = load i64, ptr %"struct member1", align 4
  %4 = mul i64 %length, 1
  %5 = add i64 %4, 1
  %6 = add i64 1, %5
  %heap_size = add i64 %6, 1
  %7 = call i64 @vector_new(i64 %heap_size)
  %heap_start = sub i64 %7, %heap_size
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %"struct member2" = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %elem3 = load i64, ptr %"struct member2", align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %elem3, ptr %start, align 4
  %"struct member4" = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %length5 = load i64, ptr %"struct member4", align 4
  %start6 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %length5, ptr %start6, align 4
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %func_0_dispatch
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr ptr, ptr %"struct member4", i64 %index
  %elem7 = load i64, ptr %element, align 4
  %start8 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %elem7, ptr %start8, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %length5
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
  %8 = add i64 %length5, 1
  %9 = add i64 1, %8
  %10 = add i64 0, %9
  %start9 = getelementptr i64, ptr %heap_to_ptr, i64 %10
  store i64 %6, ptr %start9, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
  ret void
}

define void @call() {
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
