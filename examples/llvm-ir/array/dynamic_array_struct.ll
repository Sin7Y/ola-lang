; ModuleID = 'StructArrayExample'
source_filename = "examples/source/array/dynamic_array_struct.ola"

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

define ptr @createBooks() {
entry:
  %array_literal11 = alloca [5 x i64], align 8
  %struct_alloca7 = alloca { i64, i64, [5 x i64] }, align 8
  %array_literal3 = alloca [5 x i64], align 8
  %struct_alloca = alloca { i64, i64, [5 x i64] }, align 8
  %array_literal = alloca [2 x { i64, i64, [5 x i64] }], align 8
  %elemptr0 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 0
  %"struct member" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 0
  store i64 0, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 1
  store i64 111, ptr %"struct member1", align 4
  %"struct member2" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca, i32 0, i32 2
  %elemptr04 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 0
  store i64 1, ptr %elemptr04, align 4
  %elemptr1 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 1
  store i64 2, ptr %elemptr1, align 4
  %elemptr2 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 2
  store i64 3, ptr %elemptr2, align 4
  %elemptr3 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 3
  store i64 4, ptr %elemptr3, align 4
  %elemptr4 = getelementptr [5 x i64], ptr %array_literal3, i64 0, i64 4
  store i64 5, ptr %elemptr4, align 4
  %elem = load [5 x i64], ptr %array_literal3, align 4
  store [5 x i64] %elem, ptr %"struct member2", align 4
  %elem5 = load { i64, i64, [5 x i64] }, ptr %struct_alloca, align 4
  store { i64, i64, [5 x i64] } %elem5, ptr %elemptr0, align 4
  %elemptr16 = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %array_literal, i64 0, i64 1
  %"struct member8" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca7, i32 0, i32 0
  store i64 0, ptr %"struct member8", align 4
  %"struct member9" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca7, i32 0, i32 1
  store i64 0, ptr %"struct member9", align 4
  %"struct member10" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %struct_alloca7, i32 0, i32 2
  %elemptr012 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 0
  store i64 0, ptr %elemptr012, align 4
  %elemptr113 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 1
  store i64 0, ptr %elemptr113, align 4
  %elemptr214 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 2
  store i64 0, ptr %elemptr214, align 4
  %elemptr315 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 3
  store i64 0, ptr %elemptr315, align 4
  %elemptr416 = getelementptr [5 x i64], ptr %array_literal11, i64 0, i64 4
  store i64 0, ptr %elemptr416, align 4
  %elem17 = load [5 x i64], ptr %array_literal11, align 4
  store [5 x i64] %elem17, ptr %"struct member10", align 4
  %elem18 = load { i64, i64, [5 x i64] }, ptr %struct_alloca7, align 4
  store { i64, i64, [5 x i64] } %elem18, ptr %elemptr16, align 4
  ret ptr %array_literal
}

define i64 @getFirstBookID(ptr %0) {
entry:
  %_books = alloca ptr, align 8
  store ptr %0, ptr %_books, align 8
  call void @builtin_range_check(i64 1)
  %index_access = getelementptr [2 x { i64, i64, [5 x i64] }], ptr %_books, i64 0, i64 0
  %"struct member" = getelementptr inbounds { i64, i64, [5 x i64] }, ptr %index_access, i32 0, i32 2
  call void @builtin_range_check(i64 3)
  %index_access1 = getelementptr [5 x i64], ptr %"struct member", i64 0, i64 1
  %1 = load i64, ptr %index_access1, align 4
  ret i64 %1
}
