; ModuleID = 'SqrtContract'
source_filename = "examples/sqrt_prophet.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

define i64 @u32_sqrt(i64 %0) {
entry:
  %1 = call i64 @prophet_u32_sqrt(i64 %0)
  call void @builtin_range_check(i64 %1)
  %2 = mul i64 %1, %1
  call void @builtin_assert(i64 %2, i64 %0)
  ret i64 %1
}

define void @main() {
entry:
  %i = alloca i64, align 8
  store i64 0, i64* %i, align 8
  br label %cond

cond:                                             ; preds = %next, %entry
  %0 = load i64, i64* %i, align 8
  %1 = icmp ult i64 %0, 100
  br i1 %1, label %body, label %endfor

body:                                             ; preds = %cond
  %2 = call i64 @sqrt_test(i64 81)
  br label %next

next:                                             ; preds = %body
  %3 = load i64, i64* %i, align 8
  %4 = add i64 %3, 1
  store i64 %4, i64* %i, align 8
  br label %cond

endfor:                                           ; preds = %cond
  ret void
}

define i64 @sqrt_test(i64 %0) {
entry:
  %b = alloca i64, align 8
  %n = alloca i64, align 8
  store i64 %0, i64* %n, align 8
  %1 = load i64, i64* %n, align 8
  %2 = call i64 @u32_sqrt(i64 %1)
  store i64 %2, i64* %b, align 8
  %3 = load i64, i64* %b, align 8
  ret i64 %3
}