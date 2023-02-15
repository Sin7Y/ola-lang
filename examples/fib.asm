main:
.LBL0_0:
  add r8 r8 4
  mstore [r8,-2] r8
  mov r1 10
  call fib_recursive
  not r7 4
  add r7 r7 1
  add r8 r8 r7
  end 
fib_recursive:
.LBL1_0:
  add r8 r8 9
  mstore [r8,-2] r8
  mov r0 r1
  mstore [r8,-7] r0
  mload r0 [r8,-7]
  eq r0 1
  cjmp .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 1
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
.LBL1_2:
  mload r0 [r8,-7]
  eq r0 2
  cjmp .LBL1_3
  jmp .LBL1_4
.LBL1_3:
  mov r0 1
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
.LBL1_4:
  not r7 1
  add r7 r7 1
  mload r0 [r8,-7]
  add r1 r0 r7
  call fib_recursive
  mstore [r8,-3] r0
  not r7 2
  add r7 r7 1
  mload r0 [r8,-7]
  add r0 r0 r7
  mstore [r8,-5] r0
  mload r1 [r8,-5]
  call fib_recursive
  mload r1 [r8,-3]
  add r0 r1 r0
  mstore [r8,-6] r0
  mload r0 [r8,-6]
  not r7 9
  add r7 r7 1
  add r8 r8 r7
  ret 
