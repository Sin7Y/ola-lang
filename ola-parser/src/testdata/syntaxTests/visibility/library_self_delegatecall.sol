library L1 {
    using L1 for *;
    fn f()  -> (u256 r) { return r.g(); }
    fn g(u256)  -> (u256) { return 2; }
}

library L2 {
    using L1 for *;
    fn f()  -> (u256 r) { return r.g(); }
    fn g(u256)  -> (u256) { return 2; }
}
// ----
// TypeError 6700: (88-93): Libraries cannot call their own functions externally.
