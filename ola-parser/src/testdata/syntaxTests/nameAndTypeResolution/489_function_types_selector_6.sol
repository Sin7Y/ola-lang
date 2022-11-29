contract C {
    fn h() pure external {
    }
    fn f() view external returns (bytes4) {
        fn () pure external g = this.h;
        return g.selector;
    }
}
// ----
