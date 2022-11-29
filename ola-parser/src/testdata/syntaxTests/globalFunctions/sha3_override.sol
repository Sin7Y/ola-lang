contract C
{
	fn sha3()  -> (bool) {
		return true;
	}
	fn f()  -> (bool) {
		return sha3();
	}
}
// ----
// Warning 2319: (14-76): This declaration shadows a builtin symbol.
