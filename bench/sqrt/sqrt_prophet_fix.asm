{
  "program": "u32_sqrt:\n.LBL5_0:\n  mov r3 r1\n  mov r1 r3\n.PROPHET5_0:\n  mov r0 psp\n  mload r0 [r0,0]\n  range r0\n  mul r2 r0 r0\n  assert r2 r3\n  ret\nmain:\n.LBL6_0:\n  add r8 r8 5\n  mstore [r8,-2] r8\n  mov r0 0\n  mstore [r8,-3] r0\n  jmp .LBL6_1\n.LBL6_1:\n  mload r0 [r8,-3]\n  mov r1 100\n  gte r1 r1 r0\n  neq r0 r0 100\n  and r1 r1 r0\n  cjmp r1 .LBL6_2\n  jmp .LBL6_4\n.LBL6_2:\n  mov r1 81\n  call sqrt_test\n  jmp .LBL6_3\n.LBL6_3:\n  mload r1 [r8,-3]\n  add r0 r1 1\n  mstore [r8,-3] r0\n  jmp .LBL6_1\n.LBL6_4:\n  add r8 r8 -5\n  end\nsqrt_test:\n.LBL7_0:\n  add r8 r8 6\n  mstore [r8,-2] r8\n  mov r0 r1\n  mstore [r8,-3] r0\n  mload r1 [r8,-3]\n  call u32_sqrt\n  mstore [r8,-4] r0\n  mload r0 [r8,-4]\n  add r8 r8 -6\n  ret\n",
  "prophets": [
    {
      "label": ".PROPHET5_0",
      "code": "%{\n    entry() {\n        cid.y = sqrt(cid.x);\n    }\n%}",
      "inputs": [
        "cid.x"
      ],
      "outputs": [
        "cid.y"
      ]
    }
  ]
}
