pragma abicoder v2;

contract C {
    struct S {
        u256 a;
        bytes b;
        u256 c;
    }

    fn f(S calldata c)
        external
        pure
        -> (u256, bytes1, bytes1, u256)
    {
        S memory m = c;
        return (m.a, m.b[0], m.b[1], m.c);
    }
}

// ====
// compileViaYul: also
// ----
// f((u256,bytes,u256)): 0x20, 42, 0x60, 23, 2, "ab" -> 42, "a", "b", 23
