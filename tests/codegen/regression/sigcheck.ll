define i64 @test_builtin_check_ecdsa(ptr %0) {
entry:
  ; CHECK: sigcheck r0 r1 
  %tmp = call i64 @builtin_check_ecdsa(ptr %0)
  ret i64 %tmp
}