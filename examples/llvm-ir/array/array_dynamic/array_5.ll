; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_5.ola"

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

define void @test() {
entry:
  %length3 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %0, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 5, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 5
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_to_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 0
  store i64 1, ptr %index_access2, align 4
  %7 = call i64 @array_call(ptr %heap_to_ptr)
  store i64 %7, ptr %length3, align 4
  %8 = load i64, ptr %length3, align 4
  %9 = icmp eq i64 %8, 5
  %10 = zext i1 %9 to i64
  call void @builtin_assert(i64 %10)
  ret void
}

define i64 @array_call(ptr %0) {
entry:
  %i = alloca i64, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %2 = icmp ult i64 %1, 5
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = load i64, ptr %i, align 4
  %length = load i64, ptr %0, align 4
  %4 = sub i64 %length, 1
  %5 = sub i64 %4, %3
  call void @builtin_range_check(i64 %5)
  %6 = ptrtoint ptr %0 to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %3
  %8 = load i64, ptr %i, align 4
  store i64 %8, ptr %index_access, align 4
  br label %next

next:                                             ; preds = %body
  %9 = load i64, ptr %i, align 4
  %10 = add i64 %9, 1
  call void @builtin_range_check(i64 %10)
  br label %cond

endfor:                                           ; preds = %cond
  %length1 = load i64, ptr %0, align 4
  ret i64 %length1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %offset_ptr = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 1845340408, label %func_0_dispatch
    i64 2934118673, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @test()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %3 = add i64 1, %value
  %4 = icmp ule i64 1, %1
  br i1 %4, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %size = mul i64 %value, 1
  %size_add_one = add i64 %size, 1
  %5 = call i64 @vector_new(i64 %size_add_one)
  %heap_start = sub i64 %5, %size_add_one
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %size, ptr %heap_to_ptr, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
  %array_elem_num = mul i64 %value, 1
  store i64 0, ptr %index_ptr, align 4
  store i64 1, ptr %offset_ptr, align 4
  br label %loop_body

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

loop_body:                                        ; preds = %inbounds1, %inbounds
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr i64, ptr %vector_data, i64 %index
  %offset = load i64, ptr %offset_ptr, align 4
  %8 = add i64 %offset, 1
  %9 = icmp ule i64 %8, %1
  br i1 %9, label %inbounds1, label %out_of_bounds2

loop_end:                                         ; preds = %inbounds1
  %10 = add i64 0, %array_elem_num
  %11 = icmp ule i64 %10, %1
  br i1 %11, label %inbounds5, label %out_of_bounds6

inbounds1:                                        ; preds = %loop_body
  %start3 = getelementptr i64, ptr %2, i64 %offset
  %value4 = load i64, ptr %start3, align 4
  %next_offset = add i64 %offset, 1
  store i64 %next_offset, ptr %offset_ptr, align 4
  store i64 %value4, ptr %element, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %value
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds2:                                   ; preds = %loop_body
  unreachable

inbounds5:                                        ; preds = %loop_end
  %12 = add i64 0, %3
  %13 = icmp ule i64 %12, %1
  br i1 %13, label %inbounds7, label %out_of_bounds8

out_of_bounds6:                                   ; preds = %loop_end
  unreachable

inbounds7:                                        ; preds = %inbounds5
  %14 = add i64 0, %3
  %15 = icmp ult i64 %14, %1
  br i1 %15, label %not_all_bytes_read, label %buffer_read

out_of_bounds8:                                   ; preds = %inbounds5
  unreachable

not_all_bytes_read:                               ; preds = %inbounds7
  unreachable

buffer_read:                                      ; preds = %inbounds7
  %16 = call i64 @array_call(ptr %heap_to_ptr)
  %17 = call i64 @vector_new(i64 2)
  %heap_start9 = sub i64 %17, 2
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  %start11 = getelementptr i64, ptr %heap_to_ptr10, i64 0
  store i64 %16, ptr %start11, align 4
  %start12 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 1, ptr %start12, align 4
  call void @set_tape_data(i64 %heap_start9, i64 2)
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
