; ModuleID = 'MultInputExample'
source_filename = "examples/source/contract_input/mult_simple_input.ola"

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

define void @foo(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6) {
entry:
  %result = alloca i64, align 8
  %e_f = alloca i64, align 8
  %c_d = alloca i64, align 8
  %a_b = alloca i64, align 8
  %g = alloca i64, align 8
  %f = alloca i64, align 8
  %e = alloca i64, align 8
  %d = alloca i64, align 8
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 %1, ptr %b, align 4
  store i64 %2, ptr %c, align 4
  store i64 %3, ptr %d, align 4
  store i64 %4, ptr %e, align 4
  store i64 %5, ptr %f, align 4
  store i64 %6, ptr %g, align 4
  %7 = load i64, ptr %a, align 4
  %8 = load i64, ptr %b, align 4
  %9 = add i64 %7, %8
  call void @builtin_range_check(i64 %9)
  store i64 %9, ptr %a_b, align 4
  %10 = load i64, ptr %c, align 4
  %11 = load i64, ptr %d, align 4
  %12 = add i64 %10, %11
  call void @builtin_range_check(i64 %12)
  store i64 %12, ptr %c_d, align 4
  %13 = load i64, ptr %e, align 4
  %14 = load i64, ptr %f, align 4
  %15 = add i64 %13, %14
  call void @builtin_range_check(i64 %15)
  store i64 %15, ptr %e_f, align 4
  %16 = load i64, ptr %a_b, align 4
  %17 = load i64, ptr %c_d, align 4
  %18 = add i64 %16, %17
  call void @builtin_range_check(i64 %18)
  %19 = load i64, ptr %e_f, align 4
  %20 = add i64 %18, %19
  call void @builtin_range_check(i64 %20)
  %21 = load i64, ptr %g, align 4
  %22 = add i64 %20, %21
  call void @builtin_range_check(i64 %22)
  store i64 %22, ptr %result, align 4
  %23 = load i64, ptr %result, align 4
  %24 = icmp eq i64 %23, 28
  %25 = zext i1 %24 to i64
  call void @builtin_assert(i64 %25)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3403690512, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 7, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %start1 = getelementptr i64, ptr %2, i64 1
  %value2 = load i64, ptr %start1, align 4
  %start3 = getelementptr i64, ptr %2, i64 2
  %value4 = load i64, ptr %start3, align 4
  %start5 = getelementptr i64, ptr %2, i64 3
  %value6 = load i64, ptr %start5, align 4
  %start7 = getelementptr i64, ptr %2, i64 4
  %value8 = load i64, ptr %start7, align 4
  %start9 = getelementptr i64, ptr %2, i64 5
  %value10 = load i64, ptr %start9, align 4
  %start11 = getelementptr i64, ptr %2, i64 6
  %value12 = load i64, ptr %start11, align 4
  %4 = icmp ult i64 7, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @foo(i64 %value, i64 %value2, i64 %value4, i64 %value6, i64 %value8, i64 %value10, i64 %value12)
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
