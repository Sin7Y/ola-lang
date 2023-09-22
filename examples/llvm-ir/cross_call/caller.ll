; ModuleID = 'Caller'
source_filename = "examples/source/cross_call/caller.ola"

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

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @contract_call(i64, i64)

define void @delegatecall_test([4 x i64] %0) {
entry:
  %set_data = alloca i64, align 8
  %_contract = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %_contract, align 4
  store i64 66, ptr %set_data, align 4
  %1 = load i64, ptr %set_data, align 4
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 1, ptr %start, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %1, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 1, ptr %start2, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 2371037854, ptr %start3, align 4
  %3 = load [4 x i64], ptr %_contract, align 4
  %4 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %4, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %5 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  %6 = extractvalue [4 x i64] %3, 0
  store i64 %6, ptr %5, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  %8 = extractvalue [4 x i64] %3, 1
  store i64 %8, ptr %7, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  %10 = extractvalue [4 x i64] %3, 2
  store i64 %10, ptr %9, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  %12 = extractvalue [4 x i64] %3, 3
  store i64 %12, ptr %11, align 4
  %payload_len = load i64, ptr %heap_to_ptr, align 4
  %tape_size = add i64 %payload_len, 2
  %13 = ptrtoint ptr %heap_to_ptr to i64
  %payload_start = add i64 %13, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(i64 %heap_start4, i64 1)
  %14 = call i64 @vector_new(i64 1)
  %heap_start6 = sub i64 %14, 1
  %heap_to_ptr7 = inttoptr i64 %heap_start6 to ptr
  call void @get_tape_data(i64 %heap_start6, i64 1)
  %return_length = load i64, ptr %heap_to_ptr7, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size8 = add i64 %return_length, 1
  %15 = call i64 @vector_new(i64 %heap_size)
  %heap_start9 = sub i64 %15, %heap_size
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 %return_length, ptr %heap_to_ptr10, align 4
  %16 = add i64 %heap_start9, 1
  call void @get_tape_data(i64 %16, i64 %tape_size8)
  %17 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %18 = extractvalue [4 x i64] %17, 3
  %19 = icmp eq i64 %18, 66
  %20 = zext i1 %19 to i64
  call void @builtin_assert(i64 %20)
  ret void
}

define void @call_test([4 x i64] %0) {
entry:
  %result = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  %_contract = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %_contract, align 4
  store i64 100, ptr %a, align 4
  store i64 200, ptr %b, align 4
  %1 = load i64, ptr %a, align 4
  %2 = load i64, ptr %b, align 4
  %3 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %3, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 2, ptr %start, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %1, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %2, ptr %start2, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 2, ptr %start3, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 2062500454, ptr %start4, align 4
  %4 = load [4 x i64], ptr %_contract, align 4
  %5 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %5, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %6 = getelementptr i64, ptr %heap_to_ptr6, i64 0
  %7 = extractvalue [4 x i64] %4, 0
  store i64 %7, ptr %6, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  %9 = extractvalue [4 x i64] %4, 1
  store i64 %9, ptr %8, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  %11 = extractvalue [4 x i64] %4, 2
  store i64 %11, ptr %10, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %13 = extractvalue [4 x i64] %4, 3
  store i64 %13, ptr %12, align 4
  %payload_len = load i64, ptr %heap_to_ptr, align 4
  %tape_size = add i64 %payload_len, 2
  %14 = ptrtoint ptr %heap_to_ptr to i64
  %payload_start = add i64 %14, 1
  call void @set_tape_data(i64 %payload_start, i64 %tape_size)
  call void @contract_call(i64 %heap_start5, i64 0)
  %15 = call i64 @vector_new(i64 1)
  %heap_start7 = sub i64 %15, 1
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @get_tape_data(i64 %heap_start7, i64 1)
  %return_length = load i64, ptr %heap_to_ptr8, align 4
  %heap_size = add i64 %return_length, 2
  %tape_size9 = add i64 %return_length, 1
  %16 = call i64 @vector_new(i64 %heap_size)
  %heap_start10 = sub i64 %16, %heap_size
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  store i64 %return_length, ptr %heap_to_ptr11, align 4
  %17 = add i64 %heap_start10, 1
  call void @get_tape_data(i64 %17, i64 %tape_size9)
  %length = load i64, ptr %heap_to_ptr11, align 4
  %18 = ptrtoint ptr %heap_to_ptr11 to i64
  %19 = add i64 %18, 1
  %vector_data = inttoptr i64 %19 to ptr
  %20 = icmp ule i64 1, %length
  br i1 %20, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %entry
  %start12 = getelementptr i64, ptr %vector_data, i64 0
  %value = load i64, ptr %start12, align 4
  %21 = icmp ult i64 1, %length
  br i1 %21, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %entry
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  store i64 %value, ptr %result, align 4
  %22 = load i64, ptr %result, align 4
  %23 = icmp eq i64 %22, 300
  %24 = zext i1 %23 to i64
  call void @builtin_assert(i64 %24)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3965482278, label %func_0_dispatch
    i64 1607480800, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 4, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = insertvalue [4 x i64] undef, i64 %value, 0
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %5 = insertvalue [4 x i64] %4, i64 %value2, 1
  %start3 = getelementptr i64, ptr %2, i64 2
  %value4 = load i64, ptr %start3, align 4
  %6 = insertvalue [4 x i64] %5, i64 %value4, 2
  %start5 = getelementptr i64, ptr %2, i64 3
  %value6 = load i64, ptr %start5, align 4
  %7 = insertvalue [4 x i64] %6, i64 %value6, 3
  %8 = icmp ult i64 4, %1
  br i1 %8, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @delegatecall_test([4 x i64] %7)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %9 = icmp ule i64 4, %1
  br i1 %9, label %inbounds7, label %out_of_bounds8

inbounds7:                                        ; preds = %func_1_dispatch
  %start9 = getelementptr i64, ptr %2, i64 0
  %value10 = load i64, ptr %start9, align 4
  %10 = insertvalue [4 x i64] undef, i64 %value10, 0
  %start11 = getelementptr i64, ptr %2, i64 1
  %value12 = load i64, ptr %start11, align 4
  %11 = insertvalue [4 x i64] %10, i64 %value12, 1
  %start13 = getelementptr i64, ptr %2, i64 2
  %value14 = load i64, ptr %start13, align 4
  %12 = insertvalue [4 x i64] %11, i64 %value14, 2
  %start15 = getelementptr i64, ptr %2, i64 3
  %value16 = load i64, ptr %start15, align 4
  %13 = insertvalue [4 x i64] %12, i64 %value16, 3
  %14 = icmp ult i64 4, %1
  br i1 %14, label %not_all_bytes_read17, label %buffer_read18

out_of_bounds8:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read17:                             ; preds = %inbounds7
  unreachable

buffer_read18:                                    ; preds = %inbounds7
  call void @call_test([4 x i64] %13)
  ret void
}

define void @call() {
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
