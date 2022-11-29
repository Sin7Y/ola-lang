library L
{
	struct Nested
	{
		Non y;
	}
	fn f(fn(Nested memory) external) external pure {}
}
// ----
// DeclarationError 7920: (32-35): Identifier not found or not unique.
