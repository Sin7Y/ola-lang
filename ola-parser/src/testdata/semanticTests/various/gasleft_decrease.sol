contract C {
    u256 v;

    fn f()  -> (bool) {
        u256 startGas = gasleft();
        v++;
        assert(startGas > gasleft());
        return true;
    }

    fn g()  -> (bool) {
        u256 startGas = gasleft();
        assert(startGas > gasleft());
        return true;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> true
// g() -> true
