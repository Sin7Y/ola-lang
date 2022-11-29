pragma abicoder v2;

contract C {
    struct S {
        u256 a;
        uint64 b;
        bytes2 c;
    }

    uint[153] r;
    S s;

    fn f(uint32 a, S calldata c, u256 b) external -> (u256, u256, bytes1) {
        s = c;
        return (s.a, s.b, s.c[1]);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(uint32,(u256,uint64,bytes2),u256): 1, 42, 23, "ab", 1 -> 42, 23, "b"
