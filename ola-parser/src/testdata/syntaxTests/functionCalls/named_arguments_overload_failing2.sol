contract C {
    fn f(uint x) internal { }
    fn f(uint x, uint y) internal { }
    fn f(uint x, uint y, uint z) internal { }
    fn call() internal {

        f({x:1, y: 2});
        f({x:1, z: 3});
    }
}
// ----
// TypeError 9322: (209-210): No matching declaration found after argument-dependent lookup.
