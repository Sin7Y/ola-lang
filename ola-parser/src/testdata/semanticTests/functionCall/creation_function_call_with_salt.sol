contract C {
    u256  i;
    constructor(u256 newI) {
        i = newI;
    }
}
contract D {
    C c;
    constructor(u256 v) {
        c = new C{salt: "abc"}(v);
    }
    fn f()  -> (u256 r) {
        return c.i();
    }
}
// ====
// EVMVersion: >=constantinople
// compileViaYul: also
// ----
// constructor(): 2 ->
// gas irOptimized: 200380
// gas legacy: 246202
// gas legacyOptimized: 195914
// f() -> 2
