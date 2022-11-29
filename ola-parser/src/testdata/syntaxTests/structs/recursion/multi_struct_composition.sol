pragma abicoder               v2;

contract C {
  struct T { U u; V v; }

  struct U { W w; }

  struct V { W w; }

  struct W { uint x; }

  fn f(T memory) public pure { }
}
// ----
