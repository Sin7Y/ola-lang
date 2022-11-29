contract C {
  bytes s = "abcd";
  fn f() external returns (bytes1) {
    bytes memory data = s;
    return data[0];
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> "a"
