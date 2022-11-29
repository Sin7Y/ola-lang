contract C {
    fn f()  -> (u256 r) {
        u256;
        u256;
        u256;
        u256;
        int256 x = -7;
        return u256(x);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> -7
