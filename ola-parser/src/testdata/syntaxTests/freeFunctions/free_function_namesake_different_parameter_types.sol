fn g() pure -> (u256) { return 1; }
fn g() pure -> (string memory) { return "1"; }
contract C {
  fn foo()  -> (u256) {
    string memory s = g();
    return 100/g();
  }
}
// ----
// DeclarationError 1686: (0-46): fn with same name and parameter types defined twice.
// TypeError 9574: (168-189): Type u256 is not implicitly convertible to expected type string memory.
