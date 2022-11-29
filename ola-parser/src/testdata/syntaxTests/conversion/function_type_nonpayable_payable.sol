contract C {
    fn h() external {
    }
    fn f() view external returns (bytes4) {
        fn () payable external g = this.h;
        return g.selector;
    }
}
// ----
// TypeError 9574: (105-144): Type fn () external is not implicitly convertible to expected type fn () payable external.
