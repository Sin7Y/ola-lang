contract C {
  fn f()  {
    bytes[32] memory a;
    a[-1];
  }
}
// ----
// TypeError 7407: (67-69): Type int_const -1 is not implicitly convertible to expected type u256. Cannot implicitly convert signed literal to unsigned type.
