contract C {
  fn f()  {
    bytes32 b;
    b[64];
  }
}
// ----
// TypeError 1859: (56-61): Out of bounds array access.
