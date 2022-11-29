contract C {
	int dummy;
    fn h() view external {
		dummy;
    }
    fn f() view external returns (bytes4) {
        fn () external g = this.h;
        return g.selector;
    }
}
// ----
