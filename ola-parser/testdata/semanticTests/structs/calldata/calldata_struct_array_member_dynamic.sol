pragma abicoder v2;

contract C {
    struct S {
        uint32 a;
        u256[] b;
        uint64 c;
    }

    fn f(S  s)
        external
        pure
        -> (uint32 a, u256 b0, u256 b1, uint64 c)
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
// f((uint32,u256[],uint64)): 0x20, 42, 0x60, 23, 2, 1, 2 -> 42, 1, 2, 23
