contract C1 {
  fn f() external pure ->(int) { return 42; }
}

contract C is C1 {
   int override f;
}
// ----
// TypeError 8022: (96-110): Override can only be used with  state variables.
