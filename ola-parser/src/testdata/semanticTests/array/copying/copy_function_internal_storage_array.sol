contract C {
    fn() internal returns (uint)[] x;
    fn() internal returns (uint)[] y;

    fn test() public returns (uint256) {
        x = new fn() internal returns (uint)[](10);
        x[9] = a;
        y = x;
        return y[9]();
    }

    fn a() public returns (uint256) {
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
