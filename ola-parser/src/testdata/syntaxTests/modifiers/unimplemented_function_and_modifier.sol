abstract contract A {
  fn foo()  virtual;
  fn foo(u256 x) virtual  ->(u256);
  modifier mod() virtual;
}

contract B is A {
  fn foo(u256 x) override  ->(u256) {return x;}
  modifier mod() override { _; }
}

contract C is A {
  fn foo()  override {}
  modifier mod() override { _; }
}

contract D is A {
  fn foo()  override {}
  fn foo(u256 x) override  ->(u256) {return x;}
}

/* No errors */
contract E is A {
  fn foo()  override {}
  fn foo(u256 x) override  ->(u256) {return x;}
  modifier mod() override { _;}
}
// ----
// TypeError 3656: (137-254): Contract "B" should be marked as abstract.
// TypeError 3656: (256-344): Contract "C" should be marked as abstract.
// TypeError 3656: (346-466): Contract "D" should be marked as abstract.
