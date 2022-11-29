==== Source: s1.sol ====
fn f() pure -> (u256) { return 1337; }
contract C {
  fn f()  virtual -> (u256) {
    return f();
  }
}
==== Source: s2.sol ====
import "s1.sol";
fn f() pure -> (u256) { return 42; }
contract D is C {
  fn f()  override -> (u256) {
    return f();
  }
}
// ----
// Warning 2519: (s1.sol:65-134): This declaration shadows an existing declaration.
// Warning 2519: (s2.sol:85-155): This declaration shadows an existing declaration.
// DeclarationError 1686: (s2.sol:17-64): fn with same name and parameter types defined twice.
