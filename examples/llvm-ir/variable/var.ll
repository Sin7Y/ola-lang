; ModuleID = 'Fibonacci'
source_filename = "examples/source/variable/var.ola"

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

define i64 @var_test(i64 %0) {
entry:
  %second = alloca i64, align 8
  %first = alloca i64, align 8
  %third = alloca i64, align 8
  %n = alloca i64, align 8
  store i64 %0, ptr %n, align 4
  %1 = load i64, ptr %n, align 4
  %2 = add i64 1, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %third, align 4
  %3 = load i64, ptr %n, align 4
  %4 = add i64 2, %3
  call void @builtin_range_check(i64 %4)
  store i64 %4, ptr %first, align 4
  %5 = load i64, ptr %n, align 4
  %6 = add i64 3, %5
  call void @builtin_range_check(i64 %6)
  store i64 %6, ptr %second, align 4
  %7 = load i64, ptr %third, align 4
  %8 = load i64, ptr %first, align 4
  %9 = add i64 %7, %8
  call void @builtin_range_check(i64 %9)
  %10 = load i64, ptr %second, align 4
  %11 = add i64 %9, %10
  call void @builtin_range_check(i64 %11)
  ret i64 %11
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1236882408, label %func_0_dispatch
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
  %5 = call i64 @var_test(i64 %value)
  %6 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %6, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start2, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void
}

define void @call() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 1)
  %function_selector = load i64, ptr %heap_to_ptr, align 4
  %1 = call i64 @vector_new(i64 2)
  %heap_start1 = sub i64 %1, 2
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  call void @get_tape_data(i64 %heap_start1, i64 2)
  %input_length = load i64, ptr %heap_to_ptr2, align 4
  %2 = add i64 %input_length, 2
  %3 = call i64 @vector_new(i64 %2)
  %heap_start3 = sub i64 %3, %2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @get_tape_data(i64 %heap_start3, i64 %2)
  call void @function_dispatch(i64 %function_selector, i64 %input_length, ptr %heap_to_ptr4)
  ret void
}
