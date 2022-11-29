contract test {
    fn fun(uint256 a) public {
        uint256 x = 3 ** a;
    }
}
// ----
// Warning 2072: (61-70): Unused local variable.
// Warning 2018: (20-86): fn state mutability can be restricted to pure
