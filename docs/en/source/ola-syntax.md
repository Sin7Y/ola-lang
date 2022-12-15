# Olang Syntax

### Variables

#### Identifier

Variables consist of numbers (`0-9`), ASCII uppercase and lowercase letters (`a-zA-Z`), underscores (`_`).
Variables cannot start with a number, and cannot use 


```
fn foo() {
    // declare and ine `_variable`
    u32 _aBC123 = 2u;   // identifiers start with "_"
    // u32 0a = 2u;  define error, identifiers can't start with number
}
```

#### Declaration

Variables need to be declared in order to be used. To avoid variables being undefined, it needs to be initialized at declaration time. 

```
fn foo() {
    // declare and define `a`
    field a = 2f;
    // redefine `a`
    a = 3f;
}
```

#### Scope

For security reasons, variable definitions do not support Shadowing. 
If you need multiple adjacent variables with similar logical meanings, use a variable or type suffix.

```
fn foo() {
    field a = 5;
    {        
        field a = 25; // compile error: redeclared variable 'a'
    };    
    field a = 25; // compile error: redeclared variable 'a'

    a = 25; // ok
}
```
Variables differ from constants in that the scope of a variable is limited to the current function itself and global variables are not supported.

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

Variables in a `For-Loop` loop are scoped only inside the loop.

```
fn foo() -> u32 {
    u32 a = 0;
    for (u32 i = 0; i < 5; i++) {
        a = a + i;
    }
    // return i; <- not allowed
    return a;
}
```

### Data Type

Olang is a statically typed language, and variable types must be known at compile time to avoid most runtime exceptions. 
Three basic types and multiple complex types are supported.

#### Basic Types

There are three types of basic types, namely integer, field and Boolean

##### Integer Type

There are several types of integer types: `u32`, `u64`, and `u256`, and currently only unsigned integer operations are supported. 
All types are built on the basis of the `field` type.
Olang provides the above-mentioned basic libs of various integer types based on the field implementation, which is convenient for developers to write complex logic.
Note: The literal quantity of a number is composed of three parts: base character prefix, corresponding number, and type suffix. The default is a decimal field type literal. 

```
u32 a = 2u; // u8
field b = 2;
u64 b  = 0xffffl; // u64
u256 d = 102411ll  // u256
```

##### Field
`Field` is the most basic type of Olang, and the data range of the `field` variable is `[0, p-1]`.
The olaVM uses plonky2 as its back-end proof system, so the `field` of prime is selected as `$p=2^{64}-2^{32}+1$`. 
For Olang developers, `field` type operations, like integer types, require special attention when overflowing.

```
field a = 0xff; // field
field b = 0; // field
```

##### Boolean

Bool indicates that the value of `field` is `0` or `1`, which is declared using the keyword `bool`.
```
bool a = true;
bool b = false;
```
#### Complex Types

Olang supports a variety of complex types such as`Arrays`,`Slice`,`Tuples`,`Structs`,`Enumerations`,`Map`。

##### Arrays

Olang supports statically typed arrays. The data types of array elements must be consistent, and the array size must be determined at compile time. 

Array elements are numbered from zero and are accessed using`[index]`for addressing.

Array declarations must be initialized, and the array declaration format is为`type`and`[]`(`type []`),and the array size must be specified.
Two ways to initialize arrays are provided:
- Split the list of elements by commas,`[array_element1,array_element2,...]`。
- Array declaration and initialization with consistent array elements,`[array_value; size]`。

```
field[5] a = [1, 2, 3, 4, 5]; // initialize a field array with field values
bool[3] b = [true; 3]; // initialize a bool array with value true
```

Two-dimensional Arrays

Two-dimensional arrays are declared and used similarly to one-dimensional arrays, except that the internal elements of a two-dimensional array are also one-dimensional arrays. 

Declar`type [row_size][col_size]`, and initializ`[[],[],...]`。

```
// Array of two elements of array of 3 elements

field[2][4] a = [[1, 2, 3, 4],[4, 5, 6, 7]];

field[4] b = a[1]; // should be [4, 5, 6, 7]
```

Array Slicing

Similar to rust, arrays can be created by slicing an array to copy the generated array,`[from_index..to_index]`。
```
field[5] a = [1, 2, 3, 4, 5];
field[3] b = a[2..4];   // initialize an array copying a slice from `a`
// array b is [3, 4, 5]
```

##### Tuples

A collection of elements of two types, with each element in the collection accessed through`.`(`t.0`、`t.1`).

```
fn main() -> bool {
    (field[2], bool) v = ([1, 2], true);
    v.0 = [2, 3];
    return v.1;
}
```

##### Structs
A combination of multiple data types to form a new custom combination type. 
Struct members are accessed via`.` (`struct_name.struct_field`)

```
struct Person {
    age: u32,
    id: u64,
}

fn foo() {
   Person person = Person {
        age: 18,
        id: 123456789,
    };
    person.age = 25;
}
```

##### Enumerations

The enumeration type is defined by the keyword `enum`.

````
contract Foo {
    u256 const x = 56;
    enum ActionChoices {
        GoLeft,
        GoRight,
        GoStraight,
        Sit
    }
    ActionChoices const choices = ActionChoices.GoLeft;
}
````

##### Map

TODO

#### Type Alias

To increase code readability, defining a type alias for each type is supported.
At compile time, the type alias will be replaced with real types.

```
type balance = uint256;

fn main() -> balance {
    balance a = 32ll;
    a -= 2;
    return a;
}
```

### Constant

Constants can only be declared as constant expressions when defined with the `const` keyword.

Compile time determination cannot be redeclared and assigned, that is, once defined, it can only be used within its scope, and it is recommended to declare with all capital letters and `_` concatenation. 
```
const field ONE = 1;
const field TWO = ONE + ONE;

const field HASH_SIZE = 256;

fn hash_size() -> field {
    return HASH_SIZE;
}
```

### Operators

Provides operators such as arithmetic, logic, relational, bits, and so on. Except for the arithmetic operation acting on numerical values, which is Mod p, all others are standard semantics. 

#### Arithmetic operators

All arithmetic operators are Mod p.

Arithmetic operators can be combined with the assignment operator`=`to form new compound operators `+=`、`-=`、`*=`、`/=`、`%=`, with arithmetic operators having higher priority than compound operators. 

| Operat |Example|Explanation|
|:---:| :--:| :---: |
|  +  | a + b |Arithmetic addition modulo p |
|  -  | a-b |Arithmetic subtraction modulo p |
|  *  | a * b |Arithmetic multiplication modulo p |
|  /  | a / b |Arithmetic multiplication inverse modulo p |
|  %  | a%b |The modulo of arithmetic integer division|
| **  | a**b |Power modulo p|

#### Boolean operators

Support with AND(`&&`)as well as OR(`||`),with the latter having higher priority.

| Operator | Example | Explanation |
| :--- | :--- | :--- |
| && | a && b | Boolean operator and (AND) |
| \|\| | a \|\| b | Boolean operator or (OR) |
| ! | ! a | Boolean operator NEGATION |

#### Relational operators

The return result of the relational operator is type`bool`

|Operator|Example|Explanation|
| :--- | :--- | :--- |
| == | a == b |equal|
| != | a ！= b | not equal|
| < | a < b | less than |
| > | a >b  | greater than |
|<= | a <= b  |less than or equal to |
| >= | a >= b | greater than or equal to | 

#### Bitwise operators

All bitwise operators are modulo p, containing bit or and non and shift operations.

|Operator|Example|Explanation|
| :--- | :--- | :--- |
| & | a & b |bit and|
| \| | a \| b |bit or|
| ^ | a ^ b |XOR 32 bits|
|<<| a << 3 | shift left |
| >> | a >> 3 | shift right |
| ~ | ~a | Complement 32  bits |

Bitwise operators can be combined with the assignment operator`=`to form the new compound operators`&=`、`|=`、`^=`、`<<=`、`>>=`, with bitwise operators taking precedence over compound operators. 

### Control Flow

#### Conditional statement

Control conditional branch and select different branch programs to execute according to different conditions. If the expression value is nonzero, the branch body is executed.
It comes in two forms:

- Contains only single branch`if`,`if conditional_expression {statements}`。
- Contains multiple branches of`if`and`else`,`if conditional_expression {statements} else {statements}`.

```
fn foo(field a) -> field {
    
    // Similar to rust, the result of a conditional expression 
    // can be received directly by the variable
    field b = if (a + 1 == 2) { 1 } else { 3 };
    return b;
}
```
Note: Conditional statements support ternary conditional operators.

```
fn foo(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

#### Loop statement

Repeats the statement within the loop for a specified number of times based on the loop condition.

`for-loop`statement is supported. Its syntax is
`for (init_expression; conditional_expression; loop_expression) {statements}` 

The execution process is:
- Calculate the`init_expression`，namely the loop initialization.
- Calculate the`conditional_expression`.If the result is`true`,the loop body`statements`are executed, followed by the`loop_expression`.
- If the result is`false`,`for-loop`statement terminates. Sequential execution starts with the next`statement`.

```
fn foo() -> u32 {
    u32 res = 0u;
    for (u32 i = 0u; i <= 10u; i++) {
        res = res + i;
    }
    return res;
}
```

### Functions

It is the basic module unit of Olang, containing declarations and statements.

If the`fn`keyword is used, the function name must be explicitly provided. parameters, and return values are optional, and parameters are passed by value.

The function return type must be specified after`->`.

- - When a function call occurs, program execution control is passed from the calling function to the called function, and the parameters are passed to the called function by value. 
- The called function executes the return control to the calling function through the`return`statement, and returns the return value to the calling function.

The basic syntax is:

```
fn function_name(parameter_declaration_list) -> return_parameter_list {
    // compound-statement
    statements
    return_statement
}
```
e.g.:
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

### Imports

In order to use the code from other files, we can import them into our program using the keyword `import` and `as`with the corresponding file name.
Using `import` makes it easier for us to import some modular ibs, eliminating the need for repeated development.
The basic syntax is as follow,`path-spec`can be absolute path(the full path of source file) or relative path (file path starts with`./` or `../`).
```
import "path-spec"
import "path-spec" as alias_name
```
e.g.:

```
import "./math/uint256.ola";
import "crypto/sha256.ola" as sha256;
```

### Comment Lines

They are in-code documentation. When comments are inserted into the code, the compiler simply ignores them. Comment lines only serve as an aid in understanding the code.

ingle-line comments start with `//` and multi-line paragraph comments start with `/*` and end with `*/` .

Single line using`//`:
```
// Using this, we can comment a line.
fn main(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

Multi-line paragraph comments using`/*` 及 `*/`:
```
fn sum(u32 a, u32 b) -> u32 {
/* 
 *  Unlike rust, the return value of 
 *  a function must be a combination of return and return value
*/
    return a + b;  
}
```
