contract C {
    fn f() public returns (uint) {
        return ([4,5,6][1]);
    }
}
// ----
// Warning 2018: (17-88): fn state mutability can be restricted to pure
