# Comment Lines

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