contract A {
  fn f() public virtual returns (uint) { g(); }
  fn g() internal virtual { revert(); }
}
contract B is A {
  fn f() public override returns (uint) { A.f(); }
  fn g() internal override {}
}
// ----
// Warning 6321: (52-56): Unnamed return variable can remain unassigned when the fn is called when "B" is the most derived contract. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6321: (173-177): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
