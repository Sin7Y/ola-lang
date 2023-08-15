; ModuleID = 'SimpleMappingExample'
source_filename = "examples/source/storage/storage_mapping.ola"

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

define void @add_mapping([4 x i64] %0, i64 %1) {
entry:
  %number = alloca i64, align 8
  %name = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %name, align 4
  store i64 %1, ptr %number, align 4
  %2 = load [4 x i64], ptr %name, align 4
  %3 = extractvalue [4 x i64] %2, 0
  %4 = extractvalue [4 x i64] %2, 1
  %5 = extractvalue [4 x i64] %2, 2
  %6 = extractvalue [4 x i64] %2, 3
  %7 = insertvalue [8 x i64] undef, i64 %6, 7
  %8 = insertvalue [8 x i64] %7, i64 %5, 6
  %9 = insertvalue [8 x i64] %8, i64 %4, 5
  %10 = insertvalue [8 x i64] %9, i64 %3, 4
  %11 = insertvalue [8 x i64] %10, i64 0, 3
  %12 = insertvalue [8 x i64] %11, i64 0, 2
  %13 = insertvalue [8 x i64] %12, i64 0, 1
  %14 = insertvalue [8 x i64] %13, i64 0, 0
  %15 = call [4 x i64] @poseidon_hash([8 x i64] %14)
  %16 = load i64, ptr %number, align 4
  %17 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %16, 3
  call void @set_storage([4 x i64] %15, [4 x i64] %17)
  ret void
}

define i64 @get_mapping([4 x i64] %0) {
entry:
  %name = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %name, align 4
  %1 = load [4 x i64], ptr %name, align 4
  %2 = extractvalue [4 x i64] %1, 0
  %3 = extractvalue [4 x i64] %1, 1
  %4 = extractvalue [4 x i64] %1, 2
  %5 = extractvalue [4 x i64] %1, 3
  %6 = insertvalue [8 x i64] undef, i64 %5, 7
  %7 = insertvalue [8 x i64] %6, i64 %4, 6
  %8 = insertvalue [8 x i64] %7, i64 %3, 5
  %9 = insertvalue [8 x i64] %8, i64 %2, 4
  %10 = insertvalue [8 x i64] %9, i64 0, 3
  %11 = insertvalue [8 x i64] %10, i64 0, 2
  %12 = insertvalue [8 x i64] %11, i64 0, 1
  %13 = insertvalue [8 x i64] %12, i64 0, 0
  %14 = call [4 x i64] @poseidon_hash([8 x i64] %13)
  %15 = call [4 x i64] @get_storage([4 x i64] %14)
  %16 = extractvalue [4 x i64] %15, 3
  ret i64 %16
}

define void @main() {
entry:
  %myaddress = alloca [4 x i64], align 8
  store [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938], ptr %myaddress, align 4
  %0 = load [4 x i64], ptr %myaddress, align 4
  call void @add_mapping([4 x i64] %0, i64 1)
  %1 = load [4 x i64], ptr %myaddress, align 4
  %2 = call i64 @get_mapping([4 x i64] %1)
  ret void
}
