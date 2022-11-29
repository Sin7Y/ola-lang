contract C {
    struct S { bool f; }
    S s;
    fn f(bool flag) internal view {
        S storage c;
        flag ? c = s : c = s;
        c;
    }
    fn g(bool flag) internal view {
        S storage c;
        flag ? c = s : (c = s);
        c;
    }
    fn h(bool flag) internal view {
        S storage c;
        flag ? (c = s).f : (c = s).f;
        c;
    }
}
// ----
