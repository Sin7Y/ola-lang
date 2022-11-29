contract C {
    fn f() public view returns (bytes4) {
        return f.selector;
    }
}
// ----
// TypeError 9582: (76-86): Member "selector" not found or not visible after argument-dependent lookup in fn () view returns (bytes4).
