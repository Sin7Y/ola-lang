; ModuleID = 'DynamicArrayInMemory'
source_filename = "examples/source/array/array_dynamic/array_2d.ola"

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

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @contract_call(i64, i64)

define void @processDynamicArray() {
entry:
  %index_alloca9 = alloca i64, align 8
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
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  store ptr null, ptr %index_access, align 8
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
  %7 = call i64 @vector_new(i64 3)
  %heap_start3 = sub i64 %7, 3
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 2, ptr %heap_to_ptr4, align 4
  %8 = ptrtoint ptr %heap_to_ptr4 to i64
  %9 = add i64 %8, 1
  %vector_data5 = inttoptr i64 %9 to ptr
  store i64 0, ptr %index_alloca9, align 4
  br label %cond6

cond6:                                            ; preds = %body7, %done
  %index_value10 = load i64, ptr %index_alloca9, align 4
  %loop_cond11 = icmp ult i64 %index_value10, 2
  br i1 %loop_cond11, label %body7, label %done8

body7:                                            ; preds = %cond6
  %index_access12 = getelementptr i64, ptr %vector_data5, i64 %index_value10
  store i64 0, ptr %index_access12, align 4
  %next_index13 = add i64 %index_value10, 1
  store i64 %next_index13, ptr %index_alloca9, align 4
  br label %cond6

done8:                                            ; preds = %cond6
  store ptr %heap_to_ptr4, ptr %index_access2, align 8
  %length14 = load i64, ptr %heap_to_ptr, align 4
  %10 = sub i64 %length14, 1
  %11 = sub i64 %10, 0
  call void @builtin_range_check(i64 %11)
  %12 = ptrtoint ptr %heap_to_ptr to i64
  %13 = add i64 %12, 1
  %vector_data15 = inttoptr i64 %13 to ptr
  %index_access16 = getelementptr ptr, ptr %vector_data15, i64 0
  %14 = load ptr, ptr %index_access16, align 8
  %length17 = load i64, ptr %14, align 4
  %15 = sub i64 %length17, 1
  %16 = sub i64 %15, 0
  call void @builtin_range_check(i64 %16)
  %17 = ptrtoint ptr %14 to i64
  %18 = add i64 %17, 1
  %vector_data18 = inttoptr i64 %18 to ptr
  %index_access19 = getelementptr i64, ptr %vector_data18, i64 0
  store i64 1, ptr %index_access19, align 4
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1008636309, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @processDynamicArray()
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
