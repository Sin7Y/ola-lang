contract C {
  // Tests that we don't get a wrong error about constructors
  fn f() public view returns (C) { return this; }
  fn g() public { this.f.value(); }
}
// ----
// TypeError 8820: (155-167): Member "value" is only available for payable functions.
