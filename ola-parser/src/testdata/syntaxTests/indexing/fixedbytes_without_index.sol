contract C {
  fn f()  {
    bytes32 b;
    b[];
  }
}
// ----
// TypeError 8830: (56-59): Index expression cannot be omitted.
