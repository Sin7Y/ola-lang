interface A {
    fn f() external;
}
interface B {
    fn f() external;
}
abstract contract C is A, B {
    fn f() external virtual override(A, B);
}
// ----
