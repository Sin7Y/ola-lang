---
description: >-
  The Ola language references the syntax implementations of Solidity and Rust,
  removing some zk-unfriendly operations at the language level, and adding some
  built-in functions and data types, allowing d
---

# 👏 Ola Language

## Data Type

Ola is a statically typed language, and variable types must be known at compile time to avoid most runtime exceptions. Three basic types and multiple complex types are supported.

### Basic Types

Ola supports multiple basic types, including `integer` ,`field` , `boolean`, `address`,`hash`.

#### **Integer Type**

There are several types of integer types: `u32`, `u64`, `u256`, and currently only `u32` integer operations are supported. All types are built on the basis of the `field` type. Ola provides the above-mentioned basic libs of various integer types based on the field implementation, which is convenient for developers to write complex logic. Note: The literal quantity of a number is composed of three parts: base character prefix, corresponding number, and type suffix. The default is a decimal field type literal.

```rust
u32 a = 2u32; // u32
u32 b = 43; // u32
u64 b = 2u64; // u64
```

#### **Field Elements Type**

Ola supports the `field` type for elements of the base field of the elliptic curve. These are unsigned integers less than the modulus of the base field. The following are the smallest and largest field elements.

The `filed` type is a goldilocks field number, with a maximum value of `2^64 - 2^32 + 1`.

```rust
field a = 32field
field b = 22field
field c = a + b;
```

The `filed` type has limited operations because it is based on elliptic curves in a finite field. It can only support basic `+` and `-` operations, as well as accept some special function return values.

#### **Boolean**

Bool indicates that the value of `field` is `0` or `1`, which is declared using the keyword `bool`.

```rust
bool a = true;
bool b = false;
```

#### **Address**

The address type is an array composed of 4 fields. The address is calculated by Poseidon hash on certain inputs, and the first 4 fields of the hash return value are used as the address.

```rust
address addr = address(0x0000000001);
address bar = 0x01CAA2EA73DF084A017D8B4BF2B046FB96F6BA897E44E3A21A29675BA2872203address
```

#### **Hash**

Hash and address types are similar, both are arrays of 4 field elements.

```rust
 string a = "helloworld";
 hash h = poseidon_hash(a);
 assert(h == 0x01CAA2EA73DF084A017D8B4BF2B046FB96F6BA897E44E3A21A29675BA2872203hash);
```

### Complex Types

Ola supports a variety of complex types such as `Arrays`, `String`, `Fields` ,`Slice`, `Tuples`,`Structs`,`Enumerations`,`Mapping`。

#### **Arrays**

Ola supports statically typed arrays. The data types of array elements must be consistent, and the array size must be determined at compile time.

Array elements are numbered from zero and are accessed using`[index]`for addressing.

Array declarations must be initialized, and the array declaration format is为`type`and`[]`(`type []`),and the array size must be specified. Two ways to initialize arrays are provided:

* Split the list of elements by commas,`[array_element1,array_element2,...]`。
* Array declaration and initialization with consistent array elements,`[array_value; size]`。

```rust
field[5] a = [1, 2, 3, 4, 5]; // initialize a field array with field values
bool[3] b = [true; 3]; // initialize a bool array with value true
```

Two-dimensional Arrays

Two-dimensional arrays are declared and used similarly to one-dimensional arrays, except that the internal elements of a two-dimensional array are also one-dimensional arrays.

Declar`type [row_size][col_size]`, and initializ`[[],[],...]`。

```rust
// Array of two elements of array of 3 elements

field[2][4] a = [[1, 2, 3, 4],[4, 5, 6, 7]];

field[4] b = a[1]; // should be [4, 5, 6, 7]
```

Array Slicing

Similar to rust, arrays can be created by slicing an array to copy the generated array,`[from_index..to_index]`。

```rust
field[5] a = [1, 2, 3, 4, 5];
field[3] b = a[2..4];   // initialize an array copying a slice from `a`
// array b is [3, 4, 5]
```

Memory dynamic arrays must be allocated with `new` before they can be used. The `new` expression requires a single unsigned integer argument. The length can be read using `length` member variable.

```rust
u32[] b = new u32[](10);
assert(b.length == 10);
```

**String**

`String` can be initialized with a string literal Strings can be concatenated and compared equal, no other operations are allowed on strings

Note: The string type currently occupies one field for each byte in the underlying virtual machine, and there may be optimizations for this in the future.

```rust
fn test1(string s) -> (bool) {
  string str = "Hello, " + s + "!";
  return (str == "Hello, World!");
}
```

**Fields**

Fields is a dynamic array representation of the filed type. fields can be concatenated using the system library provided by the ola language.

Fields types can be converted to string types and vice versa.

```rust
fn fields_concat_test() -> (fields){
   string a = "ola";
   string b = "vm";
   fields a_b = fields_concat(fields(a), fields(b));
   return a_b;
}

fn encode_test() -> (fields) {
	fields call_data = abi.encodeWithSignature("setVars(u32)", 12);
	return call_data;
}
```

**Tuples**

A collection of elements of two types, with each element in the collection accessed through`.`(`t.0`、`t.1`).

```rust
fn main() -> bool {
    (field[2], bool) v = ([1, 2], true);
    v.0 = [2, 3];
    return v.1;
}
```

**Structs**

A combination of multiple data types to form a new custom combination type. Struct members are accessed via`.` (`struct_name.struct_field`)

```rust
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

**Enumerations**

The enumeration type is defined by the keyword `enum`.

```rust
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
```

**Mapping**

Mappings are a dictionary type, or associative arrays. Mappings have a number of limitations:

* They only work as storage variables
* They are not iterable
* The key cannot be a `struct`, array, or another mapping.

Mappings are declared with `mapping(keytype => valuetype)`, for example:

```rust
struct user {
    bool exists;
    address addr;
}
mapping(string => user) users;
```

### Type Alias

To increase code readability, defining a type alias for each type is supported. At compile time, the type alias will be replaced with real types.

```rust
type balance = u256;

fn main() -> balance {
    balance a = 32ll;
    a -= 2;
    return a;
}
```

## Constant

Constants can only be declared as constant expressions when defined with the `const` keyword.

Compile time determination cannot be redeclared and assigned, that is, once defined, it can only be used within its scope, and it is recommended to declare with all capital letters and `_` concatenation.

```rust
const field ONE = 1;
const field TWO = ONE + ONE;

const field HASH_SIZE = 256;

fn hash_size() -> field {
    return HASH_SIZE;
}
```

## Operators

Provides operators such as arithmetic, logic, relational, bits, and so on. Except for the arithmetic operation acting on numerical values, which is Mod p, all others are standard semantics.

### Arithmetic operators

All arithmetic operators are Mod p.

Arithmetic operators can be combined with the assignment operator`=`to form new compound operators `+=`、`-=`、`*=`、`/=`、`%=`, with arithmetic operators having higher priority than compound operators.

| Operat | Example |                 Explanation                |
| :----: | :-----: | :----------------------------------------: |
|    +   |  a + b  |        Arithmetic addition modulo p        |
|    -   |   a-b   |       Arithmetic subtraction modulo p      |
|   \*   |  a \* b |     Arithmetic multiplication modulo p     |
|    /   |  a / b  | Arithmetic multiplication inverse modulo p |
|    %   |   a%b   |  The modulo of arithmetic integer division |
|  \*\*  |  a\*\*b |               Power modulo p               |

### Boolean operators

Support with AND(`&&`)as well as OR(`||`),with the latter having higher priority.

| Operator | Example  | Explanation                |
| -------- | -------- | -------------------------- |
| &&       | a && b   | Boolean operator and (AND) |
| \|\|     | a \|\| b | Boolean operator or (OR)   |
| !        | ! a      | Boolean operator NEGATION  |

### Relational operators

The return result of the relational operator is type`bool`

| Operator | Example | Explanation              |
| -------- | ------- | ------------------------ |
| ==       | a == b  | equal                    |
| !=       | a ！= b  | not equal                |
| <        | a < b   | less than                |
| >        | a >b    | greater than             |
| <=       | a <= b  | less than or equal to    |
| >=       | a >= b  | greater than or equal to |

### Bitwise operators

All bitwise operators are modulo p, containing bit or and non and shift operations.

| Operator | Example | Explanation        |
| -------- | ------- | ------------------ |
| &        | a & b   | bit and            |
| \|       | a \| b  | bit or             |
| ^        | a ^ b   | XOR 32 bits        |
| <<       | a << 3  | shift left         |
| >>       | a >> 3  | shift right        |
| \~       | \~a     | Complement 32 bits |

Bitwise operators can be combined with the assignment operator`=`to form the new compound operators`&=`、`|=`、`^=`、`<<=`、`>>=`, with bitwise operators taking precedence over compound operators.

## Control Flow

### Conditional statement

Control conditional branch and select different branch programs to execute according to different conditions. If the expression value is nonzero, the branch body is executed. It comes in two forms:

* Contains only single branch`if`,`if conditional_expression {statements}`。
* Contains multiple branches of`if`and`else`,`if conditional_expression {statements} else {statements}`.

```rust
fn foo(field a) -> field {
    
    // Similar to rust, the result of a conditional expression 
    // can be received directly by the variable
    field b = if (a + 1 == 2) { 1 } else { 3 };
    return b;
}
```

Note: Conditional statements support ternary conditional operators.

```rust
fn foo(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

### Loop statement

Repeats the statement within the loop for a specified number of times based on the loop condition.

`for-loop`statement is supported. Its syntax is `for (init_expression; conditional_expression; loop_expression) {statements}`

The execution process is:

* Calculate the`init_expression`，namely the loop initialization.
* Calculate the`conditional_expression`.If the result is`true`,the loop body`statements`are executed, followed by the`loop_expression`.
* If the result is`false`,`for-loop`statement terminates. Sequential execution starts with the next`statement`.

```rust
fn foo() -> u32 {
    u32 res = 0u;
    for (u32 i = 0u; i <= 10u; i++) {
        res = res + i;
    }
    return res;
}
```

### While statement

Repeated execution of a block can be achieved using while. It syntax is similar to if, however the block is repeatedly executed until the condition evaluates to false. If the condition is not true on first execution, then the loop body is never executed:

```rust
contract Foo {
    fn foo(u32 n) {
        while (n >= 10) {
            n -= 1;
        }
    }
}
```

It is possible to terminate execution of the while statement by using the `break` statement. Execution will continue to next statement in the function. Alternatively, `continue` will cease execution of the block, but repeat the loop if the condition still holds:

```rust

  fn bar(u32 n) -> (bool) {
        return false;
   }
   
  fn foo(u32 n) {
      while (n >= 10) {
          n--;

          if (n >= 100) {
              // do not execute the if statement below, but loop again
              continue;
          }

          if (bar(n)) {
              // cease execution of this while loop and jump to the "n = 102" statement
              break;
          }

          // only executed if both if statements were false
          print("neither true");
      }

      n = 102;
  }

```

### Do While statement

A `do { ... } while (condition);` statement is much like the `while (condition) { ... }` except that the condition is evaluated after executing the block. This means that the block is always executed at least once, which is not true for `while` statements:

```rust
fn foo(u32 n) {
        do {
            n--;
            if (n >= 100) {
                // do not execute the if statement below, but loop again
                continue;
            }

            if (bar(n)) {
                // cease execution of this while loop and jump to the "n = 102" statement
                break;
            }
        } while (n > 10);

        n = 102;
    }
```

## Functions

It is the basic module unit of Ola, containing declarations and statements.

If the`fn`keyword is used, the function name must be explicitly provided. parameters, and return values are optional, and parameters are passed by value.

* The function return type must be specified after`->`.
* When a function call occurs, program execution control is passed from the calling function to the called function, and the parameters are passed to the called function by value.
* The called function executes the return control to the calling function through the`return`statement, and returns the return value to the calling function.

The basic syntax is:

```rust
fn function_name(parameter_declaration_list) -> return_parameter_list {
    // compound-statement
    statements
    return_statement
}
```

e.g.:

```rust
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

## Prophet Fuctions

Ola supports the "prophet" function, which utilizes prophet features to make previously difficult-to-prove but easy-to-verify computation processes now easily provable and verifiable, improving ZK circuit proof efficiency.

The following demonstrates the usage of the `u32_sqrt` prophet function supported by ola.

```rust
  fn sqrt_test(u32 n) -> (u32) {
      u32 b = u32_sqrt(n);
      return b;
  }
```

We can also use the Ola language to implement a simplified version of the sqrt function.

```rust
  // native approach
  fn sqrt_test(u32 a) -> (u32) {
      u32 result = 0;
      if (a > 3) {
          result = a;
          u32 x = a / 2 + 1;
          // assume the maximum iteration is 100
          for (u32 i = 0; i < 100; i++) {
              if (x >= result) break;
              result = x;
              x = (a / x + x) / 2;
          }
      } else if (a != 0) {
          result = 1;
      }
      return result;
  }
```

The efficiency comparison of circuit proof generated by using the Ola Prophet method and directly written in Ola language for sqrt is as follows:

![prophet\_benchmark](../.gitbook/assets/prophet\_benchmark.png)

## Core Functions

The goal of the Ola-lang high-level language library is to provide a set of high-level APIs that can be used to quickly develop applications. The Core lib functions provides commonly used functions and modules, such as Ola Standard Library, integer type operations, math calculations, `assert` function , `print` function , which can greatly improve the development efficiency of programmers.

<table><thead><tr><th width="238">function name</th><th>Params</th><th>returns</th><th>Usage</th></tr></thead><tbody><tr><td>assert</td><td>bool</td><td></td><td>assert(a == b);</td></tr><tr><td>u32_array_sort</td><td>u32 array</td><td>sorted array</td><td>u32_array_sort([2, 1, 3, 4]);</td></tr><tr><td>print</td><td>all type value</td><td></td><td>print(var_a) ;</td></tr><tr><td>caller_address</td><td></td><td>contract caller address</td><td>address caller = caller_address()</td></tr><tr><td>origin_address</td><td></td><td>contract origin caller address</td><td>address origin = origin_address()</td></tr><tr><td>code_address</td><td></td><td>current execute code contract address</td><td>address code_addr = code_address()</td></tr><tr><td>current_address</td><td></td><td>current state write and read contract address</td><td>address state_addr = current_address()</td></tr><tr><td>poseidon_hash</td><td>string/ fields</td><td>hash type</td><td>hash CREATE2_PREFIX = poseidon_hash("OlaCreate2");</td></tr><tr><td>chain_id</td><td></td><td>u32 (The future may be replaced by other data types.</td><td>u32 chainID = chain_id();</td></tr><tr><td>fields_concat</td><td>fields a and fields b</td><td>new fields</td><td>fields ret = fields_concat(a, b);</td></tr><tr><td>abi.encode</td><td>various types of uncertain quantities</td><td>fields</td><td>fields encode_value = abi.encode(a, b);</td></tr><tr><td>abi.decode</td><td>fields data wtih various types</td><td>tuple with all type value</td><td>u32 result = abi.decode(data, (u32));</td></tr><tr><td>abi.encodeWithSignature</td><td>String function selector and params</td><td>fields</td><td>fields call_data = abi.encodeWithSignature("add(u32,u32)", a, b);</td></tr><tr><td>block_number</td><td></td><td>u32</td><td>u32 blocknumber = block_number()</td></tr><tr><td>block_timestamp</td><td></td><td>u32</td><td>u32 time = block_timestamp()</td></tr><tr><td></td><td></td><td></td><td></td></tr><tr><td>sequence_address</td><td></td><td>address</td><td>address sequencer = sequence_address()</td></tr><tr><td>tx_version </td><td></td><td>u32</td><td>u32 version = tx_version()</td></tr><tr><td>nonce</td><td></td><td>u32</td><td>u32 nonce_number = nonce();</td></tr><tr><td>tx_hash</td><td></td><td>hash</td><td>hash h = tx_hash()</td></tr><tr><td>get_selector</td><td>string literal</td><td>u32 </td><td>u32 func_selector = get_selector()</td></tr><tr><td>signatrue</td><td></td><td>fields</td><td>fields sig = signatrue();</td></tr><tr><td>check_ecdsa</td><td>(message hash , pk,  sig)</td><td>bool</td><td>bool verify = check_ecdsa(h, pk, sig);</td></tr></tbody></table>



## Comment Lines

They are in-code documentation. When comments are inserted into the code, the compiler simply ignores them. Comment lines only serve as an aid in understanding the code.

ingle-line comments start with `//` and multi-line paragraph comments start with `/*` and end with `*/` .

Single line using`//`:

```rust
// Using this, we can comment a line.
fn main(field a) -> field {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

Multi-line paragraph comments using`/*` 及 `*/`:

```rust
fn sum(u32 a, u32 b) -> u32 {
/* 
 *  Unlike rust, the return value of 
 *  a function must be a combination of return and return value
*/
    return a + b;  
}
```

### Imports

In order to use the code from other files, we can import them into our program using the keyword `import` and `as`with the corresponding file name. Using `import` makes it easier for us to import some modular ibs, eliminating the need for repeated development. The basic syntax is as follow,`path-spec`can be absolute path(the full path of source file) or relative path (file path starts with`./` or `../`).

```rust
import "path-spec"
```

e.g.:

```rust
import "./math/u256.ola";
import "crypto/sha256.ola"
import "erc20.ola"
```

## 🚧 Features TODO

### More core libraries

The currently supported core libraries include u64 operation library, u256 operation library, signature and verification library.

### Contract event

Contract events can help users debug contracts and facilitate communication between layer2 and layer1.
