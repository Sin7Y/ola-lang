contract I {
	fn f() external view virtual -> (u256) { return 1; }
}
contract A is I
{
	u256  override f;
}
contract B is I
{
}
contract C is A, B {}
// ----
// TypeError 6480: (145-166): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types. Since one of the bases defines a  state variable which cannot be overridden, you have to change the inheritance layout or the names of the functions.
