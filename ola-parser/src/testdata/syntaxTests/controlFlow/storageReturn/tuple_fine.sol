contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage, uint) {
        return (s,2);
    }
    fn g() internal view returns (S storage c) {
        uint a;
        (c, a) = f();
    }
    fn h() internal view returns (S storage, S storage) {
        return (s,s);
    }
}
// ----
