pragma abicoder               v2;

contract C {
    struct S {
        uint32 a;
        uint128 b;
        u256 c;
        fn() internal -> (uint32) f;
    }

    struct X {
        u256 a;
        S s;
    }

    u256[79] arr;
    X x = X(12, S(42, 23, 34, g));

    fn f() external -> (uint32, uint128, u256, uint32, uint32) {
        X memory m = x;
        return (m.s.a, m.s.b, m.s.c, m.s.f(), x.s.f());
    }

    fn g() internal -> (uint32) {
        return x.s.a;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> 42, 23, 34, 42, 42
