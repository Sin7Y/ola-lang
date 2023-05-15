; ModuleID = 'ArraySortExample'
source_filename = "examples/array_sort.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare i64* @prophet_u32_array_sort(i64*, i64)

declare i64* @prophet_malloc(i64)

define void @main() {
entry:
  %a = alloca i64, align 8
  %0 = alloca [10 x i64], align 8
  %array_literal = alloca [10 x i64], align 8
  %elemptr0 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 0
  store i64 3, i64* %elemptr0, align 4
  %elemptr1 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 1
  store i64 4, i64* %elemptr1, align 4
  %elemptr2 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 2
  store i64 5, i64* %elemptr2, align 4
  %elemptr3 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 3
  store i64 1, i64* %elemptr3, align 4
  %elemptr4 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 4
  store i64 7, i64* %elemptr4, align 4
  %elemptr5 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 5
  store i64 9, i64* %elemptr5, align 4
  %elemptr6 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 6
  store i64 0, i64* %elemptr6, align 4
  %elemptr7 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 7
  store i64 2, i64* %elemptr7, align 4
  %elemptr8 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 8
  store i64 8, i64* %elemptr8, align 4
  %elemptr9 = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 9
  store i64 6, i64* %elemptr9, align 4
  %array_ptr = getelementptr [10 x i64], [10 x i64]* %array_literal, i64 0, i64 0
  %1 = call i64* @array_sort_test(i64* %array_ptr)
  %arrayidx = getelementptr i64, i64* %1, i64 0
  %2 = load i64, i64* %arrayidx, align 4
  %arrayidx1 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 0
  store i64 %2, i64* %arrayidx1, align 4
  %arrayidx2 = getelementptr i64, i64* %1, i64 1
  %3 = load i64, i64* %arrayidx2, align 4
  %arrayidx3 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 1
  store i64 %3, i64* %arrayidx3, align 4
  %arrayidx4 = getelementptr i64, i64* %1, i64 2
  %4 = load i64, i64* %arrayidx4, align 4
  %arrayidx5 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 2
  store i64 %4, i64* %arrayidx5, align 4
  %arrayidx6 = getelementptr i64, i64* %1, i64 3
  %5 = load i64, i64* %arrayidx6, align 4
  %arrayidx7 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 3
  store i64 %5, i64* %arrayidx7, align 4
  %arrayidx8 = getelementptr i64, i64* %1, i64 4
  %6 = load i64, i64* %arrayidx8, align 4
  %arrayidx9 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 4
  store i64 %6, i64* %arrayidx9, align 4
  %arrayidx10 = getelementptr i64, i64* %1, i64 5
  %7 = load i64, i64* %arrayidx10, align 4
  %arrayidx11 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 5
  store i64 %7, i64* %arrayidx11, align 4
  %arrayidx12 = getelementptr i64, i64* %1, i64 6
  %8 = load i64, i64* %arrayidx12, align 4
  %arrayidx13 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 6
  store i64 %8, i64* %arrayidx13, align 4
  %arrayidx14 = getelementptr i64, i64* %1, i64 7
  %9 = load i64, i64* %arrayidx14, align 4
  %arrayidx15 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 7
  store i64 %9, i64* %arrayidx15, align 4
  %arrayidx16 = getelementptr i64, i64* %1, i64 8
  %10 = load i64, i64* %arrayidx16, align 4
  %arrayidx17 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 8
  store i64 %10, i64* %arrayidx17, align 4
  %arrayidx18 = getelementptr i64, i64* %1, i64 9
  %11 = load i64, i64* %arrayidx18, align 4
  %arrayidx19 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 9
  store i64 %11, i64* %arrayidx19, align 4
  %12 = getelementptr [10 x i64], [10 x i64]* %0, i64 0, i64 0
  call void @builtin_range_check(i64 10)
  %index_access = getelementptr i64, i64* %12, i64 0
  %13 = load i64, i64* %index_access, align 4
  store i64 %13, i64* %a, align 8
  %14 = load i64, i64* %a, align 8
  call void @builtin_range_check(i64 10)
  %index_access20 = getelementptr i64, i64* %array_ptr, i64 0
  store i64 %14, i64* %index_access20, align 4
  ret void
}

define i64* @array_sort_test(i64* %0) {
entry:
  %1 = call i64* @prophet_u32_array_sort(i64* %0, i64 10)
  ret i64* %1
}
