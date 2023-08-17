; ModuleID = 'AssertContract'
source_filename = "examples/source/assert/string_assert.ola"

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

define void @main() {
entry:
  %index = alloca i64, align 8
  %0 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %0, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 5, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data1 = inttoptr i64 %4 to ptr
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 1
  store i64 101, ptr %index_access2, align 4
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data3 = inttoptr i64 %6 to ptr
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 2
  store i64 108, ptr %index_access4, align 4
  %7 = ptrtoint ptr %heap_to_ptr to i64
  %8 = add i64 %7, 1
  %vector_data5 = inttoptr i64 %8 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 3
  store i64 108, ptr %index_access6, align 4
  %9 = ptrtoint ptr %heap_to_ptr to i64
  %10 = add i64 %9, 1
  %vector_data7 = inttoptr i64 %10 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 4
  store i64 111, ptr %index_access8, align 4
  %11 = call i64 @vector_new(i64 6)
  %heap_start9 = sub i64 %11, 6
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 5, ptr %heap_to_ptr10, align 4
  %12 = ptrtoint ptr %heap_to_ptr10 to i64
  %13 = add i64 %12, 1
  %vector_data11 = inttoptr i64 %13 to ptr
  %index_access12 = getelementptr i64, ptr %vector_data11, i64 0
  store i64 104, ptr %index_access12, align 4
  %14 = ptrtoint ptr %heap_to_ptr10 to i64
  %15 = add i64 %14, 1
  %vector_data13 = inttoptr i64 %15 to ptr
  %index_access14 = getelementptr i64, ptr %vector_data13, i64 1
  store i64 101, ptr %index_access14, align 4
  %16 = ptrtoint ptr %heap_to_ptr10 to i64
  %17 = add i64 %16, 1
  %vector_data15 = inttoptr i64 %17 to ptr
  %index_access16 = getelementptr i64, ptr %vector_data15, i64 2
  store i64 108, ptr %index_access16, align 4
  %18 = ptrtoint ptr %heap_to_ptr10 to i64
  %19 = add i64 %18, 1
  %vector_data17 = inttoptr i64 %19 to ptr
  %index_access18 = getelementptr i64, ptr %vector_data17, i64 3
  store i64 108, ptr %index_access18, align 4
  %20 = ptrtoint ptr %heap_to_ptr10 to i64
  %21 = add i64 %20, 1
  %vector_data19 = inttoptr i64 %21 to ptr
  %index_access20 = getelementptr i64, ptr %vector_data19, i64 4
  store i64 111, ptr %index_access20, align 4
  %22 = ptrtoint ptr %heap_to_ptr to i64
  %23 = add i64 %22, 1
  %vector_data21 = inttoptr i64 %23 to ptr
  %length = load i64, ptr %heap_to_ptr, align 4
  %24 = ptrtoint ptr %heap_to_ptr10 to i64
  %25 = add i64 %24, 1
  %vector_data22 = inttoptr i64 %25 to ptr
  %length23 = load i64, ptr %heap_to_ptr10, align 4
  %26 = icmp eq i64 %length, %length23
  %27 = zext i1 %26 to i64
  call void @builtin_assert(i64 %27)
  store i64 0, ptr %index, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index24 = load i64, ptr %index, align 4
  %28 = icmp ult i64 %index24, %length
  br i1 %28, label %body, label %done

body:                                             ; preds = %cond
  %left_char_ptr = getelementptr i64, ptr %vector_data21, i64 %index24
  %right_char_ptr = getelementptr i64, ptr %vector_data22, i64 %index24
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index = add i64 %index24, 1
  store i64 %next_index, ptr %index, align 4
  br i1 %comparison, label %cond, label %done

done:                                             ; preds = %body, %cond
  %equal = icmp eq i64 %index24, %length23
  %29 = zext i1 %equal to i64
  call void @builtin_assert(i64 %29)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3501063903, label %func_0_dispatch
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
