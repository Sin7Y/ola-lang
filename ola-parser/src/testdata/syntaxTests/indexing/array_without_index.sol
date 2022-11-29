contract C {
  fn f()  {
    bytes memory a;
    a[];
  }
}
// ----
// TypeError 9689: (61-64): Index expression cannot be omitted.
