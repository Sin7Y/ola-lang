; ModuleID = 'AddressExample'
source_filename = "examples/source/types/address.ola"

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

declare void @prophet_printf(i64, i64)

define i64 @compare_address(ptr %0) {
entry:
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  %1 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %1, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %2 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %2, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %3 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %3, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %5, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %6 = load ptr, ptr %_address, align 8
  %left_elem_0 = getelementptr i64, ptr %heap_to_ptr, i64 0
  %7 = load i64, ptr %left_elem_0, align 4
  %right_elem_0 = getelementptr i64, ptr %6, i64 0
  %8 = load i64, ptr %right_elem_0, align 4
  %compare_0 = icmp eq i64 %7, %8
  %9 = zext i1 %compare_0 to i64
  %result_0 = and i64 %9, 1
  %left_elem_1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  %10 = load i64, ptr %left_elem_1, align 4
  %right_elem_1 = getelementptr i64, ptr %6, i64 1
  %11 = load i64, ptr %right_elem_1, align 4
  %compare_1 = icmp eq i64 %10, %11
  %12 = zext i1 %compare_1 to i64
  %result_1 = and i64 %12, %result_0
  %left_elem_2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  %13 = load i64, ptr %left_elem_2, align 4
  %right_elem_2 = getelementptr i64, ptr %6, i64 2
  %14 = load i64, ptr %right_elem_2, align 4
  %compare_2 = icmp eq i64 %13, %14
  %15 = zext i1 %compare_2 to i64
  %result_2 = and i64 %15, %result_1
  %left_elem_3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  %16 = load i64, ptr %left_elem_3, align 4
  %right_elem_3 = getelementptr i64, ptr %6, i64 3
  %17 = load i64, ptr %right_elem_3, align 4
  %compare_3 = icmp eq i64 %16, %17
  %18 = zext i1 %compare_3 to i64
  %result_3 = and i64 %18, %result_2
  ret i64 %result_3
}

define ptr @u32_to_address() {
entry:
  %b = alloca i64, align 8
  store i64 1, ptr %b, align 4
  %0 = load i64, ptr %b, align 4
  %1 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %1, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 0, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %0, ptr %index_access3, align 4
  ret ptr %heap_to_ptr
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1416181918, label %func_0_dispatch
    i64 193795498, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 4, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
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

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %6 = call i64 @compare_address(ptr %heap_to_ptr)
  %7 = call i64 @vector_new(i64 2)
  %heap_start10 = sub i64 %7, 2
  %heap_to_ptr11 = inttoptr i64 %heap_start10 to ptr
  %start12 = getelementptr i64, ptr %heap_to_ptr11, i64 0
  store i64 %6, ptr %start12, align 4
  %start13 = getelementptr i64, ptr %heap_to_ptr11, i64 1
  store i64 1, ptr %start13, align 4
  call void @set_tape_data(i64 %heap_start10, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %8 = call ptr @u32_to_address()
  %9 = call i64 @vector_new(i64 5)
  %heap_start14 = sub i64 %9, 5
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  %10 = getelementptr i64, ptr %8, i64 0
  %11 = load i64, ptr %10, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr15, i64 0
  store i64 %11, ptr %start16, align 4
  %12 = getelementptr i64, ptr %8, i64 1
  %13 = load i64, ptr %12, align 4
  %start17 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 %13, ptr %start17, align 4
  %14 = getelementptr i64, ptr %8, i64 2
  %15 = load i64, ptr %14, align 4
  %start18 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 %15, ptr %start18, align 4
  %16 = getelementptr i64, ptr %8, i64 3
  %17 = load i64, ptr %16, align 4
  %start19 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 %17, ptr %start19, align 4
  %start20 = getelementptr i64, ptr %heap_to_ptr15, i64 4
  store i64 4, ptr %start20, align 4
  call void @set_tape_data(i64 %heap_start14, i64 5)
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
