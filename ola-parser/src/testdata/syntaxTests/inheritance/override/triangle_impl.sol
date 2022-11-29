contract A { fn f()  virtual {} }
contract B is A { fn f()  virtual override {} }
contract C is A, B { }
contract D is A, B { fn f()  override(A, B) {} }
// ----
// TypeError 6480: (116-138): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types.
