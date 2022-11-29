contract D {
    u256  x;
    constructor(fn() external pure -> (u256) g) {
        x = g();
    }
}

contract C {
    fn f()  -> (u256 r) {
        D d = new D(this.sixteen);
        r = d.x();
    }

    fn sixteen()  -> (u256) {
        return 16;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 16
// gas legacy: 103488
