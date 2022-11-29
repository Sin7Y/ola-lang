library L {
    fn g(fn() internal -> (u256) _t) internal -> (u256) { return _t(); }
}
contract C {
    using L for *;
    fn f()  -> (u256) {
        return t.g();
    }
    fn t()  -> (u256)  { return 7; }
}
// ====
// compileToEwasm: false
// compileViaYul: also
// ----
// library: L
// f() -> 7
