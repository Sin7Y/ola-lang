; ModuleID = 'Array'
source_filename = "examples/source/array/array.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @prophet_malloc(i64)

define i64 @array_literal() {
entry:
  %a = alloca ptr, align 8
  %array_literal = alloca [3 x i64], align 8
  %elemptr0 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  store ptr %array_literal, ptr %a, align 8
  %0 = load ptr, ptr %a, align 8
  call void @builtin_range_check(i64 1)
  %index_access = getelementptr [3 x i64], ptr %0, i64 0, i64 1
  %1 = load i64, ptr %index_access, align 4
  ret i64 %1
}

define void @main() {
entry:
  %0 = call i64 @array_literal()
  ret void
}
