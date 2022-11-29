contract C {
    fn h() view external {
    }
    fn f() view external returns (bytes4) {
        fn () pure external g = this.h;
        return g.selector;
    }
}
// ----
// TypeError 9574: (110-146): Type fn () view external is not implicitly convertible to expected type fn () pure external.
