define i64 @test_prophet_split(i64 %0) {
entry:
  ; CHECK: .PROPHET0_0 
  ; CHECK: mov r0 psp
  ; CHECK: mload r0 [r0]
  %tmp1 = call i64 @prophet_split_field_high(i64 %0)
  ; CHECK: mov r1 4294967297
  ; CHECK: .PROPHET0_1 
  ; CHECK: mov r0 psp
  ; CHECK: mload r0 [r0]
  %tmp2 = call i64 @prophet_split_field_low(i64 4294967297)
  %tmp3 = add i64 %tmp1, %tmp2
  ret i64 %tmp3
}