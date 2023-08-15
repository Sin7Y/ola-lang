; ModuleID = 'AssertContract'
source_filename = "examples/source/assert/bool_assert.ola"

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

define void @main() {
entry:
  %e = alloca i64, align 8
  %d = alloca i64, align 8
  %c = alloca i64, align 8
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 1, ptr %a, align 4
  store i64 2, ptr %b, align 4
  store i64 1, ptr %c, align 4
  store i64 1, ptr %d, align 4
  store i64 0, ptr %e, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %c, align 4
  %2 = icmp eq i64 %0, %1
  %3 = zext i1 %2 to i64
  call void @builtin_assert(i64 %3)
  %4 = load i64, ptr %a, align 4
  %5 = load i64, ptr %c, align 4
  %6 = icmp ule i64 %4, %5
  %7 = zext i1 %6 to i64
  call void @builtin_assert(i64 %7)
  %8 = load i64, ptr %a, align 4
  %9 = load i64, ptr %b, align 4
  %10 = icmp ne i64 %8, %9
  %11 = zext i1 %10 to i64
  call void @builtin_assert(i64 %11)
  %12 = load i64, ptr %b, align 4
  %13 = load i64, ptr %a, align 4
  %14 = icmp uge i64 %12, %13
  %15 = zext i1 %14 to i64
  call void @builtin_assert(i64 %15)
  %16 = load i64, ptr %d, align 4
  call void @builtin_assert(i64 %16)
  %17 = load i64, ptr %e, align 4
  %18 = icmp eq i64 %17, 0
  %19 = zext i1 %18 to i64
  call void @builtin_assert(i64 %19)
  ret void
}
