contract C {
  int[] data;
  fn f() public returns (uint) {
    data.push(1);
    (data.pop)();
    return data.length;
  }
}
// ====
// compileViaYul: also
// ----
// f() -> 0
