contract C {
    fn g(u32 x, u32 y)  -> (u32) { return x - y; }
    fn h(u32 y, u32 x)  -> (u32) { return y - x; }

    fn f()  -> (u32) {
        return (false ? g : h)(2, 1);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1
