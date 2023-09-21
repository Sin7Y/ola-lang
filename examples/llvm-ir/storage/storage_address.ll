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

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @contract_call(i64, i64)

define void @addressFunction() {
entry:
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] [i64 402443140940559753, i64 -5438528055523826848, i64 6500940582073311439, i64 -6711892513312253938])
  ret void
}

define void @setAddress([4 x i64] %0) {
entry:
  %_address = alloca [4 x i64], align 8
  store [4 x i64] %0, ptr %_address, align 4
  %1 = load [4 x i64], ptr %_address, align 4
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %1)
  ret void
}

define [4 x i64] @getAddress() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  ret [4 x i64] %0
}

define [4 x i64] @get_caller() {
entry:
  %caller_ = alloca [4 x i64], align 8
  store [4 x i64] zeroinitializer, ptr %caller_, align 4
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
  %8 = icmp ult i64 4, %1
  br i1 %8, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setAddress([4 x i64] %7)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %9 = call [4 x i64] @getAddress()
  %10 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %10, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start7 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 4, ptr %start7, align 4
  %11 = extractvalue [4 x i64] %9, 0
  %start8 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %11, ptr %start8, align 4
  %12 = extractvalue [4 x i64] %9, 1
  %start9 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %12, ptr %start9, align 4
  %13 = extractvalue [4 x i64] %9, 2
  %start10 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %13, ptr %start10, align 4
  %14 = extractvalue [4 x i64] %9, 3
  %start11 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 %14, ptr %start11, align 4
  call void @set_tape_data(i64 %heap_start, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %15 = call [4 x i64] @get_caller()
  %16 = call i64 @vector_new(i64 6)
  %heap_start12 = sub i64 %16, 6
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  %start14 = getelementptr i64, ptr %heap_to_ptr13, i64 0
  store i64 4, ptr %start14, align 4
  %17 = extractvalue [4 x i64] %15, 0
  %start15 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 %17, ptr %start15, align 4
  %18 = extractvalue [4 x i64] %15, 1
  %start16 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 %18, ptr %start16, align 4
  %19 = extractvalue [4 x i64] %15, 2
  %start17 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 %19, ptr %start17, align 4
  %20 = extractvalue [4 x i64] %15, 3
  %start18 = getelementptr i64, ptr %heap_to_ptr13, i64 4
  store i64 %20, ptr %start18, align 4
  call void @set_tape_data(i64 %heap_start12, i64 5)
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
