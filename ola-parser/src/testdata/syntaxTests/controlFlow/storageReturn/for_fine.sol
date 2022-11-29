contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage c) {
        for(c = s;;) {
        }
    }
    fn g() internal view returns (S storage c) {
        for(; (c = s).f;) {
        }
    }
}
// ----
