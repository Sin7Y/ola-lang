; ModuleID = 'StructArrayExample'
source_filename = "dynamic_array_struct"

@heap_address = internal global i64 -12884901885

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @builtin_check_ecdsa(ptr)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @prophet_split_field_high(i64)

declare i64 @prophet_split_field_low(i64)

declare void @get_context_data(ptr, i64)

declare void @get_tape_data(ptr, i64)

declare void @set_tape_data(ptr, i64)

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

declare void @prophet_printf(i64, i64)

define ptr @heap_malloc(i64 %0) {
entry:
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %0
  store i64 %updated_address, ptr @heap_address, align 4
  %1 = inttoptr i64 %current_address to ptr
  ret ptr %1
}

define ptr @vector_new(i64 %0) {
entry:
  %1 = add i64 %0, 1
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %1
  store i64 %updated_address, ptr @heap_address, align 4
  %2 = inttoptr i64 %current_address to ptr
  store i64 %0, ptr %2, align 4
  ret ptr %2
}

define void @split_field(i64 %0, ptr %1, ptr %2) {
entry:
  %3 = call i64 @prophet_split_field_high(i64 %0)
  call void @builtin_range_check(i64 %3)
  %4 = call i64 @prophet_split_field_low(i64 %0)
  call void @builtin_range_check(i64 %4)
  %5 = mul i64 %3, 4294967296
  %6 = add i64 %5, %4
  %7 = icmp eq i64 %0, %6
  %8 = zext i1 %7 to i64
  call void @builtin_assert(i64 %8)
  store i64 %3, ptr %1, align 4
  store i64 %4, ptr %2, align 4
  ret void
}

define void @memcpy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %2
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %0, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %1, i64 %index_value
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
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ne(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp eq i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %right_elem, %left_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @memcmp_ult(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %left_elem, %right_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @memcmp_ule(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare = icmp uge i64 %right_elem, %left_elem
  br i1 %compare, label %cond, label %done

done:                                             ; preds = %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ugt(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %5, %3
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %6, %4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 1, %low_compare_block ], [ 0, %cond ]
  ret i64 %result_phi
}

define i64 @field_memcmp_uge(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %4, %6
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ule(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %5, %3
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %6, %4
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %cond ], [ 0, %body ], [ 0, %low_compare_block ]
  ret i64 %result_phi
}

define i64 @field_memcmp_ult(ptr %0, ptr %1, i64 %2) {
entry:
  %right_low = alloca i64, align 8
  %right_high = alloca i64, align 8
  %left_low = alloca i64, align 8
  %left_high = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %low_compare_block, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_check = icmp ult i64 %index_value, %2
  br i1 %loop_check, label %body, label %done

body:                                             ; preds = %cond
  %left_elem_ptr = getelementptr i64, ptr %0, i64 %index_value
  %left_elem = load i64, ptr %left_elem_ptr, align 4
  %right_elem_ptr = getelementptr i64, ptr %1, i64 %index_value
  %right_elem = load i64, ptr %right_elem_ptr, align 4
  call void @split_field(i64 %left_elem, ptr %left_high, ptr %left_low)
  %3 = load i64, ptr %left_high, align 4
  %4 = load i64, ptr %left_low, align 4
  call void @split_field(i64 %right_elem, ptr %right_high, ptr %right_low)
  %5 = load i64, ptr %right_high, align 4
  %6 = load i64, ptr %right_low, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  %compare_high = icmp uge i64 %3, %5
  br i1 %compare_high, label %low_compare_block, label %done

low_compare_block:                                ; preds = %body
  %compare_low = icmp uge i64 %4, %6
  br i1 %compare_low, label %cond, label %done

done:                                             ; preds = %low_compare_block, %body, %cond
  %result_phi = phi i64 [ 1, %body ], [ 1, %low_compare_block ], [ 0, %cond ]
  ret i64 %result_phi
}

define void @u32_div_mod(i64 %0, i64 %1, ptr %2, ptr %3) {
entry:
  %4 = call i64 @prophet_u32_mod(i64 %0, i64 %1)
  call void @builtin_range_check(i64 %4)
  %5 = add i64 %4, 1
  %6 = sub i64 %1, %5
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @prophet_u32_div(i64 %0, i64 %1)
  call void @builtin_range_check(ptr %2)
  %8 = mul i64 %7, %1
  %9 = add i64 %8, %4
  %10 = icmp eq i64 %9, %0
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  store i64 %7, ptr %2, align 4
  store i64 %4, ptr %3, align 4
  ret void
}

define i64 @u32_power(i64 %0, i64 %1) {
entry:
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = phi i64 [ 0, %entry ], [ %inc, %loop ]
  %3 = phi i64 [ 1, %entry ], [ %multmp, %loop ]
  %inc = add i64 %2, 1
  %multmp = mul i64 %3, %0
  %loopcond = icmp ule i64 %inc, %1
  br i1 %loopcond, label %loop, label %exit

exit:                                             ; preds = %loop
  call void @builtin_range_check(i64 %3)
  ret i64 %3
}

define ptr @createBooks() {
entry:
  %0 = call ptr @heap_malloc(i64 2)
  %elemptr0 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %0, i64 0, i64 0
  %1 = call ptr @heap_malloc(i64 3)
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %1, i32 0, i32 0
  store i64 0, ptr %struct_member, align 4
  %struct_member1 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %1, i32 0, i32 1
  store i64 111, ptr %struct_member1, align 4
  %struct_member2 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %1, i32 0, i32 2
  %2 = call ptr @heap_malloc(i64 5)
  %elemptr03 = getelementptr [5 x i64], ptr %2, i64 0, i64 0
  store i64 1, ptr %elemptr03, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %2, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %2, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %2, i64 0, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %2, i64 0, i64 4
  store i64 5, ptr %elemptr4, align 4
  store ptr %2, ptr %struct_member2, align 8
  %elem = load { i64, i64, [5 x i64] }, ptr %1, align 4
  store { i64, i64, [5 x i64] } %elem, ptr %elemptr0, align 4
  %elemptr14 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %0, i64 0, i64 1
  %3 = call ptr @heap_malloc(i64 3)
  %struct_member5 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %3, i32 0, i32 0
  store i64 0, ptr %struct_member5, align 4
  %struct_member6 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %3, i32 0, i32 1
  store i64 0, ptr %struct_member6, align 4
  %struct_member7 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %3, i32 0, i32 2
  %4 = call ptr @heap_malloc(i64 5)
  %elemptr08 = getelementptr [5 x i64], ptr %4, i64 0, i64 0
  store i64 0, ptr %elemptr08, align 4
  %elemptr19 = getelementptr [5 x i64], ptr %4, i64 0, i64 1
  store i64 0, ptr %elemptr19, align 4
  %elemptr210 = getelementptr [5 x i64], ptr %4, i64 0, i64 2
  store i64 0, ptr %elemptr210, align 4
  %elemptr311 = getelementptr [5 x i64], ptr %4, i64 0, i64 3
  store i64 0, ptr %elemptr311, align 4
  %elemptr412 = getelementptr [5 x i64], ptr %4, i64 0, i64 4
  store i64 0, ptr %elemptr412, align 4
  store ptr %4, ptr %struct_member7, align 8
  %elem13 = load { i64, i64, [5 x i64] }, ptr %3, align 4
  store { i64, i64, [5 x i64] } %elem13, ptr %elemptr14, align 4
  ret ptr %0
}

define i64 @getFirstBookID(ptr %0) {
entry:
  %_books = alloca ptr, align 8
  store ptr %0, ptr %_books, align 8
  %1 = load ptr, ptr %_books, align 8
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %1, i64 0, i64 0
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  %index_access1 = getelementptr [5 x i64], ptr %struct_member, i64 0, i64 1
  %2 = load i64, ptr %index_access1, align 4
  ret i64 %2
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr17 = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %array_offset = alloca i64, align 8
  %index_ptr2 = alloca i64, align 8
  %buffer_offset = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_size = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 4273215651, label %func_0_dispatch
    i64 4248376571, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @createBooks()
  store i64 0, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %4 = icmp ult i64 %index, 2
  br i1 %4, label %body, label %end_for

next:                                             ; preds = %body
  %index1 = load i64, ptr %index_ptr, align 4
  %5 = add i64 %index1, 1
  store i64 %5, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %6 = sub i64 1, %index
  call void @builtin_range_check(i64 %6)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 0, i64 %index
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  %7 = load ptr, ptr %struct_member, align 8
  %8 = load i64, ptr %array_size, align 4
  %9 = add i64 %8, 7
  store i64 %9, ptr %array_size, align 4
  br label %next

end_for:                                          ; preds = %cond
  %10 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %10, 1
  %11 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr2, align 4
  %index3 = load i64, ptr %index_ptr2, align 4
  br label %cond4

cond4:                                            ; preds = %next5, %end_for
  %12 = icmp ult i64 %index3, 2
  br i1 %12, label %body6, label %end_for7

next5:                                            ; preds = %body6
  %index16 = load i64, ptr %index_ptr2, align 4
  %13 = add i64 %index16, 1
  store i64 %13, ptr %index_ptr2, align 4
  br label %cond4

body6:                                            ; preds = %cond4
  %14 = sub i64 1, %index3
  call void @builtin_range_check(i64 %14)
  %index_access8 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 0, i64 %index3
  %15 = load i64, ptr %buffer_offset, align 4
  %16 = getelementptr ptr, ptr %11, i64 %15
  %struct_member9 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 0
  %strcut_member = load i64, ptr %struct_member9, align 4
  %struct_offset = getelementptr ptr, ptr %16, i64 0
  store i64 %strcut_member, ptr %struct_offset, align 4
  %struct_member10 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 1
  %strcut_member11 = load i64, ptr %struct_member10, align 4
  %struct_offset12 = getelementptr ptr, ptr %struct_offset, i64 1
  store i64 %strcut_member11, ptr %struct_offset12, align 4
  %struct_member13 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 2
  %strcut_member14 = load ptr, ptr %struct_member13, align 8
  %struct_offset15 = getelementptr ptr, ptr %struct_offset12, i64 1
  call void @memcpy(ptr %strcut_member14, ptr %struct_offset15, i64 5)
  %17 = load i64, ptr %buffer_offset, align 4
  %18 = add i64 %17, 7
  store i64 %18, ptr %buffer_offset, align 4
  br label %next5

end_for7:                                         ; preds = %cond4
  %19 = load i64, ptr %buffer_offset, align 4
  %20 = getelementptr ptr, ptr %11, i64 %19
  store i64 %10, ptr %20, align 4
  call void @set_tape_data(ptr %11, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %21 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %array_offset, align 4
  %22 = call ptr @heap_malloc(i64 0)
  store ptr %22, ptr %array_ptr, align 8
  %23 = load i64, ptr %array_offset, align 4
  store i64 0, ptr %index_ptr17, align 4
  %index18 = load i64, ptr %index_ptr17, align 4
  br label %cond19

cond19:                                           ; preds = %next20, %func_1_dispatch
  %24 = icmp ult i64 %index18, 2
  br i1 %24, label %body21, label %end_for22

next20:                                           ; preds = %body21
  %index29 = load i64, ptr %index_ptr17, align 4
  %25 = add i64 %index29, 1
  store i64 %25, ptr %index_ptr17, align 4
  br label %cond19

body21:                                           ; preds = %cond19
  %decode_struct_field = getelementptr ptr, ptr %21, i64 0
  %26 = load i64, ptr %decode_struct_field, align 4
  %decode_struct_field23 = getelementptr ptr, ptr %21, i64 1
  %27 = load i64, ptr %decode_struct_field23, align 4
  %decode_struct_field24 = getelementptr ptr, ptr %21, i64 2
  %28 = call ptr @heap_malloc(i64 3)
  %struct_member25 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %28, i32 0, i32 0
  store i64 %26, ptr %struct_member25, align 4
  %struct_member26 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %28, i32 0, i32 1
  store i64 %27, ptr %struct_member26, align 4
  %struct_member27 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %28, i32 0, i32 2
  store ptr %decode_struct_field24, ptr %struct_member27, align 8
  %29 = load ptr, ptr %array_ptr, align 8
  %30 = sub i64 1, %index18
  call void @builtin_range_check(i64 %30)
  %index_access28 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %29, i64 0, i64 %index18
  store ptr %28, ptr %index_access28, align 8
  %31 = add i64 7, %23
  store i64 %31, ptr %array_offset, align 4
  br label %next20

end_for22:                                        ; preds = %cond19
  %32 = load ptr, ptr %array_ptr, align 8
  %33 = load i64, ptr %array_offset, align 4
  %34 = call i64 @getFirstBookID(ptr %32)
  %35 = call ptr @heap_malloc(i64 2)
  store i64 %34, ptr %35, align 4
  %36 = getelementptr ptr, ptr %35, i64 1
  store i64 1, ptr %36, align 4
  call void @set_tape_data(ptr %35, i64 2)
  ret void
}

define void @main() {
entry:
  %0 = call ptr @heap_malloc(i64 13)
  call void @get_tape_data(ptr %0, i64 13)
  %function_selector = load i64, ptr %0, align 4
  %1 = call ptr @heap_malloc(i64 14)
  call void @get_tape_data(ptr %1, i64 14)
  %input_length = load i64, ptr %1, align 4
  %2 = add i64 %input_length, 14
  %3 = call ptr @heap_malloc(i64 %2)
  call void @get_tape_data(ptr %3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %3)
  ret void
}
