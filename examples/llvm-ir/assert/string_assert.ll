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

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

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
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access4, align 4
  %3 = call i64 @vector_new(i64 6)
  %heap_start5 = sub i64 %3, 6
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 5, ptr %heap_to_ptr6, align 4
  %4 = ptrtoint ptr %heap_to_ptr6 to i64
  %5 = add i64 %4, 1
  %vector_data7 = inttoptr i64 %5 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 0
  store i64 104, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data7, i64 1
  store i64 101, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data7, i64 2
  store i64 108, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data7, i64 3
  store i64 108, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data7, i64 4
  store i64 111, ptr %index_access12, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data13 = inttoptr i64 %7 to ptr
  %length = load i64, ptr %heap_to_ptr, align 4
  %8 = ptrtoint ptr %heap_to_ptr6 to i64
  %9 = add i64 %8, 1
  %vector_data14 = inttoptr i64 %9 to ptr
  %length15 = load i64, ptr %heap_to_ptr6, align 4
  %10 = icmp eq i64 %length, %length15
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  store i64 0, ptr %index, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index16 = load i64, ptr %index, align 4
  %12 = icmp ult i64 %index16, %length
  br i1 %12, label %body, label %done

body:                                             ; preds = %cond
  %left_char_ptr = getelementptr i64, ptr %vector_data13, i64 %index16
  %right_char_ptr = getelementptr i64, ptr %vector_data14, i64 %index16
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index = add i64 %index16, 1
  store i64 %next_index, ptr %index, align 4
  br i1 %comparison, label %cond, label %done

done:                                             ; preds = %body, %cond
  %equal = icmp eq i64 %index16, %length15
  %13 = zext i1 %equal to i64
  call void @builtin_assert(i64 %13)
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
