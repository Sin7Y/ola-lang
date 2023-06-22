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
  %storage_value_ptr3 = alloca i64, i64 4, align 8
  %storage_key_ptr1 = alloca i64, i64 4, align 8
  %storage_value_ptr = alloca i64, i64 4, align 8
  %hash_src_ptr = alloca i64, i64 8, align 8
  %storage_key_ptr = alloca i64, i64 4, align 8
  %element = alloca i64, align 8
  store i64 %0, ptr %element, align 4
  %storage_key = load [4 x i64], ptr %storage_key_ptr, align 4
  %1 = insertvalue [4 x i64] %storage_key, i64 0, 0
  %2 = insertvalue [4 x i64] %storage_key, i64 0, 1
  %3 = insertvalue [4 x i64] %storage_key, i64 0, 2
  %4 = insertvalue [4 x i64] %storage_key, i64 0, 3
  %5 = call [4 x i64] @get_storage([4 x i64] %storage_key)
  %6 = extractvalue [4 x i64] %5, 3
  %hash_src = load [8 x i64], ptr %hash_src_ptr, align 4
  %7 = insertvalue [8 x i64] %hash_src, i64 1, 0
  %8 = insertvalue [8 x i64] %hash_src, i64 0, 1
  %9 = insertvalue [8 x i64] %hash_src, i64 0, 2
  %10 = insertvalue [8 x i64] %hash_src, i64 0, 3
  %11 = insertvalue [8 x i64] %hash_src, i64 0, 4
  %12 = insertvalue [8 x i64] %hash_src, i64 0, 5
  %13 = insertvalue [8 x i64] %hash_src, i64 0, 6
  %14 = insertvalue [8 x i64] %hash_src, i64 0, 7
  %15 = call [4 x i64] @poseidon_hash([8 x i64] %hash_src)
  %16 = extractvalue [4 x i64] %15, 3
  %17 = add i64 %16, %6
  %18 = insertvalue [4 x i64] %15, i64 %17, 3
  %19 = load i64, ptr %element, align 4
  %storage_value = load [4 x i64], ptr %storage_value_ptr, align 4
  %20 = insertvalue [4 x i64] %storage_value, i64 0, 0
  %21 = insertvalue [4 x i64] %storage_value, i64 0, 1
  %22 = insertvalue [4 x i64] %storage_value, i64 0, 2
  %23 = insertvalue [4 x i64] %storage_value, i64 %19, 3
  call void @set_storage([4 x i64] %15, [4 x i64] %storage_value)
  %new_length = add i64 %6, 1
  %storage_key2 = load [4 x i64], ptr %storage_key_ptr1, align 4
  %24 = insertvalue [4 x i64] %storage_key2, i64 0, 0
  %25 = insertvalue [4 x i64] %storage_key2, i64 0, 1
  %26 = insertvalue [4 x i64] %storage_key2, i64 0, 2
  %27 = insertvalue [4 x i64] %storage_key2, i64 1, 3
  %storage_value4 = load [4 x i64], ptr %storage_value_ptr3, align 4
  %28 = insertvalue [4 x i64] %storage_value4, i64 0, 0
  %29 = insertvalue [4 x i64] %storage_value4, i64 0, 1
  %30 = insertvalue [4 x i64] %storage_value4, i64 0, 2
  %31 = insertvalue [4 x i64] %storage_value4, i64 %new_length, 3
  call void @set_storage([4 x i64] %storage_key2, [4 x i64] %storage_value4)
  ret void
}

define void @removeElement() {
entry:
  %storage_value_ptr3 = alloca i64, i64 4, align 8
  %storage_value_ptr = alloca i64, i64 4, align 8
  %storage_key_ptr1 = alloca i64, i64 4, align 8
  %hash_src_ptr = alloca i64, i64 8, align 8
  %storage_key_ptr = alloca i64, i64 4, align 8
  %storage_key = load [4 x i64], ptr %storage_key_ptr, align 4
  %0 = insertvalue [4 x i64] %storage_key, i64 0, 0
  %1 = insertvalue [4 x i64] %storage_key, i64 0, 1
  %2 = insertvalue [4 x i64] %storage_key, i64 0, 2
  %3 = insertvalue [4 x i64] %storage_key, i64 0, 3
  %4 = call [4 x i64] @get_storage([4 x i64] %storage_key)
  %5 = extractvalue [4 x i64] %4, 3
  %hash_src = load [8 x i64], ptr %hash_src_ptr, align 4
  %6 = insertvalue [8 x i64] %hash_src, i64 1, 0
  %7 = insertvalue [8 x i64] %hash_src, i64 0, 1
  %8 = insertvalue [8 x i64] %hash_src, i64 0, 2
  %9 = insertvalue [8 x i64] %hash_src, i64 0, 3
  %10 = insertvalue [8 x i64] %hash_src, i64 0, 4
  %11 = insertvalue [8 x i64] %hash_src, i64 0, 5
  %12 = insertvalue [8 x i64] %hash_src, i64 0, 6
  %13 = insertvalue [8 x i64] %hash_src, i64 0, 7
  %14 = call [4 x i64] @poseidon_hash([8 x i64] %hash_src)
  %15 = extractvalue [4 x i64] %14, 3
  %16 = add i64 %15, %5
  %17 = insertvalue [4 x i64] %14, i64 %16, 3
  %new_length = sub i64 %5, 1
  %storage_key2 = load [4 x i64], ptr %storage_key_ptr1, align 4
  %18 = insertvalue [4 x i64] %storage_key2, i64 0, 0
  %19 = insertvalue [4 x i64] %storage_key2, i64 0, 1
  %20 = insertvalue [4 x i64] %storage_key2, i64 0, 2
  %21 = insertvalue [4 x i64] %storage_key2, i64 1, 3
  %storage_value = load [4 x i64], ptr %storage_value_ptr, align 4
  %22 = insertvalue [4 x i64] %storage_value, i64 0, 0
  %23 = insertvalue [4 x i64] %storage_value, i64 0, 1
  %24 = insertvalue [4 x i64] %storage_value, i64 0, 2
  %25 = insertvalue [4 x i64] %storage_value, i64 %new_length, 3
  call void @set_storage([4 x i64] %storage_key2, [4 x i64] %storage_value)
  %26 = call [4 x i64] @get_storage([4 x i64] %14)
  %27 = extractvalue [4 x i64] %26, 3
  %storage_value4 = load [4 x i64], ptr %storage_value_ptr3, align 4
  %28 = insertvalue [4 x i64] %storage_value4, i64 0, 0
  %29 = insertvalue [4 x i64] %storage_value4, i64 0, 1
  %30 = insertvalue [4 x i64] %storage_value4, i64 0, 2
  %31 = insertvalue [4 x i64] %storage_value4, i64 0, 3
  call void @set_storage([4 x i64] %14, [4 x i64] %storage_value4)
  ret void
}

define i64 @getLength() {
entry:
  %storage_key_ptr = alloca i64, i64 4, align 8
  %storage_key = load [4 x i64], ptr %storage_key_ptr, align 4
  %0 = insertvalue [4 x i64] %storage_key, i64 0, 0
  %1 = insertvalue [4 x i64] %storage_key, i64 0, 1
  %2 = insertvalue [4 x i64] %storage_key, i64 0, 2
  %3 = insertvalue [4 x i64] %storage_key, i64 0, 3
  %4 = call [4 x i64] @get_storage([4 x i64] %storage_key)
  %5 = extractvalue [4 x i64] %4, 3
  ret i64 %5
}
