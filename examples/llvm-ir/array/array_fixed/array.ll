; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array.ola"

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

define void @main() {
entry:
  %array_literal6 = alloca [3 x i64], align 8
  %array_literal2 = alloca [3 x i64], align 8
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
  %1 = add i64 %0, 1
  call void @builtin_range_check(i64 %1)
  call void @builtin_range_check(i64 1)
  %index_access1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  store i64 %1, ptr %index_access1, align 4
  %elemptr03 = getelementptr [3 x i64], ptr %array_literal2, i64 0, i64 0
  store i64 1, ptr %elemptr03, align 4
  %elemptr14 = getelementptr [3 x i64], ptr %array_literal2, i64 0, i64 1
  store i64 2, ptr %elemptr14, align 4
  %elemptr25 = getelementptr [3 x i64], ptr %array_literal2, i64 0, i64 2
  store i64 3, ptr %elemptr25, align 4
  call void @builtin_range_check(i64 0)
  %index_access7 = getelementptr [3 x i64], ptr %array_literal6, i64 0, i64 2
  store i64 99, ptr %index_access7, align 4
  %2 = call ptr @array_call(ptr %array_literal6)
  ret void
}

define ptr @array_call(ptr %0) {
entry:
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %source, i64 0, i64 2
  store i64 100, ptr %index_access, align 4
  ret ptr %source
}
