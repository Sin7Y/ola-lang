# 👀 Ola Examples

Ola contracts allow users to write complex business logic that will be deployed to Ola's l2 network, and cross-contract calls can be written between different contracts just like solidity and rust.

## Fibonacci

The following example shows a recursive and non-recursive ola smart contract implementation of Fibonacci numbers.

```solidity

contract Fibonacci {

    fn main() {
       fib_non_recursive(10);
    }

    fn fib_recursive(u32 n) -> (u32) {
        if (n <= 2) {
            return 1;
        }
        return fib_recursive(n -1) + fib_recursive(n -2);
    }

    fn fib_non_recursive(u32 n) -> (u32) {
        u32 first = 0;
        u32 second = 1;
        u32 third = 1;
        for (u32 i = 2; i <= n; i++) {
             third = first + second;
             first = second;
             second = third;
        }
        return third;
    }

}

```

## Person

The following shows a simple book contract that contains a book structure, assigns a value to the book structure and reads the status of the book.

```solidity


contract BookExample {
    struct Book {
        u32 book_id;
        string book_name;
        string author;
    }

    event BookCreated(u32 indexed id, string indexe name, string author);

    fn createBook(u32 id, string name) -> (Book) {
        Book myBook = Book({
            book_name: name,
            book_id: id,
            author: "peter"
        });
        emit BookCreated(id, name, "peter");
        return myBook;
    }

    fn getBookName(Book _book) -> (string) {
        return _book.book_name;
    }

    fn getBookId(Book _book) -> (u32) {
        u32 b = _book.book_id + 1;
        return b;
    }

}

```

## Cross-contract invocation

The following example demonstrates the usage of cross-contract invocation.

**Caller contract**

```solidity

contract Caller {
    u32 num;


    fn delegatecall_test(address _contract) {
        u32 set_data = 66;
        fields call_data = abi.encodeWithSignature("setVars(u32)", set_data);
        _contract.delegatecall(call_data);
        assert(num == 66);
    }

    fn call_test(address _contract) {
        u32 a = 100;
        u32 b = 200;
        fields call_data = abi.encodeWithSignature("add(u32,u32)", a, b);
        fields memory data = _contract.call(call_data);
        u32 result = abi.decode(data, (u32));
        assert(result == 300);
    }
}
```

**Callee contract**

```solidity
contract Callee {
    u32 num;

    fn setVars(u32 data)  {
        num = data;
    }

    fn add(u32 a, u32 b) -> (u32) {
        return a + b;
    }
}

```

## Multiple files&#x20;

For better project organisation and clearer logic, it is common to split the contents of a file into multiple files. ola language supports the import of another contract within a contract through the `import` keyword.

An example of a multi-file contract is shown below.

**Contract RectangularCalculator**

```solidity

contract RectangularCalculator {
  
    fn rectangle(u32 w, u32 h) -> (u32 s, u32 p) {
        s = w * h;
        p = 2 * (w + h);
        // Returns a variable with the same name, return can be ignore
        //return (s, p)
    }
}

```

**Contract ShapeCalculator**

```solidity

contract SquareCalculator {

    fn square(u32 w) -> (u32 s, u32 p) {
        s = w * w;
        p = 4 * w;
        return (s, p);
    }
}

```

**Contract Calculator**

```solidity

import "./RectangularCalculator.ola";
import "./SquareCalculator.ola";

contract Calculator {
  
    fn sum(u32 w, u32 h) -> (u32 s, u32 p) {
        (u32 rectangle_s, u32  rectangle_p) = rectangle(w, h);
        (u32 square_s, u32 square_p) = square(w);
        return (rectangle_s + square_s, rectangle_p + square_p);
    }
}

```
