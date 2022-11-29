contract C {
    modifier m(bool condition) {
        if (condition) _;
    }

    fn f(uint x) public m(x >= 10) -> (uint[5] memory r) {
        r[2] = 3;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f(u256): 9 -> 0x00, 0x00, 0x00, 0x00, 0x00
// f(u256): 10 -> 0x00, 0x00, 3, 0x00, 0x00
