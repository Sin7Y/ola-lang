; ModuleID = 'StructExample'
source_filename = "examples/source/struct/struct_1.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @vector_new(i64, ptr)

define ptr @createBook() {
entry:
  %struct_alloca = alloca { i64, i64 }, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  store i64 1, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 3, ptr %"struct member1", align 4
  ret ptr %struct_alloca
}

define i64 @getBookName(ptr %0) {
entry:
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %_book, i32 0, i32 1
  %1 = load i64, ptr %"struct member", align 4
  ret i64 %1
}

define i64 @getBookId(ptr %0) {
entry:
  %b = alloca i64, align 8
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %_book, i32 0, i32 0
  %1 = load i64, ptr %"struct member", align 4
  %2 = add i64 %1, 1
  call void @builtin_range_check(i64 %2)
  store i64 %2, ptr %b, align 4
  %3 = load i64, ptr %b, align 4
  ret i64 %3
}

define void @main() {
entry:
  %bookId = alloca i64, align 8
  %bookTitle = alloca i64, align 8
  %0 = call ptr @createBook()
  %1 = call i64 @getBookName(ptr %0)
  store i64 %1, ptr %bookTitle, align 4
  %2 = call i64 @getBookId(ptr %0)
  store i64 %2, ptr %bookId, align 4
  ret void
}
