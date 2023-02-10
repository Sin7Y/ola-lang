# Ola backend asm codegen

Ola 高级程序基本单元 `Contract`, 其两部分要素合约变量 `GlobalVar` 及 `functions` 

汇编代码生成分别位于 `.data` 及 `.text` 段，其中函数以 `.global` 标识全局符号，供汇编器使用。

## GlobalVar data seg

以 `.data` 开始，遍历IR结构中的 `GlobalVar` 列表，获取符号表信息及相应赋值信息，按序线性生成伪指令。

## Function text seg

分为 `prologue`、 `stmtBody` 及 `epilogue` 三部分。

### prologue

功能为保存fp及ra寄存器，为局部变量计算并开辟空间。进入主体后，sp指向最后一个参数

栈布局大体如下：

```

    //          <-- fp, 访问参数从-4处开始
    // 参数0
    // 参数1
    // ..
    // 参数m
    // 局部变量0 <-- 访问从 -4 - 4 * m(fp)
    // 局部变量1
    // ...
    // 局部变量n
    // 保存的fp
    // 保存的ra <-- sp
    // <stmtBody运算临时栈>
```

### stmtBody

DFS方式，func -> BB -> stmt，获取IR中的stmt类型。

```
   /// Integer constant.
    Uint32(values::Uint32),
    Uint64(values::Uint64),
    Uint256(values::Uint256),
    Field(values::Field),
    /// Undefined value.
    Undef(values::Undef),
    /// Aggregate constant.
    Aggregate(values::Aggregate),
    /// Function argument reference.
    FuncArgRef(values::FuncArgRef),
    /// Basic block argument reference.
    BlockArgRef(values::BlockArgRef),
    /// Local memory allocation.
    Alloc(values::Alloc),
    /// Global memory allocation.
    GlobalAlloc(values::GlobalAlloc),
    /// Memory load.
    Load(values::Load),
    /// Memory store.
    Store(values::Store),
    /// Pointer calculation.
    GetPtr(values::GetPtr),
    /// Element pointer calculation.
    GetElemPtr(values::GetElemPtr),
    /// Unary operation.
    Unary(values::Unary),
    /// Binary operation.
    Binary(values::Binary),
    /// Conditional branch.
    Branch(values::Branch),
    /// Unconditional jump.
    Jump(values::Jump),
    /// Function call.
    Call(values::Call),
    /// Function return.
    Return(values::Return),
```

依次指令选择映射成Ola指令，同时从栈中获取operand的值，加载到临时寄存器r5，r6并及时保存到栈顶。

### epilogue

恢复fp、sp、ra, 由caller负责清理栈上参数。

对应指令序列类似为:

```
    mov     sp, fp
    mload   fp, [sp] # sp-(paraCnt+VarCnt+1)*4
    mload   ra, [sp] # sp-(paraCnt+VarCnt+2)*4
    ret

```
