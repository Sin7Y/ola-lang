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

define void @_constructContract(ptr %0, ptr %1, ptr %2, ptr %3, i64 %4, i64 %5) {
entry:
  %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT = alloca ptr, align 8
  %_callConstructor = alloca i64, align 8
  %_isSystem = alloca i64, align 8
  %_bytecodeHash = alloca ptr, align 8
  %_newAddress = alloca ptr, align 8
  %_sender = alloca ptr, align 8
  store ptr %0, ptr %_sender, align 8
  store ptr %1, ptr %_newAddress, align 8
  store ptr %2, ptr %_bytecodeHash, align 8
  store i64 %4, ptr %_isSystem, align 4
  store i64 %5, ptr %_callConstructor, align 4
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
  store i64 32770, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %7 = load i64, ptr %_callConstructor, align 4
  %8 = trunc i64 %7 to i1
  br i1 %8, label %then, label %else

then:                                             ; preds = %entry
  %9 = load ptr, ptr %_newAddress, align 8
  %payload_len = load i64, ptr %3, align 4
  %tape_size = add i64 %payload_len, 2
  %10 = ptrtoint ptr %3 to i64
  %payload_start = add i64 %10, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(ptr %9, i64 0)
  %11 = call i64 @vector_new(i64 1)
  %heap_start4 = sub i64 %11, 1
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  call void @get_tape_data(i64 %heap_start4, i64 1)
  %return_length = load i64, ptr %heap_to_ptr5, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size6 = add i64 %return_length, 1
  %12 = call i64 @vector_new(i64 %heap_size)
  %heap_start7 = sub i64 %12, %heap_size
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %return_length, ptr %heap_to_ptr8, align 4
  %13 = add i64 %heap_start7, 1
  call void @get_tape_data(i64 %13, i64 %tape_size6)
  %14 = load ptr, ptr %_newAddress, align 8
  %15 = load ptr, ptr %_bytecodeHash, align 8
  %16 = call i64 @vector_new(i64 11)
  %heap_start9 = sub i64 %16, 11
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 10, ptr %heap_to_ptr10, align 4
  %17 = getelementptr i64, ptr %14, i64 0
  %18 = load i64, ptr %17, align 4
  %start = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 %18, ptr %start, align 4
  %19 = getelementptr i64, ptr %14, i64 1
  %20 = load i64, ptr %19, align 4
  %start11 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 %20, ptr %start11, align 4
  %21 = getelementptr i64, ptr %14, i64 2
  %22 = load i64, ptr %21, align 4
  %start12 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 %22, ptr %start12, align 4
  %23 = getelementptr i64, ptr %14, i64 3
  %24 = load i64, ptr %23, align 4
  %start13 = getelementptr i64, ptr %heap_to_ptr10, i64 4
  store i64 %24, ptr %start13, align 4
  %25 = getelementptr i64, ptr %15, i64 0
  %26 = load i64, ptr %25, align 4
  %start14 = getelementptr i64, ptr %heap_to_ptr10, i64 5
  store i64 %26, ptr %start14, align 4
  %27 = getelementptr i64, ptr %15, i64 1
  %28 = load i64, ptr %27, align 4
  %start15 = getelementptr i64, ptr %heap_to_ptr10, i64 6
  store i64 %28, ptr %start15, align 4
  %29 = getelementptr i64, ptr %15, i64 2
  %30 = load i64, ptr %29, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr10, i64 7
  store i64 %30, ptr %start16, align 4
  %31 = getelementptr i64, ptr %15, i64 3
  %32 = load i64, ptr %31, align 4
  %start17 = getelementptr i64, ptr %heap_to_ptr10, i64 8
  store i64 %32, ptr %start17, align 4
  %start18 = getelementptr i64, ptr %heap_to_ptr10, i64 9
  store i64 8, ptr %start18, align 4
  %start19 = getelementptr i64, ptr %heap_to_ptr10, i64 10
  store i64 2997951958, ptr %start19, align 4
  %33 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %payload_len20 = load i64, ptr %heap_to_ptr10, align 4
  %tape_size21 = add i64 %payload_len20, 2
  %34 = ptrtoint ptr %heap_to_ptr10 to i64
  %payload_start22 = add i64 %34, 1
  call void @set_tape_data(i64 %payload_start22, i64 %tape_size21)
  call void @contract_call(ptr %33, i64 0)
  %35 = call i64 @vector_new(i64 1)
  %heap_start23 = sub i64 %35, 1
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  call void @get_tape_data(i64 %heap_start23, i64 1)
  %return_length25 = load i64, ptr %heap_to_ptr24, align 4
  %heap_size26 = add i64 %return_length25, 2
  %tape_size27 = add i64 %return_length25, 1
  %36 = call i64 @vector_new(i64 %heap_size26)
  %heap_start28 = sub i64 %36, %heap_size26
  %heap_to_ptr29 = inttoptr i64 %heap_start28 to ptr
  store i64 %return_length25, ptr %heap_to_ptr29, align 4
  %37 = add i64 %heap_start28, 1
  call void @get_tape_data(i64 %37, i64 %tape_size27)
  br label %enif

else:                                             ; preds = %entry
  %38 = load ptr, ptr %_newAddress, align 8
  %39 = load ptr, ptr %_bytecodeHash, align 8
  %40 = call i64 @vector_new(i64 11)
  %heap_start30 = sub i64 %40, 11
  %heap_to_ptr31 = inttoptr i64 %heap_start30 to ptr
  store i64 10, ptr %heap_to_ptr31, align 4
  %41 = getelementptr i64, ptr %38, i64 0
  %42 = load i64, ptr %41, align 4
  %start32 = getelementptr i64, ptr %heap_to_ptr31, i64 1
  store i64 %42, ptr %start32, align 4
  %43 = getelementptr i64, ptr %38, i64 1
  %44 = load i64, ptr %43, align 4
  %start33 = getelementptr i64, ptr %heap_to_ptr31, i64 2
  store i64 %44, ptr %start33, align 4
  %45 = getelementptr i64, ptr %38, i64 2
  %46 = load i64, ptr %45, align 4
  %start34 = getelementptr i64, ptr %heap_to_ptr31, i64 3
  store i64 %46, ptr %start34, align 4
  %47 = getelementptr i64, ptr %38, i64 3
  %48 = load i64, ptr %47, align 4
  %start35 = getelementptr i64, ptr %heap_to_ptr31, i64 4
  store i64 %48, ptr %start35, align 4
  %49 = getelementptr i64, ptr %39, i64 0
  %50 = load i64, ptr %49, align 4
  %start36 = getelementptr i64, ptr %heap_to_ptr31, i64 5
  store i64 %50, ptr %start36, align 4
  %51 = getelementptr i64, ptr %39, i64 1
  %52 = load i64, ptr %51, align 4
  %start37 = getelementptr i64, ptr %heap_to_ptr31, i64 6
  store i64 %52, ptr %start37, align 4
  %53 = getelementptr i64, ptr %39, i64 2
  %54 = load i64, ptr %53, align 4
  %start38 = getelementptr i64, ptr %heap_to_ptr31, i64 7
  store i64 %54, ptr %start38, align 4
  %55 = getelementptr i64, ptr %39, i64 3
  %56 = load i64, ptr %55, align 4
  %start39 = getelementptr i64, ptr %heap_to_ptr31, i64 8
  store i64 %56, ptr %start39, align 4
  %start40 = getelementptr i64, ptr %heap_to_ptr31, i64 9
  store i64 8, ptr %start40, align 4
  %start41 = getelementptr i64, ptr %heap_to_ptr31, i64 10
  store i64 1684123893, ptr %start41, align 4
  %57 = load ptr, ptr %ACCOUNT_CODE_STORAGE_SYSTEM_CONTRACT, align 8
  %payload_len42 = load i64, ptr %heap_to_ptr31, align 4
  %tape_size43 = add i64 %payload_len42, 2
  %58 = ptrtoint ptr %heap_to_ptr31 to i64
  %payload_start44 = add i64 %58, 1
  call void @set_tape_data(i64 %payload_start44, i64 %tape_size43)
  call void @contract_call(ptr %57, i64 0)
  %59 = call i64 @vector_new(i64 1)
  %heap_start45 = sub i64 %59, 1
  %heap_to_ptr46 = inttoptr i64 %heap_start45 to ptr
  call void @get_tape_data(i64 %heap_start45, i64 1)
  %return_length47 = load i64, ptr %heap_to_ptr46, align 4
  %heap_size48 = add i64 %return_length47, 2
  %tape_size49 = add i64 %return_length47, 1
  %60 = call i64 @vector_new(i64 %heap_size48)
  %heap_start50 = sub i64 %60, %heap_size48
  %heap_to_ptr51 = inttoptr i64 %heap_start50 to ptr
  store i64 %return_length47, ptr %heap_to_ptr51, align 4
  %61 = add i64 %heap_start50, 1
  call void @get_tape_data(i64 %61, i64 %tape_size49)
  br label %enif

enif:                                             ; preds = %else, %then
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2739884532, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 12, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %element = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %value, ptr %element, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %element3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %value2, ptr %element3, align 4
  %start4 = getelementptr i64, ptr %2, i64 2
  %value5 = load i64, ptr %start4, align 4
  %element6 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %value5, ptr %element6, align 4
  %start7 = getelementptr i64, ptr %2, i64 3
  %value8 = load i64, ptr %start7, align 4
  %element9 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %value8, ptr %element9, align 4
  %5 = call i64 @vector_new(i64 4)
  %heap_start10 = sub i64 %5, 4
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  %start12 = getelementptr i64, ptr %2, i64 4
  %value13 = load i64, ptr %start12, align 4
  %element14 = getelementptr i64, ptr %heap_to_ptr11, i64 0
  store i64 %value13, ptr %element14, align 4
  %start15 = getelementptr i64, ptr %2, i64 5
  %value16 = load i64, ptr %start15, align 4
  %element17 = getelementptr i64, ptr %heap_to_ptr11, i64 1
  store i64 %value16, ptr %element17, align 4
  %start18 = getelementptr i64, ptr %2, i64 6
  %value19 = load i64, ptr %start18, align 4
  %element20 = getelementptr i64, ptr %heap_to_ptr11, i64 2
  store i64 %value19, ptr %element20, align 4
  %start21 = getelementptr i64, ptr %2, i64 7
  %value22 = load i64, ptr %start21, align 4
  %element23 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  store i64 %value22, ptr %element23, align 4
  %6 = call i64 @vector_new(i64 4)
  %heap_start24 = sub i64 %6, 4
  %heap_to_ptr25 = inttoptr i64 %heap_start24 to ptr
  %start26 = getelementptr i64, ptr %2, i64 8
  %value27 = load i64, ptr %start26, align 4
  %element28 = getelementptr i64, ptr %heap_to_ptr25, i64 0
  store i64 %value27, ptr %element28, align 4
  %start29 = getelementptr i64, ptr %2, i64 9
  %value30 = load i64, ptr %start29, align 4
  %element31 = getelementptr i64, ptr %heap_to_ptr25, i64 1
  store i64 %value30, ptr %element31, align 4
  %start32 = getelementptr i64, ptr %2, i64 10
  %value33 = load i64, ptr %start32, align 4
  %element34 = getelementptr i64, ptr %heap_to_ptr25, i64 2
  store i64 %value33, ptr %element34, align 4
  %start35 = getelementptr i64, ptr %2, i64 11
  %value36 = load i64, ptr %start35, align 4
  %element37 = getelementptr i64, ptr %heap_to_ptr25, i64 3
  store i64 %value36, ptr %element37, align 4
  %start38 = getelementptr i64, ptr %2, i64 12
  %value39 = load i64, ptr %start38, align 4
  %7 = add i64 1, %value39
  %8 = icmp ule i64 13, %1
  br i1 %8, label %inbounds40, label %out_of_bounds41

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

inbounds40:                                       ; preds = %inbounds
  %9 = add i64 12, %7
  %10 = icmp ule i64 %9, %1
  br i1 %10, label %inbounds42, label %out_of_bounds43

out_of_bounds41:                                  ; preds = %inbounds
  unreachable

inbounds42:                                       ; preds = %inbounds40
  %size = mul i64 %value39, 1
  %size_add_one = add i64 %size, 1
  %11 = call i64 @vector_new(i64 %size_add_one)
  %heap_start44 = sub i64 %11, %size_add_one
  %heap_to_ptr45 = inttoptr i64 %heap_start44 to ptr
  store i64 %size, ptr %heap_to_ptr45, align 4
  %12 = ptrtoint ptr %heap_to_ptr45 to i64
  %13 = add i64 %12, 1
  %vector_data = inttoptr i64 %13 to ptr
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

out_of_bounds43:                                  ; preds = %inbounds40
  unreachable

loop_body:                                        ; preds = %inbounds47, %inbounds42
  %index = load i64, ptr %index_ptr, align 4
  %element46 = getelementptr i64, ptr %vector_data, i64 %index
  %14 = icmp ule i64 14, %1
  br i1 %14, label %inbounds47, label %out_of_bounds48

loop_end:                                         ; preds = %inbounds47
  %15 = add i64 12, %7
  %16 = add i64 %15, 2
  %17 = icmp ule i64 %16, %1
  br i1 %17, label %inbounds51, label %out_of_bounds52

inbounds47:                                       ; preds = %loop_body
  %start49 = getelementptr i64, ptr %2, i64 13
  %value50 = load i64, ptr %start49, align 4
  store i64 %value50, ptr %element46, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %value39
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds48:                                  ; preds = %loop_body
  unreachable

inbounds51:                                       ; preds = %loop_end
  %start53 = getelementptr i64, ptr %2, i64 %15
  %value54 = load i64, ptr %start53, align 4
  %18 = add i64 %15, 1
  %start55 = getelementptr i64, ptr %2, i64 %18
  %value56 = load i64, ptr %start55, align 4
  %19 = add i64 %18, 1
  %20 = icmp ult i64 %19, %1
  br i1 %20, label %not_all_bytes_read, label %buffer_read

out_of_bounds52:                                  ; preds = %loop_end
  unreachable

not_all_bytes_read:                               ; preds = %inbounds51
  unreachable

buffer_read:                                      ; preds = %inbounds51
  call void @_constructContract(ptr %heap_to_ptr, ptr %heap_to_ptr11, ptr %heap_to_ptr25, ptr %heap_to_ptr45, i64 %value54, i64 %value56)
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
