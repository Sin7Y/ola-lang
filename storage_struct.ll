; ModuleID = 'StructExample'
source_filename = "examples/source/storage/storage_struct.ola"

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

define void @setData(i64 %0, i64 %1) {
entry:
  %storage_value_ptr4 = alloca i64, i64 4, align 8
  %storage_key_ptr2 = alloca i64, i64 4, align 8
  %storage_value_ptr = alloca i64, i64 4, align 8
  %storage_key_ptr = alloca i64, i64 4, align 8
  %struct_alloca = alloca { i64, i64 }, align 8
  %_value = alloca i64, align 8
  %_id = alloca i64, align 8
  store i64 %0, ptr %_id, align 4
  store i64 %1, ptr %_value, align 4
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  %2 = load i64, ptr %_id, align 4
  store i64 %2, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  %3 = load i64, ptr %_value, align 4
  store i64 %3, ptr %"struct member1", align 4
  %id = getelementptr { i64, i64 }, ptr %struct_alloca, i64 0
  %4 = load i64, ptr %id, align 4
  %storage_key = load [4 x i64], ptr %storage_key_ptr, align 4
  %5 = insertvalue [4 x i64] %storage_key, i64 0, 0
  %6 = insertvalue [4 x i64] %storage_key, i64 0, 1
  %7 = insertvalue [4 x i64] %storage_key, i64 0, 2
  %8 = insertvalue [4 x i64] %storage_key, i64 0, 3
  %storage_value = load [4 x i64], ptr %storage_value_ptr, align 4
  %9 = insertvalue [4 x i64] %storage_value, i64 0, 0
  %10 = insertvalue [4 x i64] %storage_value, i64 0, 1
  %11 = insertvalue [4 x i64] %storage_value, i64 0, 2
  %12 = insertvalue [4 x i64] %storage_value, i64 %4, 3
  call void @set_storage([4 x i64] %storage_key, [4 x i64] %storage_value)
  %value = getelementptr { i64, i64 }, ptr %struct_alloca, i64 1
  %13 = load i64, ptr %value, align 4
  %storage_key3 = load [4 x i64], ptr %storage_key_ptr2, align 4
  %14 = insertvalue [4 x i64] %storage_key3, i64 0, 0
  %15 = insertvalue [4 x i64] %storage_key3, i64 0, 1
  %16 = insertvalue [4 x i64] %storage_key3, i64 0, 2
  %17 = insertvalue [4 x i64] %storage_key3, i64 1, 3
  %storage_value5 = load [4 x i64], ptr %storage_value_ptr4, align 4
  %18 = insertvalue [4 x i64] %storage_value5, i64 0, 0
  %19 = insertvalue [4 x i64] %storage_value5, i64 0, 1
  %20 = insertvalue [4 x i64] %storage_value5, i64 0, 2
  %21 = insertvalue [4 x i64] %storage_value5, i64 %13, 3
  call void @set_storage([4 x i64] %storage_key3, [4 x i64] %storage_value5)
  ret void
}
