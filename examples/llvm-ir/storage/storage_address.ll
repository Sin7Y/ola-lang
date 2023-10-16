; ModuleID = 'AddressExample'
source_filename = "examples/source/storage/storage_address.ola"

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

declare void @get_storage(ptr, ptr)

declare void @set_storage(ptr, ptr)

declare void @poseidon_hash(ptr, ptr, i64)

declare void @contract_call(ptr, i64)

define void @addressFunction() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 402443140940559753, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 -5438528055523826848, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 6500940582073311439, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 -6711892513312253938, ptr %index_access3, align 4
  %1 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %1, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  store i64 0, ptr %heap_to_ptr5, align 4
  %2 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 0, ptr %4, align 4
  call void @set_storage(ptr %heap_to_ptr5, ptr %heap_to_ptr)
  ret void
}

define void @setAddress(ptr %0) {
entry:
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = load ptr, ptr %_address, align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %5, align 4
  call void @set_storage(ptr %heap_to_ptr, ptr %1)
  ret void
}

define ptr @getAddress() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %1 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %1, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %2 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %4, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  ret ptr %heap_to_ptr
}

define ptr @get_caller() {
entry:
  %caller_ = alloca ptr, align 8
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %index_access3, align 4
  store ptr %heap_to_ptr, ptr %caller_, align 8
  %1 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %1, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %index_access6 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  store i64 402443140940559753, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 -5438528055523826848, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 6500940582073311439, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 -6711892513312253938, ptr %index_access9, align 4
  %2 = load ptr, ptr %heap_to_ptr5, align 8
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1977423088, label %func_0_dispatch
    i64 2692808931, label %func_1_dispatch
    i64 826854456, label %func_2_dispatch
    i64 2868727644, label %func_3_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @addressFunction()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 4, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %4 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %4, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %element = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %value, ptr %element, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %element3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %value2, ptr %element3, align 4
  %start4 = getelementptr i64, ptr %2, i64 2
  %value5 = load i64, ptr %start4, align 4
  %element6 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %value5, ptr %element6, align 4
  %start7 = getelementptr i64, ptr %2, i64 3
  %value8 = load i64, ptr %start7, align 4
  %element9 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %value8, ptr %element9, align 4
  %5 = icmp ult i64 4, %1
  br i1 %5, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setAddress(ptr %heap_to_ptr)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %6 = call ptr @getAddress()
  %7 = call i64 @vector_new(i64 5)
  %heap_start10 = sub i64 %7, 5
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  %8 = getelementptr i64, ptr %6, i64 0
  %9 = load i64, ptr %8, align 4
  %start12 = getelementptr i64, ptr %heap_to_ptr11, i64 0
  store i64 %9, ptr %start12, align 4
  %10 = getelementptr i64, ptr %6, i64 1
  %11 = load i64, ptr %10, align 4
  %start13 = getelementptr i64, ptr %heap_to_ptr11, i64 1
  store i64 %11, ptr %start13, align 4
  %12 = getelementptr i64, ptr %6, i64 2
  %13 = load i64, ptr %12, align 4
  %start14 = getelementptr i64, ptr %heap_to_ptr11, i64 2
  store i64 %13, ptr %start14, align 4
  %14 = getelementptr i64, ptr %6, i64 3
  %15 = load i64, ptr %14, align 4
  %start15 = getelementptr i64, ptr %heap_to_ptr11, i64 3
  store i64 %15, ptr %start15, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr11, i64 4
  store i64 4, ptr %start16, align 4
  call void @set_tape_data(i64 %heap_start10, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %16 = call ptr @get_caller()
  %17 = call i64 @vector_new(i64 5)
  %heap_start17 = sub i64 %17, 5
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %18 = getelementptr i64, ptr %16, i64 0
  %19 = load i64, ptr %18, align 4
  %start19 = getelementptr i64, ptr %heap_to_ptr18, i64 0
  store i64 %19, ptr %start19, align 4
  %20 = getelementptr i64, ptr %16, i64 1
  %21 = load i64, ptr %20, align 4
  %start20 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 %21, ptr %start20, align 4
  %22 = getelementptr i64, ptr %16, i64 2
  %23 = load i64, ptr %22, align 4
  %start21 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 %23, ptr %start21, align 4
  %24 = getelementptr i64, ptr %16, i64 3
  %25 = load i64, ptr %24, align 4
  %start22 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 %25, ptr %start22, align 4
  %start23 = getelementptr i64, ptr %heap_to_ptr18, i64 4
  store i64 4, ptr %start23, align 4
  call void @set_tape_data(i64 %heap_start17, i64 5)
  ret void
}

define void @main() {
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
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
