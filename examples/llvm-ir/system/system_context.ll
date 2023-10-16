; ModuleID = 'SystemContextExample'
source_filename = "examples/source/system/system_context.ola"

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

define ptr @caller_address_test() {
entry:
  %0 = call i64 @vector_new(i64 12)
  %heap_start = sub i64 %0, 12
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 12)
  ret ptr %heap_to_ptr
}

define ptr @origin_address_test() {
entry:
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %1 = getelementptr i64, ptr %heap_to_ptr, i64 0
  %2 = ptrtoint ptr %1 to i64
  call void @get_context_data(i64 %2, i64 8)
  %3 = getelementptr i64, ptr %heap_to_ptr, i64 1
  %4 = ptrtoint ptr %3 to i64
  call void @get_context_data(i64 %4, i64 9)
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  %6 = ptrtoint ptr %5 to i64
  call void @get_context_data(i64 %6, i64 10)
  %7 = getelementptr i64, ptr %heap_to_ptr, i64 3
  %8 = ptrtoint ptr %7 to i64
  call void @get_context_data(i64 %8, i64 11)
  ret ptr %heap_to_ptr
}

define ptr @code_address_test() {
entry:
  %0 = call i64 @vector_new(i64 8)
  %heap_start = sub i64 %0, 8
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 8)
  ret ptr %heap_to_ptr
}

define ptr @current_address_test() {
entry:
  %0 = call i64 @vector_new(i64 8)
  %heap_start = sub i64 %0, 8
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 8)
  ret ptr %heap_to_ptr
}

define i64 @chain_id_test() {
entry:
  %0 = call i64 @vector_new(i64 1)
  %heap_start = sub i64 %0, 1
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_context_data(i64 %heap_start, i64 7)
  %1 = load i64, ptr %heap_to_ptr, align 4
  ret i64 %1
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3263022682, label %func_0_dispatch
    i64 1793245141, label %func_1_dispatch
    i64 1041928024, label %func_2_dispatch
    i64 2985880226, label %func_3_dispatch
    i64 1386073907, label %func_4_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = call ptr @caller_address_test()
  %4 = call i64 @vector_new(i64 5)
  %heap_start = sub i64 %4, 5
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %5 = getelementptr i64, ptr %3, i64 0
  %6 = load i64, ptr %5, align 4
  %start = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %6, ptr %start, align 4
  %7 = getelementptr i64, ptr %3, i64 1
  %8 = load i64, ptr %7, align 4
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 %8, ptr %start1, align 4
  %9 = getelementptr i64, ptr %3, i64 2
  %10 = load i64, ptr %9, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 %10, ptr %start2, align 4
  %11 = getelementptr i64, ptr %3, i64 3
  %12 = load i64, ptr %11, align 4
  %start3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 %12, ptr %start3, align 4
  %start4 = getelementptr i64, ptr %heap_to_ptr, i64 4
  store i64 4, ptr %start4, align 4
  call void @set_tape_data(i64 %heap_start, i64 5)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %13 = call ptr @origin_address_test()
  %14 = call i64 @vector_new(i64 5)
  %heap_start5 = sub i64 %14, 5
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %15 = getelementptr i64, ptr %13, i64 0
  %16 = load i64, ptr %15, align 4
  %start7 = getelementptr i64, ptr %heap_to_ptr6, i64 0
  store i64 %16, ptr %start7, align 4
  %17 = getelementptr i64, ptr %13, i64 1
  %18 = load i64, ptr %17, align 4
  %start8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 %18, ptr %start8, align 4
  %19 = getelementptr i64, ptr %13, i64 2
  %20 = load i64, ptr %19, align 4
  %start9 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 %20, ptr %start9, align 4
  %21 = getelementptr i64, ptr %13, i64 3
  %22 = load i64, ptr %21, align 4
  %start10 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 %22, ptr %start10, align 4
  %start11 = getelementptr i64, ptr %heap_to_ptr6, i64 4
  store i64 4, ptr %start11, align 4
  call void @set_tape_data(i64 %heap_start5, i64 5)
  ret void

func_2_dispatch:                                  ; preds = %entry
  %23 = call ptr @code_address_test()
  %24 = call i64 @vector_new(i64 5)
  %heap_start12 = sub i64 %24, 5
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  %25 = getelementptr i64, ptr %23, i64 0
  %26 = load i64, ptr %25, align 4
  %start14 = getelementptr i64, ptr %heap_to_ptr13, i64 0
  store i64 %26, ptr %start14, align 4
  %27 = getelementptr i64, ptr %23, i64 1
  %28 = load i64, ptr %27, align 4
  %start15 = getelementptr i64, ptr %heap_to_ptr13, i64 1
  store i64 %28, ptr %start15, align 4
  %29 = getelementptr i64, ptr %23, i64 2
  %30 = load i64, ptr %29, align 4
  %start16 = getelementptr i64, ptr %heap_to_ptr13, i64 2
  store i64 %30, ptr %start16, align 4
  %31 = getelementptr i64, ptr %23, i64 3
  %32 = load i64, ptr %31, align 4
  %start17 = getelementptr i64, ptr %heap_to_ptr13, i64 3
  store i64 %32, ptr %start17, align 4
  %start18 = getelementptr i64, ptr %heap_to_ptr13, i64 4
  store i64 4, ptr %start18, align 4
  call void @set_tape_data(i64 %heap_start12, i64 5)
  ret void

func_3_dispatch:                                  ; preds = %entry
  %33 = call ptr @current_address_test()
  %34 = call i64 @vector_new(i64 5)
  %heap_start19 = sub i64 %34, 5
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  %35 = getelementptr i64, ptr %33, i64 0
  %36 = load i64, ptr %35, align 4
  %start21 = getelementptr i64, ptr %heap_to_ptr20, i64 0
  store i64 %36, ptr %start21, align 4
  %37 = getelementptr i64, ptr %33, i64 1
  %38 = load i64, ptr %37, align 4
  %start22 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 %38, ptr %start22, align 4
  %39 = getelementptr i64, ptr %33, i64 2
  %40 = load i64, ptr %39, align 4
  %start23 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 %40, ptr %start23, align 4
  %41 = getelementptr i64, ptr %33, i64 3
  %42 = load i64, ptr %41, align 4
  %start24 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 %42, ptr %start24, align 4
  %start25 = getelementptr i64, ptr %heap_to_ptr20, i64 4
  store i64 4, ptr %start25, align 4
  call void @set_tape_data(i64 %heap_start19, i64 5)
  ret void

func_4_dispatch:                                  ; preds = %entry
  %43 = call i64 @chain_id_test()
  %44 = call i64 @vector_new(i64 2)
  %heap_start26 = sub i64 %44, 2
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  %start28 = getelementptr i64, ptr %heap_to_ptr27, i64 0
  store i64 %43, ptr %start28, align 4
  %start29 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  store i64 1, ptr %start29, align 4
  call void @set_tape_data(i64 %heap_start26, i64 2)
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
