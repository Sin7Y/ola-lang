; ModuleID = 'HashContract'
source_filename = "examples/source/types/hash.ola"

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

define void @memory_copy(ptr %0, i64 %1, ptr %2, i64 %3, i64 %4) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %5 = add i64 %1, %index_value
  %src_index_access = getelementptr i64, ptr %0, i64 %5
  %6 = load i64, ptr %src_index_access, align 4
  %7 = add i64 %3, %index_value
  %dest_index_access = getelementptr i64, ptr %2, i64 %7
  store i64 %6, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
}

define void @hash_test() {
entry:
  %h = alloca ptr, align 8
  %0 = call i64 @vector_new(i64 11)
  %heap_start = sub i64 %0, 11
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 10, ptr %heap_to_ptr, align 4
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
  %index_access5 = getelementptr i64, ptr %vector_data, i64 5
  store i64 119, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 6
  store i64 111, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 7
  store i64 114, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 8
  store i64 108, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data, i64 9
  store i64 100, ptr %index_access9, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data10 = inttoptr i64 %4 to ptr
  %5 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %5, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @poseidon_hash(ptr %vector_data10, ptr %heap_to_ptr12, i64 %length)
  store ptr %heap_to_ptr12, ptr %h, align 8
  %6 = load ptr, ptr %h, align 8
  %7 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %7, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  %index_access15 = getelementptr i64, ptr %heap_to_ptr14, i64 0
  store i64 129094667183523914, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 107395124437206779, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 -7568657024057810014, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 1885151562297713155, ptr %index_access18, align 4
  %left_elem_0 = getelementptr i64, ptr %6, i64 0
  %8 = load i64, ptr %left_elem_0, align 4
  %right_elem_0 = getelementptr i64, ptr %heap_to_ptr14, i64 0
  %9 = load i64, ptr %right_elem_0, align 4
  %compare_0 = icmp eq i64 %8, %9
  %10 = zext i1 %compare_0 to i64
  %result_0 = and i64 %10, 1
  %left_elem_1 = getelementptr i64, ptr %6, i64 1
  %11 = load i64, ptr %left_elem_1, align 4
  %right_elem_1 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  %12 = load i64, ptr %right_elem_1, align 4
  %compare_1 = icmp eq i64 %11, %12
  %13 = zext i1 %compare_1 to i64
  %result_1 = and i64 %13, %result_0
  %left_elem_2 = getelementptr i64, ptr %6, i64 2
  %14 = load i64, ptr %left_elem_2, align 4
  %right_elem_2 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  %15 = load i64, ptr %right_elem_2, align 4
  %compare_2 = icmp eq i64 %14, %15
  %16 = zext i1 %compare_2 to i64
  %result_2 = and i64 %16, %result_1
  %left_elem_3 = getelementptr i64, ptr %6, i64 3
  %17 = load i64, ptr %left_elem_3, align 4
  %right_elem_3 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  %18 = load i64, ptr %right_elem_3, align 4
  %compare_3 = icmp eq i64 %17, %18
  %19 = zext i1 %compare_3 to i64
  %result_3 = and i64 %19, %result_2
  call void @builtin_assert(i64 %result_3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1239976900, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @hash_test()
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
