contract C {
    struct S { bool f; }
    S s;
    fn f(bool flag) internal view returns (S storage c) {
        flag ? (c = s).f : false;
    }
    fn g(bool flag) internal view returns (S storage c) {
        flag ? false : (c = s).f;
    }
}
// ----
// TypeError 3464: (96-107): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (200-211): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
