{
  "program": "mempcy:\n.LBL2_0:\n  add r9 r9 4\n  mstore [r9,-4] r1\n  mload r1 [r9,-4]\n  mstore [r9,-3] r2\n  mload r2 [r9,-3]\n  mstore [r9,-2] r3\n  mload r3 [r9,-2]\n  mov r4 0\n  mstore [r9,-1] r4\n  jmp .LBL2_1\n.LBL2_1:\n  mload r4 [r9,-1]\n  gte r5 r3 r4\n  neq r6 r4 r3\n  and r5 r5 r6\n  cjmp r5 .LBL2_2\n  jmp .LBL2_3\n.LBL2_2:\n  mload r6 [r1,r4]\n  mstore [r2,r4] r6\n  add r5 r4 1\n  mstore [r9,-1] r5\n  jmp .LBL2_1\n.LBL2_3:\n  add r9 r9 -4\n  ret\nsetNonce:\n.LBL16_0:\n  add r9 r9 89\n  mstore [r9,-2] r9\n  mstore [r9,-5] r1\n  mstore [r9,-4] r2\n  mload r1 [r9,-5]\n  mstore [r9,-12] r1\n  mov r1 4\n.PROPHET16_0:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 4\n  add r7 r7 1\n  add r3 r1 r7\n  mov r4 r3\n  mov r1 0\n  mstore [r4] r1\n  mov r1 0\n  mstore [r4,+1] r1\n  mov r1 0\n  mstore [r4,+2] r1\n  mov r1 0\n  mstore [r4,+3] r1\n  mov r1 8\n.PROPHET16_1:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r3 4\n  not r7 8\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-20] r1\n  mload r2 [r9,-20]\n  mov r1 r4\n  call mempcy\n  mov r3 4\n  mload r1 [r9,-20]\n  add r1 r1 4\n  mstore [r9,-11] r1\n  mload r2 [r9,-11]\n  mload r1 [r9,-12]\n  call mempcy\n  mov r1 4\n.PROPHET16_2:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mload r2 [r9,-20]\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-8] r1\n  mload r1 [r9,-8]\n  mov r4 r1\n  poseidon r4 r2 8\n  mload r2 [r9,-4]\n  mov r1 4\n.PROPHET16_3:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-18] r1\n  mload r1 [r9,-18]\n  mstore [r9,-51] r1\n  mload r1 [r9,-51]\n  mstore [r1] r2\n  mov r1 0\n  mload r2 [r9,-51]\n  mstore [r2,+1] r1\n  mov r1 0\n  mload r2 [r9,-51]\n  mstore [r2,+2] r1\n  mov r1 0\n  mload r2 [r9,-51]\n  mstore [r2,+3] r1\n  mov r1 8\n.PROPHET16_4:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r3 4\n  not r7 8\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-17] r1\n  mload r2 [r9,-17]\n  mov r1 r4\n  call mempcy\n  mov r3 4\n  mload r1 [r9,-17]\n  add r1 r1 4\n  mstore [r9,-9] r1\n  mload r2 [r9,-9]\n  mload r1 [r9,-51]\n  call mempcy\n  mov r1 4\n.PROPHET16_5:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mload r2 [r9,-17]\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-7] r1\n  mload r1 [r9,-7]\n  mov r3 r1\n  poseidon r3 r2 8\n  mov r1 4\n.PROPHET16_6:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-16] r1\n  mload r1 [r9,-16]\n  mov r2 55\n  mstore [r1] r2\n  mov r2 0\n  mstore [r1,+1] r2\n  mov r2 0\n  mstore [r1,+2] r2\n  mov r2 0\n  mstore [r1,+3] r2\n  sstore r3 r1\n  mload r1 [r9,-5]\n  mstore [r9,-71] r1\n  mov r1 4\n.PROPHET16_7:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-21] r1\n  mload r1 [r9,-21]\n  mov r4 r1\n  mov r1 0\n  mstore [r4] r1\n  mov r1 0\n  mstore [r4,+1] r1\n  mov r1 0\n  mstore [r4,+2] r1\n  mov r1 0\n  mstore [r4,+3] r1\n  mov r1 8\n.PROPHET16_8:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r3 4\n  not r7 8\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-6] r1\n  mload r2 [r9,-6]\n  mov r1 r4\n  call mempcy\n  mov r3 4\n  mload r1 [r9,-6]\n  add r1 r1 4\n  mstore [r9,-15] r1\n  mload r2 [r9,-15]\n  mload r1 [r9,-71]\n  call mempcy\n  mov r1 4\n.PROPHET16_9:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mload r2 [r9,-6]\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-13] r1\n  mload r1 [r9,-13]\n  mov r4 r1\n  poseidon r4 r2 8\n  mload r2 [r9,-4]\n  mov r1 4\n.PROPHET16_10:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-23] r1\n  mload r1 [r9,-23]\n  mstore [r9,-82] r1\n  mload r1 [r9,-82]\n  mstore [r1] r2\n  mov r1 0\n  mload r2 [r9,-82]\n  mstore [r2,+1] r1\n  mov r1 0\n  mload r2 [r9,-82]\n  mstore [r2,+2] r1\n  mov r1 0\n  mload r2 [r9,-82]\n  mstore [r2,+3] r1\n  mov r1 8\n.PROPHET16_11:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r3 4\n  not r7 8\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-22] r1\n  mload r2 [r9,-22]\n  mov r1 r4\n  call mempcy\n  mov r3 4\n  mload r1 [r9,-22]\n  add r1 r1 4\n  mstore [r9,-14] r1\n  mload r2 [r9,-14]\n  mload r1 [r9,-82]\n  call mempcy\n  mov r1 4\n.PROPHET16_12:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mload r2 [r9,-22]\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-10] r1\n  mload r1 [r9,-10]\n  mov r3 r1\n  poseidon r3 r2 8\n  mov r1 4\n.PROPHET16_13:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  not r7 4\n  add r7 r7 1\n  add r1 r1 r7\n  mstore [r9,-19] r1\n  mload r1 [r9,-19]\n  sload r3 r1\n  mload r1 [r1]\n  mstore [r9,-3] r1\n  mload r1 [r9,-3]\n  mov r2 3\n.PROPHET16_14:\n  add r9 r9 -89\n  ret\nfunction_dispatch:\n.LBL17_0:\n  add r9 r9 3\n  mstore [r9,-2] r9\n  mov r2 r3\n  mstore [r9,-3] r2\n  mload r2 [r9,-3]\n  eq r1 r1 3694669121\n  cjmp r1 .LBL17_2\n  jmp .LBL17_1\n.LBL17_1:\n  ret\n.LBL17_2:\n  mov r3 r2\n  add r1 r3 4\n  mload r2 [r1]\n  mov r1 r3\n  call setNonce\n  add r9 r9 -3\n  ret\nmain:\n.LBL18_0:\n  add r9 r9 2\n  mstore [r9,-2] r9\n  mov r1 13\n.PROPHET18_0:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r6 1\n  not r7 13\n  add r7 r7 1\n  add r2 r1 r7\n  tload r2 r6 13\n  mov r1 r2\n  mload r6 [r1]\n  mov r1 14\n.PROPHET18_1:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r2 1\n  not r7 14\n  add r7 r7 1\n  add r3 r1 r7\n  tload r3 r2 14\n  mov r1 r3\n  mload r2 [r1]\n  add r4 r2 14\n  mov r1 r4\n.PROPHET18_2:\n  mov r0 psp\n  mload r0 [r0]\n  mov r1 r0\n  mov r3 1\n  not r7 r4\n  add r7 r7 1\n  add r5 r1 r7\n  tload r5 r3 r4\n  mov r3 r5\n  mov r1 r6\n  call function_dispatch\n  add r9 r9 -2\n  end\n",
  "prophets": [
    {
      "label": ".PROPHET16_0",
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
      "label": ".PROPHET16_1",
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
      "label": ".PROPHET16_2",
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
      "label": ".PROPHET16_3",
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
      "label": ".PROPHET16_4",
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
      "label": ".PROPHET16_5",
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
      "label": ".PROPHET16_6",
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
      "label": ".PROPHET16_7",
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
      "label": ".PROPHET16_8",
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
      "label": ".PROPHET16_9",
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
      "label": ".PROPHET16_10",
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
      "label": ".PROPHET16_11",
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
      "label": ".PROPHET16_12",
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
      "label": ".PROPHET16_13",
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
      "label": ".PROPHET16_14",
      "code": "%{\n    entry() {\n        printf(cid.base, cid.flag);\n    }\n%}",
      "inputs": [
        {
          "name": "cid.base",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        },
        {
          "name": "cid.flag",
          "length": 1,
          "is_ref": false,
          "is_input_output": false
        }
      ],
      "outputs": []
    },
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
      "label": ".PROPHET18_2",
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
