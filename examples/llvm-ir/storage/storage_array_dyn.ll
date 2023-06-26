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
  %1 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %2 = extractvalue [4 x i64] %1, 3
  %3 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %4 = extractvalue [4 x i64] %3, 3
  %5 = add i64 %4, %2
  %6 = insertvalue [4 x i64] %3, i64 %5, 3
  %7 = load i64, ptr %element, align 4
  %8 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %7, 3
  call void @set_storage([4 x i64] %6, [4 x i64] %8)
  %new_length = add i64 %2, 1
  %9 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1], [4 x i64] %9)
  ret void
}

define void @removeElement() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %1 = extractvalue [4 x i64] %0, 3
  %2 = call [4 x i64] @poseidon_hash([8 x i64] [i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 1])
  %3 = extractvalue [4 x i64] %2, 3
  %4 = add i64 %3, %1
  %5 = insertvalue [4 x i64] %2, i64 %4, 3
  %new_length = sub i64 %1, 1
  %6 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] [i64 0, i64 0, i64 0, i64 1], [4 x i64] %6)
  %7 = call [4 x i64] @get_storage([4 x i64] %5)
  %8 = extractvalue [4 x i64] %7, 3
  call void @set_storage([4 x i64] %5, [4 x i64] zeroinitializer)
  ret void
}

define i64 @getLength() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %1 = extractvalue [4 x i64] %0, 3
  ret i64 %1
}
