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

define i64 @sum(ptr %0) {
entry:
  %i = alloca i64, align 8
  %totalSum = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %1 = call i64 @vector_new(i64 11)
  %heap_start = sub i64 %1, 11
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 10, ptr %heap_to_ptr, align 4
  %2 = ptrtoint ptr %heap_to_ptr to i64
  %3 = add i64 %2, 1
  %vector_data = inttoptr i64 %3 to ptr
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
  %4 = load i64, ptr %i, align 4
  %5 = icmp ult i64 %4, 10
  br i1 %5, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %6 = load i64, ptr %i, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %7 = sub i64 %length, 1
  %8 = sub i64 %7, %6
  call void @builtin_range_check(i64 %8)
  %9 = ptrtoint ptr %heap_to_ptr to i64
  %10 = add i64 %9, 1
  %vector_data3 = inttoptr i64 %10 to ptr
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 %6
  %11 = load i64, ptr %i, align 4
  %12 = sub i64 9, %11
  call void @builtin_range_check(i64 %12)
  %index_access5 = getelementptr [10 x i64], ptr %0, i64 0, i64 %11
  %13 = load i64, ptr %index_access5, align 4
  store i64 %13, ptr %index_access4, align 4
  %14 = load i64, ptr %totalSum, align 4
  %15 = load i64, ptr %i, align 4
  %length6 = load i64, ptr %heap_to_ptr, align 4
  %16 = sub i64 %length6, 1
  %17 = sub i64 %16, %15
  call void @builtin_range_check(i64 %17)
  %18 = ptrtoint ptr %heap_to_ptr to i64
  %19 = add i64 %18, 1
  %vector_data7 = inttoptr i64 %19 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 %15
  %20 = load i64, ptr %index_access8, align 4
  %21 = add i64 %14, %20
  call void @builtin_range_check(i64 %21)
  br label %next

next:                                             ; preds = %body2
  %22 = load i64, ptr %i, align 4
  %23 = add i64 %22, 1
  store i64 %23, ptr %i, align 4
  br label %cond1

endfor:                                           ; preds = %cond1
  %24 = load i64, ptr %totalSum, align 4
  ret i64 %24
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %array_literal = alloca [10 x i64], align 8
  switch i64 %0, label %missing_function [
    i64 2898485300, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  store i64 %value, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  store i64 %value2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  %start3 = getelementptr i64, ptr %2, i64 2
  %value4 = load i64, ptr %start3, align 4
  store i64 %value4, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  %start5 = getelementptr i64, ptr %2, i64 3
  %value6 = load i64, ptr %start5, align 4
  store i64 %value6, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  %start7 = getelementptr i64, ptr %2, i64 4
  %value8 = load i64, ptr %start7, align 4
  store i64 %value8, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  %start9 = getelementptr i64, ptr %2, i64 5
  %value10 = load i64, ptr %start9, align 4
  store i64 %value10, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  %start11 = getelementptr i64, ptr %2, i64 6
  %value12 = load i64, ptr %start11, align 4
  store i64 %value12, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  %start13 = getelementptr i64, ptr %2, i64 7
  %value14 = load i64, ptr %start13, align 4
  store i64 %value14, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  %start15 = getelementptr i64, ptr %2, i64 8
  %value16 = load i64, ptr %start15, align 4
  store i64 %value16, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  %start17 = getelementptr i64, ptr %2, i64 9
  %value18 = load i64, ptr %start17, align 4
  store i64 %value18, ptr %elemptr9, align 4
  %3 = icmp ule i64 10, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %4 = icmp ult i64 10, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %5 = call i64 @sum(ptr %array_literal)
  %6 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %6, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start19 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %start19, align 4
  %start20 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start20, align 4
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
