contract C {
    struct S {
        u256 a;
        bool x;
    }
    S  s;

    fn c() {
        s = S({x: true, a: 1});
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// s() -> 1, true
