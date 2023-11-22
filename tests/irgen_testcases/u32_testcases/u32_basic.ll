; ModuleID = 'U32BasicTest'
source_filename = "u32_basic"

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

define void @testU32DeclareUninitialized() {
entry:
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}

define void @testU32DeclareInitialized() {
entry:
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}

define void @testU32DeclareThenInitialized() {
entry:
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}

define void @testU32InitializedByOther() {
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

define void @testU32LeftValueExpression() {
entry:
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  store i64 %0, ptr %a, align 4
  %1 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %1, i64 3)
  ret void
}

define void @testU32RightValueExpression() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %a, align 4
  %2 = add i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32AsParameter(i64 %0) {
entry:
  %x = alloca i64, align 8
  store i64 %0, ptr %x, align 4
  %1 = load i64, ptr %x, align 4
  call void @prophet_printf(i64 %1, i64 3)
  ret void
}

define void @testU32CallByValue() {
entry:
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @testU32AsParameter(i64 %0)
  ret void
}

define i64 @testU32AsReturnValue() {
entry:
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  ret i64 %0
}

define i64 @testU32AsReturnConstValue() {
entry:
  ret i64 5
}

define void @testU32AddOperation() {
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

define void @testU32AddAssignOperation() {
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

define void @testU32SubOperation() {
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

define void @testU32SubAssignOperation() {
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

define void @testU32MulOperatoin() {
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

define void @testU32MulAssignOperation() {
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

define void @testU32DivOperation() {
entry:
  %c = alloca i64, align 8
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  store i64 5, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  call void @u32_div_mod(i64 %1, i64 %2, ptr %0, ptr null)
  %3 = load i64, ptr %0, align 4
  store i64 %3, ptr %c, align 4
  %4 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32DivAssignOperation() {
entry:
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  store i64 5, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  call void @u32_div_mod(i64 %1, i64 %2, ptr %0, ptr null)
  %3 = load i64, ptr %0, align 4
  store i64 %3, ptr %a, align 4
  %4 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32ModOperation() {
entry:
  %c = alloca i64, align 8
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  store i64 5, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  call void @u32_div_mod(i64 %1, i64 %2, ptr null, ptr %0)
  %3 = load i64, ptr %0, align 4
  store i64 %3, ptr %c, align 4
  %4 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32ModAssignOperation() {
entry:
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  store i64 5, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  call void @u32_div_mod(i64 %1, i64 %2, ptr null, ptr %0)
  %3 = load i64, ptr %0, align 4
  store i64 %3, ptr %a, align 4
  %4 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32BitWiseXorOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = xor i64 %0, %1
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32BitWiseXorAssignOperation() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = xor i64 %0, %1
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32AndOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = and i64 %0, %1
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32AndAssignOperation() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = and i64 %0, %1
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32BitWiseOrOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = or i64 %0, %1
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32BitWiseOrAssignOperation() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = or i64 %0, %1
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32PowerOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = call i64 @u32_power(i64 %0, i64 %1)
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32LeftShiftOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = call i64 @u32_power(i64 2, i64 %1)
  %3 = mul i64 %0, %2
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %c, align 4
  %4 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32LeftShiftAssignOperation() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = call i64 @u32_power(i64 2, i64 %1)
  %3 = mul i64 %0, %2
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %a, align 4
  %4 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %4, i64 3)
  ret void
}

define void @testU32RightShiftOperation() {
entry:
  %c = alloca i64, align 8
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = call i64 @u32_power(i64 2, i64 %2)
  call void @u32_div_mod(i64 %1, i64 %3, ptr %0, ptr null)
  %4 = load i64, ptr %0, align 4
  store i64 %4, ptr %c, align 4
  %5 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %5, i64 3)
  ret void
}

define void @testU32RightShiftAssignOperation() {
entry:
  %0 = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = call i64 @u32_power(i64 2, i64 %2)
  call void @u32_div_mod(i64 %1, i64 %3, ptr %0, ptr null)
  %4 = load i64, ptr %0, align 4
  store i64 %4, ptr %a, align 4
  %5 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %5, i64 3)
  ret void
}

define void @testU32EqualOperation() {
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

define void @testU32NotEqualOperation() {
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

define void @testU32GreaterOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ugt i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32GreaterEqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp uge i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32LessOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ult i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32LessEqualOperation() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  store i64 10, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ule i64 %0, %1
  store i1 %2, ptr %c, align 1
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32BitWiseNotOperation() {
entry:
  %c = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = sub i64 4294967295, %0
  call void @builtin_range_check(i64 %1)
  store i64 %1, ptr %c, align 4
  %2 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @testU32IncrementOperation() {
entry:
  %a = alloca i64, align 8
  store i64 5, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = add i64 %0, 1
  store i64 %1, ptr %a, align 4
  %2 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %2, i64 3)
  ret void
}

define void @testU32DecrementOperation() {
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

define void @testU32AddOverflow() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 4294967295, ptr %a, align 4
  store i64 1, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = add i64 %0, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %c, align 4
  %3 = load i64, ptr %c, align 4
  call void @prophet_printf(i64 %3, i64 3)
  ret void
}

define void @testU32SubOverflow() {
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

define void @testU32LocalScope() {
entry:
  %a1 = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 15, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  store i64 10, ptr %a1, align 4
  %1 = load i64, ptr %a1, align 4
  call void @prophet_printf(i64 %1, i64 3)
  ret void
}

define void @testU32IfStatement() {
entry:
  %a = alloca i64, align 8
  store i64 10, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  %1 = icmp ugt i64 %0, 5
  br i1 %1, label %then, label %else

then:                                             ; preds = %entry
  %2 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %2, i64 3)
  br label %enif

else:                                             ; preds = %entry
  call void @prophet_printf(i64 0, i64 3)
  br label %enif

enif:                                             ; preds = %else, %then
  ret void
}

define void @testU32InLoopStatement() {
entry:
  %a = alloca i64, align 8
  %i = alloca i64, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %0 = load i64, ptr %i, align 4
  %1 = icmp ult i64 %0, 10
  br i1 %1, label %body, label %endfor

body:                                             ; preds = %cond
  %2 = load i64, ptr %i, align 4
  store i64 %2, ptr %a, align 4
  %3 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %3, i64 3)
  br label %next

next:                                             ; preds = %body
  %4 = load i64, ptr %i, align 4
  %5 = add i64 %4, 1
  store i64 %5, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 2568213180, label %func_0_dispatch
    i64 3750889584, label %func_1_dispatch
    i64 3217688158, label %func_2_dispatch
    i64 3669974209, label %func_3_dispatch
    i64 2925054482, label %func_4_dispatch
    i64 13369587, label %func_5_dispatch
    i64 3691750751, label %func_6_dispatch
    i64 1109964863, label %func_7_dispatch
    i64 3349379350, label %func_8_dispatch
    i64 640212928, label %func_9_dispatch
    i64 1254824970, label %func_10_dispatch
    i64 2123909634, label %func_11_dispatch
    i64 3891384182, label %func_12_dispatch
    i64 4278823459, label %func_13_dispatch
    i64 4222898404, label %func_14_dispatch
    i64 2768553433, label %func_15_dispatch
    i64 4121377594, label %func_16_dispatch
    i64 582781278, label %func_17_dispatch
    i64 1537428472, label %func_18_dispatch
    i64 2123517549, label %func_19_dispatch
    i64 1084753243, label %func_20_dispatch
    i64 3933118057, label %func_21_dispatch
    i64 823271016, label %func_22_dispatch
    i64 1335831410, label %func_23_dispatch
    i64 348789323, label %func_24_dispatch
    i64 519625018, label %func_25_dispatch
    i64 116145519, label %func_26_dispatch
    i64 121752378, label %func_27_dispatch
    i64 1820167102, label %func_28_dispatch
    i64 710601382, label %func_29_dispatch
    i64 2691492679, label %func_30_dispatch
    i64 2109026815, label %func_31_dispatch
    i64 676425142, label %func_32_dispatch
    i64 3963438286, label %func_33_dispatch
    i64 3159649926, label %func_34_dispatch
    i64 1823605095, label %func_35_dispatch
    i64 1423442377, label %func_36_dispatch
    i64 650086011, label %func_37_dispatch
    i64 2900118479, label %func_38_dispatch
    i64 2776752803, label %func_39_dispatch
    i64 1750839130, label %func_40_dispatch
    i64 54477038, label %func_41_dispatch
    i64 93771482, label %func_42_dispatch
    i64 2672728224, label %func_43_dispatch
    i64 2918218605, label %func_44_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @testU32DeclareUninitialized()
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @testU32DeclareInitialized()
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @testU32DeclareThenInitialized()
  ret void

func_3_dispatch:                                  ; preds = %entry
  call void @testU32InitializedByOther()
  ret void

func_4_dispatch:                                  ; preds = %entry
  call void @testU32LeftValueExpression()
  ret void

func_5_dispatch:                                  ; preds = %entry
  call void @testU32RightValueExpression()
  ret void

func_6_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  call void @testU32AsParameter(i64 %decode_value)
  ret void

func_7_dispatch:                                  ; preds = %entry
  call void @testU32CallByValue()
  ret void

func_8_dispatch:                                  ; preds = %entry
  %4 = call i64 @testU32AsReturnValue()
  %5 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %5, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %4, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr1, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %6 = call i64 @testU32AsReturnConstValue()
  %7 = call i64 @vector_new(i64 2)
  %heap_start2 = sub i64 %7, 2
  %heap_to_ptr3 = inttoptr i64 %heap_start2 to ptr
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr3, i64 0
  store i64 %6, ptr %encode_value_ptr4, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr3, i64 1
  store i64 1, ptr %encode_value_ptr5, align 4
  call void @set_tape_data(i64 %heap_start2, i64 2)
  ret void

func_10_dispatch:                                 ; preds = %entry
  call void @testU32AddOperation()
  ret void

func_11_dispatch:                                 ; preds = %entry
  call void @testU32AddAssignOperation()
  ret void

func_12_dispatch:                                 ; preds = %entry
  call void @testU32SubOperation()
  ret void

func_13_dispatch:                                 ; preds = %entry
  call void @testU32SubAssignOperation()
  ret void

func_14_dispatch:                                 ; preds = %entry
  call void @testU32MulOperatoin()
  ret void

func_15_dispatch:                                 ; preds = %entry
  call void @testU32MulAssignOperation()
  ret void

func_16_dispatch:                                 ; preds = %entry
  call void @testU32DivOperation()
  ret void

func_17_dispatch:                                 ; preds = %entry
  call void @testU32DivAssignOperation()
  ret void

func_18_dispatch:                                 ; preds = %entry
  call void @testU32ModOperation()
  ret void

func_19_dispatch:                                 ; preds = %entry
  call void @testU32ModAssignOperation()
  ret void

func_20_dispatch:                                 ; preds = %entry
  call void @testU32BitWiseXorOperation()
  ret void

func_21_dispatch:                                 ; preds = %entry
  call void @testU32BitWiseXorAssignOperation()
  ret void

func_22_dispatch:                                 ; preds = %entry
  call void @testU32AndOperation()
  ret void

func_23_dispatch:                                 ; preds = %entry
  call void @testU32AndAssignOperation()
  ret void

func_24_dispatch:                                 ; preds = %entry
  call void @testU32BitWiseOrOperation()
  ret void

func_25_dispatch:                                 ; preds = %entry
  call void @testU32BitWiseOrAssignOperation()
  ret void

func_26_dispatch:                                 ; preds = %entry
  call void @testU32PowerOperation()
  ret void

func_27_dispatch:                                 ; preds = %entry
  call void @testU32LeftShiftOperation()
  ret void

func_28_dispatch:                                 ; preds = %entry
  call void @testU32LeftShiftAssignOperation()
  ret void

func_29_dispatch:                                 ; preds = %entry
  call void @testU32RightShiftOperation()
  ret void

func_30_dispatch:                                 ; preds = %entry
  call void @testU32RightShiftAssignOperation()
  ret void

func_31_dispatch:                                 ; preds = %entry
  call void @testU32EqualOperation()
  ret void

func_32_dispatch:                                 ; preds = %entry
  call void @testU32NotEqualOperation()
  ret void

func_33_dispatch:                                 ; preds = %entry
  call void @testU32GreaterOperation()
  ret void

func_34_dispatch:                                 ; preds = %entry
  call void @testU32GreaterEqualOperation()
  ret void

func_35_dispatch:                                 ; preds = %entry
  call void @testU32LessOperation()
  ret void

func_36_dispatch:                                 ; preds = %entry
  call void @testU32LessEqualOperation()
  ret void

func_37_dispatch:                                 ; preds = %entry
  call void @testU32BitWiseNotOperation()
  ret void

func_38_dispatch:                                 ; preds = %entry
  call void @testU32IncrementOperation()
  ret void

func_39_dispatch:                                 ; preds = %entry
  call void @testU32DecrementOperation()
  ret void

func_40_dispatch:                                 ; preds = %entry
  call void @testU32AddOverflow()
  ret void

func_41_dispatch:                                 ; preds = %entry
  call void @testU32SubOverflow()
  ret void

func_42_dispatch:                                 ; preds = %entry
  call void @testU32LocalScope()
  ret void

func_43_dispatch:                                 ; preds = %entry
  call void @testU32IfStatement()
  ret void

func_44_dispatch:                                 ; preds = %entry
  call void @testU32InLoopStatement()
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
