; ModuleID = 'FieldBasicTest'
source_filename = "field_basic"

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

define void @testFieldDeclareUninitialized() {
entry:
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}

define void @testFieldDeclareInitialized() {
entry:
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}

define void @testFieldDeclareThenInitialized() {
entry:
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}

define void @testFieldInitializedByOther() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  store i64 %0, ptr %b, align 4
  %1 = load i64, ptr %b, align 4
  call void @prophet_printf(i64 %1, i64 3)
  ret void
}

define void @testFieldAsParameter(i64 %0) {
entry:
  %x = alloca i64, align 8
  store i64 %0, ptr %x, align 4
  %1 = load i64, ptr %x, align 4
  call void @prophet_printf(i64 %1, i64 3)
  ret void
}

define void @testFieldCallByValue() {
entry:
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @testFieldAsParameter(i64 %0)
  ret void
}

define i64 @testFieldAsReturnValue() {
entry:
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  ret i64 %0
}

define i64 @testFieldAsReturnConstValue() {
entry:
  ret i64 5
}

define void @testFieldAddOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = add i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldAddAssignOperation() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = add i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldSubOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = sub i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldSubAssignOperation() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = sub i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldMulOperatoin() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = mul i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldMulAssignOperation() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = mul i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldEqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp eq i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldNotEqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ne i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testFieldDecrementOperation() {
entry:
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = sub i64 %0, 1
  store i64 %1, ptr %a, align 4
  %2 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @testFieldAddOverflow() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 -4294967295, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = add i64 %0, 1
  call void @builtin_range_check(i64 %1)
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %b, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @testFieldSubOverflow() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  store i64 1, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = sub i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 152984180, label %func_0_dispatch
    i64 3609461752, label %func_1_dispatch
    i64 3131860681, label %func_2_dispatch
    i64 569873571, label %func_3_dispatch
    i64 1659209820, label %func_4_dispatch
    i64 2579366386, label %func_5_dispatch
    i64 3239687250, label %func_6_dispatch
    i64 1020199043, label %func_7_dispatch
    i64 2485347696, label %func_8_dispatch
    i64 1818912378, label %func_9_dispatch
    i64 768394166, label %func_10_dispatch
    i64 2063831242, label %func_11_dispatch
    i64 3137010963, label %func_12_dispatch
    i64 2675702497, label %func_13_dispatch
    i64 1852256813, label %func_14_dispatch
    i64 2384806460, label %func_15_dispatch
    i64 2173053447, label %func_16_dispatch
    i64 1016974912, label %func_17_dispatch
    i64 2507941948, label %func_18_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @testFieldDeclareUninitialized()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @testFieldDeclareInitialized()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @testFieldDeclareThenInitialized()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_3_dispatch:                                  ; preds = %entry
  call void @testFieldInitializedByOther()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  call void @testFieldAsParameter(i64 %decode_value)
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_5_dispatch:                                  ; preds = %entry
  call void @testFieldCallByValue()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %4 = call i64 @testFieldAsReturnValue()
  %5 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %5, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %4, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr1, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %6 = call i64 @testFieldAsReturnConstValue()
  %7 = call i64 @vector_new(i64 2)
  %heap_start2 = sub i64 %7, 2
  %heap_to_ptr3 = inttoptr i64 %heap_start2 to ptr
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr3, i64 0
  store i64 %6, ptr %encode_value_ptr4, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr3, i64 1
  store i64 1, ptr %encode_value_ptr5, align 4
  call void @set_tape_data(i64 %heap_start2, i64 2)
  ret void

func_8_dispatch:                                  ; preds = %entry
  call void @testFieldAddOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_9_dispatch:                                  ; preds = %entry
  call void @testFieldAddAssignOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_10_dispatch:                                 ; preds = %entry
  call void @testFieldSubOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_11_dispatch:                                 ; preds = %entry
  call void @testFieldSubAssignOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_12_dispatch:                                 ; preds = %entry
  call void @testFieldMulOperatoin()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_13_dispatch:                                 ; preds = %entry
  call void @testFieldMulAssignOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_14_dispatch:                                 ; preds = %entry
  call void @testFieldEqualOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_15_dispatch:                                 ; preds = %entry
  call void @testFieldNotEqualOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_16_dispatch:                                 ; preds = %entry
  call void @testFieldDecrementOperation()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_17_dispatch:                                 ; preds = %entry
  call void @testFieldAddOverflow()
  call void @set_tape_data(i64 0, i64 0)
  ret void

func_18_dispatch:                                 ; preds = %entry
  call void @testFieldSubOverflow()
  call void @set_tape_data(i64 0, i64 0)
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
