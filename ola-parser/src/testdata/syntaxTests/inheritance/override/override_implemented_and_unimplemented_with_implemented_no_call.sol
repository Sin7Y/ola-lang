contract A {
    fn f()  virtual {}
}
abstract contract B {
    fn f()  virtual;
}
contract C is A, B {
    fn f()  override(A, B) {
        // This is fine. The unimplemented B.f() is not used.
    }
}
// ----
