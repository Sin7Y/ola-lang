contract C {
    fn f(uint x, string memory y, bool z) internal {}
    fn f(uint x, uint y, uint z) internal {}

    fn call() internal {
        f({a: 1, b: "abc", c: true});
    }
}
// ----
// TypeError 9322: (164-165): No matching declaration found after argument-dependent lookup.
