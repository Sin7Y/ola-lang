; ModuleID = 'MemoryArrayExample'
source_filename = "examples/source/array/array_sum.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @prophet_malloc(i64)

define i64 @sum(ptr %0) {
entry:
  %i = alloca i64, align 8
  %totalSum = alloca i64, align 8
  %tempArray = alloca ptr, align 8
  %array_length = alloca i64, align 8
  %inputArray = alloca ptr, align 8
  store ptr %0, ptr %inputArray, align 8
  %malloc = call ptr @prophet_malloc(i64 10)
  store ptr %malloc, ptr %tempArray, align 8
  store i64 0, ptr %totalSum, align 4
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %2 = icmp ult i64 %1, 10
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = load ptr, ptr %inputArray, align 8
  %4 = load i64, ptr %i, align 4
  %5 = sub i64 9, %4
  call void @builtin_range_check(i64 %5)
  %index_access = getelementptr [10 x i64], ptr %3, i64 0, i64 %4
  %6 = load i64, ptr %index_access, align 4
  %7 = load ptr, ptr %tempArray, align 8
  %8 = load i64, ptr %i, align 4
  %array_length1 = load i64, ptr %array_length, align 4
  %data = getelementptr { i64, i64, [0 x i64] }, ptr %7, i32 0, i32 2
  %index_access2 = getelementptr i8, ptr %data, i64 %8
  store i64 %6, ptr %index_access2, align 4
  %9 = load i64, ptr %totalSum, align 4
  %10 = load ptr, ptr %tempArray, align 8
  %11 = load i64, ptr %i, align 4
  %array_length3 = load i64, ptr %array_length, align 4
  %data4 = getelementptr { i64, i64, [0 x i64] }, ptr %10, i32 0, i32 2
  %index_access5 = getelementptr i8, ptr %data4, i64 %11
  %12 = load i64, ptr %index_access5, align 4
  %13 = add i64 %9, %12
  call void @builtin_range_check(i64 %13)
  store i64 %13, ptr %totalSum, align 4
  br label %next

next:                                             ; preds = %body
  %14 = load i64, ptr %i, align 4
  %15 = add i64 %14, 1
  store i64 %15, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %16 = load i64, ptr %totalSum, align 4
  ret i64 %16
}
