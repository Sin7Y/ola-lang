# Olang语法

### Variables

#### 标识符

变量由数字(`0-9`)、ASCII大小写字母(`a-zA-Z`)、下划线(`_`)组成。

不能以数字开头，不能使用关键字命名变量。

```
fn foo() {
    // declare and ine `_variable`
    u32 mut _aBC123 = 2u;   // identifiers start with "_"
    // u32 mut 0a = 2u;  define error, identifiers can't start with number
}
```

#### 声明

变量需要被声明才能被使用。为避免出现变量未定义，需在声明声明时进行初始化。

```
fn foo() {
    // declare and define `a`
    field mut a = 2f;
    // redefine `a`
    a = 3f;
}
```

#### 可变性
变量默认不可变的，即一旦定义，后续不能更改变量的值。

若需要定义可变变量，需使用 `mut` 关键字修饰变量。

```
fn foo() {
    u32 a = 0u;    
    a = 42u; // compile error: mutating an immutable variable

    u32 mut b = 0u;
    b = 42u; // ok
}
```

#### scope

出于安全考虑，变量定义不支持Shadowing。

若需要多个具有相似逻辑含义的相邻变量，则应使用可变变量或类型后缀。

```
fn foo() {
    field mut a = 5;
    {        
        field a = 25; // compile error: redeclared variable 'a'
    };    
    field a = 25; // compile error: redeclared variable 'a'

    a = 25; // ok
}
```
变量不同于常量，变量作用域仅限于当前函数本身，不支持全局变量。

```
fn foo() -> field {
    // return a; <- not allowed
    return 2;
}

fn bar() -> field {
    field a = 2;
    return foo();
}
```

在`For-Loop`循环中的变量，作用域仅限于循环内部。

```
fn foo() -> u32 {
    u32 mut a = 0;
    for u32 i in 0..5 {
        a = a + i;
    }
    // return i; <- not allowed
    return a;
}
```

### 数据类型

Olang为静态类型语言，变量类型须在在编译期已知，可以避免大部分的运行时异常。

支持三种基本类型和多种复杂类型。

#### 基本类型

基本类型主要有三种，分别是整数类型、field类型、boolean类型。

##### 整数类型

整数类型有`u32`、`u64`、`u256`几种类型，目前只支持无符号整数操作。

所有类型以`field` 类型为基础进行构建。

Olang提供基于field实现的上述的各种整数类型基础libs，便于开发者编写复杂逻辑。

注：数字字面量以进制符前缀、对应数字、类型后缀三部分构成。默认为10进制field类型字面量。

```
u32 a = 2u; // u8
u64 b  = 0xffffl; // u64
u256 d = 102411ll  // u256
```

##### field类型

`field`是Olang的最基本类型，`field`变量的数据范围为`[0, p-1]`。

olaVM使用plonky2作为其后端证明系统，故`field`的素数域选择为`$p=2^{64}-2^{32}+1$`。

对于Olang开发者，`field`类型操作与整数类型一样，在overflow时需要特别注意。

```
field a = 0xff; // field
field b = 0; // field
```

##### boolean类型

bool 表示`field`的值为`0`或`1`, 使用关键字`bool`进行声明。

```
bool a = true;
bool b = false;
```
#### 复杂类型

Olang支持多种复杂类型，如`Arrays`、`Slice`、`Tuples`、`Structs`、`Enumerations`、`Map`。

##### Arrays

Olang支持静态类型数组，数组元素的数据类型必须保持一致，且数组大小须在编译期确定。

数组元素从零开始编号，使用`[index]`进行寻址访问。

数组声明是必须初始化，数组的声明格式为`type`及`[]`(`type []`)，且须指定数组大小。

提供两种数组初始化方式：
- 通过逗号分割元素列表，`[array_element1,array_element2,...]`。
- 数组元素一致的数组声明和初始化，`[array_value; size]`。

```
field[5] a = [1, 2, 3, 4, 5]; // initialize a field array with field values
bool[3] b = [true; 3]; // initialize a bool array with value true
```

二维数组

二维数组声明和使用与一维数组类似，区别在于二维数组的内部元素同时为一维数组。

声明`type [row_size][col_size]`，初始化`[[],[],...]`。

```
// Array of two elements of array of 3 elements

field[2][4] a = [[1, 2, 3, 4],[4, 5, 6, 7]];

field[4] b = a[1]; // should be [4, 5, 6, 7]
```

数组切片

与rust类似，数组的创建可以通过一个数组的切片来复制生成，`[from_index..to_index]`。
```
field[5] a = [1, 2, 3, 4, 5];
field[3] b = a[2..4];   // initialize an array copying a slice from `a`
// array b is [3, 4, 5]
```

##### Tuples

两种类型元素的集合，通过`.`(`t.0`、`t.1`)访问集合中的每个元素。

```
fn main() -> bool {
    (field[2], bool) mut v = ([1, 2], true);
    v.0 = [2, 3];
    return v.1;
}
```

##### Structs

多种数据类型的组合，构成一个新的自定义组合类型。

stuct成员通过`.` (`struct_name.struct_filed`)访问。

```
struct Person {
    age: u32,
    id: u64,
}

fn foo() {
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

为了增加代码可读性，支持为每种类型定义类型别名。

其在编译时期类型别名将会被替换成真实类型。

```
type balance = uint256;

fn main() -> balance {
    balance mut a = 32ll;
    a -= 2;
    return a;
}
```

### 常量

使用`const`关键字定义，常量只能声明为常量表达式。

编译期确定故不能被重新声明及赋值，即一旦定义，只能在其作用域范围内使用，推荐使用全部大写字母和`_`拼接进行声明。
```
const field ONE = 1;
const field TWO = ONE + ONE;

const field HASH_SIZE = 256;

fn hash_size() -> field {
    return HASH_SIZE;
}
```

### 运算符(Operators)

提供算术、逻辑、关系、位等运算符。除作用于数值的算术运算为模p，其他均为标准语义。

#### 算术运算符(Arithmetic operators)

所有算术运算符均为模p。

算术运算符与赋值运算符`=`组合后，可以组成新的复合运算符 `+=`、`-=`、`*=`、`/=`、`%=`, 算术运算符优先级高于复合运算符。

|运算符|示例|解释|
| :---:| :---:| :---: |
| + | a + b |算术加法模p |
|-| a-b |算术减法模p |
| * | a * b |算术乘法模p |
| / | a / b |算术乘逆模p |
|%| a%b |算术整数除法的模|

#### 逻辑运算符(Logical operators)

支持与(`&&`)及或(`||`)，且后者优先级高。

| 运算符 | 示例 | 解释 |
| :--- | :--- | :--- |
| && | a && b | 布尔运算符与(AND) |
| \|\| | a \|\| b | 布尔运算符或(OR) |

#### 关系运算符(Relational operators)

关系运算符的返回结果为`bool`类型

|运算符|示例|解释|
| :--- | :--- | :--- |
| == | a == b |相等|
| != | a ！= b | 不相等|
| < | a < b | 小于 |
| > | a >b  | 大于 |
|<= | a <= b  |小于等于 |
| >= | a >= b | 大于等于 | 

#### 位运算符(Bitwise operators)

所有位运算符均为模p，包含位或与非及移位操作。

|运算符|示例|解释|
| :--- | :--- | :--- |
| & | a & b |位与|
| \| | a \| b |位或|
| ^ | a ^ b |位异或(254位)|
|<<| a << 3 | 左移 |
| >> | a >> 3 | 右移 | 

位运算符与赋值运算符`=`组合后，可以组成新的复合运算符`&=`、`|=`、`^=`、`<<=`、`>>=`, 位运算符优先级高于复合运算符。

### 控制流(Control Flow)

#### 条件语句(Conditional statement)

控制条件分支，依据不同条件选择不同分支程序执行。若表达式值不为零，则执行该分支主体。

包含两种形式：

- 仅包含`if`单分支，`if conditional_expression {statements}`。
- 包含`if`及`else`多分支，`if conditional_expression {statements} else {statements}`。

```
fn foo(field a) -> field {
    
    // Similar to rust, the result of a conditional expression 
    // can be received directly by the variable
    field b = if (a + 1 == 2) { 1 } else { 3 };
    return b;
}
```
注：条件语句支持三元运算符。

```
fn foo(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

#### 循环语句(Loop statement)

依据循环头条件将循环体内语句重复执行指定的次数。

支持`for-loop`形式的循环语句，其语法构成为
`for (init_expression; conditional_expression; loop_expression) {statements}` 

其执行过程为：
- 计算`init_expression`，即循环初始化。
- 计算`conditional_expression`，若结果为`true`，则执行循环体`statements`，之后计算`loop_expression`。
- 若结果为`false`，`for-loop`语句终止。从下一条`statement`开始顺序执行。

```
fn foo() -> u32 {
    u32 mut res = 0u;
    for (u32 i = 0u; i <= 10u; i++) {
        res = res + i;
    }
    return res;
}
```

### 函数(Functions)

为Olang的基本模块单元，包含声明与语句。

使用`fn`关键字声明，须明确提供函数的名称、特性、参数、返回类型。

特性、参数及返回值可选，参数都是按值传递的。注意函数参数如果声明为`mut`类型，仍然是按值传递，只是在函数作用域内内可以改变此值。

函数返回类型必须在`->` 之后指定。

- 当函数调用发生时，程序执行控制从调用函数传递到被调用函数，通过值将参数传递给被调用函数。
- 被调用函数通过`return`语句执行返回控制到调用函数，且将返回值返回给调用函数。

基本语法形式为：

```
fn function_name(parameter_declaration_list) -> return_parameter_list {
    // compound-statement
    statements
    return_statement
}
```
示例：
```
fn foo() -> u32 {
    return sum(1u, 2u)
}

fn sum(u32 a, u32 b) -> u32 {
/* 
 *  Unlike rust, the return value of 
 *  a function must be a combination of return and return value
 */
    return a + b;  
}
```

### 导入(Imports) 

为了使用其他文件中的代码，可以使用关键字 `import` 及 `as` 将其导入到该源程序中，并带有相应的文件名称。

使用`import` 便于导入一些模块化libs，从而无需重复开发。

基本语法形式如下，其中`path-spec`可以为绝对路径(源文件全路径)及相对路径(以 `./` 或 `../` 开始的相对文件路径)。
```
import "path-spec"
import "path-spec" as alias_name
```
示例：

```
import "./math/uint256.ola";
import "crypto/sha256.ola" as sha256;
```

### 注释(Comment Lines)

为代码内文档，注释插入到代码中编译器直接忽略，仅作为辅助理解代码。

支持单行注释以 `//` 开头，及多行块注释以 `/*` 开头、以 `*/` 结尾两种方式。

单行采用`//`:
```
// Using this, we can comment a line.
fn main(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

段注释采用`/*` 及 `*/`:
```
fn sum(u32 a, u32 b) -> u32 {
/* 
 *  Unlike rust, the return value of 
 *  a function must be a combination of return and return value
*/
    return a + b;  
}
```

### 日志(Log)

Olang 支持在 OlaVM 执行期间记录对应的执行日志。

采用 `log` 关键字记录，第一个参数是格式字符串，其中每个 `{}` 占位符都替换为剩余参数中的相应值,占位符的数量必须等于参数的数量。

示例如下：
```
fn foo(u32 a, field b) {
    log("a is {}, b is {}", a, b);
}
```
默认日志在编译期被删除。可使用 `--debug` 编译选项打开便于调试程序。