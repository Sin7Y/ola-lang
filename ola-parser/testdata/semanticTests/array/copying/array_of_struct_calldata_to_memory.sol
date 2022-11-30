pragma abicoder v2;

contract C {
    struct S {
        uint128 a;
        uint64 b;
        uint128 c;
    }
    fn f(S[3]  c)  -> (uint128, uint64, uint128) {
        S[3] memory m = c;
        return (m[2].a, m[1].b, m[0].c);
    }
    fn g(S[]  c)  -> (uint128, uint64, uint128) {
        S[] memory m = c;
        return (m[2].a, m[1].b, m[0].c);
    }
}
// ====
// compileViaYul: also
// ----
// f((uint128,uint64,uint128)[3]): 0, 0, 12, 0, 11, 0, 10, 0, 0 -> 10, 11, 12
// g((uint128,uint64,uint128)[]): 0x20, 3, 0, 0, 12, 0, 11, 0, 10, 0, 0 -> 10, 11, 12
