interface I {
    fn f() external;
    fn g() external;
}
abstract contract A is I {
    fn f() external {}
}
abstract contract B is I {
    fn g() external {}
}
contract C is A, B {
}
// ----
