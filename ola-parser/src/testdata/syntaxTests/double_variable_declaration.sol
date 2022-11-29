contract test {
	fn f()   {
		u256 x;
		x = 1;
		if (true) { u256 x; x = 2; }
	}
}
// ----
// Warning 2519: (80-89): This declaration shadows an existing declaration.
