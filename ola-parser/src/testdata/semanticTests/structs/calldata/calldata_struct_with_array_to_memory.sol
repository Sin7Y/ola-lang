

contract C {
    struct S {
        u256 a;
        u256[2] b;
        u256 c;
    }

    fn f(S  c)


        -> (u256, u256, u256, u256)
    {
        S  m = c;
        return (m.a, m.b[0], m.b[1], m.c);
    }
}

// ====
// compileViaYul: also
// ----
// f((u256,u256[2],u256)): 42, 1, 2, 23 -> 42, 1, 2, 23
