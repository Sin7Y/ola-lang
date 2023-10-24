; ModuleID = 'ArraySlice'
source_filename = "examples/source/array/array_slice.ola"

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

define void @array_slice_test() {
entry:
  %index = alloca i64, align 8
  %index_alloca = alloca i64, align 8
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
  %length = load i64, ptr %heap_to_ptr, align 4
  %array_len_sub_one = sub i64 %length, 1
  %3 = sub i64 %array_len_sub_one, 0
  call void @builtin_range_check(i64 %3)
  %4 = sub i64 %length, 2
  call void @builtin_range_check(i64 %4)
  %5 = call i64 @vector_new(i64 3)
  %heap_start5 = sub i64 %5, 3
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 2, ptr %heap_to_ptr6, align 4
  %6 = ptrtoint ptr %heap_to_ptr6 to i64
  %7 = add i64 %6, 1
  %vector_data7 = inttoptr i64 %7 to ptr
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %9 = add i64 %8, 1
  %vector_data8 = inttoptr i64 %9 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %10 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %vector_data8, i64 %10
  %11 = load i64, ptr %src_index_access, align 4
  %12 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %vector_data7, i64 %12
  store i64 %11, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %13 = ptrtoint ptr %heap_to_ptr6 to i64
  %14 = add i64 %13, 1
  %vector_data9 = inttoptr i64 %14 to ptr
  %length10 = load i64, ptr %heap_to_ptr6, align 4
  %15 = call i64 @vector_new(i64 3)
  %heap_start11 = sub i64 %15, 3
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 2, ptr %heap_to_ptr12, align 4
  %16 = ptrtoint ptr %heap_to_ptr12 to i64
  %17 = add i64 %16, 1
  %vector_data13 = inttoptr i64 %17 to ptr
  %index_access14 = getelementptr i64, ptr %vector_data13, i64 0
  store i64 104, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data13, i64 1
  store i64 101, ptr %index_access15, align 4
  %18 = ptrtoint ptr %heap_to_ptr12 to i64
  %19 = add i64 %18, 1
  %vector_data16 = inttoptr i64 %19 to ptr
  %length17 = load i64, ptr %heap_to_ptr12, align 4
  %20 = icmp eq i64 %length10, %length17
  %21 = zext i1 %20 to i64
  call void @builtin_assert(i64 %21)
  store i64 0, ptr %index, align 4
  br label %cond18

cond18:                                           ; preds = %body19, %done
  %index21 = load i64, ptr %index, align 4
  %22 = icmp ult i64 %index21, %length10
  br i1 %22, label %body19, label %done20

body19:                                           ; preds = %cond18
  %left_char_ptr = getelementptr i64, ptr %vector_data9, i64 %index21
  %right_char_ptr = getelementptr i64, ptr %vector_data16, i64 %index21
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index22 = add i64 %index21, 1
  store i64 %next_index22, ptr %index, align 4
  br i1 %comparison, label %cond18, label %done20

done20:                                           ; preds = %body19, %cond18
  %equal = icmp eq i64 %index21, %length17
  %23 = zext i1 %equal to i64
  call void @builtin_assert(i64 %23)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1458788567, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @array_slice_test()
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
