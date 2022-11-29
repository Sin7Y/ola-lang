contract A {}
contract B is A {}
contract C {
  fn f() public {
    A a = new B();
    a;
  }
}
// ----
