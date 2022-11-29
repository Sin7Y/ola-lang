pragma solidity >= 0.6.0;

contract C {
    fn h(u256[4] memory n)  -> (u256) {
        return n[0] + n[1] + n[2] + n[3];
    }

    fn i(u256[4] memory n)  -> (u256) {
        return this.h(n) * 2;
    }
}

// ====
// compileViaYul: also
// ----
// h(u256[4]): 1, 2, 3, 4 -> 10
// i(u256[4]): 1, 2, 3, 4 -> 20
