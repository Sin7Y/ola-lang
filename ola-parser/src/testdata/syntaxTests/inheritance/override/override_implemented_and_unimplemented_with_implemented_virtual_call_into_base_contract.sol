contract A {
    fn f()  virtual {}
}
abstract contract B {
    fn f()  virtual;
}
abstract contract C is A, B {
    fn g()  {
        f(); // Would call B.f() if we did not require an override in C.
    }
}
// ----
// TypeError 6480: (107-243): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types.
