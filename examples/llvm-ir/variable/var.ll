; ModuleID = 'Fibonacci'
source_filename = "examples/source/variable/var.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64)

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

declare void @tape_store(i64, i64)

declare i64 @tape_load(i64, i64)

define i64 @var_test(i64 %0) {
entry:
  %second = alloca i64, align 8
  %first = alloca i64, align 8
  %third = alloca i64, align 8
  %n = alloca i64, align 8
  store i64 %0, ptr %n, align 4
  %1 = load i64, ptr %n, align 4
  %2 = add i64 1, %1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %third, align 4
  %3 = load i64, ptr %n, align 4
  %4 = add i64 2, %3
  call void @builtin_range_check(i64 %4)
  store i64 %4, ptr %first, align 4
  %5 = load i64, ptr %n, align 4
  %6 = add i64 3, %5
  call void @builtin_range_check(i64 %6)
  store i64 %6, ptr %second, align 4
  %7 = load i64, ptr %third, align 4
  %8 = load i64, ptr %first, align 4
  %9 = add i64 %7, %8
  call void @builtin_range_check(i64 %9)
  %10 = load i64, ptr %second, align 4
  %11 = add i64 %9, %10
  call void @builtin_range_check(i64 %11)
  ret i64 %11
}
