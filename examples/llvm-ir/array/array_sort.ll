; ModuleID = 'ArraySortExample'
source_filename = "examples/source/array/array_sort.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry:
  %array_literal = alloca [10 x i64], align 8
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  store i64 3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  store i64 4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  store i64 5, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  store i64 1, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  store i64 7, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  store i64 9, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  store i64 0, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  store i64 2, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  store i64 6, ptr %elemptr9, align 4
  %0 = call ptr @array_sort_test(ptr %array_literal)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %1 = sub i64 %length, 1
  %2 = sub i64 %1, 0
  call void @builtin_range_check(i64 %2)
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %3 = sub i64 %length2, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %data3 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access4 = getelementptr i64, ptr %data3, i64 0
  %5 = load i64, ptr %index_access4, align 4
  %6 = add i64 %5, 1
  call void @builtin_range_check(i64 %6)
  store i64 %6, ptr %index_access, align 4
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %7 = sub i64 %length6, 1
  %8 = sub i64 %7, 1
  call void @builtin_range_check(i64 %8)
  %data7 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access8 = getelementptr i64, ptr %data7, i64 1
  %vector_len9 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length10 = load i64, ptr %vector_len9, align 4
  %9 = sub i64 %length10, 1
  %10 = sub i64 %9, 1
  call void @builtin_range_check(i64 %10)
  %data11 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access12 = getelementptr i64, ptr %data11, i64 1
  %11 = load i64, ptr %index_access12, align 4
  %12 = sub i64 %11, 1
  call void @builtin_range_check(i64 %12)
  store i64 %12, ptr %index_access8, align 4
  ret void
}

define ptr @array_sort_test(ptr %0) {
entry:
  %i = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  %1 = call i64 @vector_new(i64 10)
  %heap_ptr = sub i64 %1, 10
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 10
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %2 = call ptr @vector_new_init(i64 10, ptr %int_to_ptr)
  store i64 0, ptr %i, align 4
  br label %cond1

cond1:                                            ; preds = %next, %done
  %3 = load i64, ptr %i, align 4
  %4 = icmp ult i64 %3, 10
  br i1 %4, label %body2, label %endfor

body2:                                            ; preds = %cond1
  %5 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %2, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %6 = sub i64 %length, 1
  %7 = sub i64 %6, %5
  call void @builtin_range_check(i64 %7)
  %data = getelementptr inbounds { i64, ptr }, ptr %2, i32 0, i32 1
  %index_access3 = getelementptr i64, ptr %data, i64 %5
  %8 = load i64, ptr %i, align 4
  %9 = sub i64 9, %8
  call void @builtin_range_check(i64 %9)
  %index_access4 = getelementptr [10 x i64], ptr %source, i64 0, i64 %8
  %10 = load i64, ptr %index_access4, align 4
  store i64 %10, ptr %index_access3, align 4
  br label %next

next:                                             ; preds = %body2
  %11 = load i64, ptr %i, align 4
  %12 = add i64 %11, 1
  call void @builtin_range_check(i64 %12)
  br label %cond1

endfor:                                           ; preds = %cond1
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %2, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %13 = call ptr @prophet_u32_array_sort(ptr %2, i64 %length6)
  ret ptr %13
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  %array_literal = alloca [10 x i64], align 8
  switch i64 %0, label %missing_function [
    i64 3501063903, label %func_0_dispatch
    i64 1940129018, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @main()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  %3 = call i64 @tape_load(i64 %2, i64 0)
  store i64 %3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  %4 = call i64 @tape_load(i64 %2, i64 1)
  store i64 %4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  %5 = call i64 @tape_load(i64 %2, i64 2)
  store i64 %5, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  %6 = call i64 @tape_load(i64 %2, i64 3)
  store i64 %6, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  %7 = call i64 @tape_load(i64 %2, i64 4)
  store i64 %7, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  %8 = call i64 @tape_load(i64 %2, i64 5)
  store i64 %8, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  %9 = call i64 @tape_load(i64 %2, i64 6)
  store i64 %9, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  %10 = call i64 @tape_load(i64 %2, i64 7)
  store i64 %10, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  %11 = call i64 @tape_load(i64 %2, i64 8)
  store i64 %11, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  %12 = call i64 @tape_load(i64 %2, i64 9)
  store i64 %12, ptr %elemptr9, align 4
  %13 = icmp ule i64 10, %1
  br i1 %13, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %14 = icmp ult i64 10, %1
  br i1 %14, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %15 = call ptr @array_sort_test(ptr %array_literal)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %15, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  call void @tape_store(i64 0, i64 %length)
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

loop_body:                                        ; preds = %loop_body, %buffer_read
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr { i64, ptr }, ptr %15, i64 %index
  %elem = load i64, ptr %element, align 4
  call void @tape_store(i64 1, i64 %elem)
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %length
  br i1 %index_cond, label %loop_body, label %loop_end

loop_end:                                         ; preds = %loop_body
  %16 = add i64 %length, 1
  %17 = add i64 0, %16
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
