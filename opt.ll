; ModuleID = 'array_struct.ll'
source_filename = "examples/source/array/array_struct.ola"

declare ptr @vector_new(i64, ptr) local_unnamed_addr

define ptr @createBooks() local_unnamed_addr {
entry:
  %0 = tail call ptr @vector_new(i64 1, ptr null)
  %data = getelementptr inbounds { i64, ptr }, ptr %0, i64 0, i32 1
  store i64 99, ptr %data, align 4
  %data.repack1 = getelementptr inbounds { i64, ptr }, ptr %0, i64 1
  store i64 100, ptr %data.repack1, align 4
  ret ptr %0
}
