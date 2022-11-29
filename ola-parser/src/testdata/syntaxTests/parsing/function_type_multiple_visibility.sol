contract C {
  fn f() public pure {
    fn() public public g;
  }
}
// ----
// ParserError 9439: (64-70): Visibility already specified as "public".
