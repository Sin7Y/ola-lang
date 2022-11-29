contract C {
    struct S { bool f; }
    S s;
    fn f() internal view returns (S storage c) {
        for(;; c = s) {
        }
    }
    fn g() internal view returns (S storage c) {
        for(;;) {
            c = s;
        }
    }
}
// ----
// TypeError 3464: (87-98): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (182-193): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
