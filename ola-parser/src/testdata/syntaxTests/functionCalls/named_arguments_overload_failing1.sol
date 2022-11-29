contract C {
    fn f(uint x) internal { }
    fn f(uint x, uint y) internal { }
    fn f(uint x, uint y, uint z) internal { }
    fn call() internal {
        f(1, 2);
        f(1);

        f({x: 1, y: 2});
        f({y: 2});
    }
}
// ----
// TypeError 9322: (241-242): No matching declaration found after argument-dependent lookup.
