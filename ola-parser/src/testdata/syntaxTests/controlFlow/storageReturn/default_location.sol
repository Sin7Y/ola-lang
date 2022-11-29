contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S memory c) {
        c = s;
    }
    fn g() internal view returns (S memory) {
        return s;
    }
    fn h() internal pure returns (S memory) {
    }
    fn i(bool flag) internal view returns (S memory c) {
        if (flag) c = s;
    }
    fn j(bool flag) internal view returns (S memory) {
        if (flag) return s;
    }
}
// ----
// Warning 6321: (399-407): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
