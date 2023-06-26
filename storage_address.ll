; ModuleID = 'AddressExample'
source_filename = "examples/source/storage/storage_address.ola"

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

define [4 x i64] @get_caller() {
entry:
  %caller_ = alloca [4 x i64], align 8
  store [4 x i64] zeroinitializer, ptr %caller_, align 4
  %0 = load [4 x i64], ptr %caller_, align 4
  ret [4 x i64] %0
}
