contract C {
	fn f()  {
		u256 now = block.timestamp;
		now;
	}
}
// ----
// Warning 2319: (43-51): This declaration shadows a builtin symbol.
