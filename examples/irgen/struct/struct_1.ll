; ModuleID = 'StructExample'
source_filename = "examples/source/struct/struct_1.ola"

declare void @builtin_assert(i64, i64)

declare void @builtin_range_check(i64)

declare i64 @prophet_u32_sqrt(i64)

declare i64 @prophet_u32_div(i64, i64)

declare i64 @prophet_u32_mod(i64, i64)

declare ptr @prophet_u32_array_sort(ptr, i64)

declare ptr @prophet_malloc(i64)

define ptr @createBook() {
entry:
  %myBook = alloca ptr, align 8
  %struct_alloca = alloca { i64, i64 }, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 0
  store i64 1, ptr %"struct member", align 4
  %"struct member1" = getelementptr inbounds { i64, i64 }, ptr %struct_alloca, i32 0, i32 1
  store i64 3, ptr %"struct member1", align 4
  store ptr %struct_alloca, ptr %myBook, align 8
  %0 = load ptr, ptr %myBook, align 8
  ret ptr %0
}

define i64 @getBookName(ptr %0) {
entry:
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 1
  %2 = load i64, ptr %"struct member", align 4
  ret i64 %2
}

define i64 @getBookId(ptr %0) {
entry:
  %b = alloca i64, align 8
  %_book = alloca ptr, align 8
  store ptr %0, ptr %_book, align 8
  %1 = load ptr, ptr %_book, align 8
  %"struct member" = getelementptr inbounds { i64, i64 }, ptr %1, i32 0, i32 0
  %2 = load i64, ptr %"struct member", align 4
  %3 = add i64 %2, 1
  call void @builtin_range_check(i64 %3)
  store i64 %3, ptr %b, align 4
  %4 = load i64, ptr %b, align 4
  ret i64 %4
}

define void @main() {
entry:
  %bookId = alloca i64, align 8
  %bookTitle = alloca i64, align 8
  %myBook = alloca ptr, align 8
  %0 = alloca ptr, align 8
  %1 = call ptr @createBook()
  store ptr %1, ptr %0, align 8
  store ptr %0, ptr %myBook, align 8
  %2 = load ptr, ptr %myBook, align 8
  %3 = call i64 @getBookName(ptr %2)
  store i64 %3, ptr %bookTitle, align 4
  %4 = load ptr, ptr %myBook, align 8
  %5 = call i64 @getBookId(ptr %4)
  store i64 %5, ptr %bookId, align 4
  ret void
}
