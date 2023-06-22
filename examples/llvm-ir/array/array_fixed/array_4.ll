; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array_4.ola"

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

define i64 @array_call(ptr %0) {
entry:
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %source, i64 0, i64 2
  store i64 100, ptr %index_access, align 4
  call void @builtin_range_check(i64 0)
  %index_access1 = getelementptr [3 x i64], ptr %source, i64 0, i64 2
  %1 = load i64, ptr %index_access1, align 4
  ret i64 %1
}
