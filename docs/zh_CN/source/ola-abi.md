# Procedure Call Conventions

`fp` 寄存器加载程序后初始化指向frame堆栈的首地址。

之后在执行 `call` 指令时地址会增加。在执行 `ret` 指令时 `fp` 寄存器指向地址会回退。

## 调用过程 
- 使用 `call` 指令调用函数，fp指向新的frame。
- 函数返回的pc地址放在 `[fp-1]` 。
- 函数调用前的fp指向的地址放在 `[fp-2]` 
- 函数参数处理：前4个入参依次放在 `r0` 、 `r1`、 `r2`、 `r3` 四个寄存器。
              若超过4个参数，则从第5个入参开始，依次递减放在 `[fp-3]` , `[fp-4]` ， $\cdots$。
- 函数内部局部变量从 `[fp]` 开始，`fp` 地址递增存放。返回值存放在 `r0` 中。 若返回值不是一个域元素，则需要通过返回数据的内存指针返回。

函数调用示例：

函数原型： `foo(field a, field b, field c, field d, field e)`

入参：`a=0x1, b=0x2, c=0x3, d=0x4, e=0x5`

函数定义：
```
fn foo(field a, field b, field c, field d, field e) -> field {
    field res = 0;
    res = a+b;
    res = res * c;
    res = res + d + e;
    return res;
}
```

则函数调用前后的 `fp` , `pc` 和内存状态如下，其中黄色表示内存地址，红色表示指令地址，蓝色表示寄存器。

![OlaVM函数调用模型](images/procedure_call.png)