contract C {
    fn h() external {
    }
    fn f() view external returns (bytes4) {
        fn () pure external g = this.h;
        return g.selector;
    }
}
// ----
// TypeError 9574: (105-141): Type fn () external is not implicitly convertible to expected type fn () pure external.
