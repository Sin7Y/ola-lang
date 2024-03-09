
# Functions

Function is the basic module unit of Ola, containing declarations and statements.

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