; ModuleID = 'SimpleMappingExample'
source_filename = "storage_mapping_fields"

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
<<<<<<< HEAD
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
=======
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
>>>>>>> 7998cf0 (fixed llvm type bug.)
}

define void @add_mapping() {
entry:
  %0 = alloca ptr, align 8
<<<<<<< HEAD
  %index_alloca27 = alloca i64, align 8
=======
  %index_alloca26 = alloca i64, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %1 = alloca ptr, align 8
  %index_alloca14 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
<<<<<<< HEAD
<<<<<<< HEAD
  %myaddress = alloca ptr, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %3, i64 3
  store i64 -6711892513312253938, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %3, i64 2
  store i64 6500940582073311439, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %3, i64 1
  store i64 -5438528055523826848, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %3, i64 0
  store i64 402443140940559753, ptr %index_access3, align 4
  store ptr %3, ptr %myaddress, align 8
=======
=======
  %myaddress = alloca ptr, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  %3 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %3, i64 0
  store i64 402443140940559753, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %3, i64 1
  store i64 -5438528055523826848, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %3, i64 2
  store i64 6500940582073311439, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %3, i64 3
  store i64 -6711892513312253938, ptr %index_access3, align 4
<<<<<<< HEAD
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  store ptr %3, ptr %myaddress, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  %4 = call ptr @vector_new(i64 5)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %index_access4 = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 3
  store i64 108, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access8, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  %5 = load ptr, ptr %myaddress, align 8
  %6 = call ptr @heap_malloc(i64 4)
  %7 = getelementptr i64, ptr %6, i64 0
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %6, i64 1
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %6, i64 2
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %6, i64 3
  store i64 0, ptr %10, align 4
  %11 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %6, ptr %11, i64 4)
  %12 = getelementptr i64, ptr %11, i64 4
  call void @memcpy(ptr %5, ptr %12, i64 4)
  %13 = getelementptr i64, ptr %12, i64 4
  %14 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %11, ptr %14, i64 8)
  %15 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %14, ptr %15)
  %length = getelementptr i64, ptr %15, i64 3
  %16 = load i64, ptr %length, align 4
  %vector_length = load i64, ptr %4, align 4
  %17 = call ptr @heap_malloc(i64 4)
  %18 = getelementptr i64, ptr %17, i64 0
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %17, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %17, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %17, i64 3
  store i64 %vector_length, ptr %21, align 4
  call void @set_storage(ptr %14, ptr %17)
  %22 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %14, ptr %22, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %22, ptr %2, align 8
=======
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
=======
  %5 = load ptr, ptr %myaddress, align 8
  %6 = call ptr @heap_malloc(i64 4)
  %7 = getelementptr i64, ptr %6, i64 0
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %6, i64 1
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %6, i64 2
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %6, i64 3
  store i64 0, ptr %10, align 4
  %11 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %6, ptr %11, i64 4)
  %12 = getelementptr i64, ptr %11, i64 4
  call void @memcpy(ptr %5, ptr %12, i64 4)
  %13 = getelementptr i64, ptr %12, i64 4
  %14 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %11, ptr %14, i64 8)
  %15 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %14, ptr %15)
  %length = getelementptr i64, ptr %15, i64 3
  %16 = load i64, ptr %length, align 4
  %vector_length = load i64, ptr %4, align 4
  %17 = call ptr @heap_malloc(i64 4)
  %18 = getelementptr i64, ptr %17, i64 0
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %17, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %17, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %17, i64 3
  store i64 %vector_length, ptr %21, align 4
  call void @set_storage(ptr %14, ptr %17)
  %22 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %14, ptr %22, i64 4)
  store i64 0, ptr %index_alloca, align 4
<<<<<<< HEAD
  store ptr %21, ptr %2, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  store ptr %22, ptr %2, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %vector_length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
<<<<<<< HEAD
<<<<<<< HEAD
  %23 = load ptr, ptr %2, align 8
  %vector_data9 = getelementptr i64, ptr %4, i64 1
  %index_access10 = getelementptr ptr, ptr %vector_data9, i64 %index_value
  %24 = load i64, ptr %index_access10, align 4
  %25 = call ptr @heap_malloc(i64 4)
  %26 = getelementptr i64, ptr %25, i64 0
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %25, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %25, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %25, i64 3
  store i64 %24, ptr %29, align 4
  call void @set_storage(ptr %23, ptr %25)
  %30 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %23, ptr %30, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %30, i64 3
  %31 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %31, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store ptr %30, ptr %2, align 8
=======
  %22 = load ptr, ptr %2, align 8
=======
  %23 = load ptr, ptr %2, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  %vector_data9 = getelementptr i64, ptr %4, i64 1
  %index_access10 = getelementptr ptr, ptr %vector_data9, i64 %index_value
  %24 = load i64, ptr %index_access10, align 4
  %25 = call ptr @heap_malloc(i64 4)
  %26 = getelementptr i64, ptr %25, i64 0
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %25, i64 1
  store i64 0, ptr %27, align 4
<<<<<<< HEAD
  %28 = getelementptr i64, ptr %24, i64 3
  store i64 %23, ptr %28, align 4
  call void @set_storage(ptr %22, ptr %24)
  %29 = getelementptr i64, ptr %22, i64 3
  %30 = load i64, ptr %29, align 4
  %slot_offset = add i64 %30, 1
  store i64 %slot_offset, ptr %29, align 4
  store ptr %22, ptr %2, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  %28 = getelementptr i64, ptr %25, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %25, i64 3
  store i64 %24, ptr %29, align 4
  call void @set_storage(ptr %23, ptr %25)
  %30 = getelementptr i64, ptr %23, i64 3
  %31 = load i64, ptr %30, align 4
  %slot_offset = add i64 %31, 1
  store i64 %slot_offset, ptr %30, align 4
  store ptr %23, ptr %2, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %vector_length, ptr %index_alloca14, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  store ptr %22, ptr %1, align 8
=======
  store ptr %21, ptr %1, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  store ptr %22, ptr %1, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  br label %cond11

cond11:                                           ; preds = %body12, %done
  %index_value15 = load i64, ptr %index_alloca14, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  %loop_cond16 = icmp ult i64 %index_value15, %16
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %32 = load ptr, ptr %1, align 8
  %33 = call ptr @heap_malloc(i64 4)
  %storage_zero_ptr = getelementptr i64, ptr %33, i64 0
  store i64 0, ptr %storage_zero_ptr, align 4
  %storage_zero_ptr17 = getelementptr i64, ptr %33, i64 1
  store i64 0, ptr %storage_zero_ptr17, align 4
  %storage_zero_ptr18 = getelementptr i64, ptr %33, i64 2
  store i64 0, ptr %storage_zero_ptr18, align 4
  %storage_zero_ptr19 = getelementptr i64, ptr %33, i64 3
  store i64 0, ptr %storage_zero_ptr19, align 4
  call void @set_storage(ptr %32, ptr %33)
  %34 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %32, ptr %34, i64 4)
  %last_elem_ptr20 = getelementptr i64, ptr %34, i64 3
  %35 = load i64, ptr %last_elem_ptr20, align 4
  %last_elem21 = add i64 %35, 1
  store i64 %last_elem21, ptr %last_elem_ptr20, align 4
  store ptr %34, ptr %1, align 8
  %next_index22 = add i64 %index_value15, 1
  store i64 %next_index22, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  %36 = load ptr, ptr %myaddress, align 8
  %37 = call ptr @heap_malloc(i64 4)
  %38 = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %41, align 4
  %42 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %37, ptr %42, i64 4)
  %43 = getelementptr i64, ptr %42, i64 4
  call void @memcpy(ptr %36, ptr %43, i64 4)
  %44 = getelementptr i64, ptr %43, i64 4
  %45 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %42, ptr %45, i64 8)
  %46 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %45, ptr %46)
  %length23 = getelementptr i64, ptr %46, i64 3
  %47 = load i64, ptr %length23, align 4
  %48 = call ptr @vector_new(i64 %47)
  %49 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %45, ptr %49, i64 4)
  store i64 0, ptr %index_alloca27, align 4
  store ptr %49, ptr %0, align 8
  br label %cond24

cond24:                                           ; preds = %body25, %done13
  %index_value28 = load i64, ptr %index_alloca27, align 4
  %loop_cond29 = icmp ult i64 %index_value28, %47
  br i1 %loop_cond29, label %body25, label %done26

body25:                                           ; preds = %cond24
  %50 = load ptr, ptr %0, align 8
  %vector_data30 = getelementptr i64, ptr %48, i64 1
  %index_access31 = getelementptr ptr, ptr %vector_data30, i64 %index_value28
  %51 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %50, ptr %51)
  %52 = getelementptr i64, ptr %51, i64 3
  %storage_value = load i64, ptr %52, align 4
  %53 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %50, ptr %53, i64 4)
  %last_elem_ptr32 = getelementptr i64, ptr %53, i64 3
  %54 = load i64, ptr %last_elem_ptr32, align 4
  %last_elem33 = add i64 %54, 1
  store i64 %last_elem33, ptr %last_elem_ptr32, align 4
  store i64 %storage_value, ptr %index_access31, align 4
  store ptr %53, ptr %0, align 8
  %next_index34 = add i64 %index_value28, 1
  store i64 %next_index34, ptr %index_alloca27, align 4
  br label %cond24

done26:                                           ; preds = %cond24
  %55 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %45, ptr %55, i64 4)
  %last_elem_ptr35 = getelementptr i64, ptr %55, i64 3
  %56 = load i64, ptr %last_elem_ptr35, align 4
  %last_elem36 = add i64 %56, 1
  store i64 %last_elem36, ptr %last_elem_ptr35, align 4
  %fields_start = ptrtoint ptr %48 to i64
=======
  %loop_cond16 = icmp ult i64 %index_value15, %15
=======
  %loop_cond16 = icmp ult i64 %index_value15, %16
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %32 = load ptr, ptr %1, align 8
  %33 = call ptr @heap_malloc(i64 4)
  %storage_key_ptr = getelementptr i64, ptr %33, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr17 = getelementptr i64, ptr %33, i64 1
  store i64 0, ptr %storage_key_ptr17, align 4
  %storage_key_ptr18 = getelementptr i64, ptr %33, i64 2
  store i64 0, ptr %storage_key_ptr18, align 4
  %storage_key_ptr19 = getelementptr i64, ptr %33, i64 3
  store i64 0, ptr %storage_key_ptr19, align 4
  call void @set_storage(ptr %32, ptr %33)
  %34 = getelementptr i64, ptr %32, i64 3
  %35 = load i64, ptr %34, align 4
  %slot_offset20 = add i64 %35, 1
  store i64 %slot_offset20, ptr %34, align 4
  store ptr %32, ptr %1, align 8
  %next_index21 = add i64 %index_value15, 1
  store i64 %next_index21, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  %36 = load ptr, ptr %myaddress, align 8
  %37 = call ptr @heap_malloc(i64 4)
  %38 = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %37, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %37, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %37, i64 3
  store i64 0, ptr %41, align 4
  %42 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %37, ptr %42, i64 4)
  %43 = getelementptr i64, ptr %42, i64 4
  call void @memcpy(ptr %36, ptr %43, i64 4)
  %44 = getelementptr i64, ptr %43, i64 4
  %45 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %42, ptr %45, i64 8)
  %46 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %45, ptr %46)
  %length22 = getelementptr i64, ptr %46, i64 3
  %47 = load i64, ptr %length22, align 4
  %48 = call ptr @vector_new(i64 %47)
  %49 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %45, ptr %49, i64 4)
  store i64 0, ptr %index_alloca26, align 4
  store ptr %49, ptr %0, align 8
  br label %cond23

cond23:                                           ; preds = %body24, %done13
  %index_value27 = load i64, ptr %index_alloca26, align 4
  %loop_cond28 = icmp ult i64 %index_value27, %47
  br i1 %loop_cond28, label %body24, label %done25

body24:                                           ; preds = %cond23
  %50 = load ptr, ptr %0, align 8
  %vector_data29 = getelementptr i64, ptr %48, i64 1
  %index_access30 = getelementptr ptr, ptr %vector_data29, i64 %index_value27
  %51 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %50, ptr %51)
  %52 = getelementptr i64, ptr %51, i64 3
  %storage_value = load i64, ptr %52, align 4
  %53 = getelementptr i64, ptr %50, i64 3
  %54 = load i64, ptr %53, align 4
  %slot_offset31 = add i64 %54, 1
  store i64 %slot_offset31, ptr %53, align 4
  store i64 %storage_value, ptr %index_access30, align 4
  store ptr %50, ptr %0, align 8
  %next_index32 = add i64 %index_value27, 1
  store i64 %next_index32, ptr %index_alloca26, align 4
  br label %cond23

done25:                                           ; preds = %cond23
<<<<<<< HEAD
  %53 = getelementptr i64, ptr %43, i64 3
  %54 = load i64, ptr %53, align 4
  %slot_offset33 = add i64 %54, 1
  store i64 %slot_offset33, ptr %53, align 4
  %fields_start = ptrtoint ptr %46 to i64
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  %55 = getelementptr i64, ptr %45, i64 3
  %56 = load i64, ptr %55, align 4
  %slot_offset33 = add i64 %56, 1
  store i64 %slot_offset33, ptr %55, align 4
  %fields_start = ptrtoint ptr %48 to i64
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  call void @prophet_printf(i64 %fields_start, i64 0)
  ret void
}

define ptr @get_mapping() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
<<<<<<< HEAD
<<<<<<< HEAD
  %myaddress = alloca ptr, align 8
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 3
  store i64 -6711892513312253937, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 2
  store i64 6500940582073311439, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 1
  store i64 -5438528055523826848, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 0
  store i64 402443140940559753, ptr %index_access3, align 4
  store ptr %1, ptr %myaddress, align 8
  %2 = load ptr, ptr %myaddress, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 0, ptr %7, align 4
  %8 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %3, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = getelementptr i64, ptr %9, i64 4
  %11 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %8, ptr %11, i64 8)
  %12 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %11, ptr %12)
  %length = getelementptr i64, ptr %12, i64 3
  %13 = load i64, ptr %length, align 4
  %14 = call ptr @vector_new(i64 %13)
  %15 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %11, ptr %15, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %15, ptr %0, align 8
=======
=======
  %myaddress = alloca ptr, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 0
  store i64 402443140940559753, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 1
  store i64 -5438528055523826848, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 2
  store i64 6500940582073311439, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 3
  store i64 -6711892513312253937, ptr %index_access3, align 4
  store ptr %1, ptr %myaddress, align 8
  %2 = load ptr, ptr %myaddress, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 0, ptr %7, align 4
  %8 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %3, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  call void @memcpy(ptr %2, ptr %9, i64 4)
  %10 = getelementptr i64, ptr %9, i64 4
  %11 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %8, ptr %11, i64 8)
  %12 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %11, ptr %12)
  %length = getelementptr i64, ptr %12, i64 3
  %13 = load i64, ptr %length, align 4
  %14 = call ptr @vector_new(i64 %13)
  %15 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %11, ptr %15, i64 4)
  store i64 0, ptr %index_alloca, align 4
<<<<<<< HEAD
  store ptr %14, ptr %0, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  store ptr %15, ptr %0, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  %loop_cond = icmp ult i64 %index_value, %13
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %16 = load ptr, ptr %0, align 8
  %vector_data = getelementptr i64, ptr %14, i64 1
  %index_access4 = getelementptr ptr, ptr %vector_data, i64 %index_value
  %17 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %16, ptr %17)
  %18 = getelementptr i64, ptr %17, i64 3
  %storage_value = load i64, ptr %18, align 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %19, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %19, i64 3
  %20 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %20, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store i64 %storage_value, ptr %index_access4, align 4
  store ptr %19, ptr %0, align 8
=======
  %loop_cond = icmp ult i64 %index_value, %12
=======
  %loop_cond = icmp ult i64 %index_value, %13
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %16 = load ptr, ptr %0, align 8
  %vector_data = getelementptr i64, ptr %14, i64 1
  %index_access4 = getelementptr ptr, ptr %vector_data, i64 %index_value
  %17 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %16, ptr %17)
  %18 = getelementptr i64, ptr %17, i64 3
  %storage_value = load i64, ptr %18, align 4
  %19 = getelementptr i64, ptr %16, i64 3
  %20 = load i64, ptr %19, align 4
  %slot_offset = add i64 %20, 1
  store i64 %slot_offset, ptr %19, align 4
  store i64 %storage_value, ptr %index_access4, align 4
<<<<<<< HEAD
  store ptr %15, ptr %0, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  store ptr %16, ptr %0, align 8
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
<<<<<<< HEAD
<<<<<<< HEAD
  %21 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %11, ptr %21, i64 4)
  %last_elem_ptr5 = getelementptr i64, ptr %21, i64 3
  %22 = load i64, ptr %last_elem_ptr5, align 4
  %last_elem6 = add i64 %22, 1
  store i64 %last_elem6, ptr %last_elem_ptr5, align 4
  ret ptr %14
=======
  %20 = getelementptr i64, ptr %10, i64 3
  %21 = load i64, ptr %20, align 4
  %slot_offset5 = add i64 %21, 1
  store i64 %slot_offset5, ptr %20, align 4
  ret ptr %13
>>>>>>> 7998cf0 (fixed llvm type bug.)
=======
  %21 = getelementptr i64, ptr %11, i64 3
  %22 = load i64, ptr %21, align 4
  %slot_offset5 = add i64 %22, 1
  store i64 %slot_offset5, ptr %21, align 4
  ret ptr %14
>>>>>>> 5d414ab (fixed mult dims array decode and encode bug)
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2292892674, label %func_0_dispatch
    i64 3605061393, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @add_mapping()
  %3 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %3, align 4
  call void @set_tape_data(ptr %3, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %4 = call ptr @get_mapping()
  %vector_length = load i64, ptr %4, align 4
  %5 = add i64 %vector_length, 1
  %heap_size = add i64 %5, 1
  %6 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length1 = load i64, ptr %4, align 4
  %7 = add i64 %vector_length1, 1
  call void @memcpy(ptr %4, ptr %6, i64 %7)
  %8 = getelementptr ptr, ptr %6, i64 %7
  store i64 %5, ptr %8, align 4
  call void @set_tape_data(ptr %6, i64 %heap_size)
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
