contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure returns (S storage) {
        revert();
    }
    fn g(bool flag) internal view returns (S storage c) {
        if (flag) c = s;
        else revert();
    }
}
// ----
