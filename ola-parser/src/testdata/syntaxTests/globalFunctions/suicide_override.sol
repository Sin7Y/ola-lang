contract C
{
	fn suicide()  -> (bool) {
		return true;
	}
	fn f()  -> (bool) {
		return suicide();
	}
}
// ----
// Warning 2319: (14-79): This declaration shadows a builtin symbol.
