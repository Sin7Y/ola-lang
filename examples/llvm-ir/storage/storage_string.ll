; ModuleID = 'AddressExample'
source_filename = "examples/source/storage/storage_string.ola"

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

define void @setStringLiteral() {
entry:
  %0 = alloca [4 x i64], align 8
  %index_alloca9 = alloca i64, align 8
  %1 = alloca [4 x i64], align 8
  %index_alloca = alloca i64, align 8
  %2 = call i64 @vector_new(i64 5)
  %heap_ptr = sub i64 %2, 5
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
  %3 = call ptr @vector_new_init(i64 5, ptr %int_to_ptr)
  %length_ptr = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 0
  %length = load i64, ptr %length_ptr, align 4
  %4 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %5 = extractvalue [4 x i64] %4, 3
  %6 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %6)
  %7 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  store i64 0, ptr %index_alloca, align 4
  store [4 x i64] %7, ptr %1, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %8 = load [4 x i64], ptr %1, align 4
  %data_ptr = getelementptr inbounds { i64, ptr }, ptr %3, i32 0, i32 1
  %index_access5 = getelementptr i64, ptr %data_ptr, i64 %index_value
  %9 = load i64, ptr %index_access5, align 4
  %10 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %9, 3
  call void @set_storage([4 x i64] %8, [4 x i64] %10)
  %11 = extractvalue [4 x i64] %8, 3
  %12 = add i64 %11, 1
  %13 = insertvalue [4 x i64] %8, i64 %12, 3
  store [4 x i64] %13, ptr %1, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca9, align 4
  store [4 x i64] %7, ptr %0, align 4
  br label %cond6

cond6:                                            ; preds = %body7, %done
  %index_value10 = load i64, ptr %index_alloca9, align 4
  %loop_cond11 = icmp ult i64 %index_value10, %5
  br i1 %loop_cond11, label %body7, label %done8

body7:                                            ; preds = %cond6
  %14 = load [4 x i64], ptr %0, align 4
  call void @set_storage([4 x i64] %14, [4 x i64] zeroinitializer)
  %15 = extractvalue [4 x i64] %14, 3
  %16 = add i64 %15, 1
  %17 = insertvalue [4 x i64] %14, i64 %16, 3
  store [4 x i64] %17, ptr %0, align 4
  %next_index12 = add i64 %index_value10, 1
  store i64 %next_index12, ptr %index_alloca9, align 4
  br label %cond6

done8:                                            ; preds = %cond6
  ret void
}
