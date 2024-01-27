; ModuleID = 'ContractDeployer'
source_filename = "ContractDeployer"

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

define i64 @extendedAccountVersion(ptr %0) {
entry:
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = load ptr, ptr %_address, align 8
  %2 = call ptr @heap_malloc(i64 4)
  %3 = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %2, i64 3
  store i64 0, ptr %6, align 4
  %7 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %2, ptr %7, i64 4)
  %8 = getelementptr i64, ptr %7, i64 4
  call void @memcpy(ptr %1, ptr %8, i64 4)
  %9 = getelementptr i64, ptr %8, i64 4
  %10 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %7, ptr %10, i64 8)
  %11 = call ptr @heap_malloc(i64 2)
  %12 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %12)
  %13 = getelementptr i64, ptr %12, i64 3
  %storage_value = load i64, ptr %13, align 4
<<<<<<< HEAD
  %14 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %10, ptr %14, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %14, i64 3
  %15 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %15, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %supportedAAVersion = getelementptr inbounds { i64, i64 }, ptr %11, i32 0, i32 0
  store i64 %storage_value, ptr %supportedAAVersion, align 4
  %16 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %14, ptr %16)
  %17 = getelementptr i64, ptr %16, i64 3
  %storage_value1 = load i64, ptr %17, align 4
  %18 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %14, ptr %18, i64 4)
  %last_elem_ptr2 = getelementptr i64, ptr %18, i64 3
  %19 = load i64, ptr %last_elem_ptr2, align 4
  %last_elem3 = add i64 %19, 1
  store i64 %last_elem3, ptr %last_elem_ptr2, align 4
=======
  %14 = getelementptr i64, ptr %10, i64 3
  %15 = load i64, ptr %14, align 4
  %slot_offset = add i64 %15, 1
  store i64 %slot_offset, ptr %14, align 4
  %supportedAAVersion = getelementptr inbounds { i64, i64 }, ptr %11, i32 0, i32 0
  store i64 %storage_value, ptr %supportedAAVersion, align 4
  %16 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %16)
  %17 = getelementptr i64, ptr %16, i64 3
  %storage_value1 = load i64, ptr %17, align 4
  %18 = getelementptr i64, ptr %10, i64 3
  %19 = load i64, ptr %18, align 4
  %slot_offset2 = add i64 %19, 1
  store i64 %slot_offset2, ptr %18, align 4
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
  %nonceOrdering = getelementptr inbounds { i64, i64 }, ptr %11, i32 0, i32 1
  store i64 %storage_value1, ptr %nonceOrdering, align 4
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %11, i32 0, i32 0
  %20 = load i64, ptr %struct_member, align 4
  %21 = icmp ne i64 %20, 0
  br i1 %21, label %then, label %endif

then:                                             ; preds = %entry
<<<<<<< HEAD
  %struct_member4 = getelementptr inbounds { i64, i64 }, ptr %11, i32 0, i32 0
  %22 = load i64, ptr %struct_member4, align 4
=======
  %struct_member3 = getelementptr inbounds { i64, i64 }, ptr %11, i32 0, i32 0
  %22 = load i64, ptr %struct_member3, align 4
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
  ret i64 %22

endif:                                            ; preds = %entry
  %23 = call ptr @heap_malloc(i64 4)
<<<<<<< HEAD
  %index_access = getelementptr i64, ptr %23, i64 3
  store i64 32770, ptr %index_access, align 4
  %index_access5 = getelementptr i64, ptr %23, i64 2
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %23, i64 1
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %23, i64 0
  store i64 0, ptr %index_access7, align 4
=======
  %index_access = getelementptr i64, ptr %23, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access4 = getelementptr i64, ptr %23, i64 1
  store i64 0, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %23, i64 2
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %23, i64 3
  store i64 32770, ptr %index_access6, align 4
<<<<<<< HEAD
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
  store ptr %23, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %24 = load ptr, ptr %_address, align 8
  %25 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %25, i64 1
  %26 = getelementptr i64, ptr %24, i64 0
  %27 = load i64, ptr %26, align 4
  %28 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %27, ptr %28, align 4
  %29 = getelementptr i64, ptr %24, i64 1
  %30 = load i64, ptr %29, align 4
  %31 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %30, ptr %31, align 4
  %32 = getelementptr i64, ptr %24, i64 2
  %33 = load i64, ptr %32, align 4
  %34 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %33, ptr %34, align 4
  %35 = getelementptr i64, ptr %24, i64 3
  %36 = load i64, ptr %35, align 4
  %37 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %36, ptr %37, align 4
  %38 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %38, align 4
  %39 = getelementptr ptr, ptr %38, i64 1
  store i64 2179613704, ptr %39, align 4
  %40 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %vector_length = load i64, ptr %25, align 4
<<<<<<< HEAD
  %vector_data8 = getelementptr i64, ptr %25, i64 1
  call void @set_tape_data(ptr %vector_data8, i64 %vector_length)
=======
  %vector_data7 = getelementptr i64, ptr %25, i64 1
  call void @set_tape_data(ptr %vector_data7, i64 %vector_length)
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
  call void @contract_call(ptr %40, i64 0)
  %41 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %41, i64 1)
  %return_length = load i64, ptr %41, align 4
=======
  %24 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %24, i64 1
  %25 = getelementptr i64, ptr %1, i64 0
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %26, ptr %27, align 4
  %28 = getelementptr i64, ptr %1, i64 1
  %29 = load i64, ptr %28, align 4
  %30 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %29, ptr %30, align 4
  %31 = getelementptr i64, ptr %1, i64 2
  %32 = load i64, ptr %31, align 4
  %33 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %32, ptr %33, align 4
  %34 = getelementptr i64, ptr %1, i64 3
  %35 = load i64, ptr %34, align 4
  %36 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %35, ptr %36, align 4
  %37 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %37, align 4
  %38 = getelementptr ptr, ptr %37, i64 1
  store i64 2179613704, ptr %38, align 4
  %vector_length = load i64, ptr %24, align 4
  %vector_data7 = getelementptr i64, ptr %24, i64 1
  call void @set_tape_data(ptr %vector_data7, i64 %vector_length)
  call void @contract_call(ptr %23, i64 0)
  %39 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %39, i64 1)
  %return_length = load i64, ptr %39, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %40 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %40, align 4
  %return_data_start = getelementptr i64, ptr %40, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  %vector_data9 = getelementptr i64, ptr %42, i64 1
  %43 = getelementptr ptr, ptr %vector_data9, i64 0
  store ptr %43, ptr %codeHash, align 8
  %44 = load ptr, ptr %codeHash, align 8
  %45 = call ptr @heap_malloc(i64 4)
  %index_access10 = getelementptr i64, ptr %45, i64 3
  store i64 0, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %45, i64 2
  store i64 0, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %45, i64 1
  store i64 0, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %45, i64 0
  store i64 0, ptr %index_access13, align 4
  %46 = call i64 @memcmp_eq(ptr %44, ptr %45, i64 4)
  %47 = trunc i64 %46 to i1
  br i1 %47, label %then14, label %endif15
=======
  %vector_data9 = getelementptr i64, ptr %35, i64 1
  %36 = getelementptr ptr, ptr %vector_data9, i64 0
  store ptr %36, ptr %codeHash, align 8
  %37 = load ptr, ptr %codeHash, align 8
  %38 = call ptr @heap_malloc(i64 4)
  %index_access10 = getelementptr i64, ptr %38, i64 0
=======
  %vector_data8 = getelementptr i64, ptr %42, i64 1
  %43 = getelementptr ptr, ptr %vector_data8, i64 0
  store ptr %43, ptr %codeHash, align 8
  %44 = load ptr, ptr %codeHash, align 8
  %45 = call ptr @heap_malloc(i64 4)
  %index_access9 = getelementptr i64, ptr %45, i64 0
  store i64 0, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %45, i64 1
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %vector_data8 = getelementptr i64, ptr %40, i64 1
  %41 = getelementptr ptr, ptr %vector_data8, i64 0
  %42 = call ptr @heap_malloc(i64 4)
  %index_access9 = getelementptr i64, ptr %42, i64 0
  store i64 0, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %42, i64 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  store i64 0, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %42, i64 2
  store i64 0, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %42, i64 3
  store i64 0, ptr %index_access12, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  %index_access13 = getelementptr i64, ptr %38, i64 3
  store i64 0, ptr %index_access13, align 4
  %39 = call i64 @memcmp_eq(ptr %37, ptr %38, i64 4)
  %40 = trunc i64 %39 to i1
  br i1 %40, label %then14, label %endif15
>>>>>>> 83491ee (update examples out files.)
=======
  %46 = call i64 @memcmp_eq(ptr %44, ptr %45, i64 4)
  %47 = trunc i64 %46 to i1
  br i1 %47, label %then13, label %endif14
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
=======
  %43 = call i64 @memcmp_eq(ptr %41, ptr %42, i64 4)
  %44 = trunc i64 %43 to i1
  br i1 %44, label %then13, label %endif14
>>>>>>> 7998cf0 (fixed llvm type bug.)

then13:                                           ; preds = %endif
  ret i64 1

endif14:                                          ; preds = %endif
  ret i64 0
}

define ptr @create2(ptr %0, ptr %1, ptr %2, ptr %3) {
entry:
  %_input = alloca ptr, align 8
  %_codeHash = alloca ptr, align 8
  %_rawHash = alloca ptr, align 8
  %_salt = alloca ptr, align 8
  store ptr %0, ptr %_salt, align 8
  %4 = load ptr, ptr %_salt, align 8
  store ptr %1, ptr %_rawHash, align 8
  %5 = load ptr, ptr %_rawHash, align 8
  store ptr %2, ptr %_codeHash, align 8
  %6 = load ptr, ptr %_codeHash, align 8
  store ptr %3, ptr %_input, align 8
  %7 = load ptr, ptr %_input, align 8
  %8 = call ptr @create2Account(ptr %4, ptr %5, ptr %6, ptr %7, i64 0)
  ret ptr %8
}

define ptr @create2Account(ptr %0, ptr %1, ptr %2, ptr %3, i64 %4) {
entry:
  %_aaVersion = alloca i64, align 8
  %_input = alloca ptr, align 8
  %_codeHash = alloca ptr, align 8
  %_rawHash = alloca ptr, align 8
  %_salt = alloca ptr, align 8
  store ptr %0, ptr %_salt, align 8
  %5 = load ptr, ptr %_salt, align 8
  store ptr %1, ptr %_rawHash, align 8
  %6 = load ptr, ptr %_rawHash, align 8
  store ptr %2, ptr %_codeHash, align 8
  %7 = load ptr, ptr %_codeHash, align 8
  store ptr %3, ptr %_input, align 8
  %8 = load ptr, ptr %_input, align 8
  store i64 %4, ptr %_aaVersion, align 4
  %9 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %9, i64 12)
  %10 = call ptr @getNewAddressCreate2(ptr %9, ptr %7, ptr %5, ptr %8)
  %11 = load i64, ptr %_aaVersion, align 4
  call void @_nonSystemDeployOnAddress(ptr %6, ptr %7, ptr %10, i64 %11, ptr %8)
  ret ptr %10
}

define ptr @getNewAddressCreate2(ptr %0, ptr %1, ptr %2, ptr %3) {
entry:
  %_input = alloca ptr, align 8
  %_salt = alloca ptr, align 8
  %_codeHash = alloca ptr, align 8
  %_from = alloca ptr, align 8
  store ptr %0, ptr %_from, align 8
  %4 = load ptr, ptr %_from, align 8
  store ptr %1, ptr %_codeHash, align 8
  %5 = load ptr, ptr %_codeHash, align 8
  store ptr %2, ptr %_salt, align 8
  %6 = load ptr, ptr %_salt, align 8
  store ptr %3, ptr %_input, align 8
  %7 = load ptr, ptr %_input, align 8
  %8 = call ptr @vector_new(i64 10)
  %vector_data = getelementptr i64, ptr %8, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 79, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 108, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 97, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 67, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 114, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 5
  store i64 101, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 6
  store i64 97, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 7
  store i64 116, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 8
  store i64 101, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data, i64 9
  store i64 50, ptr %index_access9, align 4
  %vector_length = load i64, ptr %8, align 4
  %vector_data10 = getelementptr i64, ptr %8, i64 1
  %9 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data10, ptr %9, i64 %vector_length)
  %vector_length11 = load i64, ptr %7, align 4
  %vector_data12 = getelementptr i64, ptr %7, i64 1
  %10 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data12, ptr %10, i64 %vector_length11)
  %11 = call ptr @vector_new(i64 20)
  %12 = getelementptr ptr, ptr %11, i64 1
  %13 = getelementptr i64, ptr %9, i64 0
  %14 = load i64, ptr %13, align 4
  %15 = getelementptr i64, ptr %12, i64 0
  store i64 %14, ptr %15, align 4
  %16 = getelementptr i64, ptr %9, i64 1
  %17 = load i64, ptr %16, align 4
  %18 = getelementptr i64, ptr %12, i64 1
  store i64 %17, ptr %18, align 4
  %19 = getelementptr i64, ptr %9, i64 2
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %12, i64 2
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %9, i64 3
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %12, i64 3
  store i64 %23, ptr %24, align 4
  %25 = getelementptr ptr, ptr %12, i64 4
  %26 = getelementptr i64, ptr %4, i64 0
  %27 = load i64, ptr %26, align 4
  %28 = getelementptr i64, ptr %25, i64 0
  store i64 %27, ptr %28, align 4
  %29 = getelementptr i64, ptr %4, i64 1
  %30 = load i64, ptr %29, align 4
  %31 = getelementptr i64, ptr %25, i64 1
  store i64 %30, ptr %31, align 4
  %32 = getelementptr i64, ptr %4, i64 2
  %33 = load i64, ptr %32, align 4
  %34 = getelementptr i64, ptr %25, i64 2
  store i64 %33, ptr %34, align 4
  %35 = getelementptr i64, ptr %4, i64 3
  %36 = load i64, ptr %35, align 4
  %37 = getelementptr i64, ptr %25, i64 3
  store i64 %36, ptr %37, align 4
  %38 = getelementptr ptr, ptr %25, i64 4
  %39 = getelementptr i64, ptr %6, i64 0
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %38, i64 0
  store i64 %40, ptr %41, align 4
  %42 = getelementptr i64, ptr %6, i64 1
  %43 = load i64, ptr %42, align 4
  %44 = getelementptr i64, ptr %38, i64 1
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %6, i64 2
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %38, i64 2
  store i64 %46, ptr %47, align 4
  %48 = getelementptr i64, ptr %6, i64 3
  %49 = load i64, ptr %48, align 4
  %50 = getelementptr i64, ptr %38, i64 3
  store i64 %49, ptr %50, align 4
  %51 = getelementptr ptr, ptr %38, i64 4
  %52 = getelementptr i64, ptr %5, i64 0
  %53 = load i64, ptr %52, align 4
  %54 = getelementptr i64, ptr %51, i64 0
  store i64 %53, ptr %54, align 4
  %55 = getelementptr i64, ptr %5, i64 1
  %56 = load i64, ptr %55, align 4
  %57 = getelementptr i64, ptr %51, i64 1
  store i64 %56, ptr %57, align 4
  %58 = getelementptr i64, ptr %5, i64 2
  %59 = load i64, ptr %58, align 4
  %60 = getelementptr i64, ptr %51, i64 2
  store i64 %59, ptr %60, align 4
  %61 = getelementptr i64, ptr %5, i64 3
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr i64, ptr %51, i64 3
  store i64 %62, ptr %63, align 4
  %64 = getelementptr ptr, ptr %51, i64 4
  %65 = getelementptr i64, ptr %10, i64 0
  %66 = load i64, ptr %65, align 4
  %67 = getelementptr i64, ptr %64, i64 0
  store i64 %66, ptr %67, align 4
  %68 = getelementptr i64, ptr %10, i64 1
  %69 = load i64, ptr %68, align 4
  %70 = getelementptr i64, ptr %64, i64 1
  store i64 %69, ptr %70, align 4
  %71 = getelementptr i64, ptr %10, i64 2
  %72 = load i64, ptr %71, align 4
  %73 = getelementptr i64, ptr %64, i64 2
  store i64 %72, ptr %73, align 4
  %74 = getelementptr i64, ptr %10, i64 3
  %75 = load i64, ptr %74, align 4
  %76 = getelementptr i64, ptr %64, i64 3
  store i64 %75, ptr %76, align 4
  %vector_length13 = load i64, ptr %11, align 4
  %vector_data14 = getelementptr i64, ptr %11, i64 1
  %77 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data14, ptr %77, i64 %vector_length13)
  ret ptr %77
}

define void @_nonSystemDeployOnAddress(ptr %0, ptr %1, ptr %2, i64 %3, ptr %4) {
entry:
  %deploy_nonce = alloca i64, align 8
  %_input = alloca ptr, align 8
  %_aaVersion = alloca i64, align 8
  %_newAddress = alloca ptr, align 8
  %_codeHash = alloca ptr, align 8
  %_rawHash = alloca ptr, align 8
  store ptr %0, ptr %_rawHash, align 8
  %5 = load ptr, ptr %_rawHash, align 8
  store ptr %1, ptr %_codeHash, align 8
  %6 = load ptr, ptr %_codeHash, align 8
  store ptr %2, ptr %_newAddress, align 8
  %7 = load ptr, ptr %_newAddress, align 8
  store i64 %3, ptr %_aaVersion, align 4
  store ptr %4, ptr %_input, align 8
<<<<<<< HEAD
  %5 = load ptr, ptr %_input, align 8
  %6 = load ptr, ptr %_codeHash, align 8
  %7 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %7, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %7, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %7, i64 0
  store i64 0, ptr %index_access3, align 4
  %8 = call i64 @memcmp_ne(ptr %6, ptr %7, i64 4)
  call void @builtin_assert(i64 %8)
  %9 = call ptr @heap_malloc(i64 4)
  %index_access4 = getelementptr i64, ptr %9, i64 3
  store i64 65535, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %9, i64 0
  store i64 0, ptr %index_access7, align 4
  store ptr %9, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %10 = load ptr, ptr %_newAddress, align 8
  %11 = load ptr, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %12 = call i64 @field_memcmp_ugt(ptr %10, ptr %11, i64 4)
=======
  %8 = load ptr, ptr %_input, align 8
  %9 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %9, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %9, i64 3
  store i64 0, ptr %index_access3, align 4
  %10 = call i64 @memcmp_ne(ptr %6, ptr %9, i64 4)
  call void @builtin_assert(i64 %10)
  %11 = call ptr @heap_malloc(i64 4)
  %index_access4 = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %11, i64 3
  store i64 65535, ptr %index_access7, align 4
  %12 = call i64 @field_memcmp_ugt(ptr %7, ptr %11, i64 4)
>>>>>>> 7998cf0 (fixed llvm type bug.)
  call void @builtin_assert(i64 %12)
  %13 = call ptr @heap_malloc(i64 4)
  %index_access8 = getelementptr i64, ptr %13, i64 3
  store i64 32770, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %13, i64 2
  store i64 0, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %13, i64 1
  store i64 0, ptr %index_access10, align 4
<<<<<<< HEAD
  %index_access11 = getelementptr i64, ptr %13, i64 0
  store i64 0, ptr %index_access11, align 4
  store ptr %13, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %14 = load ptr, ptr %_newAddress, align 8
  %15 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %15, i64 1
  %16 = getelementptr i64, ptr %14, i64 0
  %17 = load i64, ptr %16, align 4
  %18 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %17, ptr %18, align 4
  %19 = getelementptr i64, ptr %14, i64 1
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %14, i64 2
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %23, ptr %24, align 4
  %25 = getelementptr i64, ptr %14, i64 3
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %26, ptr %27, align 4
  %28 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %28, align 4
  %29 = getelementptr ptr, ptr %28, i64 1
  store i64 2179613704, ptr %29, align 4
  %30 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %vector_length = load i64, ptr %15, align 4
  %vector_data12 = getelementptr i64, ptr %15, i64 1
=======
  %index_access11 = getelementptr i64, ptr %13, i64 3
  store i64 32770, ptr %index_access11, align 4
  %14 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %14, i64 1
  %15 = getelementptr i64, ptr %7, i64 0
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %16, ptr %17, align 4
  %18 = getelementptr i64, ptr %7, i64 1
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %7, i64 2
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %7, i64 3
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %25, ptr %26, align 4
  %27 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %27, align 4
  %28 = getelementptr ptr, ptr %27, i64 1
  store i64 2179613704, ptr %28, align 4
  %vector_length = load i64, ptr %14, align 4
  %vector_data12 = getelementptr i64, ptr %14, i64 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  call void @set_tape_data(ptr %vector_data12, i64 %vector_length)
  call void @contract_call(ptr %13, i64 0)
  %29 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %29, i64 1)
  %return_length = load i64, ptr %29, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %30 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %30, align 4
  %return_data_start = getelementptr i64, ptr %30, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
<<<<<<< HEAD
  %vector_data13 = getelementptr i64, ptr %32, i64 1
  %33 = getelementptr ptr, ptr %vector_data13, i64 0
  store ptr %33, ptr %codeHash, align 8
  %34 = load ptr, ptr %codeHash, align 8
  %35 = call ptr @heap_malloc(i64 4)
<<<<<<< HEAD
  %index_access14 = getelementptr i64, ptr %35, i64 3
  store i64 0, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %35, i64 2
=======
  %index_access14 = getelementptr i64, ptr %35, i64 0
  store i64 0, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %35, i64 1
>>>>>>> 83491ee (update examples out files.)
=======
  %vector_data13 = getelementptr i64, ptr %30, i64 1
  %31 = getelementptr ptr, ptr %vector_data13, i64 0
  %32 = call ptr @heap_malloc(i64 4)
  %index_access14 = getelementptr i64, ptr %32, i64 0
  store i64 0, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %32, i64 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  store i64 0, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %32, i64 2
  store i64 0, ptr %index_access16, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  %index_access17 = getelementptr i64, ptr %35, i64 0
=======
  %index_access17 = getelementptr i64, ptr %35, i64 3
>>>>>>> 83491ee (update examples out files.)
  store i64 0, ptr %index_access17, align 4
  %36 = call i64 @memcmp_eq(ptr %34, ptr %35, i64 4)
  call void @builtin_assert(i64 %36)
  %37 = call ptr @heap_malloc(i64 4)
<<<<<<< HEAD
  %index_access18 = getelementptr i64, ptr %37, i64 3
  store i64 32771, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %37, i64 2
=======
  %index_access18 = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %37, i64 1
>>>>>>> 83491ee (update examples out files.)
=======
  %index_access17 = getelementptr i64, ptr %32, i64 3
  store i64 0, ptr %index_access17, align 4
  %33 = call i64 @memcmp_eq(ptr %31, ptr %32, i64 4)
  call void @builtin_assert(i64 %33)
  %34 = call ptr @heap_malloc(i64 4)
  %index_access18 = getelementptr i64, ptr %34, i64 0
  store i64 0, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %34, i64 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  store i64 0, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %34, i64 2
  store i64 0, ptr %index_access20, align 4
<<<<<<< HEAD
<<<<<<< HEAD
  %index_access21 = getelementptr i64, ptr %37, i64 0
  store i64 0, ptr %index_access21, align 4
=======
  %index_access21 = getelementptr i64, ptr %37, i64 3
  store i64 32771, ptr %index_access21, align 4
>>>>>>> 83491ee (update examples out files.)
  store ptr %37, ptr %NONCE_HOLDER_ADDRESS, align 8
  %38 = load ptr, ptr %_newAddress, align 8
  %39 = call ptr @vector_new(i64 6)
  %vector_data22 = getelementptr i64, ptr %39, i64 1
  %40 = getelementptr i64, ptr %38, i64 0
  %41 = load i64, ptr %40, align 4
  %42 = getelementptr i64, ptr %vector_data22, i64 0
  store i64 %41, ptr %42, align 4
  %43 = getelementptr i64, ptr %38, i64 1
  %44 = load i64, ptr %43, align 4
  %45 = getelementptr i64, ptr %vector_data22, i64 1
  store i64 %44, ptr %45, align 4
  %46 = getelementptr i64, ptr %38, i64 2
  %47 = load i64, ptr %46, align 4
  %48 = getelementptr i64, ptr %vector_data22, i64 2
  store i64 %47, ptr %48, align 4
  %49 = getelementptr i64, ptr %38, i64 3
  %50 = load i64, ptr %49, align 4
  %51 = getelementptr i64, ptr %vector_data22, i64 3
  store i64 %50, ptr %51, align 4
  %52 = getelementptr ptr, ptr %vector_data22, i64 4
  store i64 4, ptr %52, align 4
  %53 = getelementptr ptr, ptr %52, i64 1
  store i64 3868785611, ptr %53, align 4
  %54 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %vector_length23 = load i64, ptr %39, align 4
  %vector_data24 = getelementptr i64, ptr %39, i64 1
=======
  %index_access21 = getelementptr i64, ptr %34, i64 3
  store i64 32771, ptr %index_access21, align 4
  %35 = call ptr @vector_new(i64 6)
  %vector_data22 = getelementptr i64, ptr %35, i64 1
  %36 = getelementptr i64, ptr %7, i64 0
  %37 = load i64, ptr %36, align 4
  %38 = getelementptr i64, ptr %vector_data22, i64 0
  store i64 %37, ptr %38, align 4
  %39 = getelementptr i64, ptr %7, i64 1
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %vector_data22, i64 1
  store i64 %40, ptr %41, align 4
  %42 = getelementptr i64, ptr %7, i64 2
  %43 = load i64, ptr %42, align 4
  %44 = getelementptr i64, ptr %vector_data22, i64 2
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %7, i64 3
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %vector_data22, i64 3
  store i64 %46, ptr %47, align 4
  %48 = getelementptr ptr, ptr %vector_data22, i64 4
  store i64 4, ptr %48, align 4
  %49 = getelementptr ptr, ptr %48, i64 1
  store i64 3868785611, ptr %49, align 4
  %vector_length23 = load i64, ptr %35, align 4
  %vector_data24 = getelementptr i64, ptr %35, i64 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  call void @set_tape_data(ptr %vector_data24, i64 %vector_length23)
  call void @contract_call(ptr %34, i64 0)
  %50 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %50, i64 1)
  %return_length25 = load i64, ptr %50, align 4
  %tape_size26 = add i64 %return_length25, 1
  %heap_size27 = add i64 %return_length25, 2
  %51 = call ptr @heap_malloc(i64 %heap_size27)
  store i64 %return_length25, ptr %51, align 4
  %return_data_start28 = getelementptr i64, ptr %51, i64 1
  call void @get_tape_data(ptr %return_data_start28, i64 %tape_size26)
  %vector_data29 = getelementptr i64, ptr %51, i64 1
  %52 = getelementptr ptr, ptr %vector_data29, i64 0
  %53 = load i64, ptr %52, align 4
  store i64 %53, ptr %deploy_nonce, align 4
  %54 = load i64, ptr %deploy_nonce, align 4
  %55 = icmp eq i64 %54, 0
  %56 = zext i1 %55 to i64
  call void @builtin_assert(i64 %56)
  %57 = load i64, ptr %_aaVersion, align 4
  call void @_performDeployOnAddress(ptr %5, ptr %6, ptr %7, i64 %57, ptr %8)
  ret void
}

define void @_performDeployOnAddress(ptr %0, ptr %1, ptr %2, i64 %3, ptr %4) {
entry:
  %is_codehash_known = alloca i64, align 8
  %_input = alloca ptr, align 8
  %_aaVersion = alloca i64, align 8
  %_newAddress = alloca ptr, align 8
  %_codeHash = alloca ptr, align 8
  %_rawHash = alloca ptr, align 8
  store ptr %0, ptr %_rawHash, align 8
  %5 = load ptr, ptr %_rawHash, align 8
  store ptr %1, ptr %_codeHash, align 8
  %6 = load ptr, ptr %_codeHash, align 8
  store ptr %2, ptr %_newAddress, align 8
  %7 = load ptr, ptr %_newAddress, align 8
  store i64 %3, ptr %_aaVersion, align 4
  store ptr %4, ptr %_input, align 8
<<<<<<< HEAD
  %5 = load ptr, ptr %_input, align 8
  %6 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %6, i64 3
  store i64 32772, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %6, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %6, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %6, i64 0
  store i64 0, ptr %index_access3, align 4
  store ptr %6, ptr %KNOWN_CODES_STORAGE_CONTRACT, align 8
  %7 = load ptr, ptr %_codeHash, align 8
  %8 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %8, i64 1
  %9 = getelementptr i64, ptr %7, i64 0
  %10 = load i64, ptr %9, align 4
  %11 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %10, ptr %11, align 4
  %12 = getelementptr i64, ptr %7, i64 1
  %13 = load i64, ptr %12, align 4
  %14 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %13, ptr %14, align 4
  %15 = getelementptr i64, ptr %7, i64 2
  %16 = load i64, ptr %15, align 4
  %17 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %16, ptr %17, align 4
  %18 = getelementptr i64, ptr %7, i64 3
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %19, ptr %20, align 4
  %21 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %21, align 4
  %22 = getelementptr ptr, ptr %21, i64 1
  store i64 4199620571, ptr %22, align 4
  %23 = load ptr, ptr %KNOWN_CODES_STORAGE_CONTRACT, align 8
  %vector_length = load i64, ptr %8, align 4
  %vector_data4 = getelementptr i64, ptr %8, i64 1
=======
  %8 = load ptr, ptr %_input, align 8
  %9 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %9, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %9, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %9, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %9, i64 3
  store i64 32772, ptr %index_access3, align 4
  %10 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %10, i64 1
  %11 = getelementptr i64, ptr %6, i64 0
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %6, i64 1
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %15, ptr %16, align 4
  %17 = getelementptr i64, ptr %6, i64 2
  %18 = load i64, ptr %17, align 4
  %19 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %18, ptr %19, align 4
  %20 = getelementptr i64, ptr %6, i64 3
  %21 = load i64, ptr %20, align 4
  %22 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %21, ptr %22, align 4
  %23 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %23, align 4
  %24 = getelementptr ptr, ptr %23, i64 1
  store i64 4199620571, ptr %24, align 4
  %vector_length = load i64, ptr %10, align 4
  %vector_data4 = getelementptr i64, ptr %10, i64 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  call void @set_tape_data(ptr %vector_data4, i64 %vector_length)
  call void @contract_call(ptr %9, i64 0)
  %25 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %25, i64 1)
  %return_length = load i64, ptr %25, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %26 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %26, align 4
  %return_data_start = getelementptr i64, ptr %26, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_data5 = getelementptr i64, ptr %26, i64 1
  %27 = getelementptr ptr, ptr %vector_data5, i64 0
  %28 = load i64, ptr %27, align 4
  store i64 %28, ptr %is_codehash_known, align 4
  %29 = load i64, ptr %is_codehash_known, align 4
  call void @builtin_assert(i64 %29)
  %30 = call ptr @heap_malloc(i64 2)
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %30, i32 0, i32 0
  %31 = load i64, ptr %_aaVersion, align 4
  store i64 %31, ptr %struct_member, align 4
  %struct_member6 = getelementptr inbounds { i64, i64 }, ptr %30, i32 0, i32 1
  store i64 0, ptr %struct_member6, align 4
  %32 = call ptr @heap_malloc(i64 4)
  %33 = getelementptr i64, ptr %32, i64 0
  store i64 0, ptr %33, align 4
  %34 = getelementptr i64, ptr %32, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %32, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %32, i64 3
  store i64 0, ptr %36, align 4
  %37 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %32, ptr %37, i64 4)
  %38 = getelementptr i64, ptr %37, i64 4
  call void @memcpy(ptr %7, ptr %38, i64 4)
  %39 = getelementptr i64, ptr %38, i64 4
  %40 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %37, ptr %40, i64 8)
  %supportedAAVersion = getelementptr inbounds { i64, i64 }, ptr %30, i32 0, i32 0
  %41 = load i64, ptr %supportedAAVersion, align 4
  %42 = call ptr @heap_malloc(i64 4)
  %43 = getelementptr i64, ptr %42, i64 0
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %42, i64 1
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %42, i64 2
  store i64 0, ptr %45, align 4
  %46 = getelementptr i64, ptr %42, i64 3
  store i64 %41, ptr %46, align 4
  call void @set_storage(ptr %40, ptr %42)
<<<<<<< HEAD
  %47 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %40, ptr %47, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %47, i64 3
  %48 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %48, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
=======
  %47 = getelementptr i64, ptr %40, i64 3
  %48 = load i64, ptr %47, align 4
  %slot_offset = add i64 %48, 1
  store i64 %slot_offset, ptr %47, align 4
<<<<<<< HEAD
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
  %nonceOrdering = getelementptr inbounds { i64, i64 }, ptr %29, i32 0, i32 1
=======
  %nonceOrdering = getelementptr inbounds { i64, i64 }, ptr %30, i32 0, i32 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %49 = load i64, ptr %nonceOrdering, align 4
  %50 = call ptr @heap_malloc(i64 4)
  %51 = getelementptr i64, ptr %50, i64 0
  store i64 0, ptr %51, align 4
  %52 = getelementptr i64, ptr %50, i64 1
  store i64 0, ptr %52, align 4
  %53 = getelementptr i64, ptr %50, i64 2
  store i64 0, ptr %53, align 4
  %54 = getelementptr i64, ptr %50, i64 3
  store i64 %49, ptr %54, align 4
<<<<<<< HEAD
  call void @set_storage(ptr %47, ptr %50)
=======
  call void @set_storage(ptr %40, ptr %50)
>>>>>>> c951d67 ((bugfix) fixed storage slot and value arrangement.)
  %55 = call ptr @heap_malloc(i64 12)
  call void @get_tape_data(ptr %55, i64 12)
  call void @_constructContract(ptr %55, ptr %7, ptr %5, ptr %6, ptr %8, i64 1)
  ret void
}

define void @_constructContract(ptr %0, ptr %1, ptr %2, ptr %3, ptr %4, i64 %5) {
entry:
  %_callConstructor = alloca i64, align 8
  %_input = alloca ptr, align 8
  %_codeHash = alloca ptr, align 8
  %_rawHash = alloca ptr, align 8
  %_newAddress = alloca ptr, align 8
  %_from = alloca ptr, align 8
  store ptr %0, ptr %_from, align 8
  %6 = load ptr, ptr %_from, align 8
  store ptr %1, ptr %_newAddress, align 8
  %7 = load ptr, ptr %_newAddress, align 8
  store ptr %2, ptr %_rawHash, align 8
  %8 = load ptr, ptr %_rawHash, align 8
  store ptr %3, ptr %_codeHash, align 8
  %9 = load ptr, ptr %_codeHash, align 8
  store ptr %4, ptr %_input, align 8
  %10 = load ptr, ptr %_input, align 8
  store i64 %5, ptr %_callConstructor, align 4
<<<<<<< HEAD
  %7 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %7, i64 3
  store i64 32770, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %7, i64 2
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %7, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %7, i64 0
  store i64 0, ptr %index_access3, align 4
  store ptr %7, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %8 = load i64, ptr %_callConstructor, align 4
  %9 = trunc i64 %8 to i1
  br i1 %9, label %then, label %else
=======
  %11 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %11, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %11, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %11, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %11, i64 3
  store i64 32770, ptr %index_access3, align 4
  %12 = load i64, ptr %_callConstructor, align 4
  %13 = trunc i64 %12 to i1
  br i1 %13, label %then, label %else
>>>>>>> 7998cf0 (fixed llvm type bug.)

then:                                             ; preds = %entry
  %vector_length = load i64, ptr %10, align 4
  %vector_data = getelementptr i64, ptr %10, i64 1
  call void @set_tape_data(ptr %vector_data, i64 %vector_length)
  call void @contract_call(ptr %7, i64 0)
  %14 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %14, i64 1)
  %return_length = load i64, ptr %14, align 4
  %tape_size = add i64 %return_length, 1
  %heap_size = add i64 %return_length, 2
  %15 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %15, align 4
  %return_data_start = getelementptr i64, ptr %15, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %16 = call ptr @vector_new(i64 14)
  %vector_data4 = getelementptr i64, ptr %16, i64 1
  %17 = getelementptr i64, ptr %7, i64 0
  %18 = load i64, ptr %17, align 4
  %19 = getelementptr i64, ptr %vector_data4, i64 0
  store i64 %18, ptr %19, align 4
  %20 = getelementptr i64, ptr %7, i64 1
  %21 = load i64, ptr %20, align 4
  %22 = getelementptr i64, ptr %vector_data4, i64 1
  store i64 %21, ptr %22, align 4
  %23 = getelementptr i64, ptr %7, i64 2
  %24 = load i64, ptr %23, align 4
  %25 = getelementptr i64, ptr %vector_data4, i64 2
  store i64 %24, ptr %25, align 4
  %26 = getelementptr i64, ptr %7, i64 3
  %27 = load i64, ptr %26, align 4
  %28 = getelementptr i64, ptr %vector_data4, i64 3
  store i64 %27, ptr %28, align 4
  %29 = getelementptr ptr, ptr %vector_data4, i64 4
  %30 = getelementptr i64, ptr %8, i64 0
  %31 = load i64, ptr %30, align 4
  %32 = getelementptr i64, ptr %29, i64 0
  store i64 %31, ptr %32, align 4
  %33 = getelementptr i64, ptr %8, i64 1
  %34 = load i64, ptr %33, align 4
  %35 = getelementptr i64, ptr %29, i64 1
  store i64 %34, ptr %35, align 4
  %36 = getelementptr i64, ptr %8, i64 2
  %37 = load i64, ptr %36, align 4
  %38 = getelementptr i64, ptr %29, i64 2
  store i64 %37, ptr %38, align 4
  %39 = getelementptr i64, ptr %8, i64 3
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %29, i64 3
  store i64 %40, ptr %41, align 4
  %42 = getelementptr ptr, ptr %29, i64 4
  %43 = getelementptr i64, ptr %9, i64 0
  %44 = load i64, ptr %43, align 4
  %45 = getelementptr i64, ptr %42, i64 0
  store i64 %44, ptr %45, align 4
  %46 = getelementptr i64, ptr %9, i64 1
  %47 = load i64, ptr %46, align 4
  %48 = getelementptr i64, ptr %42, i64 1
  store i64 %47, ptr %48, align 4
  %49 = getelementptr i64, ptr %9, i64 2
  %50 = load i64, ptr %49, align 4
  %51 = getelementptr i64, ptr %42, i64 2
  store i64 %50, ptr %51, align 4
  %52 = getelementptr i64, ptr %9, i64 3
  %53 = load i64, ptr %52, align 4
  %54 = getelementptr i64, ptr %42, i64 3
  store i64 %53, ptr %54, align 4
  %55 = getelementptr ptr, ptr %42, i64 4
  store i64 12, ptr %55, align 4
  %56 = getelementptr ptr, ptr %55, i64 1
  store i64 4294318592, ptr %56, align 4
  %vector_length5 = load i64, ptr %16, align 4
  %vector_data6 = getelementptr i64, ptr %16, i64 1
  call void @set_tape_data(ptr %vector_data6, i64 %vector_length5)
  call void @contract_call(ptr %11, i64 0)
  %57 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %57, i64 1)
  %return_length7 = load i64, ptr %57, align 4
  %tape_size8 = add i64 %return_length7, 1
  %heap_size9 = add i64 %return_length7, 2
  %58 = call ptr @heap_malloc(i64 %heap_size9)
  store i64 %return_length7, ptr %58, align 4
  %return_data_start10 = getelementptr i64, ptr %58, i64 1
  call void @get_tape_data(ptr %return_data_start10, i64 %tape_size8)
  br label %endif

else:                                             ; preds = %entry
  %59 = call ptr @vector_new(i64 14)
  %vector_data11 = getelementptr i64, ptr %59, i64 1
  %60 = getelementptr i64, ptr %7, i64 0
  %61 = load i64, ptr %60, align 4
  %62 = getelementptr i64, ptr %vector_data11, i64 0
  store i64 %61, ptr %62, align 4
  %63 = getelementptr i64, ptr %7, i64 1
  %64 = load i64, ptr %63, align 4
  %65 = getelementptr i64, ptr %vector_data11, i64 1
  store i64 %64, ptr %65, align 4
  %66 = getelementptr i64, ptr %7, i64 2
  %67 = load i64, ptr %66, align 4
  %68 = getelementptr i64, ptr %vector_data11, i64 2
  store i64 %67, ptr %68, align 4
  %69 = getelementptr i64, ptr %7, i64 3
  %70 = load i64, ptr %69, align 4
  %71 = getelementptr i64, ptr %vector_data11, i64 3
  store i64 %70, ptr %71, align 4
  %72 = getelementptr ptr, ptr %vector_data11, i64 4
  %73 = getelementptr i64, ptr %8, i64 0
  %74 = load i64, ptr %73, align 4
  %75 = getelementptr i64, ptr %72, i64 0
  store i64 %74, ptr %75, align 4
  %76 = getelementptr i64, ptr %8, i64 1
  %77 = load i64, ptr %76, align 4
  %78 = getelementptr i64, ptr %72, i64 1
  store i64 %77, ptr %78, align 4
  %79 = getelementptr i64, ptr %8, i64 2
  %80 = load i64, ptr %79, align 4
  %81 = getelementptr i64, ptr %72, i64 2
  store i64 %80, ptr %81, align 4
  %82 = getelementptr i64, ptr %8, i64 3
  %83 = load i64, ptr %82, align 4
  %84 = getelementptr i64, ptr %72, i64 3
  store i64 %83, ptr %84, align 4
  %85 = getelementptr ptr, ptr %72, i64 4
  %86 = getelementptr i64, ptr %9, i64 0
  %87 = load i64, ptr %86, align 4
  %88 = getelementptr i64, ptr %85, i64 0
  store i64 %87, ptr %88, align 4
  %89 = getelementptr i64, ptr %9, i64 1
  %90 = load i64, ptr %89, align 4
  %91 = getelementptr i64, ptr %85, i64 1
  store i64 %90, ptr %91, align 4
  %92 = getelementptr i64, ptr %9, i64 2
  %93 = load i64, ptr %92, align 4
  %94 = getelementptr i64, ptr %85, i64 2
  store i64 %93, ptr %94, align 4
  %95 = getelementptr i64, ptr %9, i64 3
  %96 = load i64, ptr %95, align 4
  %97 = getelementptr i64, ptr %85, i64 3
  store i64 %96, ptr %97, align 4
  %98 = getelementptr ptr, ptr %85, i64 4
  store i64 12, ptr %98, align 4
  %99 = getelementptr ptr, ptr %98, i64 1
  store i64 4294318592, ptr %99, align 4
  %vector_length12 = load i64, ptr %59, align 4
  %vector_data13 = getelementptr i64, ptr %59, i64 1
  call void @set_tape_data(ptr %vector_data13, i64 %vector_length12)
  call void @contract_call(ptr %11, i64 0)
  %100 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %100, i64 1)
  %return_length14 = load i64, ptr %100, align 4
  %tape_size15 = add i64 %return_length14, 1
  %heap_size16 = add i64 %return_length14, 2
  %101 = call ptr @heap_malloc(i64 %heap_size16)
  store i64 %return_length14, ptr %101, align 4
  %return_data_start17 = getelementptr i64, ptr %101, i64 1
  call void @get_tape_data(ptr %return_data_start17, i64 %tape_size15)
  br label %endif

endif:                                            ; preds = %else, %then
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3138377232, label %func_0_dispatch
    i64 4054612981, label %func_1_dispatch
    i64 1043134025, label %func_2_dispatch
    i64 321189754, label %func_3_dispatch
    i64 2892244336, label %func_4_dispatch
    i64 2042052731, label %func_5_dispatch
    i64 248726812, label %func_6_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = call i64 @extendedAccountVersion(ptr %3)
  %5 = call ptr @heap_malloc(i64 2)
  store i64 %4, ptr %5, align 4
  %6 = getelementptr ptr, ptr %5, i64 1
  store i64 1, ptr %6, align 4
  call void @set_tape_data(ptr %5, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = getelementptr ptr, ptr %2, i64 0
  %8 = getelementptr ptr, ptr %7, i64 4
  %9 = getelementptr ptr, ptr %8, i64 4
  %10 = getelementptr ptr, ptr %9, i64 4
  %vector_length = load i64, ptr %10, align 4
  %11 = add i64 %vector_length, 1
  %12 = call ptr @create2(ptr %7, ptr %8, ptr %9, ptr %10)
  %13 = call ptr @heap_malloc(i64 5)
  %14 = getelementptr i64, ptr %12, i64 0
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %13, i64 0
  store i64 %15, ptr %16, align 4
  %17 = getelementptr i64, ptr %12, i64 1
  %18 = load i64, ptr %17, align 4
  %19 = getelementptr i64, ptr %13, i64 1
  store i64 %18, ptr %19, align 4
  %20 = getelementptr i64, ptr %12, i64 2
  %21 = load i64, ptr %20, align 4
  %22 = getelementptr i64, ptr %13, i64 2
  store i64 %21, ptr %22, align 4
  %23 = getelementptr i64, ptr %12, i64 3
  %24 = load i64, ptr %23, align 4
  %25 = getelementptr i64, ptr %13, i64 3
  store i64 %24, ptr %25, align 4
  %26 = getelementptr ptr, ptr %13, i64 4
  store i64 4, ptr %26, align 4
  call void @set_tape_data(ptr %13, i64 5)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %27 = getelementptr ptr, ptr %2, i64 0
  %28 = getelementptr ptr, ptr %27, i64 4
  %29 = getelementptr ptr, ptr %28, i64 4
  %30 = getelementptr ptr, ptr %29, i64 4
  %vector_length1 = load i64, ptr %30, align 4
  %31 = add i64 %vector_length1, 1
  %32 = getelementptr ptr, ptr %30, i64 %31
  %33 = load i64, ptr %32, align 4
  %34 = call ptr @create2Account(ptr %27, ptr %28, ptr %29, ptr %30, i64 %33)
  %35 = call ptr @heap_malloc(i64 5)
  %36 = getelementptr i64, ptr %34, i64 0
  %37 = load i64, ptr %36, align 4
  %38 = getelementptr i64, ptr %35, i64 0
  store i64 %37, ptr %38, align 4
  %39 = getelementptr i64, ptr %34, i64 1
  %40 = load i64, ptr %39, align 4
  %41 = getelementptr i64, ptr %35, i64 1
  store i64 %40, ptr %41, align 4
  %42 = getelementptr i64, ptr %34, i64 2
  %43 = load i64, ptr %42, align 4
  %44 = getelementptr i64, ptr %35, i64 2
  store i64 %43, ptr %44, align 4
  %45 = getelementptr i64, ptr %34, i64 3
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %35, i64 3
  store i64 %46, ptr %47, align 4
  %48 = getelementptr ptr, ptr %35, i64 4
  store i64 4, ptr %48, align 4
  call void @set_tape_data(ptr %35, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %49 = getelementptr ptr, ptr %2, i64 0
  %50 = getelementptr ptr, ptr %49, i64 4
  %51 = getelementptr ptr, ptr %50, i64 4
  %52 = getelementptr ptr, ptr %51, i64 4
  %vector_length2 = load i64, ptr %52, align 4
  %53 = add i64 %vector_length2, 1
  %54 = call ptr @getNewAddressCreate2(ptr %49, ptr %50, ptr %51, ptr %52)
  %55 = call ptr @heap_malloc(i64 5)
  %56 = getelementptr i64, ptr %54, i64 0
  %57 = load i64, ptr %56, align 4
  %58 = getelementptr i64, ptr %55, i64 0
  store i64 %57, ptr %58, align 4
  %59 = getelementptr i64, ptr %54, i64 1
  %60 = load i64, ptr %59, align 4
  %61 = getelementptr i64, ptr %55, i64 1
  store i64 %60, ptr %61, align 4
  %62 = getelementptr i64, ptr %54, i64 2
  %63 = load i64, ptr %62, align 4
  %64 = getelementptr i64, ptr %55, i64 2
  store i64 %63, ptr %64, align 4
  %65 = getelementptr i64, ptr %54, i64 3
  %66 = load i64, ptr %65, align 4
  %67 = getelementptr i64, ptr %55, i64 3
  store i64 %66, ptr %67, align 4
  %68 = getelementptr ptr, ptr %55, i64 4
  store i64 4, ptr %68, align 4
  call void @set_tape_data(ptr %55, i64 5)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %69 = getelementptr ptr, ptr %2, i64 0
  %70 = getelementptr ptr, ptr %69, i64 4
  %71 = getelementptr ptr, ptr %70, i64 4
  %72 = getelementptr ptr, ptr %71, i64 4
  %73 = load i64, ptr %72, align 4
  %74 = getelementptr ptr, ptr %72, i64 1
  %vector_length3 = load i64, ptr %74, align 4
  %75 = add i64 %vector_length3, 1
  call void @_nonSystemDeployOnAddress(ptr %69, ptr %70, ptr %71, i64 %73, ptr %74)
  %76 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %76, align 4
  call void @set_tape_data(ptr %76, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %77 = getelementptr ptr, ptr %2, i64 0
  %78 = getelementptr ptr, ptr %77, i64 4
  %79 = getelementptr ptr, ptr %78, i64 4
  %80 = getelementptr ptr, ptr %79, i64 4
  %81 = load i64, ptr %80, align 4
  %82 = getelementptr ptr, ptr %80, i64 1
  %vector_length4 = load i64, ptr %82, align 4
  %83 = add i64 %vector_length4, 1
  call void @_performDeployOnAddress(ptr %77, ptr %78, ptr %79, i64 %81, ptr %82)
  %84 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %84, align 4
  call void @set_tape_data(ptr %84, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %85 = getelementptr ptr, ptr %2, i64 0
  %86 = getelementptr ptr, ptr %85, i64 4
  %87 = getelementptr ptr, ptr %86, i64 4
  %88 = getelementptr ptr, ptr %87, i64 4
  %89 = getelementptr ptr, ptr %88, i64 4
  %vector_length5 = load i64, ptr %89, align 4
  %90 = add i64 %vector_length5, 1
  %91 = getelementptr ptr, ptr %89, i64 %90
  %92 = load i64, ptr %91, align 4
  call void @_constructContract(ptr %85, ptr %86, ptr %87, ptr %88, ptr %89, i64 %92)
  %93 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %93, align 4
  call void @set_tape_data(ptr %93, i64 1)
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
