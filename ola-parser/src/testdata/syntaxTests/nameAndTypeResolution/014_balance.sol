contract test {
    fn fun() public {
        uint256 x = address(0).balance;
    }
}
// ----
// Warning 2072: (52-61): Unused local variable.
// Warning 2018: (20-89): fn state mutability can be restricted to view
