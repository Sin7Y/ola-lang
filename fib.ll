; ModuleID = 'Fibonacci'
source_filename = "examples/fib.ola"

define void @main() {
entry:
  %0 = call i32 @fib_recursive(i32 10)
  ret void
}

define i32 @fib_recursive(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp eq i32 %1, 1
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 1

enif:                                             ; preds = %entry
  %3 = load i32, i32* %n, align 4
  %4 = icmp eq i32 %3, 2
  br i1 %4, label %then1, label %enif2

then1:                                            ; preds = %enif
  ret i32 1

enif2:                                            ; preds = %enif
  %5 = load i32, i32* %n, align 4
  %6 = sub i32 %5, 1
  %7 = call i32 @fib_recursive(i32 %6)
  %8 = load i32, i32* %n, align 4
  %9 = sub i32 %8, 2
  %10 = call i32 @fib_recursive(i32 %9)
  %11 = add i32 %7, %10
  ret i32 %11
}

define i32 @fib_non_recursive(i32 %0) {
entry:
  %i = alloca i32, align 4
  %b = alloca i32, align 4
  %a = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp eq i32 %1, 0
  %3 = load i32, i32* %n, align 4
  %4 = icmp eq i32 %3, 1
  %5 = or i1 %2, %4
  br i1 %5, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 1

enif:                                             ; preds = %entry
  store i32 1, i32* %a, align 4
  store i32 1, i32* %b, align 4
  store i32 2, i32* %i, align 4
  br label %cond

body:                                             ; preds = %cond
  %6 = load i32, i32* %a, align 4
  %7 = load i32, i32* %b, align 4
  %8 = add i32 %6, %7
  store i32 %8, i32* %b, align 4
  %9 = load i32, i32* %b, align 4
  %10 = load i32, i32* %a, align 4
  %11 = sub i32 %9, %10
  store i32 %11, i32* %a, align 4
  br label %next

cond:                                             ; preds = %next, %enif
  %12 = load i32, i32* %i, align 4
  %13 = load i32, i32* %n, align 4
  %14 = sub i32 %13, 1
  %15 = icmp ult i32 %12, %14
  br i1 %15, label %body, label %endfor

next:                                             ; preds = %body
  %16 = load i32, i32* %i, align 4
  %17 = add i32 %16, 1
  store i32 %17, i32* %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %18 = load i32, i32* %a, align 4
  %19 = load i32, i32* %b, align 4
  %20 = add i32 %18, %19
  ret i32 %20
}
