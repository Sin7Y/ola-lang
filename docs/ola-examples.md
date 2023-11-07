# Ola Language examples

Ola contracts allow users to write complex business logic that will be deployed to Ola's l2 network, 
and cross-contract calls can be written between different contracts just like solidity.

## Fibonacci

The following example shows a recursive and non-recursive ola smart contract implementation of Fibonacci numbers.

````javascript

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

````
## Person 
The following shows a simple Person contract that contains a person structure, 
assigns a value to the person structure and reads the status of the person.

````javascript

contract Person {

    enum Sex {
        Man,
        Women
    }

    struct Person {
        Sex s;
        u32 age;
        u256 id;
    }

    Person p;

    fn newPerson(Sex s, u32 age, u256 id) {
        p = Person(s, age, id);
    }

    fn getPersonId() -> (u256) {
        return p.id;
    }

    fn getAge() -> (u32) {
        return p.age;
    }
}

````



## Vote conctact
The following example demonstrates a simple voting contract.

```
contract Voting {
 
    struct Proposal {
        u32 name;  
        u32 voteCount;
    }


    struct Voter {
        bool voted;  
        u32 vote;   
    }

    mapping(address => Voter) voters;

    Proposal[] proposals;

    // constructor
    fn contract_init(u32[] proposalNames_) {
       for (u32 i = 0; i < proposalNames_.length; i++) {
            proposals.push(Proposal({
                name: proposalNames_[i],
                voteCount: 0
            }));
            print(proposals[i].name);
        }
    }

    fn vote_proposal(u32 proposal_)  {
        address msgSender = caller_address();
        Voter storage sender = voters[msgSender];
        assert(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal_;
        print(proposals[proposal_].name);
        assert(proposals[proposal_].name != 0, "Vote is not initialized");
        proposals[proposal_].voteCount += 1;
    }


    fn winningProposal() -> (u32 winningProposal_) {
        u32 winningVoteCount = 0;
        for (u32 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
        print(winningProposal_);
        return winningProposal_;
    }

     fn getWinnerName() -> (u32) {
        u32 winnerP = winningProposal();
        u32 winnerName = proposals[winnerP].name;
        print(winnerName);
        return winnerName;
     }

}
```

## Cross-contract invocation

The following example demonstrates the usage of cross-contract invocation.

**Caller contract**

```

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

```
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

## Multiple files (TODO)

For better project organisation and clearer logic, 
it is common to split the contents of a file into multiple files.
ola language supports the import of another contract within a contract through the `import` keyword.

An example of a multi-file contract is shown below.


**Contract RectangularCalculator**
````javascript

contract RectangularCalculator {
  
    fn rectangle(u32 w, u32 h) -> (u32 s, u32 p) {
        s = w * h;
        p = 2 * (w + h);
        // Returns a variable with the same name, return can be ignore
        //return (s, p)
    }
}

````

**Contract ShapeCalculator**
````javascript

contract SquareCalculator {

    fn square(u32 w) -> (u32 s, u32 p) {
        s = w * w;
        p = 4 * w;
        return (s, p);
    }
}

````

**Contract Calculator**
```javascript

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

