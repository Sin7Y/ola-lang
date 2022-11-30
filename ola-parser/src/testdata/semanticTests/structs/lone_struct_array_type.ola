contract C {
    struct s {
        u256 a;
        u256 b;
    }

    fn f()  -> (u256) {
        s[7][]; // This is only the type, should not have any effect
        return 3;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 3
