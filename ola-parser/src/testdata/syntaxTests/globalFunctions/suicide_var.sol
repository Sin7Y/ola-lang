contract C
{
	fn f()  -> (bool) {
		bool suicide = true;
		return suicide;
	}
}
// ----
// Warning 2319: (58-70): This declaration shadows a builtin symbol.
