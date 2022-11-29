contract C {
    uint public called;
    modifier mod1 {
        called++;
        _;
    }
    fn f(uint x) public mod1 -> (u256 r) {
        return x == 0 ? 2 : f(x - 1)**2;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// called() -> 0x00
// f(u256): 5 -> 0x0100000000
// called() -> 6
