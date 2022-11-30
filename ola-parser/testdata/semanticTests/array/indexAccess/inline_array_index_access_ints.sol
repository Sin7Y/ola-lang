contract C {
    fn f()  -> (u256) {
        return ([1, 2, 3, 4][2]);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 3
