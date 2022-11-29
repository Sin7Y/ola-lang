contract C {
    fn f(uint x, string memory y) internal {}
    fn f(bytes memory y, int x) internal {}

    fn call() internal {
        f({x: 1, y: "abc"});
    }
}
// ----
// TypeError 4487: (155-156): No unique declaration found after argument-dependent lookup.
