; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array_3.ola"

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

define void @main() {
entry:
  %array_literal = alloca [3 x i64], align 8
  %elemptr0 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 0
  store i64 0, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  store i64 0, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 0, ptr %elemptr2, align 4
  call void @builtin_range_check(i64 0)
  %index_access = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %index_access, align 4
  call void @builtin_range_check(i64 1)
  %index_access1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  call void @builtin_range_check(i64 1)
  %index_access2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  %0 = load i64, ptr %index_access2, align 4
  %1 = add i64 %0, 1
  call void @builtin_range_check(i64 %1)
  store i64 %1, ptr %index_access1, align 4
  call void @builtin_range_check(i64 0)
  %index_access3 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  call void @builtin_range_check(i64 0)
  %index_access4 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  %2 = load i64, ptr %index_access4, align 4
  %3 = sub i64 %2, 1
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %index_access3, align 4
  ret void
}
