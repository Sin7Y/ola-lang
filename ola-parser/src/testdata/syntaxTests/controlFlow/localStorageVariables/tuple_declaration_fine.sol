contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage, uint) {
      return (s,2);
    }
    fn g() internal view {
        uint a;
        S storage c;
        (c, a) = f();
        c;
    }
    fn h() internal view {
        (s, s);
    }
}
// ----
