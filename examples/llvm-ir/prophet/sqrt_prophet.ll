; ModuleID = 'SqrtContract'
source_filename = "examples/source/prophet/sqrt_prophet.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

declare [4 x i64] @get_storage([4 x i64])

declare void @set_storage([4 x i64], [4 x i64])

declare [4 x i64] @poseidon_hash([8 x i64])

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
  store i64 %0, ptr %n, align 4
  %1 = load i64, ptr %n, align 4
  %2 = call i64 @u32_sqrt(i64 %1)
  store i64 %2, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  ret i64 %3
}
