; ModuleID = 'StorageToStorage'
source_filename = "examples/source/storage/storage_array_copy.ola"

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

define void @setArray1(ptr %0) {
entry:
  %1 = alloca [4 x i64], align 8
  %index_alloca4 = alloca i64, align 8
  %2 = alloca [4 x i64], align 8
  %index_alloca = alloca i64, align 8
  %length = load i64, ptr %0, align 4
  %3 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %5)
  %6 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %6, ptr %2, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %7 = load [4 x i64], ptr %2, align 4
  %8 = ptrtoint ptr %0 to i64
  %9 = add i64 %8, 1
  %vector_data = inttoptr i64 %9 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %10 = load i64, ptr %index_access, align 4
  %11 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %10, 3
  call void @set_storage([4 x i64] %7, [4 x i64] %11)
  %12 = extractvalue [4 x i64] %7, 3
  %13 = add i64 %12, 1
  %14 = insertvalue [4 x i64] %7, i64 %13, 3
  store [4 x i64] %14, ptr %2, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca4, align 4
  store [4 x i64] %6, ptr %1, align 4
  br label %cond1

cond1:                                            ; preds = %body2, %done
  %index_value5 = load i64, ptr %index_alloca4, align 4
  %loop_cond6 = icmp ult i64 %index_value5, %4
  br i1 %loop_cond6, label %body2, label %done3

body2:                                            ; preds = %cond1
  %15 = load [4 x i64], ptr %1, align 4
  call void @set_storage([4 x i64] %15, [4 x i64] zeroinitializer)
  %16 = extractvalue [4 x i64] %15, 3
  %17 = add i64 %16, 1
  %18 = insertvalue [4 x i64] %15, i64 %17, 3
  store [4 x i64] %18, ptr %1, align 4
  %next_index7 = add i64 %index_value5, 1
  store i64 %next_index7, ptr %index_alloca4, align 4
  br label %cond1

done3:                                            ; preds = %cond1
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2477870332, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %3 = add i64 1, %value
  %4 = icmp ule i64 1, %1
  br i1 %4, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %size = mul i64 %value, 1
  %size_add_one = add i64 %size, 1
  %5 = call i64 @vector_new(i64 %size_add_one)
  %heap_start = sub i64 %5, %size_add_one
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %value, ptr %heap_to_ptr, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
  %array_elem_num = mul i64 %value, 1
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

loop_body:                                        ; preds = %inbounds1, %inbounds
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr i64, ptr %vector_data, i64 %index
  %8 = icmp ule i64 2, %1
  br i1 %8, label %inbounds1, label %out_of_bounds2

loop_end:                                         ; preds = %inbounds1
  %9 = add i64 0, %array_elem_num
  %10 = icmp ule i64 %9, %1
  br i1 %10, label %inbounds5, label %out_of_bounds6

inbounds1:                                        ; preds = %loop_body
  %start3 = getelementptr i64, ptr %2, i64 1
  %value4 = load i64, ptr %start3, align 4
  store i64 %value4, ptr %element, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %value
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds2:                                   ; preds = %loop_body
  unreachable

inbounds5:                                        ; preds = %loop_end
  %11 = add i64 0, %3
  %12 = icmp ule i64 %11, %1
  br i1 %12, label %inbounds7, label %out_of_bounds8

out_of_bounds6:                                   ; preds = %loop_end
  unreachable

inbounds7:                                        ; preds = %inbounds5
  %13 = add i64 0, %3
  %14 = icmp ult i64 %13, %1
  br i1 %14, label %not_all_bytes_read, label %buffer_read

out_of_bounds8:                                   ; preds = %inbounds5
  unreachable

not_all_bytes_read:                               ; preds = %inbounds7
  unreachable

buffer_read:                                      ; preds = %inbounds7
  call void @setArray1(ptr %heap_to_ptr)
  ret void
}

define void @call() {
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
  %2 = add i64 14, %input_length
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
