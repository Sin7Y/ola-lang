define void @test_store_dst_gep_arg_inst(ptr %0, ptr %1) {
entry:
  %index_alloca = alloca i64, align 8
  store i64 100, ptr %index_alloca, align 4
  %index_value = load i64, ptr %index_alloca, align 4
  %src_index_access = getelementptr i64, ptr %0, i64 %index_value
  %3 = load i64, ptr %src_index_access, align 4
  %dest_index_access = getelementptr i64, ptr %1, i64 %index_value
  ; CHECK: mstore [r2,r3] r1  
  store i64 %3, ptr %dest_index_access, align 4 
  ret void
}

define void @test_store_dst_arg(ptr %0) {
entry:
  ; CHECK: mstore [r1] r2 
  store i64 200, ptr %0, align 4
  ret void
}