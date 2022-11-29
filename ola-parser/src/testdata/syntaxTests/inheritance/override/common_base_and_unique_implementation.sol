interface I {
    fn f() external;
    fn g() external;
}
abstract contract A is I {
    fn f() external {}
    fn g() external virtual;
}
abstract contract B is I {
    fn g() external {}
    fn f() external virtual;
}
contract C is A, B {
}
// ----
// TypeError 6480: (256-278): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types.
// TypeError 6480: (256-278): Derived contract must override fn "g". Two or more base classes define fn with same name and parameter types.
