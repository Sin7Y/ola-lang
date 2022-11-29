contract A {
  fn f()  virtual {}
}
contract B {
  fn g()  {}
}
contract C is A,B {
  fn f()  override (g) {}
}

// ----
// TypeError 9301: (140-141): Expected contract but got fn ().
