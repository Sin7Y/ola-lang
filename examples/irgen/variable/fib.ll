; ModuleID = 'Fibonacci'
source_filename = "examples/source/variable/fib.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @prophet_malloc(i64)

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
  store i64 %8, ptr %third, align 4
  %9 = load i64, ptr %second, align 4
  store i64 %9, ptr %first, align 4
  %10 = load i64, ptr %third, align 4
  store i64 %10, ptr %second, align 4
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
