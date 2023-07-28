; ModuleID = 'vote.ll'
source_filename = "examples/source/storage/vote.ola"

declare void @builtin_range_check(i64) local_unnamed_addr

declare i64 @vector_new(i64) local_unnamed_addr

define void @main() local_unnamed_addr {
entry:
  %0 = tail call i64 @vector_new(i64 2)
  %heap_ptr = add i64 %0, -2
  %int_to_ptr = inttoptr i64 %heap_ptr to ptr
  store ptr null, ptr %int_to_ptr, align 8
  %index_access.1 = getelementptr { i64, ptr }, ptr %int_to_ptr, i64 1
  store ptr null, ptr %index_access.1, align 8
  tail call void @builtin_range_check(i64 1)
  %1 = tail call i64 @vector_new(i64 1)
  %heap_ptr3 = add i64 %1, -1
  %int_to_ptr4 = inttoptr i64 %heap_ptr3 to ptr
  store i64 65, ptr %int_to_ptr4, align 4
  tail call void @builtin_range_check(i64 0)
  %2 = tail call i64 @vector_new(i64 1)
  %heap_ptr13 = add i64 %2, -1
  %int_to_ptr14 = inttoptr i64 %heap_ptr13 to ptr
  store i64 66, ptr %int_to_ptr14, align 4
  ret void
}
