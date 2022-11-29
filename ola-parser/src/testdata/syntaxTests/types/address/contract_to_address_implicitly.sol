contract C {
  fn f() public view {
    address a = this;
    a;
  }
}
// ----
// TypeError 9574: (46-62): Type contract C is not implicitly convertible to expected type address.
