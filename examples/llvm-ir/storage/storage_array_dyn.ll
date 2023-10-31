; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/storage/storage_array_dyn.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

declare void @builtin_range_check(i64)

define void @mempcy(ptr %0, ptr %1, i64 %2) {
entry:
  %index_alloca = alloca i64, align 8
  %len_alloca = alloca i64, align 8
  %dest_ptr_alloca = alloca ptr, align 8
  %src_ptr_alloca = alloca ptr, align 8
  store ptr %0, ptr %src_ptr_alloca, align 8
  %src_ptr = load ptr, ptr %src_ptr_alloca, align 8
  store ptr %1, ptr %dest_ptr_alloca, align 8
  %dest_ptr = load ptr, ptr %dest_ptr_alloca, align 8
  store i64 %2, ptr %len_alloca, align 4
  %len = load i64, ptr %len_alloca, align 4
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %len
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %src_index_access = getelementptr i64, ptr %src_ptr, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %dest_ptr, i64 %index_value
  store i64 %3, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret void
}

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

define void @addElement(i64 %0) {
entry:
  %element = alloca i64, align 8
  store i64 %0, ptr %element, align 4
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
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %6 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %6, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 0, ptr %heap_to_ptr4, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %9, align 4
  %10 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %10, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr4, ptr %heap_to_ptr6, i64 4)
  %11 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  %12 = load i64, ptr %11, align 4
  %13 = mul i64 %storage_value, 1
  %14 = add i64 %12, %13
  store i64 %14, ptr %11, align 4
  %15 = load i64, ptr %element, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %16, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 %15, ptr %heap_to_ptr8, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %19, align 4
  call void @set_storage(ptr %heap_to_ptr6, ptr %heap_to_ptr8)
  %new_length = add i64 %storage_value, 1
  %20 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %20, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 0, ptr %heap_to_ptr10, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %23, align 4
  %24 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %24, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %new_length, ptr %heap_to_ptr12, align 4
  %25 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %25, align 4
  %26 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %26, align 4
  %27 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %27, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr12)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 4130016160, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  call void @addElement(i64 %decode_value)
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
