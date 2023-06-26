; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_4.ola"

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

define void @main() {
entry:
  %0 = call ptr @vector_new(i64 5, ptr null)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  store i64 1, ptr %index_access, align 4
  %1 = call ptr @array_call(i64 5)
  ret void
}

define ptr @array_call(i64 %0) {
entry:
  %length = alloca i64, align 8
  store i64 %0, ptr %length, align 4
  %1 = load i64, ptr %length, align 4
  %2 = call ptr @vector_new(i64 %1, ptr null)
  ret ptr %2
}
