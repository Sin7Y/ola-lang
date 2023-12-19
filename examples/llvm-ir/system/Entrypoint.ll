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
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %2 = load ptr, ptr %struct_member, align 8
  %address_start = ptrtoint ptr %2 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %3 = load i64, ptr %struct_member1, align 4
  call void @prophet_printf(i64 %3, i64 3)
  %struct_member2 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %4 = load i64, ptr %struct_member2, align 4
  call void @prophet_printf(i64 %4, i64 3)
  %struct_member3 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %5 = load i64, ptr %struct_member3, align 4
  call void @prophet_printf(i64 %5, i64 3)
  %struct_member4 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %6 = load ptr, ptr %struct_member4, align 8
  %fields_start = ptrtoint ptr %6 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  %struct_member5 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 5
  %7 = load ptr, ptr %struct_member5, align 8
  %fields_start6 = ptrtoint ptr %7 to i64
  call void @prophet_printf(i64 %fields_start6, i64 0)
  %struct_member7 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 6
  %8 = load ptr, ptr %struct_member7, align 8
  %fields_start8 = ptrtoint ptr %8 to i64
  call void @prophet_printf(i64 %fields_start8, i64 0)
  %struct_member9 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 7
  %9 = load ptr, ptr %struct_member9, align 8
  %hash_start = ptrtoint ptr %9 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  %struct_member10 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %10 = load ptr, ptr %struct_member10, align 8
  ret ptr %10
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
  %fields_start = ptrtoint ptr %2 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  %3 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %3, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %3, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %3, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %3, i64 3
  store i64 32771, ptr %index_access3, align 4
  store ptr %3, ptr %NONCE_HOLDER_ADDRESS, align 8
  %struct_member4 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %4 = load ptr, ptr %struct_member4, align 8
  %struct_member5 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %5 = load i64, ptr %struct_member5, align 4
  %6 = call ptr @vector_new(i64 7)
  %vector_data = getelementptr i64, ptr %6, i64 1
  %7 = getelementptr i64, ptr %4, i64 0
  %8 = load i64, ptr %7, align 4
  %9 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %8, ptr %9, align 4
  %10 = getelementptr i64, ptr %4, i64 1
  %11 = load i64, ptr %10, align 4
  %12 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %11, ptr %12, align 4
  %13 = getelementptr i64, ptr %4, i64 2
  %14 = load i64, ptr %13, align 4
  %15 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %14, ptr %15, align 4
  %16 = getelementptr i64, ptr %4, i64 3
  %17 = load i64, ptr %16, align 4
  %18 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %17, ptr %18, align 4
  %19 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 %5, ptr %19, align 4
  %20 = getelementptr ptr, ptr %19, i64 1
  store i64 5, ptr %20, align 4
  %21 = getelementptr ptr, ptr %20, i64 1
  store i64 1093482716, ptr %21, align 4
  %fields_start6 = ptrtoint ptr %6 to i64
  call void @prophet_printf(i64 %fields_start6, i64 0)
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
  %hash_start = ptrtoint ptr %7 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  %8 = call ptr @heap_malloc(i64 4)
  %index_access = getelementptr i64, ptr %8, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access2 = getelementptr i64, ptr %8, i64 1
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %8, i64 2
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %8, i64 3
  store i64 32772, ptr %index_access4, align 4
  store ptr %8, ptr %KNOWN_CODES_STORAGE, align 8
  %9 = load ptr, ptr %bytecodeHash, align 8
  %10 = call ptr @vector_new(i64 6)
  %vector_data = getelementptr i64, ptr %10, i64 1
  %11 = getelementptr i64, ptr %9, i64 0
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %9, i64 1
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %15, ptr %16, align 4
  %17 = getelementptr i64, ptr %9, i64 2
  %18 = load i64, ptr %17, align 4
  %19 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %18, ptr %19, align 4
  %20 = getelementptr i64, ptr %9, i64 3
  %21 = load i64, ptr %20, align 4
  %22 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %21, ptr %22, align 4
  %23 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %23, align 4
  %24 = getelementptr ptr, ptr %23, i64 1
  store i64 4199620571, ptr %24, align 4
  %fields_start = ptrtoint ptr %10 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  %25 = call ptr @heap_malloc(i64 4)
  %index_access5 = getelementptr i64, ptr %25, i64 0
  store i64 0, ptr %index_access5, align 4
  %index_access6 = getelementptr i64, ptr %25, i64 1
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %25, i64 2
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %25, i64 3
  store i64 32773, ptr %index_access8, align 4
  store ptr %25, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %struct_member9 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %26 = load ptr, ptr %struct_member9, align 8
  %vector_length10 = load i64, ptr %26, align 4
  %array_len_sub_one = sub i64 %vector_length10, 1
  %27 = sub i64 %array_len_sub_one, 0
  call void @builtin_range_check(i64 %27)
  %28 = sub i64 %vector_length10, 4
  call void @builtin_range_check(i64 %28)
  %29 = call ptr @vector_new(i64 4)
  %vector_data11 = getelementptr i64, ptr %29, i64 1
  %vector_data12 = getelementptr i64, ptr %26, i64 1
  %src_data_start = getelementptr i64, ptr %vector_data12, i64 0
  call void @memcpy(ptr %src_data_start, ptr %vector_data11, i64 4)
  %vector_length13 = load i64, ptr %29, align 4
  %vector_data14 = getelementptr i64, ptr %29, i64 1
  %30 = getelementptr ptr, ptr %vector_data14, i64 0
  store ptr %30, ptr %to, align 8
  %31 = load ptr, ptr %to, align 8
  %address_start = ptrtoint ptr %31 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  br label %endif

endif:                                            ; preds = %then, %entry
  ret void
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
  %hash_start = ptrtoint ptr %4 to i64
  call void @prophet_printf(i64 %hash_start, i64 2)
  %5 = load ptr, ptr %TRANSACTION_TYPE_HASH, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %6 = load ptr, ptr %struct_member, align 8
  %struct_member110 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %7 = load i64, ptr %struct_member110, align 4
  %struct_member111 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %8 = load i64, ptr %struct_member111, align 4
  %struct_member112 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %9 = load i64, ptr %struct_member112, align 4
  %struct_member113 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %10 = load ptr, ptr %struct_member113, align 8
  %vector_length114 = load i64, ptr %10, align 4
  %vector_data115 = getelementptr i64, ptr %10, i64 1
  %11 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data115, ptr %11, i64 %vector_length114)
  %struct_member116 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 5
  %12 = load ptr, ptr %struct_member116, align 8
  %vector_length117 = load i64, ptr %12, align 4
  %vector_data118 = getelementptr i64, ptr %12, i64 1
  %13 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data118, ptr %13, i64 %vector_length117)
  %14 = call ptr @vector_new(i64 19)
  %15 = getelementptr ptr, ptr %14, i64 1
  %16 = getelementptr i64, ptr %5, i64 0
  %17 = load i64, ptr %16, align 4
  %18 = getelementptr i64, ptr %15, i64 0
  store i64 %17, ptr %18, align 4
  %19 = getelementptr i64, ptr %5, i64 1
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %15, i64 1
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %5, i64 2
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %15, i64 2
  store i64 %23, ptr %24, align 4
  %25 = getelementptr i64, ptr %5, i64 3
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %15, i64 3
  store i64 %26, ptr %27, align 4
  %28 = getelementptr ptr, ptr %15, i64 4
  %29 = getelementptr i64, ptr %6, i64 0
  %30 = load i64, ptr %29, align 4
  %31 = getelementptr i64, ptr %28, i64 0
  store i64 %30, ptr %31, align 4
  %32 = getelementptr i64, ptr %6, i64 1
  %33 = load i64, ptr %32, align 4
  %34 = getelementptr i64, ptr %28, i64 1
  store i64 %33, ptr %34, align 4
  %35 = getelementptr i64, ptr %6, i64 2
  %36 = load i64, ptr %35, align 4
  %37 = getelementptr i64, ptr %28, i64 2
  store i64 %36, ptr %37, align 4
  %38 = getelementptr i64, ptr %6, i64 3
  %39 = load i64, ptr %38, align 4
  %40 = getelementptr i64, ptr %28, i64 3
  store i64 %39, ptr %40, align 4
  %41 = getelementptr ptr, ptr %28, i64 4
  store i64 %7, ptr %41, align 4
  %42 = getelementptr ptr, ptr %41, i64 1
  store i64 %8, ptr %42, align 4
  %43 = getelementptr ptr, ptr %42, i64 1
  store i64 %9, ptr %43, align 4
  %44 = getelementptr ptr, ptr %43, i64 1
  %45 = getelementptr i64, ptr %11, i64 0
  %46 = load i64, ptr %45, align 4
  %47 = getelementptr i64, ptr %44, i64 0
  store i64 %46, ptr %47, align 4
  %48 = getelementptr i64, ptr %11, i64 1
  %49 = load i64, ptr %48, align 4
  %50 = getelementptr i64, ptr %44, i64 1
  store i64 %49, ptr %50, align 4
  %51 = getelementptr i64, ptr %11, i64 2
  %52 = load i64, ptr %51, align 4
  %53 = getelementptr i64, ptr %44, i64 2
  store i64 %52, ptr %53, align 4
  %54 = getelementptr i64, ptr %11, i64 3
  %55 = load i64, ptr %54, align 4
  %56 = getelementptr i64, ptr %44, i64 3
  store i64 %55, ptr %56, align 4
  %57 = getelementptr ptr, ptr %44, i64 4
  %58 = getelementptr i64, ptr %13, i64 0
  %59 = load i64, ptr %58, align 4
  %60 = getelementptr i64, ptr %57, i64 0
  store i64 %59, ptr %60, align 4
  %61 = getelementptr i64, ptr %13, i64 1
  %62 = load i64, ptr %61, align 4
  %63 = getelementptr i64, ptr %57, i64 1
  store i64 %62, ptr %63, align 4
  %64 = getelementptr i64, ptr %13, i64 2
  %65 = load i64, ptr %64, align 4
  %66 = getelementptr i64, ptr %57, i64 2
  store i64 %65, ptr %66, align 4
  %67 = getelementptr i64, ptr %13, i64 3
  %68 = load i64, ptr %67, align 4
  %69 = getelementptr i64, ptr %57, i64 3
  store i64 %68, ptr %69, align 4
  %fields_start = ptrtoint ptr %14 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  %vector_length119 = load i64, ptr %14, align 4
  %vector_data120 = getelementptr i64, ptr %14, i64 1
  %70 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data120, ptr %70, i64 %vector_length119)
  store ptr %70, ptr %structHash, align 8
  %71 = load ptr, ptr %structHash, align 8
  %hash_start121 = ptrtoint ptr %71 to i64
  call void @prophet_printf(i64 %hash_start121, i64 2)
  %72 = call ptr @vector_new(i64 52)
  %vector_data122 = getelementptr i64, ptr %72, i64 1
  %index_access123 = getelementptr i64, ptr %vector_data122, i64 0
  store i64 69, ptr %index_access123, align 4
  %index_access124 = getelementptr i64, ptr %vector_data122, i64 1
  store i64 73, ptr %index_access124, align 4
  %index_access125 = getelementptr i64, ptr %vector_data122, i64 2
  store i64 80, ptr %index_access125, align 4
  %index_access126 = getelementptr i64, ptr %vector_data122, i64 3
  store i64 55, ptr %index_access126, align 4
  %index_access127 = getelementptr i64, ptr %vector_data122, i64 4
  store i64 49, ptr %index_access127, align 4
  %index_access128 = getelementptr i64, ptr %vector_data122, i64 5
  store i64 50, ptr %index_access128, align 4
  %index_access129 = getelementptr i64, ptr %vector_data122, i64 6
  store i64 68, ptr %index_access129, align 4
  %index_access130 = getelementptr i64, ptr %vector_data122, i64 7
  store i64 111, ptr %index_access130, align 4
  %index_access131 = getelementptr i64, ptr %vector_data122, i64 8
  store i64 109, ptr %index_access131, align 4
  %index_access132 = getelementptr i64, ptr %vector_data122, i64 9
  store i64 97, ptr %index_access132, align 4
  %index_access133 = getelementptr i64, ptr %vector_data122, i64 10
  store i64 105, ptr %index_access133, align 4
  %index_access134 = getelementptr i64, ptr %vector_data122, i64 11
  store i64 110, ptr %index_access134, align 4
  %index_access135 = getelementptr i64, ptr %vector_data122, i64 12
  store i64 40, ptr %index_access135, align 4
  %index_access136 = getelementptr i64, ptr %vector_data122, i64 13
  store i64 115, ptr %index_access136, align 4
  %index_access137 = getelementptr i64, ptr %vector_data122, i64 14
  store i64 116, ptr %index_access137, align 4
  %index_access138 = getelementptr i64, ptr %vector_data122, i64 15
  store i64 114, ptr %index_access138, align 4
  %index_access139 = getelementptr i64, ptr %vector_data122, i64 16
  store i64 105, ptr %index_access139, align 4
  %index_access140 = getelementptr i64, ptr %vector_data122, i64 17
  store i64 110, ptr %index_access140, align 4
  %index_access141 = getelementptr i64, ptr %vector_data122, i64 18
  store i64 103, ptr %index_access141, align 4
  %index_access142 = getelementptr i64, ptr %vector_data122, i64 19
  store i64 32, ptr %index_access142, align 4
  %index_access143 = getelementptr i64, ptr %vector_data122, i64 20
  store i64 110, ptr %index_access143, align 4
  %index_access144 = getelementptr i64, ptr %vector_data122, i64 21
  store i64 97, ptr %index_access144, align 4
  %index_access145 = getelementptr i64, ptr %vector_data122, i64 22
  store i64 109, ptr %index_access145, align 4
  %index_access146 = getelementptr i64, ptr %vector_data122, i64 23
  store i64 101, ptr %index_access146, align 4
  %index_access147 = getelementptr i64, ptr %vector_data122, i64 24
  store i64 44, ptr %index_access147, align 4
  %index_access148 = getelementptr i64, ptr %vector_data122, i64 25
  store i64 115, ptr %index_access148, align 4
  %index_access149 = getelementptr i64, ptr %vector_data122, i64 26
  store i64 116, ptr %index_access149, align 4
  %index_access150 = getelementptr i64, ptr %vector_data122, i64 27
  store i64 114, ptr %index_access150, align 4
  %index_access151 = getelementptr i64, ptr %vector_data122, i64 28
  store i64 105, ptr %index_access151, align 4
  %index_access152 = getelementptr i64, ptr %vector_data122, i64 29
  store i64 110, ptr %index_access152, align 4
  %index_access153 = getelementptr i64, ptr %vector_data122, i64 30
  store i64 103, ptr %index_access153, align 4
  %index_access154 = getelementptr i64, ptr %vector_data122, i64 31
  store i64 32, ptr %index_access154, align 4
  %index_access155 = getelementptr i64, ptr %vector_data122, i64 32
  store i64 118, ptr %index_access155, align 4
  %index_access156 = getelementptr i64, ptr %vector_data122, i64 33
  store i64 101, ptr %index_access156, align 4
  %index_access157 = getelementptr i64, ptr %vector_data122, i64 34
  store i64 114, ptr %index_access157, align 4
  %index_access158 = getelementptr i64, ptr %vector_data122, i64 35
  store i64 115, ptr %index_access158, align 4
  %index_access159 = getelementptr i64, ptr %vector_data122, i64 36
  store i64 105, ptr %index_access159, align 4
  %index_access160 = getelementptr i64, ptr %vector_data122, i64 37
  store i64 111, ptr %index_access160, align 4
  %index_access161 = getelementptr i64, ptr %vector_data122, i64 38
  store i64 110, ptr %index_access161, align 4
  %index_access162 = getelementptr i64, ptr %vector_data122, i64 39
  store i64 44, ptr %index_access162, align 4
  %index_access163 = getelementptr i64, ptr %vector_data122, i64 40
  store i64 117, ptr %index_access163, align 4
  %index_access164 = getelementptr i64, ptr %vector_data122, i64 41
  store i64 51, ptr %index_access164, align 4
  %index_access165 = getelementptr i64, ptr %vector_data122, i64 42
  store i64 50, ptr %index_access165, align 4
  %index_access166 = getelementptr i64, ptr %vector_data122, i64 43
  store i64 32, ptr %index_access166, align 4
  %index_access167 = getelementptr i64, ptr %vector_data122, i64 44
  store i64 99, ptr %index_access167, align 4
  %index_access168 = getelementptr i64, ptr %vector_data122, i64 45
  store i64 104, ptr %index_access168, align 4
  %index_access169 = getelementptr i64, ptr %vector_data122, i64 46
  store i64 97, ptr %index_access169, align 4
  %index_access170 = getelementptr i64, ptr %vector_data122, i64 47
  store i64 105, ptr %index_access170, align 4
  %index_access171 = getelementptr i64, ptr %vector_data122, i64 48
  store i64 110, ptr %index_access171, align 4
  %index_access172 = getelementptr i64, ptr %vector_data122, i64 49
  store i64 73, ptr %index_access172, align 4
  %index_access173 = getelementptr i64, ptr %vector_data122, i64 50
  store i64 100, ptr %index_access173, align 4
  %index_access174 = getelementptr i64, ptr %vector_data122, i64 51
  store i64 41, ptr %index_access174, align 4
  %vector_length175 = load i64, ptr %72, align 4
  %vector_data176 = getelementptr i64, ptr %72, i64 1
  %73 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data176, ptr %73, i64 %vector_length175)
  store ptr %73, ptr %EIP712_DOMAIN_TYPEHASH, align 8
  %74 = load ptr, ptr %EIP712_DOMAIN_TYPEHASH, align 8
  %hash_start177 = ptrtoint ptr %74 to i64
  call void @prophet_printf(i64 %hash_start177, i64 2)
  %75 = load ptr, ptr %EIP712_DOMAIN_TYPEHASH, align 8
  %76 = call ptr @vector_new(i64 3)
  %vector_data178 = getelementptr i64, ptr %76, i64 1
  %index_access179 = getelementptr i64, ptr %vector_data178, i64 0
  store i64 79, ptr %index_access179, align 4
  %index_access180 = getelementptr i64, ptr %vector_data178, i64 1
  store i64 108, ptr %index_access180, align 4
  %index_access181 = getelementptr i64, ptr %vector_data178, i64 2
  store i64 97, ptr %index_access181, align 4
  %vector_length182 = load i64, ptr %76, align 4
  %vector_data183 = getelementptr i64, ptr %76, i64 1
  %77 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data183, ptr %77, i64 %vector_length182)
  %78 = call ptr @vector_new(i64 1)
  %vector_data184 = getelementptr i64, ptr %78, i64 1
  %index_access185 = getelementptr i64, ptr %vector_data184, i64 0
  store i64 49, ptr %index_access185, align 4
  %vector_length186 = load i64, ptr %78, align 4
  %vector_data187 = getelementptr i64, ptr %78, i64 1
  %79 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data187, ptr %79, i64 %vector_length186)
  %80 = call ptr @heap_malloc(i64 1)
  call void @get_context_data(ptr %80, i64 7)
  %81 = load i64, ptr %80, align 4
  %82 = call ptr @vector_new(i64 13)
  %83 = getelementptr ptr, ptr %82, i64 1
  %84 = getelementptr i64, ptr %75, i64 0
  %85 = load i64, ptr %84, align 4
  %86 = getelementptr i64, ptr %83, i64 0
  store i64 %85, ptr %86, align 4
  %87 = getelementptr i64, ptr %75, i64 1
  %88 = load i64, ptr %87, align 4
  %89 = getelementptr i64, ptr %83, i64 1
  store i64 %88, ptr %89, align 4
  %90 = getelementptr i64, ptr %75, i64 2
  %91 = load i64, ptr %90, align 4
  %92 = getelementptr i64, ptr %83, i64 2
  store i64 %91, ptr %92, align 4
  %93 = getelementptr i64, ptr %75, i64 3
  %94 = load i64, ptr %93, align 4
  %95 = getelementptr i64, ptr %83, i64 3
  store i64 %94, ptr %95, align 4
  %96 = getelementptr ptr, ptr %83, i64 4
  %97 = getelementptr i64, ptr %77, i64 0
  %98 = load i64, ptr %97, align 4
  %99 = getelementptr i64, ptr %96, i64 0
  store i64 %98, ptr %99, align 4
  %100 = getelementptr i64, ptr %77, i64 1
  %101 = load i64, ptr %100, align 4
  %102 = getelementptr i64, ptr %96, i64 1
  store i64 %101, ptr %102, align 4
  %103 = getelementptr i64, ptr %77, i64 2
  %104 = load i64, ptr %103, align 4
  %105 = getelementptr i64, ptr %96, i64 2
  store i64 %104, ptr %105, align 4
  %106 = getelementptr i64, ptr %77, i64 3
  %107 = load i64, ptr %106, align 4
  %108 = getelementptr i64, ptr %96, i64 3
  store i64 %107, ptr %108, align 4
  %109 = getelementptr ptr, ptr %96, i64 4
  %110 = getelementptr i64, ptr %79, i64 0
  %111 = load i64, ptr %110, align 4
  %112 = getelementptr i64, ptr %109, i64 0
  store i64 %111, ptr %112, align 4
  %113 = getelementptr i64, ptr %79, i64 1
  %114 = load i64, ptr %113, align 4
  %115 = getelementptr i64, ptr %109, i64 1
  store i64 %114, ptr %115, align 4
  %116 = getelementptr i64, ptr %79, i64 2
  %117 = load i64, ptr %116, align 4
  %118 = getelementptr i64, ptr %109, i64 2
  store i64 %117, ptr %118, align 4
  %119 = getelementptr i64, ptr %79, i64 3
  %120 = load i64, ptr %119, align 4
  %121 = getelementptr i64, ptr %109, i64 3
  store i64 %120, ptr %121, align 4
  %122 = getelementptr ptr, ptr %109, i64 4
  store i64 %81, ptr %122, align 4
  %vector_length188 = load i64, ptr %82, align 4
  %vector_data189 = getelementptr i64, ptr %82, i64 1
  %123 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data189, ptr %123, i64 %vector_length188)
  store ptr %123, ptr %domainSeparator, align 8
  %124 = load ptr, ptr %domainSeparator, align 8
  %hash_start190 = ptrtoint ptr %124 to i64
  call void @prophet_printf(i64 %hash_start190, i64 2)
  %125 = call ptr @vector_new(i64 2)
  %vector_data191 = getelementptr i64, ptr %125, i64 1
  %index_access192 = getelementptr i64, ptr %vector_data191, i64 0
  store i64 25, ptr %index_access192, align 4
  %index_access193 = getelementptr i64, ptr %vector_data191, i64 1
  store i64 1, ptr %index_access193, align 4
  %126 = load ptr, ptr %domainSeparator, align 8
  %127 = load ptr, ptr %structHash, align 8
  %vector_length194 = load i64, ptr %125, align 4
  %128 = add i64 %vector_length194, 1
  %129 = add i64 %128, 4
  %130 = add i64 %129, 4
  %131 = call ptr @vector_new(i64 %130)
  %132 = getelementptr ptr, ptr %131, i64 1
  %vector_length195 = load i64, ptr %125, align 4
  %133 = add i64 %vector_length195, 1
  call void @memcpy(ptr %125, ptr %132, i64 %133)
  %134 = getelementptr ptr, ptr %132, i64 %133
  %135 = getelementptr i64, ptr %126, i64 0
  %136 = load i64, ptr %135, align 4
  %137 = getelementptr i64, ptr %134, i64 0
  store i64 %136, ptr %137, align 4
  %138 = getelementptr i64, ptr %126, i64 1
  %139 = load i64, ptr %138, align 4
  %140 = getelementptr i64, ptr %134, i64 1
  store i64 %139, ptr %140, align 4
  %141 = getelementptr i64, ptr %126, i64 2
  %142 = load i64, ptr %141, align 4
  %143 = getelementptr i64, ptr %134, i64 2
  store i64 %142, ptr %143, align 4
  %144 = getelementptr i64, ptr %126, i64 3
  %145 = load i64, ptr %144, align 4
  %146 = getelementptr i64, ptr %134, i64 3
  store i64 %145, ptr %146, align 4
  %147 = getelementptr ptr, ptr %134, i64 4
  %148 = getelementptr i64, ptr %127, i64 0
  %149 = load i64, ptr %148, align 4
  %150 = getelementptr i64, ptr %147, i64 0
  store i64 %149, ptr %150, align 4
  %151 = getelementptr i64, ptr %127, i64 1
  %152 = load i64, ptr %151, align 4
  %153 = getelementptr i64, ptr %147, i64 1
  store i64 %152, ptr %153, align 4
  %154 = getelementptr i64, ptr %127, i64 2
  %155 = load i64, ptr %154, align 4
  %156 = getelementptr i64, ptr %147, i64 2
  store i64 %155, ptr %156, align 4
  %157 = getelementptr i64, ptr %127, i64 3
  %158 = load i64, ptr %157, align 4
  %159 = getelementptr i64, ptr %147, i64 3
  store i64 %158, ptr %159, align 4
  %vector_length196 = load i64, ptr %131, align 4
  %vector_data197 = getelementptr i64, ptr %131, i64 1
  %160 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data197, ptr %160, i64 %vector_length196)
  store ptr %160, ptr %signedHash, align 8
  %161 = load ptr, ptr %signedHash, align 8
  %hash_start198 = ptrtoint ptr %161 to i64
  call void @prophet_printf(i64 %hash_start198, i64 2)
  %162 = load ptr, ptr %signedHash, align 8
  ret ptr %162
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
  %vector_data = getelementptr i64, ptr %4, i64 1
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %7 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %6, ptr %7, align 4
  %8 = getelementptr i64, ptr %3, i64 1
  %9 = load i64, ptr %8, align 4
  %10 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %9, ptr %10, align 4
  %11 = getelementptr i64, ptr %3, i64 2
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %3, i64 3
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %15, ptr %16, align 4
  %vector_length = load i64, ptr %2, align 4
  %vector_data1 = getelementptr i64, ptr %2, i64 1
  %17 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data1, ptr %17, i64 %vector_length)
  %18 = call ptr @vector_new(i64 4)
  %vector_data2 = getelementptr i64, ptr %18, i64 1
  %19 = getelementptr i64, ptr %17, i64 0
  %20 = load i64, ptr %19, align 4
  %21 = getelementptr i64, ptr %vector_data2, i64 0
  store i64 %20, ptr %21, align 4
  %22 = getelementptr i64, ptr %17, i64 1
  %23 = load i64, ptr %22, align 4
  %24 = getelementptr i64, ptr %vector_data2, i64 1
  store i64 %23, ptr %24, align 4
  %25 = getelementptr i64, ptr %17, i64 2
  %26 = load i64, ptr %25, align 4
  %27 = getelementptr i64, ptr %vector_data2, i64 2
  store i64 %26, ptr %27, align 4
  %28 = getelementptr i64, ptr %17, i64 3
  %29 = load i64, ptr %28, align 4
  %30 = getelementptr i64, ptr %vector_data2, i64 3
  store i64 %29, ptr %30, align 4
  %31 = call ptr @fields_concat(ptr %4, ptr %18)
  %vector_length3 = load i64, ptr %31, align 4
  %vector_data4 = getelementptr i64, ptr %31, i64 1
  %32 = call ptr @heap_malloc(i64 4)
  call void @poseidon_hash(ptr %vector_data4, ptr %32, i64 %vector_length3)
  store ptr %32, ptr %txHash, align 8
  %33 = load ptr, ptr %txHash, align 8
  ret ptr %33
}

define void @validate_sender(ptr %0) {
entry:
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
  %vector_data = getelementptr i64, ptr %3, i64 1
  %4 = getelementptr i64, ptr %2, i64 0
  %5 = load i64, ptr %4, align 4
  %6 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %5, ptr %6, align 4
  %7 = getelementptr i64, ptr %2, i64 1
  %8 = load i64, ptr %7, align 4
  %9 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %8, ptr %9, align 4
  %10 = getelementptr i64, ptr %2, i64 2
  %11 = load i64, ptr %10, align 4
  %12 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %11, ptr %12, align 4
  %13 = getelementptr i64, ptr %2, i64 3
  %14 = load i64, ptr %13, align 4
  %15 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %14, ptr %15, align 4
  %16 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 4, ptr %16, align 4
  %17 = getelementptr ptr, ptr %16, i64 1
  store i64 3138377232, ptr %17, align 4
  %fields_start = ptrtoint ptr %3 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  ret void
}

define void @validate_nonce(ptr %0, i64 %1) {
entry:
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
  %3 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %address_start = ptrtoint ptr %3 to i64
  call void @prophet_printf(i64 %address_start, i64 2)
  %4 = load ptr, ptr %_address, align 8
  %5 = load i64, ptr %_nonce, align 4
  %6 = call ptr @vector_new(i64 7)
  %vector_data = getelementptr i64, ptr %6, i64 1
  %7 = getelementptr i64, ptr %4, i64 0
  %8 = load i64, ptr %7, align 4
  %9 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %8, ptr %9, align 4
  %10 = getelementptr i64, ptr %4, i64 1
  %11 = load i64, ptr %10, align 4
  %12 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %11, ptr %12, align 4
  %13 = getelementptr i64, ptr %4, i64 2
  %14 = load i64, ptr %13, align 4
  %15 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %14, ptr %15, align 4
  %16 = getelementptr i64, ptr %4, i64 3
  %17 = load i64, ptr %16, align 4
  %18 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %17, ptr %18, align 4
  %19 = getelementptr ptr, ptr %vector_data, i64 4
  store i64 %5, ptr %19, align 4
  %20 = getelementptr ptr, ptr %19, i64 1
  store i64 5, ptr %20, align 4
  %21 = getelementptr ptr, ptr %20, i64 1
  store i64 3775522898, ptr %21, align 4
  %fields_start = ptrtoint ptr %6 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
  ret void
}

define void @validate_tx(ptr %0, ptr %1, ptr %2) {
entry:
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
  %6 = load ptr, ptr %struct_member, align 8
  %vector_length = load i64, ptr %6, align 4
  %7 = add i64 %vector_length, 1
  %8 = add i64 7, %7
  %struct_member1 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 5
  %9 = load ptr, ptr %struct_member1, align 8
  %vector_length2 = load i64, ptr %9, align 4
  %10 = add i64 %vector_length2, 1
  %11 = add i64 %8, %10
  %struct_member3 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 6
  %12 = load ptr, ptr %struct_member3, align 8
  %vector_length4 = load i64, ptr %12, align 4
  %13 = add i64 %vector_length4, 1
  %14 = add i64 %11, %13
  %15 = add i64 %14, 4
  %16 = add i64 8, %15
  %heap_size = add i64 %16, 2
  %17 = call ptr @vector_new(i64 %heap_size)
  %vector_data = getelementptr i64, ptr %17, i64 1
  %18 = getelementptr i64, ptr %4, i64 0
  %19 = load i64, ptr %18, align 4
  %20 = getelementptr i64, ptr %vector_data, i64 0
  store i64 %19, ptr %20, align 4
  %21 = getelementptr i64, ptr %4, i64 1
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %vector_data, i64 1
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %4, i64 2
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %vector_data, i64 2
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %4, i64 3
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %vector_data, i64 3
  store i64 %28, ptr %29, align 4
  %30 = getelementptr ptr, ptr %vector_data, i64 4
  %31 = getelementptr i64, ptr %5, i64 0
  %32 = load i64, ptr %31, align 4
  %33 = getelementptr i64, ptr %30, i64 0
  store i64 %32, ptr %33, align 4
  %34 = getelementptr i64, ptr %5, i64 1
  %35 = load i64, ptr %34, align 4
  %36 = getelementptr i64, ptr %30, i64 1
  store i64 %35, ptr %36, align 4
  %37 = getelementptr i64, ptr %5, i64 2
  %38 = load i64, ptr %37, align 4
  %39 = getelementptr i64, ptr %30, i64 2
  store i64 %38, ptr %39, align 4
  %40 = getelementptr i64, ptr %5, i64 3
  %41 = load i64, ptr %40, align 4
  %42 = getelementptr i64, ptr %30, i64 3
  store i64 %41, ptr %42, align 4
  %43 = getelementptr ptr, ptr %30, i64 4
  %struct_member5 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %strcut_member = load ptr, ptr %struct_member5, align 8
  %encode_struct_field = getelementptr ptr, ptr %43, i64 0
  %44 = getelementptr i64, ptr %strcut_member, i64 0
  %45 = load i64, ptr %44, align 4
  %46 = getelementptr i64, ptr %encode_struct_field, i64 0
  store i64 %45, ptr %46, align 4
  %47 = getelementptr i64, ptr %strcut_member, i64 1
  %48 = load i64, ptr %47, align 4
  %49 = getelementptr i64, ptr %encode_struct_field, i64 1
  store i64 %48, ptr %49, align 4
  %50 = getelementptr i64, ptr %strcut_member, i64 2
  %51 = load i64, ptr %50, align 4
  %52 = getelementptr i64, ptr %encode_struct_field, i64 2
  store i64 %51, ptr %52, align 4
  %53 = getelementptr i64, ptr %strcut_member, i64 3
  %54 = load i64, ptr %53, align 4
  %55 = getelementptr i64, ptr %encode_struct_field, i64 3
  store i64 %54, ptr %55, align 4
  %struct_member6 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 1
  %strcut_member7 = load i64, ptr %struct_member6, align 4
  %encode_struct_field8 = getelementptr ptr, ptr %encode_struct_field, i64 4
  store i64 %strcut_member7, ptr %encode_struct_field8, align 4
  %struct_member9 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 2
  %strcut_member10 = load i64, ptr %struct_member9, align 4
  %encode_struct_field11 = getelementptr ptr, ptr %encode_struct_field8, i64 1
  store i64 %strcut_member10, ptr %encode_struct_field11, align 4
  %struct_member12 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 3
  %strcut_member13 = load i64, ptr %struct_member12, align 4
  %encode_struct_field14 = getelementptr ptr, ptr %encode_struct_field11, i64 1
  store i64 %strcut_member13, ptr %encode_struct_field14, align 4
  %struct_member15 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 4
  %strcut_member16 = load ptr, ptr %struct_member15, align 8
  %encode_struct_field17 = getelementptr ptr, ptr %encode_struct_field14, i64 1
  %vector_length18 = load i64, ptr %strcut_member16, align 4
  %56 = add i64 %vector_length18, 1
  call void @memcpy(ptr %strcut_member16, ptr %encode_struct_field17, i64 %56)
  %57 = add i64 %56, 7
  %struct_member19 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 5
  %strcut_member20 = load ptr, ptr %struct_member19, align 8
  %encode_struct_field21 = getelementptr ptr, ptr %encode_struct_field17, i64 %56
  %vector_length22 = load i64, ptr %strcut_member20, align 4
  %58 = add i64 %vector_length22, 1
  call void @memcpy(ptr %strcut_member20, ptr %encode_struct_field21, i64 %58)
  %59 = add i64 %58, %57
  %struct_member23 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 6
  %strcut_member24 = load ptr, ptr %struct_member23, align 8
  %encode_struct_field25 = getelementptr ptr, ptr %encode_struct_field21, i64 %58
  %vector_length26 = load i64, ptr %strcut_member24, align 4
  %60 = add i64 %vector_length26, 1
  call void @memcpy(ptr %strcut_member24, ptr %encode_struct_field25, i64 %60)
  %61 = add i64 %60, %59
  %struct_member27 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 7
  %strcut_member28 = load ptr, ptr %struct_member27, align 8
  %encode_struct_field29 = getelementptr ptr, ptr %encode_struct_field25, i64 %60
  %62 = getelementptr i64, ptr %strcut_member28, i64 0
  %63 = load i64, ptr %62, align 4
  %64 = getelementptr i64, ptr %encode_struct_field29, i64 0
  store i64 %63, ptr %64, align 4
  %65 = getelementptr i64, ptr %strcut_member28, i64 1
  %66 = load i64, ptr %65, align 4
  %67 = getelementptr i64, ptr %encode_struct_field29, i64 1
  store i64 %66, ptr %67, align 4
  %68 = getelementptr i64, ptr %strcut_member28, i64 2
  %69 = load i64, ptr %68, align 4
  %70 = getelementptr i64, ptr %encode_struct_field29, i64 2
  store i64 %69, ptr %70, align 4
  %71 = getelementptr i64, ptr %strcut_member28, i64 3
  %72 = load i64, ptr %71, align 4
  %73 = getelementptr i64, ptr %encode_struct_field29, i64 3
  store i64 %72, ptr %73, align 4
  %74 = add i64 4, %61
  %75 = getelementptr ptr, ptr %43, i64 %74
  store i64 %16, ptr %75, align 4
  %76 = getelementptr ptr, ptr %75, i64 1
  store i64 3738116221, ptr %76, align 4
  %fields_start = ptrtoint ptr %17 to i64
  call void @prophet_printf(i64 %fields_start, i64 0)
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
  %3 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field = getelementptr ptr, ptr %3, i64 0
  %decode_struct_field1 = getelementptr ptr, ptr %3, i64 4
  %4 = load i64, ptr %decode_struct_field1, align 4
  %decode_struct_field2 = getelementptr ptr, ptr %3, i64 5
  %5 = load i64, ptr %decode_struct_field2, align 4
  %decode_struct_field3 = getelementptr ptr, ptr %3, i64 6
  %6 = load i64, ptr %decode_struct_field3, align 4
  %decode_struct_field4 = getelementptr ptr, ptr %3, i64 7
  %vector_length = load i64, ptr %decode_struct_field4, align 4
  %7 = add i64 %vector_length, 1
  %decode_struct_offset = add i64 7, %7
  %decode_struct_field5 = getelementptr ptr, ptr %3, i64 %decode_struct_offset
  %vector_length6 = load i64, ptr %decode_struct_field5, align 4
  %8 = add i64 %vector_length6, 1
  %decode_struct_offset7 = add i64 %decode_struct_offset, %8
  %decode_struct_field8 = getelementptr ptr, ptr %3, i64 %decode_struct_offset7
  %vector_length9 = load i64, ptr %decode_struct_field8, align 4
  %9 = add i64 %vector_length9, 1
  %decode_struct_offset10 = add i64 %decode_struct_offset7, %9
  %decode_struct_field11 = getelementptr ptr, ptr %3, i64 %decode_struct_offset10
  %decode_struct_offset12 = add i64 %decode_struct_offset10, 4
  %10 = call ptr @heap_malloc(i64 8)
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 0
  store ptr %decode_struct_field, ptr %struct_member, align 8
  %struct_member13 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 1
  store i64 %4, ptr %struct_member13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 2
  store i64 %5, ptr %struct_member14, align 4
  %struct_member15 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 3
  store i64 %6, ptr %struct_member15, align 4
  %struct_member16 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 4
  store ptr %decode_struct_field4, ptr %struct_member16, align 8
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 5
  store ptr %decode_struct_field5, ptr %struct_member17, align 8
  %struct_member18 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 6
  store ptr %decode_struct_field8, ptr %struct_member18, align 8
  %struct_member19 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %10, i32 0, i32 7
  store ptr %decode_struct_field11, ptr %struct_member19, align 8
  %11 = getelementptr ptr, ptr %3, i64 %decode_struct_offset12
  %12 = load i64, ptr %11, align 4
  call void @system_entrance(ptr %10, i64 %12)
  %13 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %13, align 4
  call void @set_tape_data(ptr %13, i64 1)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %14 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field20 = getelementptr ptr, ptr %14, i64 0
  %decode_struct_field21 = getelementptr ptr, ptr %14, i64 4
  %15 = load i64, ptr %decode_struct_field21, align 4
  %decode_struct_field22 = getelementptr ptr, ptr %14, i64 5
  %16 = load i64, ptr %decode_struct_field22, align 4
  %decode_struct_field23 = getelementptr ptr, ptr %14, i64 6
  %17 = load i64, ptr %decode_struct_field23, align 4
  %decode_struct_field24 = getelementptr ptr, ptr %14, i64 7
  %vector_length25 = load i64, ptr %decode_struct_field24, align 4
  %18 = add i64 %vector_length25, 1
  %decode_struct_offset26 = add i64 7, %18
  %decode_struct_field27 = getelementptr ptr, ptr %14, i64 %decode_struct_offset26
  %vector_length28 = load i64, ptr %decode_struct_field27, align 4
  %19 = add i64 %vector_length28, 1
  %decode_struct_offset29 = add i64 %decode_struct_offset26, %19
  %decode_struct_field30 = getelementptr ptr, ptr %14, i64 %decode_struct_offset29
  %vector_length31 = load i64, ptr %decode_struct_field30, align 4
  %20 = add i64 %vector_length31, 1
  %decode_struct_offset32 = add i64 %decode_struct_offset29, %20
  %decode_struct_field33 = getelementptr ptr, ptr %14, i64 %decode_struct_offset32
  %decode_struct_offset34 = add i64 %decode_struct_offset32, 4
  %21 = call ptr @heap_malloc(i64 8)
  %struct_member35 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 0
  store ptr %decode_struct_field20, ptr %struct_member35, align 8
  %struct_member36 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 1
  store i64 %15, ptr %struct_member36, align 4
  %struct_member37 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 2
  store i64 %16, ptr %struct_member37, align 4
  %struct_member38 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 3
  store i64 %17, ptr %struct_member38, align 4
  %struct_member39 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 4
  store ptr %decode_struct_field24, ptr %struct_member39, align 8
  %struct_member40 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 5
  store ptr %decode_struct_field27, ptr %struct_member40, align 8
  %struct_member41 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 6
  store ptr %decode_struct_field30, ptr %struct_member41, align 8
  %struct_member42 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %21, i32 0, i32 7
  store ptr %decode_struct_field33, ptr %struct_member42, align 8
  call void @validateTxStructure(ptr %21)
  %22 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %22, align 4
  call void @set_tape_data(ptr %22, i64 1)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %23 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field43 = getelementptr ptr, ptr %23, i64 0
  %decode_struct_field44 = getelementptr ptr, ptr %23, i64 4
  %24 = load i64, ptr %decode_struct_field44, align 4
  %decode_struct_field45 = getelementptr ptr, ptr %23, i64 5
  %25 = load i64, ptr %decode_struct_field45, align 4
  %decode_struct_field46 = getelementptr ptr, ptr %23, i64 6
  %26 = load i64, ptr %decode_struct_field46, align 4
  %decode_struct_field47 = getelementptr ptr, ptr %23, i64 7
  %vector_length48 = load i64, ptr %decode_struct_field47, align 4
  %27 = add i64 %vector_length48, 1
  %decode_struct_offset49 = add i64 7, %27
  %decode_struct_field50 = getelementptr ptr, ptr %23, i64 %decode_struct_offset49
  %vector_length51 = load i64, ptr %decode_struct_field50, align 4
  %28 = add i64 %vector_length51, 1
  %decode_struct_offset52 = add i64 %decode_struct_offset49, %28
  %decode_struct_field53 = getelementptr ptr, ptr %23, i64 %decode_struct_offset52
  %vector_length54 = load i64, ptr %decode_struct_field53, align 4
  %29 = add i64 %vector_length54, 1
  %decode_struct_offset55 = add i64 %decode_struct_offset52, %29
  %decode_struct_field56 = getelementptr ptr, ptr %23, i64 %decode_struct_offset55
  %decode_struct_offset57 = add i64 %decode_struct_offset55, 4
  %30 = call ptr @heap_malloc(i64 8)
  %struct_member58 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 0
  store ptr %decode_struct_field43, ptr %struct_member58, align 8
  %struct_member59 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 1
  store i64 %24, ptr %struct_member59, align 4
  %struct_member60 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 2
  store i64 %25, ptr %struct_member60, align 4
  %struct_member61 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 3
  store i64 %26, ptr %struct_member61, align 4
  %struct_member62 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 4
  store ptr %decode_struct_field47, ptr %struct_member62, align 8
  %struct_member63 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 5
  store ptr %decode_struct_field50, ptr %struct_member63, align 8
  %struct_member64 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 6
  store ptr %decode_struct_field53, ptr %struct_member64, align 8
  %struct_member65 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %30, i32 0, i32 7
  store ptr %decode_struct_field56, ptr %struct_member65, align 8
  %31 = call ptr @callTx(ptr %30)
  %vector_length66 = load i64, ptr %31, align 4
  %32 = add i64 %vector_length66, 1
  %heap_size = add i64 %32, 1
  %33 = call ptr @heap_malloc(i64 %heap_size)
  %vector_length67 = load i64, ptr %31, align 4
  %34 = add i64 %vector_length67, 1
  call void @memcpy(ptr %31, ptr %33, i64 %34)
  %35 = getelementptr ptr, ptr %33, i64 %34
  store i64 %32, ptr %35, align 4
  call void @set_tape_data(ptr %33, i64 %heap_size)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %36 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field68 = getelementptr ptr, ptr %36, i64 0
  %decode_struct_field69 = getelementptr ptr, ptr %36, i64 4
  %37 = load i64, ptr %decode_struct_field69, align 4
  %decode_struct_field70 = getelementptr ptr, ptr %36, i64 5
  %38 = load i64, ptr %decode_struct_field70, align 4
  %decode_struct_field71 = getelementptr ptr, ptr %36, i64 6
  %39 = load i64, ptr %decode_struct_field71, align 4
  %decode_struct_field72 = getelementptr ptr, ptr %36, i64 7
  %vector_length73 = load i64, ptr %decode_struct_field72, align 4
  %40 = add i64 %vector_length73, 1
  %decode_struct_offset74 = add i64 7, %40
  %decode_struct_field75 = getelementptr ptr, ptr %36, i64 %decode_struct_offset74
  %vector_length76 = load i64, ptr %decode_struct_field75, align 4
  %41 = add i64 %vector_length76, 1
  %decode_struct_offset77 = add i64 %decode_struct_offset74, %41
  %decode_struct_field78 = getelementptr ptr, ptr %36, i64 %decode_struct_offset77
  %vector_length79 = load i64, ptr %decode_struct_field78, align 4
  %42 = add i64 %vector_length79, 1
  %decode_struct_offset80 = add i64 %decode_struct_offset77, %42
  %decode_struct_field81 = getelementptr ptr, ptr %36, i64 %decode_struct_offset80
  %decode_struct_offset82 = add i64 %decode_struct_offset80, 4
  %43 = call ptr @heap_malloc(i64 8)
  %struct_member83 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 0
  store ptr %decode_struct_field68, ptr %struct_member83, align 8
  %struct_member84 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 1
  store i64 %37, ptr %struct_member84, align 4
  %struct_member85 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 2
  store i64 %38, ptr %struct_member85, align 4
  %struct_member86 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 3
  store i64 %39, ptr %struct_member86, align 4
  %struct_member87 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 4
  store ptr %decode_struct_field72, ptr %struct_member87, align 8
  %struct_member88 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 5
  store ptr %decode_struct_field75, ptr %struct_member88, align 8
  %struct_member89 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 6
  store ptr %decode_struct_field78, ptr %struct_member89, align 8
  %struct_member90 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %43, i32 0, i32 7
  store ptr %decode_struct_field81, ptr %struct_member90, align 8
  call void @sendTx(ptr %43)
  %44 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %44, align 4
  call void @set_tape_data(ptr %44, i64 1)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %45 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field91 = getelementptr ptr, ptr %45, i64 0
  %decode_struct_field92 = getelementptr ptr, ptr %45, i64 4
  %46 = load i64, ptr %decode_struct_field92, align 4
  %decode_struct_field93 = getelementptr ptr, ptr %45, i64 5
  %47 = load i64, ptr %decode_struct_field93, align 4
  %decode_struct_field94 = getelementptr ptr, ptr %45, i64 6
  %48 = load i64, ptr %decode_struct_field94, align 4
  %decode_struct_field95 = getelementptr ptr, ptr %45, i64 7
  %vector_length96 = load i64, ptr %decode_struct_field95, align 4
  %49 = add i64 %vector_length96, 1
  %decode_struct_offset97 = add i64 7, %49
  %decode_struct_field98 = getelementptr ptr, ptr %45, i64 %decode_struct_offset97
  %vector_length99 = load i64, ptr %decode_struct_field98, align 4
  %50 = add i64 %vector_length99, 1
  %decode_struct_offset100 = add i64 %decode_struct_offset97, %50
  %decode_struct_field101 = getelementptr ptr, ptr %45, i64 %decode_struct_offset100
  %vector_length102 = load i64, ptr %decode_struct_field101, align 4
  %51 = add i64 %vector_length102, 1
  %decode_struct_offset103 = add i64 %decode_struct_offset100, %51
  %decode_struct_field104 = getelementptr ptr, ptr %45, i64 %decode_struct_offset103
  %decode_struct_offset105 = add i64 %decode_struct_offset103, 4
  %52 = call ptr @heap_malloc(i64 8)
  %struct_member106 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 0
  store ptr %decode_struct_field91, ptr %struct_member106, align 8
  %struct_member107 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 1
  store i64 %46, ptr %struct_member107, align 4
  %struct_member108 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 2
  store i64 %47, ptr %struct_member108, align 4
  %struct_member109 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 3
  store i64 %48, ptr %struct_member109, align 4
  %struct_member110 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 4
  store ptr %decode_struct_field95, ptr %struct_member110, align 8
  %struct_member111 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 5
  store ptr %decode_struct_field98, ptr %struct_member111, align 8
  %struct_member112 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 6
  store ptr %decode_struct_field101, ptr %struct_member112, align 8
  %struct_member113 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %52, i32 0, i32 7
  store ptr %decode_struct_field104, ptr %struct_member113, align 8
  call void @validateTx(ptr %52)
  %53 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %53, align 4
  call void @set_tape_data(ptr %53, i64 1)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %54 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field114 = getelementptr ptr, ptr %54, i64 0
  %decode_struct_field115 = getelementptr ptr, ptr %54, i64 4
  %55 = load i64, ptr %decode_struct_field115, align 4
  %decode_struct_field116 = getelementptr ptr, ptr %54, i64 5
  %56 = load i64, ptr %decode_struct_field116, align 4
  %decode_struct_field117 = getelementptr ptr, ptr %54, i64 6
  %57 = load i64, ptr %decode_struct_field117, align 4
  %decode_struct_field118 = getelementptr ptr, ptr %54, i64 7
  %vector_length119 = load i64, ptr %decode_struct_field118, align 4
  %58 = add i64 %vector_length119, 1
  %decode_struct_offset120 = add i64 7, %58
  %decode_struct_field121 = getelementptr ptr, ptr %54, i64 %decode_struct_offset120
  %vector_length122 = load i64, ptr %decode_struct_field121, align 4
  %59 = add i64 %vector_length122, 1
  %decode_struct_offset123 = add i64 %decode_struct_offset120, %59
  %decode_struct_field124 = getelementptr ptr, ptr %54, i64 %decode_struct_offset123
  %vector_length125 = load i64, ptr %decode_struct_field124, align 4
  %60 = add i64 %vector_length125, 1
  %decode_struct_offset126 = add i64 %decode_struct_offset123, %60
  %decode_struct_field127 = getelementptr ptr, ptr %54, i64 %decode_struct_offset126
  %decode_struct_offset128 = add i64 %decode_struct_offset126, 4
  %61 = call ptr @heap_malloc(i64 8)
  %struct_member129 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 0
  store ptr %decode_struct_field114, ptr %struct_member129, align 8
  %struct_member130 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 1
  store i64 %55, ptr %struct_member130, align 4
  %struct_member131 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 2
  store i64 %56, ptr %struct_member131, align 4
  %struct_member132 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 3
  store i64 %57, ptr %struct_member132, align 4
  %struct_member133 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 4
  store ptr %decode_struct_field118, ptr %struct_member133, align 8
  %struct_member134 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 5
  store ptr %decode_struct_field121, ptr %struct_member134, align 8
  %struct_member135 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 6
  store ptr %decode_struct_field124, ptr %struct_member135, align 8
  %struct_member136 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %61, i32 0, i32 7
  store ptr %decode_struct_field127, ptr %struct_member136, align 8
  call void @validateDeployment(ptr %61)
  %62 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %62, align 4
  call void @set_tape_data(ptr %62, i64 1)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %63 = getelementptr ptr, ptr %input, i64 0
  %decode_struct_field137 = getelementptr ptr, ptr %63, i64 0
  %decode_struct_field138 = getelementptr ptr, ptr %63, i64 4
  %64 = load i64, ptr %decode_struct_field138, align 4
  %decode_struct_field139 = getelementptr ptr, ptr %63, i64 5
  %65 = load i64, ptr %decode_struct_field139, align 4
  %decode_struct_field140 = getelementptr ptr, ptr %63, i64 6
  %66 = load i64, ptr %decode_struct_field140, align 4
  %decode_struct_field141 = getelementptr ptr, ptr %63, i64 7
  %vector_length142 = load i64, ptr %decode_struct_field141, align 4
  %67 = add i64 %vector_length142, 1
  %decode_struct_offset143 = add i64 7, %67
  %decode_struct_field144 = getelementptr ptr, ptr %63, i64 %decode_struct_offset143
  %vector_length145 = load i64, ptr %decode_struct_field144, align 4
  %68 = add i64 %vector_length145, 1
  %decode_struct_offset146 = add i64 %decode_struct_offset143, %68
  %decode_struct_field147 = getelementptr ptr, ptr %63, i64 %decode_struct_offset146
  %vector_length148 = load i64, ptr %decode_struct_field147, align 4
  %69 = add i64 %vector_length148, 1
  %decode_struct_offset149 = add i64 %decode_struct_offset146, %69
  %decode_struct_field150 = getelementptr ptr, ptr %63, i64 %decode_struct_offset149
  %decode_struct_offset151 = add i64 %decode_struct_offset149, 4
  %70 = call ptr @heap_malloc(i64 8)
  %struct_member152 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 0
  store ptr %decode_struct_field137, ptr %struct_member152, align 8
  %struct_member153 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 1
  store i64 %64, ptr %struct_member153, align 4
  %struct_member154 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 2
  store i64 %65, ptr %struct_member154, align 4
  %struct_member155 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 3
  store i64 %66, ptr %struct_member155, align 4
  %struct_member156 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 4
  store ptr %decode_struct_field141, ptr %struct_member156, align 8
  %struct_member157 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 5
  store ptr %decode_struct_field144, ptr %struct_member157, align 8
  %struct_member158 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 6
  store ptr %decode_struct_field147, ptr %struct_member158, align 8
  %struct_member159 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %70, i32 0, i32 7
  store ptr %decode_struct_field150, ptr %struct_member159, align 8
  %71 = call ptr @getSignedHash(ptr %70)
  %72 = call ptr @heap_malloc(i64 5)
  %73 = getelementptr i64, ptr %71, i64 0
  %74 = load i64, ptr %73, align 4
  %75 = getelementptr i64, ptr %72, i64 0
  store i64 %74, ptr %75, align 4
  %76 = getelementptr i64, ptr %71, i64 1
  %77 = load i64, ptr %76, align 4
  %78 = getelementptr i64, ptr %72, i64 1
  store i64 %77, ptr %78, align 4
  %79 = getelementptr i64, ptr %71, i64 2
  %80 = load i64, ptr %79, align 4
  %81 = getelementptr i64, ptr %72, i64 2
  store i64 %80, ptr %81, align 4
  %82 = getelementptr i64, ptr %71, i64 3
  %83 = load i64, ptr %82, align 4
  %84 = getelementptr i64, ptr %72, i64 3
  store i64 %83, ptr %84, align 4
  %85 = getelementptr ptr, ptr %72, i64 4
  store i64 4, ptr %85, align 4
  call void @set_tape_data(ptr %72, i64 5)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %86 = getelementptr ptr, ptr %input, i64 0
  %87 = getelementptr ptr, ptr %86, i64 4
  %vector_length160 = load i64, ptr %87, align 4
  %88 = add i64 %vector_length160, 1
  %89 = call ptr @getTransactionHash(ptr %86, ptr %87)
  %90 = call ptr @heap_malloc(i64 5)
  %91 = getelementptr i64, ptr %89, i64 0
  %92 = load i64, ptr %91, align 4
  %93 = getelementptr i64, ptr %90, i64 0
  store i64 %92, ptr %93, align 4
  %94 = getelementptr i64, ptr %89, i64 1
  %95 = load i64, ptr %94, align 4
  %96 = getelementptr i64, ptr %90, i64 1
  store i64 %95, ptr %96, align 4
  %97 = getelementptr i64, ptr %89, i64 2
  %98 = load i64, ptr %97, align 4
  %99 = getelementptr i64, ptr %90, i64 2
  store i64 %98, ptr %99, align 4
  %100 = getelementptr i64, ptr %89, i64 3
  %101 = load i64, ptr %100, align 4
  %102 = getelementptr i64, ptr %90, i64 3
  store i64 %101, ptr %102, align 4
  %103 = getelementptr ptr, ptr %90, i64 4
  store i64 4, ptr %103, align 4
  call void @set_tape_data(ptr %90, i64 5)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %104 = getelementptr ptr, ptr %input, i64 0
  call void @validate_sender(ptr %104)
  %105 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %105, align 4
  call void @set_tape_data(ptr %105, i64 1)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %106 = getelementptr ptr, ptr %input, i64 0
  %107 = getelementptr ptr, ptr %106, i64 4
  %108 = load i64, ptr %107, align 4
  call void @validate_nonce(ptr %106, i64 %108)
  %109 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %109, align 4
  call void @set_tape_data(ptr %109, i64 1)
  ret void

func_10_dispatch:                                 ; preds = %entry
  %110 = getelementptr ptr, ptr %input, i64 0
  %111 = getelementptr ptr, ptr %110, i64 4
  %112 = getelementptr ptr, ptr %111, i64 4
  %decode_struct_field161 = getelementptr ptr, ptr %112, i64 0
  %decode_struct_field162 = getelementptr ptr, ptr %112, i64 4
  %113 = load i64, ptr %decode_struct_field162, align 4
  %decode_struct_field163 = getelementptr ptr, ptr %112, i64 5
  %114 = load i64, ptr %decode_struct_field163, align 4
  %decode_struct_field164 = getelementptr ptr, ptr %112, i64 6
  %115 = load i64, ptr %decode_struct_field164, align 4
  %decode_struct_field165 = getelementptr ptr, ptr %112, i64 7
  %vector_length166 = load i64, ptr %decode_struct_field165, align 4
  %116 = add i64 %vector_length166, 1
  %decode_struct_offset167 = add i64 7, %116
  %decode_struct_field168 = getelementptr ptr, ptr %112, i64 %decode_struct_offset167
  %vector_length169 = load i64, ptr %decode_struct_field168, align 4
  %117 = add i64 %vector_length169, 1
  %decode_struct_offset170 = add i64 %decode_struct_offset167, %117
  %decode_struct_field171 = getelementptr ptr, ptr %112, i64 %decode_struct_offset170
  %vector_length172 = load i64, ptr %decode_struct_field171, align 4
  %118 = add i64 %vector_length172, 1
  %decode_struct_offset173 = add i64 %decode_struct_offset170, %118
  %decode_struct_field174 = getelementptr ptr, ptr %112, i64 %decode_struct_offset173
  %decode_struct_offset175 = add i64 %decode_struct_offset173, 4
  %119 = call ptr @heap_malloc(i64 8)
  %struct_member176 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 0
  store ptr %decode_struct_field161, ptr %struct_member176, align 8
  %struct_member177 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 1
  store i64 %113, ptr %struct_member177, align 4
  %struct_member178 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 2
  store i64 %114, ptr %struct_member178, align 4
  %struct_member179 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 3
  store i64 %115, ptr %struct_member179, align 4
  %struct_member180 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 4
  store ptr %decode_struct_field165, ptr %struct_member180, align 8
  %struct_member181 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 5
  store ptr %decode_struct_field168, ptr %struct_member181, align 8
  %struct_member182 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 6
  store ptr %decode_struct_field171, ptr %struct_member182, align 8
  %struct_member183 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %119, i32 0, i32 7
  store ptr %decode_struct_field174, ptr %struct_member183, align 8
  call void @validate_tx(ptr %110, ptr %111, ptr %119)
  %120 = call ptr @heap_malloc(i64 1)
  store i64 0, ptr %120, align 4
  call void @set_tape_data(ptr %120, i64 1)
  ret void

func_11_dispatch:                                 ; preds = %entry
  %121 = getelementptr ptr, ptr %input, i64 0
  %vector_length184 = load i64, ptr %121, align 4
  %122 = add i64 %vector_length184, 1
  %123 = call ptr @hashL2Bytecode(ptr %121)
  %124 = call ptr @heap_malloc(i64 5)
  %125 = getelementptr i64, ptr %123, i64 0
  %126 = load i64, ptr %125, align 4
  %127 = getelementptr i64, ptr %124, i64 0
  store i64 %126, ptr %127, align 4
  %128 = getelementptr i64, ptr %123, i64 1
  %129 = load i64, ptr %128, align 4
  %130 = getelementptr i64, ptr %124, i64 1
  store i64 %129, ptr %130, align 4
  %131 = getelementptr i64, ptr %123, i64 2
  %132 = load i64, ptr %131, align 4
  %133 = getelementptr i64, ptr %124, i64 2
  store i64 %132, ptr %133, align 4
  %134 = getelementptr i64, ptr %123, i64 3
  %135 = load i64, ptr %134, align 4
  %136 = getelementptr i64, ptr %124, i64 3
  store i64 %135, ptr %136, align 4
  %137 = getelementptr ptr, ptr %124, i64 4
  store i64 4, ptr %137, align 4
  call void @set_tape_data(ptr %124, i64 5)
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
