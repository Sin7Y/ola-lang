; ModuleID = 'StructWithArrayExample'
source_filename = "examples/source/struct/struct_array.ola"

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

define ptr @createStudent() {
entry:
  %struct_alloca = alloca { i64, ptr }, align 8
  %0 = call ptr @vector_new(i64 3, ptr null)
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  store i64 85, ptr %index_access, align 4
  %vector_len1 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length2 = load i64, ptr %vector_len1, align 4
  %data3 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access4 = getelementptr i64, ptr %data3, i64 1
  store i64 90, ptr %index_access4, align 4
  %vector_len5 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 0
  %length6 = load i64, ptr %vector_len5, align 4
  %data7 = getelementptr inbounds { i64, ptr }, ptr %0, i32 0, i32 1
  %index_access8 = getelementptr i64, ptr %data7, i64 2
  store i64 95, ptr %index_access8, align 4
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 0
  store i64 20, ptr %"struct member", align 4
  %"struct member9" = getelementptr inbounds { i64, ptr }, ptr %struct_alloca, i32 0, i32 1
  store ptr %0, ptr %"struct member9", align 8
  ret ptr %struct_alloca
}

define i64 @getFirstGrade(ptr %0) {
entry:
  %_student = alloca ptr, align 8
  store ptr %0, ptr %_student, align 8
  %"struct member" = getelementptr inbounds { i64, ptr }, ptr %_student, i32 0, i32 1
  %"struct member1" = getelementptr inbounds { i64, ptr }, ptr %_student, i32 0, i32 1
  %vector_len = getelementptr inbounds { i64, ptr }, ptr %"struct member1", i32 0, i32 0
  %length = load i64, ptr %vector_len, align 4
  %data = getelementptr inbounds { i64, ptr }, ptr %"struct member", i32 0, i32 1
  %index_access = getelementptr i64, ptr %data, i64 0
  %1 = load i64, ptr %index_access, align 4
  ret i64 %1
}
