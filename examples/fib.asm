main:
.LBL0_0:
  add r8 r8 4
  mstore [r8,-2] r8
  mov r1 10
  call fib_non_recursive
  add r8 r8 -4
  end
fib_non_recursive:
.LBL1_0:
  add r8 r8 5
  mstore [r8,-1] r1
  mov r1 0
  mstore [r8,-2] r1
  mov r1 1
  mstore [r8,-3] r1
  mov r1 1
  mstore [r8,-4] r1
  mov r1 2
  mstore [r8,-5] r1
  jmp .LBL1_1
.LBL1_1:
  mload r1 [r8,-5]
  mload r2 [r8,-1]
  gte r1 r2
  cjmp r0 .LBL1_2
  jmp .LBL1_4
.LBL1_2:
  mload r2 [r8,-2]
  mload r3 [r8,-3]
  add r1 r2 r3
  mstore [r8,-4] r1
  mload r1 [r8,-3]
  mstore [r8,-2] r1
  mload r1 [r8,-4]
  mstore [r8,-3] r1
  jmp .LBL1_3
.LBL1_3:
  mload r2 [r8,-5]
  add r1 r2 1
  mstore [r8,-5] r1
  jmp .LBL1_1
.LBL1_4:
  mload r0 [r8,-4]
  add r8 r8 -5
  ret