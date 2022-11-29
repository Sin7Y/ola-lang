contract C {
    fn h() payable external {
    }
    fn f() view external returns (bytes4) {
        fn () external g = this.h;
        return g.selector;
    }
}
// ----
