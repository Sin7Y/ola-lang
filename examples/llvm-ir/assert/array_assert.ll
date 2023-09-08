; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/assert/array_assert.ola"

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

define void @main() {
entry:
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
  %3 = icmp eq i64 %length, 3
  %4 = zext i1 %3 to i64
  call void @builtin_assert(i64 %4)
  %length1 = load i64, ptr %heap_to_ptr, align 4
  %5 = sub i64 %length1, 1
  %6 = sub i64 %5, 0
  call void @builtin_range_check(i64 %6)
  %7 = ptrtoint ptr %heap_to_ptr to i64
  %8 = add i64 %7, 1
  %vector_data2 = inttoptr i64 %8 to ptr
  %index_access3 = getelementptr i64, ptr %vector_data2, i64 0
  store i64 1, ptr %index_access3, align 4
  %length4 = load i64, ptr %heap_to_ptr, align 4
  %9 = sub i64 %length4, 1
  %10 = sub i64 %9, 0
  call void @builtin_range_check(i64 %10)
  %11 = ptrtoint ptr %heap_to_ptr to i64
  %12 = add i64 %11, 1
  %vector_data5 = inttoptr i64 %12 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 0
  %13 = load i64, ptr %index_access6, align 4
  %14 = icmp eq i64 %13, 1
  %15 = zext i1 %14 to i64
  call void @builtin_assert(i64 %15)
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3758009808, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @main()
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 1)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 2)
  %heap_start1 = sub i64 %1, 2
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 2)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 2
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
