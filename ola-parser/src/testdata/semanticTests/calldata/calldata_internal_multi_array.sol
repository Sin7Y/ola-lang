pragma abicoder               v2;

contract C {
    fn g(u256[][2] calldata s) internal pure -> (u256, u256[] calldata) {
        return (s[0][1], s[1]);
    }
    fn f(u256, u256[][2] calldata s, u256) external pure -> (u256, u256) {
        (u256 x, u256[] calldata y) = g(s);
        return (x, y[0]);
    }
    fn g()  -> (u256, u256) {
        u256[][2] memory x;
        x[0] = new u256[](2);
        x[1] = new u256[](2);
        x[0][1] = 7;
        x[1][0] = 8;
        return this.f(4, x, 5);
    }
}
// ====
// compileViaYul: also
// ----
// g() -> 7, 8
