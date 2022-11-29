pragma abicoder               v2;

struct S {
    u256 x;
    u256 y;
}

contract C {
    fn f(S calldata s) internal pure -> (u256, u256) {
        return (s.x, s.y);
    }
    fn f(u256, S calldata s, u256) external pure -> (u256, u256) {
        return f(s);
    }
}
// ====
// compileViaYul: also
// ----
// f(u256,(u256,u256),u256): 7, 1, 2, 4 -> 1, 2
