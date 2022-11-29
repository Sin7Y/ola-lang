abstract contract A {
    modifier m() virtual;
    fn f() m  virtual {}
}
abstract contract B is A {
    fn f()  override {}
}
// ----
