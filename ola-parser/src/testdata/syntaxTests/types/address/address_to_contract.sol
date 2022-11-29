contract C {
  fn f() public pure returns (C c) {
    c = C(address(2));
  }
}
// ----
