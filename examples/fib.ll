; ModuleID = 'Fibonacci'
source_filename = "../../examples/fib.ola"

define void @main() {
entry:
  %0 = call i32 @fib_recursive(i32 10)
  ret void
}

define i32 @fib_recursive(i32 %0) {
entry:
  %1 = icmp eq i32 %0, 1
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 1

enif:                                             ; preds = %entry
  %2 = icmp eq i32 %0, 2
  br i1 %2, label %then1, label %enif2

then1:                                            ; preds = %enif
  ret i32 1

enif2:                                            ; preds = %enif
  %3 = sub i32 %0, 1
  %4 = call i32 @fib_recursive(i32 %3)
  %5 = sub i32 %0, 2
  %6 = call i32 @fib_recursive(i32 %5)
  %7 = add i32 %4, %6
  ret i32 %7
}
