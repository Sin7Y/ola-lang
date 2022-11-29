fn f() {}
contract C {
  fn f()  {}
  fn g()  {
    f();
  }
}
// ----
// Warning 2519: (31-53): This declaration shadows an existing declaration.
