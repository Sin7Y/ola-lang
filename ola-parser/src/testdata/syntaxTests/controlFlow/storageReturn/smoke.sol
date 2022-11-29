contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure {}
    fn g() internal view returns (S storage) { return s; }
    fn h() internal view returns (S storage c) { return s; }
    fn i() internal view returns (S storage c) { c = s; }
    fn j() internal view returns (S storage c) { (c) = s; }
}
// ----
