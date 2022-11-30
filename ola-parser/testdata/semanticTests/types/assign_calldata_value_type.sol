contract C {
    fn f(u256 x)  -> (u256, u256) {
        u256 b = x;
        x = 42;
        return (x, b);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 23 -> 42, 23
