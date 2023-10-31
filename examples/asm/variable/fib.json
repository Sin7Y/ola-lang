{
  "program": "mempcy:\n.LBL2_0:\n  add r9 r9 4\n  mstore [r9,-4] r1\n  mload r1 [r9,-4]\n  mstore [r9,-3] r2\n  mload r2 [r9,-3]\n  mstore [r9,-2] r3\n  mload r3 [r9,-2]\n  mov r4 0\n  mstore [r9,-1] r4\n  jmp .LBL2_1\n.LBL2_1:\n  mload r4 [r9,-1]\n  gte r5 r3 r4\n  neq r6 r4 r3\n  and r5 r5 r6\n  cjmp r5 .LBL2_2\n  jmp .LBL2_3\n.LBL2_2:\n  mload r6 [r1,r4]\n  mstore [r2,r4] r6\n  add r5 r4 1\n  mstore [r9,-1] r5\n  jmp .LBL2_1\n.LBL2_3:\n  add r9 r9 -4\n  ret\nfib_recursive:\n.LBL16_0:\n  add r9 r9 7\n  mstore [r9,-2] r9\n  mstore [r9,-3] r1\n  mload r1 [r9,-3]\n  eq r1 r1 0\n  cjmp r1 .LBL16_1\n  jmp .LBL16_2\n.LBL16_1:\n  mov r0 0\n  add r9 r9 -7\n  ret\n.LBL16_2:\n  mload r1 [r9,-3]\n  eq r1 r1 1\n  cjmp r1 .LBL16_3\n  jmp .LBL16_4\n.LBL16_3:\n  mov r0 1\n  add r9 r9 -7\n  ret\n.LBL16_4:\n  mload r2 [r9,-3]\n  not r7 1\n  add r7 r7 1\n  add r1 r2 r7\n  range r1\n  call fib_recursive\n  mov r1 r0\n  mstore [r9,-7] r1\n  mload r1 [r9,-3]\n  not r7 2\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-5] r1\n  mload r1 [r9,-5]\n  range r1\n  mload r1 [r9,-5]\n  call fib_recursive\n  mov r1 r0\n  mload r2 [r9,-7]\n  add r1 r2 r1\n  mstore [r9,-4] r1\n  mload r1 [r9,-4]\n  range r1\n  mload r0 [r9,-4]\n  add r9 r9 -7\n  ret\nfib_non_recursive:\n.LBL17_0:\n  add r9 r9 5\n  mstore [r9,-5] r1\n  mload r1 [r9,-5]\n  eq r1 r1 0\n  cjmp r1 .LBL17_1\n  jmp .LBL17_2\n.LBL17_1:\n  mov r0 0\n  add r9 r9 -5\n  ret\n.LBL17_2:\n  mov r1 0\n  mstore [r9,-4] r1\n  mov r1 1\n  mstore [r9,-3] r1\n  mov r1 1\n  mstore [r9,-2] r1\n  mov r1 2\n  mstore [r9,-1] r1\n  jmp .LBL17_3\n.LBL17_3:\n  mload r1 [r9,-1]\n  mload r2 [r9,-5]\n  gte r1 r2 r1\n  cjmp r1 .LBL17_4\n  jmp .LBL17_6\n.LBL17_4:\n  mload r2 [r9,-4]\n  mload r3 [r9,-3]\n  add r1 r2 r3\n  range r1\n  mload r1 [r9,-3]\n  mload r1 [r9,-2]\n  jmp .LBL17_5\n.LBL17_5:\n  mload r2 [r9,-1]\n  add r1 r2 1\n  mstore [r9,-1] r1\n  jmp .LBL17_3\n.LBL17_6:\n  mload r0 [r9,-2]\n  add r9 r9 -5\n  ret\nfunction_dispatch:\n.LBL18_0:\n  add r9 r9 5\n  mstore [r9,-2] r9\n  mov r4 r1\n  mov r1 r2\n  mov r1 r3\n  mstore [r9,-3] r1\n  mload r1 [r9,-3]\n  eq r1 r4 229678162\n  cjmp r1 .LBL18_2\n  eq r1 r4 2146118040\n  cjmp r1 .LBL18_3\n  jmp .LBL18_1\n.LBL18_1:\n  ret\n.LBL18_2:\n  mload r1 [r1]\n  call fib_recursive\n  mov r2 r0\n  mov r1 2\n.PROPHET18_0:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 2\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-4] r1\n  mload r1 [r9,-4]\n  mstore [r1] r2\n  mov r2 1\n  mstore [r1,+1] r2\n  mload r1 [r9,-4]\n  tstore r1 2\n  add r9 r9 -5\n  ret\n.LBL18_3:\n  mload r1 [r1]\n  call fib_non_recursive\n  mov r2 r0\n  mov r1 2\n.PROPHET18_1:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 2\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-5] r1\n  mload r1 [r9,-5]\n  mstore [r1] r2\n  mov r2 1\n  mstore [r1,+1] r2\n  mload r1 [r9,-5]\n  tstore r1 2\n  add r9 r9 -5\n  ret\nmain:\n.LBL19_0:\n  add r9 r9 2\n  mstore [r9,-2] r9\n  mov r1 13\n.PROPHET19_0:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r6 1\n  not r7 13\n  add r7 r7 1\n  add r2 r1 r7\n  tload r2 r6 13\n  mov r1 r2\n  mload r6 [r1]\n  mov r1 14\n.PROPHET19_1:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r2 1\n  not r7 14\n  add r7 r7 1\n  add r3 r1 r7\n  tload r3 r2 14\n  mov r1 r3\n  mload r2 [r1]\n  add r4 r2 14\n  mov r1 r4\n.PROPHET19_2:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r3 1\n  not r7 r4\n  add r7 r7 1\n  add r5 r1 r7\n  tload r5 r3 r4\n  mov r3 r5\n  mov r1 r6\n  call function_dispatch\n  add r9 r9 -2\n  end\n",
  "prophets": [
    {
      "label": ".PROPHET18_0",
      "code": "%{\n    entry() {\n        cid.addr = malloc(cid.len);\n    }\n%}",
      "inputs": [
        {
          "name": "cid.len",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ],
      "outputs": [
        {
          "name": "cid.addr",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ]
    },
    {
      "label": ".PROPHET18_1",
      "code": "%{\n    entry() {\n        cid.addr = malloc(cid.len);\n    }\n%}",
      "inputs": [
        {
          "name": "cid.len",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ],
      "outputs": [
        {
          "name": "cid.addr",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ]
    },
    {
      "label": ".PROPHET19_0",
      "code": "%{\n    entry() {\n        cid.addr = malloc(cid.len);\n    }\n%}",
      "inputs": [
        {
          "name": "cid.len",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ],
      "outputs": [
        {
          "name": "cid.addr",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ]
    },
    {
      "label": ".PROPHET19_1",
      "code": "%{\n    entry() {\n        cid.addr = malloc(cid.len);\n    }\n%}",
      "inputs": [
        {
          "name": "cid.len",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ],
      "outputs": [
        {
          "name": "cid.addr",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ]
    },
    {
      "label": ".PROPHET19_2",
      "code": "%{\n    entry() {\n        cid.addr = malloc(cid.len);\n    }\n%}",
      "inputs": [
        {
          "name": "cid.len",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ],
      "outputs": [
        {
          "name": "cid.addr",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ]
    }
  ]
}
