contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage c) {
        (c = s).f && false;
    }
    fn g() internal view returns (S storage c) {
        (c = s).f || true;
    }
}
// ----
