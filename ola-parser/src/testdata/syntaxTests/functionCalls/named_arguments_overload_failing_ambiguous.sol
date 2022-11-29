contract C {
    fn f(uint x, string memory y, bool z) internal {}
    fn f(string memory y, uint x, bool z) internal {}
    fn f(bool z, string memory y, uint x) internal {}

    fn call() internal {
        f({x: 1, y: "abc", z: true});
    }
}
// ----
// TypeError 4487: (233-234): No unique declaration found after argument-dependent lookup.
