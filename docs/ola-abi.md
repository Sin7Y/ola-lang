# Procedure Call Conventions


Initialization points to the first address of frame stack after the `fp`  register is loaded.

The address will be increased when the `call`  instruction is executed later. When the `ret` instruction is executed, the `fp` register points to the address and falls back.



## Calling Process - 
Use  `call` to call function, and `fp` points to the new frame.
- The pc address returned by the function is placed in `[fp-1]`.
- The address pointed to by fp before the function call is placed in  `[fp-2]`
- Function parameter processing: the first four input parameters are placed in the four registers `r0`, `r1`, `r2`, and `r3`. If there are more than 4 parameters, start with the fifth input parameter and descend accordingly in `[fp-3]` , `[fp-4]` , ⋯
- Local variables inside the function start at `[fp]`, and the `fp` address is stored incrementally. The return value is stored in `r0`. If the return value is not a domain element, it needs to be returned by a memory pointer that returns the data.


Function call example:

Function prototype: `foo(field a, field b, field c, field d, field e)`

Input parameters：`a=0x1, b=0x2, c=0x3, d=0x4, e=0x5`

Function definition：
```
fn foo(field a, field b, field c, field d, field e) -> field {
    field res = 0;
    res = a+b;
    res = res * c;
    res = res + d + e;
    return res;
}
```

The `fp`, `pc` and memory states before and after the function call are as follows, where yellow represents the memory address, red represents the instruction address, and blue represents the register. 

![OlaVM函数调用模型](images/procedure_call.png)