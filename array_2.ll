; ModuleID = 'ArraySortExample'
source_filename = "examples/array_2.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @prophet_malloc(i64)

define i64 @array_sort_test(ptr %0) {
entry:
  %array_literal = alloca [10 x i64], align 8
  %elemptr0 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 0
  store i64 0, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 1
  store i64 1, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  store i64 2, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 3
  store i64 3, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 4
  store i64 4, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 5
  store i64 5, ptr %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 6
  store i64 6, ptr %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 7
  store i64 7, ptr %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 8
  store i64 8, ptr %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 9
  store i64 9, ptr %elemptr9, align 4
  %array_literal1 = alloca [10 x i64], align 8
  %elemptr02 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 0
  store i64 1, ptr %elemptr02, align 4
  %elemptr13 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 1
  store i64 2, ptr %elemptr13, align 4
  %elemptr24 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 2
  store i64 3, ptr %elemptr24, align 4
  %elemptr35 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 3
  store i64 4, ptr %elemptr35, align 4
  %elemptr46 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 4
  store i64 5, ptr %elemptr46, align 4
  %elemptr57 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 5
  store i64 6, ptr %elemptr57, align 4
  %elemptr68 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 6
  store i64 7, ptr %elemptr68, align 4
  %elemptr79 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 7
  store i64 8, ptr %elemptr79, align 4
  %elemptr810 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 8
  store i64 9, ptr %elemptr810, align 4
  %elemptr911 = getelementptr [10 x i64], ptr %array_literal1, i64 0, i64 9
  store i64 0, ptr %elemptr911, align 4
  store ptr %array_literal, ptr %array_literal1, align 8
  call void @builtin_range_check(i64 8)
  %index_access = getelementptr [10 x i64], ptr %array_literal, i64 0, i64 2
  %1 = load i64, ptr %index_access, align 4
  ret i64 %1
}
