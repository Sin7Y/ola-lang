contract C {
    fn h() pure external {
    }
    fn f() view external returns (bytes4) {
        fn () payable external g = this.h;
        return g.selector;
    }
}
// ----
// TypeError 9574: (110-149): Type fn () pure external is not implicitly convertible to expected type fn () payable external.
