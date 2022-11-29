contract C {
    fn f() public view returns (bytes4) {
        fn () g;
        return g.selector;
    }
}
// ----
// TypeError 9582: (99-109): Member "selector" not found or not visible after argument-dependent lookup in fn ().
