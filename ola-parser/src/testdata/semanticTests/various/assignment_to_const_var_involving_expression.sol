contract C {
    u256 constant x = 0x123 + 0x456;

    fn f()  -> (u256) {
        return x + 1;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x57a
