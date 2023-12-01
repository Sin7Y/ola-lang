; ModuleID = 'Entrypoint'
source_filename = "Entrypoint"

@heap_address = internal global i64 -4294967353

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
  %2 = call ptr @vector_new(i64 109)
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
  %47 = call ptr @vector_new(i64 52)
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
  %50 = call ptr @vector_new(i64 3)
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
  %82 = call ptr @vector_new(i64 2)
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
  %6 = getelementptr ptr, ptr %3, i64 0
  %7 = getelementptr i64, ptr %6, i64 1
  %8 = getelementptr i64, ptr %7, i64 2
  %9 = getelementptr i64, ptr %8, i64 3
  %vector_length = load i64, ptr %9, align 4
  %10 = add i64 %vector_length, 1
  %11 = getelementptr ptr, ptr %9, i64 4
  %12 = add i64 7, %10
  %vector_length1 = load i64, ptr %11, align 4
  %13 = add i64 %vector_length1, 1
  %14 = getelementptr ptr, ptr %11, i64 5
  %15 = add i64 %12, %13
  %vector_length2 = load i64, ptr %14, align 4
  %16 = add i64 %vector_length2, 1
  %17 = getelementptr ptr, ptr %14, i64 6
  %18 = add i64 %15, %16
  %19 = getelementptr ptr, ptr %17, i64 7
  %20 = add i64 %18, 4
  %21 = add i64 8, %20
  %heap_size = add i64 %21, 2
  %22 = call ptr @vector_new(i64 %heap_size)
  %23 = getelementptr i64, ptr %4, i64 0
  %24 = load i64, ptr %23, align 4
  %encode_value_ptr = getelementptr i64, ptr %22, i64 1
  store i64 %24, ptr %encode_value_ptr, align 4
  %25 = getelementptr i64, ptr %4, i64 1
  %26 = load i64, ptr %25, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %22, i64 2
  store i64 %26, ptr %encode_value_ptr3, align 4
  %27 = getelementptr i64, ptr %4, i64 2
  %28 = load i64, ptr %27, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %22, i64 3
  store i64 %28, ptr %encode_value_ptr4, align 4
  %29 = getelementptr i64, ptr %4, i64 3
  %30 = load i64, ptr %29, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %22, i64 4
  store i64 %30, ptr %encode_value_ptr5, align 4
  %31 = getelementptr i64, ptr %5, i64 0
  %32 = load i64, ptr %31, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %22, i64 5
  store i64 %32, ptr %encode_value_ptr6, align 4
  %33 = getelementptr i64, ptr %5, i64 1
  %34 = load i64, ptr %33, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %22, i64 6
  store i64 %34, ptr %encode_value_ptr7, align 4
  %35 = getelementptr i64, ptr %5, i64 2
  %36 = load i64, ptr %35, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %22, i64 7
  store i64 %36, ptr %encode_value_ptr8, align 4
  %37 = getelementptr i64, ptr %5, i64 3
  %38 = load i64, ptr %37, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %22, i64 8
  store i64 %38, ptr %encode_value_ptr9, align 4
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %elem = load ptr, ptr %struct_member, align 8
  %39 = getelementptr i64, ptr %elem, i64 0
  %40 = load i64, ptr %39, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %22, i64 9
  store i64 %40, ptr %encode_value_ptr10, align 4
  %41 = getelementptr i64, ptr %elem, i64 1
  %42 = load i64, ptr %41, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %22, i64 10
  store i64 %42, ptr %encode_value_ptr11, align 4
  %43 = getelementptr i64, ptr %elem, i64 2
  %44 = load i64, ptr %43, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %22, i64 11
  store i64 %44, ptr %encode_value_ptr12, align 4
  %45 = getelementptr i64, ptr %elem, i64 3
  %46 = load i64, ptr %45, align 4
  %encode_value_ptr13 = getelementptr i64, ptr %22, i64 12
  store i64 %46, ptr %encode_value_ptr13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 1
  %elem15 = load i64, ptr %struct_member14, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %22, i64 13
  store i64 %elem15, ptr %encode_value_ptr16, align 4
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 2
  %elem18 = load i64, ptr %struct_member17, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %22, i64 14
  store i64 %elem18, ptr %encode_value_ptr19, align 4
  %struct_member20 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 3
  %elem21 = load i64, ptr %struct_member20, align 4
  %encode_value_ptr22 = getelementptr i64, ptr %22, i64 15
  store i64 %elem21, ptr %encode_value_ptr22, align 4
  %struct_member23 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 4
  %vector_length24 = load i64, ptr %struct_member23, align 4
  %vector_data = getelementptr i64, ptr %struct_member23, i64 1
  %47 = add i64 %vector_length24, 1
  call void @memcpy(ptr %vector_data, ptr %22, i64 %47)
  %48 = add i64 %47, 7
  %49 = add i64 %47, 16
  %struct_member25 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 5
  %vector_length26 = load i64, ptr %struct_member25, align 4
  %vector_data27 = getelementptr i64, ptr %struct_member25, i64 1
  %50 = add i64 %vector_length26, 1
  call void @memcpy(ptr %vector_data27, ptr %22, i64 %50)
  %51 = add i64 %50, %48
  %52 = add i64 %50, %49
  %struct_member28 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 6
  %vector_length29 = load i64, ptr %struct_member28, align 4
  %vector_data30 = getelementptr i64, ptr %struct_member28, i64 1
  %53 = add i64 %vector_length29, 1
  call void @memcpy(ptr %vector_data30, ptr %22, i64 %53)
  %54 = add i64 %53, %51
  %55 = add i64 %53, %52
  %struct_member31 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 7
  %elem32 = load ptr, ptr %struct_member31, align 8
  %56 = getelementptr i64, ptr %elem32, i64 0
  %57 = load i64, ptr %56, align 4
  %encode_value_ptr33 = getelementptr i64, ptr %22, i64 %55
  store i64 %57, ptr %encode_value_ptr33, align 4
  %58 = add i64 %55, 1
  %59 = getelementptr i64, ptr %elem32, i64 1
  %60 = load i64, ptr %59, align 4
  %encode_value_ptr34 = getelementptr i64, ptr %22, i64 %58
  store i64 %60, ptr %encode_value_ptr34, align 4
  %61 = add i64 %58, 1
  %62 = getelementptr i64, ptr %elem32, i64 2
  %63 = load i64, ptr %62, align 4
  %encode_value_ptr35 = getelementptr i64, ptr %22, i64 %61
  store i64 %63, ptr %encode_value_ptr35, align 4
  %64 = add i64 %61, 1
  %65 = getelementptr i64, ptr %elem32, i64 3
  %66 = load i64, ptr %65, align 4
  %encode_value_ptr36 = getelementptr i64, ptr %22, i64 %64
  store i64 %66, ptr %encode_value_ptr36, align 4
  %67 = add i64 %64, 1
  %68 = add i64 4, %54
  %69 = add i64 %68, 9
  %encode_value_ptr37 = getelementptr i64, ptr %22, i64 %69
  store i64 %21, ptr %encode_value_ptr37, align 4
  %70 = add i64 %69, 1
  %encode_value_ptr38 = getelementptr i64, ptr %22, i64 %70
  store i64 3738116221, ptr %encode_value_ptr38, align 4
  %struct_member39 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %71 = load ptr, ptr %struct_member39, align 8
  %vector_length40 = load i64, ptr %22, align 4
  %vector_data41 = getelementptr i64, ptr %22, i64 1
  %tape_size = add i64 %vector_length40, 2
  call void @set_tape_data(ptr %vector_data41, i64 %tape_size)
  call void @contract_call(ptr %71, i64 0)
  %72 = call ptr @heap_malloc(i64 1)
  call void @get_tape_data(ptr %72, i64 1)
  %return_length = load i64, ptr %72, align 4
  %heap_size42 = add i64 %return_length, 2
  %73 = call ptr @heap_malloc(i64 %heap_size42)
  store i64 %return_length, ptr %73, align 4
  %return_data_start = getelementptr i64, ptr %73, i64 1
  call void @get_tape_data(ptr %return_data_start, i64 %tape_size)
  %vector_length43 = load i64, ptr %73, align 4
  %vector_data44 = getelementptr i64, ptr %73, i64 1
  %74 = load i64, ptr %vector_data44, align 4
  %75 = getelementptr ptr, ptr %vector_data44, i64 1
  store i64 %74, ptr %magic, align 4
  %76 = call ptr @vector_new(i64 42)
  %vector_data45 = getelementptr i64, ptr %76, i64 1
  %index_access = getelementptr i64, ptr %vector_data45, i64 0
  store i64 118, ptr %index_access, align 4
  %index_access46 = getelementptr i64, ptr %vector_data45, i64 1
  store i64 97, ptr %index_access46, align 4
  %index_access47 = getelementptr i64, ptr %vector_data45, i64 2
  store i64 108, ptr %index_access47, align 4
  %index_access48 = getelementptr i64, ptr %vector_data45, i64 3
  store i64 105, ptr %index_access48, align 4
  %index_access49 = getelementptr i64, ptr %vector_data45, i64 4
  store i64 100, ptr %index_access49, align 4
  %index_access50 = getelementptr i64, ptr %vector_data45, i64 5
  store i64 97, ptr %index_access50, align 4
  %index_access51 = getelementptr i64, ptr %vector_data45, i64 6
  store i64 116, ptr %index_access51, align 4
  %index_access52 = getelementptr i64, ptr %vector_data45, i64 7
  store i64 101, ptr %index_access52, align 4
  %index_access53 = getelementptr i64, ptr %vector_data45, i64 8
  store i64 84, ptr %index_access53, align 4
  %index_access54 = getelementptr i64, ptr %vector_data45, i64 9
  store i64 114, ptr %index_access54, align 4
  %index_access55 = getelementptr i64, ptr %vector_data45, i64 10
  store i64 97, ptr %index_access55, align 4
  %index_access56 = getelementptr i64, ptr %vector_data45, i64 11
  store i64 110, ptr %index_access56, align 4
  %index_access57 = getelementptr i64, ptr %vector_data45, i64 12
  store i64 115, ptr %index_access57, align 4
  %index_access58 = getelementptr i64, ptr %vector_data45, i64 13
  store i64 97, ptr %index_access58, align 4
  %index_access59 = getelementptr i64, ptr %vector_data45, i64 14
  store i64 99, ptr %index_access59, align 4
  %index_access60 = getelementptr i64, ptr %vector_data45, i64 15
  store i64 116, ptr %index_access60, align 4
  %index_access61 = getelementptr i64, ptr %vector_data45, i64 16
  store i64 105, ptr %index_access61, align 4
  %index_access62 = getelementptr i64, ptr %vector_data45, i64 17
  store i64 111, ptr %index_access62, align 4
  %index_access63 = getelementptr i64, ptr %vector_data45, i64 18
  store i64 110, ptr %index_access63, align 4
  %index_access64 = getelementptr i64, ptr %vector_data45, i64 19
  store i64 40, ptr %index_access64, align 4
  %index_access65 = getelementptr i64, ptr %vector_data45, i64 20
  store i64 104, ptr %index_access65, align 4
  %index_access66 = getelementptr i64, ptr %vector_data45, i64 21
  store i64 97, ptr %index_access66, align 4
  %index_access67 = getelementptr i64, ptr %vector_data45, i64 22
  store i64 115, ptr %index_access67, align 4
  %index_access68 = getelementptr i64, ptr %vector_data45, i64 23
  store i64 104, ptr %index_access68, align 4
  %index_access69 = getelementptr i64, ptr %vector_data45, i64 24
  store i64 44, ptr %index_access69, align 4
  %index_access70 = getelementptr i64, ptr %vector_data45, i64 25
  store i64 104, ptr %index_access70, align 4
  %index_access71 = getelementptr i64, ptr %vector_data45, i64 26
  store i64 97, ptr %index_access71, align 4
  %index_access72 = getelementptr i64, ptr %vector_data45, i64 27
  store i64 115, ptr %index_access72, align 4
  %index_access73 = getelementptr i64, ptr %vector_data45, i64 28
  store i64 104, ptr %index_access73, align 4
  %index_access74 = getelementptr i64, ptr %vector_data45, i64 29
  store i64 44, ptr %index_access74, align 4
  %index_access75 = getelementptr i64, ptr %vector_data45, i64 30
  store i64 84, ptr %index_access75, align 4
  %index_access76 = getelementptr i64, ptr %vector_data45, i64 31
  store i64 114, ptr %index_access76, align 4
  %index_access77 = getelementptr i64, ptr %vector_data45, i64 32
  store i64 97, ptr %index_access77, align 4
  %index_access78 = getelementptr i64, ptr %vector_data45, i64 33
  store i64 110, ptr %index_access78, align 4
  %index_access79 = getelementptr i64, ptr %vector_data45, i64 34
  store i64 115, ptr %index_access79, align 4
  %index_access80 = getelementptr i64, ptr %vector_data45, i64 35
  store i64 97, ptr %index_access80, align 4
  %index_access81 = getelementptr i64, ptr %vector_data45, i64 36
  store i64 99, ptr %index_access81, align 4
  %index_access82 = getelementptr i64, ptr %vector_data45, i64 37
  store i64 116, ptr %index_access82, align 4
  %index_access83 = getelementptr i64, ptr %vector_data45, i64 38
  store i64 105, ptr %index_access83, align 4
  %index_access84 = getelementptr i64, ptr %vector_data45, i64 39
  store i64 111, ptr %index_access84, align 4
  %index_access85 = getelementptr i64, ptr %vector_data45, i64 40
  store i64 110, ptr %index_access85, align 4
  %index_access86 = getelementptr i64, ptr %vector_data45, i64 41
  store i64 41, ptr %index_access86, align 4
  %vector_length87 = load i64, ptr %76, align 4
  %vector_data88 = getelementptr i64, ptr %76, i64 1
  %77 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data88, ptr %77, i64 %vector_length87)
  store ptr %77, ptr %magics, align 8
  %78 = load ptr, ptr %magics, align 8
  %79 = call ptr @vector_new(i64 4)
  %80 = getelementptr i64, ptr %78, i64 0
  %81 = load i64, ptr %80, align 4
  %82 = getelementptr i64, ptr %79, i64 0
  store i64 %81, ptr %82, align 4
  %83 = getelementptr i64, ptr %78, i64 1
  %84 = load i64, ptr %83, align 4
  %85 = getelementptr i64, ptr %79, i64 1
  store i64 %84, ptr %85, align 4
  %86 = getelementptr i64, ptr %78, i64 2
  %87 = load i64, ptr %86, align 4
  %88 = getelementptr i64, ptr %79, i64 2
  store i64 %87, ptr %88, align 4
  %89 = getelementptr i64, ptr %78, i64 3
  %90 = load i64, ptr %89, align 4
  %91 = getelementptr i64, ptr %79, i64 3
  store i64 %90, ptr %91, align 4
  %92 = load i64, ptr %magic, align 4
  %vector_length89 = load i64, ptr %79, align 4
  %93 = sub i64 %vector_length89, 1
  %94 = sub i64 %93, 0
  call void @builtin_range_check(i64 %94)
  %vector_data90 = getelementptr i64, ptr %79, i64 1
  %index_access91 = getelementptr i64, ptr %vector_data90, i64 0
  %95 = load i64, ptr %index_access91, align 4
  %96 = icmp eq i64 %92, %95
  %97 = zext i1 %96 to i64
  call void @builtin_assert(i64 %97)
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
  %struct_ptr = getelementptr ptr, ptr %input, i64 4
  %3 = load i64, ptr %struct_ptr, align 4
  %struct_ptr1 = getelementptr ptr, ptr %struct_ptr, i64 1
  %4 = load i64, ptr %struct_ptr1, align 4
  %struct_ptr2 = getelementptr ptr, ptr %struct_ptr1, i64 1
  %5 = load i64, ptr %struct_ptr2, align 4
  %struct_ptr3 = getelementptr ptr, ptr %struct_ptr2, i64 1
  %vector_length = load i64, ptr %struct_ptr3, align 4
  %6 = add i64 %vector_length, 1
  %struct_size = add i64 7, %6
  %struct_ptr4 = getelementptr ptr, ptr %struct_ptr3, i64 %6
  %vector_length5 = load i64, ptr %struct_ptr4, align 4
  %7 = add i64 %vector_length5, 1
  %struct_size6 = add i64 %struct_size, %7
  %struct_ptr7 = getelementptr ptr, ptr %struct_ptr4, i64 %7
  %vector_length8 = load i64, ptr %struct_ptr7, align 4
  %8 = add i64 %vector_length8, 1
  %struct_size9 = add i64 %struct_size6, %8
  %struct_ptr10 = getelementptr ptr, ptr %struct_ptr7, i64 %8
  %struct_size11 = add i64 %struct_size9, 4
  %struct_ptr12 = getelementptr ptr, ptr %struct_ptr10, i64 4
  %9 = call ptr @heap_malloc(i64 14)
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 0
  store ptr %input, ptr %struct_member, align 8
  %struct_member13 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 1
  store i64 %3, ptr %struct_member13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 2
  store i64 %4, ptr %struct_member14, align 4
  %struct_member15 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 3
  store i64 %5, ptr %struct_member15, align 4
  %struct_member16 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 4
  store ptr %struct_ptr3, ptr %struct_member16, align 8
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 5
  store ptr %struct_ptr4, ptr %struct_member17, align 8
  %struct_member18 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 6
  store ptr %struct_ptr7, ptr %struct_member18, align 8
  %struct_member19 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %9, i32 0, i32 7
  store ptr %struct_ptr10, ptr %struct_member19, align 8
  %10 = getelementptr ptr, ptr %input, i64 %struct_size11
  %11 = load i64, ptr %10, align 4
  %12 = getelementptr ptr, ptr %10, i64 1
  call void @system_entrance(ptr %9, i64 %11)
  %13 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %13, align 4
  call void @set_tape_data(ptr %13, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %struct_ptr20 = getelementptr ptr, ptr %input, i64 4
  %14 = load i64, ptr %struct_ptr20, align 4
  %struct_ptr21 = getelementptr ptr, ptr %struct_ptr20, i64 1
  %15 = load i64, ptr %struct_ptr21, align 4
  %struct_ptr22 = getelementptr ptr, ptr %struct_ptr21, i64 1
  %16 = load i64, ptr %struct_ptr22, align 4
  %struct_ptr23 = getelementptr ptr, ptr %struct_ptr22, i64 1
  %vector_length24 = load i64, ptr %struct_ptr23, align 4
  %17 = add i64 %vector_length24, 1
  %struct_size25 = add i64 7, %17
  %struct_ptr26 = getelementptr ptr, ptr %struct_ptr23, i64 %17
  %vector_length27 = load i64, ptr %struct_ptr26, align 4
  %18 = add i64 %vector_length27, 1
  %struct_size28 = add i64 %struct_size25, %18
  %struct_ptr29 = getelementptr ptr, ptr %struct_ptr26, i64 %18
  %vector_length30 = load i64, ptr %struct_ptr29, align 4
  %19 = add i64 %vector_length30, 1
  %struct_size31 = add i64 %struct_size28, %19
  %struct_ptr32 = getelementptr ptr, ptr %struct_ptr29, i64 %19
  %struct_size33 = add i64 %struct_size31, 4
  %struct_ptr34 = getelementptr ptr, ptr %struct_ptr32, i64 4
  %20 = call ptr @heap_malloc(i64 14)
  %struct_member35 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 0
  store ptr %input, ptr %struct_member35, align 8
  %struct_member36 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 1
  store i64 %14, ptr %struct_member36, align 4
  %struct_member37 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 2
  store i64 %15, ptr %struct_member37, align 4
  %struct_member38 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 3
  store i64 %16, ptr %struct_member38, align 4
  %struct_member39 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 4
  store ptr %struct_ptr23, ptr %struct_member39, align 8
  %struct_member40 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 5
  store ptr %struct_ptr26, ptr %struct_member40, align 8
  %struct_member41 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 6
  store ptr %struct_ptr29, ptr %struct_member41, align 8
  %struct_member42 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %20, i32 0, i32 7
  store ptr %struct_ptr32, ptr %struct_member42, align 8
  %21 = getelementptr ptr, ptr %input, i64 %struct_size33
  call void @validateTxStructure(ptr %20)
  %22 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %22, align 4
  call void @set_tape_data(ptr %22, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %struct_ptr43 = getelementptr ptr, ptr %input, i64 4
  %23 = load i64, ptr %struct_ptr43, align 4
  %struct_ptr44 = getelementptr ptr, ptr %struct_ptr43, i64 1
  %24 = load i64, ptr %struct_ptr44, align 4
  %struct_ptr45 = getelementptr ptr, ptr %struct_ptr44, i64 1
  %25 = load i64, ptr %struct_ptr45, align 4
  %struct_ptr46 = getelementptr ptr, ptr %struct_ptr45, i64 1
  %vector_length47 = load i64, ptr %struct_ptr46, align 4
  %26 = add i64 %vector_length47, 1
  %struct_size48 = add i64 7, %26
  %struct_ptr49 = getelementptr ptr, ptr %struct_ptr46, i64 %26
  %vector_length50 = load i64, ptr %struct_ptr49, align 4
  %27 = add i64 %vector_length50, 1
  %struct_size51 = add i64 %struct_size48, %27
  %struct_ptr52 = getelementptr ptr, ptr %struct_ptr49, i64 %27
  %vector_length53 = load i64, ptr %struct_ptr52, align 4
  %28 = add i64 %vector_length53, 1
  %struct_size54 = add i64 %struct_size51, %28
  %struct_ptr55 = getelementptr ptr, ptr %struct_ptr52, i64 %28
  %struct_size56 = add i64 %struct_size54, 4
  %struct_ptr57 = getelementptr ptr, ptr %struct_ptr55, i64 4
  %29 = call ptr @heap_malloc(i64 14)
  %struct_member58 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 0
  store ptr %input, ptr %struct_member58, align 8
  %struct_member59 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 1
  store i64 %23, ptr %struct_member59, align 4
  %struct_member60 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 2
  store i64 %24, ptr %struct_member60, align 4
  %struct_member61 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 3
  store i64 %25, ptr %struct_member61, align 4
  %struct_member62 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 4
  store ptr %struct_ptr46, ptr %struct_member62, align 8
  %struct_member63 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 5
  store ptr %struct_ptr49, ptr %struct_member63, align 8
  %struct_member64 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 6
  store ptr %struct_ptr52, ptr %struct_member64, align 8
  %struct_member65 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %29, i32 0, i32 7
  store ptr %struct_ptr55, ptr %struct_member65, align 8
  %30 = getelementptr ptr, ptr %input, i64 %struct_size56
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
  %struct_ptr68 = getelementptr ptr, ptr %input, i64 4
  %36 = load i64, ptr %struct_ptr68, align 4
  %struct_ptr69 = getelementptr ptr, ptr %struct_ptr68, i64 1
  %37 = load i64, ptr %struct_ptr69, align 4
  %struct_ptr70 = getelementptr ptr, ptr %struct_ptr69, i64 1
  %38 = load i64, ptr %struct_ptr70, align 4
  %struct_ptr71 = getelementptr ptr, ptr %struct_ptr70, i64 1
  %vector_length72 = load i64, ptr %struct_ptr71, align 4
  %39 = add i64 %vector_length72, 1
  %struct_size73 = add i64 7, %39
  %struct_ptr74 = getelementptr ptr, ptr %struct_ptr71, i64 %39
  %vector_length75 = load i64, ptr %struct_ptr74, align 4
  %40 = add i64 %vector_length75, 1
  %struct_size76 = add i64 %struct_size73, %40
  %struct_ptr77 = getelementptr ptr, ptr %struct_ptr74, i64 %40
  %vector_length78 = load i64, ptr %struct_ptr77, align 4
  %41 = add i64 %vector_length78, 1
  %struct_size79 = add i64 %struct_size76, %41
  %struct_ptr80 = getelementptr ptr, ptr %struct_ptr77, i64 %41
  %struct_size81 = add i64 %struct_size79, 4
  %struct_ptr82 = getelementptr ptr, ptr %struct_ptr80, i64 4
  %42 = call ptr @heap_malloc(i64 14)
  %struct_member83 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 0
  store ptr %input, ptr %struct_member83, align 8
  %struct_member84 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 1
  store i64 %36, ptr %struct_member84, align 4
  %struct_member85 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 2
  store i64 %37, ptr %struct_member85, align 4
  %struct_member86 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 3
  store i64 %38, ptr %struct_member86, align 4
  %struct_member87 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 4
  store ptr %struct_ptr71, ptr %struct_member87, align 8
  %struct_member88 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 5
  store ptr %struct_ptr74, ptr %struct_member88, align 8
  %struct_member89 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 6
  store ptr %struct_ptr77, ptr %struct_member89, align 8
  %struct_member90 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %42, i32 0, i32 7
  store ptr %struct_ptr80, ptr %struct_member90, align 8
  %43 = getelementptr ptr, ptr %input, i64 %struct_size81
  call void @sendTx(ptr %42)
  %44 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %44, align 4
  call void @set_tape_data(ptr %44, i64 1)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %struct_ptr91 = getelementptr ptr, ptr %input, i64 4
  %45 = load i64, ptr %struct_ptr91, align 4
  %struct_ptr92 = getelementptr ptr, ptr %struct_ptr91, i64 1
  %46 = load i64, ptr %struct_ptr92, align 4
  %struct_ptr93 = getelementptr ptr, ptr %struct_ptr92, i64 1
  %47 = load i64, ptr %struct_ptr93, align 4
  %struct_ptr94 = getelementptr ptr, ptr %struct_ptr93, i64 1
  %vector_length95 = load i64, ptr %struct_ptr94, align 4
  %48 = add i64 %vector_length95, 1
  %struct_size96 = add i64 7, %48
  %struct_ptr97 = getelementptr ptr, ptr %struct_ptr94, i64 %48
  %vector_length98 = load i64, ptr %struct_ptr97, align 4
  %49 = add i64 %vector_length98, 1
  %struct_size99 = add i64 %struct_size96, %49
  %struct_ptr100 = getelementptr ptr, ptr %struct_ptr97, i64 %49
  %vector_length101 = load i64, ptr %struct_ptr100, align 4
  %50 = add i64 %vector_length101, 1
  %struct_size102 = add i64 %struct_size99, %50
  %struct_ptr103 = getelementptr ptr, ptr %struct_ptr100, i64 %50
  %struct_size104 = add i64 %struct_size102, 4
  %struct_ptr105 = getelementptr ptr, ptr %struct_ptr103, i64 4
  %51 = call ptr @heap_malloc(i64 14)
  %struct_member106 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 0
  store ptr %input, ptr %struct_member106, align 8
  %struct_member107 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 1
  store i64 %45, ptr %struct_member107, align 4
  %struct_member108 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 2
  store i64 %46, ptr %struct_member108, align 4
  %struct_member109 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 3
  store i64 %47, ptr %struct_member109, align 4
  %struct_member110 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 4
  store ptr %struct_ptr94, ptr %struct_member110, align 8
  %struct_member111 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 5
  store ptr %struct_ptr97, ptr %struct_member111, align 8
  %struct_member112 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 6
  store ptr %struct_ptr100, ptr %struct_member112, align 8
  %struct_member113 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %51, i32 0, i32 7
  store ptr %struct_ptr103, ptr %struct_member113, align 8
  %52 = getelementptr ptr, ptr %input, i64 %struct_size104
  call void @validateTx(ptr %51)
  %53 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %53, align 4
  call void @set_tape_data(ptr %53, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %struct_ptr114 = getelementptr ptr, ptr %input, i64 4
  %54 = load i64, ptr %struct_ptr114, align 4
  %struct_ptr115 = getelementptr ptr, ptr %struct_ptr114, i64 1
  %55 = load i64, ptr %struct_ptr115, align 4
  %struct_ptr116 = getelementptr ptr, ptr %struct_ptr115, i64 1
  %56 = load i64, ptr %struct_ptr116, align 4
  %struct_ptr117 = getelementptr ptr, ptr %struct_ptr116, i64 1
  %vector_length118 = load i64, ptr %struct_ptr117, align 4
  %57 = add i64 %vector_length118, 1
  %struct_size119 = add i64 7, %57
  %struct_ptr120 = getelementptr ptr, ptr %struct_ptr117, i64 %57
  %vector_length121 = load i64, ptr %struct_ptr120, align 4
  %58 = add i64 %vector_length121, 1
  %struct_size122 = add i64 %struct_size119, %58
  %struct_ptr123 = getelementptr ptr, ptr %struct_ptr120, i64 %58
  %vector_length124 = load i64, ptr %struct_ptr123, align 4
  %59 = add i64 %vector_length124, 1
  %struct_size125 = add i64 %struct_size122, %59
  %struct_ptr126 = getelementptr ptr, ptr %struct_ptr123, i64 %59
  %struct_size127 = add i64 %struct_size125, 4
  %struct_ptr128 = getelementptr ptr, ptr %struct_ptr126, i64 4
  %60 = call ptr @heap_malloc(i64 14)
  %struct_member129 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 0
  store ptr %input, ptr %struct_member129, align 8
  %struct_member130 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 1
  store i64 %54, ptr %struct_member130, align 4
  %struct_member131 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 2
  store i64 %55, ptr %struct_member131, align 4
  %struct_member132 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 3
  store i64 %56, ptr %struct_member132, align 4
  %struct_member133 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 4
  store ptr %struct_ptr117, ptr %struct_member133, align 8
  %struct_member134 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 5
  store ptr %struct_ptr120, ptr %struct_member134, align 8
  %struct_member135 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 6
  store ptr %struct_ptr123, ptr %struct_member135, align 8
  %struct_member136 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %60, i32 0, i32 7
  store ptr %struct_ptr126, ptr %struct_member136, align 8
  %61 = getelementptr ptr, ptr %input, i64 %struct_size127
  call void @validateDeployment(ptr %60)
  %62 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %62, align 4
  call void @set_tape_data(ptr %62, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %struct_ptr137 = getelementptr ptr, ptr %input, i64 4
  %63 = load i64, ptr %struct_ptr137, align 4
  %struct_ptr138 = getelementptr ptr, ptr %struct_ptr137, i64 1
  %64 = load i64, ptr %struct_ptr138, align 4
  %struct_ptr139 = getelementptr ptr, ptr %struct_ptr138, i64 1
  %65 = load i64, ptr %struct_ptr139, align 4
  %struct_ptr140 = getelementptr ptr, ptr %struct_ptr139, i64 1
  %vector_length141 = load i64, ptr %struct_ptr140, align 4
  %66 = add i64 %vector_length141, 1
  %struct_size142 = add i64 7, %66
  %struct_ptr143 = getelementptr ptr, ptr %struct_ptr140, i64 %66
  %vector_length144 = load i64, ptr %struct_ptr143, align 4
  %67 = add i64 %vector_length144, 1
  %struct_size145 = add i64 %struct_size142, %67
  %struct_ptr146 = getelementptr ptr, ptr %struct_ptr143, i64 %67
  %vector_length147 = load i64, ptr %struct_ptr146, align 4
  %68 = add i64 %vector_length147, 1
  %struct_size148 = add i64 %struct_size145, %68
  %struct_ptr149 = getelementptr ptr, ptr %struct_ptr146, i64 %68
  %struct_size150 = add i64 %struct_size148, 4
  %struct_ptr151 = getelementptr ptr, ptr %struct_ptr149, i64 4
  %69 = call ptr @heap_malloc(i64 14)
  %struct_member152 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 0
  store ptr %input, ptr %struct_member152, align 8
  %struct_member153 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 1
  store i64 %63, ptr %struct_member153, align 4
  %struct_member154 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 2
  store i64 %64, ptr %struct_member154, align 4
  %struct_member155 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 3
  store i64 %65, ptr %struct_member155, align 4
  %struct_member156 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 4
  store ptr %struct_ptr140, ptr %struct_member156, align 8
  %struct_member157 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 5
  store ptr %struct_ptr143, ptr %struct_member157, align 8
  %struct_member158 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 6
  store ptr %struct_ptr146, ptr %struct_member158, align 8
  %struct_member159 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %69, i32 0, i32 7
  store ptr %struct_ptr149, ptr %struct_member159, align 8
  %70 = getelementptr ptr, ptr %input, i64 %struct_size150
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
  %struct_ptr171 = getelementptr ptr, ptr %101, i64 4
  %102 = load i64, ptr %struct_ptr171, align 4
  %struct_ptr172 = getelementptr ptr, ptr %struct_ptr171, i64 1
  %103 = load i64, ptr %struct_ptr172, align 4
  %struct_ptr173 = getelementptr ptr, ptr %struct_ptr172, i64 1
  %104 = load i64, ptr %struct_ptr173, align 4
  %struct_ptr174 = getelementptr ptr, ptr %struct_ptr173, i64 1
  %vector_length175 = load i64, ptr %struct_ptr174, align 4
  %105 = add i64 %vector_length175, 1
  %struct_size176 = add i64 7, %105
  %struct_ptr177 = getelementptr ptr, ptr %struct_ptr174, i64 %105
  %vector_length178 = load i64, ptr %struct_ptr177, align 4
  %106 = add i64 %vector_length178, 1
  %struct_size179 = add i64 %struct_size176, %106
  %struct_ptr180 = getelementptr ptr, ptr %struct_ptr177, i64 %106
  %vector_length181 = load i64, ptr %struct_ptr180, align 4
  %107 = add i64 %vector_length181, 1
  %struct_size182 = add i64 %struct_size179, %107
  %struct_ptr183 = getelementptr ptr, ptr %struct_ptr180, i64 %107
  %struct_size184 = add i64 %struct_size182, 4
  %struct_ptr185 = getelementptr ptr, ptr %struct_ptr183, i64 4
  %108 = call ptr @heap_malloc(i64 14)
  %struct_member186 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 0
  store ptr %101, ptr %struct_member186, align 8
  %struct_member187 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 1
  store i64 %102, ptr %struct_member187, align 4
  %struct_member188 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 2
  store i64 %103, ptr %struct_member188, align 4
  %struct_member189 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 3
  store i64 %104, ptr %struct_member189, align 4
  %struct_member190 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 4
  store ptr %struct_ptr174, ptr %struct_member190, align 8
  %struct_member191 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 5
  store ptr %struct_ptr177, ptr %struct_member191, align 8
  %struct_member192 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 6
  store ptr %struct_ptr180, ptr %struct_member192, align 8
  %struct_member193 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %108, i32 0, i32 7
  store ptr %struct_ptr183, ptr %struct_member193, align 8
  %109 = getelementptr ptr, ptr %101, i64 %struct_size184
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
