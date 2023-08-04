; ModuleID = 'FixedArrayExample'
source_filename = "examples/source/array/array_fixed/array_2.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

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
  store i64 1, ptr %elemptr0, align 4
  %elemptr1 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [3 x i64], ptr %array_literal, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  ret void
}
