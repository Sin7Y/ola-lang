contract test {
    fn f() public returns (bool) { return g(12, true) == 3; }
    fn g(uint256, bool) public returns (uint256) { }
}
// ----
