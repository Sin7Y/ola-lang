---
description: Ola language Variables can have any name which does not start with a number.
---

# Variables

### Identifier

Variables consist of numbers (`0-9`), ASCII uppercase and lowercase letters (`a-zA-Z`), underscores (`_`). Variables cannot start with a number, and cannot use

```rust
fn foo() {
    // declare and ine `_variable`
    u32 _aBC123 = 2;   // identifiers start with "_"
    // u32 0a = 2;  define error, identifiers can't start with number
}
```

### Declaration

Variables need to be declared in order to be used. To avoid variables being undefined, it needs to be initialized at declaration time.

```rust
fn foo() {
    // declare and define `a`
    u32 a = 2;
    // redefine `a`
    a = 3;
}
```

### Scope

For security reasons, variable definitions do not support Shadowing. If you need multiple adjacent variables with similar logical meanings, use a variable or type suffix.

```rust
fn foo() {
    u32 a = 5;
    {        
        u32 a = 25; // compile error: redeclared variable 'a'
    };    
    u32 a = 25; // compile error: redeclared variable 'a'

    a = 25; // ok
}
```

Variables differ from constants in that the scope of a variable is limited to the current function itself and global variables are not supported.

```rust
fn foo() -> u32 {
    // return a; <- not allowed
    return 2;
}

fn bar() -> u32 {
    32 a = 2;
    return foo();
}
```

Variables in a `For-Loop` loop are scoped only inside the loop.

```rust
fn foo() -> u32 {
    u32 a = 0;
    for (u32 i = 0; i < 5; i++) {
        a = a + i;
    }
    // return i; <- not allowed
    return a;
}
```
