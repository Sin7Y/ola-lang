; ModuleID = 'SimpleMappingExample'
source_filename = "examples/source/storage/storage_mapping.ola"

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

define void @add_mapping([4 x i64] %0, i64 %1) {
entry:
  %number = alloca i64, align 8
  %name = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %name, align 4
  store i64 %1, ptr %number, align 4
  %2 = load i64, ptr %number, align 4
  %3 = load [4 x i64], ptr %name, align 4
  %4 = extractvalue [4 x i64] %3, 0
  %5 = extractvalue [4 x i64] %3, 1
  %6 = extractvalue [4 x i64] %3, 2
  %7 = extractvalue [4 x i64] %3, 3
  %8 = insertvalue [8 x i64] undef, i64 %7, 7
  %9 = insertvalue [8 x i64] %8, i64 %6, 6
  %10 = insertvalue [8 x i64] %9, i64 %5, 5
  %11 = insertvalue [8 x i64] %10, i64 %4, 4
  %12 = insertvalue [8 x i64] %11, i64 0, 3
  %13 = insertvalue [8 x i64] %12, i64 0, 2
  %14 = insertvalue [8 x i64] %13, i64 0, 1
  %15 = insertvalue [8 x i64] %14, i64 0, 0
  %16 = call [4 x i64] @poseidon_hash([8 x i64] %15)
  %17 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %2, 3
  call void @set_storage([4 x i64] %16, [4 x i64] %17)
  ret void
}
