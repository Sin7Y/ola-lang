; ModuleID = 'Fibonacci'
source_filename = "examples/source/variable/fib.ola"

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

define i64 @fib_recursive(i64 %0) {
entry:
  %n = alloca i64, align 8
  store i64 %0, ptr %n, align 4
  %1 = load i64, ptr %n, align 4
  %2 = icmp eq i64 %1, 0
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i64 0

enif:                                             ; preds = %entry
  %3 = load i64, ptr %n, align 4
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then1, label %enif2

then1:                                            ; preds = %enif
  ret i64 1

enif2:                                            ; preds = %enif
  %5 = load i64, ptr %n, align 4
  %6 = sub i64 %5, 1
  call void @builtin_range_check(i64 %6)
  %7 = call i64 @fib_recursive(i64 %6)
  %8 = load i64, ptr %n, align 4
  %9 = sub i64 %8, 2
  call void @builtin_range_check(i64 %9)
  %10 = call i64 @fib_recursive(i64 %9)
  %11 = add i64 %7, %10
  call void @builtin_range_check(i64 %11)
  ret i64 %11
}

define i64 @fib_non_recursive(i64 %0) {
entry:
  %i = alloca i64, align 8
  %third = alloca i64, align 8
  %second = alloca i64, align 8
  %first = alloca i64, align 8
  %n = alloca i64, align 8
  store i64 %0, ptr %n, align 4
  %1 = load i64, ptr %n, align 4
  %2 = icmp eq i64 %1, 0
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i64 0

enif:                                             ; preds = %entry
  store i64 0, ptr %first, align 4
  store i64 1, ptr %second, align 4
  store i64 1, ptr %third, align 4
  store i64 2, ptr %i, align 4
  br label %cond

cond:                                             ; preds = %next, %enif
  %3 = load i64, ptr %i, align 4
  %4 = load i64, ptr %n, align 4
  %5 = icmp ule i64 %3, %4
  br i1 %5, label %body, label %endfor

body:                                             ; preds = %cond
  %6 = load i64, ptr %first, align 4
  %7 = load i64, ptr %second, align 4
  %8 = add i64 %6, %7
  call void @builtin_range_check(i64 %8)
  %9 = load i64, ptr %second, align 4
  %10 = load i64, ptr %third, align 4
  br label %next

next:                                             ; preds = %body
  %11 = load i64, ptr %i, align 4
  %12 = add i64 %11, 1
  store i64 %12, ptr %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %13 = load i64, ptr %third, align 4
  ret i64 %13
}

define void @function_dispatch(i64 %0, i64 %1, ptr %2) {
entry:
  switch i64 %0, label %missing_function [
    i64 229678162, label %func_0_dispatch
    i64 2146118040, label %func_1_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 1, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_0_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = icmp ult i64 1, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_0_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %5 = call i64 @fib_recursive(i64 %value)
  %6 = call i64 @vector_new(i64 2)
  %heap_start = sub i64 %6, 2
  %heap_to_ptr = inttoptr i64 %heap_start to ptr
  %start1 = getelementptr i64, ptr %heap_to_ptr, i64 0
  store i64 %5, ptr %start1, align 4
  %start2 = getelementptr i64, ptr %heap_to_ptr, i64 1
  store i64 1, ptr %start2, align 4
  call void @set_tape_data(i64 %heap_start, i64 2)
  ret void

func_1_dispatch:                                  ; preds = %entry
  %7 = icmp ule i64 1, %1
  br i1 %7, label %inbounds3, label %out_of_bounds4

inbounds3:                                        ; preds = %func_1_dispatch
  %start5 = getelementptr i64, ptr %2, i64 0
  %value6 = load i64, ptr %start5, align 4
  %8 = icmp ult i64 1, %1
  br i1 %8, label %not_all_bytes_read7, label %buffer_read8

out_of_bounds4:                                   ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read7:                              ; preds = %inbounds3
  unreachable

buffer_read8:                                     ; preds = %inbounds3
  %9 = call i64 @fib_non_recursive(i64 %value6)
  %10 = call i64 @vector_new(i64 2)
  %heap_start9 = sub i64 %10, 2
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  %start11 = getelementptr i64, ptr %heap_to_ptr10, i64 0
  store i64 %9, ptr %start11, align 4
  %start12 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 1, ptr %start12, align 4
  call void @set_tape_data(i64 %heap_start9, i64 2)
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
