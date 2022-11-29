interface I {
    fn f() external;
    fn g() external;
}
interface J {
	fn f() external;
}
abstract contract A is I, J {
    fn f() external override (I, J) {}
}
abstract contract B is I {
    fn g() external override {}
}
contract C is A, B {
}
// ----
// TypeError 6480: (254-276): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types.
