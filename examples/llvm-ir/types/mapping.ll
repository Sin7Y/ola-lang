; ModuleID = 'NonceHolder'
source_filename = "examples/source/types/mapping.ola"

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

define void @setNonce(ptr %0, i64 %1) {
entry:
  %index_alloca30 = alloca i64, align 8
  %index_alloca21 = alloca i64, align 8
  %index_alloca6 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %_nonce = alloca i64, align 8
  %_address = alloca ptr, align 8
  store ptr %0, ptr %_address, align 8
  store i64 %1, ptr %_nonce, align 4
  %2 = load ptr, ptr %_address, align 8
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 0, ptr %heap_to_ptr, align 4
  %4 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 0, ptr %4, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr, i64 2
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr, i64 3
  store i64 0, ptr %6, align 4
  %7 = call i64 @vector_new(i64 8)
  %heap_start1 = sub i64 %7, 8
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %8 = add i64 0, %index_value
  %src_index_access = getelementptr i64, ptr %heap_to_ptr, i64 %8
  %9 = load i64, ptr %src_index_access, align 4
  %10 = add i64 0, %index_value
  %dest_index_access = getelementptr i64, ptr %heap_to_ptr2, i64 %10
  store i64 %9, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 0, ptr %index_alloca6, align 4
  br label %cond3

cond3:                                            ; preds = %body4, %done
  %index_value7 = load i64, ptr %index_alloca6, align 4
  %loop_cond8 = icmp ult i64 %index_value7, 4
  br i1 %loop_cond8, label %body4, label %done5

body4:                                            ; preds = %cond3
  %11 = add i64 0, %index_value7
  %src_index_access9 = getelementptr i64, ptr %2, i64 %11
  %12 = load i64, ptr %src_index_access9, align 4
  %13 = add i64 4, %index_value7
  %dest_index_access10 = getelementptr i64, ptr %heap_to_ptr2, i64 %13
  store i64 %12, ptr %dest_index_access10, align 4
  %next_index11 = add i64 %index_value7, 1
  store i64 %next_index11, ptr %index_alloca6, align 4
  br label %cond3

done5:                                            ; preds = %cond3
  %14 = call i64 @vector_new(i64 4)
  %heap_start12 = sub i64 %14, 4
  %heap_to_ptr13 = inttoptr i64 %heap_start12 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr13, i64 8)
  %15 = load i64, ptr %_nonce, align 4
  %16 = call i64 @vector_new(i64 4)
  %heap_start14 = sub i64 %16, 4
  %heap_to_ptr15 = inttoptr i64 %heap_start14 to ptr
  store i64 %15, ptr %heap_to_ptr15, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr15, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr15, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr15, i64 3
  store i64 0, ptr %19, align 4
  %20 = call i64 @vector_new(i64 8)
  %heap_start16 = sub i64 %20, 8
  %heap_to_ptr17 = inttoptr i64 %heap_start16 to ptr
  store i64 0, ptr %index_alloca21, align 4
  br label %cond18

cond18:                                           ; preds = %body19, %done5
  %index_value22 = load i64, ptr %index_alloca21, align 4
  %loop_cond23 = icmp ult i64 %index_value22, 4
  br i1 %loop_cond23, label %body19, label %done20

body19:                                           ; preds = %cond18
  %21 = add i64 0, %index_value22
  %src_index_access24 = getelementptr i64, ptr %heap_to_ptr13, i64 %21
  %22 = load i64, ptr %src_index_access24, align 4
  %23 = add i64 0, %index_value22
  %dest_index_access25 = getelementptr i64, ptr %heap_to_ptr17, i64 %23
  store i64 %22, ptr %dest_index_access25, align 4
  %next_index26 = add i64 %index_value22, 1
  store i64 %next_index26, ptr %index_alloca21, align 4
  br label %cond18

done20:                                           ; preds = %cond18
  store i64 0, ptr %index_alloca30, align 4
  br label %cond27

cond27:                                           ; preds = %body28, %done20
  %index_value31 = load i64, ptr %index_alloca30, align 4
  %loop_cond32 = icmp ult i64 %index_value31, 4
  br i1 %loop_cond32, label %body28, label %done29

body28:                                           ; preds = %cond27
  %24 = add i64 0, %index_value31
  %src_index_access33 = getelementptr i64, ptr %heap_to_ptr15, i64 %24
  %25 = load i64, ptr %src_index_access33, align 4
  %26 = add i64 4, %index_value31
  %dest_index_access34 = getelementptr i64, ptr %heap_to_ptr17, i64 %26
  store i64 %25, ptr %dest_index_access34, align 4
  %next_index35 = add i64 %index_value31, 1
  store i64 %next_index35, ptr %index_alloca30, align 4
  br label %cond27

done29:                                           ; preds = %cond27
  %27 = call i64 @vector_new(i64 4)
  %heap_start36 = sub i64 %27, 4
  %heap_to_ptr37 = inttoptr i64 %heap_start36 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr17, ptr %heap_to_ptr37, i64 8)
  %28 = call i64 @vector_new(i64 4)
  %heap_start38 = sub i64 %28, 4
  %heap_to_ptr39 = inttoptr i64 %heap_start38 to ptr
  store i64 100, ptr %heap_to_ptr39, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr39, i64 1
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr39, i64 2
  store i64 0, ptr %30, align 4
  %31 = getelementptr i64, ptr %heap_to_ptr39, i64 3
  store i64 0, ptr %31, align 4
  call void @set_storage(ptr %heap_to_ptr37, ptr %heap_to_ptr39)
  ret void
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3694669121, label %func_0_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 5, %1
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
  %start10 = getelementptr i64, ptr %2, i64 4
  %value11 = load i64, ptr %start10, align 4
  %5 = icmp ult i64 5, %1
  br i1 %5, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  call void @setNonce(ptr %heap_to_ptr, i64 %value11)
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
