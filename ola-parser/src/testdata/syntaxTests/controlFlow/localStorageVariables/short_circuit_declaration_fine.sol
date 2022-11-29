contract C {
    struct S { bool f; }
    S s;
    fn f() internal view {
        S storage c;
        (c = s).f && false;
        c;
    }
    fn g() internal view {
        S storage c;
        (c = s).f || true;
        c;
    }
}
// ----
