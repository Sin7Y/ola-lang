contract C {
    u256  i;
    constructor(u256 newI) {
        i = newI;
    }
}
contract D {
    C c;
    constructor(u256 v) {
        c = new C(v);
    }
    fn f()  -> (u256 r) {
        return c.i();
    }
}
// ====
// compileViaYul: also
// ----
// constructor(): 2 ->
// gas irOptimized: 200217
// gas legacy: 245842
// gas legacyOptimized: 195676
// f() -> 2
