pragma abicoder v2;

contract C {
    struct S {
        uint64 a;
        bytes b;
    }
    struct S1 {
        u256 a;
        S s;
        u256 c;
    }

    fn f(S1 calldata s1)
        external
        pure
        -> (u256 a, uint64 b0, bytes1 b1, u256 c)
    {
        a = s1.a;
        b0 = s1.s.a;
        b1 = s1.s.b[0];
        c = s1.c;
    }
}
// ====
// compileViaYul: also
// ----
// f((u256,(uint64,bytes),u256)): 0x20, 42, 0x60, 23, 1, 0x40, 2, "ab" -> 42, 1, "a", 23
