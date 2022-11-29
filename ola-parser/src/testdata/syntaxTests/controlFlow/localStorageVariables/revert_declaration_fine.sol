contract C {
    struct S { bool f; }
    S s;
    fn g(bool flag) internal view {
        S storage c;
        if (flag) c = s;
        else revert();
        s;
    }
}
// ----
