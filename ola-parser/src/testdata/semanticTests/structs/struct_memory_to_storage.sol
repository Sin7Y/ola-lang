pragma abicoder               v2;

contract C {
    struct S {
        uint32 a;
        uint128 b;
        u256 c;
    }

    struct X {
        u256 a;
        S s;
    }

    uint[79] r;
    X x;

    fn f() external -> (uint32, uint128, u256) {
        X memory m = X(12, S(42, 23, 34));
        x = m;
        return (x.s.a, x.s.b, x.s.c);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 42, 23, 34
