; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array_6.ola"

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

define void @array_call() {
entry:
  %array_literal1 = alloca [2 x i64], align 8
  %array_literal = alloca [2 x i64], align 8
  %elemptr0 = getelementptr [2 x i64], ptr %array_literal, i64 0, i64 0
  store i64 88, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [2 x i64], ptr %array_literal, i64 0, i64 1
  store i64 99, ptr %elemptr1, align 4
  %elemptr02 = getelementptr [2 x i64], ptr %array_literal1, i64 0, i64 0
  store i64 1000, ptr %elemptr02, align 4
  %elemptr13 = getelementptr [2 x i64], ptr %array_literal1, i64 0, i64 1
  store i64 1001, ptr %elemptr13, align 4
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [2 x i64], ptr %array_literal1, i64 0, i64 1
  store i64 7, ptr %index_access, align 4
  ret void
}
