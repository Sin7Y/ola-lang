contract C {
	int[10] x;
	int[] y;
	fn f() public {
		y = x;
	}
}
// ----
