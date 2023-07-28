; ModuleID = 'SimpleMappingExample'
source_filename = "examples/source/storage/storage_mapping.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

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

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3327727046, label %func_0_dispatch
    i64 3588912103, label %func_1_dispatch
    i64 3501063903, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 5, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %4 = call i64 @tape_load(i64 %2, i64 0)
  %5 = insertvalue [4 x i64] undef, i64 %4, 0
  %6 = call i64 @tape_load(i64 %2, i64 1)
  %7 = insertvalue [4 x i64] undef, i64 %6, 1
  %8 = call i64 @tape_load(i64 %2, i64 2)
  %9 = insertvalue [4 x i64] undef, i64 %8, 2
  %10 = call i64 @tape_load(i64 %2, i64 3)
  %11 = insertvalue [4 x i64] undef, i64 %10, 3
  %12 = call i64 @tape_load(i64 %2, i64 4)
  %13 = icmp ult i64 5, %1
  br i1 %13, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @add_mapping([4 x i64] undef, i64 %12)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %14 = icmp ule i64 4, %1
  br i1 %14, label %inbounds1, label %out_of_bounds2

inbounds1:                                        ; preds = %func_1_dispatch
  %15 = call i64 @tape_load(i64 %2, i64 0)
  %16 = insertvalue [4 x i64] undef, i64 %15, 0
  %17 = call i64 @tape_load(i64 %2, i64 1)
  %18 = insertvalue [4 x i64] undef, i64 %17, 1
  %19 = call i64 @tape_load(i64 %2, i64 2)
  %20 = insertvalue [4 x i64] undef, i64 %19, 2
  %21 = call i64 @tape_load(i64 %2, i64 3)
  %22 = insertvalue [4 x i64] undef, i64 %21, 3
  %23 = icmp ult i64 4, %1
  br i1 %23, label %not_all_bytes_read3, label %buffer_read4

out_of_bounds2:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read3:                              ; preds = %inbounds1
  unreachable

buffer_read4:                                     ; preds = %inbounds1
  %24 = call i64 @get_mapping([4 x i64] undef)
  call void @tape_store(i64 0, i64 %24)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @main()
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
