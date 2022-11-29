

contract C {
    struct S {
        u64 a;
        u64 b;
    }
    struct S1 {
        u256 a;
        S s;
        u256 c;
    }

    fn f(S1  s1)


        -> (u256 a, u64 b0, u64 b1, u256 c)
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
// f((u256,(u64,u64),u256)): 42, 1, 2, 23 -> 42, 1, 2, 23
