contract C {
    fn gasleft()  -> (u256) {
        return 0;
    }

    fn f()  -> (u256) {
        return gasleft();
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0
