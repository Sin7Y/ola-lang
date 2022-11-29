contract C {
  bytes s;
  fn f() external -> (bytes1) {
    bytes memory data = "abcd";
    s = data;
    return s[0];
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> "a"
