; ModuleID = 'AddressExample'
source_filename = "examples/source/storage/storage_string.ola"

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

define void @setStringLiteral() {
entry:
  %0 = alloca [4 x i64], align 8
  %index_alloca14 = alloca i64, align 8
  %1 = alloca [4 x i64], align 8
  %index_alloca = alloca i64, align 8
  %2 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %2, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 5, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data = inttoptr i64 %4 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access, align 4
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr i64, ptr %vector_data1, i64 1
  store i64 101, ptr %index_access2, align 4
  %7 = ptrtoint ptr %heap_to_ptr to i64
  %8 = add i64 %7, 1
  %vector_data3 = inttoptr i64 %8 to ptr
  %index_access4 = getelementptr i64, ptr %vector_data3, i64 2
  store i64 108, ptr %index_access4, align 4
  %9 = ptrtoint ptr %heap_to_ptr to i64
  %10 = add i64 %9, 1
  %vector_data5 = inttoptr i64 %10 to ptr
  %index_access6 = getelementptr i64, ptr %vector_data5, i64 3
  store i64 108, ptr %index_access6, align 4
  %11 = ptrtoint ptr %heap_to_ptr to i64
  %12 = add i64 %11, 1
  %vector_data7 = inttoptr i64 %12 to ptr
  %index_access8 = getelementptr i64, ptr %vector_data7, i64 4
  store i64 111, ptr %index_access8, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %13 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %14 = extractvalue [4 x i64] %13, 3
  %15 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %15)
  %16 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %16, ptr %1, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %17 = load [4 x i64], ptr %1, align 4
  %18 = ptrtoint ptr %heap_to_ptr to i64
  %19 = add i64 %18, 1
  %vector_data9 = inttoptr i64 %19 to ptr
  %index_access10 = getelementptr i64, ptr %vector_data9, i64 %index_value
  %20 = load i64, ptr %index_access10, align 4
  %21 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %20, 3
  call void @set_storage([4 x i64] %17, [4 x i64] %21)
  %22 = extractvalue [4 x i64] %17, 3
  %23 = add i64 %22, 1
  %24 = insertvalue [4 x i64] %17, i64 %23, 3
  store [4 x i64] %24, ptr %1, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca14, align 4
  store [4 x i64] %16, ptr %0, align 4
  br label %cond11

cond11:                                           ; preds = %body12, %done
  %index_value15 = load i64, ptr %index_alloca14, align 4
  %loop_cond16 = icmp ult i64 %index_value15, %14
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %25 = load [4 x i64], ptr %0, align 4
  call void @set_storage([4 x i64] %25, [4 x i64] zeroinitializer)
  %26 = extractvalue [4 x i64] %25, 3
  %27 = add i64 %26, 1
  %28 = insertvalue [4 x i64] %25, i64 %27, 3
  store [4 x i64] %28, ptr %0, align 4
  %next_index17 = add i64 %index_value15, 1
  store i64 %next_index17, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 515430227, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @setStringLiteral()
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
