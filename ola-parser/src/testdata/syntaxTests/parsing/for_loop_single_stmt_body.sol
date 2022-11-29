contract test {
    fn fun(uint256 a) public {
        uint256 i = 0;
        for (i = 0; i < 10; i++)
            continue;
    }
}
// ----
// Warning 5667: (33-42): Unused fn parameter. Remove or comment out the variable name to silence this warning.
// Warning 2018: (20-136): fn state mutability can be restricted to pure
