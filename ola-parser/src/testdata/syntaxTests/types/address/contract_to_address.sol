contract C {
  fn f() public view {
    address a = address(this);
    a;
  }
}
// ----
