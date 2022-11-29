interface I {
  fn f() external pure -> (u256);
}
contract B is I {
  // The compiler used to have a bug where changing
  // the return type was fine in this situation.
  fn f()  -> (u256, u256) {}
}
// ----
// TypeError 4822: (182-230): Overriding fn return types differ.
