contract A
{
	fn foo() virtual internal {}
}
contract B
{
	fn foo() internal {}
}
contract C is A, B
{
}
// ----
// TypeError 6480: (94-116): Derived contract must override fn "foo". Two or more base classes define fn with same name and parameter types.
