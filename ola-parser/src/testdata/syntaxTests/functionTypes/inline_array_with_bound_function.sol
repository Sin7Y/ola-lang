library L {
    fn f(uint a) internal pure {}
    fn g(uint a) internal pure {}
}
contract C {
    using L for *;
    fn f() pure public {
        uint t = 8;
        [t.f, t.g][0]();
    }
}
// ----
// TypeError 9563: (186-189): Invalid mobile type.
