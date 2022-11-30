pragma abicoder               v2;

contract C {
    struct S {
        uint128 a;
        uint64 b;
        uint128 c;
    }
    uint128[137] unused;
    S[] s;
    fn f(S[]  c)  -> (uint128, uint64, uint128) {
        s = c;
        return (s[2].a, s[1].b, s[0].c);
    }
}
// ====
// compileViaYul: true
// ----
// f((uint128,uint64,uint128)[]): 0x20, 3, 0, 0, 12, 0, 11, 0, 10, 0, 0 -> 10, 11, 12
// gas irOptimized: 121019
