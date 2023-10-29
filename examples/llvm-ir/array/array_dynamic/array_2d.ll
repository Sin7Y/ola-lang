; ModuleID = 'DynamicArrayInMemory'
source_filename = "examples/source/array/array_dynamic/array_2d.ola"

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

define void @processDynamicArray() {
entry:
  %index_alloca9 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %0, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 1, ptr %heap_to_ptr, align 4
  %1 = ptrtoint ptr %heap_to_ptr to i64
  %2 = add i64 %1, 1
  %vector_data = inttoptr i64 %2 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 3
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr ptr, ptr %vector_data, i64 %index_value
  store ptr null, ptr %index_access, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %length = load i64, ptr %heap_to_ptr, align 4
  %3 = sub i64 %length, 1
  %4 = sub i64 %3, 0
  call void @builtin_range_check(i64 %4)
  %5 = ptrtoint ptr %heap_to_ptr to i64
  %6 = add i64 %5, 1
  %vector_data1 = inttoptr i64 %6 to ptr
  %index_access2 = getelementptr ptr, ptr %vector_data1, i64 0
  %7 = call i64 @vector_new(i64 2)
  %heap_start3 = sub i64 %7, 2
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 1, ptr %heap_to_ptr4, align 4
  %8 = ptrtoint ptr %heap_to_ptr4 to i64
  %9 = add i64 %8, 1
  %vector_data5 = inttoptr i64 %9 to ptr
  store i64 0, ptr %index_alloca9, align 4
  br label %cond6

cond6:                                            ; preds = %body7, %done
  %index_value10 = load i64, ptr %index_alloca9, align 4
  %loop_cond11 = icmp ult i64 %index_value10, 2
  br i1 %loop_cond11, label %body7, label %done8

body7:                                            ; preds = %cond6
  %index_access12 = getelementptr i64, ptr %vector_data5, i64 %index_value10
  store i64 0, ptr %index_access12, align 4
  %next_index13 = add i64 %index_value10, 1
  store i64 %next_index13, ptr %index_alloca9, align 4
  br label %cond6

done8:                                            ; preds = %cond6
  store ptr %heap_to_ptr4, ptr %index_access2, align 8
  %length14 = load i64, ptr %heap_to_ptr, align 4
  %10 = sub i64 %length14, 1
  %11 = sub i64 %10, 0
  call void @builtin_range_check(i64 %11)
  %12 = ptrtoint ptr %heap_to_ptr to i64
  %13 = add i64 %12, 1
  %vector_data15 = inttoptr i64 %13 to ptr
  %index_access16 = getelementptr ptr, ptr %vector_data15, i64 0
  %14 = load ptr, ptr %index_access16, align 8
  %length17 = load i64, ptr %14, align 4
  %15 = sub i64 %length17, 1
  %16 = sub i64 %15, 0
  call void @builtin_range_check(i64 %16)
  %17 = ptrtoint ptr %14 to i64
  %18 = add i64 %17, 1
  %vector_data18 = inttoptr i64 %18 to ptr
  %index_access19 = getelementptr i64, ptr %vector_data18, i64 0
  store i64 1, ptr %index_access19, align 4
  %length20 = load i64, ptr %14, align 4
  %19 = sub i64 %length20, 1
  %20 = sub i64 %19, 0
  call void @builtin_range_check(i64 %20)
  %21 = ptrtoint ptr %14 to i64
  %22 = add i64 %21, 1
  %vector_data21 = inttoptr i64 %22 to ptr
  %index_access22 = getelementptr i64, ptr %vector_data21, i64 0
  %23 = load i64, ptr %index_access22, align 4
  %24 = icmp eq i64 %23, 1
  %25 = zext i1 %24 to i64
  call void @builtin_assert(i64 %25)
  %length23 = load i64, ptr %heap_to_ptr, align 4
  %26 = sub i64 %length23, 1
  %27 = sub i64 %26, 0
  call void @builtin_range_check(i64 %27)
  %28 = ptrtoint ptr %heap_to_ptr to i64
  %29 = add i64 %28, 1
  %vector_data24 = inttoptr i64 %29 to ptr
  %index_access25 = getelementptr ptr, ptr %vector_data24, i64 0
  %30 = load ptr, ptr %index_access25, align 8
  %length26 = load i64, ptr %30, align 4
  %31 = sub i64 %length26, 1
  %32 = sub i64 %31, 0
  call void @builtin_range_check(i64 %32)
  %33 = ptrtoint ptr %30 to i64
  %34 = add i64 %33, 1
  %vector_data27 = inttoptr i64 %34 to ptr
  %index_access28 = getelementptr i64, ptr %vector_data27, i64 0
  %35 = load i64, ptr %index_access28, align 4
  %36 = icmp eq i64 %35, 1
  %37 = zext i1 %36 to i64
  call void @builtin_assert(i64 %37)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1008636309, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @processDynamicArray()
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
