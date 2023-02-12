; ModuleID = 'Fibonacci'
source_filename = "../../examples/fib.ola"

define i32 @main(i32* %0) {
entry:
  %1 = alloca i32, align 4
  %2 = call i32 @fib_recursive(i32 10, i32* %1)
  %success = icmp eq i32 %2, 0
  br i1 %success, label %success1, label %bail

success1:                                         ; preds = %entry
  %3 = load i32, i32* %1, align 4
  store i32 %3, i32* %0, align 4
  ret i32 0

bail:                                             ; preds = %entry
  ret i32 %2
}

define i32 @fib_recursive(i32 %0, i32* %1) {
entry:
  %2 = icmp ult i32 %0, 2
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  store i32 1, i32* %1, align 4
  ret i32 0

enif:                                             ; preds = %entry
  %3 = sub i32 %0, 1
  %4 = alloca i32, align 4
  %5 = call i32 @fib_recursive(i32 %3, i32* %4)
  %success = icmp eq i32 %5, 0
  br i1 %success, label %success1, label %bail

success1:                                         ; preds = %enif
  %6 = load i32, i32* %4, align 4
  %7 = sub i32 %0, 2
  %8 = alloca i32, align 4
  %9 = call i32 @fib_recursive(i32 %7, i32* %8)
  %success2 = icmp eq i32 %9, 0
  br i1 %success2, label %success3, label %bail4

bail:                                             ; preds = %enif
  ret i32 %5

success3:                                         ; preds = %success1
  %10 = load i32, i32* %8, align 4
  %11 = add i32 %6, %10
  store i32 %11, i32* %1, align 4
  ret i32 0

bail4:                                            ; preds = %success1
  ret i32 %9
}
