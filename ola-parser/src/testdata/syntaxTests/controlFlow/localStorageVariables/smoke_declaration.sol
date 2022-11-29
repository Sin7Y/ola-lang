contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure {}
    fn g() internal view { s; }
    fn h() internal view {
        S storage c;
        c = s;
        c;
    }
    fn i() internal view {
        S storage c;
        (c) = s;
        c;
    }
}
// ----
