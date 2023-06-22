; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_1.ola"

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
  %0 = call ptr @vector_new(i64 3, ptr null)
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  store i64 1, ptr %index_access, align 4
  %data1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access2 = getelementptr ptr, ptr %data1, i64 1
  store i64 2, ptr %index_access2, align 4
  %data3 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access4 = getelementptr ptr, ptr %data3, i64 2
  store i64 3, ptr %index_access4, align 4
  ret void
}
