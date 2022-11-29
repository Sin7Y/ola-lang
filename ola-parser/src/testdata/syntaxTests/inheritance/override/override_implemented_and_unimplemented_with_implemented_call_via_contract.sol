contract A {
    fn f()  virtual {}
}
abstract contract B {
    fn f()  virtual;
}
contract C is A, B {
    fn f()  virtual override(A, B) {
        B.f(); // Should not skip over to A.f() just because B.f() has no implementation.
    }
}
// ----
// TypeError 7501: (185-190): Cannot call unimplemented base fn.
