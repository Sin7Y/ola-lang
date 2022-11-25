# Ola DSL设计说明


## 简介
Ola 是用于开发Olavm智能合约的编程语言，它是图灵完备的，支持用于编写简单或复杂的运算，随后这些运算的过程会被Olavm后端的证明系统证明，从而验证Olavm的处理过程准确无误。

现有的编程语言大多数都过于复杂，执行过程难以被ZKP证明和验证，Ola 从设计之初就考虑到证明的效率与执行效率的均衡。从容易生成证明这个角度来看Ola 参考了[cairo](https://www.cairo-lang.org/) 语言，从对于开发者友好的角度来看，Ola 的语法接近 c/c++ 和 rust的语法，这使得大多数开发者可以快速学习。Ola 主要设计目标有以下几点：

- 安全 代码的执行结果应该是确定性的，这点会在语法层面说明以及编译器层面进行限制。
- 效率 代码的执行和证明速度在均衡的情况下是最高效的。
- 简单 代码应该尽可能的易用、易读，熟悉C++/Rust 的开发者应该可以快速入门。
- 图灵完备 使用Ola应该可以构建复杂的应用程序，包括但不局限于循环，递归等基础语法。

Ola目前正在快速发展，该文档会实时更新，希望开发者与我们一起共建。如果希望在Ola获得帮助，可以发送邮件至<contact@sin7y.com>

## 快速入门

### installation

TODO
### Hello Ola

TODO

## Ola language


### Variables

#### 标识符

变量不能以数字开头，任何非保留关键字一任意数量的"_"开头，后面是一个ASCII字母字符和任意数量的字母或者字符都可以被用作标识符

```rust=
fn main() {
    // declare and ine `_variable`
    u32 mut _a = 2;   // identifiers start with "_"
    // u32 mut 0a = 2;  define error, identifiers can't start with number
}
```

#### 声明

变量需要被声明才能被使用。声明和定义总是结合在一起的，这样就不会存在未定义的变量。

**note: 后续可能不需要声明和定义相结合，编译器会自动进行类型推导。**

```
fn main() {
    // declare and define `a`
    field mut a = 2;
    // redefine `a`
    a = 3;
}
```


#### 可变性
类似rust, 变量默认是不可变的，所以一旦定义，后续不能更改变量的值。如果需要定义可变变量，需要使用 `mut` 关键字
```rust=
fn main() {
    u32 a = 0;    
    a = 42; // compile error: mutating an immutable variable

    u32 mut b = 0;
    b = 42; // ok
}
```

#### scope

变量定义不支持Shadowing, 这是为了安全考虑，如果需要多个具有相似逻辑含义的相邻变量，则应使用可变变量或类型后缀。

```rust=
fn main() {
    field mut a = 5;
    {        
        field a = 25; // compile error: redeclared variable 'x'
    };    
    field a = 25; // compile error: redeclared variable 'x'

    a = 25; // ok
}
```
变量不同于常量，变量只能定义在函数中，作用域仅限于当前函数本身。

```rust=
fn foo() -> field {
    // return a; <- not allowed
    return 2;
}

fn bar() -> field {
    field a = 2;
    return foo();
}
```

在For-Loop 循环中的变量，只能作用域当前循环

```rust=
fn main() -> u32 {
    u32 mut a = 0;
    for u32 i in 0..5 {
        a = a + i;
    }
    // return i; <- not allowed
    return a;
}
```

### 数据类型

Ola 是一种静态类型语言，因此所有变量都必须具有在编译时已知的类型，这样可以避免大部分的运行时异常。目前Ola支持一些基本类型和复杂类型。

#### 基本类型

Ola 支持的基本类型主要有三种，分别是整数类型、field类型、boolean类型。

##### 整数类型

整数类型有 `u32`、`u64`、`u128`、`u256` 几种类型，目前只支持无符号整数操作。所有类型以`field` 类型为基础进行构建，Ola 会提供对应的libs 基于field 实现多种上述的各种整数类型，方便开发者编写函数。

```rust=
u32 a = 2; // u8
u64 b  = 0xffff; // u64
u256 d = 102411  // u256
```

##### field类型

field 是 ola的最基本类型，field中的数据范围为[0, p -1]。olaVM 使用plonky2作为其证明系统，所以 field的素数域选择为 $p=2^{64}-2^{32}+1$。

对于开发者来说， field类型数据在大多数时候表现得像整数类型一样，但是当overflow的时候需要特别注意。

```rust=
field a = 0xff; // field
field b = 0; // field
```

##### boolean类型

bool 表示 field的值 为 `0` 或者 `1`, 使用关键字`bool` 进行声明

```rust=
bool a = true;
bool b = false;
```
#### 复杂类型

Ola 支持多种复杂类型，这些复杂类型都可以在c++/rust中找到对应的原型，有了这些复杂类型，开发者可以方便的进行业务逻辑开发。

##### Arrays

Ola 支持的数组为静态类型数组，数组中数据类型必须保持一致，并且数组的大小必须在编译的时候是确定的。数组元素从零开始编号，并且可以使用`[index]`进行访问。

数组的声明和初始化

数组的声明和初始化必须一起完成，数组的声明是通过类型加上[]来完成的，并且大小必须进行指定。初始化可以通过逗号分割的元素列表和[]进行初始化。对于数组元素一致的数组声明和初始化，可以采用`[value; size]` 这种方式。下面展示了一些数组声明和初始化的例子
```rust=
field[5] a = [1, 2, 3, 4, 5]; // initialize a field array with field values
bool[3] b = [true; 3]; // initialize a bool array with value true
```

二维数组

Ola 支持二维数组的使用，二维数组的声明和使用与一维数组类似，区别在于二维数组的内部元素也是数组，二维数组的样例如下：

```rust=
// Array of two elements of array of 3 elements

field[2][4] a = [[1, 2, 3, 4],[4, 5, 6, 7]];

field[4] b = a[1]; // should be [4, 5, 6, 7]
```

数组切片

与rust类似，数组的创建可以通过一个数组的切片来复制生成，下面展示了数组切片的使用方法

```rust=
field[5] a = [1, 2, 3, 4, 5];
field[3] b = a[2..4];   // initialize an array copying a slice from `a`
// array b is [3, 4, 5]
```

##### Tuples

tuple 是一种复合类型，它是一种各种元素的集合，可以通过`.` 访问集合中的每个元素，下面展示了tuple的使用示例：

```rust=
fn main() -> bool {
    (field[2], bool) mut v = ([1, 2], true);
    v.0 = [2, 3];
    return v.1;
}
```

##### Structs

Structs是一种复合类型，它可让将多种数据类型组合起来，从而构成一个有意义的新struct。stuct的成员可以通过`.` 访问。
struct 的相关示例如下：

```rust=
struct Person {
    age: u32,
    id: u64,
}

fn main() {
   Person mut person = Person {
        age: 18,
        id: 123456789,
    };
    person.age = 25;
}
```

##### Enumerations

TODO

##### Map

TODO

#### 类型别名

为了增加代码可读性，Ola支持为每种类型定义类型别名，类型别名是一种代码语法糖，只是在代码编写阶段起作用，在编译时期类型别名将会被替换成真实类型。类型别名的定义示例如下：

```rust=
type balance = uint256;

fn main() -> balance {
    balance mut a = 32;
    a -= 2
    return a;
}
```

### 常量

常量可以使用`const` 关键字来定义， 常量只能声明为常量表达式，常量只能不能被重新声明和重新赋值，一旦定义了常量，即可在下一个常量或者其他地方使用常量。常量一般推荐使用全部大写字母和`_`拼接进行声明, 常量的声明如下所示：
```rust=
const field ONE = 1;
const field TWO = ONE + ONE;

const field HASH_SIZE = 256;

fn hash_size() -> field {
    return HASH_SIZE;
}
```

### 运算符(Operators)

Ola 提供算术、逻辑、关系、位等运算符。除作用于数值的算术运算为模p，其他均为标准语义。

#### 算术运算符(Arithmetic operators)

所有算术运算符均为模p，具体如下：

|运算符|示例|解释|
| :---:| :---:| :---: |
| + | a + b |算术加法模p |
|-| a-b |算术减法模p |
| * | a * b |算术乘法模p |
| / | a / b |乘逆模p |
|%| a%b |整数除法的模|

算数运算符结合`=` 后可以组成新的运算符，如：`+=`、`-=`、`*=`、`/=`、`%=`。

#### 逻辑运算符(Logical operators)

| 运算符 | 示例 | 解释 |
| :--- | :--- | :--- |
| && | a && b | 布尔运算符AND |
| \|\| | a \|\| b | 布尔运算符OR |
| ! | ! a | 布尔运算符非 |

#### 关系运算符(Relational operators)

关系运算符的返回结果都是`bool`类型

|运算符|示例|解释|
| :--- | :--- | :--- |
| == | a == b |相等|
| != | a ！= b | 不相等|
| < | a < b | 小于 |
| > | a >b  | 大于 |
|<= | a <= b  |小于等于 |
| >= | a >= b | 大于等于 | 


#### 位运算符(Bitwise operators)

所有位运算符均为模p，具体如下：

|运算符|示例|解释|
| :--- | :--- | :--- |
| & | a & b |位与|
| \| | a \| b |位或|
| ~ | ~ a |位非(254位)|
| ^ | a ^ b |位异或(254位)|
|<<| a << 3 | 左移 |
| >> | a >> 3 | 右移 | 

位运算符结合`=` 后可以组成新的运算符，如：`&=`、`|=`、`^=`、`<<=`、`>>=`。

### 控制流(Control Flow)

#### 条件语句(Conditional statement)

条件语句: **if-else**

`if` **boolean_condition** block_of_code `else` block_of_code。 示例代码如下：


```rust=
fn main(field a) -> field {
    
    // Similar to rust, the result of a conditional expression 
    // can be received directly by the variable
    field b = if a + 1 == 2 { 1 } else { 3 };
    return b;
}
```
条件语句支持三元运算符，示例如下:

```rust=
fn main(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

#### 循环语句(Loop statement)

循环形式: **for-loop**

`for` **identifier** `in` {range} block_of_code 

```rust=
fn main() -> u32 {
    u32 mut result = 0;
    for u32 i in 0..10 {
        for u32 j in i..10 {
            res = res + i;
        }
    }
    return result;
}
```

### 函数(Functions)

函数是使用`fn`关键字声明的，必须明确提供函数的名称。它的参数和返回值是可选择的，函数的参数都是按值传递的，函数参数如果声明为`mut` 类型，也是按值传递，只是在函数范围内可以改变此值。如果函数返回一个值，返回类型必须在`->` 之后指定。函数示例代码如下：

```rust=
fn sum(u32 a, u32 b) -> u32 {
/* 
 *  Unlike rust, the return value of 
 *  a function must be a combination of return and return value
 */
    return a + b;  
}
```

### Imports 

为了使用其他文件中的代码，我们可以使用关键字 `import` 将它们导入到我们的程序中，并带有相应的文件名称。使用`import` 可以方便我们导入一些libs，从而无需重复开发。

```rust=
import "./math/uint256.ola";
import "./crypto/sha256.ola";
```

### 注释(Comment Lines)

类似C/C++风格

单行采用` // `:
```rust=
// Using this, we can comment a line.
fn main(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

段注释采用`/*` 及 `*/`:
```rust=
fn sum(u32 a, u32 b) -> u32 {
/* 
 *  Unlike rust, the return value of 
 *  a function must be a combination of return and return value
 */
    return a + b;  
}
```

### Log

Ola 支持在OlaVM执行期间记录对应的执行日志。日志采用log关键字记录，第一个参数是格式字符串，其中每个`{}`占位符都替换为其余参数中的相应值,占位符的数量必须等于参数的数量。示例如下：

```rust=
fn main(u32 a, field b) {
    log("a is {}, b is {}", a, b);
}
```
默认情况下，日志在编译期间被删除。为了将它们包含在已编译的程序中，必须启用--debug标志。


## 智能合约

TODO

## IR介绍

原则：保持高层语言的抽象，同时方便lower到指令集。

op操作包含如下：

```rust=
/// An operator
pub enum Op {
    /// a variable
    Var(String),
    /// a constant
    Const(Value),

    /// if-then-else: ternary
    Ite,
    /// equality
    Eq,

    /// bit-vector binary operator
    BvBinOp(BvBinOp),
    /// bit-vector n-ary operator
    BvNaryOp(BvNaryOp),
    /// bit-vector unary operator
    BvUnOp(BvUnOp),
    /// single-bit bit-vector from a boolean
    BoolToBv,
    /// Zero-indexed and inclusive.
    BvExtract(usize, usize),
    /// bit-vector concatenation. n-ary. Low-index arguements map to high-order bits
    BvConcat,
    /// add this many zero bits
    BvUext(usize),
    /// add this many sign-extend bits
    BvSext(usize),

    /// boolean implication (binary)
    Implies,
    /// boolean n-ary operator
    BoolNaryOp(BoolNaryOp),
    /// boolean not
    Not,
    /// get this index bit from an input bit-vector
    BvBit(usize),

    /// Integer n-ary operator
    IntNaryOp(IntNaryOp),
    /// Integer comparison operator
    IntBinPred(IntBinPred),

    /// Binary operator, with arguments (array, index).
    ///
    /// Gets the value at index in array.
    Select,
    /// Ternary operator, with arguments (array, index, value).
    ///
    /// Makes an array equal to `array`, but with `value` at `index`.
    Store,

    /// Assemble n things into a tuple
    Tuple,
    /// Get the n'th element of a tuple
    Field(usize),
    /// Update (tuple, element)
    Update(usize),

    /// Map (operation)
    Map(Box<Op>),

    /// Call a function (name, argument sorts, return sort)
    Call(String, Vec<Sort>, Sort),

    /// Cyclic right rotation of an array
    /// i.e. (Rot(1) [1,2,3,4]) --> ([4,1,2,3])
    Rot(usize),
}
```

其中，具体op类型包含
```
/// Boolean n-ary operator
pub enum BoolNaryOp {
    /// Boolean AND
    And,
    /// Boolean XOR
    Xor,
    /// Boolean OR
    Or,
}

/// Bit-vector binary operator
pub enum BvBinOp {
    /// Bit-vector (-)
    Sub,
    /// Bit-vector (/)
    Udiv,
    /// Bit-vector (%)
    Urem,
    /// Bit-vector (<<)
    Shl,
    /// Bit-vector arithmetic (sign extend) (>>)
    Ashr,
    /// Bit-vector logical (zero fill) (>>)
    Lshr,
}

/// Bit-vector binary predicate
pub enum BvBinPred {
    // TODO: add overflow predicates.
    /// Bit-vector unsigned (<)
    Ult,
    /// Bit-vector unsigned (>)
    Ugt,
    /// Bit-vector unsigned (<=)
    Ule,
    /// Bit-vector unsigned (>=)
    Uge,
    /// Bit-vector signed (<)
    Slt,
    /// Bit-vector signed (>)
    Sgt,
    /// Bit-vector signed (<=)
    Sle,
    /// Bit-vector signed (>=)
    Sge,
}

/// Bit-vector n-ary operator
pub enum BvNaryOp {
    /// Bit-vector (+)
    Add,
    /// Bit-vector (*)
    Mul,
    /// Bit-vector bitwise OR
    Or,
    /// Bit-vector bitwise AND
    And,
    /// Bit-vector bitwise XOR
    Xor,
}

/// Bit-vector unary operator
pub enum BvUnOp {
    /// Bit-vector bitwise not
    Not,
    /// Bit-vector two's complement negation
    Neg,
}

/// Integer binary predicate. See [Op::Eq] for equality.
pub enum IntBinPred {
    /// Integer (<)
    Lt,
    /// Integer (>)
    Gt,
    /// Integer (<=)
    Le,
    /// Integer (>=)
    Ge,
}

/// The "type" of an IR term
pub enum Sort {
    /// bit-vectors of this width
    BitVector(usize),
    /// arbitrary-precision integer
    Int,
    /// boolean
    Bool,
    /// Array from one sort to another, of fixed size.
    ///
    /// size presumes an order, and a zero, for the key sort.
    Array(Box<Sort>, Box<Sort>, usize),
    /// A tuple
    Tuple(Box<[Sort]>),
}

/// An IR array value.
///
/// A sized, space array.
pub struct Array {
    /// Key sort
    pub key_sort: Sort,
    /// Default (fill) value. What is stored when a key is missing from the next member
    pub default: Box<Value>,
    /// Key-> Value map
    pub map: BTreeMap<Value, Value>,
    /// Size of array. There are this many valid keys.
    pub size: usize,
}
```


## ABI介绍

TODO

## Appendix

### grammar说明

TODO

### keywords

下面列表展示了Ola的关键字和保留字：

| 关键字 | 解释                         |
| ------ | ---------------------------- |
| mut    | 可变变量声明                 |
| const  | 常量声明                     |
| type   | 类型别名声明                 |
| struct | 结构体声明                   |
| fn     | 函数声明                     |
| for    | 根据表达式的结果有条件地循环 |
| in     | 循环的范围选择               |
| if     | 基于条件表达式的结果选择分支 |
| else   | `if`控制流的候选语句         |
| return | 函数返回结果                 |
| bool   | boolean 值                   |
| u32    | 整数类型                     |
| u64    | 整数类型                     |
| u128   | 整数类型                     |
| u256   | 整数类型                     |
| field  | 在`p` 范围内的域元素         |
| true   | boolean  ture                |
| false  | boolean  false               |
| log    | 函数运行时打印日志           |
| import | 导入其他文件                 |

保留字列表

```rust
pub
contract
impl
enum
while
loop
break
continue
use
match
as
static
```

### ola-libs说明


TODO