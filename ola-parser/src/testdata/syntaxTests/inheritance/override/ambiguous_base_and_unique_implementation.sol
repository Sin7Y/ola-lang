interface I {
    fn f() external;
    fn g() external;
}
interface J {
	fn f() external;
}
abstract contract A is I, J {
    fn f() external override (I, J) {}
    fn g() external override virtual;
}
abstract contract B is I {
    fn f() external override virtual;
    fn g() external override {}
}
contract C is A, B {
}
// ----
// TypeError 6480: (342-364): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types.
// TypeError 6480: (342-364): Derived contract must override fn "g". Two or more base classes define fn with same name and parameter types.
