library L {
    error E();
}
library S {
    error E(u256);
}
library T {
    error E();
}
contract C {
    fn f()  -> (bytes4, bytes4) {
        assert(L.E.selector == T.E.selector);
        assert(L.E.selector != S.E.selector);
        return (L.E.selector, S.E.selector);
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 0x92bbf6e800000000000000000000000000000000000000000000000000000000, 0x2ff06700000000000000000000000000000000000000000000000000000000
