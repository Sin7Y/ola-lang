contract C {
  fn f() public pure returns (uint) {
    return abi.decode("abc", (uint));
  }
}
// ----
