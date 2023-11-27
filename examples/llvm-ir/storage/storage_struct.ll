; ModuleID = 'StructExample'
source_filename = "storage_struct"

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

define void @u32_div_mod(i64 %0, i64 %1, ptr %2, ptr %3) {
entry:
  %remainder_alloca = alloca ptr, align 8
  %quotient_alloca = alloca ptr, align 8
  %divisor_alloca = alloca i64, align 8
  %dividend_alloca = alloca i64, align 8
  store i64 %0, ptr %dividend_alloca, align 4
  %dividend = load i64, ptr %dividend_alloca, align 4
  store i64 %1, ptr %divisor_alloca, align 4
  %divisor = load i64, ptr %divisor_alloca, align 4
  store ptr %2, ptr %quotient_alloca, align 8
  %quotient = load ptr, ptr %quotient_alloca, align 8
  store ptr %3, ptr %remainder_alloca, align 8
  %remainder = load ptr, ptr %remainder_alloca, align 8
  %4 = call i64 @prophet_u32_mod(i64 %dividend, i64 %divisor)
  call void @builtin_range_check(i64 %4)
  %5 = add i64 %4, 1
  %6 = sub i64 %divisor, %5
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @prophet_u32_div(i64 %dividend, i64 %divisor)
  call void @builtin_range_check(ptr %quotient)
  %8 = mul i64 %7, %divisor
  %9 = add i64 %8, %4
  %10 = icmp eq i64 %9, %dividend
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  store i64 %7, ptr %quotient, align 4
  store i64 %4, ptr %remainder, align 4
  ret void
}

define i64 @u32_power(i64 %0, i64 %1) {
entry:
  %exponent_alloca = alloca i64, align 8
  %base_alloca = alloca i64, align 8
  store i64 %0, ptr %base_alloca, align 4
  %base = load i64, ptr %base_alloca, align 4
  store i64 %1, ptr %exponent_alloca, align 4
  %exponent = load i64, ptr %exponent_alloca, align 4
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = phi i64 [ 0, %entry ], [ %inc, %loop ]
  %3 = phi i64 [ 1, %entry ], [ %multmp, %loop ]
  %inc = add i64 %2, 1
  %multmp = mul i64 %3, %base
  %loopcond = icmp ule i64 %inc, %exponent
  br i1 %loopcond, label %loop, label %exit

exit:                                             ; preds = %loop
  call void @builtin_range_check(i64 %3)
  ret i64 %3
}

define void @setData(i64 %0, i64 %1) {
entry:
  %_value = alloca i64, align 8
  %_id = alloca i64, align 8
  store i64 %0, ptr %_id, align 4
  store i64 %1, ptr %_value, align 4
  %2 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %2, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 0
  %3 = load i64, ptr %_id, align 4
  store i64 %3, ptr %struct_member, align 4
  %struct_member1 = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 1
  %4 = load i64, ptr %_value, align 4
  store i64 %4, ptr %struct_member1, align 4
  %id = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 0
  %5 = load i64, ptr %id, align 4
  %6 = call i64 @vector_new(i64 4)
  %heap_start2 = sub i64 %6, 4
  %heap_to_ptr3 = inttoptr i64 %heap_start2 to ptr
  store i64 0, ptr %heap_to_ptr3, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr3, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr3, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr3, i64 3
  store i64 0, ptr %9, align 4
  %10 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %10, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 %5, ptr %heap_to_ptr5, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 0, ptr %13, align 4
  call void @set_storage(ptr %heap_to_ptr3, ptr %heap_to_ptr5)
  %value = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr, i32 0, i32 1
  %14 = load i64, ptr %value, align 4
  %15 = call i64 @vector_new(i64 4)
  %heap_start6 = sub i64 %15, 4
  %heap_to_ptr7 = inttoptr i64 %heap_start6 to ptr
  store i64 1, ptr %heap_to_ptr7, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr7, i64 1
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr7, i64 2
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr7, i64 3
  store i64 0, ptr %18, align 4
  %19 = call i64 @vector_new(i64 4)
  %heap_start8 = sub i64 %19, 4
  %heap_to_ptr9 = inttoptr i64 %heap_start8 to ptr
  store i64 %14, ptr %heap_to_ptr9, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr9, i64 1
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr9, i64 2
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr9, i64 3
  store i64 0, ptr %22, align 4
  call void @set_storage(ptr %heap_to_ptr7, ptr %heap_to_ptr9)
  ret void
}

define i64 @getData() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %1 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %1, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 1, ptr %heap_to_ptr2, align 4
  %2 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %4, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  ret i64 %storage_value
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 596322589, label %func_0_dispatch
    i64 819905851, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  %4 = add i64 %input_start, 1
  %5 = inttoptr i64 %4 to ptr
  %decode_value1 = load i64, ptr %5, align 4
  call void @setData(i64 %decode_value, i64 %decode_value1)
  %6 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %6, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  call void @set_tape_data(i64 %heap_start, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = call i64 @getData()
  %8 = call i64 @vector_new(i64 2)
  %heap_start2 = sub i64 %8, 2
  %heap_to_ptr3 = inttoptr i64 %heap_start2 to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr3, i64 0
  store i64 %7, ptr %encode_value_ptr, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr3, i64 1
  store i64 1, ptr %encode_value_ptr4, align 4
  call void @set_tape_data(i64 %heap_start2, i64 2)
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
