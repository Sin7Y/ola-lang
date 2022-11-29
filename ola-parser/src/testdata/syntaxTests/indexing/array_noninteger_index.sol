contract C {
  fn f()  {
    bytes[32] memory a;
    a[888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888];
  }
}
// ----
// TypeError 7407: (67-178): Type int_const 8888...(103 digits omitted)...8888 is not implicitly convertible to expected type u256. Literal is too large to fit in u256.
