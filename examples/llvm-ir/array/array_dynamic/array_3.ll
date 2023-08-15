; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_3.ola"

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
  %b = alloca i64, align 8
  %length = load i64, ptr null, align 4
  %0 = sub i64 %length, 1
  %1 = sub i64 %0, 1
  call void @builtin_range_check(i64 %1)
  store i64 10, ptr getelementptr (i64, ptr inttoptr (i64 1 to ptr), i64 1), align 4
  %length1 = load i64, ptr null, align 4
  store i64 %length1, ptr %b, align 4
  ret void
}