; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_sum.ola"

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

declare void @prophet_printf(i64, i64)

define i64 @sum(ptr %0) {
entry:
  %i = alloca i64, align 8
  %totalSum = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %inputArray = alloca ptr, align 8
  store ptr %0, ptr %inputArray, align 8
  %1 = load ptr, ptr %inputArray, align 8
  %2 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %2, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data = inttoptr i64 %4 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 10
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %totalSum, align 4
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %5 = load i64, ptr %i, align 4
  %6 = icmp ult i64 %5, 10
  br i1 %6, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %7 = load i64, ptr %i, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %8 = sub i64 %length, 1
  %9 = sub i64 %8, %7
  call void @builtin_range_check(i64 %9)
  %10 = ptrtoint ptr %heap_to_ptr to i64
  %11 = add i64 %10, 1
  %vector_data3 = inttoptr i64 %11 to ptr
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 %7
  %12 = load i64, ptr %i, align 4
  %13 = sub i64 9, %12
  call void @builtin_range_check(i64 %13)
  %index_access5 = getelementptr [10 x i64], ptr %1, i64 0, i64 %12
  %14 = load i64, ptr %index_access5, align 4
  store i64 %14, ptr %index_access4, align 4
  %15 = load i64, ptr %totalSum, align 4
  %16 = load i64, ptr %i, align 4
  %length6 = load i64, ptr %heap_to_ptr, align 4
  %17 = sub i64 %length6, 1
  %18 = sub i64 %17, %16
  call void @builtin_range_check(i64 %18)
  %19 = ptrtoint ptr %heap_to_ptr to i64
  %20 = add i64 %19, 1
  %vector_data7 = inttoptr i64 %20 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 %16
  %21 = load i64, ptr %index_access8, align 4
  %22 = add i64 %15, %21
  call void @builtin_range_check(i64 %22)
  br label %next

next:                                             ; preds = %body2
  %23 = load i64, ptr %i, align 4
  %24 = add i64 %23, 1
  store i64 %24, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  %25 = load i64, ptr %totalSum, align 4
  ret i64 %25
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2898485300, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = call i64 @sum(ptr %3)
  %5 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %5, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %4, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr1, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
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
