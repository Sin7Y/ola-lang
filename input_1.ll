; ModuleID = 'InputExample'
source_filename = "examples/source/contract_input/input_1.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare void @get_context_data(i64, i64)

declare void @get_call_data(i64, i64)

declare void @set_tape_data(i64, i64)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define i64 @foo(i64 %0, i64 %1) {
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

define i64 @bar(i64 %0, i64 %1) {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  %2 = load i64, ptr %a, align 4
  %3 = load i64, ptr %b, align 4
  %4 = mul i64 %2, %3
  call void @builtin_range_check(i64 %4)
  ret i64 %4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 253268590, label %func_0_dispatch
    i64 1503968193, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 2, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %4 = icmp ult i64 2, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %5 = call i64 @foo(i64 %value, i64 %value2)
  %6 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %6, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %start3, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start4, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = icmp ule i64 2, %1
  br i1 %7, label %inbounds5, label %out_of_bounds6

inbounds5:                                        ; preds = %func_1_dispatch
  %start7 = getelementptr i64, ptr %2, i64 0
  %value8 = load i64, ptr %start7, align 4
  %start9 = getelementptr i64, ptr %2, i64 1
  %value10 = load i64, ptr %start9, align 4
  %8 = icmp ult i64 2, %1
  br i1 %8, label %not_all_bytes_read11, label %buffer_read12

out_of_bounds6:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read11:                             ; preds = %inbounds5
  unreachable

buffer_read12:                                    ; preds = %inbounds5
  %9 = call i64 @bar(i64 %value8, i64 %value10)
  %10 = call i64 @vector_new(i64 2)
  %heap_start13 = sub i64 %10, 2
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  %start15 = getelementptr i64, ptr %heap_to_ptr14, i64 0
  store i64 %9, ptr %start15, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 1, ptr %start16, align 4
  call void @set_tape_data(i64 %heap_start13, i64 2)
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_call_data(i64 %heap_start, i64 1)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 2)
  %heap_start1 = sub i64 %1, 2
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_call_data(i64 %heap_start1, i64 2)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 2
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_call_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
