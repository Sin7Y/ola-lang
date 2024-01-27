; ModuleID = 'ProposalContract'
source_filename = "proposal"

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

define void @createProposal(ptr %0, i64 %1, i64 %2, i64 %3) {
entry:
  %_proposalType = alloca i64, align 8
  %_votingType = alloca i64, align 8
  %_deadline = alloca i64, align 8
  %_contentHash = alloca ptr, align 8
  store ptr %0, ptr %_contentHash, align 8
<<<<<<< HEAD
  store i64 %1, ptr %_deadline, align 4
  store i64 %2, ptr %_votingType, align 4
  store i64 %3, ptr %_proposalType, align 4
  %4 = load i64, ptr %_deadline, align 4
  %5 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %5, i64 1)
  %6 = load i64, ptr %5, align 4
  %7 = icmp ugt i64 %4, %6
  %8 = zext i1 %7 to i64
  call void @builtin_assert(i64 %8)
  %9 = load ptr, ptr %_contentHash, align 8
=======
  %4 = load ptr, ptr %_contentHash, align 8
  store i64 %1, ptr %_deadline, align 4
  store i64 %2, ptr %_votingType, align 4
  store i64 %3, ptr %_proposalType, align 4
  %5 = load i64, ptr %_deadline, align 4
  %6 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %6, i64 1)
  %7 = load i64, ptr %6, align 4
  %8 = icmp ugt i64 %5, %7
  %9 = zext i1 %8 to i64
  call void @builtin_assert(i64 %9)
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %10 = call ptr @heap_malloc(i64 4)
  %11 = getelementptr i64, ptr %10, i64 0
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %10, i64 1
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %10, i64 2
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %10, i64 3
  store i64 0, ptr %14, align 4
  %15 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %10, ptr %15, i64 4)
  %16 = getelementptr i64, ptr %15, i64 4
<<<<<<< HEAD
  call void @memcpy(ptr %9, ptr %16, i64 4)
=======
  call void @memcpy(ptr %4, ptr %16, i64 4)
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %17 = getelementptr i64, ptr %16, i64 4
  %18 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %15, ptr %18, i64 8)
  %19 = call ptr @heap_malloc(i64 6)
  %20 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %20)
<<<<<<< HEAD
  %21 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %18, ptr %21, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %21, i64 3
  %22 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %22, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %proposer = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 0
  store ptr %20, ptr %proposer, align 8
  %23 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %21, ptr %23)
  %24 = getelementptr i64, ptr %23, i64 3
  %storage_value = load i64, ptr %24, align 4
  %25 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %21, ptr %25, i64 4)
  %last_elem_ptr1 = getelementptr i64, ptr %25, i64 3
  %26 = load i64, ptr %last_elem_ptr1, align 4
  %last_elem2 = add i64 %26, 1
  store i64 %last_elem2, ptr %last_elem_ptr1, align 4
  %deadline = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 1
  store i64 %storage_value, ptr %deadline, align 4
  %27 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %25, ptr %27)
  %28 = getelementptr i64, ptr %27, i64 3
  %storage_value3 = load i64, ptr %28, align 4
  %29 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %25, ptr %29, i64 4)
  %last_elem_ptr4 = getelementptr i64, ptr %29, i64 3
  %30 = load i64, ptr %last_elem_ptr4, align 4
  %last_elem5 = add i64 %30, 1
  store i64 %last_elem5, ptr %last_elem_ptr4, align 4
  %totalSupport = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 2
  store i64 %storage_value3, ptr %totalSupport, align 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %29, ptr %31)
  %32 = getelementptr i64, ptr %31, i64 3
  %storage_value6 = load i64, ptr %32, align 4
  %33 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %29, ptr %33, i64 4)
  %last_elem_ptr7 = getelementptr i64, ptr %33, i64 3
  %34 = load i64, ptr %last_elem_ptr7, align 4
  %last_elem8 = add i64 %34, 1
  store i64 %last_elem8, ptr %last_elem_ptr7, align 4
  %totalAgainst = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 3
  store i64 %storage_value6, ptr %totalAgainst, align 4
  %35 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %33, ptr %35)
  %36 = getelementptr i64, ptr %35, i64 3
  %storage_value9 = load i64, ptr %36, align 4
  %37 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %33, ptr %37, i64 4)
  %last_elem_ptr10 = getelementptr i64, ptr %37, i64 3
  %38 = load i64, ptr %last_elem_ptr10, align 4
  %last_elem11 = add i64 %38, 1
  store i64 %last_elem11, ptr %last_elem_ptr10, align 4
  %votingType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 4
  store i64 %storage_value9, ptr %votingType, align 4
  %39 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %37, ptr %39)
  %40 = getelementptr i64, ptr %39, i64 3
  %storage_value12 = load i64, ptr %40, align 4
  %41 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %37, ptr %41, i64 4)
  %last_elem_ptr13 = getelementptr i64, ptr %41, i64 3
  %42 = load i64, ptr %last_elem_ptr13, align 4
  %last_elem14 = add i64 %42, 1
  store i64 %last_elem14, ptr %last_elem_ptr13, align 4
  %proposalType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 5
  store i64 %storage_value12, ptr %proposalType, align 4
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 0
  %43 = load ptr, ptr %struct_member, align 8
  %44 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %44, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access15 = getelementptr i64, ptr %44, i64 2
  store i64 0, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %44, i64 1
  store i64 0, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %44, i64 0
  store i64 0, ptr %index_access17, align 4
  %45 = call i64 @memcmp_eq(ptr %43, ptr %44, i64 4)
  call void @builtin_assert(i64 %45)
  %46 = call ptr @heap_malloc(i64 6)
  %struct_member18 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 0
=======
  %21 = getelementptr i64, ptr %18, i64 3
  %22 = load i64, ptr %21, align 4
  %slot_offset = add i64 %22, 1
  store i64 %slot_offset, ptr %21, align 4
  %proposer = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 0
  store ptr %20, ptr %proposer, align 8
  %23 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %23)
  %24 = getelementptr i64, ptr %23, i64 3
  %storage_value = load i64, ptr %24, align 4
  %25 = getelementptr i64, ptr %18, i64 3
  %26 = load i64, ptr %25, align 4
  %slot_offset1 = add i64 %26, 1
  store i64 %slot_offset1, ptr %25, align 4
  %deadline = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 1
  store i64 %storage_value, ptr %deadline, align 4
  %27 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %27)
  %28 = getelementptr i64, ptr %27, i64 3
  %storage_value2 = load i64, ptr %28, align 4
  %29 = getelementptr i64, ptr %18, i64 3
  %30 = load i64, ptr %29, align 4
  %slot_offset3 = add i64 %30, 1
  store i64 %slot_offset3, ptr %29, align 4
  %totalSupport = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 2
  store i64 %storage_value2, ptr %totalSupport, align 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %31)
  %32 = getelementptr i64, ptr %31, i64 3
  %storage_value4 = load i64, ptr %32, align 4
  %33 = getelementptr i64, ptr %18, i64 3
  %34 = load i64, ptr %33, align 4
  %slot_offset5 = add i64 %34, 1
  store i64 %slot_offset5, ptr %33, align 4
  %totalAgainst = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 3
  store i64 %storage_value4, ptr %totalAgainst, align 4
  %35 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %35)
  %36 = getelementptr i64, ptr %35, i64 3
  %storage_value6 = load i64, ptr %36, align 4
  %37 = getelementptr i64, ptr %18, i64 3
  %38 = load i64, ptr %37, align 4
  %slot_offset7 = add i64 %38, 1
  store i64 %slot_offset7, ptr %37, align 4
  %votingType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 4
  store i64 %storage_value6, ptr %votingType, align 4
  %39 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %39)
  %40 = getelementptr i64, ptr %39, i64 3
  %storage_value8 = load i64, ptr %40, align 4
  %41 = getelementptr i64, ptr %18, i64 3
  %42 = load i64, ptr %41, align 4
  %slot_offset9 = add i64 %42, 1
  store i64 %slot_offset9, ptr %41, align 4
  %proposalType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 5
  store i64 %storage_value8, ptr %proposalType, align 4
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %19, i32 0, i32 0
  %43 = load ptr, ptr %struct_member, align 8
  %44 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %44, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access10 = getelementptr i64, ptr %44, i64 1
  store i64 0, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %44, i64 2
  store i64 0, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %44, i64 3
  store i64 0, ptr %index_access12, align 4
  %45 = call i64 @memcmp_eq(ptr %43, ptr %44, i64 4)
  call void @builtin_assert(i64 %45)
  %46 = call ptr @heap_malloc(i64 6)
  %struct_member13 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 0
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %47 = call ptr @heap_malloc(i64 4)
  %48 = getelementptr i64, ptr %47, i64 0
  call void @get_context_data(ptr %48, i64 8)
  %49 = getelementptr i64, ptr %47, i64 1
  call void @get_context_data(ptr %49, i64 9)
  %50 = getelementptr i64, ptr %47, i64 2
  call void @get_context_data(ptr %50, i64 10)
  %51 = getelementptr i64, ptr %47, i64 3
  call void @get_context_data(ptr %51, i64 11)
<<<<<<< HEAD
  store ptr %47, ptr %struct_member18, align 8
  %struct_member19 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 1
  %52 = load i64, ptr %_deadline, align 4
  store i64 %52, ptr %struct_member19, align 4
  %struct_member20 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 2
  store i64 0, ptr %struct_member20, align 4
  %struct_member21 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 3
  store i64 0, ptr %struct_member21, align 4
  %struct_member22 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 4
  %53 = load i64, ptr %_votingType, align 4
  store i64 %53, ptr %struct_member22, align 4
  %struct_member23 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 5
  %54 = load i64, ptr %_proposalType, align 4
  store i64 %54, ptr %struct_member23, align 4
  %55 = load ptr, ptr %_contentHash, align 8
  %56 = call ptr @heap_malloc(i64 4)
  %57 = getelementptr i64, ptr %56, i64 0
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %56, i64 1
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %56, i64 2
  store i64 0, ptr %59, align 4
  %60 = getelementptr i64, ptr %56, i64 3
  store i64 0, ptr %60, align 4
  %61 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %56, ptr %61, i64 4)
  %62 = getelementptr i64, ptr %61, i64 4
  call void @memcpy(ptr %55, ptr %62, i64 4)
  %63 = getelementptr i64, ptr %62, i64 4
  %64 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %61, ptr %64, i64 8)
  %proposer24 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 0
  %65 = load ptr, ptr %proposer24, align 8
  call void @set_storage(ptr %64, ptr %65)
  %66 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %64, ptr %66, i64 4)
  %last_elem_ptr25 = getelementptr i64, ptr %66, i64 3
  %67 = load i64, ptr %last_elem_ptr25, align 4
  %last_elem26 = add i64 %67, 1
  store i64 %last_elem26, ptr %last_elem_ptr25, align 4
  %deadline27 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 1
  %68 = load i64, ptr %deadline27, align 4
  %69 = call ptr @heap_malloc(i64 4)
  %70 = getelementptr i64, ptr %69, i64 0
  store i64 0, ptr %70, align 4
  %71 = getelementptr i64, ptr %69, i64 1
  store i64 0, ptr %71, align 4
  %72 = getelementptr i64, ptr %69, i64 2
  store i64 0, ptr %72, align 4
  %73 = getelementptr i64, ptr %69, i64 3
  store i64 %68, ptr %73, align 4
  call void @set_storage(ptr %66, ptr %69)
  %74 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %66, ptr %74, i64 4)
  %last_elem_ptr28 = getelementptr i64, ptr %74, i64 3
  %75 = load i64, ptr %last_elem_ptr28, align 4
  %last_elem29 = add i64 %75, 1
  store i64 %last_elem29, ptr %last_elem_ptr28, align 4
  %totalSupport30 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 2
  %76 = load i64, ptr %totalSupport30, align 4
  %77 = call ptr @heap_malloc(i64 4)
  %78 = getelementptr i64, ptr %77, i64 0
  store i64 0, ptr %78, align 4
  %79 = getelementptr i64, ptr %77, i64 1
  store i64 0, ptr %79, align 4
  %80 = getelementptr i64, ptr %77, i64 2
  store i64 0, ptr %80, align 4
  %81 = getelementptr i64, ptr %77, i64 3
  store i64 %76, ptr %81, align 4
  call void @set_storage(ptr %74, ptr %77)
  %82 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %74, ptr %82, i64 4)
  %last_elem_ptr31 = getelementptr i64, ptr %82, i64 3
  %83 = load i64, ptr %last_elem_ptr31, align 4
  %last_elem32 = add i64 %83, 1
  store i64 %last_elem32, ptr %last_elem_ptr31, align 4
  %totalAgainst33 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 3
  %84 = load i64, ptr %totalAgainst33, align 4
  %85 = call ptr @heap_malloc(i64 4)
  %86 = getelementptr i64, ptr %85, i64 0
  store i64 0, ptr %86, align 4
  %87 = getelementptr i64, ptr %85, i64 1
  store i64 0, ptr %87, align 4
  %88 = getelementptr i64, ptr %85, i64 2
  store i64 0, ptr %88, align 4
  %89 = getelementptr i64, ptr %85, i64 3
  store i64 %84, ptr %89, align 4
  call void @set_storage(ptr %82, ptr %85)
  %90 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %82, ptr %90, i64 4)
  %last_elem_ptr34 = getelementptr i64, ptr %90, i64 3
  %91 = load i64, ptr %last_elem_ptr34, align 4
  %last_elem35 = add i64 %91, 1
  store i64 %last_elem35, ptr %last_elem_ptr34, align 4
  %votingType36 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 4
  %92 = load i64, ptr %votingType36, align 4
  %93 = call ptr @heap_malloc(i64 4)
  %94 = getelementptr i64, ptr %93, i64 0
  store i64 0, ptr %94, align 4
  %95 = getelementptr i64, ptr %93, i64 1
  store i64 0, ptr %95, align 4
  %96 = getelementptr i64, ptr %93, i64 2
  store i64 0, ptr %96, align 4
  %97 = getelementptr i64, ptr %93, i64 3
  store i64 %92, ptr %97, align 4
  call void @set_storage(ptr %90, ptr %93)
  %98 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %90, ptr %98, i64 4)
  %last_elem_ptr37 = getelementptr i64, ptr %98, i64 3
  %99 = load i64, ptr %last_elem_ptr37, align 4
  %last_elem38 = add i64 %99, 1
  store i64 %last_elem38, ptr %last_elem_ptr37, align 4
  %proposalType39 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 5
  %100 = load i64, ptr %proposalType39, align 4
  %101 = call ptr @heap_malloc(i64 4)
  %102 = getelementptr i64, ptr %101, i64 0
  store i64 0, ptr %102, align 4
  %103 = getelementptr i64, ptr %101, i64 1
  store i64 0, ptr %103, align 4
  %104 = getelementptr i64, ptr %101, i64 2
  store i64 0, ptr %104, align 4
  %105 = getelementptr i64, ptr %101, i64 3
  store i64 %100, ptr %105, align 4
  call void @set_storage(ptr %98, ptr %101)
  %106 = call ptr @heap_malloc(i64 4)
  %107 = getelementptr i64, ptr %106, i64 0
  call void @get_context_data(ptr %107, i64 8)
  %108 = getelementptr i64, ptr %106, i64 1
  call void @get_context_data(ptr %108, i64 9)
  %109 = getelementptr i64, ptr %106, i64 2
  call void @get_context_data(ptr %109, i64 10)
  %110 = getelementptr i64, ptr %106, i64 3
  call void @get_context_data(ptr %110, i64 11)
  %111 = call ptr @heap_malloc(i64 4)
  %112 = getelementptr i64, ptr %111, i64 0
  store i64 0, ptr %112, align 4
  %113 = getelementptr i64, ptr %111, i64 1
  store i64 0, ptr %113, align 4
  %114 = getelementptr i64, ptr %111, i64 2
  store i64 0, ptr %114, align 4
  %115 = getelementptr i64, ptr %111, i64 3
  store i64 1, ptr %115, align 4
  %116 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %111, ptr %116, i64 4)
  %117 = getelementptr i64, ptr %116, i64 4
  call void @memcpy(ptr %106, ptr %117, i64 4)
  %118 = getelementptr i64, ptr %117, i64 4
  %119 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %116, ptr %119, i64 8)
  %120 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %119, ptr %120)
  %length = getelementptr i64, ptr %120, i64 3
  %121 = load i64, ptr %length, align 4
  %122 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %119, ptr %122, i64 4)
  %hash_value_low = getelementptr i64, ptr %122, i64 3
  %123 = load i64, ptr %hash_value_low, align 4
  %124 = mul i64 %121, 1
  %storage_array_offset = add i64 %123, %124
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %125 = load ptr, ptr %_contentHash, align 8
  call void @set_storage(ptr %122, ptr %125)
  %new_length = add i64 %121, 1
  %126 = call ptr @heap_malloc(i64 4)
  %127 = getelementptr i64, ptr %126, i64 0
  store i64 0, ptr %127, align 4
  %128 = getelementptr i64, ptr %126, i64 1
  store i64 0, ptr %128, align 4
  %129 = getelementptr i64, ptr %126, i64 2
  store i64 0, ptr %129, align 4
  %130 = getelementptr i64, ptr %126, i64 3
  store i64 %new_length, ptr %130, align 4
  call void @set_storage(ptr %119, ptr %126)
=======
  store ptr %47, ptr %struct_member13, align 8
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 1
  %52 = load i64, ptr %_deadline, align 4
  store i64 %52, ptr %struct_member14, align 4
  %struct_member15 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 2
  store i64 0, ptr %struct_member15, align 4
  %struct_member16 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 3
  store i64 0, ptr %struct_member16, align 4
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 4
  %53 = load i64, ptr %_votingType, align 4
  store i64 %53, ptr %struct_member17, align 4
  %struct_member18 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 5
  %54 = load i64, ptr %_proposalType, align 4
  store i64 %54, ptr %struct_member18, align 4
  %55 = call ptr @heap_malloc(i64 4)
  %56 = getelementptr i64, ptr %55, i64 0
  store i64 0, ptr %56, align 4
  %57 = getelementptr i64, ptr %55, i64 1
  store i64 0, ptr %57, align 4
  %58 = getelementptr i64, ptr %55, i64 2
  store i64 0, ptr %58, align 4
  %59 = getelementptr i64, ptr %55, i64 3
  store i64 0, ptr %59, align 4
  %60 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %55, ptr %60, i64 4)
  %61 = getelementptr i64, ptr %60, i64 4
  call void @memcpy(ptr %4, ptr %61, i64 4)
  %62 = getelementptr i64, ptr %61, i64 4
  %63 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %60, ptr %63, i64 8)
  %proposer19 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 0
  %64 = load ptr, ptr %proposer19, align 8
  call void @set_storage(ptr %63, ptr %64)
  %deadline20 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 1
  %65 = load i64, ptr %deadline20, align 4
  %66 = call ptr @heap_malloc(i64 4)
  %67 = getelementptr i64, ptr %66, i64 0
  store i64 0, ptr %67, align 4
  %68 = getelementptr i64, ptr %66, i64 1
  store i64 0, ptr %68, align 4
  %69 = getelementptr i64, ptr %66, i64 2
  store i64 0, ptr %69, align 4
  %70 = getelementptr i64, ptr %66, i64 3
  store i64 %65, ptr %70, align 4
  call void @set_storage(ptr %63, ptr %66)
  %71 = getelementptr i64, ptr %63, i64 3
  %72 = load i64, ptr %71, align 4
  %slot_offset21 = add i64 %72, 1
  store i64 %slot_offset21, ptr %71, align 4
  %totalSupport22 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 2
  %73 = load i64, ptr %totalSupport22, align 4
  %74 = call ptr @heap_malloc(i64 4)
  %75 = getelementptr i64, ptr %74, i64 0
  store i64 0, ptr %75, align 4
  %76 = getelementptr i64, ptr %74, i64 1
  store i64 0, ptr %76, align 4
  %77 = getelementptr i64, ptr %74, i64 2
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %74, i64 3
  store i64 %73, ptr %78, align 4
  call void @set_storage(ptr %63, ptr %74)
  %79 = getelementptr i64, ptr %63, i64 3
  %80 = load i64, ptr %79, align 4
  %slot_offset23 = add i64 %80, 1
  store i64 %slot_offset23, ptr %79, align 4
  %totalAgainst24 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 3
  %81 = load i64, ptr %totalAgainst24, align 4
  %82 = call ptr @heap_malloc(i64 4)
  %83 = getelementptr i64, ptr %82, i64 0
  store i64 0, ptr %83, align 4
  %84 = getelementptr i64, ptr %82, i64 1
  store i64 0, ptr %84, align 4
  %85 = getelementptr i64, ptr %82, i64 2
  store i64 0, ptr %85, align 4
  %86 = getelementptr i64, ptr %82, i64 3
  store i64 %81, ptr %86, align 4
  call void @set_storage(ptr %63, ptr %82)
  %87 = getelementptr i64, ptr %63, i64 3
  %88 = load i64, ptr %87, align 4
  %slot_offset25 = add i64 %88, 1
  store i64 %slot_offset25, ptr %87, align 4
  %votingType26 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 4
  %89 = load i64, ptr %votingType26, align 4
  %90 = call ptr @heap_malloc(i64 4)
  %91 = getelementptr i64, ptr %90, i64 0
  store i64 0, ptr %91, align 4
  %92 = getelementptr i64, ptr %90, i64 1
  store i64 0, ptr %92, align 4
  %93 = getelementptr i64, ptr %90, i64 2
  store i64 0, ptr %93, align 4
  %94 = getelementptr i64, ptr %90, i64 3
  store i64 %89, ptr %94, align 4
  call void @set_storage(ptr %63, ptr %90)
  %95 = getelementptr i64, ptr %63, i64 3
  %96 = load i64, ptr %95, align 4
  %slot_offset27 = add i64 %96, 1
  store i64 %slot_offset27, ptr %95, align 4
  %proposalType28 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %46, i32 0, i32 5
  %97 = load i64, ptr %proposalType28, align 4
  %98 = call ptr @heap_malloc(i64 4)
  %99 = getelementptr i64, ptr %98, i64 0
  store i64 0, ptr %99, align 4
  %100 = getelementptr i64, ptr %98, i64 1
  store i64 0, ptr %100, align 4
  %101 = getelementptr i64, ptr %98, i64 2
  store i64 0, ptr %101, align 4
  %102 = getelementptr i64, ptr %98, i64 3
  store i64 %97, ptr %102, align 4
  call void @set_storage(ptr %63, ptr %98)
  %103 = call ptr @heap_malloc(i64 4)
  %104 = getelementptr i64, ptr %103, i64 0
  call void @get_context_data(ptr %104, i64 8)
  %105 = getelementptr i64, ptr %103, i64 1
  call void @get_context_data(ptr %105, i64 9)
  %106 = getelementptr i64, ptr %103, i64 2
  call void @get_context_data(ptr %106, i64 10)
  %107 = getelementptr i64, ptr %103, i64 3
  call void @get_context_data(ptr %107, i64 11)
  %108 = call ptr @heap_malloc(i64 4)
  %109 = getelementptr i64, ptr %108, i64 0
  store i64 0, ptr %109, align 4
  %110 = getelementptr i64, ptr %108, i64 1
  store i64 0, ptr %110, align 4
  %111 = getelementptr i64, ptr %108, i64 2
  store i64 0, ptr %111, align 4
  %112 = getelementptr i64, ptr %108, i64 3
  store i64 1, ptr %112, align 4
  %113 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %108, ptr %113, i64 4)
  %114 = getelementptr i64, ptr %113, i64 4
  call void @memcpy(ptr %103, ptr %114, i64 4)
  %115 = getelementptr i64, ptr %114, i64 4
  %116 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %113, ptr %116, i64 8)
  %117 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %116, ptr %117)
  %length = getelementptr i64, ptr %117, i64 3
  %118 = load i64, ptr %length, align 4
  %119 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %116, ptr %119, i64 4)
  %hash_value_low = getelementptr i64, ptr %119, i64 3
  %120 = load i64, ptr %hash_value_low, align 4
  %121 = mul i64 %118, 1
  %storage_array_offset = add i64 %120, %121
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  call void @set_storage(ptr %119, ptr %4)
  %new_length = add i64 %118, 1
  %122 = call ptr @heap_malloc(i64 4)
  %123 = getelementptr i64, ptr %122, i64 0
  store i64 0, ptr %123, align 4
  %124 = getelementptr i64, ptr %122, i64 1
  store i64 0, ptr %124, align 4
  %125 = getelementptr i64, ptr %122, i64 2
  store i64 0, ptr %125, align 4
  %126 = getelementptr i64, ptr %122, i64 3
  store i64 %new_length, ptr %126, align 4
  call void @set_storage(ptr %116, ptr %122)
>>>>>>> 7998cf0 (fixed llvm type bug.)
  ret void
}

define void @vote(ptr %0, i64 %1, i64 %2) {
entry:
<<<<<<< HEAD
  %weight = alloca i64, align 8
=======
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %i = alloca i64, align 8
  %3 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %_weight = alloca i64, align 8
  %_support = alloca i64, align 8
  %_contentHash = alloca ptr, align 8
  store ptr %0, ptr %_contentHash, align 8
<<<<<<< HEAD
  store i64 %1, ptr %_support, align 4
  store i64 %2, ptr %_weight, align 4
  %4 = load ptr, ptr %_contentHash, align 8
=======
  %4 = load ptr, ptr %_contentHash, align 8
  store i64 %1, ptr %_support, align 4
  store i64 %2, ptr %_weight, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 0, ptr %9, align 4
  %10 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %5, ptr %10, i64 4)
  %11 = getelementptr i64, ptr %10, i64 4
  call void @memcpy(ptr %4, ptr %11, i64 4)
  %12 = getelementptr i64, ptr %11, i64 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %10, ptr %13, i64 8)
  %14 = call ptr @heap_malloc(i64 6)
  %15 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %15)
<<<<<<< HEAD
  %16 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %13, ptr %16, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %16, i64 3
  %17 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %17, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %proposer = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 0
  store ptr %15, ptr %proposer, align 8
  %18 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %16, ptr %18)
  %19 = getelementptr i64, ptr %18, i64 3
  %storage_value = load i64, ptr %19, align 4
  %20 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %20, i64 4)
  %last_elem_ptr1 = getelementptr i64, ptr %20, i64 3
  %21 = load i64, ptr %last_elem_ptr1, align 4
  %last_elem2 = add i64 %21, 1
  store i64 %last_elem2, ptr %last_elem_ptr1, align 4
  %deadline = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 1
  store i64 %storage_value, ptr %deadline, align 4
  %22 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %20, ptr %22)
  %23 = getelementptr i64, ptr %22, i64 3
  %storage_value3 = load i64, ptr %23, align 4
  %24 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %20, ptr %24, i64 4)
  %last_elem_ptr4 = getelementptr i64, ptr %24, i64 3
  %25 = load i64, ptr %last_elem_ptr4, align 4
  %last_elem5 = add i64 %25, 1
  store i64 %last_elem5, ptr %last_elem_ptr4, align 4
  %totalSupport = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 2
  store i64 %storage_value3, ptr %totalSupport, align 4
  %26 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %24, ptr %26)
  %27 = getelementptr i64, ptr %26, i64 3
  %storage_value6 = load i64, ptr %27, align 4
  %28 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %24, ptr %28, i64 4)
  %last_elem_ptr7 = getelementptr i64, ptr %28, i64 3
  %29 = load i64, ptr %last_elem_ptr7, align 4
  %last_elem8 = add i64 %29, 1
  store i64 %last_elem8, ptr %last_elem_ptr7, align 4
  %totalAgainst = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 3
  store i64 %storage_value6, ptr %totalAgainst, align 4
  %30 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %28, ptr %30)
  %31 = getelementptr i64, ptr %30, i64 3
  %storage_value9 = load i64, ptr %31, align 4
  %32 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %28, ptr %32, i64 4)
  %last_elem_ptr10 = getelementptr i64, ptr %32, i64 3
  %33 = load i64, ptr %last_elem_ptr10, align 4
  %last_elem11 = add i64 %33, 1
  store i64 %last_elem11, ptr %last_elem_ptr10, align 4
  %votingType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 4
  store i64 %storage_value9, ptr %votingType, align 4
  %34 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %32, ptr %34)
  %35 = getelementptr i64, ptr %34, i64 3
  %storage_value12 = load i64, ptr %35, align 4
  %36 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %32, ptr %36, i64 4)
  %last_elem_ptr13 = getelementptr i64, ptr %36, i64 3
  %37 = load i64, ptr %last_elem_ptr13, align 4
  %last_elem14 = add i64 %37, 1
  store i64 %last_elem14, ptr %last_elem_ptr13, align 4
  %proposalType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 5
  store i64 %storage_value12, ptr %proposalType, align 4
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 0
  %38 = load ptr, ptr %struct_member, align 8
  %39 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %39, i64 3
  store i64 0, ptr %index_access, align 4
  %index_access15 = getelementptr i64, ptr %39, i64 2
  store i64 0, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %39, i64 1
  store i64 0, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %39, i64 0
  store i64 0, ptr %index_access17, align 4
  %40 = call i64 @memcmp_ne(ptr %38, ptr %39, i64 4)
  call void @builtin_assert(i64 %40)
  %41 = call ptr @heap_malloc(i64 4)
  %42 = getelementptr i64, ptr %41, i64 0
  call void @get_context_data(ptr %42, i64 8)
  %43 = getelementptr i64, ptr %41, i64 1
  call void @get_context_data(ptr %43, i64 9)
  %44 = getelementptr i64, ptr %41, i64 2
  call void @get_context_data(ptr %44, i64 10)
  %45 = getelementptr i64, ptr %41, i64 3
  call void @get_context_data(ptr %45, i64 11)
  %46 = call ptr @heap_malloc(i64 4)
  %47 = getelementptr i64, ptr %46, i64 0
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %46, i64 1
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %46, i64 2
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %46, i64 3
  store i64 2, ptr %50, align 4
  %51 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %46, ptr %51, i64 4)
  %52 = getelementptr i64, ptr %51, i64 4
  call void @memcpy(ptr %41, ptr %52, i64 4)
  %53 = getelementptr i64, ptr %52, i64 4
  %54 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %51, ptr %54, i64 8)
  %55 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %54, ptr %55)
  %length = getelementptr i64, ptr %55, i64 3
  %56 = load i64, ptr %length, align 4
  %57 = call ptr @vector_new(i64 %56)
  %58 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %54, ptr %58, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %58, ptr %3, align 8
=======
  %16 = getelementptr i64, ptr %13, i64 3
  %17 = load i64, ptr %16, align 4
  %slot_offset = add i64 %17, 1
  store i64 %slot_offset, ptr %16, align 4
  %proposer = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 0
  store ptr %15, ptr %proposer, align 8
  %18 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %18)
  %19 = getelementptr i64, ptr %18, i64 3
  %storage_value = load i64, ptr %19, align 4
  %20 = getelementptr i64, ptr %13, i64 3
  %21 = load i64, ptr %20, align 4
  %slot_offset1 = add i64 %21, 1
  store i64 %slot_offset1, ptr %20, align 4
  %deadline = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 1
  store i64 %storage_value, ptr %deadline, align 4
  %22 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %22)
  %23 = getelementptr i64, ptr %22, i64 3
  %storage_value2 = load i64, ptr %23, align 4
  %24 = getelementptr i64, ptr %13, i64 3
  %25 = load i64, ptr %24, align 4
  %slot_offset3 = add i64 %25, 1
  store i64 %slot_offset3, ptr %24, align 4
  %totalSupport = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 2
  store i64 %storage_value2, ptr %totalSupport, align 4
  %26 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %26)
  %27 = getelementptr i64, ptr %26, i64 3
  %storage_value4 = load i64, ptr %27, align 4
  %28 = getelementptr i64, ptr %13, i64 3
  %29 = load i64, ptr %28, align 4
  %slot_offset5 = add i64 %29, 1
  store i64 %slot_offset5, ptr %28, align 4
  %totalAgainst = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 3
  store i64 %storage_value4, ptr %totalAgainst, align 4
  %30 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %30)
  %31 = getelementptr i64, ptr %30, i64 3
  %storage_value6 = load i64, ptr %31, align 4
  %32 = getelementptr i64, ptr %13, i64 3
  %33 = load i64, ptr %32, align 4
  %slot_offset7 = add i64 %33, 1
  store i64 %slot_offset7, ptr %32, align 4
  %votingType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 4
  store i64 %storage_value6, ptr %votingType, align 4
  %34 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %34)
  %35 = getelementptr i64, ptr %34, i64 3
  %storage_value8 = load i64, ptr %35, align 4
  %36 = getelementptr i64, ptr %13, i64 3
  %37 = load i64, ptr %36, align 4
  %slot_offset9 = add i64 %37, 1
  store i64 %slot_offset9, ptr %36, align 4
  %proposalType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 5
  store i64 %storage_value8, ptr %proposalType, align 4
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 0
  %38 = load ptr, ptr %struct_member, align 8
  %39 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %39, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access10 = getelementptr i64, ptr %39, i64 1
  store i64 0, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %39, i64 2
  store i64 0, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %39, i64 3
  store i64 0, ptr %index_access12, align 4
  %40 = call i64 @memcmp_ne(ptr %38, ptr %39, i64 4)
  call void @builtin_assert(i64 %40)
  %41 = call ptr @vector_new(i64 15)
  %vector_data = getelementptr i64, ptr %41, i64 1
  %index_access13 = getelementptr i64, ptr %vector_data, i64 0
  store i64 112, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %vector_data, i64 1
  store i64 114, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data, i64 2
  store i64 111, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %vector_data, i64 3
  store i64 112, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %vector_data, i64 5
  store i64 115, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %vector_data, i64 6
  store i64 97, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %vector_data, i64 7
  store i64 108, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %vector_data, i64 8
  store i64 32, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %vector_data, i64 9
  store i64 101, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data, i64 10
  store i64 120, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %vector_data, i64 11
  store i64 105, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %vector_data, i64 12
  store i64 115, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %vector_data, i64 13
  store i64 116, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %vector_data, i64 14
  store i64 115, ptr %index_access27, align 4
  %string_start = ptrtoint ptr %41 to i64
  call void @prophet_printf(i64 %string_start, i64 1)
  %42 = call ptr @heap_malloc(i64 4)
  %43 = getelementptr i64, ptr %42, i64 0
  call void @get_context_data(ptr %43, i64 8)
  %44 = getelementptr i64, ptr %42, i64 1
  call void @get_context_data(ptr %44, i64 9)
  %45 = getelementptr i64, ptr %42, i64 2
  call void @get_context_data(ptr %45, i64 10)
  %46 = getelementptr i64, ptr %42, i64 3
  call void @get_context_data(ptr %46, i64 11)
  %47 = call ptr @heap_malloc(i64 4)
  %48 = getelementptr i64, ptr %47, i64 0
  store i64 0, ptr %48, align 4
  %49 = getelementptr i64, ptr %47, i64 1
  store i64 0, ptr %49, align 4
  %50 = getelementptr i64, ptr %47, i64 2
  store i64 0, ptr %50, align 4
  %51 = getelementptr i64, ptr %47, i64 3
  store i64 2, ptr %51, align 4
  %52 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %47, ptr %52, i64 4)
  %53 = getelementptr i64, ptr %52, i64 4
  call void @memcpy(ptr %42, ptr %53, i64 4)
  %54 = getelementptr i64, ptr %53, i64 4
  %55 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %52, ptr %55, i64 8)
  %56 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %55, ptr %56)
  %length = getelementptr i64, ptr %56, i64 3
  %57 = load i64, ptr %length, align 4
  %58 = call ptr @vector_new(i64 %57)
  %59 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %55, ptr %59, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %59, ptr %3, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
<<<<<<< HEAD
  %loop_cond = icmp ult i64 %index_value, %56
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %59 = load ptr, ptr %3, align 8
  %vector_data = getelementptr i64, ptr %57, i64 1
  %index_access18 = getelementptr ptr, ptr %vector_data, i64 %index_value
  %60 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %59, ptr %60)
  %61 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %59, ptr %61, i64 4)
  %last_elem_ptr19 = getelementptr i64, ptr %61, i64 3
  %62 = load i64, ptr %last_elem_ptr19, align 4
  %last_elem20 = add i64 %62, 1
  store i64 %last_elem20, ptr %last_elem_ptr19, align 4
  store ptr %60, ptr %index_access18, align 8
  store ptr %61, ptr %3, align 8
=======
  %loop_cond = icmp ult i64 %index_value, %57
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %60 = load ptr, ptr %3, align 8
  %vector_data28 = getelementptr i64, ptr %58, i64 1
  %index_access29 = getelementptr ptr, ptr %vector_data28, i64 %index_value
  %61 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %60, ptr %61)
  %62 = getelementptr i64, ptr %60, i64 3
  %63 = load i64, ptr %62, align 4
  %slot_offset30 = add i64 %63, 1
  store i64 %slot_offset30, ptr %62, align 4
  store ptr %61, ptr %index_access29, align 8
  store ptr %60, ptr %3, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %i, align 4
<<<<<<< HEAD
  br label %cond21

cond21:                                           ; preds = %next, %done
  %63 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %57, align 4
  %64 = icmp ult i64 %63, %vector_length
  br i1 %64, label %body22, label %endfor

body22:                                           ; preds = %cond21
  %65 = load i64, ptr %i, align 4
  %vector_length23 = load i64, ptr %57, align 4
  %66 = sub i64 %vector_length23, 1
  %67 = sub i64 %66, %65
  call void @builtin_range_check(i64 %67)
  %vector_data24 = getelementptr i64, ptr %57, i64 1
  %index_access25 = getelementptr ptr, ptr %vector_data24, i64 %65
  %68 = load ptr, ptr %index_access25, align 8
  %69 = load ptr, ptr %_contentHash, align 8
  %70 = call i64 @memcmp_ne(ptr %68, ptr %69, i64 4)
  call void @builtin_assert(i64 %70)
  br label %next

next:                                             ; preds = %body22
  %71 = load i64, ptr %i, align 4
  %72 = add i64 %71, 1
  store i64 %72, ptr %i, align 4
  br label %cond21

endfor:                                           ; preds = %cond21
  store i64 1, ptr %weight, align 4
  %struct_member26 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %14, i32 0, i32 4
  %73 = load i64, ptr %struct_member26, align 4
  %74 = icmp eq i64 %73, 1
  br i1 %74, label %then, label %endif

then:                                             ; preds = %endfor
  %75 = load i64, ptr %_weight, align 4
  store i64 %75, ptr %weight, align 4
  br label %endif

endif:                                            ; preds = %then, %endfor
  %76 = load ptr, ptr %_contentHash, align 8
  %77 = call ptr @heap_malloc(i64 4)
  %78 = getelementptr i64, ptr %77, i64 0
  store i64 0, ptr %78, align 4
  %79 = getelementptr i64, ptr %77, i64 1
  store i64 0, ptr %79, align 4
  %80 = getelementptr i64, ptr %77, i64 2
  store i64 0, ptr %80, align 4
  %81 = getelementptr i64, ptr %77, i64 3
  store i64 0, ptr %81, align 4
  %82 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %77, ptr %82, i64 4)
  %83 = getelementptr i64, ptr %82, i64 4
  call void @memcpy(ptr %76, ptr %83, i64 4)
  %84 = getelementptr i64, ptr %83, i64 4
  %85 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %82, ptr %85, i64 8)
  %86 = call ptr @heap_malloc(i64 6)
  %87 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %85, ptr %87)
  %88 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %85, ptr %88, i64 4)
  %last_elem_ptr27 = getelementptr i64, ptr %88, i64 3
  %89 = load i64, ptr %last_elem_ptr27, align 4
  %last_elem28 = add i64 %89, 1
  store i64 %last_elem28, ptr %last_elem_ptr27, align 4
  %proposer29 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 0
  store ptr %87, ptr %proposer29, align 8
  %90 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %88, ptr %90)
  %91 = getelementptr i64, ptr %90, i64 3
  %storage_value30 = load i64, ptr %91, align 4
  %92 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %88, ptr %92, i64 4)
  %last_elem_ptr31 = getelementptr i64, ptr %92, i64 3
  %93 = load i64, ptr %last_elem_ptr31, align 4
  %last_elem32 = add i64 %93, 1
  store i64 %last_elem32, ptr %last_elem_ptr31, align 4
  %deadline33 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 1
  store i64 %storage_value30, ptr %deadline33, align 4
  %94 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %92, ptr %94)
  %95 = getelementptr i64, ptr %94, i64 3
  %storage_value34 = load i64, ptr %95, align 4
  %96 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %92, ptr %96, i64 4)
  %last_elem_ptr35 = getelementptr i64, ptr %96, i64 3
  %97 = load i64, ptr %last_elem_ptr35, align 4
  %last_elem36 = add i64 %97, 1
  store i64 %last_elem36, ptr %last_elem_ptr35, align 4
  %totalSupport37 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 2
  store i64 %storage_value34, ptr %totalSupport37, align 4
  %98 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %96, ptr %98)
  %99 = getelementptr i64, ptr %98, i64 3
  %storage_value38 = load i64, ptr %99, align 4
  %100 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %96, ptr %100, i64 4)
  %last_elem_ptr39 = getelementptr i64, ptr %100, i64 3
  %101 = load i64, ptr %last_elem_ptr39, align 4
  %last_elem40 = add i64 %101, 1
  store i64 %last_elem40, ptr %last_elem_ptr39, align 4
  %totalAgainst41 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 3
  store i64 %storage_value38, ptr %totalAgainst41, align 4
  %102 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %100, ptr %102)
  %103 = getelementptr i64, ptr %102, i64 3
  %storage_value42 = load i64, ptr %103, align 4
  %104 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %100, ptr %104, i64 4)
  %last_elem_ptr43 = getelementptr i64, ptr %104, i64 3
  %105 = load i64, ptr %last_elem_ptr43, align 4
  %last_elem44 = add i64 %105, 1
  store i64 %last_elem44, ptr %last_elem_ptr43, align 4
  %votingType45 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 4
  store i64 %storage_value42, ptr %votingType45, align 4
  %106 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %104, ptr %106)
  %107 = getelementptr i64, ptr %106, i64 3
  %storage_value46 = load i64, ptr %107, align 4
  %108 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %104, ptr %108, i64 4)
  %last_elem_ptr47 = getelementptr i64, ptr %108, i64 3
  %109 = load i64, ptr %last_elem_ptr47, align 4
  %last_elem48 = add i64 %109, 1
  store i64 %last_elem48, ptr %last_elem_ptr47, align 4
  %proposalType49 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 5
  store i64 %storage_value46, ptr %proposalType49, align 4
  %110 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %110, i64 1)
  %111 = load i64, ptr %110, align 4
  %struct_member50 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 1
  %112 = load i64, ptr %struct_member50, align 4
  %113 = icmp ult i64 %111, %112
  %114 = zext i1 %113 to i64
  call void @builtin_assert(i64 %114)
  %115 = load i64, ptr %_support, align 4
  %116 = trunc i64 %115 to i1
  br i1 %116, label %then51, label %else

then51:                                           ; preds = %endif
  %struct_member52 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 2
  %struct_member53 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 2
  %117 = load i64, ptr %struct_member53, align 4
  %118 = load i64, ptr %weight, align 4
  %119 = add i64 %117, %118
  call void @builtin_range_check(i64 %119)
  store i64 %119, ptr %struct_member52, align 4
  br label %endif54

else:                                             ; preds = %endif
  %struct_member55 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 3
  %struct_member56 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 3
  %120 = load i64, ptr %struct_member56, align 4
  %121 = load i64, ptr %weight, align 4
  %122 = add i64 %120, %121
  call void @builtin_range_check(i64 %122)
  store i64 %122, ptr %struct_member55, align 4
  br label %endif54

endif54:                                          ; preds = %else, %then51
  %123 = load ptr, ptr %_contentHash, align 8
  %124 = call ptr @heap_malloc(i64 4)
  %125 = getelementptr i64, ptr %124, i64 0
  store i64 0, ptr %125, align 4
  %126 = getelementptr i64, ptr %124, i64 1
  store i64 0, ptr %126, align 4
  %127 = getelementptr i64, ptr %124, i64 2
  store i64 0, ptr %127, align 4
  %128 = getelementptr i64, ptr %124, i64 3
  store i64 0, ptr %128, align 4
  %129 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %124, ptr %129, i64 4)
  %130 = getelementptr i64, ptr %129, i64 4
  call void @memcpy(ptr %123, ptr %130, i64 4)
  %131 = getelementptr i64, ptr %130, i64 4
  %132 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %129, ptr %132, i64 8)
  %proposer57 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 0
  %133 = load ptr, ptr %proposer57, align 8
  call void @set_storage(ptr %132, ptr %133)
  %134 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %132, ptr %134, i64 4)
  %last_elem_ptr58 = getelementptr i64, ptr %134, i64 3
  %135 = load i64, ptr %last_elem_ptr58, align 4
  %last_elem59 = add i64 %135, 1
  store i64 %last_elem59, ptr %last_elem_ptr58, align 4
  %deadline60 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 1
  %136 = load i64, ptr %deadline60, align 4
  %137 = call ptr @heap_malloc(i64 4)
  %138 = getelementptr i64, ptr %137, i64 0
  store i64 0, ptr %138, align 4
  %139 = getelementptr i64, ptr %137, i64 1
  store i64 0, ptr %139, align 4
  %140 = getelementptr i64, ptr %137, i64 2
  store i64 0, ptr %140, align 4
  %141 = getelementptr i64, ptr %137, i64 3
  store i64 %136, ptr %141, align 4
  call void @set_storage(ptr %134, ptr %137)
  %142 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %134, ptr %142, i64 4)
  %last_elem_ptr61 = getelementptr i64, ptr %142, i64 3
  %143 = load i64, ptr %last_elem_ptr61, align 4
  %last_elem62 = add i64 %143, 1
  store i64 %last_elem62, ptr %last_elem_ptr61, align 4
  %totalSupport63 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 2
  %144 = load i64, ptr %totalSupport63, align 4
=======
  br label %cond31

cond31:                                           ; preds = %next, %done
  %64 = load i64, ptr %i, align 4
  %vector_length = load i64, ptr %58, align 4
  %65 = icmp ult i64 %64, %vector_length
  br i1 %65, label %body32, label %endfor

body32:                                           ; preds = %cond31
  %66 = load i64, ptr %i, align 4
  %vector_length33 = load i64, ptr %58, align 4
  %67 = sub i64 %vector_length33, 1
  %68 = sub i64 %67, %66
  call void @builtin_range_check(i64 %68)
  %vector_data34 = getelementptr i64, ptr %58, i64 1
  %index_access35 = getelementptr ptr, ptr %vector_data34, i64 %66
  %69 = load ptr, ptr %index_access35, align 8
  %70 = call i64 @memcmp_ne(ptr %69, ptr %4, i64 4)
  call void @builtin_assert(i64 %70)
  br label %next

next:                                             ; preds = %body32
  %71 = load i64, ptr %i, align 4
  %72 = add i64 %71, 1
  store i64 %72, ptr %i, align 4
  br label %cond31

endfor:                                           ; preds = %cond31
  %73 = call ptr @vector_new(i64 19)
  %vector_data36 = getelementptr i64, ptr %73, i64 1
  %index_access37 = getelementptr i64, ptr %vector_data36, i64 0
  store i64 118, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %vector_data36, i64 1
  store i64 111, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %vector_data36, i64 2
  store i64 116, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %vector_data36, i64 3
  store i64 101, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %vector_data36, i64 4
  store i64 114, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %vector_data36, i64 5
  store i64 32, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %vector_data36, i64 6
  store i64 104, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %vector_data36, i64 7
  store i64 97, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %vector_data36, i64 8
  store i64 115, ptr %index_access45, align 4
  %index_access46 = getelementptr i64, ptr %vector_data36, i64 9
  store i64 32, ptr %index_access46, align 4
  %index_access47 = getelementptr i64, ptr %vector_data36, i64 10
  store i64 110, ptr %index_access47, align 4
  %index_access48 = getelementptr i64, ptr %vector_data36, i64 11
  store i64 111, ptr %index_access48, align 4
  %index_access49 = getelementptr i64, ptr %vector_data36, i64 12
  store i64 116, ptr %index_access49, align 4
  %index_access50 = getelementptr i64, ptr %vector_data36, i64 13
  store i64 32, ptr %index_access50, align 4
  %index_access51 = getelementptr i64, ptr %vector_data36, i64 14
  store i64 118, ptr %index_access51, align 4
  %index_access52 = getelementptr i64, ptr %vector_data36, i64 15
  store i64 111, ptr %index_access52, align 4
  %index_access53 = getelementptr i64, ptr %vector_data36, i64 16
  store i64 116, ptr %index_access53, align 4
  %index_access54 = getelementptr i64, ptr %vector_data36, i64 17
  store i64 101, ptr %index_access54, align 4
  %index_access55 = getelementptr i64, ptr %vector_data36, i64 18
  store i64 100, ptr %index_access55, align 4
  %string_start56 = ptrtoint ptr %73 to i64
  call void @prophet_printf(i64 %string_start56, i64 1)
  %74 = call ptr @heap_malloc(i64 4)
  %75 = getelementptr i64, ptr %74, i64 0
  store i64 0, ptr %75, align 4
  %76 = getelementptr i64, ptr %74, i64 1
  store i64 0, ptr %76, align 4
  %77 = getelementptr i64, ptr %74, i64 2
  store i64 0, ptr %77, align 4
  %78 = getelementptr i64, ptr %74, i64 3
  store i64 0, ptr %78, align 4
  %79 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %74, ptr %79, i64 4)
  %80 = getelementptr i64, ptr %79, i64 4
  call void @memcpy(ptr %4, ptr %80, i64 4)
  %81 = getelementptr i64, ptr %80, i64 4
  %82 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %79, ptr %82, i64 8)
  %83 = call ptr @heap_malloc(i64 6)
  %84 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %82, ptr %84)
  %85 = getelementptr i64, ptr %82, i64 3
  %86 = load i64, ptr %85, align 4
  %slot_offset57 = add i64 %86, 1
  store i64 %slot_offset57, ptr %85, align 4
  %proposer58 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 0
  store ptr %84, ptr %proposer58, align 8
  %87 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %82, ptr %87)
  %88 = getelementptr i64, ptr %87, i64 3
  %storage_value59 = load i64, ptr %88, align 4
  %89 = getelementptr i64, ptr %82, i64 3
  %90 = load i64, ptr %89, align 4
  %slot_offset60 = add i64 %90, 1
  store i64 %slot_offset60, ptr %89, align 4
  %deadline61 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 1
  store i64 %storage_value59, ptr %deadline61, align 4
  %91 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %82, ptr %91)
  %92 = getelementptr i64, ptr %91, i64 3
  %storage_value62 = load i64, ptr %92, align 4
  %93 = getelementptr i64, ptr %82, i64 3
  %94 = load i64, ptr %93, align 4
  %slot_offset63 = add i64 %94, 1
  store i64 %slot_offset63, ptr %93, align 4
  %totalSupport64 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 2
  store i64 %storage_value62, ptr %totalSupport64, align 4
  %95 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %82, ptr %95)
  %96 = getelementptr i64, ptr %95, i64 3
  %storage_value65 = load i64, ptr %96, align 4
  %97 = getelementptr i64, ptr %82, i64 3
  %98 = load i64, ptr %97, align 4
  %slot_offset66 = add i64 %98, 1
  store i64 %slot_offset66, ptr %97, align 4
  %totalAgainst67 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 3
  store i64 %storage_value65, ptr %totalAgainst67, align 4
  %99 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %82, ptr %99)
  %100 = getelementptr i64, ptr %99, i64 3
  %storage_value68 = load i64, ptr %100, align 4
  %101 = getelementptr i64, ptr %82, i64 3
  %102 = load i64, ptr %101, align 4
  %slot_offset69 = add i64 %102, 1
  store i64 %slot_offset69, ptr %101, align 4
  %votingType70 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 4
  store i64 %storage_value68, ptr %votingType70, align 4
  %103 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %82, ptr %103)
  %104 = getelementptr i64, ptr %103, i64 3
  %storage_value71 = load i64, ptr %104, align 4
  %105 = getelementptr i64, ptr %82, i64 3
  %106 = load i64, ptr %105, align 4
  %slot_offset72 = add i64 %106, 1
  store i64 %slot_offset72, ptr %105, align 4
  %proposalType73 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 5
  store i64 %storage_value71, ptr %proposalType73, align 4
  %107 = call ptr @vector_new(i64 17)
  %vector_data74 = getelementptr i64, ptr %107, i64 1
  %index_access75 = getelementptr i64, ptr %vector_data74, i64 0
  store i64 112, ptr %index_access75, align 4
  %index_access76 = getelementptr i64, ptr %vector_data74, i64 1
  store i64 114, ptr %index_access76, align 4
  %index_access77 = getelementptr i64, ptr %vector_data74, i64 2
  store i64 111, ptr %index_access77, align 4
  %index_access78 = getelementptr i64, ptr %vector_data74, i64 3
  store i64 112, ptr %index_access78, align 4
  %index_access79 = getelementptr i64, ptr %vector_data74, i64 4
  store i64 111, ptr %index_access79, align 4
  %index_access80 = getelementptr i64, ptr %vector_data74, i64 5
  store i64 115, ptr %index_access80, align 4
  %index_access81 = getelementptr i64, ptr %vector_data74, i64 6
  store i64 97, ptr %index_access81, align 4
  %index_access82 = getelementptr i64, ptr %vector_data74, i64 7
  store i64 108, ptr %index_access82, align 4
  %index_access83 = getelementptr i64, ptr %vector_data74, i64 8
  store i64 46, ptr %index_access83, align 4
  %index_access84 = getelementptr i64, ptr %vector_data74, i64 9
  store i64 100, ptr %index_access84, align 4
  %index_access85 = getelementptr i64, ptr %vector_data74, i64 10
  store i64 101, ptr %index_access85, align 4
  %index_access86 = getelementptr i64, ptr %vector_data74, i64 11
  store i64 97, ptr %index_access86, align 4
  %index_access87 = getelementptr i64, ptr %vector_data74, i64 12
  store i64 100, ptr %index_access87, align 4
  %index_access88 = getelementptr i64, ptr %vector_data74, i64 13
  store i64 108, ptr %index_access88, align 4
  %index_access89 = getelementptr i64, ptr %vector_data74, i64 14
  store i64 105, ptr %index_access89, align 4
  %index_access90 = getelementptr i64, ptr %vector_data74, i64 15
  store i64 110, ptr %index_access90, align 4
  %index_access91 = getelementptr i64, ptr %vector_data74, i64 16
  store i64 101, ptr %index_access91, align 4
  %string_start92 = ptrtoint ptr %107 to i64
  call void @prophet_printf(i64 %string_start92, i64 1)
  %struct_member93 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 1
  %108 = load i64, ptr %struct_member93, align 4
  call void @prophet_printf(i64 %108, i64 3)
  %109 = call ptr @vector_new(i64 17)
  %vector_data94 = getelementptr i64, ptr %109, i64 1
  %index_access95 = getelementptr i64, ptr %vector_data94, i64 0
  store i64 98, ptr %index_access95, align 4
  %index_access96 = getelementptr i64, ptr %vector_data94, i64 1
  store i64 108, ptr %index_access96, align 4
  %index_access97 = getelementptr i64, ptr %vector_data94, i64 2
  store i64 111, ptr %index_access97, align 4
  %index_access98 = getelementptr i64, ptr %vector_data94, i64 3
  store i64 99, ptr %index_access98, align 4
  %index_access99 = getelementptr i64, ptr %vector_data94, i64 4
  store i64 107, ptr %index_access99, align 4
  %index_access100 = getelementptr i64, ptr %vector_data94, i64 5
  store i64 95, ptr %index_access100, align 4
  %index_access101 = getelementptr i64, ptr %vector_data94, i64 6
  store i64 116, ptr %index_access101, align 4
  %index_access102 = getelementptr i64, ptr %vector_data94, i64 7
  store i64 105, ptr %index_access102, align 4
  %index_access103 = getelementptr i64, ptr %vector_data94, i64 8
  store i64 109, ptr %index_access103, align 4
  %index_access104 = getelementptr i64, ptr %vector_data94, i64 9
  store i64 101, ptr %index_access104, align 4
  %index_access105 = getelementptr i64, ptr %vector_data94, i64 10
  store i64 115, ptr %index_access105, align 4
  %index_access106 = getelementptr i64, ptr %vector_data94, i64 11
  store i64 116, ptr %index_access106, align 4
  %index_access107 = getelementptr i64, ptr %vector_data94, i64 12
  store i64 97, ptr %index_access107, align 4
  %index_access108 = getelementptr i64, ptr %vector_data94, i64 13
  store i64 109, ptr %index_access108, align 4
  %index_access109 = getelementptr i64, ptr %vector_data94, i64 14
  store i64 112, ptr %index_access109, align 4
  %index_access110 = getelementptr i64, ptr %vector_data94, i64 15
  store i64 40, ptr %index_access110, align 4
  %index_access111 = getelementptr i64, ptr %vector_data94, i64 16
  store i64 41, ptr %index_access111, align 4
  %string_start112 = ptrtoint ptr %109 to i64
  call void @prophet_printf(i64 %string_start112, i64 1)
  %110 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %110, i64 1)
  %111 = load i64, ptr %110, align 4
  call void @prophet_printf(i64 %111, i64 3)
  %112 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %112, i64 1)
  %113 = load i64, ptr %112, align 4
  %struct_member113 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 1
  %114 = load i64, ptr %struct_member113, align 4
  %115 = icmp ult i64 %113, %114
  %116 = zext i1 %115 to i64
  call void @builtin_assert(i64 %116)
  %117 = call ptr @vector_new(i64 27)
  %vector_data114 = getelementptr i64, ptr %117, i64 1
  %index_access115 = getelementptr i64, ptr %vector_data114, i64 0
  store i64 118, ptr %index_access115, align 4
  %index_access116 = getelementptr i64, ptr %vector_data114, i64 1
  store i64 111, ptr %index_access116, align 4
  %index_access117 = getelementptr i64, ptr %vector_data114, i64 2
  store i64 116, ptr %index_access117, align 4
  %index_access118 = getelementptr i64, ptr %vector_data114, i64 3
  store i64 105, ptr %index_access118, align 4
  %index_access119 = getelementptr i64, ptr %vector_data114, i64 4
  store i64 110, ptr %index_access119, align 4
  %index_access120 = getelementptr i64, ptr %vector_data114, i64 5
  store i64 103, ptr %index_access120, align 4
  %index_access121 = getelementptr i64, ptr %vector_data114, i64 6
  store i64 32, ptr %index_access121, align 4
  %index_access122 = getelementptr i64, ptr %vector_data114, i64 7
  store i64 112, ptr %index_access122, align 4
  %index_access123 = getelementptr i64, ptr %vector_data114, i64 8
  store i64 101, ptr %index_access123, align 4
  %index_access124 = getelementptr i64, ptr %vector_data114, i64 9
  store i64 114, ptr %index_access124, align 4
  %index_access125 = getelementptr i64, ptr %vector_data114, i64 10
  store i64 105, ptr %index_access125, align 4
  %index_access126 = getelementptr i64, ptr %vector_data114, i64 11
  store i64 111, ptr %index_access126, align 4
  %index_access127 = getelementptr i64, ptr %vector_data114, i64 12
  store i64 100, ptr %index_access127, align 4
  %index_access128 = getelementptr i64, ptr %vector_data114, i64 13
  store i64 32, ptr %index_access128, align 4
  %index_access129 = getelementptr i64, ptr %vector_data114, i64 14
  store i64 104, ptr %index_access129, align 4
  %index_access130 = getelementptr i64, ptr %vector_data114, i64 15
  store i64 97, ptr %index_access130, align 4
  %index_access131 = getelementptr i64, ptr %vector_data114, i64 16
  store i64 115, ptr %index_access131, align 4
  %index_access132 = getelementptr i64, ptr %vector_data114, i64 17
  store i64 32, ptr %index_access132, align 4
  %index_access133 = getelementptr i64, ptr %vector_data114, i64 18
  store i64 110, ptr %index_access133, align 4
  %index_access134 = getelementptr i64, ptr %vector_data114, i64 19
  store i64 111, ptr %index_access134, align 4
  %index_access135 = getelementptr i64, ptr %vector_data114, i64 20
  store i64 116, ptr %index_access135, align 4
  %index_access136 = getelementptr i64, ptr %vector_data114, i64 21
  store i64 32, ptr %index_access136, align 4
  %index_access137 = getelementptr i64, ptr %vector_data114, i64 22
  store i64 101, ptr %index_access137, align 4
  %index_access138 = getelementptr i64, ptr %vector_data114, i64 23
  store i64 110, ptr %index_access138, align 4
  %index_access139 = getelementptr i64, ptr %vector_data114, i64 24
  store i64 100, ptr %index_access139, align 4
  %index_access140 = getelementptr i64, ptr %vector_data114, i64 25
  store i64 101, ptr %index_access140, align 4
  %index_access141 = getelementptr i64, ptr %vector_data114, i64 26
  store i64 100, ptr %index_access141, align 4
  %string_start142 = ptrtoint ptr %117 to i64
  call void @prophet_printf(i64 %string_start142, i64 1)
  %118 = load i64, ptr %_support, align 4
  %119 = trunc i64 %118 to i1
  br i1 %119, label %then, label %else

then:                                             ; preds = %endfor
  %struct_member143 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 2
  %struct_member144 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 2
  %120 = load i64, ptr %struct_member144, align 4
  %121 = load i64, ptr %_weight, align 4
  %122 = add i64 %120, %121
  call void @builtin_range_check(i64 %122)
  store i64 %122, ptr %struct_member143, align 4
  br label %endif

else:                                             ; preds = %endfor
  %struct_member145 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 3
  %struct_member146 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %83, i32 0, i32 3
  %123 = load i64, ptr %struct_member146, align 4
  %124 = load i64, ptr %_weight, align 4
  %125 = add i64 %123, %124
  call void @builtin_range_check(i64 %125)
  store i64 %125, ptr %struct_member145, align 4
  br label %endif

endif:                                            ; preds = %else, %then
  %126 = call ptr @heap_malloc(i64 4)
  %127 = getelementptr i64, ptr %126, i64 0
  call void @get_context_data(ptr %127, i64 8)
  %128 = getelementptr i64, ptr %126, i64 1
  call void @get_context_data(ptr %128, i64 9)
  %129 = getelementptr i64, ptr %126, i64 2
  call void @get_context_data(ptr %129, i64 10)
  %130 = getelementptr i64, ptr %126, i64 3
  call void @get_context_data(ptr %130, i64 11)
  %131 = call ptr @heap_malloc(i64 4)
  %132 = getelementptr i64, ptr %131, i64 0
  store i64 0, ptr %132, align 4
  %133 = getelementptr i64, ptr %131, i64 1
  store i64 0, ptr %133, align 4
  %134 = getelementptr i64, ptr %131, i64 2
  store i64 0, ptr %134, align 4
  %135 = getelementptr i64, ptr %131, i64 3
  store i64 2, ptr %135, align 4
  %136 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %131, ptr %136, i64 4)
  %137 = getelementptr i64, ptr %136, i64 4
  call void @memcpy(ptr %126, ptr %137, i64 4)
  %138 = getelementptr i64, ptr %137, i64 4
  %139 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %136, ptr %139, i64 8)
  %140 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %139, ptr %140)
  %length147 = getelementptr i64, ptr %140, i64 3
  %141 = load i64, ptr %length147, align 4
  %142 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %139, ptr %142, i64 4)
  %hash_value_low = getelementptr i64, ptr %142, i64 3
  %143 = load i64, ptr %hash_value_low, align 4
  %144 = mul i64 %141, 1
  %storage_array_offset = add i64 %143, %144
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  call void @set_storage(ptr %142, ptr %4)
  %new_length = add i64 %141, 1
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %145 = call ptr @heap_malloc(i64 4)
  %146 = getelementptr i64, ptr %145, i64 0
  store i64 0, ptr %146, align 4
  %147 = getelementptr i64, ptr %145, i64 1
  store i64 0, ptr %147, align 4
  %148 = getelementptr i64, ptr %145, i64 2
  store i64 0, ptr %148, align 4
  %149 = getelementptr i64, ptr %145, i64 3
<<<<<<< HEAD
  store i64 %144, ptr %149, align 4
  call void @set_storage(ptr %142, ptr %145)
  %150 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %142, ptr %150, i64 4)
  %last_elem_ptr64 = getelementptr i64, ptr %150, i64 3
  %151 = load i64, ptr %last_elem_ptr64, align 4
  %last_elem65 = add i64 %151, 1
  store i64 %last_elem65, ptr %last_elem_ptr64, align 4
  %totalAgainst66 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 3
  %152 = load i64, ptr %totalAgainst66, align 4
  %153 = call ptr @heap_malloc(i64 4)
  %154 = getelementptr i64, ptr %153, i64 0
  store i64 0, ptr %154, align 4
  %155 = getelementptr i64, ptr %153, i64 1
  store i64 0, ptr %155, align 4
  %156 = getelementptr i64, ptr %153, i64 2
  store i64 0, ptr %156, align 4
  %157 = getelementptr i64, ptr %153, i64 3
  store i64 %152, ptr %157, align 4
  call void @set_storage(ptr %150, ptr %153)
  %158 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %150, ptr %158, i64 4)
  %last_elem_ptr67 = getelementptr i64, ptr %158, i64 3
  %159 = load i64, ptr %last_elem_ptr67, align 4
  %last_elem68 = add i64 %159, 1
  store i64 %last_elem68, ptr %last_elem_ptr67, align 4
  %votingType69 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 4
  %160 = load i64, ptr %votingType69, align 4
  %161 = call ptr @heap_malloc(i64 4)
  %162 = getelementptr i64, ptr %161, i64 0
  store i64 0, ptr %162, align 4
  %163 = getelementptr i64, ptr %161, i64 1
  store i64 0, ptr %163, align 4
  %164 = getelementptr i64, ptr %161, i64 2
  store i64 0, ptr %164, align 4
  %165 = getelementptr i64, ptr %161, i64 3
  store i64 %160, ptr %165, align 4
  call void @set_storage(ptr %158, ptr %161)
  %166 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %158, ptr %166, i64 4)
  %last_elem_ptr70 = getelementptr i64, ptr %166, i64 3
  %167 = load i64, ptr %last_elem_ptr70, align 4
  %last_elem71 = add i64 %167, 1
  store i64 %last_elem71, ptr %last_elem_ptr70, align 4
  %proposalType72 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %86, i32 0, i32 5
  %168 = load i64, ptr %proposalType72, align 4
  %169 = call ptr @heap_malloc(i64 4)
  %170 = getelementptr i64, ptr %169, i64 0
  store i64 0, ptr %170, align 4
  %171 = getelementptr i64, ptr %169, i64 1
  store i64 0, ptr %171, align 4
  %172 = getelementptr i64, ptr %169, i64 2
  store i64 0, ptr %172, align 4
  %173 = getelementptr i64, ptr %169, i64 3
  store i64 %168, ptr %173, align 4
  call void @set_storage(ptr %166, ptr %169)
  %174 = call ptr @heap_malloc(i64 4)
  %175 = getelementptr i64, ptr %174, i64 0
  call void @get_context_data(ptr %175, i64 8)
  %176 = getelementptr i64, ptr %174, i64 1
  call void @get_context_data(ptr %176, i64 9)
  %177 = getelementptr i64, ptr %174, i64 2
  call void @get_context_data(ptr %177, i64 10)
  %178 = getelementptr i64, ptr %174, i64 3
  call void @get_context_data(ptr %178, i64 11)
  %179 = call ptr @heap_malloc(i64 4)
  %180 = getelementptr i64, ptr %179, i64 0
  store i64 0, ptr %180, align 4
  %181 = getelementptr i64, ptr %179, i64 1
  store i64 0, ptr %181, align 4
  %182 = getelementptr i64, ptr %179, i64 2
  store i64 0, ptr %182, align 4
  %183 = getelementptr i64, ptr %179, i64 3
  store i64 2, ptr %183, align 4
  %184 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %179, ptr %184, i64 4)
  %185 = getelementptr i64, ptr %184, i64 4
  call void @memcpy(ptr %174, ptr %185, i64 4)
  %186 = getelementptr i64, ptr %185, i64 4
  %187 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %184, ptr %187, i64 8)
  %188 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %187, ptr %188)
  %length73 = getelementptr i64, ptr %188, i64 3
  %189 = load i64, ptr %length73, align 4
  %190 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %187, ptr %190, i64 4)
  %hash_value_low = getelementptr i64, ptr %190, i64 3
  %191 = load i64, ptr %hash_value_low, align 4
  %192 = mul i64 %189, 1
  %storage_array_offset = add i64 %191, %192
  store i64 %storage_array_offset, ptr %hash_value_low, align 4
  %193 = load ptr, ptr %_contentHash, align 8
  call void @set_storage(ptr %190, ptr %193)
  %new_length = add i64 %189, 1
  %194 = call ptr @heap_malloc(i64 4)
  %195 = getelementptr i64, ptr %194, i64 0
  store i64 0, ptr %195, align 4
  %196 = getelementptr i64, ptr %194, i64 1
  store i64 0, ptr %196, align 4
  %197 = getelementptr i64, ptr %194, i64 2
  store i64 0, ptr %197, align 4
  %198 = getelementptr i64, ptr %194, i64 3
  store i64 %new_length, ptr %198, align 4
  call void @set_storage(ptr %187, ptr %194)
=======
  store i64 %new_length, ptr %149, align 4
  call void @set_storage(ptr %139, ptr %145)
>>>>>>> 7998cf0 (fixed llvm type bug.)
  ret void
}

define ptr @getProposal(ptr %0) {
entry:
  %_contentHash = alloca ptr, align 8
  store ptr %0, ptr %_contentHash, align 8
  %1 = load ptr, ptr %_contentHash, align 8
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
  %11 = call ptr @heap_malloc(i64 6)
  %12 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %12)
<<<<<<< HEAD
  %13 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %10, ptr %13, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %13, i64 3
  %14 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %14, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  %proposer = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 0
  store ptr %12, ptr %proposer, align 8
  %15 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %15)
  %16 = getelementptr i64, ptr %15, i64 3
  %storage_value = load i64, ptr %16, align 4
  %17 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %13, ptr %17, i64 4)
  %last_elem_ptr1 = getelementptr i64, ptr %17, i64 3
  %18 = load i64, ptr %last_elem_ptr1, align 4
  %last_elem2 = add i64 %18, 1
  store i64 %last_elem2, ptr %last_elem_ptr1, align 4
  %deadline = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 1
  store i64 %storage_value, ptr %deadline, align 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %17, ptr %19)
  %20 = getelementptr i64, ptr %19, i64 3
  %storage_value3 = load i64, ptr %20, align 4
  %21 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %17, ptr %21, i64 4)
  %last_elem_ptr4 = getelementptr i64, ptr %21, i64 3
  %22 = load i64, ptr %last_elem_ptr4, align 4
  %last_elem5 = add i64 %22, 1
  store i64 %last_elem5, ptr %last_elem_ptr4, align 4
  %totalSupport = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 2
  store i64 %storage_value3, ptr %totalSupport, align 4
  %23 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %21, ptr %23)
  %24 = getelementptr i64, ptr %23, i64 3
  %storage_value6 = load i64, ptr %24, align 4
  %25 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %21, ptr %25, i64 4)
  %last_elem_ptr7 = getelementptr i64, ptr %25, i64 3
  %26 = load i64, ptr %last_elem_ptr7, align 4
  %last_elem8 = add i64 %26, 1
  store i64 %last_elem8, ptr %last_elem_ptr7, align 4
  %totalAgainst = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 3
  store i64 %storage_value6, ptr %totalAgainst, align 4
  %27 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %25, ptr %27)
  %28 = getelementptr i64, ptr %27, i64 3
  %storage_value9 = load i64, ptr %28, align 4
  %29 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %25, ptr %29, i64 4)
  %last_elem_ptr10 = getelementptr i64, ptr %29, i64 3
  %30 = load i64, ptr %last_elem_ptr10, align 4
  %last_elem11 = add i64 %30, 1
  store i64 %last_elem11, ptr %last_elem_ptr10, align 4
  %votingType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 4
  store i64 %storage_value9, ptr %votingType, align 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %29, ptr %31)
  %32 = getelementptr i64, ptr %31, i64 3
  %storage_value12 = load i64, ptr %32, align 4
  %33 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %29, ptr %33, i64 4)
  %last_elem_ptr13 = getelementptr i64, ptr %33, i64 3
  %34 = load i64, ptr %last_elem_ptr13, align 4
  %last_elem14 = add i64 %34, 1
  store i64 %last_elem14, ptr %last_elem_ptr13, align 4
  %proposalType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 5
  store i64 %storage_value12, ptr %proposalType, align 4
=======
  %13 = getelementptr i64, ptr %10, i64 3
  %14 = load i64, ptr %13, align 4
  %slot_offset = add i64 %14, 1
  store i64 %slot_offset, ptr %13, align 4
  %proposer = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 0
  store ptr %12, ptr %proposer, align 8
  %15 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %15)
  %16 = getelementptr i64, ptr %15, i64 3
  %storage_value = load i64, ptr %16, align 4
  %17 = getelementptr i64, ptr %10, i64 3
  %18 = load i64, ptr %17, align 4
  %slot_offset1 = add i64 %18, 1
  store i64 %slot_offset1, ptr %17, align 4
  %deadline = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 1
  store i64 %storage_value, ptr %deadline, align 4
  %19 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %19)
  %20 = getelementptr i64, ptr %19, i64 3
  %storage_value2 = load i64, ptr %20, align 4
  %21 = getelementptr i64, ptr %10, i64 3
  %22 = load i64, ptr %21, align 4
  %slot_offset3 = add i64 %22, 1
  store i64 %slot_offset3, ptr %21, align 4
  %totalSupport = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 2
  store i64 %storage_value2, ptr %totalSupport, align 4
  %23 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %23)
  %24 = getelementptr i64, ptr %23, i64 3
  %storage_value4 = load i64, ptr %24, align 4
  %25 = getelementptr i64, ptr %10, i64 3
  %26 = load i64, ptr %25, align 4
  %slot_offset5 = add i64 %26, 1
  store i64 %slot_offset5, ptr %25, align 4
  %totalAgainst = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 3
  store i64 %storage_value4, ptr %totalAgainst, align 4
  %27 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %27)
  %28 = getelementptr i64, ptr %27, i64 3
  %storage_value6 = load i64, ptr %28, align 4
  %29 = getelementptr i64, ptr %10, i64 3
  %30 = load i64, ptr %29, align 4
  %slot_offset7 = add i64 %30, 1
  store i64 %slot_offset7, ptr %29, align 4
  %votingType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 4
  store i64 %storage_value6, ptr %votingType, align 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %10, ptr %31)
  %32 = getelementptr i64, ptr %31, i64 3
  %storage_value8 = load i64, ptr %32, align 4
  %33 = getelementptr i64, ptr %10, i64 3
  %34 = load i64, ptr %33, align 4
  %slot_offset9 = add i64 %34, 1
  store i64 %slot_offset9, ptr %33, align 4
  %proposalType = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %11, i32 0, i32 5
  store i64 %storage_value8, ptr %proposalType, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
  ret ptr %11
}

define ptr @getProposalsByOwner(ptr %0) {
entry:
  %1 = alloca ptr, align 8
<<<<<<< HEAD
  %index_alloca = alloca i64, align 8
  %_owner = alloca ptr, align 8
  store ptr %0, ptr %_owner, align 8
  %2 = load ptr, ptr %_owner, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 1, ptr %7, align 4
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
  store ptr %15, ptr %1, align 8
=======
  %index_alloca34 = alloca i64, align 8
  %index_alloca24 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %_owner = alloca ptr, align 8
  store ptr %0, ptr %_owner, align 8
  %3 = load ptr, ptr %_owner, align 8
  %4 = call ptr @vector_new(i64 19)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 103, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 116, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 80, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 114, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 5
  store i64 111, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 6
  store i64 112, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 7
  store i64 111, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 8
  store i64 115, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data, i64 9
  store i64 97, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data, i64 10
  store i64 108, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data, i64 11
  store i64 115, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data, i64 12
  store i64 66, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data, i64 13
  store i64 121, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %vector_data, i64 14
  store i64 79, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data, i64 15
  store i64 119, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %vector_data, i64 16
  store i64 110, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %vector_data, i64 17
  store i64 101, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %vector_data, i64 18
  store i64 114, ptr %index_access18, align 4
  %string_start = ptrtoint ptr %4 to i64
  call void @prophet_printf(i64 %string_start, i64 1)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 1, ptr %9, align 4
  %10 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %5, ptr %10, i64 4)
  %11 = getelementptr i64, ptr %10, i64 4
  call void @memcpy(ptr %3, ptr %11, i64 4)
  %12 = getelementptr i64, ptr %11, i64 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %10, ptr %13, i64 8)
  %14 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %14)
  %length = getelementptr i64, ptr %14, i64 3
  %15 = load i64, ptr %length, align 4
  %16 = call ptr @vector_new(i64 %15)
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %13, ptr %17, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %17, ptr %2, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
<<<<<<< HEAD
  %loop_cond = icmp ult i64 %index_value, %13
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %16 = load ptr, ptr %1, align 8
  %vector_data = getelementptr i64, ptr %14, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %17 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %16, ptr %17)
  %18 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %18, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %18, i64 3
  %19 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %19, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store ptr %17, ptr %index_access, align 8
  store ptr %18, ptr %1, align 8
=======
  %loop_cond = icmp ult i64 %index_value, %15
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %18 = load ptr, ptr %2, align 8
  %vector_data19 = getelementptr i64, ptr %16, i64 1
  %index_access20 = getelementptr ptr, ptr %vector_data19, i64 %index_value
  %19 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %19)
  %20 = getelementptr i64, ptr %18, i64 3
  %21 = load i64, ptr %20, align 4
  %slot_offset = add i64 %21, 1
  store i64 %slot_offset, ptr %20, align 4
  store ptr %19, ptr %index_access20, align 8
  store ptr %18, ptr %2, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
<<<<<<< HEAD
  ret ptr %14
=======
  %vector_length = load i64, ptr %16, align 4
  store i64 0, ptr %index_alloca24, align 4
  br label %cond21

cond21:                                           ; preds = %body22, %done
  %index_value25 = load i64, ptr %index_alloca24, align 4
  %loop_cond26 = icmp ult i64 %index_value25, %vector_length
  br i1 %loop_cond26, label %body22, label %done23

body22:                                           ; preds = %cond21
  %vector_data27 = getelementptr i64, ptr %16, i64 1
  %index_access28 = getelementptr ptr, ptr %vector_data27, i64 %index_value25
  %22 = load ptr, ptr %index_access28, align 8
  %hash_start = ptrtoint ptr %22 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  %next_index29 = add i64 %index_value25, 1
  store i64 %next_index29, ptr %index_alloca24, align 4
  br label %cond21

done23:                                           ; preds = %cond21
  %23 = call ptr @heap_malloc(i64 4)
  %24 = getelementptr i64, ptr %23, i64 0
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %23, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %23, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %23, i64 3
  store i64 1, ptr %27, align 4
  %28 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %23, ptr %28, i64 4)
  %29 = getelementptr i64, ptr %28, i64 4
  call void @memcpy(ptr %3, ptr %29, i64 4)
  %30 = getelementptr i64, ptr %29, i64 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %28, ptr %31, i64 8)
  %32 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %31, ptr %32)
  %length30 = getelementptr i64, ptr %32, i64 3
  %33 = load i64, ptr %length30, align 4
  %34 = call ptr @vector_new(i64 %33)
  %35 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %31, ptr %35, i64 4)
  store i64 0, ptr %index_alloca34, align 4
  store ptr %35, ptr %1, align 8
  br label %cond31

cond31:                                           ; preds = %body32, %done23
  %index_value35 = load i64, ptr %index_alloca34, align 4
  %loop_cond36 = icmp ult i64 %index_value35, %33
  br i1 %loop_cond36, label %body32, label %done33

body32:                                           ; preds = %cond31
  %36 = load ptr, ptr %1, align 8
  %vector_data37 = getelementptr i64, ptr %34, i64 1
  %index_access38 = getelementptr ptr, ptr %vector_data37, i64 %index_value35
  %37 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %36, ptr %37)
  %38 = getelementptr i64, ptr %36, i64 3
  %39 = load i64, ptr %38, align 4
  %slot_offset39 = add i64 %39, 1
  store i64 %slot_offset39, ptr %38, align 4
  store ptr %37, ptr %index_access38, align 8
  store ptr %36, ptr %1, align 8
  %next_index40 = add i64 %index_value35, 1
  store i64 %next_index40, ptr %index_alloca34, align 4
  br label %cond31

done33:                                           ; preds = %cond31
  ret ptr %34
>>>>>>> 7998cf0 (fixed llvm type bug.)
}

define ptr @getProposalsByVoter(ptr %0) {
entry:
  %1 = alloca ptr, align 8
<<<<<<< HEAD
  %index_alloca = alloca i64, align 8
  %_voter = alloca ptr, align 8
  store ptr %0, ptr %_voter, align 8
  %2 = load ptr, ptr %_voter, align 8
  %3 = call ptr @heap_malloc(i64 4)
  %4 = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %3, i64 3
  store i64 2, ptr %7, align 4
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
  store ptr %15, ptr %1, align 8
=======
  %index_alloca34 = alloca i64, align 8
  %index_alloca24 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %_voter = alloca ptr, align 8
  store ptr %0, ptr %_voter, align 8
  %3 = load ptr, ptr %_voter, align 8
  %4 = call ptr @vector_new(i64 19)
  %vector_data = getelementptr i64, ptr %4, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 103, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 116, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 80, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 114, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 5
  store i64 111, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 6
  store i64 112, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 7
  store i64 111, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 8
  store i64 115, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data, i64 9
  store i64 97, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data, i64 10
  store i64 108, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data, i64 11
  store i64 115, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data, i64 12
  store i64 66, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data, i64 13
  store i64 121, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %vector_data, i64 14
  store i64 86, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data, i64 15
  store i64 111, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %vector_data, i64 16
  store i64 116, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %vector_data, i64 17
  store i64 101, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %vector_data, i64 18
  store i64 114, ptr %index_access18, align 4
  %string_start = ptrtoint ptr %4 to i64
  call void @prophet_printf(i64 %string_start, i64 1)
  %5 = call ptr @heap_malloc(i64 4)
  %6 = getelementptr i64, ptr %5, i64 0
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %5, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %5, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %5, i64 3
  store i64 2, ptr %9, align 4
  %10 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %5, ptr %10, i64 4)
  %11 = getelementptr i64, ptr %10, i64 4
  call void @memcpy(ptr %3, ptr %11, i64 4)
  %12 = getelementptr i64, ptr %11, i64 4
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %10, ptr %13, i64 8)
  %14 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %13, ptr %14)
  %length = getelementptr i64, ptr %14, i64 3
  %15 = load i64, ptr %length, align 4
  %16 = call ptr @vector_new(i64 %15)
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %13, ptr %17, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %17, ptr %2, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
<<<<<<< HEAD
  %loop_cond = icmp ult i64 %index_value, %13
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %16 = load ptr, ptr %1, align 8
  %vector_data = getelementptr i64, ptr %14, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  %17 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %16, ptr %17)
  %18 = call ptr @heap_malloc(i64 4)
  call void @memcpy(ptr %16, ptr %18, i64 4)
  %last_elem_ptr = getelementptr i64, ptr %18, i64 3
  %19 = load i64, ptr %last_elem_ptr, align 4
  %last_elem = add i64 %19, 1
  store i64 %last_elem, ptr %last_elem_ptr, align 4
  store ptr %17, ptr %index_access, align 8
  store ptr %18, ptr %1, align 8
=======
  %loop_cond = icmp ult i64 %index_value, %15
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %18 = load ptr, ptr %2, align 8
  %vector_data19 = getelementptr i64, ptr %16, i64 1
  %index_access20 = getelementptr ptr, ptr %vector_data19, i64 %index_value
  %19 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %18, ptr %19)
  %20 = getelementptr i64, ptr %18, i64 3
  %21 = load i64, ptr %20, align 4
  %slot_offset = add i64 %21, 1
  store i64 %slot_offset, ptr %20, align 4
  store ptr %19, ptr %index_access20, align 8
  store ptr %18, ptr %2, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
<<<<<<< HEAD
  ret ptr %14
=======
  %vector_length = load i64, ptr %16, align 4
  store i64 0, ptr %index_alloca24, align 4
  br label %cond21

cond21:                                           ; preds = %body22, %done
  %index_value25 = load i64, ptr %index_alloca24, align 4
  %loop_cond26 = icmp ult i64 %index_value25, %vector_length
  br i1 %loop_cond26, label %body22, label %done23

body22:                                           ; preds = %cond21
  %vector_data27 = getelementptr i64, ptr %16, i64 1
  %index_access28 = getelementptr ptr, ptr %vector_data27, i64 %index_value25
  %22 = load ptr, ptr %index_access28, align 8
  %hash_start = ptrtoint ptr %22 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  %next_index29 = add i64 %index_value25, 1
  store i64 %next_index29, ptr %index_alloca24, align 4
  br label %cond21

done23:                                           ; preds = %cond21
  %23 = call ptr @heap_malloc(i64 4)
  %24 = getelementptr i64, ptr %23, i64 0
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %23, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %23, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %23, i64 3
  store i64 2, ptr %27, align 4
  %28 = call ptr @heap_malloc(i64 8)
  call void @memcpy(ptr %23, ptr %28, i64 4)
  %29 = getelementptr i64, ptr %28, i64 4
  call void @memcpy(ptr %3, ptr %29, i64 4)
  %30 = getelementptr i64, ptr %29, i64 4
  %31 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %28, ptr %31, i64 8)
  %32 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %31, ptr %32)
  %length30 = getelementptr i64, ptr %32, i64 3
  %33 = load i64, ptr %length30, align 4
  %34 = call ptr @vector_new(i64 %33)
  %35 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %31, ptr %35, i64 4)
  store i64 0, ptr %index_alloca34, align 4
  store ptr %35, ptr %1, align 8
  br label %cond31

cond31:                                           ; preds = %body32, %done23
  %index_value35 = load i64, ptr %index_alloca34, align 4
  %loop_cond36 = icmp ult i64 %index_value35, %33
  br i1 %loop_cond36, label %body32, label %done33

body32:                                           ; preds = %cond31
  %36 = load ptr, ptr %1, align 8
  %vector_data37 = getelementptr i64, ptr %34, i64 1
  %index_access38 = getelementptr ptr, ptr %vector_data37, i64 %index_value35
  %37 = call ptr @heap_malloc(i64 4)
  call void @get_storage(ptr %36, ptr %37)
  %38 = getelementptr i64, ptr %36, i64 3
  %39 = load i64, ptr %38, align 4
  %slot_offset39 = add i64 %39, 1
  store i64 %slot_offset39, ptr %38, align 4
  store ptr %37, ptr %index_access38, align 8
  store ptr %36, ptr %1, align 8
  %next_index40 = add i64 %index_value35, 1
  store i64 %next_index40, ptr %index_alloca34, align 4
  br label %cond31

done33:                                           ; preds = %cond31
  ret ptr %34
>>>>>>> 7998cf0 (fixed llvm type bug.)
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
<<<<<<< HEAD
  %index_ptr46 = alloca i64, align 8
  %buffer_offset44 = alloca i64, align 8
  %index_ptr31 = alloca i64, align 8
  %array_size30 = alloca i64, align 8
  %index_ptr18 = alloca i64, align 8
=======
  %index_ptr48 = alloca i64, align 8
  %buffer_offset46 = alloca i64, align 8
  %index_ptr34 = alloca i64, align 8
  %array_size32 = alloca i64, align 8
  %index_ptr21 = alloca i64, align 8
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %buffer_offset = alloca i64, align 8
  %index_ptr = alloca i64, align 8
  %array_size = alloca i64, align 8
  switch i64 %0, label %missing_function [
    i64 86928995, label %func_0_dispatch
    i64 2465217104, label %func_1_dispatch
    i64 2916530895, label %func_2_dispatch
    i64 2880503592, label %func_3_dispatch
    i64 2566425647, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = getelementptr ptr, ptr %2, i64 0
  %4 = getelementptr ptr, ptr %3, i64 4
  %5 = load i64, ptr %4, align 4
  %6 = getelementptr ptr, ptr %4, i64 1
  %7 = load i64, ptr %6, align 4
  %8 = getelementptr ptr, ptr %6, i64 1
  %9 = load i64, ptr %8, align 4
  call void @createProposal(ptr %3, i64 %5, i64 %7, i64 %9)
  %10 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %10, align 4
  call void @set_tape_data(ptr %10, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %11 = getelementptr ptr, ptr %2, i64 0
  %12 = getelementptr ptr, ptr %11, i64 4
  %13 = load i64, ptr %12, align 4
  %14 = getelementptr ptr, ptr %12, i64 1
  %15 = load i64, ptr %14, align 4
  call void @vote(ptr %11, i64 %13, i64 %15)
  %16 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %16, align 4
  call void @set_tape_data(ptr %16, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %17 = getelementptr ptr, ptr %2, i64 0
  %18 = call ptr @getProposal(ptr %17)
<<<<<<< HEAD
  %19 = call ptr @heap_malloc(i64 10)
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 0
  %strcut_member = load ptr, ptr %struct_member, align 8
  %struct_offset = getelementptr ptr, ptr %19, i64 0
  %20 = getelementptr i64, ptr %strcut_member, i64 0
  %21 = load i64, ptr %20, align 4
  %22 = getelementptr i64, ptr %struct_offset, i64 0
  store i64 %21, ptr %22, align 4
  %23 = getelementptr i64, ptr %strcut_member, i64 1
  %24 = load i64, ptr %23, align 4
  %25 = getelementptr i64, ptr %struct_offset, i64 1
  store i64 %24, ptr %25, align 4
  %26 = getelementptr i64, ptr %strcut_member, i64 2
  %27 = load i64, ptr %26, align 4
  %28 = getelementptr i64, ptr %struct_offset, i64 2
  store i64 %27, ptr %28, align 4
  %29 = getelementptr i64, ptr %strcut_member, i64 3
  %30 = load i64, ptr %29, align 4
  %31 = getelementptr i64, ptr %struct_offset, i64 3
  store i64 %30, ptr %31, align 4
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 1
  %strcut_member2 = load i64, ptr %struct_member1, align 4
  %struct_offset3 = getelementptr ptr, ptr %struct_offset, i64 4
  store i64 %strcut_member2, ptr %struct_offset3, align 4
  %struct_member4 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 2
  %strcut_member5 = load i64, ptr %struct_member4, align 4
  %struct_offset6 = getelementptr ptr, ptr %struct_offset3, i64 1
  store i64 %strcut_member5, ptr %struct_offset6, align 4
  %struct_member7 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 3
  %strcut_member8 = load i64, ptr %struct_member7, align 4
  %struct_offset9 = getelementptr ptr, ptr %struct_offset6, i64 1
  store i64 %strcut_member8, ptr %struct_offset9, align 4
  %struct_member10 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 4
  %strcut_member11 = load i64, ptr %struct_member10, align 4
  %struct_offset12 = getelementptr ptr, ptr %struct_offset9, i64 1
  store i64 %strcut_member11, ptr %struct_offset12, align 4
  %struct_member13 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 5
  %strcut_member14 = load i64, ptr %struct_member13, align 4
  %struct_offset15 = getelementptr ptr, ptr %struct_offset12, i64 1
  store i64 %strcut_member14, ptr %struct_offset15, align 4
  %32 = getelementptr ptr, ptr %19, i64 9
  store i64 9, ptr %32, align 4
  call void @set_tape_data(ptr %19, i64 10)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %33 = getelementptr ptr, ptr %2, i64 0
  %34 = call ptr @getProposalsByOwner(ptr %33)
  store i64 0, ptr %array_size, align 4
  %35 = load i64, ptr %array_size, align 4
  %36 = add i64 %35, 1
  store i64 %36, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_3_dispatch
  %vector_length = load i64, ptr %34, align 4
  %37 = load i64, ptr %index_ptr, align 4
  %38 = icmp ult i64 %37, %vector_length
  br i1 %38, label %body, label %end_for

body:                                             ; preds = %cond
  %array_index = load i64, ptr %index_ptr, align 4
  %vector_length16 = load i64, ptr %34, align 4
  %39 = sub i64 %vector_length16, 1
  %40 = sub i64 %39, %array_index
  call void @builtin_range_check(i64 %40)
  %vector_data = getelementptr i64, ptr %34, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %array_index
  %array_element = load ptr, ptr %index_access, align 8
  %41 = load i64, ptr %array_size, align 4
  %42 = add i64 %41, 4
  store i64 %42, ptr %array_size, align 4
  br label %next

next:                                             ; preds = %body
  %index = load i64, ptr %index_ptr, align 4
  %43 = add i64 %index, 1
  store i64 %43, ptr %index_ptr, align 4
  br label %cond

=======
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 0
  %19 = load ptr, ptr %struct_member, align 8
  %20 = call ptr @heap_malloc(i64 10)
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 0
  %strcut_member = load ptr, ptr %struct_member1, align 8
  %struct_offset = getelementptr ptr, ptr %20, i64 0
  %21 = getelementptr i64, ptr %strcut_member, i64 0
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %struct_offset, i64 0
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %strcut_member, i64 1
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %struct_offset, i64 1
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %strcut_member, i64 2
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %struct_offset, i64 2
  store i64 %28, ptr %29, align 4
  %30 = getelementptr i64, ptr %strcut_member, i64 3
  %31 = load i64, ptr %30, align 4
  %32 = getelementptr i64, ptr %struct_offset, i64 3
  store i64 %31, ptr %32, align 4
  %struct_member2 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 1
  %strcut_member3 = load i64, ptr %struct_member2, align 4
  %struct_offset4 = getelementptr ptr, ptr %struct_offset, i64 4
  store i64 %strcut_member3, ptr %struct_offset4, align 4
  %struct_member5 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 2
  %strcut_member6 = load i64, ptr %struct_member5, align 4
  %struct_offset7 = getelementptr ptr, ptr %struct_offset4, i64 1
  store i64 %strcut_member6, ptr %struct_offset7, align 4
  %struct_member8 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 3
  %strcut_member9 = load i64, ptr %struct_member8, align 4
  %struct_offset10 = getelementptr ptr, ptr %struct_offset7, i64 1
  store i64 %strcut_member9, ptr %struct_offset10, align 4
  %struct_member11 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 4
  %strcut_member12 = load i64, ptr %struct_member11, align 4
  %struct_offset13 = getelementptr ptr, ptr %struct_offset10, i64 1
  store i64 %strcut_member12, ptr %struct_offset13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, i64, i64 }, ptr %18, i32 0, i32 5
  %strcut_member15 = load i64, ptr %struct_member14, align 4
  %struct_offset16 = getelementptr ptr, ptr %struct_offset13, i64 1
  store i64 %strcut_member15, ptr %struct_offset16, align 4
  %33 = getelementptr ptr, ptr %20, i64 9
  store i64 9, ptr %33, align 4
  call void @set_tape_data(ptr %20, i64 10)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %34 = getelementptr ptr, ptr %2, i64 0
  %35 = call ptr @getProposalsByOwner(ptr %34)
  store i64 0, ptr %array_size, align 4
  %vector_length = load i64, ptr %35, align 4
  %36 = load i64, ptr %array_size, align 4
  %37 = add i64 %36, %vector_length
  store i64 %37, ptr %array_size, align 4
  store i64 0, ptr %index_ptr, align 4
  %index = load i64, ptr %index_ptr, align 4
  br label %cond

cond:                                             ; preds = %next, %func_3_dispatch
  %vector_length17 = load i64, ptr %35, align 4
  %38 = icmp ult i64 %index, %vector_length17
  br i1 %38, label %body, label %end_for

next:                                             ; preds = %body
  %index19 = load i64, ptr %index_ptr, align 4
  %39 = add i64 %index19, 1
  store i64 %39, ptr %index_ptr, align 4
  br label %cond

body:                                             ; preds = %cond
  %vector_length18 = load i64, ptr %35, align 4
  %40 = sub i64 %vector_length18, 1
  %41 = sub i64 %40, %index
  call void @builtin_range_check(i64 %41)
  %vector_data = getelementptr i64, ptr %35, i64 1
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index
  %42 = load i64, ptr %array_size, align 4
  %43 = add i64 %42, 4
  store i64 %43, ptr %array_size, align 4
  br label %next

>>>>>>> 7998cf0 (fixed llvm type bug.)
end_for:                                          ; preds = %cond
  %44 = load i64, ptr %array_size, align 4
  %heap_size = add i64 %44, 1
  %45 = call ptr @heap_malloc(i64 %heap_size)
  store i64 0, ptr %buffer_offset, align 4
  %46 = load i64, ptr %buffer_offset, align 4
  %47 = add i64 %46, 1
  store i64 %47, ptr %buffer_offset, align 4
  %48 = getelementptr ptr, ptr %45, i64 %46
<<<<<<< HEAD
  %vector_length17 = load i64, ptr %34, align 4
  store i64 %vector_length17, ptr %48, align 4
  store i64 0, ptr %index_ptr18, align 4
  br label %cond19

cond19:                                           ; preds = %next21, %end_for
  %vector_length23 = load i64, ptr %34, align 4
  %49 = load i64, ptr %index_ptr18, align 4
  %50 = icmp ult i64 %49, %vector_length23
  br i1 %50, label %body20, label %end_for22

body20:                                           ; preds = %cond19
  %array_index24 = load i64, ptr %index_ptr18, align 4
  %vector_length25 = load i64, ptr %34, align 4
  %51 = sub i64 %vector_length25, 1
  %52 = sub i64 %51, %array_index24
  call void @builtin_range_check(i64 %52)
  %vector_data26 = getelementptr i64, ptr %34, i64 1
  %index_access27 = getelementptr ptr, ptr %vector_data26, i64 %array_index24
  %array_element28 = load ptr, ptr %index_access27, align 8
  %53 = load i64, ptr %buffer_offset, align 4
  %54 = getelementptr ptr, ptr %45, i64 %53
  %55 = getelementptr i64, ptr %array_element28, i64 0
  %56 = load i64, ptr %55, align 4
  %57 = getelementptr i64, ptr %54, i64 0
  store i64 %56, ptr %57, align 4
  %58 = getelementptr i64, ptr %array_element28, i64 1
  %59 = load i64, ptr %58, align 4
  %60 = getelementptr i64, ptr %54, i64 1
  store i64 %59, ptr %60, align 4
  %61 = getelementptr i64, ptr %array_element28, i64 2
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr i64, ptr %54, i64 2
  store i64 %62, ptr %63, align 4
  %64 = getelementptr i64, ptr %array_element28, i64 3
=======
  %vector_length20 = load i64, ptr %35, align 4
  store i64 %vector_length20, ptr %48, align 4
  store i64 0, ptr %index_ptr21, align 4
  %index22 = load i64, ptr %index_ptr21, align 4
  br label %cond23

cond23:                                           ; preds = %next24, %end_for
  %vector_length27 = load i64, ptr %35, align 4
  %49 = icmp ult i64 %index22, %vector_length27
  br i1 %49, label %body25, label %end_for26

next24:                                           ; preds = %body25
  %index31 = load i64, ptr %index_ptr21, align 4
  %50 = add i64 %index31, 1
  store i64 %50, ptr %index_ptr21, align 4
  br label %cond23

body25:                                           ; preds = %cond23
  %vector_length28 = load i64, ptr %35, align 4
  %51 = sub i64 %vector_length28, 1
  %52 = sub i64 %51, %index22
  call void @builtin_range_check(i64 %52)
  %vector_data29 = getelementptr i64, ptr %35, i64 1
  %index_access30 = getelementptr ptr, ptr %vector_data29, i64 %index22
  %53 = load i64, ptr %buffer_offset, align 4
  %54 = getelementptr ptr, ptr %45, i64 %53
  %55 = getelementptr i64, ptr %index_access30, i64 0
  %56 = load i64, ptr %55, align 4
  %57 = getelementptr i64, ptr %54, i64 0
  store i64 %56, ptr %57, align 4
  %58 = getelementptr i64, ptr %index_access30, i64 1
  %59 = load i64, ptr %58, align 4
  %60 = getelementptr i64, ptr %54, i64 1
  store i64 %59, ptr %60, align 4
  %61 = getelementptr i64, ptr %index_access30, i64 2
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr i64, ptr %54, i64 2
  store i64 %62, ptr %63, align 4
  %64 = getelementptr i64, ptr %index_access30, i64 3
>>>>>>> 7998cf0 (fixed llvm type bug.)
  %65 = load i64, ptr %64, align 4
  %66 = getelementptr i64, ptr %54, i64 3
  store i64 %65, ptr %66, align 4
  %67 = load i64, ptr %buffer_offset, align 4
  %68 = add i64 %67, 4
  store i64 %68, ptr %buffer_offset, align 4
<<<<<<< HEAD
  br label %next21

next21:                                           ; preds = %body20
  %index29 = load i64, ptr %index_ptr18, align 4
  %69 = add i64 %index29, 1
  store i64 %69, ptr %index_ptr18, align 4
  br label %cond19

end_for22:                                        ; preds = %cond19
  %70 = load i64, ptr %buffer_offset, align 4
  %71 = getelementptr ptr, ptr %45, i64 %70
  store i64 %44, ptr %71, align 4
=======
  br label %next24

end_for26:                                        ; preds = %cond23
  %69 = load i64, ptr %buffer_offset, align 4
  %70 = getelementptr ptr, ptr %45, i64 %69
  store i64 %44, ptr %70, align 4
>>>>>>> 7998cf0 (fixed llvm type bug.)
  call void @set_tape_data(ptr %45, i64 %heap_size)
  ret void

func_4_dispatch:                                  ; preds = %entry
<<<<<<< HEAD
  %72 = getelementptr ptr, ptr %2, i64 0
  %73 = call ptr @getProposalsByVoter(ptr %72)
  store i64 0, ptr %array_size30, align 4
  %74 = load i64, ptr %array_size30, align 4
  %75 = add i64 %74, 1
  store i64 %75, ptr %array_size30, align 4
  store i64 0, ptr %index_ptr31, align 4
  br label %cond32

cond32:                                           ; preds = %next34, %func_4_dispatch
  %vector_length36 = load i64, ptr %73, align 4
  %76 = load i64, ptr %index_ptr31, align 4
  %77 = icmp ult i64 %76, %vector_length36
  br i1 %77, label %body33, label %end_for35

body33:                                           ; preds = %cond32
  %array_index37 = load i64, ptr %index_ptr31, align 4
  %vector_length38 = load i64, ptr %73, align 4
  %78 = sub i64 %vector_length38, 1
  %79 = sub i64 %78, %array_index37
  call void @builtin_range_check(i64 %79)
  %vector_data39 = getelementptr i64, ptr %73, i64 1
  %index_access40 = getelementptr ptr, ptr %vector_data39, i64 %array_index37
  %array_element41 = load ptr, ptr %index_access40, align 8
  %80 = load i64, ptr %array_size30, align 4
  %81 = add i64 %80, 4
  store i64 %81, ptr %array_size30, align 4
  br label %next34

next34:                                           ; preds = %body33
  %index42 = load i64, ptr %index_ptr31, align 4
  %82 = add i64 %index42, 1
  store i64 %82, ptr %index_ptr31, align 4
  br label %cond32

end_for35:                                        ; preds = %cond32
  %83 = load i64, ptr %array_size30, align 4
  %heap_size43 = add i64 %83, 1
  %84 = call ptr @heap_malloc(i64 %heap_size43)
  store i64 0, ptr %buffer_offset44, align 4
  %85 = load i64, ptr %buffer_offset44, align 4
  %86 = add i64 %85, 1
  store i64 %86, ptr %buffer_offset44, align 4
  %87 = getelementptr ptr, ptr %84, i64 %85
  %vector_length45 = load i64, ptr %73, align 4
  store i64 %vector_length45, ptr %87, align 4
  store i64 0, ptr %index_ptr46, align 4
  br label %cond47

cond47:                                           ; preds = %next49, %end_for35
  %vector_length51 = load i64, ptr %73, align 4
  %88 = load i64, ptr %index_ptr46, align 4
  %89 = icmp ult i64 %88, %vector_length51
  br i1 %89, label %body48, label %end_for50

body48:                                           ; preds = %cond47
  %array_index52 = load i64, ptr %index_ptr46, align 4
  %vector_length53 = load i64, ptr %73, align 4
  %90 = sub i64 %vector_length53, 1
  %91 = sub i64 %90, %array_index52
  call void @builtin_range_check(i64 %91)
  %vector_data54 = getelementptr i64, ptr %73, i64 1
  %index_access55 = getelementptr ptr, ptr %vector_data54, i64 %array_index52
  %array_element56 = load ptr, ptr %index_access55, align 8
  %92 = load i64, ptr %buffer_offset44, align 4
  %93 = getelementptr ptr, ptr %84, i64 %92
  %94 = getelementptr i64, ptr %array_element56, i64 0
  %95 = load i64, ptr %94, align 4
  %96 = getelementptr i64, ptr %93, i64 0
  store i64 %95, ptr %96, align 4
  %97 = getelementptr i64, ptr %array_element56, i64 1
  %98 = load i64, ptr %97, align 4
  %99 = getelementptr i64, ptr %93, i64 1
  store i64 %98, ptr %99, align 4
  %100 = getelementptr i64, ptr %array_element56, i64 2
  %101 = load i64, ptr %100, align 4
  %102 = getelementptr i64, ptr %93, i64 2
  store i64 %101, ptr %102, align 4
  %103 = getelementptr i64, ptr %array_element56, i64 3
  %104 = load i64, ptr %103, align 4
  %105 = getelementptr i64, ptr %93, i64 3
  store i64 %104, ptr %105, align 4
  %106 = load i64, ptr %buffer_offset44, align 4
  %107 = add i64 %106, 4
  store i64 %107, ptr %buffer_offset44, align 4
  br label %next49

next49:                                           ; preds = %body48
  %index57 = load i64, ptr %index_ptr46, align 4
  %108 = add i64 %index57, 1
  store i64 %108, ptr %index_ptr46, align 4
  br label %cond47

end_for50:                                        ; preds = %cond47
  %109 = load i64, ptr %buffer_offset44, align 4
  %110 = getelementptr ptr, ptr %84, i64 %109
  store i64 %83, ptr %110, align 4
  call void @set_tape_data(ptr %84, i64 %heap_size43)
=======
  %71 = getelementptr ptr, ptr %2, i64 0
  %72 = call ptr @getProposalsByVoter(ptr %71)
  store i64 0, ptr %array_size32, align 4
  %vector_length33 = load i64, ptr %72, align 4
  %73 = load i64, ptr %array_size32, align 4
  %74 = add i64 %73, %vector_length33
  store i64 %74, ptr %array_size32, align 4
  store i64 0, ptr %index_ptr34, align 4
  %index35 = load i64, ptr %index_ptr34, align 4
  br label %cond36

cond36:                                           ; preds = %next37, %func_4_dispatch
  %vector_length40 = load i64, ptr %72, align 4
  %75 = icmp ult i64 %index35, %vector_length40
  br i1 %75, label %body38, label %end_for39

next37:                                           ; preds = %body38
  %index44 = load i64, ptr %index_ptr34, align 4
  %76 = add i64 %index44, 1
  store i64 %76, ptr %index_ptr34, align 4
  br label %cond36

body38:                                           ; preds = %cond36
  %vector_length41 = load i64, ptr %72, align 4
  %77 = sub i64 %vector_length41, 1
  %78 = sub i64 %77, %index35
  call void @builtin_range_check(i64 %78)
  %vector_data42 = getelementptr i64, ptr %72, i64 1
  %index_access43 = getelementptr ptr, ptr %vector_data42, i64 %index35
  %79 = load i64, ptr %array_size32, align 4
  %80 = add i64 %79, 4
  store i64 %80, ptr %array_size32, align 4
  br label %next37

end_for39:                                        ; preds = %cond36
  %81 = load i64, ptr %array_size32, align 4
  %heap_size45 = add i64 %81, 1
  %82 = call ptr @heap_malloc(i64 %heap_size45)
  store i64 0, ptr %buffer_offset46, align 4
  %83 = load i64, ptr %buffer_offset46, align 4
  %84 = add i64 %83, 1
  store i64 %84, ptr %buffer_offset46, align 4
  %85 = getelementptr ptr, ptr %82, i64 %83
  %vector_length47 = load i64, ptr %72, align 4
  store i64 %vector_length47, ptr %85, align 4
  store i64 0, ptr %index_ptr48, align 4
  %index49 = load i64, ptr %index_ptr48, align 4
  br label %cond50

cond50:                                           ; preds = %next51, %end_for39
  %vector_length54 = load i64, ptr %72, align 4
  %86 = icmp ult i64 %index49, %vector_length54
  br i1 %86, label %body52, label %end_for53

next51:                                           ; preds = %body52
  %index58 = load i64, ptr %index_ptr48, align 4
  %87 = add i64 %index58, 1
  store i64 %87, ptr %index_ptr48, align 4
  br label %cond50

body52:                                           ; preds = %cond50
  %vector_length55 = load i64, ptr %72, align 4
  %88 = sub i64 %vector_length55, 1
  %89 = sub i64 %88, %index49
  call void @builtin_range_check(i64 %89)
  %vector_data56 = getelementptr i64, ptr %72, i64 1
  %index_access57 = getelementptr ptr, ptr %vector_data56, i64 %index49
  %90 = load i64, ptr %buffer_offset46, align 4
  %91 = getelementptr ptr, ptr %82, i64 %90
  %92 = getelementptr i64, ptr %index_access57, i64 0
  %93 = load i64, ptr %92, align 4
  %94 = getelementptr i64, ptr %91, i64 0
  store i64 %93, ptr %94, align 4
  %95 = getelementptr i64, ptr %index_access57, i64 1
  %96 = load i64, ptr %95, align 4
  %97 = getelementptr i64, ptr %91, i64 1
  store i64 %96, ptr %97, align 4
  %98 = getelementptr i64, ptr %index_access57, i64 2
  %99 = load i64, ptr %98, align 4
  %100 = getelementptr i64, ptr %91, i64 2
  store i64 %99, ptr %100, align 4
  %101 = getelementptr i64, ptr %index_access57, i64 3
  %102 = load i64, ptr %101, align 4
  %103 = getelementptr i64, ptr %91, i64 3
  store i64 %102, ptr %103, align 4
  %104 = load i64, ptr %buffer_offset46, align 4
  %105 = add i64 %104, 4
  store i64 %105, ptr %buffer_offset46, align 4
  br label %next51

end_for53:                                        ; preds = %cond50
  %106 = load i64, ptr %buffer_offset46, align 4
  %107 = getelementptr ptr, ptr %82, i64 %106
  store i64 %81, ptr %107, align 4
  call void @set_tape_data(ptr %82, i64 %heap_size45)
>>>>>>> 7998cf0 (fixed llvm type bug.)
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
