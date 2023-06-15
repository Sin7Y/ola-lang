; ModuleID = 'SimpleVar'
source_filename = "examples/source/storage/storage_u32.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare void @get_storage(i64, i64, i64, i64, ptr, ptr, ptr, ptr)

declare void @set_storage(i64, i64, i64, i64, i64, i64, i64, i64)

declare void @poseidon_hash(i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr, ptr)

define void @inc_simple() {
entry:
  %storage_ret_35 = alloca i64, align 8
  %storage_ret_24 = alloca i64, align 8
  %storage_ret_13 = alloca i64, align 8
  %storage_ret_02 = alloca i64, align 8
  %storage_ret_3 = alloca i64, align 8
  %storage_ret_2 = alloca i64, align 8
  %storage_ret_1 = alloca i64, align 8
  %storage_ret_0 = alloca i64, align 8
  call void @get_storage(i64 0, i64 0, i64 0, i64 0, ptr %storage_ret_3, ptr %storage_ret_2, ptr %storage_ret_1, ptr %storage_ret_0)
  %storage_ret_01 = load i64, ptr %storage_ret_0, align 4
  %0 = add i64 %storage_ret_01, 2
  call void @builtin_range_check(i64 %0)
  call void @get_storage(i64 0, i64 0, i64 0, i64 0, ptr %storage_ret_35, ptr %storage_ret_24, ptr %storage_ret_13, ptr %storage_ret_02)
  %storage_ret_06 = load i64, ptr %storage_ret_02, align 4
  %1 = add i64 %storage_ret_06, 2
  call void @builtin_range_check(i64 %1)
  call void @set_storage(i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 %1)
  ret void
}

define i64 @get() {
entry:
  %storage_ret_3 = alloca i64, align 8
  %storage_ret_2 = alloca i64, align 8
  %storage_ret_1 = alloca i64, align 8
  %storage_ret_0 = alloca i64, align 8
  call void @get_storage(i64 0, i64 0, i64 0, i64 0, ptr %storage_ret_3, ptr %storage_ret_2, ptr %storage_ret_1, ptr %storage_ret_0)
  %storage_ret_01 = load i64, ptr %storage_ret_0, align 4
  ret i64 %storage_ret_01
}
