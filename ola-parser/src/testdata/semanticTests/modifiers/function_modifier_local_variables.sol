contract C {
    modifier mod1 {
        uint8 a = 1;
        uint8 b = 2;
        _;
    }
    modifier mod2(bool a) {
        if (a) return;
        else _;
    }

    fn f(bool a) public mod1 mod2(a) -> (u256 r) {
        return 3;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f(bool): true -> 0
// f(bool): false -> 3
