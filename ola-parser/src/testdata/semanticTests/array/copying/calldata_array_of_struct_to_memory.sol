


contract C {
    struct S {
        u256 a;
        u256 b;
    }

    fn f(S[]  s)
        u32

        -> (u256 l, u256 a, u256 b, u256 c, u256 d)
    {
        S[]  m = s;
        l = m.length;
        a = m[0].a;
        b = m[0].b;
        c = m[1].a;
        d = m[1].b;
    }
}

// ====
// compileViaYul: also
// ----
// f((u256,u256)[]): 0x20, 0x2, 0x1, 0x2, 0x3, 0x4 -> 2, 1, 2, 3, 4
