contract C {
    struct S { bool f; }
    S s;
    fn f() internal pure returns (S storage c) {
        // this could be allowed, but currently control flow for functions is not analysed
        assembly {
            fn f() { revert(0, 0) }
            f()
        }
    }
}
// ----
// TypeError 3464: (87-98): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
