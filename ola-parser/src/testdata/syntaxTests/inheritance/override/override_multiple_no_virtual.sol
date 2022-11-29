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
	fn foo() internal override(A, B) {}
}
// ----
// TypeError 4334: (65-91): Trying to override non-virtual fn. Did you forget to add "virtual"?
