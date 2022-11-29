contract C {
  fn f(uint, uint) public {}
  fn f(uint) public {}
  fn g() public { f(1, 2, 3); }
}
// ----
// TypeError 9322: (101-102): No matching declaration found after argument-dependent lookup.
