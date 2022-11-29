
contract Test {
    fn f(u256[]  c)  -> (u256 a, u256 b) {
        return (c.length, c[0]);
    }

    fn g(u256[]  c)  -> (u256 a, u256 b) {
        return f(c);
    }

    fn h(u256[]  c, u256 start, u256 end)  -> (u256 a, u256 b) {
        return f(c[start: end]);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// g(u256[]): 0x20, 4, 1, 2, 3, 4 -> 4, 1
// h(u256[],u256,u256): 0x60, 1, 3, 4, 1, 2, 3, 4 -> 2, 2
