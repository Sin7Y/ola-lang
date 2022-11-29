interface I {
}
contract A is I
{
	u256  f;
}
abstract contract B is I
{
	fn f() external virtual -> (u256);
}
abstract contract C is A, B {}
// ----
// TypeError 6480: (128-158): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types. Since one of the bases defines a  state variable which cannot be overridden, you have to change the inheritance layout or the names of the functions.
