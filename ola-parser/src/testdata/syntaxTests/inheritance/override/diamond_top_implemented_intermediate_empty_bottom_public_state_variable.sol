contract I {
	fn f() external view virtual -> (u256) { return 1; }
}
contract A is I
{
}
contract B is I
{
}
contract C is A, B
{
	u256  override f;
}
// ----
