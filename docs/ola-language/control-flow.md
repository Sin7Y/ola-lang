# Control Flow

## Conditional statement

Control conditional branch and select different branch programs to execute according to different conditions. If the expression value is nonzero, the branch body is executed. It comes in two forms:

* Contains only single branch`if`,`if conditional_expression {statements}`。
* Contains multiple branches of`if`and`else`,`if conditional_expression {statements} else {statements}`.

```rust
fn foo(field a) -> (field) {
    
    // Similar to rust, the result of a conditional expression 
    // can be received directly by the variable
    field b = if (a + 1 == 2) { 1 } else { 3 };
    return b;
}
```

Note: Conditional statements support ternary conditional operators.

```rust
fn foo(field a) -> (field) {
    field b = a + 1 == 2 ? 1 : 3;
    return b;
}
```

## Loop statement

Repeats the statement within the loop for a specified number of times based on the loop condition.

`for-loop`statement is supported. Its syntax is `for (init_expression; conditional_expression; loop_expression) {statements}`

The execution process is:

* Calculate the`init_expression`，namely the loop initialization.
* Calculate the`conditional_expression`.If the result is`true`,the loop body`statements`are executed, followed by the`loop_expression`.
* If the result is`false`,`for-loop`statement terminates. Sequential execution starts with the next`statement`.

```rust
fn foo() -> (u32) {
    u32 res = 0;
    for (u32 i = 0; i <= 10; i++) {
        res = res + i;
    }
    return res;
}
```

## While statement

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

## Do While statement

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
