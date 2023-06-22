; ModuleID = 'ArraySortExample'
source_filename = "examples/source/array/array_sort.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define void @main() {
entry:
  %array_literal = alloca [10 x i64], align 8
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  store i64 3, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  store i64 4, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  store i64 5, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  store i64 1, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  store i64 7, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  store i64 9, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  store i64 0, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  store i64 2, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  store i64 6, ptr %elemptr9, align 4
  %0 = call ptr @array_sort_test(ptr %array_literal)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  %1 = load i64, ptr %index_access, align 4
  %2 = add i64 %1, 1
  call void @builtin_range_check(i64 %2)
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %data3 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access4 = getelementptr ptr, ptr %data3, i64 0
  store i64 %2, ptr %index_access4, align 4
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %data7 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access8 = getelementptr ptr, ptr %data7, i64 1
  %3 = load i64, ptr %index_access8, align 4
  %4 = sub i64 %3, 1
  call void @builtin_range_check(i64 %4)
  %vector_len9 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length10 = load i64, ptr %vector_len9, align 4
  %data11 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access12 = getelementptr ptr, ptr %data11, i64 1
  store i64 %4, ptr %index_access12, align 4
  ret void
}

define ptr @array_sort_test(ptr %0) {
entry:
  %i = alloca i64, align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  %1 = call ptr @vector_new(i64 10, ptr null)
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %2 = load i64, ptr %i, align 4
  %3 = icmp ult i64 %2, 10
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = load i64, ptr %i, align 4
  %5 = sub i64 9, %4
  call void @builtin_range_check(i64 %5)
  %index_access = getelementptr [10 x i64], ptr %source, i64 0, i64 %4
  %6 = load i64, ptr %index_access, align 4
  %7 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access1 = getelementptr ptr, ptr %data, i64 %7
  store i64 %6, ptr %index_access1, align 4
  br label %next

next:                                             ; preds = %body
  %8 = load i64, ptr %i, align 4
  %9 = add i64 %8, 1
  call void @builtin_range_check(i64 %9)
  br label %cond

endfor:                                           ; preds = %cond
  %vector_len2 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length3 = load i64, ptr %vector_len2, align 4
  %10 = call ptr @prophet_u32_array_sort(ptr %1, i64 %length3)
  ret ptr %10
}
