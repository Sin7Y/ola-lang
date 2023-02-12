; ModuleID = 'Fibonacci'
source_filename = "../../examples/fib.ola"

define void @main() {
entry:
  %0 = call i32 @fib_recursive(i32 10)
}

define i32 @fib_recursive(i32 %0) {
entry:
  %1 = icmp ult i32 %0, 2
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 1

enif:                                             ; preds = %entry
  %2 = sub i32 %0, 1
  %3 = call i32 @fib_recursive(i32 %2)
  %4 = sub i32 %0, 2
  %5 = call i32 @fib_recursive(i32 %4)
  %6 = add i32 %3, %5
  ret i32 %6
}
