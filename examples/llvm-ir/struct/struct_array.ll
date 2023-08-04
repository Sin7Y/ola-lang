; ModuleID = 'StructWithArrayExample'
source_filename = "examples/source/struct/struct_array.ola"

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

define ptr @createStudent() {
entry:
  %struct_alloca = alloca { i64, ptr }, align 8
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
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
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
  %index_access1 = getelementptr i64, ptr %data_ptr, i64 0
  store i64 85, ptr %index_access1, align 4
  %length_ptr2 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length3 = load i64, ptr %length_ptr2, align 4
  %4 = sub i64 %length3, 1
  %5 = sub i64 %4, 1
  call void @builtin_range_check(i64 %5)
  %data_ptr4 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access5 = getelementptr i64, ptr %data_ptr4, i64 1
  store i64 90, ptr %index_access5, align 4
  %length_ptr6 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length7 = load i64, ptr %length_ptr6, align 4
  %6 = sub i64 %length7, 1
  %7 = sub i64 %6, 2
  call void @builtin_range_check(i64 %7)
  %data_ptr8 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access9 = getelementptr i64, ptr %data_ptr8, i64 2
  store i64 95, ptr %index_access9, align 4
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 0
  store i64 20, ptr %"struct member", align 4
  %"struct member10" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 1
  store ptr %1, ptr %"struct member10", align 8
  ret ptr %struct_alloca
}
