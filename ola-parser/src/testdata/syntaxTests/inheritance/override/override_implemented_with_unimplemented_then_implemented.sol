contract A {
    fn f()  virtual {}
}
abstract contract B is A {
    fn f()  virtual override;
}
contract C is B {
    fn f()  virtual override {}
}
// ----
// TypeError 4593: (81-118): Overriding an implemented fn with an unimplemented fn is not allowed.
