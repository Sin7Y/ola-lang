; ModuleID = 'SimpleMappingExample'
source_filename = "examples/source/storage/storage_mapping.ola"

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

define void @add_mapping(ptr %0, i64 %1) {
entry:
  %index_alloca6 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %number = alloca i64, align 8
  %name = alloca ptr, align 8
  store ptr %0, ptr %name, align 8
  store i64 %1, ptr %number, align 4
  %2 = load ptr, ptr %name, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %8 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %heap_to_ptr, i64 %8
  %9 = load i64, ptr %src_index_access, align 4
  %10 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %heap_to_ptr2, i64 %10
  store i64 %9, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca6, align 4
  br label %cond3

cond3:                                            ; preds = %body4, %done
  %index_value7 = load i64, ptr %index_alloca6, align 4
  %loop_cond8 = icmp ult i64 %index_value7, 4
  br i1 %loop_cond8, label %body4, label %done5

body4:                                            ; preds = %cond3
  %11 = add i64 0, %index_value7
  %src_index_access9 = getelementptr i64, ptr %2, i64 %11
  %12 = load i64, ptr %src_index_access9, align 4
  %13 = add i64 4, %index_value7
  %dest_index_access10 = getelementptr i64, ptr %heap_to_ptr2, i64 %13
  store i64 %12, ptr %dest_index_access10, align 4
  %next_index11 = add i64 %index_value7, 1
  store i64 %next_index11, ptr %index_alloca6, align 4
  br label %cond3

done5:                                            ; preds = %cond3
  %14 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %14, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr13, i64 8)
  %15 = load i64, ptr %number, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %16, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %15, ptr %heap_to_ptr15, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %19, align 4
  call void @set_storage(ptr %heap_to_ptr13, ptr %heap_to_ptr15)
  ret void
}

define i64 @get_mapping(ptr %0) {
entry:
  %index_alloca6 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %name = alloca ptr, align 8
  store ptr %0, ptr %name, align 8
  %1 = load ptr, ptr %name, align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %5, align 4
  %6 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %6, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %7 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %heap_to_ptr, i64 %7
  %8 = load i64, ptr %src_index_access, align 4
  %9 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %heap_to_ptr2, i64 %9
  store i64 %8, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca6, align 4
  br label %cond3

cond3:                                            ; preds = %body4, %done
  %index_value7 = load i64, ptr %index_alloca6, align 4
  %loop_cond8 = icmp ult i64 %index_value7, 4
  br i1 %loop_cond8, label %body4, label %done5

body4:                                            ; preds = %cond3
  %10 = add i64 0, %index_value7
  %src_index_access9 = getelementptr i64, ptr %1, i64 %10
  %11 = load i64, ptr %src_index_access9, align 4
  %12 = add i64 4, %index_value7
  %dest_index_access10 = getelementptr i64, ptr %heap_to_ptr2, i64 %12
  store i64 %11, ptr %dest_index_access10, align 4
  %next_index11 = add i64 %index_value7, 1
  store i64 %next_index11, ptr %index_alloca6, align 4
  br label %cond3

done5:                                            ; preds = %cond3
  %13 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %13, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr13, i64 8)
  %14 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %14, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  call void @get_storage(ptr %heap_to_ptr13, ptr %heap_to_ptr15)
  %storage_value = load i64, ptr %heap_to_ptr15, align 4
  ret i64 %storage_value
}

define void @mapping_test() {
entry:
  %myaddress = alloca ptr, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 402443140940559753, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 -5438528055523826848, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 6500940582073311439, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 -6711892513312253938, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %myaddress, align 8
  %1 = load ptr, ptr %myaddress, align 8
  call void @add_mapping(ptr %1, i64 1)
  %2 = load ptr, ptr %myaddress, align 8
  %3 = call i64 @get_mapping(ptr %2)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3327727046, label %func_0_dispatch
    i64 3588912103, label %func_1_dispatch
    i64 1683873080, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 5, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %element = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %value, ptr %element, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %element3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %value2, ptr %element3, align 4
  %start4 = getelementptr i64, ptr %2, i64 2
  %value5 = load i64, ptr %start4, align 4
  %element6 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %value5, ptr %element6, align 4
  %start7 = getelementptr i64, ptr %2, i64 3
  %value8 = load i64, ptr %start7, align 4
  %element9 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %value8, ptr %element9, align 4
  %start10 = getelementptr i64, ptr %2, i64 4
  %value11 = load i64, ptr %start10, align 4
  %5 = icmp ult i64 5, %1
  br i1 %5, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @add_mapping(ptr %heap_to_ptr, i64 %value11)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %6 = icmp ule i64 4, %1
  br i1 %6, label %inbounds12, label %out_of_bounds13

inbounds12:                                       ; preds = %func_1_dispatch
  %7 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %7, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  %start16 = getelementptr i64, ptr %2, i64 0
  %value17 = load i64, ptr %start16, align 4
  %element18 = getelementptr i64, ptr %heap_to_ptr15, i64 0
  store i64 %value17, ptr %element18, align 4
  %start19 = getelementptr i64, ptr %2, i64 1
  %value20 = load i64, ptr %start19, align 4
  %element21 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 %value20, ptr %element21, align 4
  %start22 = getelementptr i64, ptr %2, i64 2
  %value23 = load i64, ptr %start22, align 4
  %element24 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 %value23, ptr %element24, align 4
  %start25 = getelementptr i64, ptr %2, i64 3
  %value26 = load i64, ptr %start25, align 4
  %element27 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 %value26, ptr %element27, align 4
  %8 = icmp ult i64 4, %1
  br i1 %8, label %not_all_bytes_read28, label %buffer_read29

out_of_bounds13:                                  ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read28:                             ; preds = %inbounds12
  unreachable

buffer_read29:                                    ; preds = %inbounds12
  %9 = call i64 @get_mapping(ptr %heap_to_ptr15)
  %10 = call i64 @vector_new(i64 2)
  %heap_start30 = sub i64 %10, 2
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  %start32 = getelementptr i64, ptr %heap_to_ptr31, i64 0
  store i64 %9, ptr %start32, align 4
  %start33 = getelementptr i64, ptr %heap_to_ptr31, i64 1
  store i64 1, ptr %start33, align 4
  call void @set_tape_data(i64 %heap_start30, i64 2)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @mapping_test()
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
