contract I {
  fn f() external virtual {}
}
contract A is I {
  fn f() external virtual override {}
}
contract B is I {}
contract C is A, B {
  fn f() external override(A, I) {}
}
// ----
