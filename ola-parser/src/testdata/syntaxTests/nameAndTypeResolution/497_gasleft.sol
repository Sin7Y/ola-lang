contract C {
    fn f() public view returns (uint256 val) { return gasleft(); }
}
// ----
