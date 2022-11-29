contract C {
  fn f() internal pure returns (uint, uint, uint, uint) {
    (uint a, uint b,,) = f();
    a; b;
  }
  fn g() internal pure {
    (bytes memory a, string storage b) = h();
    a; b;
  }
  fn h() internal pure returns (bytes memory, string storage s) { s = s; }
}
// ----
// Warning 5740: (111-115): Unreachable code.
// Warning 6321: (250-262): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
