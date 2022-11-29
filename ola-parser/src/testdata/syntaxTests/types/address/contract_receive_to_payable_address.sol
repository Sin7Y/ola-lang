contract C {
  fn f() public view {
    address payable a = payable(this);
    a;
  }
  receive() external payable {
  }
}
// ----
