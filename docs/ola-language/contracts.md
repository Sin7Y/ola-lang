# Contracts

Contracts in Ola are similar to Solidity languages. Each contract can contain declarations of `State Variables`, `Functions`,  `Events`,  `Struct Types` and `Enum Types`. 

There are also special kinds of contracts called `libraries` and `interface`.

The section about  contracts contains more details than this section, which serves to provide a quick overview.

## State Variables

State variables are variables whose values are permanently stored in contract storage.

```solidity
contract SimpleStorage {
    u32 storedData; // State variable
    // ...
}
```

## Functions

Functions are the executable units of code. Functions are usually defined inside a contract.

```solidity
contract SimpleAuction {
    fn bid() { // Function
        // ...
    }
}
```

 Functions accept `parameters` and `return` variables to pass parameters and values between them.

## Events

Events are convenience interfaces with the Ola logging facilities.

```solidity
contract SimpleAuction {
	event HighestBidIncreased(address bidder, u32 amount); // Event
    fn bid() {
        // ...
        emit HighestBidIncreased(original_address(), 1); // Triggering event
    }
}
```

## Struct Types

Structs are custom defined types that can group several variables 

```solidity
contract Ballot {
    struct Voter { // Struct
        u32 weight;
        bool voted;
        address delegate;
        u32 vote;
    }
}
```

## Enum Types

Enums can be used to create custom types with a finite set of  constant values

```solidity
contract Purchase {
    enum State { Created, Locked, Inactive } // Enum
}
```

