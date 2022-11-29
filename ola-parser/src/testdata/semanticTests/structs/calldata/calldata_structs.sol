pragma abicoder               v2;


contract C {
    struct S1 {
        u256 a;
        u256 b;
    }
    struct S2 {
        u256 a;
    }

    fn f(S1 calldata s1, S2 calldata s2, S1 calldata s3)
        external
        pure
        -> (u256 a, u256 b, u256 c, u256 d, u256 e)
    {
        a = s1.a;
        b = s1.b;
        c = s2.a;
        d = s3.a;
        e = s3.b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u256,u256),(u256),(u256,u256)): 1, 2, 3, 4, 5 -> 1, 2, 3, 4, 5
