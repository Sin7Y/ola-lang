contract C {
    struct S { bool f; }
    S s;
    fn f() internal view {
        S storage c;
        for(;; c = s) {
        }
        c;
    }
    fn g() internal view {
        S storage c;
        for(;;) {
            c = s;
        }
        c;
    }
}
// ----
// TypeError 3464: (143-144): This variable is of storage pointer type and can be accessed without prior assignment, which would lead to undefined behaviour.
// TypeError 3464: (261-262): This variable is of storage pointer type and can be accessed without prior assignment, which would lead to undefined behaviour.
