# Functions

Function is the basic module unit of Ola, containing declarations and statements. A function can be declared inside a contract, in which case it has access to the contracts contract storage variables, other contract functions etc.

If the`fn`keyword is used, the function name must be explicitly provided. parameters, and return values are optional, and parameters are passed by value.

* The function return type must be specified after`->`.
* When a function call occurs, program execution control is passed from the calling function to the called function, and the parameters are passed to the called function by value.
* The called function executes the return control to the calling function through the`return`statement, and returns the return value to the calling function.

The basic syntax is:

```solidity
fn function_name(parameter_declaration_list) -> return_parameter_list {
    // compound-statement
    statements
    return_statement
}
```

e.g.:

```solidity
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

## Internal calls and externals calls

An internal function call is executed by the current contract. This is much more efficient than an external call, which requires the address of the contract to call, whose arguments must be abi encoded (also known as serialization). Then, the runtime must set up the VM for the called contract (the callee), decode the arguments, and encode return values. Lastly, the first contract (the caller) must decode return values.

## Calling an external function using call()

If you call a function on a contract, then the function selector and any arguments are ABI encoded for you, and any return values are decoded. Sometimes it is useful to call a function without abi encoding the arguments.

You can call a contract directly by using the `call()` method on the address type. This takes a single argument, which should be the ABI encoded arguments. The return values are a `boolean` which indicates success if true, and the ABI encoded return value in `fields`.

```solidity
contract B {
    fn foo(u32 a, u32 b) -> (u32) {
        return a + b;
    }
}
```

```solidity
import "./contractB.ola"
contract A {
    fn test(B v) {

        // Note that the signature is only hashed and not parsed. So, ensure that the
        // arguments are of the correct type.
        fields data = abi.encodeWithSignature(
            "foo(u32,u32)",
            3,
           5
        );

         fields rawresult = address(v).call(data);

        u32 res = abi.decode(rawresult, (u32));

        assert(res == 8);
    }
}

```

## Calling an external function using delegatecall

External functions can also be called using `delegatecall`. The difference to a regular `call` is that `delegatecall` executes the callee code in the context of the caller:

- The callee will read from and write to the caller storage.
- `caller address` does not change; it stays the same as in the callee.

```solidity
fn delegate(
    address callee,
    fields input
) -> (fields result) {
    result = callee.delegatecall(input);
		return result;
}
```

