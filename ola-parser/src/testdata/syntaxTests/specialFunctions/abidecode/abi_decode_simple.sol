contract C {
  fn f() public pure returns (uint, bytes32, C) {
    return abi.decode("abc", (uint, bytes32, C));
  }
}
// ----
