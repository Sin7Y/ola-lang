contract Test {
  // This checks a scoping error,
  // the variable "a" was not visible
  // at the assignment.
  fn test(address _ext) external {
    try Test(_ext).test(_ext) {} catch {}
    u256 a = 1;
    a = 3;
  }
}
// ----
