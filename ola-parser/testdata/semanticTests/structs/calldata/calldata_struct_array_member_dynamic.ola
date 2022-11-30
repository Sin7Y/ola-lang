

contract C {
    struct S {
        u32 a;
        u256[] b;
        u64 c;
    }

    fn f(S  s)


        -> (u32 a, u256 b0, u256 b1, u64 c)
    {
        a = s.a;
        b0 = s.b[0];
        b1 = s.b[1];
        c = s.c;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u32,u256[],u64)): 0x20, 42, 0x60, 23, 2, 1, 2 -> 42, 1, 2, 23
