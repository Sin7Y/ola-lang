

contract C {
    struct S {
        u32 a;
        u256 b;
        u256 c;
    }
    struct X {
        u32 a;
        S s;
    }

    u256[79] arr;
    X x = X(12, S(42, 23, 34));

    fn f()  -> (u32, u256, u256) {
        X  m = x;
        return (m.s.a, m.s.b, m.s.c);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 42, 23, 34
