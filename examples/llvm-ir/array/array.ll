; ModuleID = 'Array'
source_filename = "examples/source/array/array.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

define i64 @array_literal() {
entry:
  %array_literal = alloca [3 x i64], align 8
  %elemptr0 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  call void @builtin_range_check(i64 1)
  %index_access = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  %0 = load i64, ptr %index_access, align 4
  ret i64 %0
}

define i64 @array_dynamic_1() {
entry:
  %0 = call ptr @vector_new(i64 3, ptr null)
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  store i64 1, ptr %index_access, align 4
  %data1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access2 = getelementptr ptr, ptr %data1, i64 1
  store i64 2, ptr %index_access2, align 4
  %data3 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access4 = getelementptr ptr, ptr %data3, i64 2
  store i64 3, ptr %index_access4, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  ret i64 %length
}

define i64 @array_dynamic_2() {
entry:
  %0 = call ptr @vector_new(i64 5, ptr null)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  ret i64 %length
}

define void @main() {
entry:
  %0 = call i64 @array_literal()
  ret void
}
