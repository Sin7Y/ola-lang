contract C {
  fn f() public pure {
    assembly "failasm" {}
  }
}
// ----
// ParserError 4531: (55-64): Only "evmasm" supported.
