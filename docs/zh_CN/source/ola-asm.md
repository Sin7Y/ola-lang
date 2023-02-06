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
| 寄存器 |         说明                  |
| :---  |         :---                 |
| r0    |  保存返回值或传递参数           |
| r1-r3 |  保存函数参数                  |
| r4-r5 |  一般寄存器，无特殊用途          |
| r6    |  保存返回地址(lr),disable      |    
| r7    |  保存栈顶地址(sp),disable      |
| r8    |  保存栈底地址(fp)              |
| pc    |  保存当前执行指令地址,汇编不可用  |

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


