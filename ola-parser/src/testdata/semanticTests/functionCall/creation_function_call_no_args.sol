contract C {
    u256  i;
    constructor() {
        i = 2;
    }
}
contract D {
    fn f()  -> (u256 r) {
        return new C().i();
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 2
// gas legacy: 101599
