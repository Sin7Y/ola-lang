library L
{
	struct Nested
	{
		uint y;
	}
	fn f(fn(Nested memory) external) external pure {}
}
// ----
