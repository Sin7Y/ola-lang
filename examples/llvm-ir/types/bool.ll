; ModuleID = 'BoolContract'
source_filename = "examples/source/types/bool.ola"

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

define i64 @cond_bool(i64 %0) {
entry:
  %ret = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  store i64 0, ptr %ret, align 4
  %1 = load i64, ptr %a, align 4
  %2 = trunc i64 %1 to i1
  br i1 %2, label %then, label %else

then:                                             ; preds = %entry
  ret i64 1

else:                                             ; preds = %entry
  ret i64 2

enif:                                             ; No predecessors!
}

define i64 @return_bool(i64 %0) {
entry:
  %a = alloca i64, align 8
  store i64 %0, ptr %a, align 4
  %1 = load i64, ptr %a, align 4
  ret i64 %1
}

define void @bool_compare() {
entry:
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 1, ptr %a, align 4
  store i64 0, ptr %b, align 4
  store i64 1, ptr %c, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp ne i64 %0, %1
  %3 = zext i1 %2 to i64
  call void @builtin_assert(i64 %3)
  %4 = load i64, ptr %a, align 4
  %5 = load i64, ptr %c, align 4
  %6 = icmp eq i64 %4, %5
  %7 = zext i1 %6 to i64
  call void @builtin_assert(i64 %7)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  %input_alloca = alloca ptr, align 8
  store ptr %2, ptr %input_alloca, align 8
  %input = load ptr, ptr %input_alloca, align 8
  switch i64 %0, label %missing_function [
    i64 1218183603, label %func_0_dispatch
    i64 2053569270, label %func_1_dispatch
    i64 527679565, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %input_start = ptrtoint ptr %input to i64
  %3 = inttoptr i64 %input_start to ptr
  %decode_value = load i64, ptr %3, align 4
  %4 = call i64 @cond_bool(i64 %decode_value)
  %5 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %5, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %encode_value_ptr = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %4, ptr %encode_value_ptr, align 4
  %encode_value_ptr1 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %encode_value_ptr1, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %input_start2 = ptrtoint ptr %input to i64
  %6 = inttoptr i64 %input_start2 to ptr
  %decode_value3 = load i64, ptr %6, align 4
  %7 = call i64 @return_bool(i64 %decode_value3)
  %8 = call i64 @vector_new(i64 2)
  %heap_start4 = sub i64 %8, 2
  %heap_to_ptr5 = inttoptr i64 %heap_start4 to ptr
  %encode_value_ptr6 = getelementptr i64, ptr %heap_to_ptr5, i64 0
  store i64 %7, ptr %encode_value_ptr6, align 4
  %encode_value_ptr7 = getelementptr i64, ptr %heap_to_ptr5, i64 1
  store i64 1, ptr %encode_value_ptr7, align 4
  call void @set_tape_data(i64 %heap_start4, i64 2)
  ret void

func_2_dispatch:                                  ; preds = %entry
  call void @bool_compare()
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
