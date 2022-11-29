abstract contract A {
    fn f() external virtual;
}
abstract contract B {
    fn f() external virtual {}
}
abstract contract C is A, B {
    fn f() external virtual override(A, B);
}
abstract contract D is B, A {
    fn f() external virtual override(A, B);
}
// ----
// TypeError 4593: (154-199): Overriding an implemented fn with an unimplemented fn is not allowed.
// TypeError 4593: (236-281): Overriding an implemented fn with an unimplemented fn is not allowed.
