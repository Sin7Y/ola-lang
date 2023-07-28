; ModuleID = 'DynamicArrayExample'
source_filename = "examples/source/array/array_dynamic/array_5.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

define ptr @vector_new_init(i64 %0, ptr %1) {
entry:
  %vector_alloca = alloca { i64, ptr }, align 8
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 0
  store i64 %0, ptr %vector_len, align 4
  %vector_data = getelementptr inbounds { i64, ptr }, ptr %vector_alloca, i32 0, i32 1
  store ptr %1, ptr %vector_data, align 8
  ret ptr %vector_alloca
}

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define void @main() {
entry:
  %length2 = alloca i64, align 8
  %index_alloca = alloca i64, align 8
  %0 = call i64 @vector_new(i64 5)
  %heap_ptr = sub i64 %0, 5
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store i64 0, ptr %index_alloca, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %index_value = load i64, ptr %index_alloca, align 4
  %loop_cond = icmp ult i64 %index_value, 5
  br i1 %loop_cond, label %body, label %done

body:                                             ; preds = %cond
  %index_access = getelementptr i64, ptr %int_to_ptr, i64 %index_value
  store i64 0, ptr %index_access, align 4
  %next_index = add i64 %index_value, 1
  store i64 %next_index, ptr %index_alloca, align 4
  br label %cond

done:                                             ; preds = %cond
  %1 = call ptr @vector_new_init(i64 5, ptr %int_to_ptr)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %2 = sub i64 %length, 1
  %3 = sub i64 %2, 0
  call void @builtin_range_check(i64 %3)
  %data = getelementptr inbounds { i64, ptr }, ptr %1, i32 0, i32 1
  %index_access1 = getelementptr i64, ptr %data, i64 0
  store i64 1, ptr %index_access1, align 4
  %4 = call i64 @array_call(ptr %1)
  store i64 %4, ptr %length2, align 4
  ret void
}

define i64 @array_call(ptr %0) {
entry:
  %i = alloca i64, align 8
  %source = alloca ptr, align 8
  store ptr %0, ptr %source, align 8
  store i64 0, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i64, ptr %i, align 4
  %2 = icmp ult i64 %1, 5
  br i1 %2, label %body, label %endfor

body:                                             ; preds = %cond
  %3 = load i64, ptr %i, align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %4 = sub i64 %length, 1
  %5 = sub i64 %4, %3
  call void @builtin_range_check(i64 %5)
  %data = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 %3
  %6 = load i64, ptr %i, align 4
  store i64 %6, ptr %index_access, align 4
  br label %next

next:                                             ; preds = %body
  %7 = load i64, ptr %i, align 4
  %8 = add i64 %7, 1
  call void @builtin_range_check(i64 %8)
  br label %cond

endfor:                                           ; preds = %cond
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %source, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  ret i64 %length2
}

define void @function_dispatch(i64 %0, i64 %1, i64 %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 3501063903, label %func_0_dispatch
    i64 2934118673, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @main()
  ret void

func_1_dispatch:                                  ; preds = %entry
  %3 = call i64 @tape_load(i64 %2, i64 0)
  %4 = add i64 1, %3
  %5 = icmp ule i64 1, %1
  br i1 %5, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %size = mul i64 %3, 1
  %6 = call i64 @vector_new(i64 %size)
  %heap_ptr = sub i64 %6, %size
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  %7 = call ptr @vector_new_init(i64 %size, ptr %int_to_ptr)
  %data = getelementptr inbounds { i64, ptr }, ptr %7, i32 0, i32 1
  %array_elem_num = mul i64 %3, 1
  %index_ptr = alloca i64, align 8
  store i64 0, ptr %index_ptr, align 4
  br label %loop_body

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

loop_body:                                        ; preds = %inbounds1, %inbounds
  %index = load i64, ptr %index_ptr, align 4
  %element = getelementptr i64, ptr %data, i64 %index
  %8 = icmp ule i64 2, %1
  br i1 %8, label %inbounds1, label %out_of_bounds2

loop_end:                                         ; preds = %inbounds1
  %9 = add i64 0, %array_elem_num
  %10 = icmp ule i64 %9, %1
  br i1 %10, label %inbounds3, label %out_of_bounds4

inbounds1:                                        ; preds = %loop_body
  %11 = call i64 @tape_load(i64 %2, i64 1)
  store i64 %11, ptr %element, align 4
  %next_index = add i64 %index, 1
  store i64 %next_index, ptr %index_ptr, align 4
  %index_cond = icmp ult i64 %next_index, %3
  br i1 %index_cond, label %loop_body, label %loop_end

out_of_bounds2:                                   ; preds = %loop_body
  unreachable

inbounds3:                                        ; preds = %loop_end
  %12 = add i64 0, %4
  %13 = icmp ule i64 %12, %1
  br i1 %13, label %inbounds5, label %out_of_bounds6

out_of_bounds4:                                   ; preds = %loop_end
  unreachable

inbounds5:                                        ; preds = %inbounds3
  %14 = add i64 0, %4
  %15 = icmp ult i64 %14, %1
  br i1 %15, label %not_all_bytes_read, label %buffer_read

out_of_bounds6:                                   ; preds = %inbounds3
  unreachable

not_all_bytes_read:                               ; preds = %inbounds5
  unreachable

buffer_read:                                      ; preds = %inbounds5
  %16 = call i64 @array_call(ptr %7)
  call void @tape_store(i64 0, i64 %16)
  ret void
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, i64 }, ptr %0, i32 0, i32 2
  %data = load i64, ptr %input_data, align 4
  call void @function_dispatch(i64 %selector, i64 %len, i64 %data)
  unreachable
}
