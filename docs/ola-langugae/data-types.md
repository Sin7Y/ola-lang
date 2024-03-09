---
description: >-
The Ola language references the syntax implementations of Solidity and Rust, removing some zk-unfriendly operations at the language level, and adding some built-in functions and data types, allowing developers to achieve efficient zkp proofs with minimal changes to their original code.
---

# Data Type

Ola is a statically typed language, and variable types must be known at compile time to avoid most runtime exceptions. Three basic types and multiple complex types are supported.

## Basic Types

Ola supports multiple basic types, including `integer` ,`field` , `boolean`, `address`,`hash`.

### **Integer Type**

There are several types of integer types: `u32`, `u64`, `u256`, and currently only `u32` integer operations are supported. All types are built on the basis of the `field` type. Ola provides the above-mentioned basic libs of various integer types based on the field implementation, which is convenient for developers to write complex logic. Note: The literal quantity of a number is composed of three parts: base character prefix, corresponding number, and type suffix. The default is a decimal field type literal.

```rust
u32 a = 2u32; // u32
u32 b = 43; // u32
u64 b = 2u64; // u64
```

### **Field Elements Type**

Ola supports the `field` type for elements of the base field of the elliptic curve. These are unsigned integers less than the modulus of the base field. The following are the smallest and largest field elements.

The `filed` type is a goldilocks field number, with a maximum value of `2^64 - 2^32 + 1`.

```rust
field a = 32field
field b = 22field
field c = a + b;
```

The `filed` type has limited operations because it is based on elliptic curves in a finite field. It can only support basic `+` and `-` operations, as well as accept some special function return values.

### **Boolean**

Bool indicates that the value of `field` is `0` or `1`, which is declared using the keyword `bool`.

```rust
bool a = true;
bool b = false;
```

### **Address**

The address type is an array composed of 4 fields. The address is calculated by Poseidon hash on certain inputs, and the first 4 fields of the hash return value are used as the address.

```rust
address addr = address(0x0000000001);
address bar = 0x01CAA2EA73DF084A017D8B4BF2B046FB96F6BA897E44E3A21A29675BA2872203address
```

### **Hash**

Hash and address types are similar, both are arrays of 4 field elements.

```rust
 string a = "helloworld";
 hash h = poseidon_hash(a);
 assert(h == 0x01CAA2EA73DF084A017D8B4BF2B046FB96F6BA897E44E3A21A29675BA2872203hash);
```

## Complex Types

Ola supports a variety of complex types such as `Arrays`, `String`, `Fields` ,`Slice`, `Tuples`,`Structs`,`Enumerations`,`Mapping`。

### **Arrays**

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

## **String**

`String` can be initialized with a string literal Strings can be concatenated and compared equal, no other operations are allowed on strings

Note: The string type currently occupies one field for each byte in the underlying virtual machine, and there may be optimizations for this in the future.

```rust
fn test1(string s) -> (bool) {
  string str = "Hello, " + s + "!";
  return (str == "Hello, World!");
}
```

## **Fields**

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

## **Tuples**

A collection of elements of two types, with each element in the collection accessed through`.`(`t.0`、`t.1`).

```rust
fn main() -> bool {
    (field[2], bool) v = ([1, 2], true);
    v.0 = [2, 3];
    return v.1;
}
```

## **Structs**

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

## **Enumerations**

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

## **Mapping**

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

## Type Alias

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