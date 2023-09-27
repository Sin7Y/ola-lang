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

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define void @setStringLiteral() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca26 = alloca i64, align 8
  %1 = alloca ptr, align 8
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
  %13 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %13, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  %14 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %14, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 0, ptr %heap_to_ptr12, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %17, align 4
  call void @get_storage(ptr %heap_to_ptr12, ptr %heap_to_ptr10)
  %storage_value = load i64, ptr %heap_to_ptr10, align 4
  %18 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %18, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 0, ptr %heap_to_ptr14, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %21, align 4
  %22 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %22, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  store i64 %length, ptr %heap_to_ptr16, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr16, i64 1
  store i64 0, ptr %23, align 4
  %24 = getelementptr i64, ptr %heap_to_ptr16, i64 2
  store i64 0, ptr %24, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr16, i64 3
  store i64 0, ptr %25, align 4
  call void @set_storage(ptr %heap_to_ptr14, ptr %heap_to_ptr16)
  %26 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %26, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  store i64 0, ptr %heap_to_ptr18, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %27, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %29, align 4
  %30 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %30, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr18, ptr %heap_to_ptr20, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr20, ptr %1, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %31 = load ptr, ptr %1, align 8
  %32 = ptrtoint ptr %heap_to_ptr to i64
  %33 = add i64 %32, 1
  %vector_data21 = inttoptr i64 %33 to ptr
  %index_access22 = getelementptr i64, ptr %vector_data21, i64 %index_value
  call void @set_storage(ptr %31, ptr %index_access22)
  %34 = getelementptr i64, ptr %31, i64 3
  %slot_value = load i64, ptr %34, align 4
  %35 = add i64 %slot_value, 1
  store i64 %35, ptr %1, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca26, align 4
  store ptr %heap_to_ptr20, ptr %0, align 8
  br label %cond23

cond23:                                           ; preds = %body24, %done
  %index_value27 = load i64, ptr %index_alloca26, align 4
  %loop_cond28 = icmp ult i64 %index_value27, %storage_value
  br i1 %loop_cond28, label %body24, label %done25

body24:                                           ; preds = %cond23
  %36 = load ptr, ptr %0, align 8
  %37 = call i64 @vector_new(i64 4)
  %heap_start29 = sub i64 %37, 4
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr30, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr31 = getelementptr i64, ptr %heap_to_ptr30, i64 1
  store i64 0, ptr %storage_key_ptr31, align 4
  %storage_key_ptr32 = getelementptr i64, ptr %heap_to_ptr30, i64 2
  store i64 0, ptr %storage_key_ptr32, align 4
  %storage_key_ptr33 = getelementptr i64, ptr %heap_to_ptr30, i64 3
  store i64 0, ptr %storage_key_ptr33, align 4
  call void @set_storage(ptr %36, ptr %heap_to_ptr30)
  %38 = getelementptr i64, ptr %36, i64 3
  %slot_value34 = load i64, ptr %38, align 4
  %39 = add i64 %slot_value34, 1
  store i64 %39, ptr %0, align 4
  %next_index35 = add i64 %index_value27, 1
  store i64 %next_index35, ptr %index_alloca26, align 4
  br label %cond23

done25:                                           ; preds = %cond23
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
