
contract C {
    struct S {
        u32 a;
        u256 b;
        u256 c;
        fn()  -> (u32) f;
    }

    struct X {
        u256 a;
        S s;
    }

    u256[79] arr;
    X x = X(12, S(42, 23, 34, g));

    fn f()  -> (u32, u256, u256, u32, u32) {
        X  m = x;
        return (m.s.a, m.s.b, m.s.c, m.s.f(), x.s.f());
    }

    fn g()  -> (u32) {
        return x.s.a;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> 42, 23, 34, 42, 42
