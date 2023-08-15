; ModuleID = 'StructExample'
source_filename = "examples/source/struct/struct_1.ola"

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

define ptr @createBook() {
entry:
  %struct_alloca2 = alloca { i64, i64 }, align 8
  %struct_alloca = alloca { i64, i64 }, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  store i64 1, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 3, ptr %"struct member1", align 4
  %"struct member3" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca2, i32 0, i32 0
  store i64 2, ptr %"struct member3", align 4
  %"struct member4" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca2, i32 0, i32 1
  store i64 4, ptr %"struct member4", align 4
  ret ptr %struct_alloca2
}
