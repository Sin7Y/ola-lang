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

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define void @setArray1(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca14 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %length = load i64, ptr %0, align 4
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %4 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %4, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %7, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 0, ptr %heap_to_ptr4, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %11, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %length, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  call void @set_storage(ptr %heap_to_ptr4, ptr %heap_to_ptr6)
  %16 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %16, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 0, ptr %heap_to_ptr8, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %19, align 4
  %20 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %20, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr10, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr10, ptr %2, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %21 = load ptr, ptr %2, align 8
  %22 = ptrtoint ptr %0 to i64
  %23 = add i64 %22, 1
  %vector_data = inttoptr i64 %23 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  call void @set_storage(ptr %21, ptr %index_access)
  %24 = getelementptr i64, ptr %21, i64 3
  %slot_value = load i64, ptr %24, align 4
  %25 = add i64 %slot_value, 1
  store i64 %25, ptr %2, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca14, align 4
  store ptr %heap_to_ptr10, ptr %1, align 8
  br label %cond11

cond11:                                           ; preds = %body12, %done
  %index_value15 = load i64, ptr %index_alloca14, align 4
  %loop_cond16 = icmp ult i64 %index_value15, %storage_value
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %26 = load ptr, ptr %1, align 8
  %27 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %27, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr18, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr19 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %storage_key_ptr19, align 4
  %storage_key_ptr20 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %storage_key_ptr20, align 4
  %storage_key_ptr21 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %storage_key_ptr21, align 4
  call void @set_storage(ptr %26, ptr %heap_to_ptr18)
  %28 = getelementptr i64, ptr %26, i64 3
  %slot_value22 = load i64, ptr %28, align 4
  %29 = add i64 %slot_value22, 1
  store i64 %29, ptr %1, align 4
  %next_index23 = add i64 %index_value15, 1
  store i64 %next_index23, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %offset_ptr = alloca i64, align 8
  %index_ptr = alloca i64, align 8
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
  store i64 %size, ptr %heap_to_ptr, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
  %array_elem_num = mul i64 %value, 1
  store i64 0, ptr %index_ptr, align 4
  store i64 1, ptr %offset_ptr, align 4
  br label %loop_body

out_of_bounds:                                    ; preds = %func_0_dispatch
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
  call void @setArray1(ptr %heap_to_ptr)
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
