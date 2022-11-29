contract C {
  fn f() public pure {
    fn() pure pure g;
  }
}
// ----
// ParserError 9680: (62-66): State mutability already specified as "pure".
