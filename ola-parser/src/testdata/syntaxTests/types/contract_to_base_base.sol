contract A {}
contract B is A {}
contract C is B {}
contract D {
  fn f() public {
    A a = new C();
    a;
  }
}
// ----
