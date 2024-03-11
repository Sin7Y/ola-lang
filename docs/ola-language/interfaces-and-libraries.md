# Interfaces and Librariese

## Interfaces

An interface is a contract sugar type with restrictions. This type cannot be instantiated; it can only define the functions prototypes for a contract. This is useful as a generic interface.

```solidity
interface Operator {
    fn performOperation(u32 a, u32 b) -> (u32);
}
```

```solidity
import "./operator.ola"
contract Ferqu {
    Operator public operator;
    
    // Function to calculate the result of the operation performed by the chosen operator.
    fn calculate(u32 a, u32 b) -> (u32) {
        return operator.performOperation(a, b);
    }
}
```

* No contract storage variables can exist (however constants are allowed)
* No function can have a body or implementation

## Libraries

Libraries are a special type of contract which can be reused in multiple contracts. Functions declared in a library can be called with the `library.function()` syntax. When the library has been imported or declared, any contract can use its functions simply by using its name.

```solidity
library MathLib {
    fn add(u32 a, u32 b) -> (u32) {
        return a + b;
    }

    fn sub(u32 a, u32 b) -> (u32) {
        return a - b;
    }
}
```

```solidity
import "./MathLib.ola";

contract ContractB {
    fn setStructB()  {
        u32 result = MathLib.add(1, 2);
        print(result);
    }
}

```

{% hint style="info" %}
When using the Ethereum Foundation Solidity compiler, libraries are a special contract type and are called using delegatecall.Ola statically links the library calls into your contract code. This generates larger contract code, however it reduces the call overhead and make it possible to do compiler optimizations across library and contract code.
{% endhint %}
