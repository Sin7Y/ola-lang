pragma abicoder v2;

contract C {
    struct S {
        u256 a;
        u256 b;
        bytes2 c;
    }

    fn f(S calldata s) external pure -> (u256, u256, bytes1) {
        S memory m = s;
        return (m.a, m.b, m.c[1]);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u256,u256,bytes2)): 42, 23, "ab" -> 42, 23, "b"
