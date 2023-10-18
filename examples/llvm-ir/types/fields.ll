; ModuleID = 'FieldsContract'
source_filename = "examples/source/types/fields.ola"

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

define ptr @fields_test() {
entry:
  %index = alloca i64, align 8
  %index_alloca16 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 3, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 111, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 108, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 97, ptr %index_access2, align 4
  %3 = call i64 @vector_new(i64 3)
  %heap_start3 = sub i64 %3, 3
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 2, ptr %heap_to_ptr4, align 4
  %4 = ptrtoint ptr %heap_to_ptr4 to i64
  %5 = add i64 %4, 1
  %vector_data5 = inttoptr i64 %5 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 0
  store i64 118, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data5, i64 1
  store i64 109, ptr %index_access7, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data8 = inttoptr i64 %7 to ptr
  %length9 = load i64, ptr %heap_to_ptr4, align 4
  %8 = ptrtoint ptr %heap_to_ptr4 to i64
  %9 = add i64 %8, 1
  %vector_data10 = inttoptr i64 %9 to ptr
  %new_len = add i64 %length, %length9
  %size_add_one = add i64 %new_len, 1
  %10 = call i64 @vector_new(i64 %size_add_one)
  %heap_start11 = sub i64 %10, %size_add_one
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %new_len, ptr %heap_to_ptr12, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %11 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %vector_data8, i64 %11
  %12 = load i64, ptr %src_index_access, align 4
  %13 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %heap_to_ptr12, i64 %13
  store i64 %12, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca16, align 4
  br label %cond13

cond13:                                           ; preds = %body14, %done
  %index_value17 = load i64, ptr %index_alloca16, align 4
  %loop_cond18 = icmp ult i64 %index_value17, %length9
  br i1 %loop_cond18, label %body14, label %done15

body14:                                           ; preds = %cond13
  %14 = add i64 0, %index_value17
  %src_index_access19 = getelementptr i64, ptr %vector_data10, i64 %14
  %15 = load i64, ptr %src_index_access19, align 4
  %16 = add i64 %length, %index_value17
  %dest_index_access20 = getelementptr i64, ptr %heap_to_ptr12, i64 %16
  store i64 %15, ptr %dest_index_access20, align 4
  %next_index21 = add i64 %index_value17, 1
  store i64 %next_index21, ptr %index_alloca16, align 4
  br label %cond13

done15:                                           ; preds = %cond13
  %17 = ptrtoint ptr %heap_to_ptr12 to i64
  %18 = add i64 %17, 1
  %vector_data22 = inttoptr i64 %18 to ptr
  %length23 = load i64, ptr %heap_to_ptr12, align 4
  %19 = call i64 @vector_new(i64 6)
  %heap_start24 = sub i64 %19, 6
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  store i64 5, ptr %heap_to_ptr25, align 4
  %20 = ptrtoint ptr %heap_to_ptr25 to i64
  %21 = add i64 %20, 1
  %vector_data26 = inttoptr i64 %21 to ptr
  %index_access27 = getelementptr i64, ptr %vector_data26, i64 0
  store i64 111, ptr %index_access27, align 4
  %index_access28 = getelementptr i64, ptr %vector_data26, i64 1
  store i64 108, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %vector_data26, i64 2
  store i64 97, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %vector_data26, i64 3
  store i64 118, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %vector_data26, i64 4
  store i64 109, ptr %index_access31, align 4
  %22 = ptrtoint ptr %heap_to_ptr25 to i64
  %23 = add i64 %22, 1
  %vector_data32 = inttoptr i64 %23 to ptr
  %length33 = load i64, ptr %heap_to_ptr25, align 4
  %24 = icmp eq i64 %length23, %length33
  %25 = zext i1 %24 to i64
  call void @builtin_assert(i64 %25)
  store i64 0, ptr %index, align 4
  br label %cond34

cond34:                                           ; preds = %body35, %done15
  %index37 = load i64, ptr %index, align 4
  %26 = icmp ult i64 %index37, %length23
  br i1 %26, label %body35, label %done36

body35:                                           ; preds = %cond34
  %left_char_ptr = getelementptr i64, ptr %vector_data22, i64 %index37
  %right_char_ptr = getelementptr i64, ptr %vector_data32, i64 %index37
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index38 = add i64 %index37, 1
  store i64 %next_index38, ptr %index, align 4
  br i1 %comparison, label %cond34, label %done36

done36:                                           ; preds = %body35, %cond34
  %equal = icmp eq i64 %index37, %length33
  %27 = zext i1 %equal to i64
  call void @builtin_assert(i64 %27)
  ret ptr %heap_to_ptr12
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3859955665, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @fields_test()
  %length = load i64, ptr %3, align 4
  %4 = add i64 %length, 1
  %heap_size = add i64 %4, 1
  %5 = call i64 @vector_new(i64 %heap_size)
  %heap_start = sub i64 %5, %heap_size
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %length1 = load i64, ptr %3, align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %length1, ptr %start, align 4
  %6 = ptrtoint ptr %3 to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %func_0_dispatch
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr ptr, ptr %vector_data, i64 %index
  %elem = load i64, ptr %element, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %elem, ptr %start2, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %length1
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
  %8 = add i64 %length1, 1
  %9 = add i64 0, %8
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 %9
  store i64 %4, ptr %start3, align 4
  call void @set_tape_data(i64 %heap_start, i64 %heap_size)
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
