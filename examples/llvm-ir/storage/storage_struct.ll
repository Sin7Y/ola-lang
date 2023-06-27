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
  %slot = alloca i64, align 8
  %id = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  store i64 0, ptr %slot, align 4
  %4 = load i64, ptr %id, align 4
  %5 = load i64, ptr %slot, align 4
  %6 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %5, 3
  %7 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %4, 3
  call void @set_storage([4 x i64] %6, [4 x i64] %7)
  %value = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 1, ptr %slot, align 4
  %8 = load i64, ptr %value, align 4
  %9 = load i64, ptr %slot, align 4
  %10 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %9, 3
  %11 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %8, 3
  call void @set_storage([4 x i64] %10, [4 x i64] %11)
  ret void
}

define i64 @getData() {
entry:
  %slot = alloca i64, align 8
  store i64 1, ptr %slot, align 4
  %0 = load i64, ptr %slot, align 4
  %1 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %0, 3
  %2 = call [4 x i64] @get_storage([4 x i64] %1)
  %3 = extractvalue [4 x i64] %2, 3
  ret i64 %3
}
