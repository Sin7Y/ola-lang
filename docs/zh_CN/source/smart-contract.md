# Smart contracts

Ola contracts allow users to write complex business logic that will be deployed to ola's l2 network, 
and cross-contract calls can be written between different contracts just like solidity

## Examples 

### 
The following example shows a recursive and non-recursive ola smart contract implementation of Fibonacci numbers

````javascript

contract Fibonacci {
    u32 num;
    fn fib_recursive(u32 n) -> (u32){
        num += 1;
        if (n == 0 || n == 1) {
            return 1;
        } 
        return fib(n -1) + fib(n -2);
    }
    
    fb fib_non_recursive(u32 n) -> (u32) {
        num += 1;
        if (n == 0 || n == 1) {
            return 1;
        }
        u32 a = 1; u32 b = 1;
        for (u32 i = 2; i < n - 1 ;i++) {
            b = a + b;
            a = b - a;
        }
        return a + b;
    }
    
}

````



````javascript


contract Person {
    
    enum Sex {
        Man
        Women
    }
    
    struct Person {
        Sex s;
        u32 age;
        u256 person_id;
    }

    Person p;
    
    fn newPerson(Sex s, u32 age, u256 id) {
        p = Person(s, age, id);
    }
    
    fn getPersionId() -> (u256) {
        return p.id;
    }

    fn getAge() -> (u32) {
        return p.age;
    }
}

````



### 

## Multiple files


## More Features

* string support
* mapping support
* 2