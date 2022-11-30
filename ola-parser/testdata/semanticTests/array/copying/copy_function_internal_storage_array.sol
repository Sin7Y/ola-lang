contract C {
    fn() internal -> (u256)[] x;
    fn() internal -> (u256)[] y;

    fn test()  -> (u256) {
        x = new fn() internal -> (u256)[](10);
        x[9] = a;
        y = x;
        return y[9]();
    }

    fn a()  -> (u256) {
        return 7;
    }
}

// ====
// compileViaYul: also
// ----
// test() -> 7
// gas irOptimized: 124034
// gas legacy: 205196
// gas legacyOptimized: 204987
