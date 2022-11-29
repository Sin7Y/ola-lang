contract test {
  fn f() public pure returns (bytes memory) {
    return bytes("abc");
  }
}
// ----
