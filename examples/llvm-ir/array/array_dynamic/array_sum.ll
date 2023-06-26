; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_sum.ola"

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

define i64 @sum(ptr %0) {
entry:
  %i = alloca i64, align 8
  %totalSum = alloca i64, align 8
  %inputArray = alloca ptr, align 8
  store ptr %0, ptr %inputArray, align 8
  %1 = call ptr @vector_new(i64 10, ptr null)
  store i64 0, ptr %totalSum, align 4
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
  %index_access = getelementptr [10 x i64], ptr %inputArray, i64 0, i64 %4
  %6 = load i64, ptr %index_access, align 4
  %7 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access1 = getelementptr i64, ptr %data, i64 %7
  store i64 %6, ptr %index_access1, align 4
  %8 = load i64, ptr %totalSum, align 4
  %9 = load i64, ptr %i, align 4
  %vector_len2 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length3 = load i64, ptr %vector_len2, align 4
  %data4 = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access5 = getelementptr i64, ptr %data4, i64 %9
  %10 = load i64, ptr %index_access5, align 4
  %11 = add i64 %8, %10
  call void @builtin_range_check(i64 %11)
  br label %next

next:                                             ; preds = %body
  %12 = load i64, ptr %i, align 4
  %13 = add i64 %12, 1
  store i64 %13, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %14 = load i64, ptr %totalSum, align 4
  ret i64 %14
}
