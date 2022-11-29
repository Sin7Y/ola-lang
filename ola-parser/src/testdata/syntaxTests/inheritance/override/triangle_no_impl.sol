abstract contract A { fn f()  virtual; }
contract B is A { fn f()  virtual override {} }
contract C is A, B { }
contract D is A, B { fn f()  override(A, B) {} }
// ----
