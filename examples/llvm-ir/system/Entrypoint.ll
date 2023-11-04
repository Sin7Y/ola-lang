; ModuleID = 'Entrypoint'
source_filename = "examples/source/system/Entrypoint.ola"

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

define ptr @fields_concat(ptr %0, ptr %1) {
entry:
  %length = load i64, ptr %0, align 4
  %2 = ptrtoint ptr %0 to i64
  %3 = add i64 %2, 1
  %vector_data = inttoptr i64 %3 to ptr
  %length1 = load i64, ptr %1, align 4
  %4 = ptrtoint ptr %1 to i64
  %5 = add i64 %4, 1
  %vector_data2 = inttoptr i64 %5 to ptr
  %new_len = add i64 %length, %length1
  %length_and_data = add i64 %new_len, 1
  %6 = call i64 @vector_new(i64 %length_and_data)
  %heap_start = sub i64 %6, %length_and_data
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %new_len, ptr %heap_to_ptr, align 4
  %7 = ptrtoint ptr %heap_to_ptr to i64
  %8 = add i64 %7, 1
  %vector_data3 = inttoptr i64 %8 to ptr
  call void @memcpy(ptr %vector_data, ptr %heap_to_ptr, i64 %length)
  %9 = ptrtoint ptr %vector_data3 to i64
  %10 = add i64 %9, %length
  %11 = inttoptr i64 %10 to ptr
  call void @memcpy(ptr %vector_data2, ptr %11, i64 %length1)
  ret ptr %11
}

define ptr @system_entrance(ptr %0, i64 %1) {
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
  br label %enif

else:                                             ; preds = %entry
  call void @sendTx(ptr %2)
  br label %enif

enif:                                             ; preds = %else, %then
}

define void @validateTxStructure(ptr %0) {
entry:
  %MAX_SYSTEM_CONTRACT_ADDRESS = alloca ptr, align 8
  %_tx = alloca ptr, align 8
  store ptr %0, ptr %_tx, align 8
  %1 = load ptr, ptr %_tx, align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 65535, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %3 = load ptr, ptr %struct_member, align 8
  %4 = load ptr, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %5 = call i64 @memcmp_ugt(ptr %3, ptr %4, i64 4)
  call void @builtin_assert(i64 %5)
  %struct_member4 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %6 = load i64, ptr %struct_member4, align 4
  %7 = call i64 @vector_new(i64 1)
  %heap_start5 = sub i64 %7, 1
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @get_context_data(i64 %heap_start5, i64 7)
  %8 = load i64, ptr %heap_to_ptr6, align 4
  %9 = icmp eq i64 %6, %8
  %10 = zext i1 %9 to i64
  call void @builtin_assert(i64 %10)
  %struct_member7 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %11 = load ptr, ptr %struct_member7, align 8
  %length = load i64, ptr %11, align 4
  %12 = icmp ne i64 %length, 0
  %13 = zext i1 %12 to i64
  call void @builtin_assert(i64 %13)
  %struct_member8 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 6
  %14 = load ptr, ptr %struct_member8, align 8
  %length9 = load i64, ptr %14, align 4
  %15 = icmp ne i64 %length9, 0
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
  %payload_len = load i64, ptr %2, align 4
  %tape_size = add i64 %payload_len, 2
  %4 = ptrtoint ptr %2 to i64
  %payload_start = add i64 %4, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %3, i64 0)
  %5 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %5, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 1)
  %return_length = load i64, ptr %heap_to_ptr, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size2 = add i64 %return_length, 1
  %6 = call i64 @vector_new(i64 %heap_size)
  %heap_start3 = sub i64 %6, %heap_size
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 %return_length, ptr %heap_to_ptr4, align 4
  %7 = add i64 %heap_start3, 1
  call void @get_tape_data(i64 %7, i64 %tape_size2)
  ret ptr %heap_to_ptr4
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
  %payload_len = load i64, ptr %2, align 4
  %tape_size = add i64 %payload_len, 2
  %4 = ptrtoint ptr %2 to i64
  %payload_start = add i64 %4, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %3, i64 0)
  %5 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %5, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 1)
  %return_length = load i64, ptr %heap_to_ptr, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size2 = add i64 %return_length, 1
  %6 = call i64 @vector_new(i64 %heap_size)
  %heap_start3 = sub i64 %6, %heap_size
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 %return_length, ptr %heap_to_ptr4, align 4
  %7 = add i64 %heap_start3, 1
  call void @get_tape_data(i64 %7, i64 %tape_size2)
  %8 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %8, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr6, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access7 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 32771, ptr %index_access9, align 4
  store ptr %heap_to_ptr6, ptr %NONCE_HOLDER_ADDRESS, align 8
  %struct_member10 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %9 = load ptr, ptr %struct_member10, align 8
  %struct_member11 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %10 = load i64, ptr %struct_member11, align 4
  %11 = call i64 @vector_new(i64 8)
  %heap_start12 = sub i64 %11, 8
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  store i64 7, ptr %heap_to_ptr13, align 4
  %12 = getelementptr i64, ptr %9, i64 0
  %13 = load i64, ptr %12, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 %13, ptr %encode_value_ptr, align 4
  %14 = getelementptr i64, ptr %9, i64 1
  %15 = load i64, ptr %14, align 4
  %encode_value_ptr14 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 %15, ptr %encode_value_ptr14, align 4
  %16 = getelementptr i64, ptr %9, i64 2
  %17 = load i64, ptr %16, align 4
  %encode_value_ptr15 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 %17, ptr %encode_value_ptr15, align 4
  %18 = getelementptr i64, ptr %9, i64 3
  %19 = load i64, ptr %18, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %heap_to_ptr13, i64 4
  store i64 %19, ptr %encode_value_ptr16, align 4
  %encode_value_ptr17 = getelementptr i64, ptr %heap_to_ptr13, i64 5
  store i64 %10, ptr %encode_value_ptr17, align 4
  %encode_value_ptr18 = getelementptr i64, ptr %heap_to_ptr13, i64 6
  store i64 5, ptr %encode_value_ptr18, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %heap_to_ptr13, i64 7
  store i64 1093482716, ptr %encode_value_ptr19, align 4
  %20 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %payload_len20 = load i64, ptr %heap_to_ptr13, align 4
  %tape_size21 = add i64 %payload_len20, 2
  %21 = ptrtoint ptr %heap_to_ptr13 to i64
  %payload_start22 = add i64 %21, 1
  call void @set_tape_data(i64 %payload_start22, i64 %tape_size21)
  call void @contract_call(ptr %20, i64 0)
  %22 = call i64 @vector_new(i64 1)
  %heap_start23 = sub i64 %22, 1
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  call void @get_tape_data(i64 %heap_start23, i64 1)
  %return_length25 = load i64, ptr %heap_to_ptr24, align 4
  %heap_size26 = add i64 %return_length25, 2
  %tape_size27 = add i64 %return_length25, 1
  %23 = call i64 @vector_new(i64 %heap_size26)
  %heap_start28 = sub i64 %23, %heap_size26
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 %return_length25, ptr %heap_to_ptr29, align 4
  %24 = add i64 %heap_start28, 1
  call void @get_tape_data(i64 %24, i64 %tape_size27)
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
  %length = load i64, ptr %2, align 4
  store i64 %length, ptr %code_len, align 4
  %3 = load i64, ptr %code_len, align 4
  %4 = icmp ne i64 %3, 0
  br i1 %4, label %then, label %enif

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
  %10 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %10, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access4, align 4
  %index_access5 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 32772, ptr %index_access5, align 4
  store ptr %heap_to_ptr, ptr %KNOWN_CODES_STORAGE, align 8
  %11 = load ptr, ptr %bytecodeHash, align 8
  %12 = call i64 @vector_new(i64 7)
  %heap_start6 = sub i64 %12, 7
  %heap_to_ptr7 = inttoptr i64 %heap_start6 to ptr
  store i64 6, ptr %heap_to_ptr7, align 4
  %13 = getelementptr i64, ptr %11, i64 0
  %14 = load i64, ptr %13, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr7, i64 1
  store i64 %14, ptr %encode_value_ptr, align 4
  %15 = getelementptr i64, ptr %11, i64 1
  %16 = load i64, ptr %15, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr7, i64 2
  store i64 %16, ptr %encode_value_ptr8, align 4
  %17 = getelementptr i64, ptr %11, i64 2
  %18 = load i64, ptr %17, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr7, i64 3
  store i64 %18, ptr %encode_value_ptr9, align 4
  %19 = getelementptr i64, ptr %11, i64 3
  %20 = load i64, ptr %19, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %heap_to_ptr7, i64 4
  store i64 %20, ptr %encode_value_ptr10, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %heap_to_ptr7, i64 5
  store i64 4, ptr %encode_value_ptr11, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %heap_to_ptr7, i64 6
  store i64 4199620571, ptr %encode_value_ptr12, align 4
  %21 = load ptr, ptr %KNOWN_CODES_STORAGE, align 8
  %payload_len = load i64, ptr %heap_to_ptr7, align 4
  %tape_size = add i64 %payload_len, 2
  %22 = ptrtoint ptr %heap_to_ptr7 to i64
  %payload_start = add i64 %22, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %21, i64 0)
  %23 = call i64 @vector_new(i64 1)
  %heap_start13 = sub i64 %23, 1
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  call void @get_tape_data(i64 %heap_start13, i64 1)
  %return_length = load i64, ptr %heap_to_ptr14, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size15 = add i64 %return_length, 1
  %24 = call i64 @vector_new(i64 %heap_size)
  %heap_start16 = sub i64 %24, %heap_size
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 %return_length, ptr %heap_to_ptr17, align 4
  %25 = add i64 %heap_start16, 1
  call void @get_tape_data(i64 %25, i64 %tape_size15)
  %length18 = load i64, ptr %heap_to_ptr17, align 4
  %26 = ptrtoint ptr %heap_to_ptr17 to i64
  %27 = add i64 %26, 1
  %vector_data = inttoptr i64 %27 to ptr
  %input_start = ptrtoint ptr %vector_data to i64
  %28 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %28, align 4
  store i64 %decode_value, ptr %is_codehash_known, align 4
  %29 = load i64, ptr %is_codehash_known, align 4
  %30 = icmp eq i64 %29, 0
  br i1 %30, label %then19, label %enif20

enif:                                             ; preds = %enif20, %entry
  ret void

then19:                                           ; preds = %then
  %31 = load ptr, ptr %bytecodeHash, align 8
  %32 = call i64 @vector_new(i64 7)
  %heap_start21 = sub i64 %32, 7
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  store i64 6, ptr %heap_to_ptr22, align 4
  %33 = getelementptr i64, ptr %31, i64 0
  %34 = load i64, ptr %33, align 4
  %encode_value_ptr23 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 %34, ptr %encode_value_ptr23, align 4
  %35 = getelementptr i64, ptr %31, i64 1
  %36 = load i64, ptr %35, align 4
  %encode_value_ptr24 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 %36, ptr %encode_value_ptr24, align 4
  %37 = getelementptr i64, ptr %31, i64 2
  %38 = load i64, ptr %37, align 4
  %encode_value_ptr25 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 %38, ptr %encode_value_ptr25, align 4
  %39 = getelementptr i64, ptr %31, i64 3
  %40 = load i64, ptr %39, align 4
  %encode_value_ptr26 = getelementptr i64, ptr %heap_to_ptr22, i64 4
  store i64 %40, ptr %encode_value_ptr26, align 4
  %encode_value_ptr27 = getelementptr i64, ptr %heap_to_ptr22, i64 5
  store i64 4, ptr %encode_value_ptr27, align 4
  %encode_value_ptr28 = getelementptr i64, ptr %heap_to_ptr22, i64 6
  store i64 1119715209, ptr %encode_value_ptr28, align 4
  %41 = load ptr, ptr %KNOWN_CODES_STORAGE, align 8
  %payload_len29 = load i64, ptr %heap_to_ptr22, align 4
  %tape_size30 = add i64 %payload_len29, 2
  %42 = ptrtoint ptr %heap_to_ptr22 to i64
  %payload_start31 = add i64 %42, 1
  call void @set_tape_data(i64 %payload_start31, i64 %tape_size30)
  call void @contract_call(ptr %41, i64 0)
  %43 = call i64 @vector_new(i64 1)
  %heap_start32 = sub i64 %43, 1
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  call void @get_tape_data(i64 %heap_start32, i64 1)
  %return_length34 = load i64, ptr %heap_to_ptr33, align 4
  %heap_size35 = add i64 %return_length34, 2
  %tape_size36 = add i64 %return_length34, 1
  %44 = call i64 @vector_new(i64 %heap_size35)
  %heap_start37 = sub i64 %44, %heap_size35
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  store i64 %return_length34, ptr %heap_to_ptr38, align 4
  %45 = add i64 %heap_start37, 1
  call void @get_tape_data(i64 %45, i64 %tape_size36)
  br label %enif20

enif20:                                           ; preds = %then19, %then
  %46 = call i64 @vector_new(i64 4)
  %heap_start39 = sub i64 %46, 4
  %heap_to_ptr40 = inttoptr i64 %heap_start39 to ptr
  %index_access41 = getelementptr i64, ptr %heap_to_ptr40, i64 0
  store i64 0, ptr %index_access41, align 4
  %index_access42 = getelementptr i64, ptr %heap_to_ptr40, i64 1
  store i64 0, ptr %index_access42, align 4
  %index_access43 = getelementptr i64, ptr %heap_to_ptr40, i64 2
  store i64 0, ptr %index_access43, align 4
  %index_access44 = getelementptr i64, ptr %heap_to_ptr40, i64 3
  store i64 32773, ptr %index_access44, align 4
  store ptr %heap_to_ptr40, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %struct_member45 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %47 = load ptr, ptr %struct_member45, align 8
  %length46 = load i64, ptr %47, align 4
  %array_len_sub_one = sub i64 %length46, 1
  %48 = sub i64 %array_len_sub_one, 0
  call void @builtin_range_check(i64 %48)
  %49 = sub i64 %length46, 4
  call void @builtin_range_check(i64 %49)
  %50 = call i64 @vector_new(i64 5)
  %heap_start47 = sub i64 %50, 5
  %heap_to_ptr48 = inttoptr i64 %heap_start47 to ptr
  store i64 4, ptr %heap_to_ptr48, align 4
  %51 = ptrtoint ptr %heap_to_ptr48 to i64
  %52 = add i64 %51, 1
  %vector_data49 = inttoptr i64 %52 to ptr
  %53 = ptrtoint ptr %47 to i64
  %54 = add i64 %53, 1
  %vector_data50 = inttoptr i64 %54 to ptr
  call void @memcpy(ptr %vector_data50, ptr %vector_data49, i64 4)
  %length51 = load i64, ptr %heap_to_ptr48, align 4
  %55 = ptrtoint ptr %heap_to_ptr48 to i64
  %56 = add i64 %55, 1
  %vector_data52 = inttoptr i64 %56 to ptr
  %input_start53 = ptrtoint ptr %vector_data52 to i64
  %57 = inttoptr i64 %input_start53 to ptr
  store ptr %57, ptr %to, align 8
  %58 = load ptr, ptr %to, align 8
  %59 = load ptr, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %60 = call i64 @memcmp_eq(ptr %58, ptr %59, i64 4)
  call void @builtin_assert(i64 %60)
  br label %enif
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
  %2 = call i64 @vector_new(i64 110)
  %heap_start = sub i64 %2, 110
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 109, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data = inttoptr i64 %4 to ptr
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
  %length = load i64, ptr %heap_to_ptr, align 4
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data109 = inttoptr i64 %6 to ptr
  %7 = call i64 @vector_new(i64 4)
  %heap_start110 = sub i64 %7, 4
  %heap_to_ptr111 = inttoptr i64 %heap_start110 to ptr
  call void @poseidon_hash(ptr %vector_data109, ptr %heap_to_ptr111, i64 %length)
  store ptr %heap_to_ptr111, ptr %TRANSACTION_TYPE_HASH, align 8
  %8 = load ptr, ptr %TRANSACTION_TYPE_HASH, align 8
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 0
  %9 = load ptr, ptr %struct_member, align 8
  %struct_member112 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 1
  %10 = load i64, ptr %struct_member112, align 4
  %struct_member113 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 2
  %11 = load i64, ptr %struct_member113, align 4
  %struct_member114 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 3
  %12 = load i64, ptr %struct_member114, align 4
  %struct_member115 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 4
  %13 = load ptr, ptr %struct_member115, align 8
  %length116 = load i64, ptr %13, align 4
  %14 = ptrtoint ptr %13 to i64
  %15 = add i64 %14, 1
  %vector_data117 = inttoptr i64 %15 to ptr
  %16 = call i64 @vector_new(i64 4)
  %heap_start118 = sub i64 %16, 4
  %heap_to_ptr119 = inttoptr i64 %heap_start118 to ptr
  call void @poseidon_hash(ptr %vector_data117, ptr %heap_to_ptr119, i64 %length116)
  %struct_member120 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %1, i32 0, i32 5
  %17 = load ptr, ptr %struct_member120, align 8
  %length121 = load i64, ptr %17, align 4
  %18 = ptrtoint ptr %17 to i64
  %19 = add i64 %18, 1
  %vector_data122 = inttoptr i64 %19 to ptr
  %20 = call i64 @vector_new(i64 4)
  %heap_start123 = sub i64 %20, 4
  %heap_to_ptr124 = inttoptr i64 %heap_start123 to ptr
  call void @poseidon_hash(ptr %vector_data122, ptr %heap_to_ptr124, i64 %length121)
  %21 = call i64 @vector_new(i64 20)
  %heap_start125 = sub i64 %21, 20
  %heap_to_ptr126 = inttoptr i64 %heap_start125 to ptr
  store i64 19, ptr %heap_to_ptr126, align 4
  %22 = getelementptr i64, ptr %8, i64 0
  %23 = load i64, ptr %22, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr126, i64 1
  store i64 %23, ptr %encode_value_ptr, align 4
  %24 = getelementptr i64, ptr %8, i64 1
  %25 = load i64, ptr %24, align 4
  %encode_value_ptr127 = getelementptr i64, ptr %heap_to_ptr126, i64 2
  store i64 %25, ptr %encode_value_ptr127, align 4
  %26 = getelementptr i64, ptr %8, i64 2
  %27 = load i64, ptr %26, align 4
  %encode_value_ptr128 = getelementptr i64, ptr %heap_to_ptr126, i64 3
  store i64 %27, ptr %encode_value_ptr128, align 4
  %28 = getelementptr i64, ptr %8, i64 3
  %29 = load i64, ptr %28, align 4
  %encode_value_ptr129 = getelementptr i64, ptr %heap_to_ptr126, i64 4
  store i64 %29, ptr %encode_value_ptr129, align 4
  %30 = getelementptr i64, ptr %9, i64 0
  %31 = load i64, ptr %30, align 4
  %encode_value_ptr130 = getelementptr i64, ptr %heap_to_ptr126, i64 5
  store i64 %31, ptr %encode_value_ptr130, align 4
  %32 = getelementptr i64, ptr %9, i64 1
  %33 = load i64, ptr %32, align 4
  %encode_value_ptr131 = getelementptr i64, ptr %heap_to_ptr126, i64 6
  store i64 %33, ptr %encode_value_ptr131, align 4
  %34 = getelementptr i64, ptr %9, i64 2
  %35 = load i64, ptr %34, align 4
  %encode_value_ptr132 = getelementptr i64, ptr %heap_to_ptr126, i64 7
  store i64 %35, ptr %encode_value_ptr132, align 4
  %36 = getelementptr i64, ptr %9, i64 3
  %37 = load i64, ptr %36, align 4
  %encode_value_ptr133 = getelementptr i64, ptr %heap_to_ptr126, i64 8
  store i64 %37, ptr %encode_value_ptr133, align 4
  %encode_value_ptr134 = getelementptr i64, ptr %heap_to_ptr126, i64 9
  store i64 %10, ptr %encode_value_ptr134, align 4
  %encode_value_ptr135 = getelementptr i64, ptr %heap_to_ptr126, i64 10
  store i64 %11, ptr %encode_value_ptr135, align 4
  %encode_value_ptr136 = getelementptr i64, ptr %heap_to_ptr126, i64 11
  store i64 %12, ptr %encode_value_ptr136, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr119, i64 0
  %39 = load i64, ptr %38, align 4
  %encode_value_ptr137 = getelementptr i64, ptr %heap_to_ptr126, i64 12
  store i64 %39, ptr %encode_value_ptr137, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr119, i64 1
  %41 = load i64, ptr %40, align 4
  %encode_value_ptr138 = getelementptr i64, ptr %heap_to_ptr126, i64 13
  store i64 %41, ptr %encode_value_ptr138, align 4
  %42 = getelementptr i64, ptr %heap_to_ptr119, i64 2
  %43 = load i64, ptr %42, align 4
  %encode_value_ptr139 = getelementptr i64, ptr %heap_to_ptr126, i64 14
  store i64 %43, ptr %encode_value_ptr139, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr119, i64 3
  %45 = load i64, ptr %44, align 4
  %encode_value_ptr140 = getelementptr i64, ptr %heap_to_ptr126, i64 15
  store i64 %45, ptr %encode_value_ptr140, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr124, i64 0
  %47 = load i64, ptr %46, align 4
  %encode_value_ptr141 = getelementptr i64, ptr %heap_to_ptr126, i64 16
  store i64 %47, ptr %encode_value_ptr141, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr124, i64 1
  %49 = load i64, ptr %48, align 4
  %encode_value_ptr142 = getelementptr i64, ptr %heap_to_ptr126, i64 17
  store i64 %49, ptr %encode_value_ptr142, align 4
  %50 = getelementptr i64, ptr %heap_to_ptr124, i64 2
  %51 = load i64, ptr %50, align 4
  %encode_value_ptr143 = getelementptr i64, ptr %heap_to_ptr126, i64 18
  store i64 %51, ptr %encode_value_ptr143, align 4
  %52 = getelementptr i64, ptr %heap_to_ptr124, i64 3
  %53 = load i64, ptr %52, align 4
  %encode_value_ptr144 = getelementptr i64, ptr %heap_to_ptr126, i64 19
  store i64 %53, ptr %encode_value_ptr144, align 4
  %length145 = load i64, ptr %heap_to_ptr126, align 4
  %54 = ptrtoint ptr %heap_to_ptr126 to i64
  %55 = add i64 %54, 1
  %vector_data146 = inttoptr i64 %55 to ptr
  %56 = call i64 @vector_new(i64 4)
  %heap_start147 = sub i64 %56, 4
  %heap_to_ptr148 = inttoptr i64 %heap_start147 to ptr
  call void @poseidon_hash(ptr %vector_data146, ptr %heap_to_ptr148, i64 %length145)
  store ptr %heap_to_ptr148, ptr %structHash, align 8
  %57 = call i64 @vector_new(i64 53)
  %heap_start149 = sub i64 %57, 53
  %heap_to_ptr150 = inttoptr i64 %heap_start149 to ptr
  store i64 52, ptr %heap_to_ptr150, align 4
  %58 = ptrtoint ptr %heap_to_ptr150 to i64
  %59 = add i64 %58, 1
  %vector_data151 = inttoptr i64 %59 to ptr
  %index_access152 = getelementptr i64, ptr %vector_data151, i64 0
  store i64 69, ptr %index_access152, align 4
  %index_access153 = getelementptr i64, ptr %vector_data151, i64 1
  store i64 73, ptr %index_access153, align 4
  %index_access154 = getelementptr i64, ptr %vector_data151, i64 2
  store i64 80, ptr %index_access154, align 4
  %index_access155 = getelementptr i64, ptr %vector_data151, i64 3
  store i64 55, ptr %index_access155, align 4
  %index_access156 = getelementptr i64, ptr %vector_data151, i64 4
  store i64 49, ptr %index_access156, align 4
  %index_access157 = getelementptr i64, ptr %vector_data151, i64 5
  store i64 50, ptr %index_access157, align 4
  %index_access158 = getelementptr i64, ptr %vector_data151, i64 6
  store i64 68, ptr %index_access158, align 4
  %index_access159 = getelementptr i64, ptr %vector_data151, i64 7
  store i64 111, ptr %index_access159, align 4
  %index_access160 = getelementptr i64, ptr %vector_data151, i64 8
  store i64 109, ptr %index_access160, align 4
  %index_access161 = getelementptr i64, ptr %vector_data151, i64 9
  store i64 97, ptr %index_access161, align 4
  %index_access162 = getelementptr i64, ptr %vector_data151, i64 10
  store i64 105, ptr %index_access162, align 4
  %index_access163 = getelementptr i64, ptr %vector_data151, i64 11
  store i64 110, ptr %index_access163, align 4
  %index_access164 = getelementptr i64, ptr %vector_data151, i64 12
  store i64 40, ptr %index_access164, align 4
  %index_access165 = getelementptr i64, ptr %vector_data151, i64 13
  store i64 115, ptr %index_access165, align 4
  %index_access166 = getelementptr i64, ptr %vector_data151, i64 14
  store i64 116, ptr %index_access166, align 4
  %index_access167 = getelementptr i64, ptr %vector_data151, i64 15
  store i64 114, ptr %index_access167, align 4
  %index_access168 = getelementptr i64, ptr %vector_data151, i64 16
  store i64 105, ptr %index_access168, align 4
  %index_access169 = getelementptr i64, ptr %vector_data151, i64 17
  store i64 110, ptr %index_access169, align 4
  %index_access170 = getelementptr i64, ptr %vector_data151, i64 18
  store i64 103, ptr %index_access170, align 4
  %index_access171 = getelementptr i64, ptr %vector_data151, i64 19
  store i64 32, ptr %index_access171, align 4
  %index_access172 = getelementptr i64, ptr %vector_data151, i64 20
  store i64 110, ptr %index_access172, align 4
  %index_access173 = getelementptr i64, ptr %vector_data151, i64 21
  store i64 97, ptr %index_access173, align 4
  %index_access174 = getelementptr i64, ptr %vector_data151, i64 22
  store i64 109, ptr %index_access174, align 4
  %index_access175 = getelementptr i64, ptr %vector_data151, i64 23
  store i64 101, ptr %index_access175, align 4
  %index_access176 = getelementptr i64, ptr %vector_data151, i64 24
  store i64 44, ptr %index_access176, align 4
  %index_access177 = getelementptr i64, ptr %vector_data151, i64 25
  store i64 115, ptr %index_access177, align 4
  %index_access178 = getelementptr i64, ptr %vector_data151, i64 26
  store i64 116, ptr %index_access178, align 4
  %index_access179 = getelementptr i64, ptr %vector_data151, i64 27
  store i64 114, ptr %index_access179, align 4
  %index_access180 = getelementptr i64, ptr %vector_data151, i64 28
  store i64 105, ptr %index_access180, align 4
  %index_access181 = getelementptr i64, ptr %vector_data151, i64 29
  store i64 110, ptr %index_access181, align 4
  %index_access182 = getelementptr i64, ptr %vector_data151, i64 30
  store i64 103, ptr %index_access182, align 4
  %index_access183 = getelementptr i64, ptr %vector_data151, i64 31
  store i64 32, ptr %index_access183, align 4
  %index_access184 = getelementptr i64, ptr %vector_data151, i64 32
  store i64 118, ptr %index_access184, align 4
  %index_access185 = getelementptr i64, ptr %vector_data151, i64 33
  store i64 101, ptr %index_access185, align 4
  %index_access186 = getelementptr i64, ptr %vector_data151, i64 34
  store i64 114, ptr %index_access186, align 4
  %index_access187 = getelementptr i64, ptr %vector_data151, i64 35
  store i64 115, ptr %index_access187, align 4
  %index_access188 = getelementptr i64, ptr %vector_data151, i64 36
  store i64 105, ptr %index_access188, align 4
  %index_access189 = getelementptr i64, ptr %vector_data151, i64 37
  store i64 111, ptr %index_access189, align 4
  %index_access190 = getelementptr i64, ptr %vector_data151, i64 38
  store i64 110, ptr %index_access190, align 4
  %index_access191 = getelementptr i64, ptr %vector_data151, i64 39
  store i64 44, ptr %index_access191, align 4
  %index_access192 = getelementptr i64, ptr %vector_data151, i64 40
  store i64 117, ptr %index_access192, align 4
  %index_access193 = getelementptr i64, ptr %vector_data151, i64 41
  store i64 51, ptr %index_access193, align 4
  %index_access194 = getelementptr i64, ptr %vector_data151, i64 42
  store i64 50, ptr %index_access194, align 4
  %index_access195 = getelementptr i64, ptr %vector_data151, i64 43
  store i64 32, ptr %index_access195, align 4
  %index_access196 = getelementptr i64, ptr %vector_data151, i64 44
  store i64 99, ptr %index_access196, align 4
  %index_access197 = getelementptr i64, ptr %vector_data151, i64 45
  store i64 104, ptr %index_access197, align 4
  %index_access198 = getelementptr i64, ptr %vector_data151, i64 46
  store i64 97, ptr %index_access198, align 4
  %index_access199 = getelementptr i64, ptr %vector_data151, i64 47
  store i64 105, ptr %index_access199, align 4
  %index_access200 = getelementptr i64, ptr %vector_data151, i64 48
  store i64 110, ptr %index_access200, align 4
  %index_access201 = getelementptr i64, ptr %vector_data151, i64 49
  store i64 73, ptr %index_access201, align 4
  %index_access202 = getelementptr i64, ptr %vector_data151, i64 50
  store i64 100, ptr %index_access202, align 4
  %index_access203 = getelementptr i64, ptr %vector_data151, i64 51
  store i64 41, ptr %index_access203, align 4
  %length204 = load i64, ptr %heap_to_ptr150, align 4
  %60 = ptrtoint ptr %heap_to_ptr150 to i64
  %61 = add i64 %60, 1
  %vector_data205 = inttoptr i64 %61 to ptr
  %62 = call i64 @vector_new(i64 4)
  %heap_start206 = sub i64 %62, 4
  %heap_to_ptr207 = inttoptr i64 %heap_start206 to ptr
  call void @poseidon_hash(ptr %vector_data205, ptr %heap_to_ptr207, i64 %length204)
  store ptr %heap_to_ptr207, ptr %EIP712_DOMAIN_TYPEHASH, align 8
  %63 = load ptr, ptr %EIP712_DOMAIN_TYPEHASH, align 8
  %64 = call i64 @vector_new(i64 4)
  %heap_start208 = sub i64 %64, 4
  %heap_to_ptr209 = inttoptr i64 %heap_start208 to ptr
  store i64 3, ptr %heap_to_ptr209, align 4
  %65 = ptrtoint ptr %heap_to_ptr209 to i64
  %66 = add i64 %65, 1
  %vector_data210 = inttoptr i64 %66 to ptr
  %index_access211 = getelementptr i64, ptr %vector_data210, i64 0
  store i64 79, ptr %index_access211, align 4
  %index_access212 = getelementptr i64, ptr %vector_data210, i64 1
  store i64 108, ptr %index_access212, align 4
  %index_access213 = getelementptr i64, ptr %vector_data210, i64 2
  store i64 97, ptr %index_access213, align 4
  %length214 = load i64, ptr %heap_to_ptr209, align 4
  %67 = ptrtoint ptr %heap_to_ptr209 to i64
  %68 = add i64 %67, 1
  %vector_data215 = inttoptr i64 %68 to ptr
  %69 = call i64 @vector_new(i64 4)
  %heap_start216 = sub i64 %69, 4
  %heap_to_ptr217 = inttoptr i64 %heap_start216 to ptr
  call void @poseidon_hash(ptr %vector_data215, ptr %heap_to_ptr217, i64 %length214)
  %70 = call i64 @vector_new(i64 2)
  %heap_start218 = sub i64 %70, 2
  %heap_to_ptr219 = inttoptr i64 %heap_start218 to ptr
  store i64 1, ptr %heap_to_ptr219, align 4
  %71 = ptrtoint ptr %heap_to_ptr219 to i64
  %72 = add i64 %71, 1
  %vector_data220 = inttoptr i64 %72 to ptr
  %index_access221 = getelementptr i64, ptr %vector_data220, i64 0
  store i64 49, ptr %index_access221, align 4
  %length222 = load i64, ptr %heap_to_ptr219, align 4
  %73 = ptrtoint ptr %heap_to_ptr219 to i64
  %74 = add i64 %73, 1
  %vector_data223 = inttoptr i64 %74 to ptr
  %75 = call i64 @vector_new(i64 4)
  %heap_start224 = sub i64 %75, 4
  %heap_to_ptr225 = inttoptr i64 %heap_start224 to ptr
  call void @poseidon_hash(ptr %vector_data223, ptr %heap_to_ptr225, i64 %length222)
  %76 = call i64 @vector_new(i64 1)
  %heap_start226 = sub i64 %76, 1
  %heap_to_ptr227 = inttoptr i64 %heap_start226 to ptr
  call void @get_context_data(i64 %heap_start226, i64 7)
  %77 = load i64, ptr %heap_to_ptr227, align 4
  %78 = call i64 @vector_new(i64 14)
  %heap_start228 = sub i64 %78, 14
  %heap_to_ptr229 = inttoptr i64 %heap_start228 to ptr
  store i64 13, ptr %heap_to_ptr229, align 4
  %79 = getelementptr i64, ptr %63, i64 0
  %80 = load i64, ptr %79, align 4
  %encode_value_ptr230 = getelementptr i64, ptr %heap_to_ptr229, i64 1
  store i64 %80, ptr %encode_value_ptr230, align 4
  %81 = getelementptr i64, ptr %63, i64 1
  %82 = load i64, ptr %81, align 4
  %encode_value_ptr231 = getelementptr i64, ptr %heap_to_ptr229, i64 2
  store i64 %82, ptr %encode_value_ptr231, align 4
  %83 = getelementptr i64, ptr %63, i64 2
  %84 = load i64, ptr %83, align 4
  %encode_value_ptr232 = getelementptr i64, ptr %heap_to_ptr229, i64 3
  store i64 %84, ptr %encode_value_ptr232, align 4
  %85 = getelementptr i64, ptr %63, i64 3
  %86 = load i64, ptr %85, align 4
  %encode_value_ptr233 = getelementptr i64, ptr %heap_to_ptr229, i64 4
  store i64 %86, ptr %encode_value_ptr233, align 4
  %87 = getelementptr i64, ptr %heap_to_ptr217, i64 0
  %88 = load i64, ptr %87, align 4
  %encode_value_ptr234 = getelementptr i64, ptr %heap_to_ptr229, i64 5
  store i64 %88, ptr %encode_value_ptr234, align 4
  %89 = getelementptr i64, ptr %heap_to_ptr217, i64 1
  %90 = load i64, ptr %89, align 4
  %encode_value_ptr235 = getelementptr i64, ptr %heap_to_ptr229, i64 6
  store i64 %90, ptr %encode_value_ptr235, align 4
  %91 = getelementptr i64, ptr %heap_to_ptr217, i64 2
  %92 = load i64, ptr %91, align 4
  %encode_value_ptr236 = getelementptr i64, ptr %heap_to_ptr229, i64 7
  store i64 %92, ptr %encode_value_ptr236, align 4
  %93 = getelementptr i64, ptr %heap_to_ptr217, i64 3
  %94 = load i64, ptr %93, align 4
  %encode_value_ptr237 = getelementptr i64, ptr %heap_to_ptr229, i64 8
  store i64 %94, ptr %encode_value_ptr237, align 4
  %95 = getelementptr i64, ptr %heap_to_ptr225, i64 0
  %96 = load i64, ptr %95, align 4
  %encode_value_ptr238 = getelementptr i64, ptr %heap_to_ptr229, i64 9
  store i64 %96, ptr %encode_value_ptr238, align 4
  %97 = getelementptr i64, ptr %heap_to_ptr225, i64 1
  %98 = load i64, ptr %97, align 4
  %encode_value_ptr239 = getelementptr i64, ptr %heap_to_ptr229, i64 10
  store i64 %98, ptr %encode_value_ptr239, align 4
  %99 = getelementptr i64, ptr %heap_to_ptr225, i64 2
  %100 = load i64, ptr %99, align 4
  %encode_value_ptr240 = getelementptr i64, ptr %heap_to_ptr229, i64 11
  store i64 %100, ptr %encode_value_ptr240, align 4
  %101 = getelementptr i64, ptr %heap_to_ptr225, i64 3
  %102 = load i64, ptr %101, align 4
  %encode_value_ptr241 = getelementptr i64, ptr %heap_to_ptr229, i64 12
  store i64 %102, ptr %encode_value_ptr241, align 4
  %encode_value_ptr242 = getelementptr i64, ptr %heap_to_ptr229, i64 13
  store i64 %77, ptr %encode_value_ptr242, align 4
  %length243 = load i64, ptr %heap_to_ptr229, align 4
  %103 = ptrtoint ptr %heap_to_ptr229 to i64
  %104 = add i64 %103, 1
  %vector_data244 = inttoptr i64 %104 to ptr
  %105 = call i64 @vector_new(i64 4)
  %heap_start245 = sub i64 %105, 4
  %heap_to_ptr246 = inttoptr i64 %heap_start245 to ptr
  call void @poseidon_hash(ptr %vector_data244, ptr %heap_to_ptr246, i64 %length243)
  store ptr %heap_to_ptr246, ptr %domainSeparator, align 8
  %106 = call i64 @vector_new(i64 3)
  %heap_start247 = sub i64 %106, 3
  %heap_to_ptr248 = inttoptr i64 %heap_start247 to ptr
  store i64 2, ptr %heap_to_ptr248, align 4
  %107 = ptrtoint ptr %heap_to_ptr248 to i64
  %108 = add i64 %107, 1
  %vector_data249 = inttoptr i64 %108 to ptr
  %index_access250 = getelementptr i64, ptr %vector_data249, i64 0
  store i64 25, ptr %index_access250, align 4
  %index_access251 = getelementptr i64, ptr %vector_data249, i64 1
  store i64 1, ptr %index_access251, align 4
  %109 = load ptr, ptr %domainSeparator, align 8
  %110 = load ptr, ptr %structHash, align 8
  %length252 = load i64, ptr %heap_to_ptr248, align 4
  %111 = add i64 %length252, 1
  %112 = add i64 %111, 4
  %113 = add i64 %112, 4
  %length_and_data = add i64 %113, 1
  %114 = call i64 @vector_new(i64 %length_and_data)
  %heap_start253 = sub i64 %114, %length_and_data
  %heap_to_ptr254 = inttoptr i64 %heap_start253 to ptr
  store i64 %113, ptr %heap_to_ptr254, align 4
  %length255 = load i64, ptr %heap_to_ptr248, align 4
  %115 = ptrtoint ptr %heap_to_ptr254 to i64
  %buffer_start = add i64 %115, 2
  %116 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr256 = getelementptr i64, ptr %116, i64 2
  store i64 %length255, ptr %encode_value_ptr256, align 4
  %117 = ptrtoint ptr %heap_to_ptr248 to i64
  %118 = add i64 %117, 1
  %vector_data257 = inttoptr i64 %118 to ptr
  call void @memcpy(ptr %vector_data257, ptr %116, i64 %length255)
  %119 = add i64 %length255, 1
  %120 = add i64 %119, 1
  %121 = getelementptr i64, ptr %109, i64 0
  %122 = load i64, ptr %121, align 4
  %encode_value_ptr258 = getelementptr i64, ptr %heap_to_ptr254, i64 %120
  store i64 %122, ptr %encode_value_ptr258, align 4
  %123 = add i64 %120, 1
  %124 = getelementptr i64, ptr %109, i64 1
  %125 = load i64, ptr %124, align 4
  %encode_value_ptr259 = getelementptr i64, ptr %heap_to_ptr254, i64 %123
  store i64 %125, ptr %encode_value_ptr259, align 4
  %126 = add i64 %123, 1
  %127 = getelementptr i64, ptr %109, i64 2
  %128 = load i64, ptr %127, align 4
  %encode_value_ptr260 = getelementptr i64, ptr %heap_to_ptr254, i64 %126
  store i64 %128, ptr %encode_value_ptr260, align 4
  %129 = add i64 %126, 1
  %130 = getelementptr i64, ptr %109, i64 3
  %131 = load i64, ptr %130, align 4
  %encode_value_ptr261 = getelementptr i64, ptr %heap_to_ptr254, i64 %129
  store i64 %131, ptr %encode_value_ptr261, align 4
  %132 = add i64 %129, 1
  %133 = add i64 4, %120
  %134 = getelementptr i64, ptr %110, i64 0
  %135 = load i64, ptr %134, align 4
  %encode_value_ptr262 = getelementptr i64, ptr %heap_to_ptr254, i64 %133
  store i64 %135, ptr %encode_value_ptr262, align 4
  %136 = add i64 %133, 1
  %137 = getelementptr i64, ptr %110, i64 1
  %138 = load i64, ptr %137, align 4
  %encode_value_ptr263 = getelementptr i64, ptr %heap_to_ptr254, i64 %136
  store i64 %138, ptr %encode_value_ptr263, align 4
  %139 = add i64 %136, 1
  %140 = getelementptr i64, ptr %110, i64 2
  %141 = load i64, ptr %140, align 4
  %encode_value_ptr264 = getelementptr i64, ptr %heap_to_ptr254, i64 %139
  store i64 %141, ptr %encode_value_ptr264, align 4
  %142 = add i64 %139, 1
  %143 = getelementptr i64, ptr %110, i64 3
  %144 = load i64, ptr %143, align 4
  %encode_value_ptr265 = getelementptr i64, ptr %heap_to_ptr254, i64 %142
  store i64 %144, ptr %encode_value_ptr265, align 4
  %145 = add i64 %142, 1
  %146 = add i64 4, %133
  %length266 = load i64, ptr %heap_to_ptr254, align 4
  %147 = ptrtoint ptr %heap_to_ptr254 to i64
  %148 = add i64 %147, 1
  %vector_data267 = inttoptr i64 %148 to ptr
  %149 = call i64 @vector_new(i64 4)
  %heap_start268 = sub i64 %149, 4
  %heap_to_ptr269 = inttoptr i64 %heap_start268 to ptr
  call void @poseidon_hash(ptr %vector_data267, ptr %heap_to_ptr269, i64 %length266)
  store ptr %heap_to_ptr269, ptr %signedHash, align 8
  %150 = load ptr, ptr %signedHash, align 8
  ret ptr %150
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
  %4 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %4, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 4, ptr %heap_to_ptr, align 4
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %6, ptr %7, align 4
  %8 = getelementptr i64, ptr %3, i64 1
  %9 = load i64, ptr %8, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %9, ptr %10, align 4
  %11 = getelementptr i64, ptr %3, i64 2
  %12 = load i64, ptr %11, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %12, ptr %13, align 4
  %14 = getelementptr i64, ptr %3, i64 3
  %15 = load i64, ptr %14, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %15, ptr %16, align 4
  %length = load i64, ptr %2, align 4
  %17 = ptrtoint ptr %2 to i64
  %18 = add i64 %17, 1
  %vector_data = inttoptr i64 %18 to ptr
  %19 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %19, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @poseidon_hash(ptr %vector_data, ptr %heap_to_ptr2, i64 %length)
  %20 = call i64 @vector_new(i64 5)
  %heap_start3 = sub i64 %20, 5
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 4, ptr %heap_to_ptr4, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr2, i64 0
  %22 = load i64, ptr %21, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr4, i64 0
  store i64 %22, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  %25 = load i64, ptr %24, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 %25, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  %28 = load i64, ptr %27, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 %28, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  %31 = load i64, ptr %30, align 4
  %32 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 %31, ptr %32, align 4
  %33 = call ptr @fields_concat(ptr %heap_to_ptr, ptr %heap_to_ptr4)
  %length5 = load i64, ptr %33, align 4
  %34 = ptrtoint ptr %33 to i64
  %35 = add i64 %34, 1
  %vector_data6 = inttoptr i64 %35 to ptr
  %36 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %36, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @poseidon_hash(ptr %vector_data6, ptr %heap_to_ptr8, i64 %length5)
  store ptr %heap_to_ptr8, ptr %txHash, align 8
  %37 = load ptr, ptr %txHash, align 8
  ret ptr %37
}

define void @validate_sender(ptr %0) {
entry:
  %account_version = alloca i64, align 8
  %DEPLOYER_SYSTEM_CONTRACT = alloca ptr, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %1, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 32773, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 7)
  %heap_start4 = sub i64 %3, 7
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 6, ptr %heap_to_ptr5, align 4
  %4 = getelementptr i64, ptr %2, i64 0
  %5 = load i64, ptr %4, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 %5, ptr %encode_value_ptr, align 4
  %6 = getelementptr i64, ptr %2, i64 1
  %7 = load i64, ptr %6, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 %7, ptr %encode_value_ptr6, align 4
  %8 = getelementptr i64, ptr %2, i64 2
  %9 = load i64, ptr %8, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 %9, ptr %encode_value_ptr7, align 4
  %10 = getelementptr i64, ptr %2, i64 3
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr5, i64 4
  store i64 %11, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr5, i64 5
  store i64 4, ptr %encode_value_ptr9, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %heap_to_ptr5, i64 6
  store i64 3138377232, ptr %encode_value_ptr10, align 4
  %12 = load ptr, ptr %DEPLOYER_SYSTEM_CONTRACT, align 8
  %payload_len = load i64, ptr %heap_to_ptr5, align 4
  %tape_size = add i64 %payload_len, 2
  %13 = ptrtoint ptr %heap_to_ptr5 to i64
  %payload_start = add i64 %13, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %12, i64 0)
  %14 = call i64 @vector_new(i64 1)
  %heap_start11 = sub i64 %14, 1
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @get_tape_data(i64 %heap_start11, i64 1)
  %return_length = load i64, ptr %heap_to_ptr12, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size13 = add i64 %return_length, 1
  %15 = call i64 @vector_new(i64 %heap_size)
  %heap_start14 = sub i64 %15, %heap_size
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %return_length, ptr %heap_to_ptr15, align 4
  %16 = add i64 %heap_start14, 1
  call void @get_tape_data(i64 %16, i64 %tape_size13)
  %length = load i64, ptr %heap_to_ptr15, align 4
  %17 = ptrtoint ptr %heap_to_ptr15 to i64
  %18 = add i64 %17, 1
  %vector_data = inttoptr i64 %18 to ptr
  %input_start = ptrtoint ptr %vector_data to i64
  %19 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %19, align 4
  store i64 %decode_value, ptr %account_version, align 4
  %20 = load i64, ptr %account_version, align 4
  %21 = icmp ne i64 %20, 0
  %22 = zext i1 %21 to i64
  call void @builtin_assert(i64 %22)
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
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 32771, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %3 = load ptr, ptr %_address, align 8
  %4 = load i64, ptr %_nonce, align 4
  %5 = call i64 @vector_new(i64 8)
  %heap_start4 = sub i64 %5, 8
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 7, ptr %heap_to_ptr5, align 4
  %6 = getelementptr i64, ptr %3, i64 0
  %7 = load i64, ptr %6, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 %7, ptr %encode_value_ptr, align 4
  %8 = getelementptr i64, ptr %3, i64 1
  %9 = load i64, ptr %8, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 %9, ptr %encode_value_ptr6, align 4
  %10 = getelementptr i64, ptr %3, i64 2
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 %11, ptr %encode_value_ptr7, align 4
  %12 = getelementptr i64, ptr %3, i64 3
  %13 = load i64, ptr %12, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr5, i64 4
  store i64 %13, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr5, i64 5
  store i64 %4, ptr %encode_value_ptr9, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %heap_to_ptr5, i64 6
  store i64 5, ptr %encode_value_ptr10, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %heap_to_ptr5, i64 7
  store i64 3775522898, ptr %encode_value_ptr11, align 4
  %14 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %payload_len = load i64, ptr %heap_to_ptr5, align 4
  %tape_size = add i64 %payload_len, 2
  %15 = ptrtoint ptr %heap_to_ptr5 to i64
  %payload_start = add i64 %15, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %14, i64 0)
  %16 = call i64 @vector_new(i64 1)
  %heap_start12 = sub i64 %16, 1
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @get_tape_data(i64 %heap_start12, i64 1)
  %return_length = load i64, ptr %heap_to_ptr13, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size14 = add i64 %return_length, 1
  %17 = call i64 @vector_new(i64 %heap_size)
  %heap_start15 = sub i64 %17, %heap_size
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %return_length, ptr %heap_to_ptr16, align 4
  %18 = add i64 %heap_start15, 1
  call void @get_tape_data(i64 %18, i64 %tape_size14)
  %length = load i64, ptr %heap_to_ptr16, align 4
  %19 = ptrtoint ptr %heap_to_ptr16 to i64
  %20 = add i64 %19, 1
  %vector_data = inttoptr i64 %20 to ptr
  %input_start = ptrtoint ptr %vector_data to i64
  %21 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %21, align 4
  store i64 %decode_value, ptr %nonce, align 4
  %22 = load i64, ptr %nonce, align 4
  %23 = icmp eq i64 %22, 0
  %24 = zext i1 %23 to i64
  call void @builtin_assert(i64 %24)
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
  %struct_start = ptrtoint ptr %3 to i64
  %6 = add i64 %struct_start, 4
  %7 = inttoptr i64 %6 to ptr
  %8 = add i64 %6, 1
  %9 = inttoptr i64 %8 to ptr
  %10 = add i64 %8, 1
  %11 = inttoptr i64 %10 to ptr
  %12 = add i64 %10, 1
  %13 = inttoptr i64 %12 to ptr
  %length = load i64, ptr %13, align 4
  %14 = add i64 %length, 1
  %15 = add i64 %12, %14
  %16 = inttoptr i64 %15 to ptr
  %length1 = load i64, ptr %16, align 4
  %17 = add i64 %length1, 1
  %18 = add i64 %15, %17
  %19 = inttoptr i64 %18 to ptr
  %length2 = load i64, ptr %19, align 4
  %20 = add i64 %length2, 1
  %21 = add i64 %18, %20
  %22 = inttoptr i64 %21 to ptr
  %23 = add i64 %21, 4
  %24 = inttoptr i64 %23 to ptr
  %25 = sub i64 %23, %struct_start
  %26 = add i64 8, %25
  %heap_size = add i64 %26, 2
  %length_and_data = add i64 %heap_size, 1
  %27 = call i64 @vector_new(i64 %length_and_data)
  %heap_start = sub i64 %27, %length_and_data
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %heap_size, ptr %heap_to_ptr, align 4
  %28 = getelementptr i64, ptr %4, i64 0
  %29 = load i64, ptr %28, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %29, ptr %encode_value_ptr, align 4
  %30 = getelementptr i64, ptr %4, i64 1
  %31 = load i64, ptr %30, align 4
  %encode_value_ptr3 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %31, ptr %encode_value_ptr3, align 4
  %32 = getelementptr i64, ptr %4, i64 2
  %33 = load i64, ptr %32, align 4
  %encode_value_ptr4 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %33, ptr %encode_value_ptr4, align 4
  %34 = getelementptr i64, ptr %4, i64 3
  %35 = load i64, ptr %34, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 %35, ptr %encode_value_ptr5, align 4
  %36 = getelementptr i64, ptr %5, i64 0
  %37 = load i64, ptr %36, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr, i64 5
  store i64 %37, ptr %encode_value_ptr6, align 4
  %38 = getelementptr i64, ptr %5, i64 1
  %39 = load i64, ptr %38, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr, i64 6
  store i64 %39, ptr %encode_value_ptr7, align 4
  %40 = getelementptr i64, ptr %5, i64 2
  %41 = load i64, ptr %40, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr, i64 7
  store i64 %41, ptr %encode_value_ptr8, align 4
  %42 = getelementptr i64, ptr %5, i64 3
  %43 = load i64, ptr %42, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr, i64 8
  store i64 %43, ptr %encode_value_ptr9, align 4
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %elem = load ptr, ptr %struct_member, align 8
  %44 = getelementptr i64, ptr %elem, i64 0
  %45 = load i64, ptr %44, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %heap_to_ptr, i64 9
  store i64 %45, ptr %encode_value_ptr10, align 4
  %46 = getelementptr i64, ptr %elem, i64 1
  %47 = load i64, ptr %46, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %heap_to_ptr, i64 10
  store i64 %47, ptr %encode_value_ptr11, align 4
  %48 = getelementptr i64, ptr %elem, i64 2
  %49 = load i64, ptr %48, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %heap_to_ptr, i64 11
  store i64 %49, ptr %encode_value_ptr12, align 4
  %50 = getelementptr i64, ptr %elem, i64 3
  %51 = load i64, ptr %50, align 4
  %encode_value_ptr13 = getelementptr i64, ptr %heap_to_ptr, i64 12
  store i64 %51, ptr %encode_value_ptr13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 1
  %elem15 = load i64, ptr %struct_member14, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %heap_to_ptr, i64 13
  store i64 %elem15, ptr %encode_value_ptr16, align 4
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 2
  %elem18 = load i64, ptr %struct_member17, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %heap_to_ptr, i64 14
  store i64 %elem18, ptr %encode_value_ptr19, align 4
  %struct_member20 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 3
  %elem21 = load i64, ptr %struct_member20, align 4
  %encode_value_ptr22 = getelementptr i64, ptr %heap_to_ptr, i64 15
  store i64 %elem21, ptr %encode_value_ptr22, align 4
  %struct_member23 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 4
  %length24 = load i64, ptr %struct_member23, align 4
  %52 = ptrtoint ptr %heap_to_ptr to i64
  %buffer_start = add i64 %52, 17
  %53 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr25 = getelementptr i64, ptr %53, i64 17
  store i64 %length24, ptr %encode_value_ptr25, align 4
  %54 = ptrtoint ptr %struct_member23 to i64
  %55 = add i64 %54, 1
  %vector_data = inttoptr i64 %55 to ptr
  call void @memcpy(ptr %vector_data, ptr %53, i64 %length24)
  %56 = add i64 %length24, 1
  %57 = add i64 %56, 7
  %58 = add i64 %56, 16
  %struct_member26 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 5
  %length27 = load i64, ptr %struct_member26, align 4
  %offset = add i64 %58, 1
  %59 = ptrtoint ptr %heap_to_ptr to i64
  %buffer_start28 = add i64 %59, %offset
  %60 = inttoptr i64 %buffer_start28 to ptr
  %encode_value_ptr29 = getelementptr i64, ptr %60, i64 %offset
  store i64 %length27, ptr %encode_value_ptr29, align 4
  %61 = ptrtoint ptr %struct_member26 to i64
  %62 = add i64 %61, 1
  %vector_data30 = inttoptr i64 %62 to ptr
  call void @memcpy(ptr %vector_data30, ptr %60, i64 %length27)
  %63 = add i64 %length27, 1
  %64 = add i64 %63, %57
  %65 = add i64 %63, %58
  %struct_member31 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 6
  %length32 = load i64, ptr %struct_member31, align 4
  %offset33 = add i64 %65, 1
  %66 = ptrtoint ptr %heap_to_ptr to i64
  %buffer_start34 = add i64 %66, %offset33
  %67 = inttoptr i64 %buffer_start34 to ptr
  %encode_value_ptr35 = getelementptr i64, ptr %67, i64 %offset33
  store i64 %length32, ptr %encode_value_ptr35, align 4
  %68 = ptrtoint ptr %struct_member31 to i64
  %69 = add i64 %68, 1
  %vector_data36 = inttoptr i64 %69 to ptr
  call void @memcpy(ptr %vector_data36, ptr %67, i64 %length32)
  %70 = add i64 %length32, 1
  %71 = add i64 %70, %64
  %72 = add i64 %70, %65
  %struct_member37 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 7
  %elem38 = load ptr, ptr %struct_member37, align 8
  %73 = getelementptr i64, ptr %elem38, i64 0
  %74 = load i64, ptr %73, align 4
  %encode_value_ptr39 = getelementptr i64, ptr %heap_to_ptr, i64 %72
  store i64 %74, ptr %encode_value_ptr39, align 4
  %75 = add i64 %72, 1
  %76 = getelementptr i64, ptr %elem38, i64 1
  %77 = load i64, ptr %76, align 4
  %encode_value_ptr40 = getelementptr i64, ptr %heap_to_ptr, i64 %75
  store i64 %77, ptr %encode_value_ptr40, align 4
  %78 = add i64 %75, 1
  %79 = getelementptr i64, ptr %elem38, i64 2
  %80 = load i64, ptr %79, align 4
  %encode_value_ptr41 = getelementptr i64, ptr %heap_to_ptr, i64 %78
  store i64 %80, ptr %encode_value_ptr41, align 4
  %81 = add i64 %78, 1
  %82 = getelementptr i64, ptr %elem38, i64 3
  %83 = load i64, ptr %82, align 4
  %encode_value_ptr42 = getelementptr i64, ptr %heap_to_ptr, i64 %81
  store i64 %83, ptr %encode_value_ptr42, align 4
  %84 = add i64 %81, 1
  %85 = add i64 4, %71
  %86 = add i64 %85, 9
  %encode_value_ptr43 = getelementptr i64, ptr %heap_to_ptr, i64 %86
  store i64 %26, ptr %encode_value_ptr43, align 4
  %87 = add i64 %86, 1
  %encode_value_ptr44 = getelementptr i64, ptr %heap_to_ptr, i64 %87
  store i64 3738116221, ptr %encode_value_ptr44, align 4
  %struct_member45 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %3, i32 0, i32 0
  %88 = load ptr, ptr %struct_member45, align 8
  %payload_len = load i64, ptr %heap_to_ptr, align 4
  %tape_size = add i64 %payload_len, 2
  %89 = ptrtoint ptr %heap_to_ptr to i64
  %payload_start = add i64 %89, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %88, i64 0)
  %90 = call i64 @vector_new(i64 1)
  %heap_start46 = sub i64 %90, 1
  %heap_to_ptr47 = inttoptr i64 %heap_start46 to ptr
  call void @get_tape_data(i64 %heap_start46, i64 1)
  %return_length = load i64, ptr %heap_to_ptr47, align 4
  %heap_size48 = add i64 %return_length, 2
  %tape_size49 = add i64 %return_length, 1
  %91 = call i64 @vector_new(i64 %heap_size48)
  %heap_start50 = sub i64 %91, %heap_size48
  %heap_to_ptr51 = inttoptr i64 %heap_start50 to ptr
  store i64 %return_length, ptr %heap_to_ptr51, align 4
  %92 = add i64 %heap_start50, 1
  call void @get_tape_data(i64 %92, i64 %tape_size49)
  %length52 = load i64, ptr %heap_to_ptr51, align 4
  %93 = ptrtoint ptr %heap_to_ptr51 to i64
  %94 = add i64 %93, 1
  %vector_data53 = inttoptr i64 %94 to ptr
  %input_start = ptrtoint ptr %vector_data53 to i64
  %95 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %95, align 4
  store i64 %decode_value, ptr %magic, align 4
  %96 = call i64 @vector_new(i64 43)
  %heap_start54 = sub i64 %96, 43
  %heap_to_ptr55 = inttoptr i64 %heap_start54 to ptr
  store i64 42, ptr %heap_to_ptr55, align 4
  %97 = ptrtoint ptr %heap_to_ptr55 to i64
  %98 = add i64 %97, 1
  %vector_data56 = inttoptr i64 %98 to ptr
  %index_access = getelementptr i64, ptr %vector_data56, i64 0
  store i64 118, ptr %index_access, align 4
  %index_access57 = getelementptr i64, ptr %vector_data56, i64 1
  store i64 97, ptr %index_access57, align 4
  %index_access58 = getelementptr i64, ptr %vector_data56, i64 2
  store i64 108, ptr %index_access58, align 4
  %index_access59 = getelementptr i64, ptr %vector_data56, i64 3
  store i64 105, ptr %index_access59, align 4
  %index_access60 = getelementptr i64, ptr %vector_data56, i64 4
  store i64 100, ptr %index_access60, align 4
  %index_access61 = getelementptr i64, ptr %vector_data56, i64 5
  store i64 97, ptr %index_access61, align 4
  %index_access62 = getelementptr i64, ptr %vector_data56, i64 6
  store i64 116, ptr %index_access62, align 4
  %index_access63 = getelementptr i64, ptr %vector_data56, i64 7
  store i64 101, ptr %index_access63, align 4
  %index_access64 = getelementptr i64, ptr %vector_data56, i64 8
  store i64 84, ptr %index_access64, align 4
  %index_access65 = getelementptr i64, ptr %vector_data56, i64 9
  store i64 114, ptr %index_access65, align 4
  %index_access66 = getelementptr i64, ptr %vector_data56, i64 10
  store i64 97, ptr %index_access66, align 4
  %index_access67 = getelementptr i64, ptr %vector_data56, i64 11
  store i64 110, ptr %index_access67, align 4
  %index_access68 = getelementptr i64, ptr %vector_data56, i64 12
  store i64 115, ptr %index_access68, align 4
  %index_access69 = getelementptr i64, ptr %vector_data56, i64 13
  store i64 97, ptr %index_access69, align 4
  %index_access70 = getelementptr i64, ptr %vector_data56, i64 14
  store i64 99, ptr %index_access70, align 4
  %index_access71 = getelementptr i64, ptr %vector_data56, i64 15
  store i64 116, ptr %index_access71, align 4
  %index_access72 = getelementptr i64, ptr %vector_data56, i64 16
  store i64 105, ptr %index_access72, align 4
  %index_access73 = getelementptr i64, ptr %vector_data56, i64 17
  store i64 111, ptr %index_access73, align 4
  %index_access74 = getelementptr i64, ptr %vector_data56, i64 18
  store i64 110, ptr %index_access74, align 4
  %index_access75 = getelementptr i64, ptr %vector_data56, i64 19
  store i64 40, ptr %index_access75, align 4
  %index_access76 = getelementptr i64, ptr %vector_data56, i64 20
  store i64 104, ptr %index_access76, align 4
  %index_access77 = getelementptr i64, ptr %vector_data56, i64 21
  store i64 97, ptr %index_access77, align 4
  %index_access78 = getelementptr i64, ptr %vector_data56, i64 22
  store i64 115, ptr %index_access78, align 4
  %index_access79 = getelementptr i64, ptr %vector_data56, i64 23
  store i64 104, ptr %index_access79, align 4
  %index_access80 = getelementptr i64, ptr %vector_data56, i64 24
  store i64 44, ptr %index_access80, align 4
  %index_access81 = getelementptr i64, ptr %vector_data56, i64 25
  store i64 104, ptr %index_access81, align 4
  %index_access82 = getelementptr i64, ptr %vector_data56, i64 26
  store i64 97, ptr %index_access82, align 4
  %index_access83 = getelementptr i64, ptr %vector_data56, i64 27
  store i64 115, ptr %index_access83, align 4
  %index_access84 = getelementptr i64, ptr %vector_data56, i64 28
  store i64 104, ptr %index_access84, align 4
  %index_access85 = getelementptr i64, ptr %vector_data56, i64 29
  store i64 44, ptr %index_access85, align 4
  %index_access86 = getelementptr i64, ptr %vector_data56, i64 30
  store i64 84, ptr %index_access86, align 4
  %index_access87 = getelementptr i64, ptr %vector_data56, i64 31
  store i64 114, ptr %index_access87, align 4
  %index_access88 = getelementptr i64, ptr %vector_data56, i64 32
  store i64 97, ptr %index_access88, align 4
  %index_access89 = getelementptr i64, ptr %vector_data56, i64 33
  store i64 110, ptr %index_access89, align 4
  %index_access90 = getelementptr i64, ptr %vector_data56, i64 34
  store i64 115, ptr %index_access90, align 4
  %index_access91 = getelementptr i64, ptr %vector_data56, i64 35
  store i64 97, ptr %index_access91, align 4
  %index_access92 = getelementptr i64, ptr %vector_data56, i64 36
  store i64 99, ptr %index_access92, align 4
  %index_access93 = getelementptr i64, ptr %vector_data56, i64 37
  store i64 116, ptr %index_access93, align 4
  %index_access94 = getelementptr i64, ptr %vector_data56, i64 38
  store i64 105, ptr %index_access94, align 4
  %index_access95 = getelementptr i64, ptr %vector_data56, i64 39
  store i64 111, ptr %index_access95, align 4
  %index_access96 = getelementptr i64, ptr %vector_data56, i64 40
  store i64 110, ptr %index_access96, align 4
  %index_access97 = getelementptr i64, ptr %vector_data56, i64 41
  store i64 41, ptr %index_access97, align 4
  %length98 = load i64, ptr %heap_to_ptr55, align 4
  %99 = ptrtoint ptr %heap_to_ptr55 to i64
  %100 = add i64 %99, 1
  %vector_data99 = inttoptr i64 %100 to ptr
  %101 = call i64 @vector_new(i64 4)
  %heap_start100 = sub i64 %101, 4
  %heap_to_ptr101 = inttoptr i64 %heap_start100 to ptr
  call void @poseidon_hash(ptr %vector_data99, ptr %heap_to_ptr101, i64 %length98)
  store ptr %heap_to_ptr101, ptr %magics, align 8
  %102 = load ptr, ptr %magics, align 8
  %103 = call i64 @vector_new(i64 5)
  %heap_start102 = sub i64 %103, 5
  %heap_to_ptr103 = inttoptr i64 %heap_start102 to ptr
  store i64 4, ptr %heap_to_ptr103, align 4
  %104 = getelementptr i64, ptr %102, i64 0
  %105 = load i64, ptr %104, align 4
  %106 = getelementptr i64, ptr %heap_to_ptr103, i64 0
  store i64 %105, ptr %106, align 4
  %107 = getelementptr i64, ptr %102, i64 1
  %108 = load i64, ptr %107, align 4
  %109 = getelementptr i64, ptr %heap_to_ptr103, i64 1
  store i64 %108, ptr %109, align 4
  %110 = getelementptr i64, ptr %102, i64 2
  %111 = load i64, ptr %110, align 4
  %112 = getelementptr i64, ptr %heap_to_ptr103, i64 2
  store i64 %111, ptr %112, align 4
  %113 = getelementptr i64, ptr %102, i64 3
  %114 = load i64, ptr %113, align 4
  %115 = getelementptr i64, ptr %heap_to_ptr103, i64 3
  store i64 %114, ptr %115, align 4
  %116 = load i64, ptr %magic, align 4
  %length104 = load i64, ptr %heap_to_ptr103, align 4
  %117 = sub i64 %length104, 1
  %118 = sub i64 %117, 0
  call void @builtin_range_check(i64 %118)
  %119 = ptrtoint ptr %heap_to_ptr103 to i64
  %120 = add i64 %119, 1
  %vector_data105 = inttoptr i64 %120 to ptr
  %index_access106 = getelementptr i64, ptr %vector_data105, i64 0
  %121 = load i64, ptr %index_access106, align 4
  %122 = icmp eq i64 %116, %121
  %123 = zext i1 %122 to i64
  call void @builtin_assert(i64 %123)
  ret void
}

define ptr @hashL2Bytecode(ptr %0) {
entry:
  %hash_bytecode = alloca ptr, align 8
  %_bytecode = alloca ptr, align 8
  store ptr %0, ptr %_bytecode, align 8
  %1 = load ptr, ptr %_bytecode, align 8
  %length = load i64, ptr %1, align 4
  %2 = ptrtoint ptr %1 to i64
  %3 = add i64 %2, 1
  %vector_data = inttoptr i64 %3 to ptr
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @poseidon_hash(ptr %vector_data, ptr %heap_to_ptr, i64 %length)
  store ptr %heap_to_ptr, ptr %hash_bytecode, align 8
  %5 = load ptr, ptr %hash_bytecode, align 8
  ret ptr %5
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 4238180920, label %func_0_dispatch
    i64 2567667530, label %func_1_dispatch
    i64 1681860290, label %func_2_dispatch
    i64 4234869418, label %func_3_dispatch
    i64 3941117412, label %func_4_dispatch
    i64 2371655542, label %func_5_dispatch
    i64 665363203, label %func_6_dispatch
    i64 3738237042, label %func_7_dispatch
    i64 233676252, label %func_8_dispatch
    i64 3605241001, label %func_9_dispatch
    i64 1187965026, label %func_10_dispatch
    i64 1440883071, label %func_11_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %struct_offset = add i64 %input_start, 4
  %4 = inttoptr i64 %struct_offset to ptr
  %decode_value = load i64, ptr %4, align 4
  %struct_offset1 = add i64 %struct_offset, 1
  %5 = inttoptr i64 %struct_offset1 to ptr
  %decode_value2 = load i64, ptr %5, align 4
  %struct_offset3 = add i64 %struct_offset1, 1
  %6 = inttoptr i64 %struct_offset3 to ptr
  %decode_value4 = load i64, ptr %6, align 4
  %struct_offset5 = add i64 %struct_offset3, 1
  %7 = inttoptr i64 %struct_offset5 to ptr
  %length = load i64, ptr %7, align 4
  %8 = add i64 %length, 1
  %struct_offset6 = add i64 %struct_offset5, %8
  %9 = inttoptr i64 %struct_offset6 to ptr
  %length7 = load i64, ptr %9, align 4
  %10 = add i64 %length7, 1
  %struct_offset8 = add i64 %struct_offset6, %10
  %11 = inttoptr i64 %struct_offset8 to ptr
  %length9 = load i64, ptr %11, align 4
  %12 = add i64 %length9, 1
  %struct_offset10 = add i64 %struct_offset8, %12
  %13 = inttoptr i64 %struct_offset10 to ptr
  %struct_offset11 = add i64 %struct_offset10, 4
  %struct_decode_size = sub i64 %struct_offset11, %input_start
  %14 = call i64 @vector_new(i64 14)
  %heap_start = sub i64 %14, 14
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %struct_member = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 0
  store ptr %3, ptr %struct_member, align 8
  %struct_member12 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 1
  store i64 %decode_value, ptr %struct_member12, align 4
  %struct_member13 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 2
  store i64 %decode_value2, ptr %struct_member13, align 4
  %struct_member14 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 3
  store i64 %decode_value4, ptr %struct_member14, align 4
  %struct_member15 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 4
  store ptr %7, ptr %struct_member15, align 8
  %struct_member16 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 5
  store ptr %9, ptr %struct_member16, align 8
  %struct_member17 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 6
  store ptr %11, ptr %struct_member17, align 8
  %struct_member18 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr, i32 0, i32 7
  store ptr %13, ptr %struct_member18, align 8
  %15 = add i64 %input_start, %struct_decode_size
  %16 = inttoptr i64 %15 to ptr
  %decode_value19 = load i64, ptr %16, align 4
  %17 = call ptr @system_entrance(ptr %heap_to_ptr, i64 %decode_value19)
  %length20 = load i64, ptr %17, align 4
  %18 = add i64 %length20, 1
  %heap_size = add i64 %18, 1
  %19 = call i64 @vector_new(i64 %heap_size)
  %heap_start21 = sub i64 %19, %heap_size
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  %length23 = load i64, ptr %17, align 4
  %20 = ptrtoint ptr %heap_to_ptr22 to i64
  %buffer_start = add i64 %20, 1
  %21 = inttoptr i64 %buffer_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %21, i64 1
  store i64 %length23, ptr %encode_value_ptr, align 4
  %22 = ptrtoint ptr %17 to i64
  %23 = add i64 %22, 1
  %vector_data = inttoptr i64 %23 to ptr
  call void @memcpy(ptr %vector_data, ptr %21, i64 %length23)
  %24 = add i64 %length23, 1
  %25 = add i64 %24, 0
  %encode_value_ptr24 = getelementptr i64, ptr %heap_to_ptr22, i64 %25
  store i64 %18, ptr %encode_value_ptr24, align 4
  call void @set_tape_data(i64 %heap_start21, i64 %heap_size)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start25 = ptrtoint ptr %input to i64
  %26 = inttoptr i64 %input_start25 to ptr
  %struct_offset26 = add i64 %input_start25, 4
  %27 = inttoptr i64 %struct_offset26 to ptr
  %decode_value27 = load i64, ptr %27, align 4
  %struct_offset28 = add i64 %struct_offset26, 1
  %28 = inttoptr i64 %struct_offset28 to ptr
  %decode_value29 = load i64, ptr %28, align 4
  %struct_offset30 = add i64 %struct_offset28, 1
  %29 = inttoptr i64 %struct_offset30 to ptr
  %decode_value31 = load i64, ptr %29, align 4
  %struct_offset32 = add i64 %struct_offset30, 1
  %30 = inttoptr i64 %struct_offset32 to ptr
  %length33 = load i64, ptr %30, align 4
  %31 = add i64 %length33, 1
  %struct_offset34 = add i64 %struct_offset32, %31
  %32 = inttoptr i64 %struct_offset34 to ptr
  %length35 = load i64, ptr %32, align 4
  %33 = add i64 %length35, 1
  %struct_offset36 = add i64 %struct_offset34, %33
  %34 = inttoptr i64 %struct_offset36 to ptr
  %length37 = load i64, ptr %34, align 4
  %35 = add i64 %length37, 1
  %struct_offset38 = add i64 %struct_offset36, %35
  %36 = inttoptr i64 %struct_offset38 to ptr
  %struct_offset39 = add i64 %struct_offset38, 4
  %struct_decode_size40 = sub i64 %struct_offset39, %input_start25
  %37 = call i64 @vector_new(i64 14)
  %heap_start41 = sub i64 %37, 14
  %heap_to_ptr42 = inttoptr i64 %heap_start41 to ptr
  %struct_member43 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 0
  store ptr %26, ptr %struct_member43, align 8
  %struct_member44 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 1
  store i64 %decode_value27, ptr %struct_member44, align 4
  %struct_member45 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 2
  store i64 %decode_value29, ptr %struct_member45, align 4
  %struct_member46 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 3
  store i64 %decode_value31, ptr %struct_member46, align 4
  %struct_member47 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 4
  store ptr %30, ptr %struct_member47, align 8
  %struct_member48 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 5
  store ptr %32, ptr %struct_member48, align 8
  %struct_member49 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 6
  store ptr %34, ptr %struct_member49, align 8
  %struct_member50 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr42, i32 0, i32 7
  store ptr %36, ptr %struct_member50, align 8
  call void @validateTxStructure(ptr %heap_to_ptr42)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %input_start51 = ptrtoint ptr %input to i64
  %38 = inttoptr i64 %input_start51 to ptr
  %struct_offset52 = add i64 %input_start51, 4
  %39 = inttoptr i64 %struct_offset52 to ptr
  %decode_value53 = load i64, ptr %39, align 4
  %struct_offset54 = add i64 %struct_offset52, 1
  %40 = inttoptr i64 %struct_offset54 to ptr
  %decode_value55 = load i64, ptr %40, align 4
  %struct_offset56 = add i64 %struct_offset54, 1
  %41 = inttoptr i64 %struct_offset56 to ptr
  %decode_value57 = load i64, ptr %41, align 4
  %struct_offset58 = add i64 %struct_offset56, 1
  %42 = inttoptr i64 %struct_offset58 to ptr
  %length59 = load i64, ptr %42, align 4
  %43 = add i64 %length59, 1
  %struct_offset60 = add i64 %struct_offset58, %43
  %44 = inttoptr i64 %struct_offset60 to ptr
  %length61 = load i64, ptr %44, align 4
  %45 = add i64 %length61, 1
  %struct_offset62 = add i64 %struct_offset60, %45
  %46 = inttoptr i64 %struct_offset62 to ptr
  %length63 = load i64, ptr %46, align 4
  %47 = add i64 %length63, 1
  %struct_offset64 = add i64 %struct_offset62, %47
  %48 = inttoptr i64 %struct_offset64 to ptr
  %struct_offset65 = add i64 %struct_offset64, 4
  %struct_decode_size66 = sub i64 %struct_offset65, %input_start51
  %49 = call i64 @vector_new(i64 14)
  %heap_start67 = sub i64 %49, 14
  %heap_to_ptr68 = inttoptr i64 %heap_start67 to ptr
  %struct_member69 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 0
  store ptr %38, ptr %struct_member69, align 8
  %struct_member70 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 1
  store i64 %decode_value53, ptr %struct_member70, align 4
  %struct_member71 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 2
  store i64 %decode_value55, ptr %struct_member71, align 4
  %struct_member72 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 3
  store i64 %decode_value57, ptr %struct_member72, align 4
  %struct_member73 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 4
  store ptr %42, ptr %struct_member73, align 8
  %struct_member74 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 5
  store ptr %44, ptr %struct_member74, align 8
  %struct_member75 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 6
  store ptr %46, ptr %struct_member75, align 8
  %struct_member76 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr68, i32 0, i32 7
  store ptr %48, ptr %struct_member76, align 8
  %50 = call ptr @callTx(ptr %heap_to_ptr68)
  %length77 = load i64, ptr %50, align 4
  %51 = add i64 %length77, 1
  %heap_size78 = add i64 %51, 1
  %52 = call i64 @vector_new(i64 %heap_size78)
  %heap_start79 = sub i64 %52, %heap_size78
  %heap_to_ptr80 = inttoptr i64 %heap_start79 to ptr
  %length81 = load i64, ptr %50, align 4
  %53 = ptrtoint ptr %heap_to_ptr80 to i64
  %buffer_start82 = add i64 %53, 1
  %54 = inttoptr i64 %buffer_start82 to ptr
  %encode_value_ptr83 = getelementptr i64, ptr %54, i64 1
  store i64 %length81, ptr %encode_value_ptr83, align 4
  %55 = ptrtoint ptr %50 to i64
  %56 = add i64 %55, 1
  %vector_data84 = inttoptr i64 %56 to ptr
  call void @memcpy(ptr %vector_data84, ptr %54, i64 %length81)
  %57 = add i64 %length81, 1
  %58 = add i64 %57, 0
  %encode_value_ptr85 = getelementptr i64, ptr %heap_to_ptr80, i64 %58
  store i64 %51, ptr %encode_value_ptr85, align 4
  call void @set_tape_data(i64 %heap_start79, i64 %heap_size78)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %input_start86 = ptrtoint ptr %input to i64
  %59 = inttoptr i64 %input_start86 to ptr
  %struct_offset87 = add i64 %input_start86, 4
  %60 = inttoptr i64 %struct_offset87 to ptr
  %decode_value88 = load i64, ptr %60, align 4
  %struct_offset89 = add i64 %struct_offset87, 1
  %61 = inttoptr i64 %struct_offset89 to ptr
  %decode_value90 = load i64, ptr %61, align 4
  %struct_offset91 = add i64 %struct_offset89, 1
  %62 = inttoptr i64 %struct_offset91 to ptr
  %decode_value92 = load i64, ptr %62, align 4
  %struct_offset93 = add i64 %struct_offset91, 1
  %63 = inttoptr i64 %struct_offset93 to ptr
  %length94 = load i64, ptr %63, align 4
  %64 = add i64 %length94, 1
  %struct_offset95 = add i64 %struct_offset93, %64
  %65 = inttoptr i64 %struct_offset95 to ptr
  %length96 = load i64, ptr %65, align 4
  %66 = add i64 %length96, 1
  %struct_offset97 = add i64 %struct_offset95, %66
  %67 = inttoptr i64 %struct_offset97 to ptr
  %length98 = load i64, ptr %67, align 4
  %68 = add i64 %length98, 1
  %struct_offset99 = add i64 %struct_offset97, %68
  %69 = inttoptr i64 %struct_offset99 to ptr
  %struct_offset100 = add i64 %struct_offset99, 4
  %struct_decode_size101 = sub i64 %struct_offset100, %input_start86
  %70 = call i64 @vector_new(i64 14)
  %heap_start102 = sub i64 %70, 14
  %heap_to_ptr103 = inttoptr i64 %heap_start102 to ptr
  %struct_member104 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 0
  store ptr %59, ptr %struct_member104, align 8
  %struct_member105 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 1
  store i64 %decode_value88, ptr %struct_member105, align 4
  %struct_member106 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 2
  store i64 %decode_value90, ptr %struct_member106, align 4
  %struct_member107 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 3
  store i64 %decode_value92, ptr %struct_member107, align 4
  %struct_member108 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 4
  store ptr %63, ptr %struct_member108, align 8
  %struct_member109 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 5
  store ptr %65, ptr %struct_member109, align 8
  %struct_member110 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 6
  store ptr %67, ptr %struct_member110, align 8
  %struct_member111 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr103, i32 0, i32 7
  store ptr %69, ptr %struct_member111, align 8
  call void @sendTx(ptr %heap_to_ptr103)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %input_start112 = ptrtoint ptr %input to i64
  %71 = inttoptr i64 %input_start112 to ptr
  %struct_offset113 = add i64 %input_start112, 4
  %72 = inttoptr i64 %struct_offset113 to ptr
  %decode_value114 = load i64, ptr %72, align 4
  %struct_offset115 = add i64 %struct_offset113, 1
  %73 = inttoptr i64 %struct_offset115 to ptr
  %decode_value116 = load i64, ptr %73, align 4
  %struct_offset117 = add i64 %struct_offset115, 1
  %74 = inttoptr i64 %struct_offset117 to ptr
  %decode_value118 = load i64, ptr %74, align 4
  %struct_offset119 = add i64 %struct_offset117, 1
  %75 = inttoptr i64 %struct_offset119 to ptr
  %length120 = load i64, ptr %75, align 4
  %76 = add i64 %length120, 1
  %struct_offset121 = add i64 %struct_offset119, %76
  %77 = inttoptr i64 %struct_offset121 to ptr
  %length122 = load i64, ptr %77, align 4
  %78 = add i64 %length122, 1
  %struct_offset123 = add i64 %struct_offset121, %78
  %79 = inttoptr i64 %struct_offset123 to ptr
  %length124 = load i64, ptr %79, align 4
  %80 = add i64 %length124, 1
  %struct_offset125 = add i64 %struct_offset123, %80
  %81 = inttoptr i64 %struct_offset125 to ptr
  %struct_offset126 = add i64 %struct_offset125, 4
  %struct_decode_size127 = sub i64 %struct_offset126, %input_start112
  %82 = call i64 @vector_new(i64 14)
  %heap_start128 = sub i64 %82, 14
  %heap_to_ptr129 = inttoptr i64 %heap_start128 to ptr
  %struct_member130 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 0
  store ptr %71, ptr %struct_member130, align 8
  %struct_member131 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 1
  store i64 %decode_value114, ptr %struct_member131, align 4
  %struct_member132 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 2
  store i64 %decode_value116, ptr %struct_member132, align 4
  %struct_member133 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 3
  store i64 %decode_value118, ptr %struct_member133, align 4
  %struct_member134 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 4
  store ptr %75, ptr %struct_member134, align 8
  %struct_member135 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 5
  store ptr %77, ptr %struct_member135, align 8
  %struct_member136 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 6
  store ptr %79, ptr %struct_member136, align 8
  %struct_member137 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr129, i32 0, i32 7
  store ptr %81, ptr %struct_member137, align 8
  call void @validateTx(ptr %heap_to_ptr129)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %input_start138 = ptrtoint ptr %input to i64
  %83 = inttoptr i64 %input_start138 to ptr
  %struct_offset139 = add i64 %input_start138, 4
  %84 = inttoptr i64 %struct_offset139 to ptr
  %decode_value140 = load i64, ptr %84, align 4
  %struct_offset141 = add i64 %struct_offset139, 1
  %85 = inttoptr i64 %struct_offset141 to ptr
  %decode_value142 = load i64, ptr %85, align 4
  %struct_offset143 = add i64 %struct_offset141, 1
  %86 = inttoptr i64 %struct_offset143 to ptr
  %decode_value144 = load i64, ptr %86, align 4
  %struct_offset145 = add i64 %struct_offset143, 1
  %87 = inttoptr i64 %struct_offset145 to ptr
  %length146 = load i64, ptr %87, align 4
  %88 = add i64 %length146, 1
  %struct_offset147 = add i64 %struct_offset145, %88
  %89 = inttoptr i64 %struct_offset147 to ptr
  %length148 = load i64, ptr %89, align 4
  %90 = add i64 %length148, 1
  %struct_offset149 = add i64 %struct_offset147, %90
  %91 = inttoptr i64 %struct_offset149 to ptr
  %length150 = load i64, ptr %91, align 4
  %92 = add i64 %length150, 1
  %struct_offset151 = add i64 %struct_offset149, %92
  %93 = inttoptr i64 %struct_offset151 to ptr
  %struct_offset152 = add i64 %struct_offset151, 4
  %struct_decode_size153 = sub i64 %struct_offset152, %input_start138
  %94 = call i64 @vector_new(i64 14)
  %heap_start154 = sub i64 %94, 14
  %heap_to_ptr155 = inttoptr i64 %heap_start154 to ptr
  %struct_member156 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 0
  store ptr %83, ptr %struct_member156, align 8
  %struct_member157 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 1
  store i64 %decode_value140, ptr %struct_member157, align 4
  %struct_member158 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 2
  store i64 %decode_value142, ptr %struct_member158, align 4
  %struct_member159 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 3
  store i64 %decode_value144, ptr %struct_member159, align 4
  %struct_member160 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 4
  store ptr %87, ptr %struct_member160, align 8
  %struct_member161 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 5
  store ptr %89, ptr %struct_member161, align 8
  %struct_member162 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 6
  store ptr %91, ptr %struct_member162, align 8
  %struct_member163 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr155, i32 0, i32 7
  store ptr %93, ptr %struct_member163, align 8
  call void @validateDeployment(ptr %heap_to_ptr155)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %input_start164 = ptrtoint ptr %input to i64
  %95 = inttoptr i64 %input_start164 to ptr
  %struct_offset165 = add i64 %input_start164, 4
  %96 = inttoptr i64 %struct_offset165 to ptr
  %decode_value166 = load i64, ptr %96, align 4
  %struct_offset167 = add i64 %struct_offset165, 1
  %97 = inttoptr i64 %struct_offset167 to ptr
  %decode_value168 = load i64, ptr %97, align 4
  %struct_offset169 = add i64 %struct_offset167, 1
  %98 = inttoptr i64 %struct_offset169 to ptr
  %decode_value170 = load i64, ptr %98, align 4
  %struct_offset171 = add i64 %struct_offset169, 1
  %99 = inttoptr i64 %struct_offset171 to ptr
  %length172 = load i64, ptr %99, align 4
  %100 = add i64 %length172, 1
  %struct_offset173 = add i64 %struct_offset171, %100
  %101 = inttoptr i64 %struct_offset173 to ptr
  %length174 = load i64, ptr %101, align 4
  %102 = add i64 %length174, 1
  %struct_offset175 = add i64 %struct_offset173, %102
  %103 = inttoptr i64 %struct_offset175 to ptr
  %length176 = load i64, ptr %103, align 4
  %104 = add i64 %length176, 1
  %struct_offset177 = add i64 %struct_offset175, %104
  %105 = inttoptr i64 %struct_offset177 to ptr
  %struct_offset178 = add i64 %struct_offset177, 4
  %struct_decode_size179 = sub i64 %struct_offset178, %input_start164
  %106 = call i64 @vector_new(i64 14)
  %heap_start180 = sub i64 %106, 14
  %heap_to_ptr181 = inttoptr i64 %heap_start180 to ptr
  %struct_member182 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 0
  store ptr %95, ptr %struct_member182, align 8
  %struct_member183 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 1
  store i64 %decode_value166, ptr %struct_member183, align 4
  %struct_member184 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 2
  store i64 %decode_value168, ptr %struct_member184, align 4
  %struct_member185 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 3
  store i64 %decode_value170, ptr %struct_member185, align 4
  %struct_member186 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 4
  store ptr %99, ptr %struct_member186, align 8
  %struct_member187 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 5
  store ptr %101, ptr %struct_member187, align 8
  %struct_member188 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 6
  store ptr %103, ptr %struct_member188, align 8
  %struct_member189 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr181, i32 0, i32 7
  store ptr %105, ptr %struct_member189, align 8
  %107 = call ptr @getSignedHash(ptr %heap_to_ptr181)
  %108 = call i64 @vector_new(i64 5)
  %heap_start190 = sub i64 %108, 5
  %heap_to_ptr191 = inttoptr i64 %heap_start190 to ptr
  %109 = getelementptr i64, ptr %107, i64 0
  %110 = load i64, ptr %109, align 4
  %encode_value_ptr192 = getelementptr i64, ptr %heap_to_ptr191, i64 0
  store i64 %110, ptr %encode_value_ptr192, align 4
  %111 = getelementptr i64, ptr %107, i64 1
  %112 = load i64, ptr %111, align 4
  %encode_value_ptr193 = getelementptr i64, ptr %heap_to_ptr191, i64 1
  store i64 %112, ptr %encode_value_ptr193, align 4
  %113 = getelementptr i64, ptr %107, i64 2
  %114 = load i64, ptr %113, align 4
  %encode_value_ptr194 = getelementptr i64, ptr %heap_to_ptr191, i64 2
  store i64 %114, ptr %encode_value_ptr194, align 4
  %115 = getelementptr i64, ptr %107, i64 3
  %116 = load i64, ptr %115, align 4
  %encode_value_ptr195 = getelementptr i64, ptr %heap_to_ptr191, i64 3
  store i64 %116, ptr %encode_value_ptr195, align 4
  %encode_value_ptr196 = getelementptr i64, ptr %heap_to_ptr191, i64 4
  store i64 4, ptr %encode_value_ptr196, align 4
  call void @set_tape_data(i64 %heap_start190, i64 5)
  ret void

func_7_dispatch:                                  ; preds = %entry
  %input_start197 = ptrtoint ptr %input to i64
  %117 = inttoptr i64 %input_start197 to ptr
  %118 = add i64 %input_start197, 4
  %119 = inttoptr i64 %118 to ptr
  %length198 = load i64, ptr %119, align 4
  %120 = add i64 %length198, 1
  %121 = call ptr @getTransactionHash(ptr %117, ptr %119)
  %122 = call i64 @vector_new(i64 5)
  %heap_start199 = sub i64 %122, 5
  %heap_to_ptr200 = inttoptr i64 %heap_start199 to ptr
  %123 = getelementptr i64, ptr %121, i64 0
  %124 = load i64, ptr %123, align 4
  %encode_value_ptr201 = getelementptr i64, ptr %heap_to_ptr200, i64 0
  store i64 %124, ptr %encode_value_ptr201, align 4
  %125 = getelementptr i64, ptr %121, i64 1
  %126 = load i64, ptr %125, align 4
  %encode_value_ptr202 = getelementptr i64, ptr %heap_to_ptr200, i64 1
  store i64 %126, ptr %encode_value_ptr202, align 4
  %127 = getelementptr i64, ptr %121, i64 2
  %128 = load i64, ptr %127, align 4
  %encode_value_ptr203 = getelementptr i64, ptr %heap_to_ptr200, i64 2
  store i64 %128, ptr %encode_value_ptr203, align 4
  %129 = getelementptr i64, ptr %121, i64 3
  %130 = load i64, ptr %129, align 4
  %encode_value_ptr204 = getelementptr i64, ptr %heap_to_ptr200, i64 3
  store i64 %130, ptr %encode_value_ptr204, align 4
  %encode_value_ptr205 = getelementptr i64, ptr %heap_to_ptr200, i64 4
  store i64 4, ptr %encode_value_ptr205, align 4
  call void @set_tape_data(i64 %heap_start199, i64 5)
  ret void

func_8_dispatch:                                  ; preds = %entry
  %input_start206 = ptrtoint ptr %input to i64
  %131 = inttoptr i64 %input_start206 to ptr
  call void @validate_sender(ptr %131)
  ret void

func_9_dispatch:                                  ; preds = %entry
  %input_start207 = ptrtoint ptr %input to i64
  %132 = inttoptr i64 %input_start207 to ptr
  %133 = add i64 %input_start207, 4
  %134 = inttoptr i64 %133 to ptr
  %decode_value208 = load i64, ptr %134, align 4
  call void @validate_nonce(ptr %132, i64 %decode_value208)
  ret void

func_10_dispatch:                                 ; preds = %entry
  %input_start209 = ptrtoint ptr %input to i64
  %135 = inttoptr i64 %input_start209 to ptr
  %136 = add i64 %input_start209, 4
  %137 = inttoptr i64 %136 to ptr
  %138 = add i64 %136, 4
  %139 = inttoptr i64 %138 to ptr
  %struct_offset210 = add i64 %138, 4
  %140 = inttoptr i64 %struct_offset210 to ptr
  %decode_value211 = load i64, ptr %140, align 4
  %struct_offset212 = add i64 %struct_offset210, 1
  %141 = inttoptr i64 %struct_offset212 to ptr
  %decode_value213 = load i64, ptr %141, align 4
  %struct_offset214 = add i64 %struct_offset212, 1
  %142 = inttoptr i64 %struct_offset214 to ptr
  %decode_value215 = load i64, ptr %142, align 4
  %struct_offset216 = add i64 %struct_offset214, 1
  %143 = inttoptr i64 %struct_offset216 to ptr
  %length217 = load i64, ptr %143, align 4
  %144 = add i64 %length217, 1
  %struct_offset218 = add i64 %struct_offset216, %144
  %145 = inttoptr i64 %struct_offset218 to ptr
  %length219 = load i64, ptr %145, align 4
  %146 = add i64 %length219, 1
  %struct_offset220 = add i64 %struct_offset218, %146
  %147 = inttoptr i64 %struct_offset220 to ptr
  %length221 = load i64, ptr %147, align 4
  %148 = add i64 %length221, 1
  %struct_offset222 = add i64 %struct_offset220, %148
  %149 = inttoptr i64 %struct_offset222 to ptr
  %struct_offset223 = add i64 %struct_offset222, 4
  %struct_decode_size224 = sub i64 %struct_offset223, %138
  %150 = call i64 @vector_new(i64 14)
  %heap_start225 = sub i64 %150, 14
  %heap_to_ptr226 = inttoptr i64 %heap_start225 to ptr
  %struct_member227 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 0
  store ptr %139, ptr %struct_member227, align 8
  %struct_member228 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 1
  store i64 %decode_value211, ptr %struct_member228, align 4
  %struct_member229 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 2
  store i64 %decode_value213, ptr %struct_member229, align 4
  %struct_member230 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 3
  store i64 %decode_value215, ptr %struct_member230, align 4
  %struct_member231 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 4
  store ptr %143, ptr %struct_member231, align 8
  %struct_member232 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 5
  store ptr %145, ptr %struct_member232, align 8
  %struct_member233 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 6
  store ptr %147, ptr %struct_member233, align 8
  %struct_member234 = getelementptr inbounds { ptr, i64, i64, i64, ptr, ptr, ptr, ptr }, ptr %heap_to_ptr226, i32 0, i32 7
  store ptr %149, ptr %struct_member234, align 8
  call void @validate_tx(ptr %135, ptr %137, ptr %heap_to_ptr226)
  ret void

func_11_dispatch:                                 ; preds = %entry
  %input_start235 = ptrtoint ptr %input to i64
  %151 = inttoptr i64 %input_start235 to ptr
  %length236 = load i64, ptr %151, align 4
  %152 = add i64 %length236, 1
  %153 = call ptr @hashL2Bytecode(ptr %151)
  %154 = call i64 @vector_new(i64 5)
  %heap_start237 = sub i64 %154, 5
  %heap_to_ptr238 = inttoptr i64 %heap_start237 to ptr
  %155 = getelementptr i64, ptr %153, i64 0
  %156 = load i64, ptr %155, align 4
  %encode_value_ptr239 = getelementptr i64, ptr %heap_to_ptr238, i64 0
  store i64 %156, ptr %encode_value_ptr239, align 4
  %157 = getelementptr i64, ptr %153, i64 1
  %158 = load i64, ptr %157, align 4
  %encode_value_ptr240 = getelementptr i64, ptr %heap_to_ptr238, i64 1
  store i64 %158, ptr %encode_value_ptr240, align 4
  %159 = getelementptr i64, ptr %153, i64 2
  %160 = load i64, ptr %159, align 4
  %encode_value_ptr241 = getelementptr i64, ptr %heap_to_ptr238, i64 2
  store i64 %160, ptr %encode_value_ptr241, align 4
  %161 = getelementptr i64, ptr %153, i64 3
  %162 = load i64, ptr %161, align 4
  %encode_value_ptr242 = getelementptr i64, ptr %heap_to_ptr238, i64 3
  store i64 %162, ptr %encode_value_ptr242, align 4
  %encode_value_ptr243 = getelementptr i64, ptr %heap_to_ptr238, i64 4
  store i64 4, ptr %encode_value_ptr243, align 4
  call void @set_tape_data(i64 %heap_start237, i64 5)
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
