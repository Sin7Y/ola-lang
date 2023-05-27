; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array_3.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

define void @main() {
entry:
  %array_literal = alloca [3 x i64], align 8
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %index_access, align 4
  call void @builtin_range_check(i64 1)
  %index_access1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  %0 = load i64, ptr %index_access1, align 4
  %1 = add i64 %0, 1
  call void @builtin_range_check(i64 %1)
  call void @builtin_range_check(i64 1)
  %index_access2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  store i64 %1, ptr %index_access2, align 4
  call void @builtin_range_check(i64 0)
  %index_access3 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  %2 = load i64, ptr %index_access3, align 4
  %3 = sub i64 %2, 1
  call void @builtin_range_check(i64 %3)
  call void @builtin_range_check(i64 0)
  %index_access4 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 %3, ptr %index_access4, align 4
  ret void
}
