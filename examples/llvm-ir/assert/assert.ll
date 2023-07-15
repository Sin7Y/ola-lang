; ModuleID = 'SqrtContract'
source_filename = "examples/source/assert/assert.ola"

@heap_address = internal global i64 -4294967353

declare void @builtin_assert(i64, i64)

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

define void @main() {
entry:
  %b = alloca i64, align 8
  %a = alloca i64, align 8
  store i64 2, ptr %a, align 4
  store i64 2, ptr %b, align 4
  %0 = load i64, ptr %a, align 4
  %1 = load i64, ptr %b, align 4
  %2 = icmp eq i64 %0, %1
  br i1 %2, label %noassert, label %doassert

noassert:                                         ; preds = %entry
  %3 = load i64, ptr %a, align 4
  %4 = load i64, ptr %b, align 4
  %5 = icmp ne i64 %3, %4
  br i1 %5, label %noassert1, label %doassert2

doassert:                                         ; preds = %entry
  unreachable

noassert1:                                        ; preds = %noassert
  ret void

doassert2:                                        ; preds = %noassert
  unreachable
}
