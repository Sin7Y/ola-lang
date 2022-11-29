contract I {
	fn f() external view virtual -> (u256) { return 1; }
}
contract A is I
{
	u256  override f;
}
contract B is I
{
	fn f() external pure virtual override -> (u256) { return 2; }
}
contract C is A, B {}
// ----
// TypeError 6480: (219-240): Derived contract must override fn "f". Two or more base classes define fn with same name and parameter types. Since one of the bases defines a  state variable which cannot be overridden, you have to change the inheritance layout or the names of the functions.
