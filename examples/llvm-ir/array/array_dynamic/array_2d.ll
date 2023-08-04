; ModuleID = 'DynamicArrayInMemory'
source_filename = "examples/source/array/array_dynamic/array_2d.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @processDynamicArray() {
entry:
  %index_alloca7 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 3)
  %heap_ptr = sub i64 %0, 3
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr { i64, ptr }, ptr %int_to_ptr, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %1 = call ptr @vector_new_init(i64 3, ptr %int_to_ptr)
  %length_ptr = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length = load i64, ptr %length_ptr, align 4
  %2 = sub i64 %length, 1
  %3 = sub i64 %2, 0
  call void @builtin_range_check(i64 %3)
  %data_ptr = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access1 = getelementptr ptr, ptr %data_ptr, i64 0
  %4 = call i64 @vector_new(i64 2)
  %heap_ptr2 = sub i64 %4, 2
  %int_to_ptr3 = inttoptr i64 %heap_ptr2 to ptr
  store i64 0, ptr %index_alloca7, align 4
  br label %cond4

cond4:                                            ; preds = %body5, %done
  %index_value8 = load i64, ptr %index_alloca7, align 4
  %loop_cond9 = icmp ult i64 %index_value8, 2
  br i1 %loop_cond9, label %body5, label %done6

body5:                                            ; preds = %cond4
  %index_access10 = getelementptr i64, ptr %int_to_ptr3, i64 %index_value8
  store i64 0, ptr %index_access10, align 4
  %next_index11 = add i64 %index_value8, 1
  store i64 %next_index11, ptr %index_alloca7, align 4
  br label %cond4

done6:                                            ; preds = %cond4
  %5 = call ptr @vector_new_init(i64 2, ptr %int_to_ptr3)
  store ptr %5, ptr %index_access1, align 8
  %length_ptr12 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length13 = load i64, ptr %length_ptr12, align 4
  %6 = sub i64 %length13, 1
  %7 = sub i64 %6, 0
  call void @builtin_range_check(i64 %7)
  %data_ptr14 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access15 = getelementptr ptr, ptr %data_ptr14, i64 0
  %length_ptr16 = getelementptr inbounds { i64, ptr }, ptr %index_access15, i32 0, i32 0
  %length17 = load i64, ptr %length_ptr16, align 4
  %8 = sub i64 %length17, 1
  %9 = sub i64 %8, 0
  call void @builtin_range_check(i64 %9)
  %data_ptr18 = getelementptr inbounds { i64, ptr }, ptr %index_access15, i32 0, i32 1
  %index_access19 = getelementptr i64, ptr %data_ptr18, i64 0
  store i64 1, ptr %index_access19, align 4
  ret void
}
