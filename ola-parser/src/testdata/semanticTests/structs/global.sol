pragma abicoder               v2;

struct S { u256 a; u256 b; }
contract C {
    fn f(S calldata s) external pure -> (u256, u256) {
        return (s.a, s.b);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u256,u256)): 42, 23 -> 42, 23
