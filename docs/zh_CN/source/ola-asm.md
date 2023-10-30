# 基本格式
ola汇编语言基本格式如下：
``` 
{symbol} {instruction | directive | pseudo-instruction} {; | // comment}
``` 
- symbol表示符号，必须从行头开始。
- instruction表示指令，指令前通常包含两个空格。
- directive表示伪操作。
- pseudo-instruction表示伪指令。

指令、伪操作、伪指令的助记符均可大小写，但不能混用。

# 汇编指令
简单起见，暂不考虑类似 `.global main` 的伪操作或伪指令。

函数入口以 `funcName:` 开始，以 `:` 结尾的均被视作label（标签）。如 `main:` 定义了一个名为 `main` 的函数标签。

注意： 通常以 `.` 开头的符号表示伪指令或伪操作，如表示不同的段。以 `:` 结尾的符号表示标签，如函数名及BB块编号。

## 指令格式
函数内部汇编指令的格式为三地址码形式： `  <opcode>  <Rd>  <Rn>  <shifter_operand>`

- opcode 表示指令助记符，通常为olavm定义的指令助记符。
- Rd 表示指令操作目的寄存器，通常为olavm定义的寄存器。
- Rn 表示指令第一源操作数，通常为olavm定义的寄存器。
- shifter_operand 表示指令数据处理操作数，通常为立即数或olavm定义的寄存器。

## 寄存器
olavm提供10个寄存器，包含前9个通用寄存器 `r0-r8` 及最后一个专用寄存器 `pc`。

r8寄存器为fp寄存器。汇编中通用寄存器访问不能通过名字，只能通过数字索引方式访问。pc寄存器表示程序执行地址，汇编中不可访问。

当涉及函数调用时，通用寄存器的分类：
| 寄存器 |         功能                  |          使用场景                |          说明                |
| :---  |         :---                 |         :---                 |        :---                 |
| r0    |  通用、返回值、storage/poseidon传参及返回值| <br> 1）通用局部变量、表达式结果 <br> 2）普通函数调用单返回值 <br> 3）sstore/sload的value第1个参数 <br>4）poseidon第一个参数、第一个返回值| 编译器可读可写、vm可读当包含sload/poseidon时可读可写 |
| r1-r3 |  通用、传参、storage/poseidon传参及返回值  |<br>1）通用局部变量、表达式结果 <br>2）普通函数调用传递第1/2/3个参数<br> 3）sstore/sload的value第2/3/4个参数 <br>4）poseidon第2/3/4参数、第2/3/4返回值|编译器可读可写、vm可读当包含sload/poseidon时可读可写|
| r4-r7 |  通用、 storage/poseidon传参         |<br>1）通用局部变量、表达式结果 <br>2）sstore/sload的key第1/2/3/4个参数 <br>3）poseidon的第5/6/7/8个参数|编译器可读可写、vm可读|
| r8    |  栈指针              |编译器函数栈指针|编译器可读可写、vm可读|
| pc    |  当前执行指令地址  |VM标识当前执行指令地址|编译器不可见、vm可读可写|
| psp    |  当前prophet区地址  |VM标识当前prophet内存空间地址|编译器可读、vm可读可写|


sstore指令

ir接口  `set_storage(i64 %key1, %key2, %key3, %key4, %val1, %val2, %val3, %val4)`

汇编接口：
1） 保存r0-r7通用寄存器到栈，如`mstore [r8,stOffBase],r0`  ... `mstore [r8,stOffBase+7],r7`
2) 占用r0-r7寄存器分配参数即key及value，如`mov r4 %key1` ... `mov r7 %key4`  `mov r0 %val1` ... `mov r3 %val4`
3) 调用sstore指令
4）恢复r0-r7寄存器，如`mload r0,[r8,stOffBase]`  ... `mload r7,[r8,stOffBase+7]`

sload指令

ir接口  `get_storage(i64 %key1, i64 %key2, i64 %key3, i64 %key4, ptr %val1, ptr %val2, ptr %val3, ptr %val4)`

汇编接口：
1） 保存r0-r7通用寄存器到栈，如`mstore [r8,slOffBase],r0`  ... `mstore [r8,slOffBase+7],r7`
2) 占用r4-r7寄存器分配参数即key及value，如`mov r4 %key1` ... `mov r7 %key4`
3) 调用sstore指令
4) 接收返回值，保存到栈，如`mstore [r8,slRetOffBase],r0`  ... `mstore [r8,slRetOffBase+3],r3`
5）恢复r0-r7寄存器，如`mload r0,[r8,slOffBase]`  ... `mload r7,[r8,slOffBase+7]`


poseidon builtin

ir接口  `poseidon_hash(i64 %param1, i64 %%param2, i64 %%param3, i64 %%param4, i64 %%param5,i64 %%param5,i64 %%param7,i64 %%param8, ptr %val1, ptr %val2, ptr %val3, ptr %val4)`

汇编接口：
1） 保存r0-r7通用寄存器到栈，如`mstore [r8,psOffBase],r0`  ... `mstore [r8,psOffBase+7],r7`
2) 占用r0-r7寄存器分配参数，如`mov r0 %param1` ... `mov r7 %param7`
3) 调用poseidon指令
4) 接收返回值，保存到栈，如`mstore [r8,psRetOffBase],r0`  ... `mstore [r8,psRetOffBase+3],r3`
5）恢复r0-r7寄存器，如`mload r0,[r8,psOffBase]`  ... `mload r7,[r8,psOffBase+7]`

## 内存布局
指令地址与内存空间共享统一空间。

程序加载加载后pc指向零地址，依据函数调用的层级关系进行函数栈帧切换，内存地址栈内从 `低地址 -> 高地址` 方向生长。

# 汇编示例
## 算术运算
```
main: ;加法算术运算
.LBL_0_0:
  add r8 r8 4 ;计算局部变量栈空间并开栈,r8为fp
  mov r4 100   ;立即数存入通用寄存器
  not r5 3    ;局部变量1计算栈位置
  add r5 r5 1
  add r5 r8 r5
  mstore r5 r4 ;局部变量1赋值入栈
  mov r4 1     ;同上，局部变量2赋值入栈
  not r6 2
  add r6 r6 1
  add r6 r8 r6
  mstore r6 r4
  mov r4 2     ;同上，局部变量3赋值入栈
  not r7 1
  add r7 r7 1
  add r7 r8 r7
  mstore r7 r4
  mload r4 r6  ;栈上取局部变量2
  mload r1 r7  ;栈上取局部变量3
  add r4 r4 r1 ;加法二元运算
  mstore r5 r4 ;运算结果覆盖局部变量1栈空间
  mload r0 r5  ;栈上运算结果存入r0返回值寄存器
  not r4 4    ;回收栈空间
  add r4 r4 1
  add r8 r8 r4
  end          ;程序结束
```
## 函数调用
```
fib_recursive:
.LBL_0_0:
  mov r4 r8
  add r8 r8 6
  not r5 5
  add r5 r5 1
  add r5 r8 r5
  mstore r5 r4  ;保存fp, lr由vm保存于[fp-1]
  not r6 2
  add r6 r6 1
  add r6 r8 r6
  mstore r6 r0
  mload  r1 r6
  eq r1 0
  cjmp .LBL_0_2
  jmp .LBL_0_1
.LBL_0_1:
  mload  r1 r6
  not r2 1
  add r2 r2 1
  add r1 r1 r2
  eq r1 0
  cjmp .LBL_0_2
  jmp .LBL_0_3
.LBL_0_2:
  mov r1 1
  not r2 3
  add r2 r2 1
  add r2 r8 r2
  mstore r2 r1
  jmp LBL_0_4
.LBL_0_3:
  not r4 2
  add r4 r4 1
  add r4 r8 r4
  mload r5 r4
  not r6 1
  add r6 r6 1
  add r5 r5 r6
  call fib_recursive
  add r6 r8 r6
  mstore r6 r0
  not r7 2
  add r7 r7 1
  add r8 r8 r7
  call fib_recursive
  mov r4 r0
  mload r0 r6
  add r4 r4 r0
  not r5 3
  add r5 r5 1
  add r5 r8 r5
  mstore r5 r4
  jmp .LBL_0_4
.LBL_0_4:
  not r7 3
  add r7 r7 1
  add r7 r8 r7
  mload r0 r7
  not r7 4
  add r7 r7 1
  add r7 r8 r7
  mload r8 r7
  not r7 6
  add r7 r7 1
  add r8 r8 r7
  ret
main:
  mov r4 r8
  add r8 r8 4
  not r5 3
  add r5 r5 1
  add r5 r8 r5
  mstore r5 r4
  mov r0 6
  call fib_recursive
  not r6 1
  add r6 r6 1
  add r6 r8 r6
  mstore r6 r0
  mload r8 r5
  not r7 4
  add r7 r7 1
  add r7 r8 r7
  end
```


