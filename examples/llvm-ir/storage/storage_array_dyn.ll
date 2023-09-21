; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/storage/storage_array_dyn.ola"

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

define void @addElement(i64 %0) {
entry:
  %element = alloca i64, align 8
  store i64 %0, ptr %element, align 4
  %1 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %2 = extractvalue [4 x i64] %1, 3
  %3 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %4 = extractvalue [4 x i64] %3, 3
  %5 = mul i64 %2, 1
  %6 = add i64 %4, %5
  %7 = insertvalue [4 x i64] %3, i64 %6, 3
  %8 = load i64, ptr %element, align 4
  %9 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %8, 3
  call void @set_storage([4 x i64] %7, [4 x i64] %9)
  %new_length = add i64 %2, 1
  %10 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %10)
  ret void
}

define void @removeElement() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %1 = extractvalue [4 x i64] %0, 3
  %2 = call [4 x i64] @poseidon_hash([8 x i64] zeroinitializer)
  %3 = extractvalue [4 x i64] %2, 3
  %4 = mul i64 %1, 1
  %5 = add i64 %3, %4
  %6 = insertvalue [4 x i64] %2, i64 %5, 3
  %7 = call [4 x i64] @get_storage([4 x i64] %6)
  %8 = extractvalue [4 x i64] %7, 3
  call void @set_storage([4 x i64] %6, [4 x i64] zeroinitializer)
  %new_length = sub i64 %1, 1
  %9 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %new_length, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %9)
  ret void
}

define i64 @getLength() {
entry:
  %0 = call [4 x i64] @get_storage([4 x i64] zeroinitializer)
  %1 = extractvalue [4 x i64] %0, 3
  ret i64 %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 4130016160, label %func_0_dispatch
    i64 1584379561, label %func_1_dispatch
    i64 1802902718, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 1, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = icmp ult i64 1, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @addElement(i64 %value)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @removeElement()
  ret void

func_2_dispatch:                                  ; preds = %entry
  %5 = call i64 @getLength()
  %6 = call i64 @vector_new(i64 3)
  %heap_start = sub i64 %6, 3
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 1, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %5, ptr %start2, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
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
