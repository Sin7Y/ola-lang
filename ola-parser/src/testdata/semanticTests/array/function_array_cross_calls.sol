contract D {
    fn f(fn() external -> (fn() external -> (u256))[] memory x)
         -> (fn() external -> (u256)[3] memory r) {
        r[0] = x[0]();
        r[1] = x[1]();
        r[2] = x[2]();
    }
}


contract C {
    fn test()  -> (u256, u256, u256) {
        fn() external -> (fn() external -> (u256))[] memory x =
            new fn() external -> (fn() external -> (u256))[](10);
        for (u256 i = 0; i < x.length; i++) x[i] = this.h;
        x[0] = this.htwo;
        fn() external -> (u256)[3] memory y = (new D()).f(x);
        return (y[0](), y[1](), y[2]());
    }

    fn e()  -> (u256) {
        return 5;
    }

    fn f()  -> (u256) {
        return 6;
    }

    fn g()  -> (u256) {
        return 7;
    }

    u256 counter;

    fn h()  -> (fn() external -> (u256)) {
        return counter++ == 0 ? this.f : this.g;
    }

    fn htwo()  -> (fn() external -> (u256)) {
        return this.e;
    }
}

// ====
// compileViaYul: also
// ----
// test() -> 5, 6, 7
// gas irOptimized: 292502
// gas legacy: 452136
// gas legacyOptimized: 284945
