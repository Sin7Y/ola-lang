; ModuleID = 'StructArrayExample'
source_filename = "examples/source/array/array_struct.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

define ptr @createBooks() {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %0 = call ptr @vector_new(i64 1, ptr null)
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  store i64 99, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 100, ptr %"struct member1", align 4
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr ptr, ptr %data, i64 0
  store ptr %struct_alloca, ptr %index_access, align 8
  ret ptr %0
}
