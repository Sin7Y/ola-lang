; ModuleID = 'TwoDArrayExample'
source_filename = "examples/source/array/array_2d.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define ptr @create2DArray() {
entry:
  %array_literal = alloca [3 x [2 x i64]], align 8
  %elemptr0 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 0
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 0
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 1, i64 1
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 0
  store i64 5, ptr %elemptr4, align 4
  %elemptr5 = getelementptr [3 x [2 x i64]], ptr %array_literal, i64 0, i64 2, i64 1
  store i64 6, ptr %elemptr5, align 4
  ret ptr %array_literal
}

define i64 @getElement(ptr %0, i64 %1, i64 %2) {
entry:
  %_j = alloca i64, align 8
  %_i = alloca i64, align 8
  %_array2D = alloca ptr, align 8
  store ptr %0, ptr %_array2D, align 8
  store i64 %1, ptr %_i, align 4
  store i64 %2, ptr %_j, align 4
  %3 = load i64, ptr %_i, align 4
  %4 = sub i64 2, %3
  call void @builtin_range_check(i64 %4)
  %index_access = getelementptr [3 x [2 x i64]], ptr %_array2D, i64 0, i64 %3
  %5 = load i64, ptr %_j, align 4
  %6 = sub i64 1, %5
  call void @builtin_range_check(i64 %6)
  %index_access1 = getelementptr [2 x i64], ptr %index_access, i64 0, i64 %5
  %7 = load i64, ptr %index_access1, align 4
  ret i64 %7
}
