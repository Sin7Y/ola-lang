contract C {
    struct S { bool f; }
    S s;
    fn f(bool flag) internal view returns (S storage c) {
        flag ? c = s : c = s;
    }
    fn g(bool flag) internal view returns (S storage c) {
        flag ? c = s : (c = s);
    }
    fn h(bool flag) internal view returns (S storage c) {
        flag ? (c = s).f : (c = s).f;
    }
}
// ----
