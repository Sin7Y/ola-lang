contract C0 {
  fn f() external {}
  fn f(int) external {}
  fn f2() external {}
}
fn f() {}
contract C {
  fn f() external {}
}
contract C2 is C0 {}
// ----
// Warning 2519: (16-40): This declaration shadows an existing declaration.
// Warning 2519: (43-70): This declaration shadows an existing declaration.
// Warning 2519: (132-156): This declaration shadows an existing declaration.
