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

declare void @prophet_printf(i64, i64)

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
  %1 = add i64 %heap_start, 0
  call void @get_context_data(i64 %1, i64 8)
  %2 = add i64 %heap_start, 1
  call void @get_context_data(i64 %2, i64 9)
  %3 = add i64 %heap_start, 2
  call void @get_context_data(i64 %3, i64 10)
  %4 = add i64 %heap_start, 3
  call void @get_context_data(i64 %4, i64 11)
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
  %0 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %0, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  call void @get_tape_data(i64 %heap_start, i64 4)
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

define void @all_test() {
entry:
  %chain = alloca i64, align 8
  %current = alloca ptr, align 8
  %code = alloca ptr, align 8
  %origin = alloca ptr, align 8
  %caller = alloca ptr, align 8
  %0 = call ptr @caller_address_test()
  store ptr %0, ptr %caller, align 8
  %1 = load ptr, ptr %caller, align 8
  %2 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %2, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %index_access = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 17, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 18, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 19, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 20, ptr %index_access3, align 4
  %left_elem_0 = getelementptr i64, ptr %1, i64 0
  %3 = load i64, ptr %left_elem_0, align 4
  %right_elem_0 = getelementptr i64, ptr %heap_to_ptr, i64 0
  %4 = load i64, ptr %right_elem_0, align 4
  %compare_0 = icmp eq i64 %3, %4
  %5 = zext i1 %compare_0 to i64
  %result_0 = and i64 %5, 1
  %left_elem_1 = getelementptr i64, ptr %1, i64 1
  %6 = load i64, ptr %left_elem_1, align 4
  %right_elem_1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  %7 = load i64, ptr %right_elem_1, align 4
  %compare_1 = icmp eq i64 %6, %7
  %8 = zext i1 %compare_1 to i64
  %result_1 = and i64 %8, %result_0
  %left_elem_2 = getelementptr i64, ptr %1, i64 2
  %9 = load i64, ptr %left_elem_2, align 4
  %right_elem_2 = getelementptr i64, ptr %heap_to_ptr, i64 2
  %10 = load i64, ptr %right_elem_2, align 4
  %compare_2 = icmp eq i64 %9, %10
  %11 = zext i1 %compare_2 to i64
  %result_2 = and i64 %11, %result_1
  %left_elem_3 = getelementptr i64, ptr %1, i64 3
  %12 = load i64, ptr %left_elem_3, align 4
  %right_elem_3 = getelementptr i64, ptr %heap_to_ptr, i64 3
  %13 = load i64, ptr %right_elem_3, align 4
  %compare_3 = icmp eq i64 %12, %13
  %14 = zext i1 %compare_3 to i64
  %result_3 = and i64 %14, %result_2
  call void @builtin_assert(i64 %result_3)
  %15 = call ptr @origin_address_test()
  store ptr %15, ptr %origin, align 8
  %16 = load ptr, ptr %origin, align 8
  %17 = call i64 @vector_new(i64 4)
  %heap_start4 = sub i64 %17, 4
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %index_access6 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  store i64 5, ptr %index_access6, align 4
  %index_access7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 6, ptr %index_access7, align 4
  %index_access8 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  store i64 7, ptr %index_access8, align 4
  %index_access9 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  store i64 8, ptr %index_access9, align 4
  %left_elem_010 = getelementptr i64, ptr %16, i64 0
  %18 = load i64, ptr %left_elem_010, align 4
  %right_elem_011 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  %19 = load i64, ptr %right_elem_011, align 4
  %compare_012 = icmp eq i64 %18, %19
  %20 = zext i1 %compare_012 to i64
  %result_013 = and i64 %20, 1
  %left_elem_114 = getelementptr i64, ptr %16, i64 1
  %21 = load i64, ptr %left_elem_114, align 4
  %right_elem_115 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  %22 = load i64, ptr %right_elem_115, align 4
  %compare_116 = icmp eq i64 %21, %22
  %23 = zext i1 %compare_116 to i64
  %result_117 = and i64 %23, %result_013
  %left_elem_218 = getelementptr i64, ptr %16, i64 2
  %24 = load i64, ptr %left_elem_218, align 4
  %right_elem_219 = getelementptr i64, ptr %heap_to_ptr5, i64 2
  %25 = load i64, ptr %right_elem_219, align 4
  %compare_220 = icmp eq i64 %24, %25
  %26 = zext i1 %compare_220 to i64
  %result_221 = and i64 %26, %result_117
  %left_elem_322 = getelementptr i64, ptr %16, i64 3
  %27 = load i64, ptr %left_elem_322, align 4
  %right_elem_323 = getelementptr i64, ptr %heap_to_ptr5, i64 3
  %28 = load i64, ptr %right_elem_323, align 4
  %compare_324 = icmp eq i64 %27, %28
  %29 = zext i1 %compare_324 to i64
  %result_325 = and i64 %29, %result_221
  call void @builtin_assert(i64 %result_325)
  %30 = call ptr @code_address_test()
  store ptr %30, ptr %code, align 8
  %31 = load ptr, ptr %code, align 8
  %32 = call i64 @vector_new(i64 4)
  %heap_start26 = sub i64 %32, 4
  %heap_to_ptr27 = inttoptr i64 %heap_start26 to ptr
  %index_access28 = getelementptr i64, ptr %heap_to_ptr27, i64 0
  store i64 9, ptr %index_access28, align 4
  %index_access29 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  store i64 10, ptr %index_access29, align 4
  %index_access30 = getelementptr i64, ptr %heap_to_ptr27, i64 2
  store i64 11, ptr %index_access30, align 4
  %index_access31 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  store i64 12, ptr %index_access31, align 4
  %left_elem_032 = getelementptr i64, ptr %31, i64 0
  %33 = load i64, ptr %left_elem_032, align 4
  %right_elem_033 = getelementptr i64, ptr %heap_to_ptr27, i64 0
  %34 = load i64, ptr %right_elem_033, align 4
  %compare_034 = icmp eq i64 %33, %34
  %35 = zext i1 %compare_034 to i64
  %result_035 = and i64 %35, 1
  %left_elem_136 = getelementptr i64, ptr %31, i64 1
  %36 = load i64, ptr %left_elem_136, align 4
  %right_elem_137 = getelementptr i64, ptr %heap_to_ptr27, i64 1
  %37 = load i64, ptr %right_elem_137, align 4
  %compare_138 = icmp eq i64 %36, %37
  %38 = zext i1 %compare_138 to i64
  %result_139 = and i64 %38, %result_035
  %left_elem_240 = getelementptr i64, ptr %31, i64 2
  %39 = load i64, ptr %left_elem_240, align 4
  %right_elem_241 = getelementptr i64, ptr %heap_to_ptr27, i64 2
  %40 = load i64, ptr %right_elem_241, align 4
  %compare_242 = icmp eq i64 %39, %40
  %41 = zext i1 %compare_242 to i64
  %result_243 = and i64 %41, %result_139
  %left_elem_344 = getelementptr i64, ptr %31, i64 3
  %42 = load i64, ptr %left_elem_344, align 4
  %right_elem_345 = getelementptr i64, ptr %heap_to_ptr27, i64 3
  %43 = load i64, ptr %right_elem_345, align 4
  %compare_346 = icmp eq i64 %42, %43
  %44 = zext i1 %compare_346 to i64
  %result_347 = and i64 %44, %result_243
  call void @builtin_assert(i64 %result_347)
  %45 = call ptr @current_address_test()
  store ptr %45, ptr %current, align 8
  %46 = load ptr, ptr %current, align 8
  %47 = call i64 @vector_new(i64 4)
  %heap_start48 = sub i64 %47, 4
  %heap_to_ptr49 = inttoptr i64 %heap_start48 to ptr
  %index_access50 = getelementptr i64, ptr %heap_to_ptr49, i64 0
  store i64 13, ptr %index_access50, align 4
  %index_access51 = getelementptr i64, ptr %heap_to_ptr49, i64 1
  store i64 14, ptr %index_access51, align 4
  %index_access52 = getelementptr i64, ptr %heap_to_ptr49, i64 2
  store i64 15, ptr %index_access52, align 4
  %index_access53 = getelementptr i64, ptr %heap_to_ptr49, i64 3
  store i64 16, ptr %index_access53, align 4
  %left_elem_054 = getelementptr i64, ptr %46, i64 0
  %48 = load i64, ptr %left_elem_054, align 4
  %right_elem_055 = getelementptr i64, ptr %heap_to_ptr49, i64 0
  %49 = load i64, ptr %right_elem_055, align 4
  %compare_056 = icmp eq i64 %48, %49
  %50 = zext i1 %compare_056 to i64
  %result_057 = and i64 %50, 1
  %left_elem_158 = getelementptr i64, ptr %46, i64 1
  %51 = load i64, ptr %left_elem_158, align 4
  %right_elem_159 = getelementptr i64, ptr %heap_to_ptr49, i64 1
  %52 = load i64, ptr %right_elem_159, align 4
  %compare_160 = icmp eq i64 %51, %52
  %53 = zext i1 %compare_160 to i64
  %result_161 = and i64 %53, %result_057
  %left_elem_262 = getelementptr i64, ptr %46, i64 2
  %54 = load i64, ptr %left_elem_262, align 4
  %right_elem_263 = getelementptr i64, ptr %heap_to_ptr49, i64 2
  %55 = load i64, ptr %right_elem_263, align 4
  %compare_264 = icmp eq i64 %54, %55
  %56 = zext i1 %compare_264 to i64
  %result_265 = and i64 %56, %result_161
  %left_elem_366 = getelementptr i64, ptr %46, i64 3
  %57 = load i64, ptr %left_elem_366, align 4
  %right_elem_367 = getelementptr i64, ptr %heap_to_ptr49, i64 3
  %58 = load i64, ptr %right_elem_367, align 4
  %compare_368 = icmp eq i64 %57, %58
  %59 = zext i1 %compare_368 to i64
  %result_369 = and i64 %59, %result_265
  call void @builtin_assert(i64 %result_369)
  %60 = call i64 @chain_id_test()
  store i64 %60, ptr %chain, align 4
  %61 = load i64, ptr %chain, align 4
  %62 = icmp eq i64 %61, 1
  %63 = zext i1 %62 to i64
  call void @builtin_assert(i64 %63)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3263022682, label %func_0_dispatch
    i64 1793245141, label %func_1_dispatch
    i64 1041928024, label %func_2_dispatch
    i64 2985880226, label %func_3_dispatch
    i64 1386073907, label %func_4_dispatch
    i64 3458276513, label %func_5_dispatch
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

func_5_dispatch:                                  ; preds = %entry
  call void @all_test()
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
