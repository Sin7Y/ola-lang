; ModuleID = 'AddressExample'
source_filename = "examples/source/storage/storage_address.ola"

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

define void @memcpy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

define i64 @memcmp_eq(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp ugt i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %right_ptr_alloca = alloca ptr, align 8
  %left_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %left_ptr_alloca, align 8
  %left_ptr = load ptr, ptr %left_ptr_alloca, align 8
  store ptr %1, ptr %right_ptr_alloca, align 8
  %right_ptr = load ptr, ptr %right_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %len
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %left_ptr, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %right_ptr, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define void @addressFunction() {
entry:
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
  %1 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %1, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 0, ptr %heap_to_ptr5, align 4
  %2 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 0, ptr %4, align 4
  call void @set_storage(ptr %heap_to_ptr5, ptr %heap_to_ptr)
  ret void
}

define void @setAddress(ptr %0) {
entry:
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = load ptr, ptr %_address, align 8
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
  call void @set_storage(ptr %heap_to_ptr, ptr %1)
  ret void
}

define ptr @getAddress() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %1 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %1, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %2 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %4, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  ret ptr %heap_to_ptr
}

define ptr @get_caller() {
entry:
  %caller_ = alloca ptr, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %caller_, align 8
  %1 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %1, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %index_access6 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  store i64 402443140940559753, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 -5438528055523826848, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 6500940582073311439, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 -6711892513312253938, ptr %index_access9, align 4
  store ptr %heap_to_ptr5, ptr %caller_, align 8
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1977423088, label %func_0_dispatch
    i64 2692808931, label %func_1_dispatch
    i64 826854456, label %func_2_dispatch
    i64 2868727644, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @addressFunction()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  call void @setAddress(ptr %3)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %4 = call ptr @getAddress()
  %5 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %5, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %6 = getelementptr i64, ptr %4, i64 0
  %7 = load i64, ptr %6, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %7, ptr %encode_value_ptr, align 4
  %8 = getelementptr i64, ptr %4, i64 1
  %9 = load i64, ptr %8, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %9, ptr %encode_value_ptr1, align 4
  %10 = getelementptr i64, ptr %4, i64 2
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %11, ptr %encode_value_ptr2, align 4
  %12 = getelementptr i64, ptr %4, i64 3
  %13 = load i64, ptr %12, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %13, ptr %encode_value_ptr3, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 4, ptr %encode_value_ptr4, align 4
  call void @set_tape_data(i64 %heap_start, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %14 = call ptr @get_caller()
  %15 = call i64 @vector_new(i64 5)
  %heap_start5 = sub i64 %15, 5
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %16 = getelementptr i64, ptr %14, i64 0
  %17 = load i64, ptr %16, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr6, i64 0
  store i64 %17, ptr %encode_value_ptr7, align 4
  %18 = getelementptr i64, ptr %14, i64 1
  %19 = load i64, ptr %18, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 %19, ptr %encode_value_ptr8, align 4
  %20 = getelementptr i64, ptr %14, i64 2
  %21 = load i64, ptr %20, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 %21, ptr %encode_value_ptr9, align 4
  %22 = getelementptr i64, ptr %14, i64 3
  %23 = load i64, ptr %22, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 %23, ptr %encode_value_ptr10, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %heap_to_ptr6, i64 4
  store i64 4, ptr %encode_value_ptr11, align 4
  call void @set_tape_data(i64 %heap_start5, i64 5)
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
