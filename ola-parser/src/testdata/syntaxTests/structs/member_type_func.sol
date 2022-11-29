contract C {
  fn f() public {}
  struct S {f x;}
  fn g(fn(S memory) external) public {}
}
// ----
// TypeError 5172: (50-51): Name has to refer to a struct, enum or contract.
