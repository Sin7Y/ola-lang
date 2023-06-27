; ModuleID = 'SimpleVar'
source_filename = "examples/source/storage/storage_u32.ola"

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

define void @inc_simple() {
entry:
  %slot = alloca i64, align 8
  store i64 0, ptr %slot, align 4
  %0 = load i64, ptr %slot, align 4
  %1 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %0, 3
  call void @set_storage([4 x i64] %1, [4 x i64] [i64 0, i64 0, i64 0, i64 100])
  ret void
}

define i64 @get() {
entry:
  %slot = alloca i64, align 8
  store i64 0, ptr %slot, align 4
  %0 = load i64, ptr %slot, align 4
  %1 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %0, 3
  %2 = call [4 x i64] @get_storage([4 x i64] %1)
  %3 = extractvalue [4 x i64] %2, 3
  ret i64 %3
}

define void @main() {
entry:
  %x = alloca i64, align 8
  call void @inc_simple()
  %0 = call i64 @get()
  store i64 %0, ptr %x, align 4
  ret void
}
