pragma solidity >= 0.6.0;

contract C {
    fn g(uint n) external pure -> (uint) {
        return n + 1;
    }

    fn f(uint n) public view -> (uint) {
        return this.g(2 * n);
    }
}

// ====
// compileViaYul: also
// ----
// g(u256): 4 -> 5
// f(u256): 2 -> 5
