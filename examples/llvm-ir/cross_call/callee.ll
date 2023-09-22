; ModuleID = 'Callee'
source_filename = "examples/source/cross_call/callee.ola"

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

define void @setVars(i64 %0) {
entry:
  %data = alloca i64, align 8
  store i64 %0, ptr %data, align 4
  %1 = load i64, ptr %data, align 4
  %2 = insertvalue [4 x i64] [i64 0, i64 0, i64 0, i64 undef], i64 %1, 3
  call void @set_storage([4 x i64] zeroinitializer, [4 x i64] %2)
  ret void
}

define i64 @add(i64 %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = add i64 %2, %3
  call void @builtin_range_check(i64 %4)
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 2371037854, label %func_0_dispatch
    i64 2062500454, label %func_1_dispatch
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
  call void @setVars(i64 %value)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %5 = icmp ule i64 2, %1
  br i1 %5, label %inbounds1, label %out_of_bounds2

inbounds1:                                        ; preds = %func_1_dispatch
  %start3 = getelementptr i64, ptr %2, i64 0
  %value4 = load i64, ptr %start3, align 4
  %start5 = getelementptr i64, ptr %2, i64 1
  %value6 = load i64, ptr %start5, align 4
  %6 = icmp ult i64 2, %1
  br i1 %6, label %not_all_bytes_read7, label %buffer_read8

out_of_bounds2:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read7:                              ; preds = %inbounds1
  unreachable

buffer_read8:                                     ; preds = %inbounds1
  %7 = call i64 @add(i64 %value4, i64 %value6)
  %8 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %8, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start9 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %7, ptr %start9, align 4
  %start10 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start10, align 4
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
  %2 = add i64 %input_length, 14
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
