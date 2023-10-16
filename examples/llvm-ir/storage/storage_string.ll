; ModuleID = 'StringExample'
source_filename = "examples/source/storage/storage_string.ola"

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

define void @set(ptr %0) {
entry:
  %1 = alloca ptr, align 8
  %index_alloca14 = alloca i64, align 8
  %2 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %length = load i64, ptr %0, align 4
  %3 = call i64 @vector_new(i64 4)
  %heap_start = sub i64 %3, 4
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %4 = call i64 @vector_new(i64 4)
  %heap_start1 = sub i64 %4, 4
  %heap_to_ptr2 = inttoptr i64 %heap_start1 to ptr
  store i64 0, ptr %heap_to_ptr2, align 4
  %5 = getelementptr i64, ptr %heap_to_ptr2, i64 1
  store i64 0, ptr %5, align 4
  %6 = getelementptr i64, ptr %heap_to_ptr2, i64 2
  store i64 0, ptr %6, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr2, i64 3
  store i64 0, ptr %7, align 4
  call void @get_storage(ptr %heap_to_ptr2, ptr %heap_to_ptr)
  %storage_value = load i64, ptr %heap_to_ptr, align 4
  %8 = call i64 @vector_new(i64 4)
  %heap_start3 = sub i64 %8, 4
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 0, ptr %heap_to_ptr4, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr4, i64 1
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr4, i64 2
  store i64 0, ptr %10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr4, i64 3
  store i64 0, ptr %11, align 4
  %12 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %12, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 %length, ptr %heap_to_ptr6, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %13, align 4
  %14 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %14, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %15, align 4
  call void @set_storage(ptr %heap_to_ptr4, ptr %heap_to_ptr6)
  %16 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %16, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 0, ptr %heap_to_ptr8, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %17, align 4
  %18 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %18, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %19, align 4
  %20 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %20, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr8, ptr %heap_to_ptr10, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr10, ptr %2, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %21 = load ptr, ptr %2, align 8
  %22 = ptrtoint ptr %0 to i64
  %23 = add i64 %22, 1
  %vector_data = inttoptr i64 %23 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  call void @set_storage(ptr %21, ptr %index_access)
  %24 = getelementptr i64, ptr %21, i64 3
  %slot_value = load i64, ptr %24, align 4
  %25 = add i64 %slot_value, 1
  store i64 %25, ptr %2, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca14, align 4
  store ptr %heap_to_ptr10, ptr %1, align 8
  br label %cond11

cond11:                                           ; preds = %body12, %done
  %index_value15 = load i64, ptr %index_alloca14, align 4
  %loop_cond16 = icmp ult i64 %index_value15, %storage_value
  br i1 %loop_cond16, label %body12, label %done13

body12:                                           ; preds = %cond11
  %26 = load ptr, ptr %1, align 8
  %27 = call i64 @vector_new(i64 4)
  %heap_start17 = sub i64 %27, 4
  %heap_to_ptr18 = inttoptr i64 %heap_start17 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr18, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr19 = getelementptr i64, ptr %heap_to_ptr18, i64 1
  store i64 0, ptr %storage_key_ptr19, align 4
  %storage_key_ptr20 = getelementptr i64, ptr %heap_to_ptr18, i64 2
  store i64 0, ptr %storage_key_ptr20, align 4
  %storage_key_ptr21 = getelementptr i64, ptr %heap_to_ptr18, i64 3
  store i64 0, ptr %storage_key_ptr21, align 4
  call void @set_storage(ptr %26, ptr %heap_to_ptr18)
  %28 = getelementptr i64, ptr %26, i64 3
  %slot_value22 = load i64, ptr %28, align 4
  %29 = add i64 %slot_value22, 1
  store i64 %29, ptr %1, align 4
  %next_index23 = add i64 %index_value15, 1
  store i64 %next_index23, ptr %index_alloca14, align 4
  br label %cond11

done13:                                           ; preds = %cond11
  ret void
}

define void @setStringLiteral() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca22 = alloca i64, align 8
  %1 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
  %2 = call i64 @vector_new(i64 6)
  %heap_start = sub i64 %2, 6
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 5, ptr %heap_to_ptr, align 4
  %3 = ptrtoint ptr %heap_to_ptr to i64
  %4 = add i64 %3, 1
  %vector_data = inttoptr i64 %4 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 0
  store i64 104, ptr %index_access, align 4
  %index_access1 = getelementptr i64, ptr %vector_data, i64 1
  store i64 101, ptr %index_access1, align 4
  %index_access2 = getelementptr i64, ptr %vector_data, i64 2
  store i64 108, ptr %index_access2, align 4
  %index_access3 = getelementptr i64, ptr %vector_data, i64 3
  store i64 108, ptr %index_access3, align 4
  %index_access4 = getelementptr i64, ptr %vector_data, i64 4
  store i64 111, ptr %index_access4, align 4
  %length = load i64, ptr %heap_to_ptr, align 4
  %5 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %5, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  %6 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %6, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  store i64 0, ptr %heap_to_ptr8, align 4
  %7 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 0, ptr %7, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr8, i64 2
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr8, i64 3
  store i64 0, ptr %9, align 4
  call void @get_storage(ptr %heap_to_ptr8, ptr %heap_to_ptr6)
  %storage_value = load i64, ptr %heap_to_ptr6, align 4
  %10 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %10, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  store i64 0, ptr %heap_to_ptr10, align 4
  %11 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 0, ptr %11, align 4
  %12 = getelementptr i64, ptr %heap_to_ptr10, i64 2
  store i64 0, ptr %12, align 4
  %13 = getelementptr i64, ptr %heap_to_ptr10, i64 3
  store i64 0, ptr %13, align 4
  %14 = call i64 @vector_new(i64 4)
  %heap_start11 = sub i64 %14, 4
  %heap_to_ptr12 = inttoptr i64 %heap_start11 to ptr
  store i64 %length, ptr %heap_to_ptr12, align 4
  %15 = getelementptr i64, ptr %heap_to_ptr12, i64 1
  store i64 0, ptr %15, align 4
  %16 = getelementptr i64, ptr %heap_to_ptr12, i64 2
  store i64 0, ptr %16, align 4
  %17 = getelementptr i64, ptr %heap_to_ptr12, i64 3
  store i64 0, ptr %17, align 4
  call void @set_storage(ptr %heap_to_ptr10, ptr %heap_to_ptr12)
  %18 = call i64 @vector_new(i64 4)
  %heap_start13 = sub i64 %18, 4
  %heap_to_ptr14 = inttoptr i64 %heap_start13 to ptr
  store i64 0, ptr %heap_to_ptr14, align 4
  %19 = getelementptr i64, ptr %heap_to_ptr14, i64 1
  store i64 0, ptr %19, align 4
  %20 = getelementptr i64, ptr %heap_to_ptr14, i64 2
  store i64 0, ptr %20, align 4
  %21 = getelementptr i64, ptr %heap_to_ptr14, i64 3
  store i64 0, ptr %21, align 4
  %22 = call i64 @vector_new(i64 4)
  %heap_start15 = sub i64 %22, 4
  %heap_to_ptr16 = inttoptr i64 %heap_start15 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr14, ptr %heap_to_ptr16, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr16, ptr %1, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %length
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %23 = load ptr, ptr %1, align 8
  %24 = ptrtoint ptr %heap_to_ptr to i64
  %25 = add i64 %24, 1
  %vector_data17 = inttoptr i64 %25 to ptr
  %index_access18 = getelementptr i64, ptr %vector_data17, i64 %index_value
  call void @set_storage(ptr %23, ptr %index_access18)
  %26 = getelementptr i64, ptr %23, i64 3
  %slot_value = load i64, ptr %26, align 4
  %27 = add i64 %slot_value, 1
  store i64 %27, ptr %1, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  store i64 %length, ptr %index_alloca22, align 4
  store ptr %heap_to_ptr16, ptr %0, align 8
  br label %cond19

cond19:                                           ; preds = %body20, %done
  %index_value23 = load i64, ptr %index_alloca22, align 4
  %loop_cond24 = icmp ult i64 %index_value23, %storage_value
  br i1 %loop_cond24, label %body20, label %done21

body20:                                           ; preds = %cond19
  %28 = load ptr, ptr %0, align 8
  %29 = call i64 @vector_new(i64 4)
  %heap_start25 = sub i64 %29, 4
  %heap_to_ptr26 = inttoptr i64 %heap_start25 to ptr
  %storage_key_ptr = getelementptr i64, ptr %heap_to_ptr26, i64 0
  store i64 0, ptr %storage_key_ptr, align 4
  %storage_key_ptr27 = getelementptr i64, ptr %heap_to_ptr26, i64 1
  store i64 0, ptr %storage_key_ptr27, align 4
  %storage_key_ptr28 = getelementptr i64, ptr %heap_to_ptr26, i64 2
  store i64 0, ptr %storage_key_ptr28, align 4
  %storage_key_ptr29 = getelementptr i64, ptr %heap_to_ptr26, i64 3
  store i64 0, ptr %storage_key_ptr29, align 4
  call void @set_storage(ptr %28, ptr %heap_to_ptr26)
  %30 = getelementptr i64, ptr %28, i64 3
  %slot_value30 = load i64, ptr %30, align 4
  %31 = add i64 %slot_value30, 1
  store i64 %31, ptr %0, align 4
  %next_index31 = add i64 %index_value23, 1
  store i64 %next_index31, ptr %index_alloca22, align 4
  br label %cond19

done21:                                           ; preds = %cond19
  ret void
}

define ptr @get() {
entry:
  %0 = alloca ptr, align 8
  %index_alloca = alloca i64, align 8
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
  %size = mul i64 %storage_value, 1
  %size_add_one = add i64 %size, 1
  %6 = call i64 @vector_new(i64 %size_add_one)
  %heap_start3 = sub i64 %6, %size_add_one
  %heap_to_ptr4 = inttoptr i64 %heap_start3 to ptr
  store i64 %size, ptr %heap_to_ptr4, align 4
  %7 = call i64 @vector_new(i64 4)
  %heap_start5 = sub i64 %7, 4
  %heap_to_ptr6 = inttoptr i64 %heap_start5 to ptr
  store i64 0, ptr %heap_to_ptr6, align 4
  %8 = getelementptr i64, ptr %heap_to_ptr6, i64 1
  store i64 0, ptr %8, align 4
  %9 = getelementptr i64, ptr %heap_to_ptr6, i64 2
  store i64 0, ptr %9, align 4
  %10 = getelementptr i64, ptr %heap_to_ptr6, i64 3
  store i64 0, ptr %10, align 4
  %11 = call i64 @vector_new(i64 4)
  %heap_start7 = sub i64 %11, 4
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  call void @poseidon_hash(ptr %heap_to_ptr6, ptr %heap_to_ptr8, i64 4)
  store i64 0, ptr %index_alloca, align 4
  store ptr %heap_to_ptr8, ptr %0, align 8
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, %storage_value
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %12 = load ptr, ptr %0, align 8
  %13 = ptrtoint ptr %heap_to_ptr4 to i64
  %14 = add i64 %13, 1
  %vector_data = inttoptr i64 %14 to ptr
  %index_access = getelementptr i64, ptr %vector_data, i64 %index_value
  %15 = call i64 @vector_new(i64 4)
  %heap_start9 = sub i64 %15, 4
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  call void @get_storage(ptr %12, ptr %heap_to_ptr10)
  %storage_value11 = load i64, ptr %heap_to_ptr10, align 4
  store i64 %storage_value11, ptr %index_access, align 4
  store ptr %12, ptr %0, align 8
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  ret ptr %heap_to_ptr4
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 1586025294, label %func_0_dispatch
    i64 515430227, label %func_1_dispatch
    i64 1021725805, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %3 = add i64 1, %value
  %4 = icmp ule i64 1, %1
  br i1 %4, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %5 = add i64 0, %3
  %6 = icmp ule i64 %5, %1
  br i1 %6, label %inbounds1, label %out_of_bounds2

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

inbounds1:                                        ; preds = %inbounds
  %size = mul i64 %value, 1
  %size_add_one = add i64 %size, 1
  %7 = call i64 @vector_new(i64 %size_add_one)
  %heap_start = sub i64 %7, %size_add_one
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  store i64 %size, ptr %heap_to_ptr, align 4
  %8 = ptrtoint ptr %heap_to_ptr to i64
  %9 = add i64 %8, 1
  %vector_data = inttoptr i64 %9 to ptr
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

out_of_bounds2:                                   ; preds = %inbounds
  unreachable

loop_body:                                        ; preds = %inbounds3, %inbounds1
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr i64, ptr %vector_data, i64 %index
  %10 = icmp ule i64 2, %1
  br i1 %10, label %inbounds3, label %out_of_bounds4

loop_end:                                         ; preds = %inbounds3
  %11 = add i64 0, %3
  %12 = icmp ult i64 %11, %1
  br i1 %12, label %not_all_bytes_read, label %buffer_read

inbounds3:                                        ; preds = %loop_body
  %start5 = getelementptr i64, ptr %2, i64 1
  %value6 = load i64, ptr %start5, align 4
  store i64 %value6, ptr %element, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %value
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds4:                                   ; preds = %loop_body
  unreachable

not_all_bytes_read:                               ; preds = %loop_end
  unreachable

buffer_read:                                      ; preds = %loop_end
  call void @set(ptr %heap_to_ptr)
  ret void

func_1_dispatch:                                  ; preds = %entry
  call void @setStringLiteral()
  ret void

func_2_dispatch:                                  ; preds = %entry
  %13 = call ptr @get()
  %length = load i64, ptr %13, align 4
  %14 = add i64 %length, 1
  %heap_size = add i64 %14, 1
  %15 = call i64 @vector_new(i64 %heap_size)
  %heap_start7 = sub i64 %15, %heap_size
  %heap_to_ptr8 = inttoptr i64 %heap_start7 to ptr
  %length9 = load i64, ptr %13, align 4
  %start10 = getelementptr i64, ptr %heap_to_ptr8, i64 0
  store i64 %length9, ptr %start10, align 4
  %16 = ptrtoint ptr %13 to i64
  %17 = add i64 %16, 1
  %vector_data11 = inttoptr i64 %17 to ptr
  %index_ptr14 = alloca i64, align 8
  store i64 0, ptr %index_ptr14, align 4
  br label %loop_body12

loop_body12:                                      ; preds = %loop_body12, %func_2_dispatch
  %index15 = load i64, ptr %index_ptr14, align 4
  %element16 = getelementptr ptr, ptr %vector_data11, i64 %index15
  %elem = load i64, ptr %element16, align 4
  %start17 = getelementptr i64, ptr %heap_to_ptr8, i64 1
  store i64 %elem, ptr %start17, align 4
  %next_index18 = add i64 %index15, 1
  store i64 %next_index18, ptr %index_ptr14, align 4
  %index_cond19 = icmp ult i64 %next_index18, %length9
  br i1 %index_cond19, label %loop_body12, label %loop_end13

loop_end13:                                       ; preds = %loop_body12
  %18 = add i64 %length9, 1
  %19 = add i64 0, %18
  %start20 = getelementptr i64, ptr %heap_to_ptr8, i64 %19
  store i64 %14, ptr %start20, align 4
  call void @set_tape_data(i64 %heap_start7, i64 %heap_size)
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
