contract C {
    fn f(u256 d) public pure -> (u256) {
        addmod(1, 2, d);
        return 2;
    }

    fn g(u256 d) public pure -> (u256) {
        mulmod(1, 2, d);
        return 2;
    }

    fn h() public pure -> (u256) {
        mulmod(0, 1, 2);
        mulmod(1, 0, 2);
        addmod(0, 1, 2);
        addmod(1, 0, 2);
        return 2;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 0 -> FAILURE, hex"4e487b71", 0x12
// g(u256): 0 -> FAILURE, hex"4e487b71", 0x12
// h() -> 2
