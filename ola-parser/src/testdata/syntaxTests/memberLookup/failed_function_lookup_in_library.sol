library L {
  fn f(uint, uint) public {}
  fn f(uint) public {}
}
contract C {
  fn g() public { L.f(1, 2, 3); }
}
// ----
// TypeError 9582: (115-118): Member "f" not found or not visible after argument-dependent lookup in type(library L).
