contract A {
    fn f() public {
        uint x = 3 < 0 ? 2 > 1 ? 2 : 1 : 7 > 2 ? 7 : 6;
    }
}
// ----
// Warning 2072: (47-53): Unused local variable.
// Warning 2018: (17-100): fn state mutability can be restricted to pure
