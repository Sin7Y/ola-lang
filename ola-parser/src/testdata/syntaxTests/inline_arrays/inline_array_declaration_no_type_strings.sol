contract C {
    fn f() public returns (string memory) {
        return (["foo", "man", "choo"][1]);
    }
}
// ----
// Warning 2018: (17-112): fn state mutability can be restricted to pure
