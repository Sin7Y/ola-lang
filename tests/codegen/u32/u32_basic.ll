
; BEGIN-CHECK: testU32DeclareUninitialized:
define void @testU32DeclareUninitialized() {
entry:
  ; CHECK: mov r1 0
  ; CHECK: mstore [r9,-1] r1
  %a = alloca i64, align 8
  store i64 0, ptr %a, align 4
  %0 = load i64, ptr %a, align 4
  call void @prophet_printf(i64 %0, i64 3)
  ret void
}