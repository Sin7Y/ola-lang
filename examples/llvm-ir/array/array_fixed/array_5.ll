; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array_5.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

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

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define ptr @array_call(ptr %0) {
entry:
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %0, i64 0, i64 2
  store i64 100, ptr %index_access, align 4
  ret ptr %0
}