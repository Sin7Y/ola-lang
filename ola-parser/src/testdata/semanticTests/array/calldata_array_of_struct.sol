


contract C {
    struct S {
        u256 a;
        u256 b;
    }

    fn f(S[]  s)


        -> (u256 l, u256 a, u256 b, u256 c, u256 d)
    {
        l = s.length;
        a = s[0].a;
        b = s[0].b;
        c = s[1].a;
        d = s[1].b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u256,u256)[]): 0x20, 0x2, 0x1, 0x2, 0x3, 0x4 -> 2, 1, 2, 3, 4
