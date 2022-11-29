contract C {
    fn h() pure external {
    }
    fn f() pure external returns (bytes4) {
        return this.h.selector;
    }
}
// ----
