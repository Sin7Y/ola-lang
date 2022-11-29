contract C {
    fn g(int x, int y)  -> (int) { return x - y; }
    fn h(int y, int x)  -> (int) { return y - x; }

    fn f()  -> (int) {
        return (false ? g : h)(2, 1);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1
