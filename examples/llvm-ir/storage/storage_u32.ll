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

define void @inc_simple(i64 %0) {
entry:
  %storage_value_ptr = alloca i64, i64 4, align 8
  %storage_key_ptr = alloca i64, i64 4, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  %1 = load i64, ptr %a, align 4
  %storage_key = load [4 x i64], ptr %storage_key_ptr, align 4
  %2 = insertvalue [4 x i64] %storage_key, i64 0, 0
  %3 = insertvalue [4 x i64] %storage_key, i64 0, 1
  %4 = insertvalue [4 x i64] %storage_key, i64 0, 2
  %5 = insertvalue [4 x i64] %storage_key, i64 0, 3
  %storage_value = load [4 x i64], ptr %storage_value_ptr, align 4
  %6 = insertvalue [4 x i64] %storage_value, i64 0, 0
  %7 = insertvalue [4 x i64] %storage_value, i64 0, 1
  %8 = insertvalue [4 x i64] %storage_value, i64 0, 2
  %9 = insertvalue [4 x i64] %storage_value, i64 %1, 3
  call void @set_storage([4 x i64] %storage_key, [4 x i64] %storage_value)
  ret void
}

define i64 @get() {
entry:
  %storage_key_ptr = alloca i64, i64 4, align 8
  %storage_key = load [4 x i64], ptr %storage_key_ptr, align 4
  %0 = insertvalue [4 x i64] %storage_key, i64 0, 0
  %1 = insertvalue [4 x i64] %storage_key, i64 0, 1
  %2 = insertvalue [4 x i64] %storage_key, i64 0, 2
  %3 = insertvalue [4 x i64] %storage_key, i64 0, 3
  %4 = call [4 x i64] @get_storage([4 x i64] %storage_key)
  %5 = extractvalue [4 x i64] %4, 3
  ret i64 %5
}
