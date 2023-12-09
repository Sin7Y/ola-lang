; ModuleID = 'Entrypoint'
source_filename = "Entrypoint"

@heap_address = internal global i64 -12884901885

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

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
  %size_alloca = alloca i64, align 8
  store i64 %0, ptr %size_alloca, align 4
  %size = load i64, ptr %size_alloca, align 4
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %size
  store i64 %updated_address, ptr @heap_address, align 4
  %1 = inttoptr i64 %current_address to ptr
  ret ptr %1
}

define ptr @vector_new(i64 %0) {
entry:
  %size_alloca = alloca i64, align 8
  store i64 %0, ptr %size_alloca, align 4
  %size = load i64, ptr %size_alloca, align 4
  %1 = add i64 %size, 1
  %current_address = load i64, ptr @heap_address, align 4
  %updated_address = add i64 %current_address, %1
  store i64 %updated_address, ptr @heap_address, align 4
  %2 = inttoptr i64 %current_address to ptr
  store i64 %size, ptr %2, align 4
  ret ptr %2
}

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

define ptr @fields_concat(ptr %0, ptr %1) {
entry:
  %vector_length = load i64, ptr %0, align 4
  %vector_data = getelementptr i64, ptr %1, i64 1
  %vector_length1 = load i64, ptr %0, align 4
  %vector_data2 = getelementptr i64, ptr %1, i64 1
  %new_len = add i64 %vector_length, %vector_length1
  %2 = call ptr @vector_new(i64 %new_len)
  %vector_data3 = getelementptr i64, ptr %2, i64 1
  call void @memcpy(ptr %vector_data, ptr %vector_data3, i64 %vector_length)
  %new_fields_data = getelementptr ptr, ptr %vector_data3, i64 %vector_length
  call void @memcpy(ptr %vector_data2, ptr %new_fields_data, i64 %vector_length1)
  ret ptr %2
}

define void @system_entrance(ptr %0, i64 %1) {
entry:
  %_isETHCall = alloca i64, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %2 = load ptr, ptr %_tx, align 8
  store i64 %1, ptr %_isETHCall, align 4
  call void @validateTxStructure(ptr %2)
  %3 = load i64, ptr %_isETHCall, align 4
  %4 = trunc i64 %3 to i1
  br i1 %4, label %then, label %else

then:                                             ; preds = %entry
  %5 = call ptr @callTx(ptr %2)
  br label %endif

else:                                             ; preds = %entry
  call void @sendTx(ptr %2)
  br label %endif

endif:                                            ; preds = %else, %then
  ret void
}

define void @validateTxStructure(ptr %0) {
entry:
  %MAX_SYSTEM_CONTRACT_ADDRESS = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %2 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %2, i64 3
  store i64 65535, ptr %index_access3, align 4
  store ptr %2, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %3 = load ptr, ptr %struct_member, align 8
  %4 = load ptr, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %5 = call i64 @memcmp_ugt(ptr %3, ptr %4, i64 4)
  call void @builtin_assert(i64 %5)
  %struct_member4 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %6 = load i64, ptr %struct_member4, align 4
  %7 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %7, i64 7)
  %8 = load i64, ptr %7, align 4
  %9 = icmp eq i64 %6, %8
  %10 = zext i1 %9 to i64
  call void @builtin_assert(i64 %10)
  %struct_member5 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %11 = load ptr, ptr %struct_member5, align 8
  %vector_length = load i64, ptr %11, align 4
  %12 = icmp ne i64 %vector_length, 0
  %13 = zext i1 %12 to i64
  call void @builtin_assert(i64 %13)
  %struct_member6 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 6
  %14 = load ptr, ptr %struct_member6, align 8
  %vector_length7 = load i64, ptr %14, align 4
  %15 = icmp ne i64 %vector_length7, 0
  %16 = zext i1 %15 to i64
  call void @builtin_assert(i64 %16)
  ret void
}

define ptr @callTx(ptr %0) {
entry:
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  call void @builtin_assert(i64 0)
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %2 = load ptr, ptr %struct_member, align 8
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %3 = load ptr, ptr %struct_member1, align 8
  %vector_length = load i64, ptr %2, align 4
  %vector_data = getelementptr i64, ptr %2, i64 1
  %tape_size = add i64 %vector_length, 2
  call void @set_tape_data(ptr %vector_data, i64 %tape_size)
  call void @contract_call(ptr %3, i64 0)
  %4 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %4, i64 1)
  %return_length = load i64, ptr %4, align 4
  %heap_size = add i64 %return_length, 2
  %5 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %5, align 4
  %return_data_start = getelementptr i64, ptr %5, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  ret ptr %5
}

define void @sendTx(ptr %0) {
entry:
  %NONCE_HOLDER_ADDRESS = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  call void @validateTx(ptr %1)
  call void @validateDeployment(ptr %1)
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %2 = load ptr, ptr %struct_member, align 8
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %3 = load ptr, ptr %struct_member1, align 8
  %vector_length = load i64, ptr %2, align 4
  %vector_data = getelementptr i64, ptr %2, i64 1
  %tape_size = add i64 %vector_length, 2
  call void @set_tape_data(ptr %vector_data, i64 %tape_size)
  call void @contract_call(ptr %3, i64 0)
  %4 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %4, i64 1)
  %return_length = load i64, ptr %4, align 4
  %heap_size = add i64 %return_length, 2
  %5 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %5, align 4
  %return_data_start = getelementptr i64, ptr %5, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %6 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %6, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access2 = getelementptr i64, ptr %6, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %6, i64 2
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %6, i64 3
  store i64 32771, ptr %index_access4, align 4
  store ptr %6, ptr %NONCE_HOLDER_ADDRESS, align 8
  %struct_member5 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %7 = load ptr, ptr %struct_member5, align 8
  %struct_member6 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %8 = load i64, ptr %struct_member6, align 4
  %9 = call ptr @vector_new(i64 7)
  %10 = getelementptr i64, ptr %7, i64 0
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr = getelementptr i64, ptr %9, i64 1
  store i64 %11, ptr %encode_value_ptr, align 4
  %12 = getelementptr i64, ptr %7, i64 1
  %13 = load i64, ptr %12, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %9, i64 2
  store i64 %13, ptr %encode_value_ptr7, align 4
  %14 = getelementptr i64, ptr %7, i64 2
  %15 = load i64, ptr %14, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %9, i64 3
  store i64 %15, ptr %encode_value_ptr8, align 4
  %16 = getelementptr i64, ptr %7, i64 3
  %17 = load i64, ptr %16, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %9, i64 4
  store i64 %17, ptr %encode_value_ptr9, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %9, i64 5
  store i64 %8, ptr %encode_value_ptr10, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %9, i64 6
  store i64 5, ptr %encode_value_ptr11, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %9, i64 7
  store i64 1093482716, ptr %encode_value_ptr12, align 4
  %18 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %vector_length13 = load i64, ptr %9, align 4
  %vector_data14 = getelementptr i64, ptr %9, i64 1
  %tape_size15 = add i64 %vector_length13, 2
  call void @set_tape_data(ptr %vector_data14, i64 %tape_size15)
  call void @contract_call(ptr %18, i64 0)
  %19 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %19, i64 1)
  %return_length16 = load i64, ptr %19, align 4
  %heap_size17 = add i64 %return_length16, 2
  %20 = call ptr @heap_malloc(i64 %heap_size17)
  store i64 %return_length16, ptr %20, align 4
  %return_data_start18 = getelementptr i64, ptr %20, i64 1
  call void @get_tape_data(ptr %return_data_start18, i64 %tape_size15)
  ret void
}

define void @validateTx(ptr %0) {
entry:
  %txHash = alloca ptr, align 8
  %signedHash = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %2 = call ptr @getSignedHash(ptr %1)
  store ptr %2, ptr %signedHash, align 8
  %3 = load ptr, ptr %signedHash, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 6
  %4 = load ptr, ptr %struct_member, align 8
  %5 = call ptr @getTransactionHash(ptr %3, ptr %4)
  store ptr %5, ptr %txHash, align 8
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %6 = load ptr, ptr %struct_member1, align 8
  call void @validate_sender(ptr %6)
  %struct_member2 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %7 = load ptr, ptr %struct_member2, align 8
  %struct_member3 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %8 = load i64, ptr %struct_member3, align 4
  call void @validate_nonce(ptr %7, i64 %8)
  %9 = load ptr, ptr %txHash, align 8
  %10 = load ptr, ptr %signedHash, align 8
  call void @validate_tx(ptr %9, ptr %10, ptr %1)
  ret void
}

define void @validateDeployment(ptr %0) {
entry:
  %to = alloca ptr, align 8
  %DEPLOYER_SYSTEM_CONTRACT = alloca ptr, align 8
  %is_codehash_known = alloca i64, align 8
  %KNOWN_CODES_STORAGE = alloca ptr, align 8
  %bytecodeHash = alloca ptr, align 8
  %code_len = alloca i64, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 5
  %2 = load ptr, ptr %struct_member, align 8
  %vector_length = load i64, ptr %2, align 4
  store i64 %vector_length, ptr %code_len, align 4
  %3 = load i64, ptr %code_len, align 4
  %4 = icmp ne i64 %3, 0
  br i1 %4, label %then, label %endif

then:                                             ; preds = %entry
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 5
  %5 = load ptr, ptr %struct_member1, align 8
  %6 = call ptr @hashL2Bytecode(ptr %5)
  store ptr %6, ptr %bytecodeHash, align 8
  %7 = load ptr, ptr %bytecodeHash, align 8
  %struct_member2 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 7
  %8 = load ptr, ptr %struct_member2, align 8
  %9 = call i64 @memcmp_eq(ptr %7, ptr %8, i64 4)
  call void @builtin_assert(i64 %9)
  %10 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %10, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access3 = getelementptr i64, ptr %10, i64 1
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %10, i64 2
  store i64 0, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %10, i64 3
  store i64 32772, ptr %index_access5, align 4
  store ptr %10, ptr %KNOWN_CODES_STORAGE, align 8
  %11 = load ptr, ptr %bytecodeHash, align 8
  %12 = call ptr @vector_new(i64 6)
  %13 = getelementptr i64, ptr %11, i64 0
  %14 = load i64, ptr %13, align 4
  %encode_value_ptr = getelementptr i64, ptr %12, i64 1
  store i64 %14, ptr %encode_value_ptr, align 4
  %15 = getelementptr i64, ptr %11, i64 1
  %16 = load i64, ptr %15, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %12, i64 2
  store i64 %16, ptr %encode_value_ptr6, align 4
  %17 = getelementptr i64, ptr %11, i64 2
  %18 = load i64, ptr %17, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %12, i64 3
  store i64 %18, ptr %encode_value_ptr7, align 4
  %19 = getelementptr i64, ptr %11, i64 3
  %20 = load i64, ptr %19, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %12, i64 4
  store i64 %20, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %12, i64 5
  store i64 4, ptr %encode_value_ptr9, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %12, i64 6
  store i64 4199620571, ptr %encode_value_ptr10, align 4
  %21 = load ptr, ptr %KNOWN_CODES_STORAGE, align 8
  %vector_length11 = load i64, ptr %12, align 4
  %vector_data = getelementptr i64, ptr %12, i64 1
  %tape_size = add i64 %vector_length11, 2
  call void @set_tape_data(ptr %vector_data, i64 %tape_size)
  call void @contract_call(ptr %21, i64 0)
  %22 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %22, i64 1)
  %return_length = load i64, ptr %22, align 4
  %heap_size = add i64 %return_length, 2
  %23 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %23, align 4
  %return_data_start = getelementptr i64, ptr %23, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_length12 = load i64, ptr %23, align 4
  %vector_data13 = getelementptr i64, ptr %23, i64 1
  %24 = load i64, ptr %vector_data13, align 4
  %25 = getelementptr ptr, ptr %vector_data13, i64 1
  store i64 %24, ptr %is_codehash_known, align 4
  %26 = load i64, ptr %is_codehash_known, align 4
  %27 = icmp eq i64 %26, 0
  br i1 %27, label %then14, label %endif15

endif:                                            ; preds = %endif15, %entry
  ret void

then14:                                           ; preds = %then
  %28 = load ptr, ptr %bytecodeHash, align 8
  %29 = call ptr @vector_new(i64 6)
  %30 = getelementptr i64, ptr %28, i64 0
  %31 = load i64, ptr %30, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %29, i64 1
  store i64 %31, ptr %encode_value_ptr16, align 4
  %32 = getelementptr i64, ptr %28, i64 1
  %33 = load i64, ptr %32, align 4
  %encode_value_ptr17 = getelementptr i64, ptr %29, i64 2
  store i64 %33, ptr %encode_value_ptr17, align 4
  %34 = getelementptr i64, ptr %28, i64 2
  %35 = load i64, ptr %34, align 4
  %encode_value_ptr18 = getelementptr i64, ptr %29, i64 3
  store i64 %35, ptr %encode_value_ptr18, align 4
  %36 = getelementptr i64, ptr %28, i64 3
  %37 = load i64, ptr %36, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %29, i64 4
  store i64 %37, ptr %encode_value_ptr19, align 4
  %encode_value_ptr20 = getelementptr i64, ptr %29, i64 5
  store i64 4, ptr %encode_value_ptr20, align 4
  %encode_value_ptr21 = getelementptr i64, ptr %29, i64 6
  store i64 1119715209, ptr %encode_value_ptr21, align 4
  %38 = load ptr, ptr %KNOWN_CODES_STORAGE, align 8
  %vector_length22 = load i64, ptr %29, align 4
  %vector_data23 = getelementptr i64, ptr %29, i64 1
  %tape_size24 = add i64 %vector_length22, 2
  call void @set_tape_data(ptr %vector_data23, i64 %tape_size24)
  call void @contract_call(ptr %38, i64 0)
  %39 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %39, i64 1)
  %return_length25 = load i64, ptr %39, align 4
  %heap_size26 = add i64 %return_length25, 2
  %40 = call ptr @heap_malloc(i64 %heap_size26)
  store i64 %return_length25, ptr %40, align 4
  %return_data_start27 = getelementptr i64, ptr %40, i64 1
  call void @get_tape_data(ptr %return_data_start27, i64 %tape_size24)
  br label %endif15

endif15:                                          ; preds = %then14, %then
  %41 = call ptr @heap_malloc(i64 4)
  %index_access28 = getelementptr i64, ptr %41, i64 0
  store i64 0, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %41, i64 1
  store i64 0, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %41, i64 2
  store i64 0, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %41, i64 3
  store i64 32773, ptr %index_access31, align 4
  store ptr %41, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %struct_member32 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %42 = load ptr, ptr %struct_member32, align 8
  %vector_length33 = load i64, ptr %42, align 4
  %array_len_sub_one = sub i64 %vector_length33, 1
  %43 = sub i64 %array_len_sub_one, 0
  call void @builtin_range_check(i64 %43)
  %44 = sub i64 %vector_length33, 4
  call void @builtin_range_check(i64 %44)
  call void @builtin_range_check(i64 4)
  %45 = call ptr @vector_new(i64 4)
  %vector_data34 = getelementptr i64, ptr %45, i64 1
  %vector_data35 = getelementptr i64, ptr %42, i64 1
  call void @memcpy(ptr %vector_data35, ptr %vector_data34, i64 4)
  %vector_length36 = load i64, ptr %45, align 4
  %vector_data37 = getelementptr i64, ptr %45, i64 1
  %46 = getelementptr ptr, ptr %vector_data37, i64 4
  store ptr %vector_data37, ptr %to, align 8
  %47 = load ptr, ptr %to, align 8
  %48 = load ptr, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %49 = call i64 @memcmp_eq(ptr %47, ptr %48, i64 4)
  call void @builtin_assert(i64 %49)
  br label %endif
}

define ptr @getSignedHash(ptr %0) {
entry:
  %signedHash = alloca ptr, align 8
  %domainSeparator = alloca ptr, align 8
  %EIP712_DOMAIN_TYPEHASH = alloca ptr, align 8
  %structHash = alloca ptr, align 8
  %TRANSACTION_TYPE_HASH = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %2 = call ptr @vector_new(i64 11881)
  %vector_data = getelementptr i64, ptr %2, i64 1
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 84, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 114, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 97, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 110, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 115, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %vector_data, i64 5
  store i64 97, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %vector_data, i64 6
  store i64 99, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %vector_data, i64 7
  store i64 116, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %vector_data, i64 8
  store i64 105, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %vector_data, i64 9
  store i64 111, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %vector_data, i64 10
  store i64 110, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %vector_data, i64 11
  store i64 40, ptr %index_access11, align 4
  %index_access12 = getelementptr i64, ptr %vector_data, i64 12
  store i64 97, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %vector_data, i64 13
  store i64 100, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %vector_data, i64 14
  store i64 100, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %vector_data, i64 15
  store i64 114, ptr %index_access15, align 4
  %index_access16 = getelementptr i64, ptr %vector_data, i64 16
  store i64 101, ptr %index_access16, align 4
  %index_access17 = getelementptr i64, ptr %vector_data, i64 17
  store i64 115, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %vector_data, i64 18
  store i64 115, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %vector_data, i64 19
  store i64 32, ptr %index_access19, align 4
  %index_access20 = getelementptr i64, ptr %vector_data, i64 20
  store i64 115, ptr %index_access20, align 4
  %index_access21 = getelementptr i64, ptr %vector_data, i64 21
  store i64 101, ptr %index_access21, align 4
  %index_access22 = getelementptr i64, ptr %vector_data, i64 22
  store i64 110, ptr %index_access22, align 4
  %index_access23 = getelementptr i64, ptr %vector_data, i64 23
  store i64 100, ptr %index_access23, align 4
  %index_access24 = getelementptr i64, ptr %vector_data, i64 24
  store i64 101, ptr %index_access24, align 4
  %index_access25 = getelementptr i64, ptr %vector_data, i64 25
  store i64 114, ptr %index_access25, align 4
  %index_access26 = getelementptr i64, ptr %vector_data, i64 26
  store i64 44, ptr %index_access26, align 4
  %index_access27 = getelementptr i64, ptr %vector_data, i64 27
  store i64 32, ptr %index_access27, align 4
  %index_access28 = getelementptr i64, ptr %vector_data, i64 28
  store i64 117, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %vector_data, i64 29
  store i64 51, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %vector_data, i64 30
  store i64 50, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %vector_data, i64 31
  store i64 32, ptr %index_access31, align 4
  %index_access32 = getelementptr i64, ptr %vector_data, i64 32
  store i64 110, ptr %index_access32, align 4
  %index_access33 = getelementptr i64, ptr %vector_data, i64 33
  store i64 111, ptr %index_access33, align 4
  %index_access34 = getelementptr i64, ptr %vector_data, i64 34
  store i64 110, ptr %index_access34, align 4
  %index_access35 = getelementptr i64, ptr %vector_data, i64 35
  store i64 99, ptr %index_access35, align 4
  %index_access36 = getelementptr i64, ptr %vector_data, i64 36
  store i64 101, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %vector_data, i64 37
  store i64 44, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %vector_data, i64 38
  store i64 32, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %vector_data, i64 39
  store i64 102, ptr %index_access39, align 4
  %index_access40 = getelementptr i64, ptr %vector_data, i64 40
  store i64 105, ptr %index_access40, align 4
  %index_access41 = getelementptr i64, ptr %vector_data, i64 41
  store i64 101, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %vector_data, i64 42
  store i64 108, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %vector_data, i64 43
  store i64 100, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %vector_data, i64 44
  store i64 115, ptr %index_access44, align 4
  %index_access45 = getelementptr i64, ptr %vector_data, i64 45
  store i64 32, ptr %index_access45, align 4
  %index_access46 = getelementptr i64, ptr %vector_data, i64 46
  store i64 100, ptr %index_access46, align 4
  %index_access47 = getelementptr i64, ptr %vector_data, i64 47
  store i64 97, ptr %index_access47, align 4
  %index_access48 = getelementptr i64, ptr %vector_data, i64 48
  store i64 116, ptr %index_access48, align 4
  %index_access49 = getelementptr i64, ptr %vector_data, i64 49
  store i64 97, ptr %index_access49, align 4
  %index_access50 = getelementptr i64, ptr %vector_data, i64 50
  store i64 44, ptr %index_access50, align 4
  %index_access51 = getelementptr i64, ptr %vector_data, i64 51
  store i64 32, ptr %index_access51, align 4
  %index_access52 = getelementptr i64, ptr %vector_data, i64 52
  store i64 117, ptr %index_access52, align 4
  %index_access53 = getelementptr i64, ptr %vector_data, i64 53
  store i64 51, ptr %index_access53, align 4
  %index_access54 = getelementptr i64, ptr %vector_data, i64 54
  store i64 50, ptr %index_access54, align 4
  %index_access55 = getelementptr i64, ptr %vector_data, i64 55
  store i64 32, ptr %index_access55, align 4
  %index_access56 = getelementptr i64, ptr %vector_data, i64 56
  store i64 99, ptr %index_access56, align 4
  %index_access57 = getelementptr i64, ptr %vector_data, i64 57
  store i64 104, ptr %index_access57, align 4
  %index_access58 = getelementptr i64, ptr %vector_data, i64 58
  store i64 97, ptr %index_access58, align 4
  %index_access59 = getelementptr i64, ptr %vector_data, i64 59
  store i64 105, ptr %index_access59, align 4
  %index_access60 = getelementptr i64, ptr %vector_data, i64 60
  store i64 110, ptr %index_access60, align 4
  %index_access61 = getelementptr i64, ptr %vector_data, i64 61
  store i64 105, ptr %index_access61, align 4
  %index_access62 = getelementptr i64, ptr %vector_data, i64 62
  store i64 100, ptr %index_access62, align 4
  %index_access63 = getelementptr i64, ptr %vector_data, i64 63
  store i64 44, ptr %index_access63, align 4
  %index_access64 = getelementptr i64, ptr %vector_data, i64 64
  store i64 32, ptr %index_access64, align 4
  %index_access65 = getelementptr i64, ptr %vector_data, i64 65
  store i64 117, ptr %index_access65, align 4
  %index_access66 = getelementptr i64, ptr %vector_data, i64 66
  store i64 51, ptr %index_access66, align 4
  %index_access67 = getelementptr i64, ptr %vector_data, i64 67
  store i64 50, ptr %index_access67, align 4
  %index_access68 = getelementptr i64, ptr %vector_data, i64 68
  store i64 32, ptr %index_access68, align 4
  %index_access69 = getelementptr i64, ptr %vector_data, i64 69
  store i64 118, ptr %index_access69, align 4
  %index_access70 = getelementptr i64, ptr %vector_data, i64 70
  store i64 101, ptr %index_access70, align 4
  %index_access71 = getelementptr i64, ptr %vector_data, i64 71
  store i64 114, ptr %index_access71, align 4
  %index_access72 = getelementptr i64, ptr %vector_data, i64 72
  store i64 115, ptr %index_access72, align 4
  %index_access73 = getelementptr i64, ptr %vector_data, i64 73
  store i64 105, ptr %index_access73, align 4
  %index_access74 = getelementptr i64, ptr %vector_data, i64 74
  store i64 111, ptr %index_access74, align 4
  %index_access75 = getelementptr i64, ptr %vector_data, i64 75
  store i64 110, ptr %index_access75, align 4
  %index_access76 = getelementptr i64, ptr %vector_data, i64 76
  store i64 44, ptr %index_access76, align 4
  %index_access77 = getelementptr i64, ptr %vector_data, i64 77
  store i64 32, ptr %index_access77, align 4
  %index_access78 = getelementptr i64, ptr %vector_data, i64 78
  store i64 102, ptr %index_access78, align 4
  %index_access79 = getelementptr i64, ptr %vector_data, i64 79
  store i64 105, ptr %index_access79, align 4
  %index_access80 = getelementptr i64, ptr %vector_data, i64 80
  store i64 101, ptr %index_access80, align 4
  %index_access81 = getelementptr i64, ptr %vector_data, i64 81
  store i64 108, ptr %index_access81, align 4
  %index_access82 = getelementptr i64, ptr %vector_data, i64 82
  store i64 100, ptr %index_access82, align 4
  %index_access83 = getelementptr i64, ptr %vector_data, i64 83
  store i64 115, ptr %index_access83, align 4
  %index_access84 = getelementptr i64, ptr %vector_data, i64 84
  store i64 32, ptr %index_access84, align 4
  %index_access85 = getelementptr i64, ptr %vector_data, i64 85
  store i64 99, ptr %index_access85, align 4
  %index_access86 = getelementptr i64, ptr %vector_data, i64 86
  store i64 111, ptr %index_access86, align 4
  %index_access87 = getelementptr i64, ptr %vector_data, i64 87
  store i64 100, ptr %index_access87, align 4
  %index_access88 = getelementptr i64, ptr %vector_data, i64 88
  store i64 101, ptr %index_access88, align 4
  %index_access89 = getelementptr i64, ptr %vector_data, i64 89
  store i64 115, ptr %index_access89, align 4
  %index_access90 = getelementptr i64, ptr %vector_data, i64 90
  store i64 44, ptr %index_access90, align 4
  %index_access91 = getelementptr i64, ptr %vector_data, i64 91
  store i64 32, ptr %index_access91, align 4
  %index_access92 = getelementptr i64, ptr %vector_data, i64 92
  store i64 102, ptr %index_access92, align 4
  %index_access93 = getelementptr i64, ptr %vector_data, i64 93
  store i64 105, ptr %index_access93, align 4
  %index_access94 = getelementptr i64, ptr %vector_data, i64 94
  store i64 101, ptr %index_access94, align 4
  %index_access95 = getelementptr i64, ptr %vector_data, i64 95
  store i64 108, ptr %index_access95, align 4
  %index_access96 = getelementptr i64, ptr %vector_data, i64 96
  store i64 100, ptr %index_access96, align 4
  %index_access97 = getelementptr i64, ptr %vector_data, i64 97
  store i64 115, ptr %index_access97, align 4
  %index_access98 = getelementptr i64, ptr %vector_data, i64 98
  store i64 32, ptr %index_access98, align 4
  %index_access99 = getelementptr i64, ptr %vector_data, i64 99
  store i64 115, ptr %index_access99, align 4
  %index_access100 = getelementptr i64, ptr %vector_data, i64 100
  store i64 105, ptr %index_access100, align 4
  %index_access101 = getelementptr i64, ptr %vector_data, i64 101
  store i64 103, ptr %index_access101, align 4
  %index_access102 = getelementptr i64, ptr %vector_data, i64 102
  store i64 110, ptr %index_access102, align 4
  %index_access103 = getelementptr i64, ptr %vector_data, i64 103
  store i64 97, ptr %index_access103, align 4
  %index_access104 = getelementptr i64, ptr %vector_data, i64 104
  store i64 116, ptr %index_access104, align 4
  %index_access105 = getelementptr i64, ptr %vector_data, i64 105
  store i64 117, ptr %index_access105, align 4
  %index_access106 = getelementptr i64, ptr %vector_data, i64 106
  store i64 114, ptr %index_access106, align 4
  %index_access107 = getelementptr i64, ptr %vector_data, i64 107
  store i64 101, ptr %index_access107, align 4
  %index_access108 = getelementptr i64, ptr %vector_data, i64 108
  store i64 41, ptr %index_access108, align 4
  %vector_length = load i64, ptr %2, align 4
  %vector_data109 = getelementptr i64, ptr %2, i64 1
  %3 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data109, ptr %3, i64 %vector_length)
  store ptr %3, ptr %TRANSACTION_TYPE_HASH, align 8
  %4 = load ptr, ptr %TRANSACTION_TYPE_HASH, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %5 = load ptr, ptr %struct_member, align 8
  %struct_member110 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %6 = load i64, ptr %struct_member110, align 4
  %struct_member111 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %7 = load i64, ptr %struct_member111, align 4
  %struct_member112 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %8 = load i64, ptr %struct_member112, align 4
  %struct_member113 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %9 = load ptr, ptr %struct_member113, align 8
  %vector_length114 = load i64, ptr %9, align 4
  %vector_data115 = getelementptr i64, ptr %9, i64 1
  %10 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data115, ptr %10, i64 %vector_length114)
  %struct_member116 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 5
  %11 = load ptr, ptr %struct_member116, align 8
  %vector_length117 = load i64, ptr %11, align 4
  %vector_data118 = getelementptr i64, ptr %11, i64 1
  %12 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data118, ptr %12, i64 %vector_length117)
  %13 = call ptr @vector_new(i64 19)
  %14 = getelementptr i64, ptr %4, i64 0
  %15 = load i64, ptr %14, align 4
  %encode_value_ptr = getelementptr i64, ptr %13, i64 1
  store i64 %15, ptr %encode_value_ptr, align 4
  %16 = getelementptr i64, ptr %4, i64 1
  %17 = load i64, ptr %16, align 4
  %encode_value_ptr119 = getelementptr i64, ptr %13, i64 2
  store i64 %17, ptr %encode_value_ptr119, align 4
  %18 = getelementptr i64, ptr %4, i64 2
  %19 = load i64, ptr %18, align 4
  %encode_value_ptr120 = getelementptr i64, ptr %13, i64 3
  store i64 %19, ptr %encode_value_ptr120, align 4
  %20 = getelementptr i64, ptr %4, i64 3
  %21 = load i64, ptr %20, align 4
  %encode_value_ptr121 = getelementptr i64, ptr %13, i64 4
  store i64 %21, ptr %encode_value_ptr121, align 4
  %22 = getelementptr i64, ptr %5, i64 0
  %23 = load i64, ptr %22, align 4
  %encode_value_ptr122 = getelementptr i64, ptr %13, i64 5
  store i64 %23, ptr %encode_value_ptr122, align 4
  %24 = getelementptr i64, ptr %5, i64 1
  %25 = load i64, ptr %24, align 4
  %encode_value_ptr123 = getelementptr i64, ptr %13, i64 6
  store i64 %25, ptr %encode_value_ptr123, align 4
  %26 = getelementptr i64, ptr %5, i64 2
  %27 = load i64, ptr %26, align 4
  %encode_value_ptr124 = getelementptr i64, ptr %13, i64 7
  store i64 %27, ptr %encode_value_ptr124, align 4
  %28 = getelementptr i64, ptr %5, i64 3
  %29 = load i64, ptr %28, align 4
  %encode_value_ptr125 = getelementptr i64, ptr %13, i64 8
  store i64 %29, ptr %encode_value_ptr125, align 4
  %encode_value_ptr126 = getelementptr i64, ptr %13, i64 9
  store i64 %6, ptr %encode_value_ptr126, align 4
  %encode_value_ptr127 = getelementptr i64, ptr %13, i64 10
  store i64 %7, ptr %encode_value_ptr127, align 4
  %encode_value_ptr128 = getelementptr i64, ptr %13, i64 11
  store i64 %8, ptr %encode_value_ptr128, align 4
  %30 = getelementptr i64, ptr %10, i64 0
  %31 = load i64, ptr %30, align 4
  %encode_value_ptr129 = getelementptr i64, ptr %13, i64 12
  store i64 %31, ptr %encode_value_ptr129, align 4
  %32 = getelementptr i64, ptr %10, i64 1
  %33 = load i64, ptr %32, align 4
  %encode_value_ptr130 = getelementptr i64, ptr %13, i64 13
  store i64 %33, ptr %encode_value_ptr130, align 4
  %34 = getelementptr i64, ptr %10, i64 2
  %35 = load i64, ptr %34, align 4
  %encode_value_ptr131 = getelementptr i64, ptr %13, i64 14
  store i64 %35, ptr %encode_value_ptr131, align 4
  %36 = getelementptr i64, ptr %10, i64 3
  %37 = load i64, ptr %36, align 4
  %encode_value_ptr132 = getelementptr i64, ptr %13, i64 15
  store i64 %37, ptr %encode_value_ptr132, align 4
  %38 = getelementptr i64, ptr %12, i64 0
  %39 = load i64, ptr %38, align 4
  %encode_value_ptr133 = getelementptr i64, ptr %13, i64 16
  store i64 %39, ptr %encode_value_ptr133, align 4
  %40 = getelementptr i64, ptr %12, i64 1
  %41 = load i64, ptr %40, align 4
  %encode_value_ptr134 = getelementptr i64, ptr %13, i64 17
  store i64 %41, ptr %encode_value_ptr134, align 4
  %42 = getelementptr i64, ptr %12, i64 2
  %43 = load i64, ptr %42, align 4
  %encode_value_ptr135 = getelementptr i64, ptr %13, i64 18
  store i64 %43, ptr %encode_value_ptr135, align 4
  %44 = getelementptr i64, ptr %12, i64 3
  %45 = load i64, ptr %44, align 4
  %encode_value_ptr136 = getelementptr i64, ptr %13, i64 19
  store i64 %45, ptr %encode_value_ptr136, align 4
  %vector_length137 = load i64, ptr %13, align 4
  %vector_data138 = getelementptr i64, ptr %13, i64 1
  %46 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data138, ptr %46, i64 %vector_length137)
  store ptr %46, ptr %structHash, align 8
  %47 = call ptr @vector_new(i64 2704)
  %vector_data139 = getelementptr i64, ptr %47, i64 1
  %index_access140 = getelementptr i64, ptr %vector_data139, i64 0
  store i64 69, ptr %index_access140, align 4
  %index_access141 = getelementptr i64, ptr %vector_data139, i64 1
  store i64 73, ptr %index_access141, align 4
  %index_access142 = getelementptr i64, ptr %vector_data139, i64 2
  store i64 80, ptr %index_access142, align 4
  %index_access143 = getelementptr i64, ptr %vector_data139, i64 3
  store i64 55, ptr %index_access143, align 4
  %index_access144 = getelementptr i64, ptr %vector_data139, i64 4
  store i64 49, ptr %index_access144, align 4
  %index_access145 = getelementptr i64, ptr %vector_data139, i64 5
  store i64 50, ptr %index_access145, align 4
  %index_access146 = getelementptr i64, ptr %vector_data139, i64 6
  store i64 68, ptr %index_access146, align 4
  %index_access147 = getelementptr i64, ptr %vector_data139, i64 7
  store i64 111, ptr %index_access147, align 4
  %index_access148 = getelementptr i64, ptr %vector_data139, i64 8
  store i64 109, ptr %index_access148, align 4
  %index_access149 = getelementptr i64, ptr %vector_data139, i64 9
  store i64 97, ptr %index_access149, align 4
  %index_access150 = getelementptr i64, ptr %vector_data139, i64 10
  store i64 105, ptr %index_access150, align 4
  %index_access151 = getelementptr i64, ptr %vector_data139, i64 11
  store i64 110, ptr %index_access151, align 4
  %index_access152 = getelementptr i64, ptr %vector_data139, i64 12
  store i64 40, ptr %index_access152, align 4
  %index_access153 = getelementptr i64, ptr %vector_data139, i64 13
  store i64 115, ptr %index_access153, align 4
  %index_access154 = getelementptr i64, ptr %vector_data139, i64 14
  store i64 116, ptr %index_access154, align 4
  %index_access155 = getelementptr i64, ptr %vector_data139, i64 15
  store i64 114, ptr %index_access155, align 4
  %index_access156 = getelementptr i64, ptr %vector_data139, i64 16
  store i64 105, ptr %index_access156, align 4
  %index_access157 = getelementptr i64, ptr %vector_data139, i64 17
  store i64 110, ptr %index_access157, align 4
  %index_access158 = getelementptr i64, ptr %vector_data139, i64 18
  store i64 103, ptr %index_access158, align 4
  %index_access159 = getelementptr i64, ptr %vector_data139, i64 19
  store i64 32, ptr %index_access159, align 4
  %index_access160 = getelementptr i64, ptr %vector_data139, i64 20
  store i64 110, ptr %index_access160, align 4
  %index_access161 = getelementptr i64, ptr %vector_data139, i64 21
  store i64 97, ptr %index_access161, align 4
  %index_access162 = getelementptr i64, ptr %vector_data139, i64 22
  store i64 109, ptr %index_access162, align 4
  %index_access163 = getelementptr i64, ptr %vector_data139, i64 23
  store i64 101, ptr %index_access163, align 4
  %index_access164 = getelementptr i64, ptr %vector_data139, i64 24
  store i64 44, ptr %index_access164, align 4
  %index_access165 = getelementptr i64, ptr %vector_data139, i64 25
  store i64 115, ptr %index_access165, align 4
  %index_access166 = getelementptr i64, ptr %vector_data139, i64 26
  store i64 116, ptr %index_access166, align 4
  %index_access167 = getelementptr i64, ptr %vector_data139, i64 27
  store i64 114, ptr %index_access167, align 4
  %index_access168 = getelementptr i64, ptr %vector_data139, i64 28
  store i64 105, ptr %index_access168, align 4
  %index_access169 = getelementptr i64, ptr %vector_data139, i64 29
  store i64 110, ptr %index_access169, align 4
  %index_access170 = getelementptr i64, ptr %vector_data139, i64 30
  store i64 103, ptr %index_access170, align 4
  %index_access171 = getelementptr i64, ptr %vector_data139, i64 31
  store i64 32, ptr %index_access171, align 4
  %index_access172 = getelementptr i64, ptr %vector_data139, i64 32
  store i64 118, ptr %index_access172, align 4
  %index_access173 = getelementptr i64, ptr %vector_data139, i64 33
  store i64 101, ptr %index_access173, align 4
  %index_access174 = getelementptr i64, ptr %vector_data139, i64 34
  store i64 114, ptr %index_access174, align 4
  %index_access175 = getelementptr i64, ptr %vector_data139, i64 35
  store i64 115, ptr %index_access175, align 4
  %index_access176 = getelementptr i64, ptr %vector_data139, i64 36
  store i64 105, ptr %index_access176, align 4
  %index_access177 = getelementptr i64, ptr %vector_data139, i64 37
  store i64 111, ptr %index_access177, align 4
  %index_access178 = getelementptr i64, ptr %vector_data139, i64 38
  store i64 110, ptr %index_access178, align 4
  %index_access179 = getelementptr i64, ptr %vector_data139, i64 39
  store i64 44, ptr %index_access179, align 4
  %index_access180 = getelementptr i64, ptr %vector_data139, i64 40
  store i64 117, ptr %index_access180, align 4
  %index_access181 = getelementptr i64, ptr %vector_data139, i64 41
  store i64 51, ptr %index_access181, align 4
  %index_access182 = getelementptr i64, ptr %vector_data139, i64 42
  store i64 50, ptr %index_access182, align 4
  %index_access183 = getelementptr i64, ptr %vector_data139, i64 43
  store i64 32, ptr %index_access183, align 4
  %index_access184 = getelementptr i64, ptr %vector_data139, i64 44
  store i64 99, ptr %index_access184, align 4
  %index_access185 = getelementptr i64, ptr %vector_data139, i64 45
  store i64 104, ptr %index_access185, align 4
  %index_access186 = getelementptr i64, ptr %vector_data139, i64 46
  store i64 97, ptr %index_access186, align 4
  %index_access187 = getelementptr i64, ptr %vector_data139, i64 47
  store i64 105, ptr %index_access187, align 4
  %index_access188 = getelementptr i64, ptr %vector_data139, i64 48
  store i64 110, ptr %index_access188, align 4
  %index_access189 = getelementptr i64, ptr %vector_data139, i64 49
  store i64 73, ptr %index_access189, align 4
  %index_access190 = getelementptr i64, ptr %vector_data139, i64 50
  store i64 100, ptr %index_access190, align 4
  %index_access191 = getelementptr i64, ptr %vector_data139, i64 51
  store i64 41, ptr %index_access191, align 4
  %vector_length192 = load i64, ptr %47, align 4
  %vector_data193 = getelementptr i64, ptr %47, i64 1
  %48 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data193, ptr %48, i64 %vector_length192)
  store ptr %48, ptr %EIP712_DOMAIN_TYPEHASH, align 8
  %49 = load ptr, ptr %EIP712_DOMAIN_TYPEHASH, align 8
  %50 = call ptr @vector_new(i64 9)
  %vector_data194 = getelementptr i64, ptr %50, i64 1
  %index_access195 = getelementptr i64, ptr %vector_data194, i64 0
  store i64 79, ptr %index_access195, align 4
  %index_access196 = getelementptr i64, ptr %vector_data194, i64 1
  store i64 108, ptr %index_access196, align 4
  %index_access197 = getelementptr i64, ptr %vector_data194, i64 2
  store i64 97, ptr %index_access197, align 4
  %vector_length198 = load i64, ptr %50, align 4
  %vector_data199 = getelementptr i64, ptr %50, i64 1
  %51 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data199, ptr %51, i64 %vector_length198)
  %52 = call ptr @vector_new(i64 1)
  %vector_data200 = getelementptr i64, ptr %52, i64 1
  %index_access201 = getelementptr i64, ptr %vector_data200, i64 0
  store i64 49, ptr %index_access201, align 4
  %vector_length202 = load i64, ptr %52, align 4
  %vector_data203 = getelementptr i64, ptr %52, i64 1
  %53 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data203, ptr %53, i64 %vector_length202)
  %54 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %54, i64 7)
  %55 = load i64, ptr %54, align 4
  %56 = call ptr @vector_new(i64 13)
  %57 = getelementptr i64, ptr %49, i64 0
  %58 = load i64, ptr %57, align 4
  %encode_value_ptr204 = getelementptr i64, ptr %56, i64 1
  store i64 %58, ptr %encode_value_ptr204, align 4
  %59 = getelementptr i64, ptr %49, i64 1
  %60 = load i64, ptr %59, align 4
  %encode_value_ptr205 = getelementptr i64, ptr %56, i64 2
  store i64 %60, ptr %encode_value_ptr205, align 4
  %61 = getelementptr i64, ptr %49, i64 2
  %62 = load i64, ptr %61, align 4
  %encode_value_ptr206 = getelementptr i64, ptr %56, i64 3
  store i64 %62, ptr %encode_value_ptr206, align 4
  %63 = getelementptr i64, ptr %49, i64 3
  %64 = load i64, ptr %63, align 4
  %encode_value_ptr207 = getelementptr i64, ptr %56, i64 4
  store i64 %64, ptr %encode_value_ptr207, align 4
  %65 = getelementptr i64, ptr %51, i64 0
  %66 = load i64, ptr %65, align 4
  %encode_value_ptr208 = getelementptr i64, ptr %56, i64 5
  store i64 %66, ptr %encode_value_ptr208, align 4
  %67 = getelementptr i64, ptr %51, i64 1
  %68 = load i64, ptr %67, align 4
  %encode_value_ptr209 = getelementptr i64, ptr %56, i64 6
  store i64 %68, ptr %encode_value_ptr209, align 4
  %69 = getelementptr i64, ptr %51, i64 2
  %70 = load i64, ptr %69, align 4
  %encode_value_ptr210 = getelementptr i64, ptr %56, i64 7
  store i64 %70, ptr %encode_value_ptr210, align 4
  %71 = getelementptr i64, ptr %51, i64 3
  %72 = load i64, ptr %71, align 4
  %encode_value_ptr211 = getelementptr i64, ptr %56, i64 8
  store i64 %72, ptr %encode_value_ptr211, align 4
  %73 = getelementptr i64, ptr %53, i64 0
  %74 = load i64, ptr %73, align 4
  %encode_value_ptr212 = getelementptr i64, ptr %56, i64 9
  store i64 %74, ptr %encode_value_ptr212, align 4
  %75 = getelementptr i64, ptr %53, i64 1
  %76 = load i64, ptr %75, align 4
  %encode_value_ptr213 = getelementptr i64, ptr %56, i64 10
  store i64 %76, ptr %encode_value_ptr213, align 4
  %77 = getelementptr i64, ptr %53, i64 2
  %78 = load i64, ptr %77, align 4
  %encode_value_ptr214 = getelementptr i64, ptr %56, i64 11
  store i64 %78, ptr %encode_value_ptr214, align 4
  %79 = getelementptr i64, ptr %53, i64 3
  %80 = load i64, ptr %79, align 4
  %encode_value_ptr215 = getelementptr i64, ptr %56, i64 12
  store i64 %80, ptr %encode_value_ptr215, align 4
  %encode_value_ptr216 = getelementptr i64, ptr %56, i64 13
  store i64 %55, ptr %encode_value_ptr216, align 4
  %vector_length217 = load i64, ptr %56, align 4
  %vector_data218 = getelementptr i64, ptr %56, i64 1
  %81 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data218, ptr %81, i64 %vector_length217)
  store ptr %81, ptr %domainSeparator, align 8
  %82 = call ptr @vector_new(i64 4)
  %vector_data219 = getelementptr i64, ptr %82, i64 1
  %index_access220 = getelementptr i64, ptr %vector_data219, i64 0
  store i64 25, ptr %index_access220, align 4
  %index_access221 = getelementptr i64, ptr %vector_data219, i64 1
  store i64 1, ptr %index_access221, align 4
  %83 = load ptr, ptr %domainSeparator, align 8
  %84 = load ptr, ptr %structHash, align 8
  %vector_length222 = load i64, ptr %82, align 4
  %85 = add i64 %vector_length222, 1
  %86 = add i64 %85, 4
  %87 = add i64 %86, 4
  %88 = call ptr @vector_new(i64 %87)
  %vector_length223 = load i64, ptr %82, align 4
  %vector_data224 = getelementptr i64, ptr %82, i64 1
  %89 = add i64 %vector_length223, 1
  call void @memcpy(ptr %vector_data224, ptr %88, i64 %89)
  %90 = add i64 %89, 1
  %91 = getelementptr i64, ptr %83, i64 0
  %92 = load i64, ptr %91, align 4
  %encode_value_ptr225 = getelementptr i64, ptr %88, i64 %90
  store i64 %92, ptr %encode_value_ptr225, align 4
  %93 = add i64 %90, 1
  %94 = getelementptr i64, ptr %83, i64 1
  %95 = load i64, ptr %94, align 4
  %encode_value_ptr226 = getelementptr i64, ptr %88, i64 %93
  store i64 %95, ptr %encode_value_ptr226, align 4
  %96 = add i64 %93, 1
  %97 = getelementptr i64, ptr %83, i64 2
  %98 = load i64, ptr %97, align 4
  %encode_value_ptr227 = getelementptr i64, ptr %88, i64 %96
  store i64 %98, ptr %encode_value_ptr227, align 4
  %99 = add i64 %96, 1
  %100 = getelementptr i64, ptr %83, i64 3
  %101 = load i64, ptr %100, align 4
  %encode_value_ptr228 = getelementptr i64, ptr %88, i64 %99
  store i64 %101, ptr %encode_value_ptr228, align 4
  %102 = add i64 %99, 1
  %103 = add i64 4, %90
  %104 = getelementptr i64, ptr %84, i64 0
  %105 = load i64, ptr %104, align 4
  %encode_value_ptr229 = getelementptr i64, ptr %88, i64 %103
  store i64 %105, ptr %encode_value_ptr229, align 4
  %106 = add i64 %103, 1
  %107 = getelementptr i64, ptr %84, i64 1
  %108 = load i64, ptr %107, align 4
  %encode_value_ptr230 = getelementptr i64, ptr %88, i64 %106
  store i64 %108, ptr %encode_value_ptr230, align 4
  %109 = add i64 %106, 1
  %110 = getelementptr i64, ptr %84, i64 2
  %111 = load i64, ptr %110, align 4
  %encode_value_ptr231 = getelementptr i64, ptr %88, i64 %109
  store i64 %111, ptr %encode_value_ptr231, align 4
  %112 = add i64 %109, 1
  %113 = getelementptr i64, ptr %84, i64 3
  %114 = load i64, ptr %113, align 4
  %encode_value_ptr232 = getelementptr i64, ptr %88, i64 %112
  store i64 %114, ptr %encode_value_ptr232, align 4
  %115 = add i64 %112, 1
  %116 = add i64 4, %103
  %vector_length233 = load i64, ptr %88, align 4
  %vector_data234 = getelementptr i64, ptr %88, i64 1
  %117 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data234, ptr %117, i64 %vector_length233)
  store ptr %117, ptr %signedHash, align 8
  %118 = load ptr, ptr %signedHash, align 8
  ret ptr %118
}

define ptr @getTransactionHash(ptr %0, ptr %1) {
entry:
  %txHash = alloca ptr, align 8
  %signature = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  store ptr %0, ptr %_signedHash, align 8
  store ptr %1, ptr %signature, align 8
  %2 = load ptr, ptr %signature, align 8
  %3 = load ptr, ptr %_signedHash, align 8
  %4 = call ptr @vector_new(i64 4)
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %7 = getelementptr i64, ptr %4, i64 0
  store i64 %6, ptr %7, align 4
  %8 = getelementptr i64, ptr %3, i64 1
  %9 = load i64, ptr %8, align 4
  %10 = getelementptr i64, ptr %4, i64 1
  store i64 %9, ptr %10, align 4
  %11 = getelementptr i64, ptr %3, i64 2
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %4, i64 2
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %3, i64 3
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %4, i64 3
  store i64 %15, ptr %16, align 4
  %vector_length = load i64, ptr %2, align 4
  %vector_data = getelementptr i64, ptr %2, i64 1
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data, ptr %17, i64 %vector_length)
  %18 = call ptr @vector_new(i64 4)
  %19 = getelementptr i64, ptr %17, i64 0
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %18, i64 0
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %17, i64 1
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %18, i64 1
  store i64 %23, ptr %24, align 4
  %25 = getelementptr i64, ptr %17, i64 2
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %18, i64 2
  store i64 %26, ptr %27, align 4
  %28 = getelementptr i64, ptr %17, i64 3
  %29 = load i64, ptr %28, align 4
  %30 = getelementptr i64, ptr %18, i64 3
  store i64 %29, ptr %30, align 4
  %31 = call ptr @fields_concat(ptr %4, ptr %18)
  %vector_length1 = load i64, ptr %31, align 4
  %vector_data2 = getelementptr i64, ptr %31, i64 1
  %32 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data2, ptr %32, i64 %vector_length1)
  store ptr %32, ptr %txHash, align 8
  %33 = load ptr, ptr %txHash, align 8
  ret ptr %33
}

define void @validate_sender(ptr %0) {
entry:
  %account_version = alloca i64, align 8
  %DEPLOYER_SYSTEM_CONTRACT = alloca ptr, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %1, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %1, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %1, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %1, i64 3
  store i64 32773, ptr %index_access3, align 4
  store ptr %1, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %2 = load ptr, ptr %_address, align 8
  %3 = call ptr @vector_new(i64 6)
  %4 = getelementptr i64, ptr %2, i64 0
  %5 = load i64, ptr %4, align 4
  %encode_value_ptr = getelementptr i64, ptr %3, i64 1
  store i64 %5, ptr %encode_value_ptr, align 4
  %6 = getelementptr i64, ptr %2, i64 1
  %7 = load i64, ptr %6, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %3, i64 2
  store i64 %7, ptr %encode_value_ptr4, align 4
  %8 = getelementptr i64, ptr %2, i64 2
  %9 = load i64, ptr %8, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %3, i64 3
  store i64 %9, ptr %encode_value_ptr5, align 4
  %10 = getelementptr i64, ptr %2, i64 3
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %3, i64 4
  store i64 %11, ptr %encode_value_ptr6, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %3, i64 5
  store i64 4, ptr %encode_value_ptr7, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %3, i64 6
  store i64 3138377232, ptr %encode_value_ptr8, align 4
  %12 = load ptr, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %vector_length = load i64, ptr %3, align 4
  %vector_data = getelementptr i64, ptr %3, i64 1
  %tape_size = add i64 %vector_length, 2
  call void @set_tape_data(ptr %vector_data, i64 %tape_size)
  call void @contract_call(ptr %12, i64 0)
  %13 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %13, i64 1)
  %return_length = load i64, ptr %13, align 4
  %heap_size = add i64 %return_length, 2
  %14 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %14, align 4
  %return_data_start = getelementptr i64, ptr %14, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_length9 = load i64, ptr %14, align 4
  %vector_data10 = getelementptr i64, ptr %14, i64 1
  %15 = load i64, ptr %vector_data10, align 4
  %16 = getelementptr ptr, ptr %vector_data10, i64 1
  store i64 %15, ptr %account_version, align 4
  %17 = load i64, ptr %account_version, align 4
  %18 = icmp ne i64 %17, 0
  %19 = zext i1 %18 to i64
  call void @builtin_assert(i64 %19)
  ret void
}

define void @validate_nonce(ptr %0, i64 %1) {
entry:
  %nonce = alloca i64, align 8
  %NONCE_HOLDER_ADDRESS = alloca ptr, align 8
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %2, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %2, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %2, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %2, i64 3
  store i64 32771, ptr %index_access3, align 4
  store ptr %2, ptr %NONCE_HOLDER_ADDRESS, align 8
  %3 = load ptr, ptr %_address, align 8
  %4 = load i64, ptr %_nonce, align 4
  %5 = call ptr @vector_new(i64 7)
  %6 = getelementptr i64, ptr %3, i64 0
  %7 = load i64, ptr %6, align 4
  %encode_value_ptr = getelementptr i64, ptr %5, i64 1
  store i64 %7, ptr %encode_value_ptr, align 4
  %8 = getelementptr i64, ptr %3, i64 1
  %9 = load i64, ptr %8, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %5, i64 2
  store i64 %9, ptr %encode_value_ptr4, align 4
  %10 = getelementptr i64, ptr %3, i64 2
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %5, i64 3
  store i64 %11, ptr %encode_value_ptr5, align 4
  %12 = getelementptr i64, ptr %3, i64 3
  %13 = load i64, ptr %12, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %5, i64 4
  store i64 %13, ptr %encode_value_ptr6, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %5, i64 5
  store i64 %4, ptr %encode_value_ptr7, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %5, i64 6
  store i64 5, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %5, i64 7
  store i64 3775522898, ptr %encode_value_ptr9, align 4
  %14 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %vector_length = load i64, ptr %5, align 4
  %vector_data = getelementptr i64, ptr %5, i64 1
  %tape_size = add i64 %vector_length, 2
  call void @set_tape_data(ptr %vector_data, i64 %tape_size)
  call void @contract_call(ptr %14, i64 0)
  %15 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %15, i64 1)
  %return_length = load i64, ptr %15, align 4
  %heap_size = add i64 %return_length, 2
  %16 = call ptr @heap_malloc(i64 %heap_size)
  store i64 %return_length, ptr %16, align 4
  %return_data_start = getelementptr i64, ptr %16, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_length10 = load i64, ptr %16, align 4
  %vector_data11 = getelementptr i64, ptr %16, i64 1
  %17 = load i64, ptr %vector_data11, align 4
  %18 = getelementptr ptr, ptr %vector_data11, i64 1
  store i64 %17, ptr %nonce, align 4
  %19 = load i64, ptr %nonce, align 4
  %20 = icmp eq i64 %19, 0
  %21 = zext i1 %20 to i64
  call void @builtin_assert(i64 %21)
  ret void
}

define void @validate_tx(ptr %0, ptr %1, ptr %2) {
entry:
  %magics = alloca ptr, align 8
  %magic = alloca i64, align 8
  %_tx = alloca ptr, align 8
  %_signedHash = alloca ptr, align 8
  %_txHash = alloca ptr, align 8
  store ptr %0, ptr %_txHash, align 8
  store ptr %1, ptr %_signedHash, align 8
  store ptr %2, ptr %_tx, align 8
  %3 = load ptr, ptr %_tx, align 8
  %4 = load ptr, ptr %_txHash, align 8
  %5 = load ptr, ptr %_signedHash, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 4
  %vector_length = load i64, ptr %struct_member, align 4
  %6 = add i64 %vector_length, 1
  %7 = add i64 7, %6
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 5
  %vector_length2 = load i64, ptr %struct_member1, align 4
  %8 = add i64 %vector_length2, 1
  %9 = add i64 %7, %8
  %struct_member3 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 6
  %vector_length4 = load i64, ptr %struct_member3, align 4
  %10 = add i64 %vector_length4, 1
  %11 = add i64 %9, %10
  %12 = add i64 %11, 4
  %13 = add i64 8, %12
  %heap_size = add i64 %13, 2
  %14 = call ptr @vector_new(i64 %heap_size)
  %15 = getelementptr i64, ptr %4, i64 0
  %16 = load i64, ptr %15, align 4
  %encode_value_ptr = getelementptr i64, ptr %14, i64 1
  store i64 %16, ptr %encode_value_ptr, align 4
  %17 = getelementptr i64, ptr %4, i64 1
  %18 = load i64, ptr %17, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %14, i64 2
  store i64 %18, ptr %encode_value_ptr5, align 4
  %19 = getelementptr i64, ptr %4, i64 2
  %20 = load i64, ptr %19, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %14, i64 3
  store i64 %20, ptr %encode_value_ptr6, align 4
  %21 = getelementptr i64, ptr %4, i64 3
  %22 = load i64, ptr %21, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %14, i64 4
  store i64 %22, ptr %encode_value_ptr7, align 4
  %23 = getelementptr i64, ptr %5, i64 0
  %24 = load i64, ptr %23, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %14, i64 5
  store i64 %24, ptr %encode_value_ptr8, align 4
  %25 = getelementptr i64, ptr %5, i64 1
  %26 = load i64, ptr %25, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %14, i64 6
  store i64 %26, ptr %encode_value_ptr9, align 4
  %27 = getelementptr i64, ptr %5, i64 2
  %28 = load i64, ptr %27, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %14, i64 7
  store i64 %28, ptr %encode_value_ptr10, align 4
  %29 = getelementptr i64, ptr %5, i64 3
  %30 = load i64, ptr %29, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %14, i64 8
  store i64 %30, ptr %encode_value_ptr11, align 4
  %struct_member12 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %elem = load ptr, ptr %struct_member12, align 8
  %31 = getelementptr i64, ptr %elem, i64 0
  %32 = load i64, ptr %31, align 4
  %encode_value_ptr13 = getelementptr i64, ptr %14, i64 9
  store i64 %32, ptr %encode_value_ptr13, align 4
  %33 = getelementptr i64, ptr %elem, i64 1
  %34 = load i64, ptr %33, align 4
  %encode_value_ptr14 = getelementptr i64, ptr %14, i64 10
  store i64 %34, ptr %encode_value_ptr14, align 4
  %35 = getelementptr i64, ptr %elem, i64 2
  %36 = load i64, ptr %35, align 4
  %encode_value_ptr15 = getelementptr i64, ptr %14, i64 11
  store i64 %36, ptr %encode_value_ptr15, align 4
  %37 = getelementptr i64, ptr %elem, i64 3
  %38 = load i64, ptr %37, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %14, i64 12
  store i64 %38, ptr %encode_value_ptr16, align 4
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 1
  %elem18 = load i64, ptr %struct_member17, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %14, i64 13
  store i64 %elem18, ptr %encode_value_ptr19, align 4
  %struct_member20 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 2
  %elem21 = load i64, ptr %struct_member20, align 4
  %encode_value_ptr22 = getelementptr i64, ptr %14, i64 14
  store i64 %elem21, ptr %encode_value_ptr22, align 4
  %struct_member23 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 3
  %elem24 = load i64, ptr %struct_member23, align 4
  %encode_value_ptr25 = getelementptr i64, ptr %14, i64 15
  store i64 %elem24, ptr %encode_value_ptr25, align 4
  %struct_member26 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 4
  %elem27 = load ptr, ptr %struct_member26, align 8
  %vector_length28 = load i64, ptr %elem27, align 4
  %vector_data = getelementptr i64, ptr %elem27, i64 1
  %39 = add i64 %vector_length28, 1
  call void @memcpy(ptr %vector_data, ptr %14, i64 %39)
  %40 = add i64 %39, 7
  %41 = add i64 %39, 16
  %struct_member29 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 5
  %elem30 = load ptr, ptr %struct_member29, align 8
  %vector_length31 = load i64, ptr %elem30, align 4
  %vector_data32 = getelementptr i64, ptr %elem30, i64 1
  %42 = add i64 %vector_length31, 1
  call void @memcpy(ptr %vector_data32, ptr %14, i64 %42)
  %43 = add i64 %42, %40
  %44 = add i64 %42, %41
  %struct_member33 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 6
  %elem34 = load ptr, ptr %struct_member33, align 8
  %vector_length35 = load i64, ptr %elem34, align 4
  %vector_data36 = getelementptr i64, ptr %elem34, i64 1
  %45 = add i64 %vector_length35, 1
  call void @memcpy(ptr %vector_data36, ptr %14, i64 %45)
  %46 = add i64 %45, %43
  %47 = add i64 %45, %44
  %struct_member37 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 7
  %elem38 = load ptr, ptr %struct_member37, align 8
  %48 = getelementptr i64, ptr %elem38, i64 0
  %49 = load i64, ptr %48, align 4
  %encode_value_ptr39 = getelementptr i64, ptr %14, i64 %47
  store i64 %49, ptr %encode_value_ptr39, align 4
  %50 = add i64 %47, 1
  %51 = getelementptr i64, ptr %elem38, i64 1
  %52 = load i64, ptr %51, align 4
  %encode_value_ptr40 = getelementptr i64, ptr %14, i64 %50
  store i64 %52, ptr %encode_value_ptr40, align 4
  %53 = add i64 %50, 1
  %54 = getelementptr i64, ptr %elem38, i64 2
  %55 = load i64, ptr %54, align 4
  %encode_value_ptr41 = getelementptr i64, ptr %14, i64 %53
  store i64 %55, ptr %encode_value_ptr41, align 4
  %56 = add i64 %53, 1
  %57 = getelementptr i64, ptr %elem38, i64 3
  %58 = load i64, ptr %57, align 4
  %encode_value_ptr42 = getelementptr i64, ptr %14, i64 %56
  store i64 %58, ptr %encode_value_ptr42, align 4
  %59 = add i64 %56, 1
  %60 = add i64 4, %46
  %61 = add i64 %60, 9
  %encode_value_ptr43 = getelementptr i64, ptr %14, i64 %61
  store i64 %13, ptr %encode_value_ptr43, align 4
  %62 = add i64 %61, 1
  %encode_value_ptr44 = getelementptr i64, ptr %14, i64 %62
  store i64 3738116221, ptr %encode_value_ptr44, align 4
  %struct_member45 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %63 = load ptr, ptr %struct_member45, align 8
  %vector_length46 = load i64, ptr %14, align 4
  %vector_data47 = getelementptr i64, ptr %14, i64 1
  %tape_size = add i64 %vector_length46, 2
  call void @set_tape_data(ptr %vector_data47, i64 %tape_size)
  call void @contract_call(ptr %63, i64 0)
  %64 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %64, i64 1)
  %return_length = load i64, ptr %64, align 4
  %heap_size48 = add i64 %return_length, 2
  %65 = call ptr @heap_malloc(i64 %heap_size48)
  store i64 %return_length, ptr %65, align 4
  %return_data_start = getelementptr i64, ptr %65, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_length49 = load i64, ptr %65, align 4
  %vector_data50 = getelementptr i64, ptr %65, i64 1
  %66 = load i64, ptr %vector_data50, align 4
  %67 = getelementptr ptr, ptr %vector_data50, i64 1
  store i64 %66, ptr %magic, align 4
  %68 = call ptr @vector_new(i64 1764)
  %vector_data51 = getelementptr i64, ptr %68, i64 1
  %index_access = getelementptr i64, ptr %vector_data51, i64 0
  store i64 118, ptr %index_access, align 4
  %index_access52 = getelementptr i64, ptr %vector_data51, i64 1
  store i64 97, ptr %index_access52, align 4
  %index_access53 = getelementptr i64, ptr %vector_data51, i64 2
  store i64 108, ptr %index_access53, align 4
  %index_access54 = getelementptr i64, ptr %vector_data51, i64 3
  store i64 105, ptr %index_access54, align 4
  %index_access55 = getelementptr i64, ptr %vector_data51, i64 4
  store i64 100, ptr %index_access55, align 4
  %index_access56 = getelementptr i64, ptr %vector_data51, i64 5
  store i64 97, ptr %index_access56, align 4
  %index_access57 = getelementptr i64, ptr %vector_data51, i64 6
  store i64 116, ptr %index_access57, align 4
  %index_access58 = getelementptr i64, ptr %vector_data51, i64 7
  store i64 101, ptr %index_access58, align 4
  %index_access59 = getelementptr i64, ptr %vector_data51, i64 8
  store i64 84, ptr %index_access59, align 4
  %index_access60 = getelementptr i64, ptr %vector_data51, i64 9
  store i64 114, ptr %index_access60, align 4
  %index_access61 = getelementptr i64, ptr %vector_data51, i64 10
  store i64 97, ptr %index_access61, align 4
  %index_access62 = getelementptr i64, ptr %vector_data51, i64 11
  store i64 110, ptr %index_access62, align 4
  %index_access63 = getelementptr i64, ptr %vector_data51, i64 12
  store i64 115, ptr %index_access63, align 4
  %index_access64 = getelementptr i64, ptr %vector_data51, i64 13
  store i64 97, ptr %index_access64, align 4
  %index_access65 = getelementptr i64, ptr %vector_data51, i64 14
  store i64 99, ptr %index_access65, align 4
  %index_access66 = getelementptr i64, ptr %vector_data51, i64 15
  store i64 116, ptr %index_access66, align 4
  %index_access67 = getelementptr i64, ptr %vector_data51, i64 16
  store i64 105, ptr %index_access67, align 4
  %index_access68 = getelementptr i64, ptr %vector_data51, i64 17
  store i64 111, ptr %index_access68, align 4
  %index_access69 = getelementptr i64, ptr %vector_data51, i64 18
  store i64 110, ptr %index_access69, align 4
  %index_access70 = getelementptr i64, ptr %vector_data51, i64 19
  store i64 40, ptr %index_access70, align 4
  %index_access71 = getelementptr i64, ptr %vector_data51, i64 20
  store i64 104, ptr %index_access71, align 4
  %index_access72 = getelementptr i64, ptr %vector_data51, i64 21
  store i64 97, ptr %index_access72, align 4
  %index_access73 = getelementptr i64, ptr %vector_data51, i64 22
  store i64 115, ptr %index_access73, align 4
  %index_access74 = getelementptr i64, ptr %vector_data51, i64 23
  store i64 104, ptr %index_access74, align 4
  %index_access75 = getelementptr i64, ptr %vector_data51, i64 24
  store i64 44, ptr %index_access75, align 4
  %index_access76 = getelementptr i64, ptr %vector_data51, i64 25
  store i64 104, ptr %index_access76, align 4
  %index_access77 = getelementptr i64, ptr %vector_data51, i64 26
  store i64 97, ptr %index_access77, align 4
  %index_access78 = getelementptr i64, ptr %vector_data51, i64 27
  store i64 115, ptr %index_access78, align 4
  %index_access79 = getelementptr i64, ptr %vector_data51, i64 28
  store i64 104, ptr %index_access79, align 4
  %index_access80 = getelementptr i64, ptr %vector_data51, i64 29
  store i64 44, ptr %index_access80, align 4
  %index_access81 = getelementptr i64, ptr %vector_data51, i64 30
  store i64 84, ptr %index_access81, align 4
  %index_access82 = getelementptr i64, ptr %vector_data51, i64 31
  store i64 114, ptr %index_access82, align 4
  %index_access83 = getelementptr i64, ptr %vector_data51, i64 32
  store i64 97, ptr %index_access83, align 4
  %index_access84 = getelementptr i64, ptr %vector_data51, i64 33
  store i64 110, ptr %index_access84, align 4
  %index_access85 = getelementptr i64, ptr %vector_data51, i64 34
  store i64 115, ptr %index_access85, align 4
  %index_access86 = getelementptr i64, ptr %vector_data51, i64 35
  store i64 97, ptr %index_access86, align 4
  %index_access87 = getelementptr i64, ptr %vector_data51, i64 36
  store i64 99, ptr %index_access87, align 4
  %index_access88 = getelementptr i64, ptr %vector_data51, i64 37
  store i64 116, ptr %index_access88, align 4
  %index_access89 = getelementptr i64, ptr %vector_data51, i64 38
  store i64 105, ptr %index_access89, align 4
  %index_access90 = getelementptr i64, ptr %vector_data51, i64 39
  store i64 111, ptr %index_access90, align 4
  %index_access91 = getelementptr i64, ptr %vector_data51, i64 40
  store i64 110, ptr %index_access91, align 4
  %index_access92 = getelementptr i64, ptr %vector_data51, i64 41
  store i64 41, ptr %index_access92, align 4
  %vector_length93 = load i64, ptr %68, align 4
  %vector_data94 = getelementptr i64, ptr %68, i64 1
  %69 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data94, ptr %69, i64 %vector_length93)
  store ptr %69, ptr %magics, align 8
  %70 = load ptr, ptr %magics, align 8
  %71 = call ptr @vector_new(i64 4)
  %72 = getelementptr i64, ptr %70, i64 0
  %73 = load i64, ptr %72, align 4
  %74 = getelementptr i64, ptr %71, i64 0
  store i64 %73, ptr %74, align 4
  %75 = getelementptr i64, ptr %70, i64 1
  %76 = load i64, ptr %75, align 4
  %77 = getelementptr i64, ptr %71, i64 1
  store i64 %76, ptr %77, align 4
  %78 = getelementptr i64, ptr %70, i64 2
  %79 = load i64, ptr %78, align 4
  %80 = getelementptr i64, ptr %71, i64 2
  store i64 %79, ptr %80, align 4
  %81 = getelementptr i64, ptr %70, i64 3
  %82 = load i64, ptr %81, align 4
  %83 = getelementptr i64, ptr %71, i64 3
  store i64 %82, ptr %83, align 4
  %84 = load i64, ptr %magic, align 4
  %vector_length95 = load i64, ptr %71, align 4
  %85 = sub i64 %vector_length95, 1
  %86 = sub i64 %85, 0
  call void @builtin_range_check(i64 %86)
  %vector_data96 = getelementptr i64, ptr %71, i64 1
  %index_access97 = getelementptr i64, ptr %vector_data96, i64 0
  %87 = load i64, ptr %index_access97, align 4
  %88 = icmp eq i64 %84, %87
  %89 = zext i1 %88 to i64
  call void @builtin_assert(i64 %89)
  ret void
}

define ptr @hashL2Bytecode(ptr %0) {
entry:
  %hash_bytecode = alloca ptr, align 8
  %_bytecode = alloca ptr, align 8
  store ptr %0, ptr %_bytecode, align 8
  %1 = load ptr, ptr %_bytecode, align 8
  %vector_length = load i64, ptr %1, align 4
  %vector_data = getelementptr i64, ptr %1, i64 1
  %2 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data, ptr %2, i64 %vector_length)
  store ptr %2, ptr %hash_bytecode, align 8
  %3 = load ptr, ptr %hash_bytecode, align 8
  ret ptr %3
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 948084220, label %func_0_dispatch
    i64 1249840025, label %func_1_dispatch
    i64 3257286500, label %func_2_dispatch
    i64 2868538108, label %func_3_dispatch
    i64 3836602602, label %func_4_dispatch
    i64 1989631117, label %func_5_dispatch
    i64 61057063, label %func_6_dispatch
    i64 1928909022, label %func_7_dispatch
    i64 3701337357, label %func_8_dispatch
    i64 2845631446, label %func_9_dispatch
    i64 1659424326, label %func_10_dispatch
    i64 2132927061, label %func_11_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %decode_struct_field = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 0
  %decode_struct_field1 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 4
  %3 = load i64, ptr %decode_struct_field1, align 4
  %decode_struct_field2 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 5
  %4 = load i64, ptr %decode_struct_field2, align 4
  %decode_struct_field3 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 6
  %5 = load i64, ptr %decode_struct_field3, align 4
  %decode_struct_field4 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 7
  %vector_length = load i64, ptr %decode_struct_field4, align 4
  %6 = add i64 %vector_length, 1
  %decode_struct_offset = add i64 7, %6
  %decode_struct_field5 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset
  %vector_length6 = load i64, ptr %decode_struct_field5, align 4
  %7 = add i64 %vector_length6, 1
  %decode_struct_offset7 = add i64 %decode_struct_offset, %7
  %decode_struct_field8 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset7
  %vector_length9 = load i64, ptr %decode_struct_field8, align 4
  %8 = add i64 %vector_length9, 1
  %decode_struct_offset10 = add i64 %decode_struct_offset7, %8
  %decode_struct_field11 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset10
  %decode_struct_offset12 = add i64 %decode_struct_offset10, 4
  %9 = call ptr @heap_malloc(i64 14)
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 0
  store ptr %decode_struct_field, ptr %struct_member, align 8
  %struct_member13 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 1
  store i64 %3, ptr %struct_member13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 2
  store i64 %4, ptr %struct_member14, align 4
  %struct_member15 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 3
  store i64 %5, ptr %struct_member15, align 4
  %struct_member16 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 4
  store ptr %decode_struct_field4, ptr %struct_member16, align 8
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 5
  store ptr %decode_struct_field5, ptr %struct_member17, align 8
  %struct_member18 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 6
  store ptr %decode_struct_field8, ptr %struct_member18, align 8
  %struct_member19 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 7
  store ptr %decode_struct_field11, ptr %struct_member19, align 8
  %10 = getelementptr ptr, ptr %input, i64 %decode_struct_offset12
  %11 = load i64, ptr %10, align 4
  %12 = getelementptr ptr, ptr %10, i64 1
  call void @system_entrance(ptr %9, i64 %11)
  %13 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %13, align 4
  call void @set_tape_data(ptr %13, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %decode_struct_field20 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 0
  %decode_struct_field21 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 4
  %14 = load i64, ptr %decode_struct_field21, align 4
  %decode_struct_field22 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 5
  %15 = load i64, ptr %decode_struct_field22, align 4
  %decode_struct_field23 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 6
  %16 = load i64, ptr %decode_struct_field23, align 4
  %decode_struct_field24 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 7
  %vector_length25 = load i64, ptr %decode_struct_field24, align 4
  %17 = add i64 %vector_length25, 1
  %decode_struct_offset26 = add i64 7, %17
  %decode_struct_field27 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset26
  %vector_length28 = load i64, ptr %decode_struct_field27, align 4
  %18 = add i64 %vector_length28, 1
  %decode_struct_offset29 = add i64 %decode_struct_offset26, %18
  %decode_struct_field30 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset29
  %vector_length31 = load i64, ptr %decode_struct_field30, align 4
  %19 = add i64 %vector_length31, 1
  %decode_struct_offset32 = add i64 %decode_struct_offset29, %19
  %decode_struct_field33 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset32
  %decode_struct_offset34 = add i64 %decode_struct_offset32, 4
  %20 = call ptr @heap_malloc(i64 14)
  %struct_member35 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 0
  store ptr %decode_struct_field20, ptr %struct_member35, align 8
  %struct_member36 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 1
  store i64 %14, ptr %struct_member36, align 4
  %struct_member37 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 2
  store i64 %15, ptr %struct_member37, align 4
  %struct_member38 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 3
  store i64 %16, ptr %struct_member38, align 4
  %struct_member39 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 4
  store ptr %decode_struct_field24, ptr %struct_member39, align 8
  %struct_member40 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 5
  store ptr %decode_struct_field27, ptr %struct_member40, align 8
  %struct_member41 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 6
  store ptr %decode_struct_field30, ptr %struct_member41, align 8
  %struct_member42 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 7
  store ptr %decode_struct_field33, ptr %struct_member42, align 8
  %21 = getelementptr ptr, ptr %input, i64 %decode_struct_offset34
  call void @validateTxStructure(ptr %20)
  %22 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %22, align 4
  call void @set_tape_data(ptr %22, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %decode_struct_field43 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 0
  %decode_struct_field44 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 4
  %23 = load i64, ptr %decode_struct_field44, align 4
  %decode_struct_field45 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 5
  %24 = load i64, ptr %decode_struct_field45, align 4
  %decode_struct_field46 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 6
  %25 = load i64, ptr %decode_struct_field46, align 4
  %decode_struct_field47 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 7
  %vector_length48 = load i64, ptr %decode_struct_field47, align 4
  %26 = add i64 %vector_length48, 1
  %decode_struct_offset49 = add i64 7, %26
  %decode_struct_field50 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset49
  %vector_length51 = load i64, ptr %decode_struct_field50, align 4
  %27 = add i64 %vector_length51, 1
  %decode_struct_offset52 = add i64 %decode_struct_offset49, %27
  %decode_struct_field53 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset52
  %vector_length54 = load i64, ptr %decode_struct_field53, align 4
  %28 = add i64 %vector_length54, 1
  %decode_struct_offset55 = add i64 %decode_struct_offset52, %28
  %decode_struct_field56 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset55
  %decode_struct_offset57 = add i64 %decode_struct_offset55, 4
  %29 = call ptr @heap_malloc(i64 14)
  %struct_member58 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 0
  store ptr %decode_struct_field43, ptr %struct_member58, align 8
  %struct_member59 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 1
  store i64 %23, ptr %struct_member59, align 4
  %struct_member60 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 2
  store i64 %24, ptr %struct_member60, align 4
  %struct_member61 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 3
  store i64 %25, ptr %struct_member61, align 4
  %struct_member62 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 4
  store ptr %decode_struct_field47, ptr %struct_member62, align 8
  %struct_member63 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 5
  store ptr %decode_struct_field50, ptr %struct_member63, align 8
  %struct_member64 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 6
  store ptr %decode_struct_field53, ptr %struct_member64, align 8
  %struct_member65 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 7
  store ptr %decode_struct_field56, ptr %struct_member65, align 8
  %30 = getelementptr ptr, ptr %input, i64 %decode_struct_offset57
  %31 = call ptr @callTx(ptr %29)
  %vector_length66 = load i64, ptr %31, align 4
  %32 = add i64 %vector_length66, 1
  %heap_size = add i64 %32, 1
  %33 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length67 = load i64, ptr %31, align 4
  %vector_data = getelementptr i64, ptr %31, i64 1
  %34 = add i64 %vector_length67, 1
  call void @memcpy(ptr %vector_data, ptr %33, i64 %34)
  %35 = add i64 %34, 0
  %encode_value_ptr = getelementptr i64, ptr %33, i64 %35
  store i64 %32, ptr %encode_value_ptr, align 4
  call void @set_tape_data(ptr %33, i64 %heap_size)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %decode_struct_field68 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 0
  %decode_struct_field69 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 4
  %36 = load i64, ptr %decode_struct_field69, align 4
  %decode_struct_field70 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 5
  %37 = load i64, ptr %decode_struct_field70, align 4
  %decode_struct_field71 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 6
  %38 = load i64, ptr %decode_struct_field71, align 4
  %decode_struct_field72 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 7
  %vector_length73 = load i64, ptr %decode_struct_field72, align 4
  %39 = add i64 %vector_length73, 1
  %decode_struct_offset74 = add i64 7, %39
  %decode_struct_field75 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset74
  %vector_length76 = load i64, ptr %decode_struct_field75, align 4
  %40 = add i64 %vector_length76, 1
  %decode_struct_offset77 = add i64 %decode_struct_offset74, %40
  %decode_struct_field78 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset77
  %vector_length79 = load i64, ptr %decode_struct_field78, align 4
  %41 = add i64 %vector_length79, 1
  %decode_struct_offset80 = add i64 %decode_struct_offset77, %41
  %decode_struct_field81 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset80
  %decode_struct_offset82 = add i64 %decode_struct_offset80, 4
  %42 = call ptr @heap_malloc(i64 14)
  %struct_member83 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 0
  store ptr %decode_struct_field68, ptr %struct_member83, align 8
  %struct_member84 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 1
  store i64 %36, ptr %struct_member84, align 4
  %struct_member85 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 2
  store i64 %37, ptr %struct_member85, align 4
  %struct_member86 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 3
  store i64 %38, ptr %struct_member86, align 4
  %struct_member87 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 4
  store ptr %decode_struct_field72, ptr %struct_member87, align 8
  %struct_member88 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 5
  store ptr %decode_struct_field75, ptr %struct_member88, align 8
  %struct_member89 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 6
  store ptr %decode_struct_field78, ptr %struct_member89, align 8
  %struct_member90 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 7
  store ptr %decode_struct_field81, ptr %struct_member90, align 8
  %43 = getelementptr ptr, ptr %input, i64 %decode_struct_offset82
  call void @sendTx(ptr %42)
  %44 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %44, align 4
  call void @set_tape_data(ptr %44, i64 1)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %decode_struct_field91 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 0
  %decode_struct_field92 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 4
  %45 = load i64, ptr %decode_struct_field92, align 4
  %decode_struct_field93 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 5
  %46 = load i64, ptr %decode_struct_field93, align 4
  %decode_struct_field94 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 6
  %47 = load i64, ptr %decode_struct_field94, align 4
  %decode_struct_field95 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 7
  %vector_length96 = load i64, ptr %decode_struct_field95, align 4
  %48 = add i64 %vector_length96, 1
  %decode_struct_offset97 = add i64 7, %48
  %decode_struct_field98 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset97
  %vector_length99 = load i64, ptr %decode_struct_field98, align 4
  %49 = add i64 %vector_length99, 1
  %decode_struct_offset100 = add i64 %decode_struct_offset97, %49
  %decode_struct_field101 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset100
  %vector_length102 = load i64, ptr %decode_struct_field101, align 4
  %50 = add i64 %vector_length102, 1
  %decode_struct_offset103 = add i64 %decode_struct_offset100, %50
  %decode_struct_field104 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset103
  %decode_struct_offset105 = add i64 %decode_struct_offset103, 4
  %51 = call ptr @heap_malloc(i64 14)
  %struct_member106 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 0
  store ptr %decode_struct_field91, ptr %struct_member106, align 8
  %struct_member107 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 1
  store i64 %45, ptr %struct_member107, align 4
  %struct_member108 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 2
  store i64 %46, ptr %struct_member108, align 4
  %struct_member109 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 3
  store i64 %47, ptr %struct_member109, align 4
  %struct_member110 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 4
  store ptr %decode_struct_field95, ptr %struct_member110, align 8
  %struct_member111 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 5
  store ptr %decode_struct_field98, ptr %struct_member111, align 8
  %struct_member112 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 6
  store ptr %decode_struct_field101, ptr %struct_member112, align 8
  %struct_member113 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 7
  store ptr %decode_struct_field104, ptr %struct_member113, align 8
  %52 = getelementptr ptr, ptr %input, i64 %decode_struct_offset105
  call void @validateTx(ptr %51)
  %53 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %53, align 4
  call void @set_tape_data(ptr %53, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %decode_struct_field114 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 0
  %decode_struct_field115 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 4
  %54 = load i64, ptr %decode_struct_field115, align 4
  %decode_struct_field116 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 5
  %55 = load i64, ptr %decode_struct_field116, align 4
  %decode_struct_field117 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 6
  %56 = load i64, ptr %decode_struct_field117, align 4
  %decode_struct_field118 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 7
  %vector_length119 = load i64, ptr %decode_struct_field118, align 4
  %57 = add i64 %vector_length119, 1
  %decode_struct_offset120 = add i64 7, %57
  %decode_struct_field121 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset120
  %vector_length122 = load i64, ptr %decode_struct_field121, align 4
  %58 = add i64 %vector_length122, 1
  %decode_struct_offset123 = add i64 %decode_struct_offset120, %58
  %decode_struct_field124 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset123
  %vector_length125 = load i64, ptr %decode_struct_field124, align 4
  %59 = add i64 %vector_length125, 1
  %decode_struct_offset126 = add i64 %decode_struct_offset123, %59
  %decode_struct_field127 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset126
  %decode_struct_offset128 = add i64 %decode_struct_offset126, 4
  %60 = call ptr @heap_malloc(i64 14)
  %struct_member129 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 0
  store ptr %decode_struct_field114, ptr %struct_member129, align 8
  %struct_member130 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 1
  store i64 %54, ptr %struct_member130, align 4
  %struct_member131 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 2
  store i64 %55, ptr %struct_member131, align 4
  %struct_member132 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 3
  store i64 %56, ptr %struct_member132, align 4
  %struct_member133 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 4
  store ptr %decode_struct_field118, ptr %struct_member133, align 8
  %struct_member134 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 5
  store ptr %decode_struct_field121, ptr %struct_member134, align 8
  %struct_member135 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 6
  store ptr %decode_struct_field124, ptr %struct_member135, align 8
  %struct_member136 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 7
  store ptr %decode_struct_field127, ptr %struct_member136, align 8
  %61 = getelementptr ptr, ptr %input, i64 %decode_struct_offset128
  call void @validateDeployment(ptr %60)
  %62 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %62, align 4
  call void @set_tape_data(ptr %62, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %decode_struct_field137 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 0
  %decode_struct_field138 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 4
  %63 = load i64, ptr %decode_struct_field138, align 4
  %decode_struct_field139 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 5
  %64 = load i64, ptr %decode_struct_field139, align 4
  %decode_struct_field140 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 6
  %65 = load i64, ptr %decode_struct_field140, align 4
  %decode_struct_field141 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 7
  %vector_length142 = load i64, ptr %decode_struct_field141, align 4
  %66 = add i64 %vector_length142, 1
  %decode_struct_offset143 = add i64 7, %66
  %decode_struct_field144 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset143
  %vector_length145 = load i64, ptr %decode_struct_field144, align 4
  %67 = add i64 %vector_length145, 1
  %decode_struct_offset146 = add i64 %decode_struct_offset143, %67
  %decode_struct_field147 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset146
  %vector_length148 = load i64, ptr %decode_struct_field147, align 4
  %68 = add i64 %vector_length148, 1
  %decode_struct_offset149 = add i64 %decode_struct_offset146, %68
  %decode_struct_field150 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %input, i64 %decode_struct_offset149
  %decode_struct_offset151 = add i64 %decode_struct_offset149, 4
  %69 = call ptr @heap_malloc(i64 14)
  %struct_member152 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 0
  store ptr %decode_struct_field137, ptr %struct_member152, align 8
  %struct_member153 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 1
  store i64 %63, ptr %struct_member153, align 4
  %struct_member154 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 2
  store i64 %64, ptr %struct_member154, align 4
  %struct_member155 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 3
  store i64 %65, ptr %struct_member155, align 4
  %struct_member156 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 4
  store ptr %decode_struct_field141, ptr %struct_member156, align 8
  %struct_member157 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 5
  store ptr %decode_struct_field144, ptr %struct_member157, align 8
  %struct_member158 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 6
  store ptr %decode_struct_field147, ptr %struct_member158, align 8
  %struct_member159 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 7
  store ptr %decode_struct_field150, ptr %struct_member159, align 8
  %70 = getelementptr ptr, ptr %input, i64 %decode_struct_offset151
  %71 = call ptr @getSignedHash(ptr %69)
  %72 = call ptr @heap_malloc(i64 5)
  %73 = getelementptr i64, ptr %71, i64 0
  %74 = load i64, ptr %73, align 4
  %encode_value_ptr160 = getelementptr i64, ptr %72, i64 0
  store i64 %74, ptr %encode_value_ptr160, align 4
  %75 = getelementptr i64, ptr %71, i64 1
  %76 = load i64, ptr %75, align 4
  %encode_value_ptr161 = getelementptr i64, ptr %72, i64 1
  store i64 %76, ptr %encode_value_ptr161, align 4
  %77 = getelementptr i64, ptr %71, i64 2
  %78 = load i64, ptr %77, align 4
  %encode_value_ptr162 = getelementptr i64, ptr %72, i64 2
  store i64 %78, ptr %encode_value_ptr162, align 4
  %79 = getelementptr i64, ptr %71, i64 3
  %80 = load i64, ptr %79, align 4
  %encode_value_ptr163 = getelementptr i64, ptr %72, i64 3
  store i64 %80, ptr %encode_value_ptr163, align 4
  %encode_value_ptr164 = getelementptr i64, ptr %72, i64 4
  store i64 4, ptr %encode_value_ptr164, align 4
  call void @set_tape_data(ptr %72, i64 5)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %81 = getelementptr ptr, ptr %input, i64 4
  %vector_length165 = load i64, ptr %81, align 4
  %82 = add i64 %vector_length165, 1
  %83 = getelementptr ptr, ptr %81, i64 %82
  %84 = call ptr @getTransactionHash(ptr %input, ptr %81)
  %85 = call ptr @heap_malloc(i64 5)
  %86 = getelementptr i64, ptr %84, i64 0
  %87 = load i64, ptr %86, align 4
  %encode_value_ptr166 = getelementptr i64, ptr %85, i64 0
  store i64 %87, ptr %encode_value_ptr166, align 4
  %88 = getelementptr i64, ptr %84, i64 1
  %89 = load i64, ptr %88, align 4
  %encode_value_ptr167 = getelementptr i64, ptr %85, i64 1
  store i64 %89, ptr %encode_value_ptr167, align 4
  %90 = getelementptr i64, ptr %84, i64 2
  %91 = load i64, ptr %90, align 4
  %encode_value_ptr168 = getelementptr i64, ptr %85, i64 2
  store i64 %91, ptr %encode_value_ptr168, align 4
  %92 = getelementptr i64, ptr %84, i64 3
  %93 = load i64, ptr %92, align 4
  %encode_value_ptr169 = getelementptr i64, ptr %85, i64 3
  store i64 %93, ptr %encode_value_ptr169, align 4
  %encode_value_ptr170 = getelementptr i64, ptr %85, i64 4
  store i64 4, ptr %encode_value_ptr170, align 4
  call void @set_tape_data(ptr %85, i64 5)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %94 = getelementptr ptr, ptr %input, i64 4
  call void @validate_sender(ptr %input)
  %95 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %95, align 4
  call void @set_tape_data(ptr %95, i64 1)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %96 = getelementptr ptr, ptr %input, i64 4
  %97 = load i64, ptr %96, align 4
  %98 = getelementptr ptr, ptr %96, i64 1
  call void @validate_nonce(ptr %input, i64 %97)
  %99 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %99, align 4
  call void @set_tape_data(ptr %99, i64 1)
  ret void

func_10_dispatch:                                 ; preds = %entry
  %100 = getelementptr ptr, ptr %input, i64 4
  %101 = getelementptr ptr, ptr %100, i64 4
  %decode_struct_field171 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 0
  %decode_struct_field172 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 4
  %102 = load i64, ptr %decode_struct_field172, align 4
  %decode_struct_field173 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 5
  %103 = load i64, ptr %decode_struct_field173, align 4
  %decode_struct_field174 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 6
  %104 = load i64, ptr %decode_struct_field174, align 4
  %decode_struct_field175 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 7
  %vector_length176 = load i64, ptr %decode_struct_field175, align 4
  %105 = add i64 %vector_length176, 1
  %decode_struct_offset177 = add i64 7, %105
  %decode_struct_field178 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 %decode_struct_offset177
  %vector_length179 = load i64, ptr %decode_struct_field178, align 4
  %106 = add i64 %vector_length179, 1
  %decode_struct_offset180 = add i64 %decode_struct_offset177, %106
  %decode_struct_field181 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 %decode_struct_offset180
  %vector_length182 = load i64, ptr %decode_struct_field181, align 4
  %107 = add i64 %vector_length182, 1
  %decode_struct_offset183 = add i64 %decode_struct_offset180, %107
  %decode_struct_field184 = getelementptr { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %101, i64 %decode_struct_offset183
  %decode_struct_offset185 = add i64 %decode_struct_offset183, 4
  %108 = call ptr @heap_malloc(i64 14)
  %struct_member186 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 0
  store ptr %decode_struct_field171, ptr %struct_member186, align 8
  %struct_member187 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 1
  store i64 %102, ptr %struct_member187, align 4
  %struct_member188 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 2
  store i64 %103, ptr %struct_member188, align 4
  %struct_member189 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 3
  store i64 %104, ptr %struct_member189, align 4
  %struct_member190 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 4
  store ptr %decode_struct_field175, ptr %struct_member190, align 8
  %struct_member191 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 5
  store ptr %decode_struct_field178, ptr %struct_member191, align 8
  %struct_member192 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 6
  store ptr %decode_struct_field181, ptr %struct_member192, align 8
  %struct_member193 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 7
  store ptr %decode_struct_field184, ptr %struct_member193, align 8
  %109 = getelementptr ptr, ptr %101, i64 %decode_struct_offset185
  call void @validate_tx(ptr %input, ptr %100, ptr %108)
  %110 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %110, align 4
  call void @set_tape_data(ptr %110, i64 1)
  ret void

func_11_dispatch:                                 ; preds = %entry
  %vector_length194 = load i64, ptr %input, align 4
  %111 = add i64 %vector_length194, 1
  %112 = getelementptr ptr, ptr %input, i64 %111
  %113 = call ptr @hashL2Bytecode(ptr %input)
  %114 = call ptr @heap_malloc(i64 5)
  %115 = getelementptr i64, ptr %113, i64 0
  %116 = load i64, ptr %115, align 4
  %encode_value_ptr195 = getelementptr i64, ptr %114, i64 0
  store i64 %116, ptr %encode_value_ptr195, align 4
  %117 = getelementptr i64, ptr %113, i64 1
  %118 = load i64, ptr %117, align 4
  %encode_value_ptr196 = getelementptr i64, ptr %114, i64 1
  store i64 %118, ptr %encode_value_ptr196, align 4
  %119 = getelementptr i64, ptr %113, i64 2
  %120 = load i64, ptr %119, align 4
  %encode_value_ptr197 = getelementptr i64, ptr %114, i64 2
  store i64 %120, ptr %encode_value_ptr197, align 4
  %121 = getelementptr i64, ptr %113, i64 3
  %122 = load i64, ptr %121, align 4
  %encode_value_ptr198 = getelementptr i64, ptr %114, i64 3
  store i64 %122, ptr %encode_value_ptr198, align 4
  %encode_value_ptr199 = getelementptr i64, ptr %114, i64 4
  store i64 4, ptr %encode_value_ptr199, align 4
  call void @set_tape_data(ptr %114, i64 5)
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
