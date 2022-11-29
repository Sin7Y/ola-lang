contract C {
    fn f()  -> (int, int) {
        int x = int((-(-5.2 % 3)) * 5);
        int t = 5;
        return (x, (-(-t % 3)) * 5);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 11, 10
