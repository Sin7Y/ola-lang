fn f() pure -> (u256) { return 1337; }
fn f() view -> (u256) { return 42; }
contract C {
  fn g()  virtual -> (u256) {
    return f();
  }
}
// ----
// DeclarationError 1686: (0-49): fn with same name and parameter types defined twice.
