contract C {
    fn h() pure external {
    }
    fn f() view external returns (bytes4) {
        fn () external g = this.h;
        return g.selector;
    }
}
// ----
