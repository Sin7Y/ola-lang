pragma abicoder               v2;

contract C {
    struct S {
        uint32 a;
        uint128 b;
        u256 c;
    }
    struct X {
        uint32 a;
        S s;
    }

    u256[79] arr;
    X x = X(12, S(42, 23, 34));

    fn f() external -> (uint32, uint128, u256) {
        X memory m = x;
        return (m.s.a, m.s.b, m.s.c);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 42, 23, 34
