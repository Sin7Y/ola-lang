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
  %counter = alloca i64, align 8
  %result = alloca i64, align 8
  store i64 0, ptr %counter, align 4
  store i64 1, ptr %result, align 4
  br label %loop

loop:                                             ; preds = %loop, %entry
  %2 = load i64, ptr %counter, align 4
  %3 = load i64, ptr %result, align 4
  %newCounter = add i64 %2, 1
  %newResult = mul i64 %3, %0
  store i64 %newCounter, ptr %counter, align 4
  store i64 %newResult, ptr %result, align 4
  %condition = icmp ult i64 %newCounter, %1
  br i1 %condition, label %loop, label %exit

exit:                                             ; preds = %loop
  %finalResult = load i64, ptr %result, align 4
  ret i64 %finalResult
}

define ptr @createBooks() {
entry:
  %0 = call ptr @heap_malloc(i64 2)
<<<<<<< HEAD
  %elemptr0 = getelementptr [2 x { i64, i64, ptr }], ptr %0, i64 0, i64 0
=======
  %elemptr0 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %0, i64 0, i64 0
>>>>>>> 7998cf0 (fixed llvm type bug.)
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
<<<<<<< HEAD
  %elem = load { i64, i64, ptr }, ptr %1, align 8
  store { i64, i64, ptr } %elem, ptr %elemptr0, align 8
  %elemptr14 = getelementptr [2 x { i64, i64, ptr }], ptr %0, i64 0, i64 1
=======
  %elem = load { i64, i64, [5 x i64] }, ptr %1, align 4
  store { i64, i64, [5 x i64] } %elem, ptr %elemptr0, align 4
  %elemptr14 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %0, i64 0, i64 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
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
<<<<<<< HEAD
  %elem13 = load { i64, i64, ptr }, ptr %3, align 8
  store { i64, i64, ptr } %elem13, ptr %elemptr14, align 8
=======
  %elem13 = load { i64, i64, [5 x i64] }, ptr %3, align 4
  store { i64, i64, [5 x i64] } %elem13, ptr %elemptr14, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
  ret ptr %0
}

define i64 @getFirstBookID(ptr %0) {
entry:
  %_books = alloca ptr, align 8
  store ptr %0, ptr %_books, align 8
  %1 = load ptr, ptr %_books, align 8
<<<<<<< HEAD
  %index_access = getelementptr [2 x { i64, i64, ptr }], ptr %1, i64 0, i64 0
  %struct_member = getelementptr inbounds { i64, i64, ptr }, ptr %index_access, i32 0, i32 2
=======
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %1, i64 0, i64 0
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %index_access1 = getelementptr [5 x i64], ptr %struct_member, i64 0, i64 1
  %2 = load i64, ptr %index_access1, align 4
  ret i64 %2
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %index_ptr17 = alloca i64, align 8
  %array_ptr = alloca ptr, align 8
  %offset_var = alloca i64, align 8
  %index_ptr1 = alloca i64, align 8
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
  br label %cond

cond:                                             ; preds = %next, %func_0_dispatch
  %4 = load i64, ptr %index_ptr, align 4
  %5 = icmp ult i64 %4, 2
  br i1 %5, label %body, label %end_for

body:                                             ; preds = %cond
  %array_index = load i64, ptr %index_ptr, align 4
  %6 = sub i64 1, %array_index
  call void @builtin_range_check(i64 %6)
<<<<<<< HEAD
  %index_access = getelementptr [2 x { i64, i64, ptr }], ptr %3, i64 0, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %struct_member = getelementptr inbounds { i64, i64, ptr }, ptr %array_element, i32 0, i32 2
=======
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %3, i64 0, i64 %index
  %struct_member = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %7 = load ptr, ptr %struct_member, align 8
  %8 = load i64, ptr %array_size, align 4
  %9 = add i64 %8, 7
  store i64 %9, ptr %array_size, align 4
  br label %next

next:                                             ; preds = %body
  %index = load i64, ptr %index_ptr, align 4
  %10 = add i64 %index, 1
  store i64 %10, ptr %index_ptr, align 4
  br label %cond

end_for:                                          ; preds = %cond
  %11 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %11, 1
  %12 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  store i64 0, ptr %index_ptr1, align 4
  br label %cond2

cond2:                                            ; preds = %next4, %end_for
  %13 = load i64, ptr %index_ptr1, align 4
  %14 = icmp ult i64 %13, 2
  br i1 %14, label %body3, label %end_for5

<<<<<<< HEAD
body3:                                            ; preds = %cond2
  %array_index6 = load i64, ptr %index_ptr1, align 4
  %15 = sub i64 1, %array_index6
  call void @builtin_range_check(i64 %15)
  %index_access7 = getelementptr [2 x { i64, i64, ptr }], ptr %3, i64 0, i64 %array_index6
  %array_element8 = load ptr, ptr %index_access7, align 8
  %16 = load i64, ptr %buffer_offset, align 4
  %17 = getelementptr ptr, ptr %12, i64 %16
  %struct_member9 = getelementptr inbounds { i64, i64, ptr }, ptr %array_element8, i32 0, i32 0
=======
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
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %strcut_member = load i64, ptr %struct_member9, align 4
  %struct_offset = getelementptr ptr, ptr %17, i64 0
  store i64 %strcut_member, ptr %struct_offset, align 4
<<<<<<< HEAD
  %struct_member10 = getelementptr inbounds { i64, i64, ptr }, ptr %array_element8, i32 0, i32 1
  %strcut_member11 = load i64, ptr %struct_member10, align 4
  %struct_offset12 = getelementptr ptr, ptr %struct_offset, i64 1
  store i64 %strcut_member11, ptr %struct_offset12, align 4
  %struct_member13 = getelementptr inbounds { i64, i64, ptr }, ptr %array_element8, i32 0, i32 2
=======
  %struct_member10 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 1
  %strcut_member11 = load i64, ptr %struct_member10, align 4
  %struct_offset12 = getelementptr ptr, ptr %struct_offset, i64 1
  store i64 %strcut_member11, ptr %struct_offset12, align 4
  %struct_member13 = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access8, i32 0, i32 2
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %strcut_member14 = load ptr, ptr %struct_member13, align 8
  %struct_offset15 = getelementptr ptr, ptr %struct_offset12, i64 1
  call void @memcpy(ptr %strcut_member14, ptr %struct_offset15, i64 5)
  %18 = load i64, ptr %buffer_offset, align 4
  %19 = add i64 %18, 7
  store i64 %19, ptr %buffer_offset, align 4
  br label %next4

next4:                                            ; preds = %body3
  %index16 = load i64, ptr %index_ptr1, align 4
  %20 = add i64 %index16, 1
  store i64 %20, ptr %index_ptr1, align 4
  br label %cond2

end_for5:                                         ; preds = %cond2
  %21 = load i64, ptr %buffer_offset, align 4
  %22 = getelementptr ptr, ptr %12, i64 %21
  store i64 %11, ptr %22, align 4
  call void @set_tape_data(ptr %12, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %23 = getelementptr ptr, ptr %2, i64 0
  store i64 0, ptr %offset_var, align 4
  %24 = load i64, ptr %offset_var, align 4
  %25 = load ptr, ptr %array_ptr, align 8
  store i64 0, ptr %index_ptr17, align 4
  br label %cond18

cond18:                                           ; preds = %next20, %func_1_dispatch
  %26 = load i64, ptr %index_ptr17, align 4
  %27 = icmp ult i64 %26, 2
  br i1 %27, label %body19, label %end_for21

<<<<<<< HEAD
body19:                                           ; preds = %cond18
  %28 = load i64, ptr %offset_var, align 4
  %29 = getelementptr ptr, ptr %23, i64 %28
  %decode_struct_field = getelementptr ptr, ptr %29, i64 0
  %30 = load i64, ptr %decode_struct_field, align 4
  %decode_struct_field22 = getelementptr ptr, ptr %29, i64 1
  %31 = load i64, ptr %decode_struct_field22, align 4
  %decode_struct_field23 = getelementptr ptr, ptr %29, i64 2
  %32 = call ptr @heap_malloc(i64 3)
  %struct_member24 = getelementptr inbounds { i64, i64, ptr }, ptr %32, i32 0, i32 0
  store i64 %30, ptr %struct_member24, align 4
  %struct_member25 = getelementptr inbounds { i64, i64, ptr }, ptr %32, i32 0, i32 1
  store i64 %31, ptr %struct_member25, align 4
  %struct_member26 = getelementptr inbounds { i64, i64, ptr }, ptr %32, i32 0, i32 2
  store ptr %decode_struct_field23, ptr %struct_member26, align 8
  %33 = load ptr, ptr %array_ptr, align 8
  %array_index27 = load i64, ptr %index_ptr17, align 4
  %34 = sub i64 1, %array_index27
  call void @builtin_range_check(i64 %34)
  %index_access28 = getelementptr [2 x { i64, i64, ptr }], ptr %33, i64 0, i64 %array_index27
  %array_element29 = load ptr, ptr %index_access28, align 8
  store ptr %32, ptr %index_access28, align 8
  %35 = add i64 7, %28
  store i64 %35, ptr %offset_var, align 4
=======
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
>>>>>>> 7998cf0 (fixed llvm type bug.)
  br label %next20

next20:                                           ; preds = %body19
  %index30 = load i64, ptr %index_ptr17, align 4
  %36 = add i64 %index30, 1
  store i64 %36, ptr %index_ptr17, align 4
  br label %cond18

end_for21:                                        ; preds = %cond18
  %37 = load ptr, ptr %array_ptr, align 8
  %38 = load i64, ptr %offset_var, align 4
  %39 = call i64 @getFirstBookID(ptr %37)
  %40 = call ptr @heap_malloc(i64 2)
  store i64 %39, ptr %40, align 4
  %41 = getelementptr ptr, ptr %40, i64 1
  store i64 1, ptr %41, align 4
  call void @set_tape_data(ptr %40, i64 2)
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
