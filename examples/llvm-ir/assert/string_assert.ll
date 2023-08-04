; ModuleID = 'AssertContract'
source_filename = "examples/source/assert/string_assert.ola"

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

define void @main() {
entry:
  %index = alloca i64, align 8
  %0 = call i64 @vector_new(i64 5)
  %heap_ptr = sub i64 %0, 5
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 0
  store i64 104, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %int_to_ptr, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %int_to_ptr, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %int_to_ptr, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %int_to_ptr, i64 4
  store i64 111, ptr %index_access4, align 4
  %1 = call ptr @vector_new_init(i64 5, ptr %int_to_ptr)
  %2 = call i64 @vector_new(i64 5)
  %heap_ptr5 = sub i64 %2, 5
  %int_to_ptr6 = inttoptr i64 %heap_ptr5 to ptr
  %index_access7 = getelementptr i64, ptr %int_to_ptr6, i64 0
  store i64 104, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %int_to_ptr6, i64 1
  store i64 101, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %int_to_ptr6, i64 2
  store i64 108, ptr %index_access9, align 4
  %index_access10 = getelementptr i64, ptr %int_to_ptr6, i64 3
  store i64 108, ptr %index_access10, align 4
  %index_access11 = getelementptr i64, ptr %int_to_ptr6, i64 4
  store i64 111, ptr %index_access11, align 4
  %3 = call ptr @vector_new_init(i64 5, ptr %int_to_ptr6)
  %data_ptr = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %length_ptr = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length = load i64, ptr %length_ptr, align 4
  %data_ptr12 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %length_ptr13 = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length14 = load i64, ptr %length_ptr13, align 4
  call void @builtin_assert(i64 %length, i64 %length14)
  store i64 0, ptr %index, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index15 = load i64, ptr %index, align 4
  %4 = icmp ult i64 %index15, %length
  br i1 %4, label %body, label %done

body:                                             ; preds = %cond
  %left_char_ptr = getelementptr i64, ptr %data_ptr, i64 %index15
  %right_char_ptr = getelementptr i64, ptr %data_ptr12, i64 %index15
  %left_char = load i64, ptr %left_char_ptr, align 4
  %right_char = load i64, ptr %right_char_ptr, align 4
  %comparison = icmp eq i64 %left_char, %right_char
  %next_index = add i64 %index15, 1
  store i64 %next_index, ptr %index, align 4
  br i1 %comparison, label %cond, label %done

done:                                             ; preds = %body, %cond
  %equal = icmp eq i64 %index15, %length14
  %5 = zext i1 %equal to i64
  call void @builtin_assert(i64 %5, i64 1)
  ret void
}
