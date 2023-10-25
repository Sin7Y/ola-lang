; ModuleID = 'BoolContract'
source_filename = "examples/source/types/bool.ola"

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
  switch i64 %0, label %missing_function [
    i64 1218183603, label %func_0_dispatch
    i64 2053569270, label %func_1_dispatch
    i64 527679565, label %func_2_dispatch
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
  %5 = call i64 @cond_bool(i64 %value)
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
  %9 = call i64 @return_bool(i64 %value6)
  %10 = call i64 @vector_new(i64 2)
  %heap_start9 = sub i64 %10, 2
  %heap_to_ptr10 = inttoptr i64 %heap_start9 to ptr
  %start11 = getelementptr i64, ptr %heap_to_ptr10, i64 0
  store i64 %9, ptr %start11, align 4
  %start12 = getelementptr i64, ptr %heap_to_ptr10, i64 1
  store i64 1, ptr %start12, align 4
  call void @set_tape_data(i64 %heap_start9, i64 2)
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
