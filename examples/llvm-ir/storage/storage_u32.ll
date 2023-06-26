; ModuleID = 'SimpleVar'
source_filename = "examples/source/storage/storage_u32.ola"

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

define void @inc_simple() {
entry:
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] [i64 0, i64 0, i64 0, i64 100])
  ret void
}

define i64 @get() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %1 = extractvalue [4 x i64] %0, 3
  ret i64 %1
}
