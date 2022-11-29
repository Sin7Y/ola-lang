pragma solidity >= 0.6.0;

contract C {
    fn g(uint n) external payable -> (uint, uint) {
        return (msg.value * 1000, n);
    }

    fn f(uint n) public payable -> (uint, uint) {
        return this.g{value: 10}(n);
    }
}

// ====
// compileViaYul: also
// ----
// g(u256), 1 ether: 4 -> 1000000000000000000000, 4
// f(u256), 11 ether: 2 -> 10000, 2
