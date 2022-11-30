pragma abicoder v2;

contract C {
    struct S {
        uint64 a;
        uint64 b;
    }
    struct S1 {
        u256 a;
        S s;
        u256 c;
    }

    fn f(S1  s1)
        external
        pure
        -> (u256 a, uint64 b0, uint64 b1, u256 c)
    {
        a = s1.a;
        b0 = s1.s.a;
        b1 = s1.s.b;
        c = s1.c;
    }
}
// ====
// compileViaYul: also
// ----
// f((u256,(uint64,uint64),u256)): 42, 1, 2, 23 -> 42, 1, 2, 23
