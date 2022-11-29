contract C {
    fn g() pure internal {
    }
    fn f() public view returns (bytes4) {
        return g.selector;
    }
}
// ----
// TypeError 9582: (115-125): Member "selector" not found or not visible after argument-dependent lookup in fn () pure.
