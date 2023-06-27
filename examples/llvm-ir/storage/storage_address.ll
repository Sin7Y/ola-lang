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

define void @addressFunction() {
entry:
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938])
  ret void
}

define void @setAddress([4 x i64] %0) {
entry:
  %_address = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %_address, align 4
  %1 = load [4 x i64], ptr %_address, align 4
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %1)
  ret void
}

define [4 x i64] @getAddress() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  ret [4 x i64] %0
}

define [4 x i64] @get_caller() {
entry:
  %caller_ = alloca [4 x i64], align 8
  store [4 x i64] zeroinitializer, ptr %caller_, align 4
}
