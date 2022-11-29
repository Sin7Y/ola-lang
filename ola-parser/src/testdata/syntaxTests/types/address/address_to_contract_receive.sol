contract C {
  fn f() public pure returns (C c) {
    c = C(payable(address(2)));
  }
  receive() external payable {
  }
}
// ----
