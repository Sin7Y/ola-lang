; ModuleID = 'SqrtContract'
source_filename = "examples/sqrt.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

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
  %0 = call i64 @sqrt_test(i64 4)
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
