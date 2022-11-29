contract C {
    fn gasleft() public pure returns (bytes32 val) { return "abc"; }
    fn f() public pure returns (bytes32 val) { return gasleft(); }
}
// ----
// Warning 2319: (17-87): This declaration shadows a builtin symbol.
