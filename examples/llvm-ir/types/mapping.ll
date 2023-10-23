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

define void @memory_copy(ptr %0, i64 %1, ptr %2, i64 %3, i64 %4) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %4
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %5 = add i64 %1, %index_value
  %src_index_access = getelementptr i64, ptr %0, i64 %5
  %6 = load i64, ptr %src_index_access, align 4
  %7 = add i64 %3, %index_value
  %dest_index_access = getelementptr i64, ptr %2, i64 %7
  store i64 %6, ptr %dest_index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
}

define void @setNonce(ptr %0, i64 %1) {
entry:
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
  call void @memory_copy(ptr %heap_to_ptr, i64 0, ptr %heap_to_ptr2, i64 0, i64 4)
  call void @memory_copy(ptr %2, i64 0, ptr %heap_to_ptr2, i64 4, i64 4)
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr2, ptr %heap_to_ptr4, i64 8)
  %9 = load i64, ptr %_nonce, align 4
  %10 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %10, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %9, ptr %heap_to_ptr6, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %13, align 4
  %14 = call i64 @vector_new(i64 8)
  %heap_start7 = sub i64 %14, 8
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @memory_copy(ptr %heap_to_ptr4, i64 0, ptr %heap_to_ptr8, i64 0, i64 4)
  call void @memory_copy(ptr %heap_to_ptr6, i64 0, ptr %heap_to_ptr8, i64 4, i64 4)
  %15 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %15, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr10, i64 8)
  %16 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %16, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  call void @get_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr12)
  %storage_value = load i64, ptr %heap_to_ptr12, align 4
  %17 = icmp eq i64 %storage_value, 0
  %18 = zext i1 %17 to i64
  call void @builtin_assert(i64 %18)
  %19 = load ptr, ptr %_address, align 8
  %20 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %20, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 0, ptr %heap_to_ptr14, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %21, align 4
  %22 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %22, align 4
  %23 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %23, align 4
  %24 = call i64 @vector_new(i64 8)
  %heap_start15 = sub i64 %24, 8
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  call void @memory_copy(ptr %heap_to_ptr14, i64 0, ptr %heap_to_ptr16, i64 0, i64 4)
  call void @memory_copy(ptr %19, i64 0, ptr %heap_to_ptr16, i64 4, i64 4)
  %25 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %25, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr16, ptr %heap_to_ptr18, i64 8)
  %26 = load i64, ptr %_nonce, align 4
  %27 = call i64 @vector_new(i64 4)
  %heap_start19 = sub i64 %27, 4
  %heap_to_ptr20 = inttoptr i64 %heap_start19 to ptr
  store i64 %26, ptr %heap_to_ptr20, align 4
  %28 = getelementptr i64, ptr %heap_to_ptr20, i64 1
  store i64 0, ptr %28, align 4
  %29 = getelementptr i64, ptr %heap_to_ptr20, i64 2
  store i64 0, ptr %29, align 4
  %30 = getelementptr i64, ptr %heap_to_ptr20, i64 3
  store i64 0, ptr %30, align 4
  %31 = call i64 @vector_new(i64 8)
  %heap_start21 = sub i64 %31, 8
  %heap_to_ptr22 = inttoptr i64 %heap_start21 to ptr
  call void @memory_copy(ptr %heap_to_ptr18, i64 0, ptr %heap_to_ptr22, i64 0, i64 4)
  call void @memory_copy(ptr %heap_to_ptr20, i64 0, ptr %heap_to_ptr22, i64 4, i64 4)
  %32 = call i64 @vector_new(i64 4)
  %heap_start23 = sub i64 %32, 4
  %heap_to_ptr24 = inttoptr i64 %heap_start23 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr22, ptr %heap_to_ptr24, i64 8)
  %33 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %33, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  store i64 1, ptr %heap_to_ptr26, align 4
  %34 = getelementptr i64, ptr %heap_to_ptr26, i64 1
  store i64 0, ptr %34, align 4
  %35 = getelementptr i64, ptr %heap_to_ptr26, i64 2
  store i64 0, ptr %35, align 4
  %36 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  store i64 0, ptr %36, align 4
  call void @set_storage(ptr %heap_to_ptr24, ptr %heap_to_ptr26)
  %37 = load ptr, ptr %_address, align 8
  %38 = call i64 @vector_new(i64 4)
  %heap_start27 = sub i64 %38, 4
  %heap_to_ptr28 = inttoptr i64 %heap_start27 to ptr
  store i64 0, ptr %heap_to_ptr28, align 4
  %39 = getelementptr i64, ptr %heap_to_ptr28, i64 1
  store i64 0, ptr %39, align 4
  %40 = getelementptr i64, ptr %heap_to_ptr28, i64 2
  store i64 0, ptr %40, align 4
  %41 = getelementptr i64, ptr %heap_to_ptr28, i64 3
  store i64 0, ptr %41, align 4
  %42 = call i64 @vector_new(i64 8)
  %heap_start29 = sub i64 %42, 8
  %heap_to_ptr30 = inttoptr i64 %heap_start29 to ptr
  call void @memory_copy(ptr %heap_to_ptr28, i64 0, ptr %heap_to_ptr30, i64 0, i64 4)
  call void @memory_copy(ptr %37, i64 0, ptr %heap_to_ptr30, i64 4, i64 4)
  %43 = call i64 @vector_new(i64 4)
  %heap_start31 = sub i64 %43, 4
  %heap_to_ptr32 = inttoptr i64 %heap_start31 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr30, ptr %heap_to_ptr32, i64 8)
  %44 = load i64, ptr %_nonce, align 4
  %45 = call i64 @vector_new(i64 4)
  %heap_start33 = sub i64 %45, 4
  %heap_to_ptr34 = inttoptr i64 %heap_start33 to ptr
  store i64 %44, ptr %heap_to_ptr34, align 4
  %46 = getelementptr i64, ptr %heap_to_ptr34, i64 1
  store i64 0, ptr %46, align 4
  %47 = getelementptr i64, ptr %heap_to_ptr34, i64 2
  store i64 0, ptr %47, align 4
  %48 = getelementptr i64, ptr %heap_to_ptr34, i64 3
  store i64 0, ptr %48, align 4
  %49 = call i64 @vector_new(i64 8)
  %heap_start35 = sub i64 %49, 8
  %heap_to_ptr36 = inttoptr i64 %heap_start35 to ptr
  call void @memory_copy(ptr %heap_to_ptr32, i64 0, ptr %heap_to_ptr36, i64 0, i64 4)
  call void @memory_copy(ptr %heap_to_ptr34, i64 0, ptr %heap_to_ptr36, i64 4, i64 4)
  %50 = call i64 @vector_new(i64 4)
  %heap_start37 = sub i64 %50, 4
  %heap_to_ptr38 = inttoptr i64 %heap_start37 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr36, ptr %heap_to_ptr38, i64 8)
  %51 = call i64 @vector_new(i64 4)
  %heap_start39 = sub i64 %51, 4
  %heap_to_ptr40 = inttoptr i64 %heap_start39 to ptr
  call void @get_storage(ptr %heap_to_ptr38, ptr %heap_to_ptr40)
  %storage_value41 = load i64, ptr %heap_to_ptr40, align 4
  call void @builtin_assert(i64 %storage_value41)
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
