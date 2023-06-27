; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/storage/storage_array_dyn.ola"

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

define void @addElement(i64 %0) {
entry:
  %element = alloca i64, align 8
  store i64 %0, ptr %element, align 4
  %slot = alloca i64, align 8
  store i64 0, ptr %slot, align 4
  %1 = load i64, ptr %slot, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  %3 = call [4 x i64] @get_storage([4 x i64] %2)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %6 = extractvalue [4 x i64] %5, 3
  %7 = add i64 %6, %4
  %8 = insertvalue [4 x i64] %5, i64 %7, 3
  %9 = load i64, ptr %element, align 4
  %slot1 = alloca [4 x i64], align 8
  store [4 x i64] %8, ptr %slot1, align 4
  %10 = load [4 x i64], ptr %slot1, align 4
  %11 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %9, 3
  call void @set_storage([4 x i64] %10, [4 x i64] %11)
  %new_length = add i64 %4, 1
  %slot2 = alloca i64, align 8
  store i64 0, ptr %slot2, align 4
  %12 = load i64, ptr %slot2, align 4
  %13 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %12, 3
  %14 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] %13, [4 x i64] %14)
  ret void
}
