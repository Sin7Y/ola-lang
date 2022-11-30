


contract C {
    struct S1 {
        u256 a;
        u256 b;
    }
    struct S2 {
        u256 a;
        u256 b;
        S1 s;
        u256 c;
    }

    fn f(S2  s)
        u32
        u32
        -> (u256 a, u256 b, u256 sa, u256 sb, u256 c)
    {
        S2  m = s;
        return (m.a, m.b, m.s.a, m.s.b, m.c);
    }
}

// ====
// compileViaYul: also
// ----
// f((u256,u256,(u256,u256),u256)): 1, 2, 3, 4, 5 -> 1, 2, 3, 4, 5
