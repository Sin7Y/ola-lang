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

declare void @get_context_data(i64, i64)

declare void @get_tape_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @contract_call(i64, i64)

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

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
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
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = insertvalue [4 x i64] undef, i64 %value, 0
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %5 = insertvalue [4 x i64] %4, i64 %value2, 1
  %start3 = getelementptr i64, ptr %2, i64 2
  %value4 = load i64, ptr %start3, align 4
  %6 = insertvalue [4 x i64] %5, i64 %value4, 2
  %start5 = getelementptr i64, ptr %2, i64 3
  %value6 = load i64, ptr %start5, align 4
  %7 = insertvalue [4 x i64] %6, i64 %value6, 3
  %start7 = getelementptr i64, ptr %2, i64 4
  %value8 = load i64, ptr %start7, align 4
  %8 = icmp ult i64 5, %1
  br i1 %8, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @add_mapping([4 x i64] %7, i64 %value8)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %9 = icmp ule i64 4, %1
  br i1 %9, label %inbounds9, label %out_of_bounds10

inbounds9:                                        ; preds = %func_1_dispatch
  %start11 = getelementptr i64, ptr %2, i64 0
  %value12 = load i64, ptr %start11, align 4
  %10 = insertvalue [4 x i64] undef, i64 %value12, 0
  %start13 = getelementptr i64, ptr %2, i64 1
  %value14 = load i64, ptr %start13, align 4
  %11 = insertvalue [4 x i64] %10, i64 %value14, 1
  %start15 = getelementptr i64, ptr %2, i64 2
  %value16 = load i64, ptr %start15, align 4
  %12 = insertvalue [4 x i64] %11, i64 %value16, 2
  %start17 = getelementptr i64, ptr %2, i64 3
  %value18 = load i64, ptr %start17, align 4
  %13 = insertvalue [4 x i64] %12, i64 %value18, 3
  %14 = icmp ult i64 4, %1
  br i1 %14, label %not_all_bytes_read19, label %buffer_read20

out_of_bounds10:                                  ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read19:                             ; preds = %inbounds9
  unreachable

buffer_read20:                                    ; preds = %inbounds9
  %15 = call i64 @get_mapping([4 x i64] %13)
  %16 = call i64 @vector_new(i64 3)
  %heap_start = sub i64 %16, 3
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start21 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 1, ptr %start21, align 4
  %start22 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %15, ptr %start22, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @main()
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 13)
  %heap_start = sub i64 %0, 13
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 13)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 14)
  %heap_start1 = sub i64 %1, 14
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 14)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 14, %input_length
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
