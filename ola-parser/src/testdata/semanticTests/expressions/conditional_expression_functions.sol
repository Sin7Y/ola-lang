contract test {
    fn x()  -> (u256) { return 1; }
    fn y()  -> (u256) { return 2; }

    fn f(bool cond)  -> (u256) {
        fn () -> (u256) z = cond ? x : y;
        return z();
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(bool): true -> 1
// f(bool): false -> 2
