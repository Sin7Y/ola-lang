contract A {
    fn f()  virtual {}
}
abstract contract B {
    fn f()  virtual;
}
contract C is A, B {
    fn f()  override(A, B) {
        super.f(); // super should skip the unimplemented B.f() and call A.f() instead.
    }
}
// ----
