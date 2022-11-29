interface I {
	fn f() external -> (u256);
}
abstract contract A is I
{
	u256  f;
}
abstract contract B is I
{
}
// This is fine because `f` is not implemented in `I` and `A.f` is the only mention below `I`.
abstract contract C is A, B {}
// ----
