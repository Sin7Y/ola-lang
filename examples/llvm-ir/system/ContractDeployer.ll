; ModuleID = 'ContractDeployer'
source_filename = "examples/source/system/ContractDeployer.ola"

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

define i64 @extendedAccountVersion(ptr %0) {
entry:
  %codeHash = alloca ptr, align 8
  %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT = alloca ptr, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = load ptr, ptr %_address, align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %5, align 4
  %6 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %6, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  %7 = inttoptr i64 %heap_start1 to ptr
  call void @memcpy(ptr %heap_to_ptr, ptr %7, i64 4)
  %next_dest_offset = add i64 %heap_start1, 4
  %8 = inttoptr i64 %next_dest_offset to ptr
  call void @memcpy(ptr %1, ptr %8, i64 4)
  %9 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %9, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %10 = call i64 @vector_new(i64 2)
  %heap_start5 = sub i64 %10, 2
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %11 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %11, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @get_storage(ptr %heap_to_ptr4, ptr %heap_to_ptr8)
  %storage_value = load i64, ptr %heap_to_ptr8, align 4
  %slot_value = load i64, ptr %heap_to_ptr4, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr4, align 4
  %supportedAAVersion = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr6, i32 0, i32 0
  store i64 %storage_value, ptr %supportedAAVersion, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %12, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @get_storage(ptr %heap_to_ptr4, ptr %heap_to_ptr10)
  %storage_value11 = load i64, ptr %heap_to_ptr10, align 4
  %slot_value12 = load i64, ptr %heap_to_ptr4, align 4
  %slot_offset13 = add i64 %slot_value12, 1
  store i64 %slot_offset13, ptr %heap_to_ptr4, align 4
  %nonceOrdering = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr6, i32 0, i32 1
  store i64 %storage_value11, ptr %nonceOrdering, align 4
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr6, i32 0, i32 0
  %13 = load i64, ptr %struct_member, align 4
  %14 = icmp ne i64 %13, 0
  br i1 %14, label %then, label %enif

then:                                             ; preds = %entry
  %struct_member14 = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr6, i32 0, i32 0
  %15 = load i64, ptr %struct_member14, align 4
  ret i64 %15

enif:                                             ; preds = %entry
  %16 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %16, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr16, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access17 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %index_access17, align 4
  %index_access18 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %index_access18, align 4
  %index_access19 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 32770, ptr %index_access19, align 4
  store ptr %heap_to_ptr16, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %17 = load ptr, ptr %_address, align 8
  %18 = call i64 @vector_new(i64 7)
  %heap_start20 = sub i64 %18, 7
  %heap_to_ptr21 = inttoptr i64 %heap_start20 to ptr
  store i64 6, ptr %heap_to_ptr21, align 4
  %19 = getelementptr i64, ptr %17, i64 0
  %20 = load i64, ptr %19, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr21, i64 1
  store i64 %20, ptr %encode_value_ptr, align 4
  %21 = getelementptr i64, ptr %17, i64 1
  %22 = load i64, ptr %21, align 4
  %encode_value_ptr22 = getelementptr i64, ptr %heap_to_ptr21, i64 2
  store i64 %22, ptr %encode_value_ptr22, align 4
  %23 = getelementptr i64, ptr %17, i64 2
  %24 = load i64, ptr %23, align 4
  %encode_value_ptr23 = getelementptr i64, ptr %heap_to_ptr21, i64 3
  store i64 %24, ptr %encode_value_ptr23, align 4
  %25 = getelementptr i64, ptr %17, i64 3
  %26 = load i64, ptr %25, align 4
  %encode_value_ptr24 = getelementptr i64, ptr %heap_to_ptr21, i64 4
  store i64 %26, ptr %encode_value_ptr24, align 4
  %encode_value_ptr25 = getelementptr i64, ptr %heap_to_ptr21, i64 5
  store i64 4, ptr %encode_value_ptr25, align 4
  %encode_value_ptr26 = getelementptr i64, ptr %heap_to_ptr21, i64 6
  store i64 2179613704, ptr %encode_value_ptr26, align 4
  %27 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %payload_len = load i64, ptr %heap_to_ptr21, align 4
  %tape_size = add i64 %payload_len, 2
  %28 = ptrtoint ptr %heap_to_ptr21 to i64
  %payload_start = add i64 %28, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %27, i64 0)
  %29 = call i64 @vector_new(i64 1)
  %heap_start27 = sub i64 %29, 1
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  call void @get_tape_data(i64 %heap_start27, i64 1)
  %return_length = load i64, ptr %heap_to_ptr28, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size29 = add i64 %return_length, 1
  %30 = call i64 @vector_new(i64 %heap_size)
  %heap_start30 = sub i64 %30, %heap_size
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  store i64 %return_length, ptr %heap_to_ptr31, align 4
  %31 = add i64 %heap_start30, 1
  call void @get_tape_data(i64 %31, i64 %tape_size29)
  %length = load i64, ptr %heap_to_ptr31, align 4
  %32 = ptrtoint ptr %heap_to_ptr31 to i64
  %33 = add i64 %32, 1
  %vector_data = inttoptr i64 %33 to ptr
  %input_start = ptrtoint ptr %vector_data to i64
  %34 = inttoptr i64 %input_start to ptr
  store ptr %34, ptr %codeHash, align 8
  %35 = load ptr, ptr %codeHash, align 8
  %36 = call i64 @vector_new(i64 4)
  %heap_start32 = sub i64 %36, 4
  %heap_to_ptr33 = inttoptr i64 %heap_start32 to ptr
  %index_access34 = getelementptr i64, ptr %heap_to_ptr33, i64 0
  store i64 0, ptr %index_access34, align 4
  %index_access35 = getelementptr i64, ptr %heap_to_ptr33, i64 1
  store i64 0, ptr %index_access35, align 4
  %index_access36 = getelementptr i64, ptr %heap_to_ptr33, i64 2
  store i64 0, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %heap_to_ptr33, i64 3
  store i64 0, ptr %index_access37, align 4
  %37 = call i64 @memcmp_eq(ptr %35, ptr %heap_to_ptr33, i64 4)
  %38 = trunc i64 %37 to i1
  br i1 %38, label %then38, label %enif39

then38:                                           ; preds = %enif
  ret i64 1

enif39:                                           ; preds = %enif
  ret i64 0
}

define ptr @create2(ptr %0, ptr %1, ptr %2) {
entry:
  %_input = alloca ptr, align 8
  %_bytecodeHash = alloca ptr, align 8
  %_salt = alloca ptr, align 8
  store ptr %0, ptr %_salt, align 8
  store ptr %1, ptr %_bytecodeHash, align 8
  store ptr %2, ptr %_input, align 8
  %3 = load ptr, ptr %_input, align 8
  %4 = load ptr, ptr %_salt, align 8
  %5 = load ptr, ptr %_bytecodeHash, align 8
  %6 = call ptr @create2Account(ptr %4, ptr %5, ptr %3, i64 0)
  ret ptr %6
}

define ptr @create2Account(ptr %0, ptr %1, ptr %2, i64 %3) {
entry:
  %newAddress = alloca ptr, align 8
  %_aaVersion = alloca i64, align 8
  %_input = alloca ptr, align 8
  %_bytecodeHash = alloca ptr, align 8
  %_salt = alloca ptr, align 8
  store ptr %0, ptr %_salt, align 8
  store ptr %1, ptr %_bytecodeHash, align 8
  store ptr %2, ptr %_input, align 8
  %4 = load ptr, ptr %_input, align 8
  store i64 %3, ptr %_aaVersion, align 4
  %5 = call i64 @vector_new(i64 12)
  %heap_start = sub i64 %5, 12
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 12)
  %6 = load ptr, ptr %_bytecodeHash, align 8
  %7 = load ptr, ptr %_salt, align 8
  %8 = call ptr @getNewAddressCreate2(ptr %heap_to_ptr, ptr %6, ptr %7, ptr %4)
  store ptr %8, ptr %newAddress, align 8
  %9 = load ptr, ptr %_bytecodeHash, align 8
  %10 = load ptr, ptr %newAddress, align 8
  %11 = load i64, ptr %_aaVersion, align 4
  call void @_nonSystemDeployOnAddress(ptr %9, ptr %10, i64 %11, ptr %4)
  %12 = load ptr, ptr %newAddress, align 8
  ret ptr %12
}

define ptr @getNewAddressCreate2(ptr %0, ptr %1, ptr %2, ptr %3) {
entry:
  %_hash = alloca ptr, align 8
  %constructorInputHash = alloca ptr, align 8
  %CREATE2_PREFIX = alloca ptr, align 8
  %_input = alloca ptr, align 8
  %_salt = alloca ptr, align 8
  %_bytecodeHash = alloca ptr, align 8
  %_sender = alloca ptr, align 8
  store ptr %0, ptr %_sender, align 8
  store ptr %1, ptr %_bytecodeHash, align 8
  store ptr %2, ptr %_salt, align 8
  store ptr %3, ptr %_input, align 8
  %4 = load ptr, ptr %_input, align 8
  %5 = call i64 @vector_new(i64 11)
  %heap_start = sub i64 %5, 11
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 10, ptr %heap_to_ptr, align 4
  %6 = ptrtoint ptr %heap_to_ptr to i64
  %7 = add i64 %6, 1
  %vector_data = inttoptr i64 %7 to ptr
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
  %length = load i64, ptr %heap_to_ptr, align 4
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %9 = add i64 %8, 1
  %vector_data10 = inttoptr i64 %9 to ptr
  %10 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %10, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @poseidon_hash(ptr %vector_data10, ptr %heap_to_ptr12, i64 %length)
  store ptr %heap_to_ptr12, ptr %CREATE2_PREFIX, align 8
  %length13 = load i64, ptr %4, align 4
  %11 = ptrtoint ptr %4 to i64
  %12 = add i64 %11, 1
  %vector_data14 = inttoptr i64 %12 to ptr
  %13 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %13, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  call void @poseidon_hash(ptr %vector_data14, ptr %heap_to_ptr16, i64 %length13)
  store ptr %heap_to_ptr16, ptr %constructorInputHash, align 8
  %14 = load ptr, ptr %CREATE2_PREFIX, align 8
  %15 = load ptr, ptr %_sender, align 8
  %16 = load ptr, ptr %_salt, align 8
  %17 = load ptr, ptr %_bytecodeHash, align 8
  %18 = load ptr, ptr %constructorInputHash, align 8
  %19 = call i64 @vector_new(i64 21)
  %heap_start17 = sub i64 %19, 21
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 20, ptr %heap_to_ptr18, align 4
  %20 = getelementptr i64, ptr %14, i64 0
  %21 = load i64, ptr %20, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 %21, ptr %encode_value_ptr, align 4
  %22 = getelementptr i64, ptr %14, i64 1
  %23 = load i64, ptr %22, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 %23, ptr %encode_value_ptr19, align 4
  %24 = getelementptr i64, ptr %14, i64 2
  %25 = load i64, ptr %24, align 4
  %encode_value_ptr20 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 %25, ptr %encode_value_ptr20, align 4
  %26 = getelementptr i64, ptr %14, i64 3
  %27 = load i64, ptr %26, align 4
  %encode_value_ptr21 = getelementptr i64, ptr %heap_to_ptr18, i64 4
  store i64 %27, ptr %encode_value_ptr21, align 4
  %28 = getelementptr i64, ptr %15, i64 0
  %29 = load i64, ptr %28, align 4
  %encode_value_ptr22 = getelementptr i64, ptr %heap_to_ptr18, i64 5
  store i64 %29, ptr %encode_value_ptr22, align 4
  %30 = getelementptr i64, ptr %15, i64 1
  %31 = load i64, ptr %30, align 4
  %encode_value_ptr23 = getelementptr i64, ptr %heap_to_ptr18, i64 6
  store i64 %31, ptr %encode_value_ptr23, align 4
  %32 = getelementptr i64, ptr %15, i64 2
  %33 = load i64, ptr %32, align 4
  %encode_value_ptr24 = getelementptr i64, ptr %heap_to_ptr18, i64 7
  store i64 %33, ptr %encode_value_ptr24, align 4
  %34 = getelementptr i64, ptr %15, i64 3
  %35 = load i64, ptr %34, align 4
  %encode_value_ptr25 = getelementptr i64, ptr %heap_to_ptr18, i64 8
  store i64 %35, ptr %encode_value_ptr25, align 4
  %36 = getelementptr i64, ptr %16, i64 0
  %37 = load i64, ptr %36, align 4
  %encode_value_ptr26 = getelementptr i64, ptr %heap_to_ptr18, i64 9
  store i64 %37, ptr %encode_value_ptr26, align 4
  %38 = getelementptr i64, ptr %16, i64 1
  %39 = load i64, ptr %38, align 4
  %encode_value_ptr27 = getelementptr i64, ptr %heap_to_ptr18, i64 10
  store i64 %39, ptr %encode_value_ptr27, align 4
  %40 = getelementptr i64, ptr %16, i64 2
  %41 = load i64, ptr %40, align 4
  %encode_value_ptr28 = getelementptr i64, ptr %heap_to_ptr18, i64 11
  store i64 %41, ptr %encode_value_ptr28, align 4
  %42 = getelementptr i64, ptr %16, i64 3
  %43 = load i64, ptr %42, align 4
  %encode_value_ptr29 = getelementptr i64, ptr %heap_to_ptr18, i64 12
  store i64 %43, ptr %encode_value_ptr29, align 4
  %44 = getelementptr i64, ptr %17, i64 0
  %45 = load i64, ptr %44, align 4
  %encode_value_ptr30 = getelementptr i64, ptr %heap_to_ptr18, i64 13
  store i64 %45, ptr %encode_value_ptr30, align 4
  %46 = getelementptr i64, ptr %17, i64 1
  %47 = load i64, ptr %46, align 4
  %encode_value_ptr31 = getelementptr i64, ptr %heap_to_ptr18, i64 14
  store i64 %47, ptr %encode_value_ptr31, align 4
  %48 = getelementptr i64, ptr %17, i64 2
  %49 = load i64, ptr %48, align 4
  %encode_value_ptr32 = getelementptr i64, ptr %heap_to_ptr18, i64 15
  store i64 %49, ptr %encode_value_ptr32, align 4
  %50 = getelementptr i64, ptr %17, i64 3
  %51 = load i64, ptr %50, align 4
  %encode_value_ptr33 = getelementptr i64, ptr %heap_to_ptr18, i64 16
  store i64 %51, ptr %encode_value_ptr33, align 4
  %52 = getelementptr i64, ptr %18, i64 0
  %53 = load i64, ptr %52, align 4
  %encode_value_ptr34 = getelementptr i64, ptr %heap_to_ptr18, i64 17
  store i64 %53, ptr %encode_value_ptr34, align 4
  %54 = getelementptr i64, ptr %18, i64 1
  %55 = load i64, ptr %54, align 4
  %encode_value_ptr35 = getelementptr i64, ptr %heap_to_ptr18, i64 18
  store i64 %55, ptr %encode_value_ptr35, align 4
  %56 = getelementptr i64, ptr %18, i64 2
  %57 = load i64, ptr %56, align 4
  %encode_value_ptr36 = getelementptr i64, ptr %heap_to_ptr18, i64 19
  store i64 %57, ptr %encode_value_ptr36, align 4
  %58 = getelementptr i64, ptr %18, i64 3
  %59 = load i64, ptr %58, align 4
  %encode_value_ptr37 = getelementptr i64, ptr %heap_to_ptr18, i64 20
  store i64 %59, ptr %encode_value_ptr37, align 4
  %length38 = load i64, ptr %heap_to_ptr18, align 4
  %60 = ptrtoint ptr %heap_to_ptr18 to i64
  %61 = add i64 %60, 1
  %vector_data39 = inttoptr i64 %61 to ptr
  %62 = call i64 @vector_new(i64 4)
  %heap_start40 = sub i64 %62, 4
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  call void @poseidon_hash(ptr %vector_data39, ptr %heap_to_ptr41, i64 %length38)
  store ptr %heap_to_ptr41, ptr %_hash, align 8
  %63 = load ptr, ptr %_hash, align 8
  ret ptr %63
}

define void @_nonSystemDeployOnAddress(ptr %0, ptr %1, i64 %2, ptr %3) {
entry:
  %deploy_nonce = alloca i64, align 8
  %NONCE_HOLDER_ADDRESS = alloca ptr, align 8
  %codeHash = alloca ptr, align 8
  %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT = alloca ptr, align 8
  %MAX_SYSTEM_CONTRACT_ADDRESS = alloca ptr, align 8
  %_input = alloca ptr, align 8
  %_aaVersion = alloca i64, align 8
  %_newAddress = alloca ptr, align 8
  %_bytecodeHash = alloca ptr, align 8
  store ptr %0, ptr %_bytecodeHash, align 8
  store ptr %1, ptr %_newAddress, align 8
  store i64 %2, ptr %_aaVersion, align 4
  store ptr %3, ptr %_input, align 8
  %4 = load ptr, ptr %_input, align 8
  %5 = load ptr, ptr %_bytecodeHash, align 8
  %6 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %6, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %index_access3, align 4
  %7 = call i64 @memcmp_eq(ptr %5, ptr %heap_to_ptr, i64 4)
  %8 = icmp eq i64 %7, 0
  %9 = zext i1 %8 to i64
  call void @builtin_assert(i64 %9)
  %10 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %10, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %index_access6 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  store i64 0, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 0, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 0, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 65535, ptr %index_access9, align 4
  store ptr %heap_to_ptr5, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %11 = load ptr, ptr %_newAddress, align 8
  %12 = load ptr, ptr %MAX_SYSTEM_CONTRACT_ADDRESS, align 8
  %13 = call i64 @memcmp_ugt(ptr %11, ptr %12, i64 4)
  call void @builtin_assert(i64 %13)
  %14 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %14, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  %index_access12 = getelementptr i64, ptr %heap_to_ptr11, i64 0
  store i64 0, ptr %index_access12, align 4
  %index_access13 = getelementptr i64, ptr %heap_to_ptr11, i64 1
  store i64 0, ptr %index_access13, align 4
  %index_access14 = getelementptr i64, ptr %heap_to_ptr11, i64 2
  store i64 0, ptr %index_access14, align 4
  %index_access15 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  store i64 32770, ptr %index_access15, align 4
  store ptr %heap_to_ptr11, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %15 = load ptr, ptr %_newAddress, align 8
  %16 = call i64 @vector_new(i64 7)
  %heap_start16 = sub i64 %16, 7
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 6, ptr %heap_to_ptr17, align 4
  %17 = getelementptr i64, ptr %15, i64 0
  %18 = load i64, ptr %17, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr17, i64 1
  store i64 %18, ptr %encode_value_ptr, align 4
  %19 = getelementptr i64, ptr %15, i64 1
  %20 = load i64, ptr %19, align 4
  %encode_value_ptr18 = getelementptr i64, ptr %heap_to_ptr17, i64 2
  store i64 %20, ptr %encode_value_ptr18, align 4
  %21 = getelementptr i64, ptr %15, i64 2
  %22 = load i64, ptr %21, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %heap_to_ptr17, i64 3
  store i64 %22, ptr %encode_value_ptr19, align 4
  %23 = getelementptr i64, ptr %15, i64 3
  %24 = load i64, ptr %23, align 4
  %encode_value_ptr20 = getelementptr i64, ptr %heap_to_ptr17, i64 4
  store i64 %24, ptr %encode_value_ptr20, align 4
  %encode_value_ptr21 = getelementptr i64, ptr %heap_to_ptr17, i64 5
  store i64 4, ptr %encode_value_ptr21, align 4
  %encode_value_ptr22 = getelementptr i64, ptr %heap_to_ptr17, i64 6
  store i64 2179613704, ptr %encode_value_ptr22, align 4
  %25 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %payload_len = load i64, ptr %heap_to_ptr17, align 4
  %tape_size = add i64 %payload_len, 2
  %26 = ptrtoint ptr %heap_to_ptr17 to i64
  %payload_start = add i64 %26, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %25, i64 0)
  %27 = call i64 @vector_new(i64 1)
  %heap_start23 = sub i64 %27, 1
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  call void @get_tape_data(i64 %heap_start23, i64 1)
  %return_length = load i64, ptr %heap_to_ptr24, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size25 = add i64 %return_length, 1
  %28 = call i64 @vector_new(i64 %heap_size)
  %heap_start26 = sub i64 %28, %heap_size
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  store i64 %return_length, ptr %heap_to_ptr27, align 4
  %29 = add i64 %heap_start26, 1
  call void @get_tape_data(i64 %29, i64 %tape_size25)
  %length = load i64, ptr %heap_to_ptr27, align 4
  %30 = ptrtoint ptr %heap_to_ptr27 to i64
  %31 = add i64 %30, 1
  %vector_data = inttoptr i64 %31 to ptr
  %input_start = ptrtoint ptr %vector_data to i64
  %32 = inttoptr i64 %input_start to ptr
  store ptr %32, ptr %codeHash, align 8
  %33 = load ptr, ptr %codeHash, align 8
  %34 = call i64 @vector_new(i64 4)
  %heap_start28 = sub i64 %34, 4
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  %index_access30 = getelementptr i64, ptr %heap_to_ptr29, i64 0
  store i64 0, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %heap_to_ptr29, i64 1
  store i64 0, ptr %index_access31, align 4
  %index_access32 = getelementptr i64, ptr %heap_to_ptr29, i64 2
  store i64 0, ptr %index_access32, align 4
  %index_access33 = getelementptr i64, ptr %heap_to_ptr29, i64 3
  store i64 0, ptr %index_access33, align 4
  %35 = call i64 @memcmp_eq(ptr %33, ptr %heap_to_ptr29, i64 4)
  call void @builtin_assert(i64 %35)
  %36 = call i64 @vector_new(i64 4)
  %heap_start34 = sub i64 %36, 4
  %heap_to_ptr35 = inttoptr i64 %heap_start34 to ptr
  %index_access36 = getelementptr i64, ptr %heap_to_ptr35, i64 0
  store i64 0, ptr %index_access36, align 4
  %index_access37 = getelementptr i64, ptr %heap_to_ptr35, i64 1
  store i64 0, ptr %index_access37, align 4
  %index_access38 = getelementptr i64, ptr %heap_to_ptr35, i64 2
  store i64 0, ptr %index_access38, align 4
  %index_access39 = getelementptr i64, ptr %heap_to_ptr35, i64 3
  store i64 32771, ptr %index_access39, align 4
  store ptr %heap_to_ptr35, ptr %NONCE_HOLDER_ADDRESS, align 8
  %37 = load ptr, ptr %_newAddress, align 8
  %38 = call i64 @vector_new(i64 7)
  %heap_start40 = sub i64 %38, 7
  %heap_to_ptr41 = inttoptr i64 %heap_start40 to ptr
  store i64 6, ptr %heap_to_ptr41, align 4
  %39 = getelementptr i64, ptr %37, i64 0
  %40 = load i64, ptr %39, align 4
  %encode_value_ptr42 = getelementptr i64, ptr %heap_to_ptr41, i64 1
  store i64 %40, ptr %encode_value_ptr42, align 4
  %41 = getelementptr i64, ptr %37, i64 1
  %42 = load i64, ptr %41, align 4
  %encode_value_ptr43 = getelementptr i64, ptr %heap_to_ptr41, i64 2
  store i64 %42, ptr %encode_value_ptr43, align 4
  %43 = getelementptr i64, ptr %37, i64 2
  %44 = load i64, ptr %43, align 4
  %encode_value_ptr44 = getelementptr i64, ptr %heap_to_ptr41, i64 3
  store i64 %44, ptr %encode_value_ptr44, align 4
  %45 = getelementptr i64, ptr %37, i64 3
  %46 = load i64, ptr %45, align 4
  %encode_value_ptr45 = getelementptr i64, ptr %heap_to_ptr41, i64 4
  store i64 %46, ptr %encode_value_ptr45, align 4
  %encode_value_ptr46 = getelementptr i64, ptr %heap_to_ptr41, i64 5
  store i64 4, ptr %encode_value_ptr46, align 4
  %encode_value_ptr47 = getelementptr i64, ptr %heap_to_ptr41, i64 6
  store i64 3868785611, ptr %encode_value_ptr47, align 4
  %47 = load ptr, ptr %NONCE_HOLDER_ADDRESS, align 8
  %payload_len48 = load i64, ptr %heap_to_ptr41, align 4
  %tape_size49 = add i64 %payload_len48, 2
  %48 = ptrtoint ptr %heap_to_ptr41 to i64
  %payload_start50 = add i64 %48, 1
  call void @set_tape_data(i64 %payload_start50, i64 %tape_size49)
  call void @contract_call(ptr %47, i64 0)
  %49 = call i64 @vector_new(i64 1)
  %heap_start51 = sub i64 %49, 1
  %heap_to_ptr52 = inttoptr i64 %heap_start51 to ptr
  call void @get_tape_data(i64 %heap_start51, i64 1)
  %return_length53 = load i64, ptr %heap_to_ptr52, align 4
  %heap_size54 = add i64 %return_length53, 2
  %tape_size55 = add i64 %return_length53, 1
  %50 = call i64 @vector_new(i64 %heap_size54)
  %heap_start56 = sub i64 %50, %heap_size54
  %heap_to_ptr57 = inttoptr i64 %heap_start56 to ptr
  store i64 %return_length53, ptr %heap_to_ptr57, align 4
  %51 = add i64 %heap_start56, 1
  call void @get_tape_data(i64 %51, i64 %tape_size55)
  %length58 = load i64, ptr %heap_to_ptr57, align 4
  %52 = ptrtoint ptr %heap_to_ptr57 to i64
  %53 = add i64 %52, 1
  %vector_data59 = inttoptr i64 %53 to ptr
  %input_start60 = ptrtoint ptr %vector_data59 to i64
  %54 = inttoptr i64 %input_start60 to ptr
  %decode_value = load i64, ptr %54, align 4
  store i64 %decode_value, ptr %deploy_nonce, align 4
  %55 = load i64, ptr %deploy_nonce, align 4
  %56 = icmp eq i64 %55, 0
  %57 = zext i1 %56 to i64
  call void @builtin_assert(i64 %57)
  %58 = load ptr, ptr %_bytecodeHash, align 8
  %59 = load ptr, ptr %_newAddress, align 8
  %60 = load i64, ptr %_aaVersion, align 4
  call void @_performDeployOnAddress(ptr %58, ptr %59, i64 %60, ptr %4)
  ret void
}

define void @_performDeployOnAddress(ptr %0, ptr %1, i64 %2, ptr %3) {
entry:
  %is_codehash_known = alloca i64, align 8
  %KNOWN_CODE_STORAGE_CONTRACT = alloca ptr, align 8
  %_input = alloca ptr, align 8
  %_aaVersion = alloca i64, align 8
  %_newAddress = alloca ptr, align 8
  %_bytecodeHash = alloca ptr, align 8
  store ptr %0, ptr %_bytecodeHash, align 8
  store ptr %1, ptr %_newAddress, align 8
  store i64 %2, ptr %_aaVersion, align 4
  store ptr %3, ptr %_input, align 8
  %4 = load ptr, ptr %_input, align 8
  %5 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %5, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 32772, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %KNOWN_CODE_STORAGE_CONTRACT, align 8
  %6 = load ptr, ptr %_bytecodeHash, align 8
  %7 = call i64 @vector_new(i64 7)
  %heap_start4 = sub i64 %7, 7
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 6, ptr %heap_to_ptr5, align 4
  %8 = getelementptr i64, ptr %6, i64 0
  %9 = load i64, ptr %8, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 %9, ptr %encode_value_ptr, align 4
  %10 = getelementptr i64, ptr %6, i64 1
  %11 = load i64, ptr %10, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 %11, ptr %encode_value_ptr6, align 4
  %12 = getelementptr i64, ptr %6, i64 2
  %13 = load i64, ptr %12, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 %13, ptr %encode_value_ptr7, align 4
  %14 = getelementptr i64, ptr %6, i64 3
  %15 = load i64, ptr %14, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr5, i64 4
  store i64 %15, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr5, i64 5
  store i64 4, ptr %encode_value_ptr9, align 4
  %encode_value_ptr10 = getelementptr i64, ptr %heap_to_ptr5, i64 6
  store i64 4199620571, ptr %encode_value_ptr10, align 4
  %16 = load ptr, ptr %KNOWN_CODE_STORAGE_CONTRACT, align 8
  %payload_len = load i64, ptr %heap_to_ptr5, align 4
  %tape_size = add i64 %payload_len, 2
  %17 = ptrtoint ptr %heap_to_ptr5 to i64
  %payload_start = add i64 %17, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %16, i64 0)
  %18 = call i64 @vector_new(i64 1)
  %heap_start11 = sub i64 %18, 1
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @get_tape_data(i64 %heap_start11, i64 1)
  %return_length = load i64, ptr %heap_to_ptr12, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size13 = add i64 %return_length, 1
  %19 = call i64 @vector_new(i64 %heap_size)
  %heap_start14 = sub i64 %19, %heap_size
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %return_length, ptr %heap_to_ptr15, align 4
  %20 = add i64 %heap_start14, 1
  call void @get_tape_data(i64 %20, i64 %tape_size13)
  %length = load i64, ptr %heap_to_ptr15, align 4
  %21 = ptrtoint ptr %heap_to_ptr15 to i64
  %22 = add i64 %21, 1
  %vector_data = inttoptr i64 %22 to ptr
  %input_start = ptrtoint ptr %vector_data to i64
  %23 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %23, align 4
  store i64 %decode_value, ptr %is_codehash_known, align 4
  %24 = load i64, ptr %is_codehash_known, align 4
  call void @builtin_assert(i64 %24)
  %25 = call i64 @vector_new(i64 2)
  %heap_start16 = sub i64 %25, 2
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  %struct_member = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr17, i32 0, i32 0
  %26 = load i64, ptr %_aaVersion, align 4
  store i64 %26, ptr %struct_member, align 4
  %struct_member18 = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr17, i32 0, i32 1
  store i64 0, ptr %struct_member18, align 4
  %27 = load ptr, ptr %_newAddress, align 8
  %28 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %28, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 0, ptr %heap_to_ptr20, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %31, align 4
  %32 = call i64 @vector_new(i64 8)
  %heap_start21 = sub i64 %32, 8
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  %33 = inttoptr i64 %heap_start21 to ptr
  call void @memcpy(ptr %heap_to_ptr20, ptr %33, i64 4)
  %next_dest_offset = add i64 %heap_start21, 4
  %34 = inttoptr i64 %next_dest_offset to ptr
  call void @memcpy(ptr %27, ptr %34, i64 4)
  %35 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %35, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr22, ptr %heap_to_ptr24, i64 8)
  %supportedAAVersion = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr17, i32 0, i32 0
  %36 = load i64, ptr %supportedAAVersion, align 4
  %37 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %37, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  store i64 %36, ptr %heap_to_ptr26, align 4
  %38 = getelementptr i64, ptr %heap_to_ptr26, i64 1
  store i64 0, ptr %38, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr26, i64 2
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  store i64 0, ptr %40, align 4
  call void @set_storage(ptr %heap_to_ptr24, ptr %heap_to_ptr26)
  %slot_value = load i64, ptr %heap_to_ptr24, align 4
  %slot_offset = add i64 %slot_value, 1
  store i64 %slot_offset, ptr %heap_to_ptr24, align 4
  %nonceOrdering = getelementptr inbounds { i64, i64 }, ptr %heap_to_ptr17, i32 0, i32 1
  %41 = load i64, ptr %nonceOrdering, align 4
  %42 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %42, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  store i64 %41, ptr %heap_to_ptr28, align 4
  %43 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 0, ptr %43, align 4
  %44 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 0, ptr %44, align 4
  %45 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 0, ptr %45, align 4
  call void @set_storage(ptr %heap_to_ptr24, ptr %heap_to_ptr28)
  %46 = call i64 @vector_new(i64 12)
  %heap_start29 = sub i64 %46, 12
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  call void @get_tape_data(i64 %heap_start29, i64 12)
  %47 = load ptr, ptr %_newAddress, align 8
  %48 = load ptr, ptr %_bytecodeHash, align 8
  call void @_constructContract(ptr %heap_to_ptr30, ptr %47, ptr %48, ptr %4, i64 0, i64 1)
  ret void
}

define void @_constructContract(ptr %0, ptr %1, ptr %2, ptr %3, i64 %4, i64 %5) {
entry:
  %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT = alloca ptr, align 8
  %_callConstructor = alloca i64, align 8
  %_isSystem = alloca i64, align 8
  %_input = alloca ptr, align 8
  %_bytecodeHash = alloca ptr, align 8
  %_newAddress = alloca ptr, align 8
  %_sender = alloca ptr, align 8
  store ptr %0, ptr %_sender, align 8
  store ptr %1, ptr %_newAddress, align 8
  store ptr %2, ptr %_bytecodeHash, align 8
  store ptr %3, ptr %_input, align 8
  %6 = load ptr, ptr %_input, align 8
  store i64 %4, ptr %_isSystem, align 4
  store i64 %5, ptr %_callConstructor, align 4
  %7 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %7, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 32770, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %8 = load i64, ptr %_callConstructor, align 4
  %9 = trunc i64 %8 to i1
  br i1 %9, label %then, label %else

then:                                             ; preds = %entry
  %10 = load ptr, ptr %_newAddress, align 8
  %payload_len = load i64, ptr %6, align 4
  %tape_size = add i64 %payload_len, 2
  %11 = ptrtoint ptr %6 to i64
  %payload_start = add i64 %11, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %10, i64 0)
  %12 = call i64 @vector_new(i64 1)
  %heap_start4 = sub i64 %12, 1
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  call void @get_tape_data(i64 %heap_start4, i64 1)
  %return_length = load i64, ptr %heap_to_ptr5, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size6 = add i64 %return_length, 1
  %13 = call i64 @vector_new(i64 %heap_size)
  %heap_start7 = sub i64 %13, %heap_size
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %return_length, ptr %heap_to_ptr8, align 4
  %14 = add i64 %heap_start7, 1
  call void @get_tape_data(i64 %14, i64 %tape_size6)
  %15 = load ptr, ptr %_newAddress, align 8
  %16 = load ptr, ptr %_bytecodeHash, align 8
  %17 = call i64 @vector_new(i64 11)
  %heap_start9 = sub i64 %17, 11
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 10, ptr %heap_to_ptr10, align 4
  %18 = getelementptr i64, ptr %15, i64 0
  %19 = load i64, ptr %18, align 4
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 %19, ptr %encode_value_ptr, align 4
  %20 = getelementptr i64, ptr %15, i64 1
  %21 = load i64, ptr %20, align 4
  %encode_value_ptr11 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 %21, ptr %encode_value_ptr11, align 4
  %22 = getelementptr i64, ptr %15, i64 2
  %23 = load i64, ptr %22, align 4
  %encode_value_ptr12 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 %23, ptr %encode_value_ptr12, align 4
  %24 = getelementptr i64, ptr %15, i64 3
  %25 = load i64, ptr %24, align 4
  %encode_value_ptr13 = getelementptr i64, ptr %heap_to_ptr10, i64 4
  store i64 %25, ptr %encode_value_ptr13, align 4
  %26 = getelementptr i64, ptr %16, i64 0
  %27 = load i64, ptr %26, align 4
  %encode_value_ptr14 = getelementptr i64, ptr %heap_to_ptr10, i64 5
  store i64 %27, ptr %encode_value_ptr14, align 4
  %28 = getelementptr i64, ptr %16, i64 1
  %29 = load i64, ptr %28, align 4
  %encode_value_ptr15 = getelementptr i64, ptr %heap_to_ptr10, i64 6
  store i64 %29, ptr %encode_value_ptr15, align 4
  %30 = getelementptr i64, ptr %16, i64 2
  %31 = load i64, ptr %30, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %heap_to_ptr10, i64 7
  store i64 %31, ptr %encode_value_ptr16, align 4
  %32 = getelementptr i64, ptr %16, i64 3
  %33 = load i64, ptr %32, align 4
  %encode_value_ptr17 = getelementptr i64, ptr %heap_to_ptr10, i64 8
  store i64 %33, ptr %encode_value_ptr17, align 4
  %encode_value_ptr18 = getelementptr i64, ptr %heap_to_ptr10, i64 9
  store i64 8, ptr %encode_value_ptr18, align 4
  %encode_value_ptr19 = getelementptr i64, ptr %heap_to_ptr10, i64 10
  store i64 3592270258, ptr %encode_value_ptr19, align 4
  %34 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %payload_len20 = load i64, ptr %heap_to_ptr10, align 4
  %tape_size21 = add i64 %payload_len20, 2
  %35 = ptrtoint ptr %heap_to_ptr10 to i64
  %payload_start22 = add i64 %35, 1
  call void @set_tape_data(i64 %payload_start22, i64 %tape_size21)
  call void @contract_call(ptr %34, i64 0)
  %36 = call i64 @vector_new(i64 1)
  %heap_start23 = sub i64 %36, 1
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  call void @get_tape_data(i64 %heap_start23, i64 1)
  %return_length25 = load i64, ptr %heap_to_ptr24, align 4
  %heap_size26 = add i64 %return_length25, 2
  %tape_size27 = add i64 %return_length25, 1
  %37 = call i64 @vector_new(i64 %heap_size26)
  %heap_start28 = sub i64 %37, %heap_size26
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 %return_length25, ptr %heap_to_ptr29, align 4
  %38 = add i64 %heap_start28, 1
  call void @get_tape_data(i64 %38, i64 %tape_size27)
  br label %enif

else:                                             ; preds = %entry
  %39 = load ptr, ptr %_newAddress, align 8
  %40 = load ptr, ptr %_bytecodeHash, align 8
  %41 = call i64 @vector_new(i64 11)
  %heap_start30 = sub i64 %41, 11
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  store i64 10, ptr %heap_to_ptr31, align 4
  %42 = getelementptr i64, ptr %39, i64 0
  %43 = load i64, ptr %42, align 4
  %encode_value_ptr32 = getelementptr i64, ptr %heap_to_ptr31, i64 1
  store i64 %43, ptr %encode_value_ptr32, align 4
  %44 = getelementptr i64, ptr %39, i64 1
  %45 = load i64, ptr %44, align 4
  %encode_value_ptr33 = getelementptr i64, ptr %heap_to_ptr31, i64 2
  store i64 %45, ptr %encode_value_ptr33, align 4
  %46 = getelementptr i64, ptr %39, i64 2
  %47 = load i64, ptr %46, align 4
  %encode_value_ptr34 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  store i64 %47, ptr %encode_value_ptr34, align 4
  %48 = getelementptr i64, ptr %39, i64 3
  %49 = load i64, ptr %48, align 4
  %encode_value_ptr35 = getelementptr i64, ptr %heap_to_ptr31, i64 4
  store i64 %49, ptr %encode_value_ptr35, align 4
  %50 = getelementptr i64, ptr %40, i64 0
  %51 = load i64, ptr %50, align 4
  %encode_value_ptr36 = getelementptr i64, ptr %heap_to_ptr31, i64 5
  store i64 %51, ptr %encode_value_ptr36, align 4
  %52 = getelementptr i64, ptr %40, i64 1
  %53 = load i64, ptr %52, align 4
  %encode_value_ptr37 = getelementptr i64, ptr %heap_to_ptr31, i64 6
  store i64 %53, ptr %encode_value_ptr37, align 4
  %54 = getelementptr i64, ptr %40, i64 2
  %55 = load i64, ptr %54, align 4
  %encode_value_ptr38 = getelementptr i64, ptr %heap_to_ptr31, i64 7
  store i64 %55, ptr %encode_value_ptr38, align 4
  %56 = getelementptr i64, ptr %40, i64 3
  %57 = load i64, ptr %56, align 4
  %encode_value_ptr39 = getelementptr i64, ptr %heap_to_ptr31, i64 8
  store i64 %57, ptr %encode_value_ptr39, align 4
  %encode_value_ptr40 = getelementptr i64, ptr %heap_to_ptr31, i64 9
  store i64 8, ptr %encode_value_ptr40, align 4
  %encode_value_ptr41 = getelementptr i64, ptr %heap_to_ptr31, i64 10
  store i64 4121977188, ptr %encode_value_ptr41, align 4
  %58 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %payload_len42 = load i64, ptr %heap_to_ptr31, align 4
  %tape_size43 = add i64 %payload_len42, 2
  %59 = ptrtoint ptr %heap_to_ptr31 to i64
  %payload_start44 = add i64 %59, 1
  call void @set_tape_data(i64 %payload_start44, i64 %tape_size43)
  call void @contract_call(ptr %58, i64 0)
  %60 = call i64 @vector_new(i64 1)
  %heap_start45 = sub i64 %60, 1
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  call void @get_tape_data(i64 %heap_start45, i64 1)
  %return_length47 = load i64, ptr %heap_to_ptr46, align 4
  %heap_size48 = add i64 %return_length47, 2
  %tape_size49 = add i64 %return_length47, 1
  %61 = call i64 @vector_new(i64 %heap_size48)
  %heap_start50 = sub i64 %61, %heap_size48
  %heap_to_ptr51 = inttoptr i64 %heap_start50 to ptr
  store i64 %return_length47, ptr %heap_to_ptr51, align 4
  %62 = add i64 %heap_start50, 1
  call void @get_tape_data(i64 %62, i64 %tape_size49)
  br label %enif

enif:                                             ; preds = %else, %then
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 282464187, label %func_0_dispatch
    i64 1923006418, label %func_1_dispatch
    i64 3984217463, label %func_2_dispatch
    i64 2063016979, label %func_3_dispatch
    i64 893325452, label %func_4_dispatch
    i64 4027571991, label %func_5_dispatch
    i64 2739884532, label %func_6_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %4 = call i64 @extendedAccountVersion(ptr %3)
  %5 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %5, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %4, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr1, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start2 = ptrtoint ptr %input to i64
  %6 = inttoptr i64 %input_start2 to ptr
  %7 = add i64 %input_start2, 4
  %8 = inttoptr i64 %7 to ptr
  %9 = add i64 %7, 4
  %10 = inttoptr i64 %9 to ptr
  %length = load i64, ptr %10, align 4
  %11 = add i64 %length, 1
  %12 = call ptr @create2(ptr %6, ptr %8, ptr %10)
  %13 = call i64 @vector_new(i64 5)
  %heap_start3 = sub i64 %13, 5
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  %14 = getelementptr i64, ptr %12, i64 0
  %15 = load i64, ptr %14, align 4
  %encode_value_ptr5 = getelementptr i64, ptr %heap_to_ptr4, i64 0
  store i64 %15, ptr %encode_value_ptr5, align 4
  %16 = getelementptr i64, ptr %12, i64 1
  %17 = load i64, ptr %16, align 4
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 %17, ptr %encode_value_ptr6, align 4
  %18 = getelementptr i64, ptr %12, i64 2
  %19 = load i64, ptr %18, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 %19, ptr %encode_value_ptr7, align 4
  %20 = getelementptr i64, ptr %12, i64 3
  %21 = load i64, ptr %20, align 4
  %encode_value_ptr8 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 %21, ptr %encode_value_ptr8, align 4
  %encode_value_ptr9 = getelementptr i64, ptr %heap_to_ptr4, i64 4
  store i64 4, ptr %encode_value_ptr9, align 4
  call void @set_tape_data(i64 %heap_start3, i64 5)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %input_start10 = ptrtoint ptr %input to i64
  %22 = inttoptr i64 %input_start10 to ptr
  %23 = add i64 %input_start10, 4
  %24 = inttoptr i64 %23 to ptr
  %25 = add i64 %23, 4
  %26 = inttoptr i64 %25 to ptr
  %length11 = load i64, ptr %26, align 4
  %27 = add i64 %length11, 1
  %28 = add i64 %25, %27
  %29 = inttoptr i64 %28 to ptr
  %decode_value = load i64, ptr %29, align 4
  %30 = call ptr @create2Account(ptr %22, ptr %24, ptr %26, i64 %decode_value)
  %31 = call i64 @vector_new(i64 5)
  %heap_start12 = sub i64 %31, 5
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  %32 = getelementptr i64, ptr %30, i64 0
  %33 = load i64, ptr %32, align 4
  %encode_value_ptr14 = getelementptr i64, ptr %heap_to_ptr13, i64 0
  store i64 %33, ptr %encode_value_ptr14, align 4
  %34 = getelementptr i64, ptr %30, i64 1
  %35 = load i64, ptr %34, align 4
  %encode_value_ptr15 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 %35, ptr %encode_value_ptr15, align 4
  %36 = getelementptr i64, ptr %30, i64 2
  %37 = load i64, ptr %36, align 4
  %encode_value_ptr16 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 %37, ptr %encode_value_ptr16, align 4
  %38 = getelementptr i64, ptr %30, i64 3
  %39 = load i64, ptr %38, align 4
  %encode_value_ptr17 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 %39, ptr %encode_value_ptr17, align 4
  %encode_value_ptr18 = getelementptr i64, ptr %heap_to_ptr13, i64 4
  store i64 4, ptr %encode_value_ptr18, align 4
  call void @set_tape_data(i64 %heap_start12, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %input_start19 = ptrtoint ptr %input to i64
  %40 = inttoptr i64 %input_start19 to ptr
  %41 = add i64 %input_start19, 4
  %42 = inttoptr i64 %41 to ptr
  %43 = add i64 %41, 4
  %44 = inttoptr i64 %43 to ptr
  %45 = add i64 %43, 4
  %46 = inttoptr i64 %45 to ptr
  %length20 = load i64, ptr %46, align 4
  %47 = add i64 %length20, 1
  %48 = call ptr @getNewAddressCreate2(ptr %40, ptr %42, ptr %44, ptr %46)
  %49 = call i64 @vector_new(i64 5)
  %heap_start21 = sub i64 %49, 5
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  %50 = getelementptr i64, ptr %48, i64 0
  %51 = load i64, ptr %50, align 4
  %encode_value_ptr23 = getelementptr i64, ptr %heap_to_ptr22, i64 0
  store i64 %51, ptr %encode_value_ptr23, align 4
  %52 = getelementptr i64, ptr %48, i64 1
  %53 = load i64, ptr %52, align 4
  %encode_value_ptr24 = getelementptr i64, ptr %heap_to_ptr22, i64 1
  store i64 %53, ptr %encode_value_ptr24, align 4
  %54 = getelementptr i64, ptr %48, i64 2
  %55 = load i64, ptr %54, align 4
  %encode_value_ptr25 = getelementptr i64, ptr %heap_to_ptr22, i64 2
  store i64 %55, ptr %encode_value_ptr25, align 4
  %56 = getelementptr i64, ptr %48, i64 3
  %57 = load i64, ptr %56, align 4
  %encode_value_ptr26 = getelementptr i64, ptr %heap_to_ptr22, i64 3
  store i64 %57, ptr %encode_value_ptr26, align 4
  %encode_value_ptr27 = getelementptr i64, ptr %heap_to_ptr22, i64 4
  store i64 4, ptr %encode_value_ptr27, align 4
  call void @set_tape_data(i64 %heap_start21, i64 5)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %input_start28 = ptrtoint ptr %input to i64
  %58 = inttoptr i64 %input_start28 to ptr
  %59 = add i64 %input_start28, 4
  %60 = inttoptr i64 %59 to ptr
  %61 = add i64 %59, 4
  %62 = inttoptr i64 %61 to ptr
  %decode_value29 = load i64, ptr %62, align 4
  %63 = add i64 %61, 1
  %64 = inttoptr i64 %63 to ptr
  %length30 = load i64, ptr %64, align 4
  %65 = add i64 %length30, 1
  call void @_nonSystemDeployOnAddress(ptr %58, ptr %60, i64 %decode_value29, ptr %64)
  ret void

func_5_dispatch:                                  ; preds = %entry
  %input_start31 = ptrtoint ptr %input to i64
  %66 = inttoptr i64 %input_start31 to ptr
  %67 = add i64 %input_start31, 4
  %68 = inttoptr i64 %67 to ptr
  %69 = add i64 %67, 4
  %70 = inttoptr i64 %69 to ptr
  %decode_value32 = load i64, ptr %70, align 4
  %71 = add i64 %69, 1
  %72 = inttoptr i64 %71 to ptr
  %length33 = load i64, ptr %72, align 4
  %73 = add i64 %length33, 1
  call void @_performDeployOnAddress(ptr %66, ptr %68, i64 %decode_value32, ptr %72)
  ret void

func_6_dispatch:                                  ; preds = %entry
  %input_start34 = ptrtoint ptr %input to i64
  %74 = inttoptr i64 %input_start34 to ptr
  %75 = add i64 %input_start34, 4
  %76 = inttoptr i64 %75 to ptr
  %77 = add i64 %75, 4
  %78 = inttoptr i64 %77 to ptr
  %79 = add i64 %77, 4
  %80 = inttoptr i64 %79 to ptr
  %length35 = load i64, ptr %80, align 4
  %81 = add i64 %length35, 1
  %82 = add i64 %79, %81
  %83 = inttoptr i64 %82 to ptr
  %decode_value36 = load i64, ptr %83, align 4
  %84 = add i64 %82, 1
  %85 = inttoptr i64 %84 to ptr
  %decode_value37 = load i64, ptr %85, align 4
  call void @_constructContract(ptr %74, ptr %76, ptr %78, ptr %80, i64 %decode_value36, i64 %decode_value37)
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
