; ModuleID = 'Fibonacci'
source_filename = "examples/source/variable/fib.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare i64 @vector_new(i64)

declare ptr @contract_input()

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

define void @main() {
entry:
  %0 = call i64 @fib_non_recursive(i64 10)
  ret void
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
    i64 3501063903, label %func_0_dispatch
    i64 229678162, label %func_1_dispatch
    i64 2146118040, label %func_2_dispatch
  ]

missing_function:                                 ; preds = %entry
  unreachable

func_0_dispatch:                                  ; preds = %entry
  call void @main()

func_1_dispatch:                                  ; preds = %entry
  %3 = icmp ule i64 1, %1
  br i1 %3, label %inbounds, label %out_of_bounds

inbounds:                                         ; preds = %func_1_dispatch
  %start = getelementptr i64, ptr %2, i64 0
  %value = load i64, ptr %start, align 4
  %4 = icmp ult i64 1, %1
  br i1 %4, label %not_all_bytes_read, label %buffer_read

out_of_bounds:                                    ; preds = %func_1_dispatch
  unreachable

not_all_bytes_read:                               ; preds = %inbounds
  unreachable

buffer_read:                                      ; preds = %inbounds
  %5 = call i64 @fib_recursive(i64 %value)

func_2_dispatch:                                  ; preds = %entry
  %6 = icmp ule i64 1, %1
  br i1 %6, label %inbounds1, label %out_of_bounds2

inbounds1:                                        ; preds = %func_2_dispatch
  %start3 = getelementptr i64, ptr %2, i64 0
  %value4 = load i64, ptr %start3, align 4
  %7 = icmp ult i64 1, %1
  br i1 %7, label %not_all_bytes_read5, label %buffer_read6

out_of_bounds2:                                   ; preds = %func_2_dispatch
  unreachable

not_all_bytes_read5:                              ; preds = %inbounds1
  unreachable

buffer_read6:                                     ; preds = %inbounds1
  %8 = call i64 @fib_non_recursive(i64 %value4)
}

define void @call() {
entry:
  %0 = call ptr @contract_input()
  %input_selector = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 0
  %selector = load i64, ptr %input_selector, align 4
  %input_len = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 1
  %len = load i64, ptr %input_len, align 4
  %input_data = getelementptr inbounds { i64, i64, ptr }, ptr %0, i32 0, i32 2
  %data = load ptr, ptr %input_data, align 8
  call void @function_dispatch(i64 %selector, i64 %len, ptr %data)
  unreachable
}
