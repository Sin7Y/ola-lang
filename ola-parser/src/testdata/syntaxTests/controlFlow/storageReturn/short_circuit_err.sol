contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage c) {
        false && (c = s).f;
    }
    fn g() internal view returns (S storage c) {
        true || (c = s).f;
    }
    fn h() internal view returns (S storage c) {
        // expect error, although this is always fine
        true && (false || (c = s).f);
    }
}
// ----
// TypeError 3464: (87-98): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (176-187): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (264-275): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
