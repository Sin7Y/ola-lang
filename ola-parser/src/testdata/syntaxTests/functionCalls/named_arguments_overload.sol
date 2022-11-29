contract C {
    fn f(uint x) internal { }
    fn f(uint x, uint y) internal { }
    fn f(uint x, uint y, uint z) internal { }
    fn call() internal {
        f({x: 1});
        f({x: 1, y: 2});
        f({y: 2, x: 1});
        f({x: 1, y: 2, z: 3});
        f({z: 3, x: 1, y: 2});
        f({y: 2, z: 3, x: 1});
    }
}
// ----
