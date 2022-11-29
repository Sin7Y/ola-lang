contract A {
    fn f() public {
        uint x = 3 > 0 ? 3 : 0;
        uint y = (3 > 0) ? 3 : 0;
    }
}
// ----
// Warning 2072: (47-53): Unused local variable.
// Warning 2072: (79-85): Unused local variable.
// Warning 2018: (17-110): fn state mutability can be restricted to pure
