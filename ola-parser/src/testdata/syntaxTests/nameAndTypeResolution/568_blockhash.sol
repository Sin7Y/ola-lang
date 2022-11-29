contract C {
    fn f() public view returns (bytes32) { return blockhash(3); }
}
// ----
