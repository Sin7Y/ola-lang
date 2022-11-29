fn f() pure -> (u256) { return 1337; }
contract C {
  fn f()  -> (u256) {
    return f();
  }
}
// ----
// Warning 2519: (65-126): This declaration shadows an existing declaration.
