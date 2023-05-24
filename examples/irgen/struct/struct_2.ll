; ModuleID = 'MyContract'
source_filename = "examples/source/struct/struct_2.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @prophet_malloc(i64)

define ptr @myFunction() {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %0 = load ptr, ptr %struct_alloca, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %0, i32 0, i32 0
  store i64 42, ptr %"struct member", align 4
  %1 = load ptr, ptr %struct_alloca, align 8
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  store i64 3, ptr %"struct member1", align 4
  %2 = load ptr, ptr %struct_alloca, align 8
  ret ptr %2
}
