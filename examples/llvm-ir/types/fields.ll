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
  %index_alloca23 = alloca i64, align 8
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
  %3 = call i64 @vector_new(i64 6)
  %heap_start5 = sub i64 %3, 6
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 5, ptr %heap_to_ptr6, align 4
  %4 = ptrtoint ptr %heap_to_ptr6 to i64
  %5 = add i64 %4, 1
  %vector_data7 = inttoptr i64 %5 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 0
  store i64 119, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data7, i64 1
  store i64 111, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data7, i64 2
  store i64 114, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data7, i64 3
  store i64 108, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data7, i64 4
  store i64 100, ptr %index_access12, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data13 = inttoptr i64 %7 to ptr
  %length14 = load i64, ptr %heap_to_ptr6, align 4
  %8 = ptrtoint ptr %heap_to_ptr6 to i64
  %9 = add i64 %8, 1
  %vector_data15 = inttoptr i64 %9 to ptr
  %new_len = add i64 %length, %length14
  %size_add_one = add i64 %new_len, 1
  %10 = call i64 @vector_new(i64 %size_add_one)
  %heap_start16 = sub i64 %10, %size_add_one
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 %new_len, ptr %heap_to_ptr17, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access18 = getelementptr i64, ptr %vector_data13, i64 %index_value
  %11 = load i64, ptr %index_access18, align 4
  %12 = add i64 0, %index_value
  %index_access19 = getelementptr i64, ptr %heap_to_ptr17, i64 %12
  store i64 %11, ptr %index_access19, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca23, align 4
  br label %cond20

cond20:                                           ; preds = %body21, %done
  %index_value24 = load i64, ptr %index_alloca23, align 4
  %loop_cond25 = icmp ult i64 %index_value24, %length14
  br i1 %loop_cond25, label %body21, label %done22

body21:                                           ; preds = %cond20
  %index_access26 = getelementptr i64, ptr %vector_data15, i64 %index_value24
  %13 = load i64, ptr %index_access26, align 4
  %14 = add i64 %length, %index_value24
  %index_access27 = getelementptr i64, ptr %heap_to_ptr17, i64 %14
  store i64 %13, ptr %index_access27, align 4
  %next_index28 = add i64 %index_value24, 1
  store i64 %next_index28, ptr %index_alloca23, align 4
  br label %cond20

done22:                                           ; preds = %cond20
  ret ptr %heap_to_ptr17
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
