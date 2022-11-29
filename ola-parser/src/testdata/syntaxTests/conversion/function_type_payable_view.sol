contract C {
    fn h() payable external {
    }
    fn f() view external returns (bytes4) {
        fn () view external g = this.h;
        return g.selector;
    }
}
// ----
// TypeError 9574: (113-149): Type fn () payable external is not implicitly convertible to expected type fn () view external.
