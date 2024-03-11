# Data Types

Ola is a statically typed language, and variable types must be known at compile time to avoid most runtime exceptions. Three basic types and multiple complex types are supported.

## Basic Types

Ola supports multiple basic types, including `integer` ,`field` , `boolean`, `address`,`hash`.

### **Integer Type**

There are two types of integer types: `u32` and `u256`, All types are built on the basis of the `field` type. Ola provides the above-mentioned basic libs of various integer types based on the field implementation, which is convenient for developers to write complex logic. Note: The literal quantity of a number is composed of three parts: base character prefix, corresponding number, and type suffix. The default is a decimal field type literal.

```solidity
u32 a = 2;
u256 b = 1000; 
```

### **Field Elements Type**

Ola supports the `field` type for elements of the base field of the elliptic curve. These are unsigned integers less than the modulus of the base field. The following are the smallest and largest field elements.

The `filed` type is a goldilocks field number, with a maximum value of `2^64 - 2^32 + 1`.

```solidity
field a = 32;
field b = 64;
field c = a + b;
```

The `filed` type has limited operations because it is based on elliptic curves in a finite field. It can only support basic `+` and `-` operations, as well as accept some special function return values.

### **Boolean**

Bool indicates that the value of `field` is `0` or `1`, which is declared using the keyword `bool`.

```solidity
bool a = true;
bool b = false;
```

### **Address**

The address type is an array composed of 4 fields. The address is calculated by Poseidon hash on certain inputs, and the first 4 fields of the hash return value are used as the address.

```solidity
address addr = address(0x0000000001);
address bar = 0x01CAA2EA73DF084A017D8B4BF2B046FB96F6BA897E44E3A21A29675BA2872203address
```

### **Hash**

Hash and address types are similar, both are arrays of 4 field elements.

```solidity
 string a = "helloworld";
 hash h = poseidon_hash(a);
 assert(h == 0x01CAA2EA73DF084A017D8B4BF2B046FB96F6BA897E44E3A21A29675BA2872203hash);
```

## Complex Types

Ola supports a variety of complex types such as `Arrays`, `String`, `Fields` ,`Slice`, `Tuples`,`Structs`,`Enumerations`,`Mapping`。

### Arrays

Ola supports fixed length and dynamic length array.

Array elements are numbered from zero and are accessed using`[index]`for addressing.

Arrays are passed by reference. If you modify the array in another function, those changes will be reflected in the current function. For example:

#### Fiexed Length Array

Arrays can be declared by adding \[length] to the type name, where length is a constant expression. Any type can be made into an array, including arrays themselves (also known as arrays of arrays). For example:

```solidity
contract foo {
    /// In a vote with 11 voters, do the ayes have it?
    fn f(bool[11] votes) -> (bool) {
        u32 i;
        u32 ayes = 0;

        for (i = 0; i < votes.length; i++) {
            if (votes[i]) {
                ayes += 1;
            }
        }

        // votes.length is odd; integer truncation means that 11 / 2 = 5
        return ayes > votes.length / 2;
    }
}
```

{% hint style="info" %}
The length of the array can be read with the `.length` member. The length is readonly. Arrays can be initialized with an array literal.&#x20;
{% endhint %}

For example:

```
  fn primenumber(u32 n) -> (u32) {
      u32[10] primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29];

      return primes[n];
  }
```

Any array subscript which is out of bounds (either an negative array index, or an index past the last element) will cause a runtime exception. In this example, calling `primenumber(10)` will fail; the first prime number is indexed by 0, and the last by 9.

#### Dynamatic Array

Dynamic length arrays are useful for when you do not know in advance how long your arrays will need to be. They are declared by adding `[]` to your type. How they can be used depends on whether they are contract storage variables or stored in memory.

Memory dynamic arrays must be allocated with `new` before they can be used. The `new` expression requires a single unsigned integer argument. The length can be read using `length` member variable.

```solidity
contract dynamicarray {
    fn test(u32 size) {
        u32[] a = new u32[](size);

        for (u32 i = 0; i < size; i++) {
            a[i] = 1 << i;
        }

        assert(a.length == size);
    }
}
```

Storage dynamic memory arrays do not have to be allocated. By default, they have a length of zero and elements can be added and removed using the `push()` and `pop()` methods.

```solidity
contract s {
    u32[] a;

    fn test() {
        // push takes a single argument with the item to be added
        a.push(128);
        // push with no arguments adds 0
        a.push();
        // now we have two elements in our array, 128 and 0
        assert(a.length == 2);
        a[0] |= 64;
        // pop removes the last element
        a.pop();
        // you can assign the return value of pop
        u32 v = a.pop();
        assert(v == 192);
    }
}
```

Calling the method `pop()` on an empty array is an error and contract execution will abort, just like when accessing an element beyond the end of an array.

Depending on the array element, `pop()` can be costly. It has to first copy the element to memory, and then clear storage.

#### Array Slicing

Similar to rust, arrays can be created by slicing an array to copy the generated array,`[from_index..to_index]`。

```solidity
field[5] a = [1, 2, 3, 4, 5];
field[3] b = a[2:4];   // initialize an array copying a slice from `a`
// array b is [3, 4, 5]
```

Memory dynamic arrays must be allocated with `new` before they can be used. The `new` expression requires a single unsigned integer argument. The length can be read using `length` member variable.

```solidity
u32[] b = new u32[](10);
assert(b.length == 10);
```

### **String**

`String` can be initialized with a string literal Strings can be concatenated and compared equal, no other operations are allowed on strings. string types can be converted to fields types and vice versa.

{% hint style="info" %}
&#x20;The string type currently occupies one field for each byte in the underlying virtual machine, and there may be optimizations for this in the future.
{% endhint %}

```solidity
fn test1(string s) -> (bool) {
  string str = string_concat("Hello", "World!");
  return (str == "HelloWorld!");
}
```

### **Fields**

Fields is a dynamic array representation of the filed type. fields can be concatenated using the system library provided by the ola language.

Fields types can be converted to string types and vice versa.

```solidity
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

If the `fields` variable is a storage variable, there is a `push()` and `pop()` method available to add and remove bytes from the array. Array elements in a memory `fields` can be modified, but no elements can be removed or added, in other words, `push()` and `pop()` are not available when `fields` is stored in memory.

### **Structs**

A combination of multiple data types to form a new custom combination type. Struct members are accessed via`.` (`struct_name.struct_field`).

A struct has one or more fields, each with a unique name. Structs can be function arguments and return values. Structs can contain other structs. There is a struct literal syntax to create a struct with all the fields set.

```solidity
contract deck {
    enum suit {
        club,
        diamonds,
        hearts,
        spades
    }
    enum value {
        two,
        three,
        four,
        five,
        six,
        seven,
        eight,
        nine,
        ten,
        jack,
        queen,
        king,
        ace
    }
    struct card {
        value v;
        suit s;
    }

    fn score_card(card c) -> (u32 score) {
        if (c.s == suit.hearts) {
            if (c.v == value.ace) {
                score = 14;
            }
            if (c.v == value.king) {
                score = 13;
            }
            if (c.v == value.queen) {
                score = 12;
            }
            if (c.v == value.jack) {
                score = 11;
            }
        }
        // all others score 0
    }
}
```

{% hint style="info" %}
Struct variables are references. When contract struct variables or normal struct variables are passed around, just the memory address or storage slot is passed around internally. This makes it very cheap, but it does mean that if a called function modifies the struct, then this is visible in the caller as well.
{% endhint %}

### **Enumerations**

The enumeration type is defined by the keyword `enum`. enums types need to have a definition which lists the possible values it can hold. An enum has a type name, and a list of unique values. Enum types can used in functions, but the value is represented as a `u32` in the ABI. Enum are limited to u32 values.

```solidity
contract enum_example {
    enum Weekday {
        Monday,
        Tuesday,
        Wednesday,
        Thursday,
        Friday,
        Saturday,
        Sunday
    }

    fn is_weekend(Weekday day) -> (bool) {
        return (day == Weekday.Saturday || day == Weekday.Sunday);
    }
}
```

If enum is declared in another contract, the type can be referred to with contractname.typename. The individual enum values are `contractname.typename.value`.

### **Mapping**

Mappings are a dictionary type, or associative arrays. Mappings have a number of limitations:

* They only work as storage variables
* They are not iterable
* The key cannot be a `struct`, `array`, or another mapping.

Mappings are declared with `mapping(keytype => valuetype)`, for example:

```solidity
contract b {
    struct user {
        bool exists;
        address addr;
    }
    mapping(string => user) users;

    fn add(string name, address addr) {
        // This construction is not recommended, because it requires two hash calculations.
        // See the tip below.
        users[name].exists = true;
        users[name].addr = addr;
    }

    fn get(string name) -> (address) {
        // assigning to a memory variable creates a copy
        user s = users[name];
        assert(s.exists);
        return s.addr;
    }

    fn rm(string name) {
        delete users[name];
    }
}
```

{% hint style="info" %}
When assigning multiple members in a struct in a mapping, it is better to create a storage variable as a reference to the struct, and then assign to the reference. The `add()` function above can be optimized like the following.
{% endhint %}

```solidity
fn add(string name, address addr) {
    // assigning to a storage variable creates a reference
    user storage s = users[name];
    s.exists = true;
    s.addr = addr;
}
```

If you access a non-existing field on a mapping, all the fields will read as zero. It is common practise to have a boolean field called `exists`. Since mappings are not iterable, it is not possible to `delete` an entire mapping itself, but individual mapping entries can be deleted.

{% hint style="info" %}
Solidity on Ethereum and on Polkadot takes the keccak 256 hash of the key and the storage slot, and simply uses that to find the entry. Ola used the zk-friendly posiedon hash to calculate solt.
{% endhint %}
