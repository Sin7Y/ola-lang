; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_3.ola"

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
  %b = alloca i64, align 8
  %0 = call ptr @vector_new(i64 0, ptr null)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 1
  store i64 10, ptr %index_access, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  store i64 %length2, ptr %b, align 4
  ret void
}
