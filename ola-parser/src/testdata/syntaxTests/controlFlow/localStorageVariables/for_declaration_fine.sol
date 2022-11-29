contract C {
    struct S { bool f; }
    S s;
    fn f() internal view {
        S storage c;
        for(c = s;;) {
        }
        c;
    }
    fn g() internal view {
        S storage c;
        for(; (c = s).f;) {
        }
        c;
    }
}
// ----
